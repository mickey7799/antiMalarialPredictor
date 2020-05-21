library(dplyr)
library(plyr)
library(ggplot2)
library(stringr)
library(RColorBrewer)
library(ggpubr)

mydata <- read.csv('/Users/mickey/projects/PlasmoCSM/data_all/activity.csv',header=1,check.names=FALSE)
auxiliary_all <- read.csv('/Users/mickey/projects/PlasmoCSM/pdcsm/output_all.pdCSM_no.csv',header=1,check.names=FALSE)
colnames(mydata) <- c("Molecule_ID" ,  "Activity_Value" ,"Activity_Type" , "Activity")
auxiliary_all <- left_join(mydata, auxiliary_all, by = c("Molecule_ID" = "CLASS"))
auxiliary_all <- auxiliary_all[Reduce(`&`, lapply(auxiliary_all, function(x) !is.na(x)  & is.finite(x))),]

#auxiliary$log_activity_value <- log(auxiliary$Activity_Value) 
#auxiliary <- filter(auxiliary, Activity_Type == "Potency(nM)")
#write.csv(auxiliary,'/Users/mickey/projects/PlasmoCSM/data＿all/auxiliary_raw_cor.csv', row.names = FALSE)
datasource <- read.csv('/Users/mickey/projects/PlasmoCSM/data_all/molecule.csv',header=1,check.names=FALSE)
datasource_count <- datasource %>% count("Origin")
datasource_all <- left_join(mydata, datasource, by = c("Molecule_ID" = "Molecule ID"))
datasource_activity_count <- datasource_all %>% count(c("Origin","Activity"))
write.csv(datasource_activity_count,'/Users/mickey/projects/PlasmoCSM/datasource_activity_count.csv', row.names = FALSE)

# reading data
auxiliary <- read.csv('/Users/mickey/projects/PlasmoCSM/data_all/auxiliary_raw_cor.csv',header=1,check.names=FALSE)
graph_based <- read.csv('/Users/mickey/projects/PlasmoCSM/potency_output_all.pdCSM_pharm_1_20_combined_activity_train_classification_dropna.csv',header=1,check.names=FALSE)
source <- read.csv('/Users/mickey/projects/PlasmoCSM/data_all/molecule.csv',header=1,check.names=FALSE)

#checking counts of each Activity_Type  
mydata_count <- mydata %>% count("Activity_Type")
mydata_count$percent <- round(mydata_count$freq / sum(mydata_count$freq),4) *100
df <- mydata_count[order(-mydata_count$freq),]
write.csv(df,'/Users/mickey/projects/PlasmoCSM/data＿all/datasource.csv', row.names = FALSE)

#check class activity distribution for whole dataset
mydata_activity_count <- mydata %>% count("Activity")
colnames(mydata_activity_count) <- c("Activity", "Count")
bar_class_all <- ggplot(data=mydata_activity_count, aes(x=Activity, y=Count, fill=Activity)) +
  geom_bar(stat="identity") 

#filter Potency(nM)
#potency_data <- filter(mydata, Activity_Type == "Potency(nM)")
#potency_data <- auxiliary
potency_data <- auxiliary_all
potency_data <- potency_data[Reduce(`&`, lapply(potency_data, function(x) !is.na(x)  & is.finite(x))),]
potency_data$Activity_Value_log <- log(potency_data$Activity_Value)*(-1)
potency_data_mean <- ddply(potency_data, "Activity_Type", summarise, activity_mean=mean(Activity_Value))

#check class activity distribution
potency_data_count <- auxiliary %>% count("Activity")
colnames(potency_data_count) <- c("Activity", "Count")

#plot the potency distribution
#gg_potency <- ggplot(potency_data, aes(x=Activity_Value_log, color=Activity)) +geom_histogram(binwidth=.5, alpha=.5, fill="black", colour="black", position="identity") + geom_vline(data=potency_data_mean, aes(xintercept=log(activity_mean)), color="black",linetype="dashed",size=0.7) + scale_x_continuous(limits=c(-12,0))+theme(legend.position="none", panel.border = element_rect(linetype="solid",fill=NA, size=1.5),plot.title = element_text(face="bold",size=20,hjust = 0.5,vjust=2), panel.background = element_blank(), axis.title.y = element_text(size=17,vjust=1),axis.title.x = element_text(size=17, vjust=--0.5), axis.text.x=element_text(size=15, colour="black"),axis.text.y=element_text(size=15, colour="black"),plot.margin = unit(c(1.5,1.5,1.5,1.5), "lines")) +
 # labs(title="Potency Distribution",x=expression("log(Potency(M))"),y=expression("Count")) 

