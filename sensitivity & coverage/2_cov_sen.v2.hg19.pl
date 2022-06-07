#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

#=cut
my $P;
my $bulk;
my $cell; 
my $chr;
my $path;
my $dir;

GetOptions(
	'g=s' => \$P,
	'p=s' => \$path,
	'b=s' => \$bulk,
	'c=s' => \$cell,
	'd=s' => \$dir,
	'r=s' => \$chr,
);

my $refgenome="/Software/Refs/references/Homo_sapiens/GATK/GRCh37/Sequence/WholeGenomeFasta/human_g1k_v37_decoy.fasta";

#把vcf文件中符合条件的、有内容的每一行，序列映射到SNV和INDEL上，记录在ht中
open(F,"/Jan-Lab/zhengchen/correct_cov/cov_sen/bulk/$bulk\.hs.vcf");
my $ht={};
while (my $content=<F>) {
	my @data=split(/\t/,$content);
	#如果REF和ALE中任何一个没有内容就忽略
	next if ($data[3]=~m/\,/ || $data[4]=~m/\,/);
	#只有是1号染色体才继续
	next unless ($data[0] eq $chr);
	if (length($data[3])==1 && length($data[4])==1) { # SNV
		$ht->{SNV}->{$data[0]}->{$data[1]}=$data[4];
	}
	if (length($data[3])>1 || length($data[4])>1) { # INDEL
		$ht->{INDEL}->{$data[0]}->{$data[1]}="$data[3]\t$data[4]";
	}
}
close(F);
print STDERR "bulk finished\n";

#对bam文件进行samtools mpileup，并把文件输出到F1中
#这一步特别费时，能不能把弄好的文件直接输入
#-r –region STR 只在指定区域产生pileup，需要已建立索引的bam文件。通常和-l参数一起使用。
#由于用了这个参数，所以必须得定好$chr,跑循环应该是？
open(F1,"samtools mpileup -C50 -f $refgenome -s -r $chr $dir\/$bulk\.recal.bam |");
open(F2,"samtools mpileup -C50 -f $refgenome -q 40 -s -r $chr $path\/$cell\.recal.bam |");


#这里是直接打开文件还是把内容输入进去？
##将生成的R1\R2以写入方式打开，将文件指针指向文件头并将文件大小截为零。如果文件不存在则尝试创建之。

open(R1,">/Jan-Lab/zhengchen/correct_cov/cov_sen/${P}/cov/SNV/$cell\/$cell\.$chr\.bed");
open(R2,">/Jan-Lab/zhengchen/correct_cov/cov_sen/${P}/cov/INDEL/$cell\/$cell\.$chr\.bed");
my $start_SNV=0;
my $start_INDEL=0;
my $end_SNV;
my $end_INDEL;
my $htc={};

