mydata <- read.csv('/Users/ymyung/Desktop/mCSM_AB2/8_DEC/1810_signatures_features.csv',header=1,check.names=FALSE)

library(dplyr)
dat_forward <- data.frame(cond=factor(rep(c("forward"),each=905)), DDG = mydata$DDG[1:905])
dat_all <- data.frame(cond=factor(rep(c("all"),each=1810)), DDG=mydata$DDG)
dat_merged <- rbind(dat_forward, dat_all)


library(plyr)
cdat_forward <- ddply(dat_forward, "cond", summarise, rating.mean=mean(DDG))
cdat_all <- ddply(dat_all, "cond", summarise, rating.mean=mean(DDG))
cdat_merged <- ddply(dat_merged, "cond", summarise, rating.mean=mean(DDG))

gg_forward <- ggplot(dat_forward, aes(x=DDG)) +geom_histogram(binwidth=.5, alpha=.5, fill="black", colour="black", position="identity") + geom_vline(data=cdat_forward, aes(xintercept=rating.mean), color="black",linetype="dashed",size=0.7) + scale_x_continuous(limits=c(-10,10))+theme(legend.position="none", panel.border = element_rect(linetype="solid",fill=NA, size=1.5),plot.title = element_text(face="bold",size=20,hjust = 0.5,vjust=2), panel.background = element_blank(), axis.title.y = element_text(size=17,vjust=1),axis.title.x = element_text(size=17, vjust=--0.5), axis.text.x=element_text(size=15, colour="black"),axis.text.y=element_text(size=15, colour="black"),plot.margin = unit(c(1.5,1.5,1.5,1.5), "lines")) +
  labs(title="Forward mutation",x=expression(Experimental~Delta*Delta*G[italic("Affinity")]~(Kcal/mol)),y=expression("Count")) 

# gg_all <- ggplot(dat_all, aes(x=DDG)) +theme_bw()+ geom_histogram(binwidth=.5, alpha=.5, fill="#70706F", colour="black", position="identity") + geom_vline(data=cdat_all, aes(xintercept=rating.mean),color="black", linetype="dashed",size=0.7)+ scale_x_continuous(limits=c(-10,10))+ theme(legend.position="none",panel.border = element_rect(linetype="solid",fill=NA, size=1.5),plot.title = element_text(hjust = 0.5), panel.background = element_blank(),axis.title.y = element_text(size=20),axis.title.x = element_text(size=20), axis.text.x=element_text(size=15),axis.text.y=element_text(size=15),plot.margin = unit(c(1,1,1,1), "lines")) +
#   labs(x=expression(bold(Experimental~Delta*Delta*G[italic("Affinity")])),y=expression(bold("count"))) 

# For Paper
gg_merged <- ggplot(dat_merged, aes(x=DDG,fill=cond)) + geom_histogram(binwidth=.5, alpha=.5, colour="black", position="identity") + geom_vline(data=cdat_merged[2,], aes(xintercept=rating.mean), linetype="dashed",size=0.7)+ scale_x_continuous(limits=c(-10,10))+ theme(legend.position="none",panel.border = element_rect(linetype="solid",fill=NA, size=1.5),plot.title = element_text(face="bold",size=20,hjust = 0.5,vjust=2), panel.background = element_blank(),axis.title.y = element_text(size=17,vjust=1),axis.title.x = element_text(size=17, vjust=-0.5), axis.text.x=element_text(size=15, colour = "black"),axis.text.y=element_text(size=15, colour = "black"),plot.margin = unit(c(1.5,1.5,1.5,1.5), "lines")) +
  labs(title="Forward and reverse mutation",x=expression(Experimental~Delta*Delta*G[italic("Affinity")]~(Kcal/mol)),y=expression("Count")) +scale_fill_manual(values=c("black","grey"))

# For Poster
ggplot(dat_merged, aes(x=DDG,fill=cond)) + geom_histogram(binwidth=.5, alpha=0.5, colour="black", position="identity") + geom_vline(data=cdat_merged[2,], aes(xintercept=rating.mean), linetype="dashed",size=0.7)+ scale_x_continuous(limits=c(-10,10))+ theme(legend.position="none",panel.border = element_rect(linetype="solid",fill=NA, size=1.5),plot.title = element_text(face="bold",size=20,hjust = 0.5,vjust=2), panel.background = element_blank(),axis.title.y = element_text(size=17,vjust=1),axis.title.x = element_text(size=17, vjust=-0.5), axis.text.x=element_text(size=15, colour = "black"),axis.text.y=element_text(size=15, colour = "black"),plot.margin = unit(c(1.5,1.5,1.5,1.5), "lines")) +
  labs(x=expression(Experimental~Delta*Delta*G[italic("Affinity")]~(Kcal/mol)),y=expression("Count")) +scale_fill_manual(values=c("black","darkolivegreen"))


library(ggpubr)
png("/Users/ymyung/Desktop/mCSM_AB2/8_DEC/Figure_S4.png",width=12,heigh=5,units='in',res=500)
#ggarrange(gg_forward,gg_all+rremove("y.title"),ncol=2,nrow=1)
ggarrange(gg_forward,gg_merged+rremove("y.title"),ncol=2,nrow=1)
dev.off()
