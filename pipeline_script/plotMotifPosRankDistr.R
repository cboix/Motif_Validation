options(stringsAsFactors=FALSE)

Args<-commandArgs()[grep("^--",commandArgs(),invert=T)]
#
print(Args)
inputOlFile=Args[2]
motif=Args[3]
outdir=Args[4]
cmd=sprintf("grep %s %s|tr '|' '\t'|tr ' '  '\t' ",motif,inputOlFile)
#
#cmd
df=read.table(pipe(cmd),sep="\t")

system(sprintf("mkdir -p %s",outdir))

mpos=as.integer((df[,3]+df[,4])/2)
ppos=as.integer((df[,10]+df[,11])/2)

distances=abs(mpos-ppos)
ranks=df[,13]


pdf(sprintf("%s/%s.pdf",outdir,motif),height=4,width=8)
par(mfrow=c(1,2))
hist(distances,10,col='red',xlab="Distance to Peak Center(bp)" ,main="Position Distribution" )
hist(ranks,10,col='blue',xlab="Peak Rank",main="Peak-Rank Distribution" )

dev.off()

Sys.setenv("DISPLAY"=":0.0")
#print(sprintf("%s/%s.png",outdir,motif))
png(sprintf("%s/%s.png",outdir,motif),height=4,width=8,units = "in",res=80,type="cairo" )
par(mfrow=c(1,2))
hist(distances,10,col='red',xlab="Distance to Peak Center(bp)" ,main="Position Distribution" )
hist(ranks,10,col='blue',xlab="Peak Rank",main="Peak-Rank Distribution" )

dev.off()












