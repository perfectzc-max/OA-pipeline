#计算cov
#导入文件
cov=read.table("99.cov")
len=read.table("genome_size.txt")
#修改列名
colnames(cov)=c("cov","sc","snv22","snvx","indel22","indelx")
cov$num=sum(len[len$V1!="chrX"&len$V1!="chrY",2])
cov$x=len[len$V1=="chrX",2]
cov$cov_numsnv=cov$snv22/cov$num
cov$cov_numindel=cov$indel22/cov$num

#cov$total=(cov$snv22+cov$snvx)/3086910193
cov_indel=cov[,c(2,5,10)]
save(cov,file = "cov_indel.Rdata")
cov=cov[,c(2,3,9)]
save(cov,file = "cov.Rdata")
#计算sen
sen=read.table("99.sen")
#修改列名
colnames(sen)=c("sen","sc","obsnv22","misssnv22","obsnvx","misssnvx","obid22","missid22","obidx","missidx")
sen$sen22=sen$obsnv22/(sen$obsnv22+sen$misssnv22)
sen$all22=(sen$obsnv22+sen$misssnv22)

sen$sen22indel=sen$obid22/(sen$obid22+sen$missid22)
sen$all22indel=(sen$obid22+sen$missid22)

sen_indel=sen[,c(2,7,14,13)]
save(sen,file = "sen_indel.Rdata")
sen=sen[,c(2,3,12,11)]
save(sen,file = "sen.Rdata")

#算一下平均覆盖度
cov_mean=read.table("cov_mean.txt")
cov_20=read.table("cov_20x.txt")
 
cov_mean=cov_mean[,c(1,6)]
cov_20=cov_20[,c(1,6)]
cov_sum=left_join(cov_mean,cov_20,by="V1")
colnames(cov_sum)=c("sc","mean","20x")
cov_sum$mean=as.numeric(substr(cov_sum$mean,1,5))
cov_sum$`20x`=as.numeric(str_remove_all(cov_sum$`20x`,"%"))


cov_sum=cov_sum[!str_detect(cov_sum$sc,"_P"),]
cov_sum=cov_sum[!str_detect(cov_sum$sc,"P_"),]
cov_sum$sc=str_replace_all(cov_sum$sc,'_','-')
#平均测序深度
mean(cov_sum$mean[str_detect(cov_sum$sc,"B")])
sd(cov_sum$mean[str_detect(cov_sum$sc,"B")])
summary(cov_sum$mean[str_detect(cov_sum$sc,"B")])

mean(cov_sum$mean[cov_sum$sc %in% num_snv$sc])
sd(cov_sum$mean[cov_sum$sc %in% num_snv$sc])

#20x百分比
mean(cov_sum$`20x`[str_detect(cov_sum$sc,"B")])
sd(cov_sum$`20x`[str_detect(cov_sum$sc,"B")])
summary(cov_sum$`20x`[str_detect(cov_sum$sc,"B")])

mean(cov_sum$`20x`[cov_sum$sc %in% num_snv$sc])
sd(cov_sum$`20x`[cov_sum$sc %in% num_snv$sc])