#把F1和F2的内容放进去
my $content_bulk=<F1>;
my $content_cell=<F2>;
while ( defined $content_bulk || defined $content_cell ) {
#用 chomp 剔除输入数据末尾的换行符，有助于避免在当前使用场合对那些值作出错误的解释!
	chomp $content_bulk;
	chomp $content_cell;
	#print "$content_bulk\t$content_cell\n";
	my @data_bulk=split(/\t/,$content_bulk);
	my @data_cell=split(/\t/,$content_cell);
#bulk和cell中都出现的位置	
	if ($data_bulk[1]==$data_cell[1]) {
		#remove head part with possible +/-
		# $data_bulk[4] =~ s/\^.//g if ($data_bulk[4]=~m,\^,);
		#no * in base list ($data[4])
		#no indel in bulk 
		# if ($data_bulk[4]=~m,\*, || $data_cell[4]=~m,\*, || $data_bulk[4]=~m,\+, || $data_bulk[4]=~m,\-,) {
		
		# only remove * itself
		
		#‘*’代表模糊碱基
		#bulk和cell都有值，不然就什么也不处理
		if ($data_bulk[4] eq "\*" || $data_cell[4] eq "\*") {
			; # go to next
		}
		
		#在bulk和cell都不是模糊碱基的列中进行下列操作
		else {
			#print STDERR "$data_cell[1]\t$data_cell[3]\t$data_cell[6]\t$data_bulk[3]\t$data_bulk[6]\n";####
			# depth for cell
			#对比上的reads数目
			#结果会有一个第七行，mapping quality
			for (my $i=0; $i<length($data_cell[6]); $i++) {
				my $sub=substr($data_cell[6],$i,1);
				$data_cell[3]-- if (ord($sub)-33<40); # 40
			}
			if ($data_cell[3]<20) {
				; # go to next
			}
			#如果depth不小于20、把质量差的reads不算在里面，则执行这些
			#得高质量的reads数大于20才进行下面的步骤（indel的则要大于30）
			#把符合条件的SNV和INdel重新记录到htc变量中
			else {
				# for sensitivity
				if (exists $ht->{SNV}->{$data_cell[0]}->{$data_cell[1]}) {
					my $temp=$ht->{SNV}->{$data_cell[0]}->{$data_cell[1]};
					$htc->{SNV}->{$data_cell[0]}->{$data_cell[1]}=$temp;
				}
				if (exists $ht->{INDEL}->{$data_cell[0]}->{$data_cell[1]} && $data_cell[3]>=30) {
					my $temp=$ht->{INDEL}->{$data_cell[0]}->{$data_cell[1]};
					$htc->{INDEL}->{$data_cell[0]}->{$data_cell[1]}=$temp;
				}
				# depth for bulk
				#对bulk进行处理，但是质量要求较低
				for (my $i=0; $i<length($data_bulk[6]); $i++) {
					my $sub=substr($data_bulk[6],$i,1);
					$data_bulk[3]-- if (ord($sub)-33<20); # 20
				}
				if ($data_bulk[3]<20) {
					; # go to next
				}
				else {
					# for SNV coverage
					#染色体记录起始的位置
					if ($start_SNV==0) {
						$start_SNV=$data_cell[1];
						$end_SNV=$data_cell[1];
					}
					#记录每一个的染色体、起始位置和结束位置
					else {
						if ($data_cell[1]-$end_SNV>1) {
							print R1 "$chr\t$start_SNV\t$end_SNV\n";
							$start_SNV=$data_cell[1];
							$end_SNV=$data_cell[1];
						}
						else {
							$end_SNV=$data_cell[1];
						}
					}
					
					if ($data_cell[3]>=30) {
						# for indel coverage
						#记录起始位置
						if ($start_INDEL==0) {
							$start_INDEL=$data_cell[1];
							$end_INDEL=$data_cell[1];
						}
						else {
							#记录每一个的染色体、起始位置和结束位置
							if ($data_cell[1]-$end_INDEL>1) {
								print R2 "$chr\t$start_INDEL\t$end_INDEL\n";
								$start_INDEL=$data_cell[1];
								$end_INDEL=$data_cell[1];
							}
							else {
								$end_INDEL=$data_cell[1];
							}
						}
					}
				}
			}
		}
		$content_bulk=<F1>;
		$content_cell=<F2>;
		last if ((! defined $content_bulk) || (! defined $content_cell));
	}
	#如果bulk大于cell就读取下一个cell的值
	elsif ($data_bulk[1]>$data_cell[1]) {
		$content_cell=<F2>;
		last if (! defined $content_cell);
	}
	elsif ($data_bulk[1]<$data_cell[1]) {
		$content_bulk=<F1>;
		last if (! defined $content_bulk);
	}
	else {
		print STDERR "error in $data_bulk[1] and $data_cell[1]\n";
		exit(0);
	}
}




print R1 "$chr\t$start_SNV\t$end_SNV\n";
print R2 "$chr\t$start_INDEL\t$end_INDEL\n";
close(R2);
close(R1);
close(F2);
close(F1);
print STDERR "mpileup finished\n";

#开始记录sensitivity的相关文件
open(F,"/Jan-Lab/zhengchen/sccaller/$P/$cell\_vs_B.vcf");
open(R1,">/Jan-Lab/zhengchen/correct_cov/cov_sen/${P}/sen/SNV/$cell\/$cell\.$chr\.bed");
open(R2,">/Jan-Lab/zhengchen/correct_cov/cov_sen/${P}/sen/INDEL/$cell\/$cell\.$chr\.bed");
while (my $content=<F>) {
	next if ($content=~m,\#,);
	my @data=split(/\t/,$content);
	#只处理这个染色体
	next if ($data[0] ne $chr);
	#只处理没通过的过滤的文本
	next if (length($data[6])>1);
	my @word=split(/\:/,$data[9]);
	#只处理杂合位点
	next if ($word[0] ne "0/1");
	#R1写入SNV的染色体、位置、突变后碱基
	#删掉htc里面对应的位置
	if (length($data[4])==1) {
		if (exists $htc->{SNV}->{$data[0]}->{$data[1]}) {
			my $temp=$htc->{SNV}->{$data[0]}->{$data[1]};
			print R1 "$data[0]\t$data[1]\t$data[4]\t$temp\ttop\n";
			$htc->{SNV}->{$data[0]}->{$data[1]}="NA";
		}
	}
	#R1写入indel的染色体、位置、突变后碱基
	#删掉htc里面对应的位置
	else {
		if (exists $htc->{INDEL}->{$data[0]}->{$data[1]}) {
			my $temp=$htc->{INDEL}->{$data[0]}->{$data[1]};
			print R2 "$data[0]\t$data[1]\t$data[4]\t$temp\ttop\n";
			$htc->{INDEL}->{$data[0]}->{$data[1]}="NA";
		}
	}
	
}
close(F);
#把没有删掉的拿出来，写的是染色体、位置、0
foreach my $key (keys %{$htc->{SNV}->{$chr}}) {
	next if ($htc->{SNV}->{$chr}->{$key} eq "NA");
	my $temp=$htc->{SNV}->{$chr}->{$key};
	print R1 "$chr\t$key\t0\t$temp\tbot\n";
}
close(R1);
foreach my $key (keys %{$htc->{INDEL}->{$chr}}) {
	next if ($htc->{INDEL}->{$chr}->{$key} eq "NA");
	my $temp=$htc->{INDEL}->{$chr}->{$key};
	print R2 "$chr\t$key\t0\t$temp\tbot\n";
}
close(R2);