gg_potency <- ggplot(potency_data, aes(x=Activity_Value_log, color=Activity)) +geom_histogram(binwidth=.5, alpha=.5, fill="white") + theme(legend.position="top") + geom_vline(data=potency_data_mean, aes(xintercept=log(activity_mean)*(-1)), color="black",linetype="dashed",size=0.7) + scale_x_continuous(limits=c(-11,0))+theme(panel.border = element_rect(linetype="solid",fill=NA, size=1.5),plot.title = element_text(face="bold",size=20,hjust = 0.5,vjust=2), panel.background = element_blank(), axis.title.y = element_text(size=17,vjust=1),axis.title.x = element_text(size=17, vjust=--0.5), axis.text.x=element_text(size=15, colour="black"),axis.text.y=element_text(size=15, colour="black"),plot.margin = unit(c(1.5,1.5,1.5,1.5), "lines")) +
  labs(title="Potency Distribution",x=expression("-log(Potency(M))"),y=expression("Count")) 

#plot the MolWt distribution
potency_data_mean <- data.frame(mean=NA)
potency_data_mean$mean <- mean(potency_data$MolWt)

gg_potency <- ggplot(potency_data, aes(x=MolWt, color=Activity, fill=Activity)) +geom_histogram(breaks=seq(0, 1000, by=25), position = "identity", bins = 30, alpha = 0.4) + theme(legend.position="top") + geom_vline(data=potency_data_mean, aes(xintercept=mean), color="black",linetype="dashed",size=0.7) + theme(panel.border = element_rect(linetype="solid",fill=NA, size=1.5),plot.title = element_text(face="bold",size=20,hjust = 0.5,vjust=2), panel.background = element_blank(), axis.title.y = element_text(size=17,vjust=1),axis.title.x = element_text(size=17, vjust=--0.5), axis.text.x=element_text(size=15, colour="black"),axis.text.y=element_text(size=15, colour="black"),plot.margin = unit(c(1.5,1.5,1.5,1.5), "lines")) +
  labs(title="MolWt Distribution between Classes",x=expression("MolWt"),y=expression("Count")) 


#plot the MolLogP distribution

potency_data_mean <- data.frame(mean=NA)
potency_data_mean$mean <- mean(potency_data$MolLogP)

gg_potency <- ggplot(potency_data, aes(x=MolLogP, color=Activity, fill=Activity)) +geom_histogram(breaks=seq(-10, 15, by=1), position = "identity", bins = 30, alpha = 0.4) + theme(legend.position="top") + geom_vline(data=potency_data_mean, aes(xintercept=mean), color="black",linetype="dashed",size=0.7) + theme(panel.border = element_rect(linetype="solid",fill=NA, size=1.5),plot.title = element_text(face="bold",size=20,hjust = 0.5,vjust=2), panel.background = element_blank(), axis.title.y = element_text(size=17,vjust=1),axis.title.x = element_text(size=17, vjust=--0.5), axis.text.x=element_text(size=15, colour="black"),axis.text.y=element_text(size=15, colour="black"),plot.margin = unit(c(1.5,1.5,1.5,1.5), "lines")) +
  labs(title="MolLogP Distribution between Classes",x=expression("MolLogP"),y=expression("Count")) 


#plot the AcceptorCount distribution
potency_data_mean <- data.frame(mean=NA)
potency_data_mean$mean <- mean(graph_based$AcceptorCount)

