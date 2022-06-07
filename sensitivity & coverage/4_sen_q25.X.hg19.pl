#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

my $cell; 
my $P; 

GetOptions(
	'c=s' => \$cell,
	'g=s' => \$P,
);

my $quality=25;

print $cell;

my $SNV_bot=0;
my $SNV_top=0;
my $SNV_bot_X=0;
my $SNV_top_X=0;


#对上一步生成的文件进行处理
for (my $i=1; $i<=22; $i++) {
	open(F,"/Jan-Lab/zhengchen/correct_cov/cov_sen/${P}/sen/SNV/$cell/$cell.$i.bed");
	while (my $content=<F>) {
		$SNV_bot++ if ($content=~m,bot,);
		$SNV_top++ if ($content=~m,top,);
	}
	close(F);
}
#print "sen\t$cell\t$SNV_top\t$SNV_bot";

{
	$SNV_bot_X=0; $SNV_top_X=0;
	open(F,"/Jan-Lab/zhengchen/correct_cov/cov_sen/${P}/sen/SNV/$cell/$cell.X.bed");
	while (my $content=<F>) {
		$SNV_bot_X++ if ($content=~m,bot,);
		$SNV_top_X++ if ($content=~m,top,);
	}
	close(F);
#	print "\t$SNV_top\t$SNV_bot";
}


my $INDEL_bot=0;
my %INDEL_top_list;
for (my $i=1; $i<=22; $i++) {
	open(F,"/Jan-Lab/zhengchen/correct_cov/cov_sen/${P}/sen/INDEL/$cell/$cell.$i.bed");
	while (my $content=<F>) {
		$INDEL_bot++ if ($content=~m,bot,);
		if ($content=~m,top,) {
			chomp $content;
			my @data=split(/\t/,$content);
			$INDEL_top_list{"$data[0]\_$data[1]"}=1;
		}
	}
	close(F);
}

my $INDEL_bot_X=0;
my %INDEL_top_list_X;
{
	open(F,"/Jan-Lab/zhengchen/correct_cov/cov_sen/${P}/sen/INDEL/$cell/$cell.X.bed");
	while (my $content=<F>) {
		$INDEL_bot_X++ if ($content=~m,bot,);
		if ($content=~m,top,) {
			chomp $content;
			my @data=split(/\t/,$content);
			$INDEL_top_list_X{"$data[0]\_$data[1]"}=1;
		}
	}
	close(F);
}


my $INDEL_top=0;
my $INDEL_top_X=0;
open(F,"/Jan-Lab/zhengchen/sccaller/${P}/$cell\_vs_B.vcf");
while (my $content=<F>) {
	next if ($content=~m,\#,);
	my @data=split(/\t/,$content);
	if (exists $INDEL_top_list{"$data[0]\_$data[1]"}) {
		if ($data[5]>=$quality) {
			$INDEL_top++;
		}
		else {
			$INDEL_bot++;
		}
	}
	if (exists $INDEL_top_list_X{"$data[0]\_$data[1]"}) {
		if ($data[5]>=$quality) {
			$INDEL_top_X++;
		}
		else {
			$INDEL_bot_X++;
		}
	}
}
close(F);

open(F,">/Jan-Lab/zhengchen/correct_cov/cov_sen/$P/$cell.sen");
print F "sen\t$cell\t$SNV_top\t$SNV_bot\t$SNV_top_X\t$SNV_bot_X\t$INDEL_top\t$INDEL_bot\t$INDEL_top_X\t$INDEL_bot_X\n";
close(F);