gg_potency <- ggplot(graph_based, aes(x=AcceptorCount, color=Class, fill=Class)) +geom_histogram(breaks=seq(0, 20, by=1), position = "identity", bins = 30, alpha = 0.4) + theme(legend.position="top") + geom_vline(data=potency_data_mean, aes(xintercept=mean), color="black",linetype="dashed",size=0.7) + theme(panel.border = element_rect(linetype="solid",fill=NA, size=1.5),plot.title = element_text(face="bold",size=18,hjust = 0.5,vjust=2), panel.background = element_blank(), axis.title.y = element_text(size=17,vjust=1),axis.title.x = element_text(size=17, vjust=--0.5), axis.text.x=element_text(size=15, colour="black"),axis.text.y=element_text(size=15, colour="black"),plot.margin = unit(c(1.5,1.5,1.5,1.5), "lines")) +
  labs(title="Num Hydrogen Acceptors between Classes",x=expression("Number of Hydrogen Bond Acceptors"),y=expression("Count")) 

#plot the DonorCount distribution
potency_data_mean <- data.frame(mean=NA)
potency_data_mean$mean <- mean(graph_based$DonorCount)

gg_potency <- ggplot(graph_based, aes(x=DonorCount, color=Class, fill=Class)) +geom_histogram(breaks=seq(0, 15, by=1), position = "identity", bins = 30, alpha = 0.4) + theme(legend.position="top") + geom_vline(data=potency_data_mean, aes(xintercept=mean), color="black",linetype="dashed",size=0.7) + theme(panel.border = element_rect(linetype="solid",fill=NA, size=1.5),plot.title = element_text(face="bold",size=20,hjust = 0.5,vjust=2), panel.background = element_blank(), axis.title.y = element_text(size=17,vjust=1),axis.title.x = element_text(size=17, vjust=--0.5), axis.text.x=element_text(size=15, colour="black"),axis.text.y=element_text(size=15, colour="black"),plot.margin = unit(c(1.5,1.5,1.5,1.5), "lines")) +
  labs(title="Num Hydrogen Donors between Classes",x=expression("Number of Hydrogen Bond Donors"),y=expression("Count")) 



#plot class bar chart
bar_class <- ggplot(data=potency_data_count, aes(x=Activity, y=Count, fill=Activity)) +
  geom_bar(stat="identity") 
#+ scale_color_brewer(palette="Paired") 


#create p-value dataframe with descending order
p_df <- data.frame("auxiliary_feature" = colnames(auxiliary)[5:200], "pValue" =NA)
x <- filter(auxiliary, Activity == "Active")
y <- filter(auxiliary, Activity == "Inactive")

for (feature in colnames(auxiliary)[5:200]){
      
      result <- t.test(x[[feature]],y[[feature]])
      p_df[p_df$auxiliary_feature==feature,'pValue'] <- result$p.value
      #compare_means(feature ~ Activity, auxiliary, label = "p.format" ,method = "t.test",label.x = 2)
}

#p_df$pValue <- round(p_df$pValue,8)
write.csv(filter(p_df, pValue <= 0.05),'/Users/mickey/projects/PlasmoCSM/data_all/sig_aux_pvalue.csv', row.names = FALSE)
significateAux_list <- filter(p_df, pValue <= 0.05)[['auxiliary_feature']]

#plot boxplot
# Compute t-test
for (feature in significateAux_list){
  
  gg_boxplot <- ggboxplot(auxiliary, x = "Activity", y = feature, 
                          color = "Activity", palette = c("#00AFBB", "#E7B800"),
                          ylab = feature, xlab = "Activity") + stat_compare_means(label = "p.format" ,method = "t.test",label.x = 1.5)
  
  ggsave(paste0(feature,".pdf"), device = "pdf")
}


#plot pearson correlation
for (feature in colnames(auxiliary)[5:6]){
ggscatter(auxiliary, x = "log_activity_value", y = feature, 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "Activity", ylab = feature)
ggsave(paste0(feature,"_cor_",".png"))
}

#create corelation dataframe with descending order
cor_df <- data.frame("auxiliary_feature" = colnames(auxiliary)[5:200], "cor" =NA)

for (i in 5:200){
res <- cor.test(auxiliary$Activity_Value, auxiliary[[i]], method = "pearson")
cor_df[cor_df$auxiliary_feature==colnames(auxiliary)[i],'cor'] <- res$estimate[["cor"]]

}
cor_df <- cor_df[order(-cor_df$cor),]
write.csv(cor_df,'/Users/mickey/projects/PlasmoCSM/data＿all/cor_df.csv', row.names = FALSE)

#PCA
library("FactoMineR")
library("factoextra")
res.pca <- PCA(auxiliary_all[,5:200], scale.unit = TRUE, ncp = 2, graph = TRUE)

#examine the eigenvalues to determine the number of principal components to be considered
eig.val <- get_eigenvalue(res.pca)
#An alternative method to determine the number of principal components is to look at a Scree Plot
fviz_eig(res.pca, addlabels = TRUE, ylim = c(0, 20))
#extract the results, for variables, from a PCA output which can be used in the plot of variables
var <- get_pca_var(res.pca)

for (i in 1:length(res.pca$var)) {
  res.pca$var[[i]] <- head(res.pca$var[[i]],10)
}

# Coordinates of variables(The correlation between a variable and a principal component (PC))
head(var$coord, 4)
#their contributions to the principal components.
fviz_pca_var(res.pca, col.var = "cos2",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"), 
             repel = TRUE # Avoid text overlapping
)
#their quality of representation on the factor map
library("corrplot")
corrplot(var$cos2, is.corr=FALSE)
# Total cos2 of variables on Dim.1 and Dim.2 bar plot
fviz_cos2(res.pca, choice = "var", axes = 1:2)

# Contributions of variables to PC1
fviz_contrib(res.pca, choice = "var", axes = 1, top = 10)

# Contributions of variables to PC2
fviz_contrib(res.pca, choice = "var", axes = 2, top = 10)
#The total contribution to PC1 and PC2 is obtained with the following R code:
fviz_contrib(res.pca, choice = "var", axes = 1:2, top = 10)

fviz_pca_var(res.pca, col.var = "contrib",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07")
)



ind.p <- fviz_pca_ind(res.pca, geom = "point", col.ind = auxiliary_all$Activity)
ggpubr::ggpar(ind.p,
              title = "Principal Component Analysis",
              subtitle = "Auxiliary Features",
              xlab = "PC1", ylab = "PC2",
              legend.title = "Activity", legend.position = "top",
              ggtheme = theme_gray(), palette = "jco"
)

fviz_pca_ind(res.pca,
             geom.ind = "point", # show points only (nbut not "text")
             col.ind = auxiliary_all$Activity, # color by groups
             palette = c( "#00AFBB", "#E7B800"),
             addEllipses = TRUE, # Concentration ellipses
             legend.title = "Activity"
             
)

fviz_pca_biplot(res.pca, 
                col.ind = auxiliary_all$Activity, palette = "jco", 
                addEllipses = TRUE, label = "var",
                col.var = "black", repel = TRUE,
                legend.title = "Activity") 

input <- apply(auxiliary_all[,5:200],2, function(x) n_distinct(x)) !=1
input <- auxiliary_all[,5:200][,input]
prin_comp <- prcomp(input, scale. = T)
prin_comp$rotation[1:5,1:4]
dim(prin_comp$x)
biplot(prin_comp, scale = 0)
# library(dplyr)
# dat_forward <- data.frame(cond=factor(rep(c("forward"),each=905)), DDG = mydata$DDG[1:905])
# dat_all <- data.frame(cond=factor(rep(c("all"),each=1810)), DDG=mydata$DDG)
# dat_merged <- rbind(dat_forward, dat_all)
# 
# 
# library(plyr)
# cdat_forward <- ddply(dat_forward, "cond", summarise, rating.mean=mean(DDG))
# cdat_all <- ddply(dat_all, "cond", summarise, rating.mean=mean(DDG))
# cdat_merged <- ddply(dat_merged, "cond", summarise, rating.mean=mean(DDG))
# 
# gg_forward <- ggplot(dat_forward, aes(x=DDG)) +geom_histogram(binwidth=.5, alpha=.5, fill="black", colour="black", position="identity") + geom_vline(data=cdat_forward, aes(xintercept=rating.mean), color="black",linetype="dashed",size=0.7) + scale_x_continuous(limits=c(-10,10))+theme(legend.position="none", panel.border = element_rect(linetype="solid",fill=NA, size=1.5),plot.title = element_text(face="bold",size=20,hjust = 0.5,vjust=2), panel.background = element_blank(), axis.title.y = element_text(size=17,vjust=1),axis.title.x = element_text(size=17, vjust=--0.5), axis.text.x=element_text(size=15, colour="black"),axis.text.y=element_text(size=15, colour="black"),plot.margin = unit(c(1.5,1.5,1.5,1.5), "lines")) +
#   labs(title="Forward mutation",x=expression(Experimental~Delta*Delta*G[italic("Affinity")]~(Kcal/mol)),y=expression("Count")) 
# 
# # gg_all <- ggplot(dat_all, aes(x=DDG)) +theme_bw()+ geom_histogram(binwidth=.5, alpha=.5, fill="#70706F", colour="black", position="identity") + geom_vline(data=cdat_all, aes(xintercept=rating.mean),color="black", linetype="dashed",size=0.7)+ scale_x_continuous(limits=c(-10,10))+ theme(legend.position="none",panel.border = element_rect(linetype="solid",fill=NA, size=1.5),plot.title = element_text(hjust = 0.5), panel.background = element_blank(),axis.title.y = element_text(size=20),axis.title.x = element_text(size=20), axis.text.x=element_text(size=15),axis.text.y=element_text(size=15),plot.margin = unit(c(1,1,1,1), "lines")) +
# #   labs(x=expression(bold(Experimental~Delta*Delta*G[italic("Affinity")])),y=expression(bold("count"))) 
# 
# # For Paper
# gg_merged <- ggplot(dat_merged, aes(x=DDG,fill=cond)) + geom_histogram(binwidth=.5, alpha=.5, colour="black", position="identity") + geom_vline(data=cdat_merged[2,], aes(xintercept=rating.mean), linetype="dashed",size=0.7)+ scale_x_continuous(limits=c(-10,10))+ theme(legend.position="none",panel.border = element_rect(linetype="solid",fill=NA, size=1.5),plot.title = element_text(face="bold",size=20,hjust = 0.5,vjust=2), panel.background = element_blank(),axis.title.y = element_text(size=17,vjust=1),axis.title.x = element_text(size=17, vjust=-0.5), axis.text.x=element_text(size=15, colour = "black"),axis.text.y=element_text(size=15, colour = "black"),plot.margin = unit(c(1.5,1.5,1.5,1.5), "lines")) +
#   labs(title="Forward and reverse mutation",x=expression(Experimental~Delta*Delta*G[italic("Affinity")]~(Kcal/mol)),y=expression("Count")) +scale_fill_manual(values=c("black","grey"))
# 
# # For Poster
# ggplot(dat_merged, aes(x=DDG,fill=cond)) + geom_histogram(binwidth=.5, alpha=0.5, colour="black", position="identity") + geom_vline(data=cdat_merged[2,], aes(xintercept=rating.mean), linetype="dashed",size=0.7)+ scale_x_continuous(limits=c(-10,10))+ theme(legend.position="none",panel.border = element_rect(linetype="solid",fill=NA, size=1.5),plot.title = element_text(face="bold",size=20,hjust = 0.5,vjust=2), panel.background = element_blank(),axis.title.y = element_text(size=17,vjust=1),axis.title.x = element_text(size=17, vjust=-0.5), axis.text.x=element_text(size=15, colour = "black"),axis.text.y=element_text(size=15, colour = "black"),plot.margin = unit(c(1.5,1.5,1.5,1.5), "lines")) +
#   labs(x=expression(Experimental~Delta*Delta*G[italic("Affinity")]~(Kcal/mol)),y=expression("Count")) +scale_fill_manual(values=c("black","darkolivegreen"))
# 
# 
# library(ggpubr)
# png("/Users/ymyung/Desktop/mCSM_AB2/8_DEC/Figure_S4.png",width=12,heigh=5,units='in',res=500)
# #ggarrange(gg_forward,gg_all+rremove("y.title"),ncol=2,nrow=1)
# ggarrange(gg_forward,gg_merged+rremove("y.title"),ncol=2,nrow=1)
# dev.off()
