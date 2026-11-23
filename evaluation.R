library(caret)
library(targets)
library(rpart)
library(nnet)
library(randomForest)
library(glmnet)
library(xgboost)
library(fastAdaboost)


###KNN
tar_read(knntune)
plot(tar_read(knntune))
confusionMatrix(as.factor(tar_read(knntrainpred)),as.factor(tar_read(Y.train)))
confusionMatrix(as.factor(tar_read(knntestpred)),as.factor(tar_read(Y.test)))



####CART
tar_read(classtree)
plot(tar_read(classtree))
summary(tar_read(classtreefit))
confusionMatrix(as.factor(tar_read(classtrainpred)),as.factor(tar_read(Y.train)))
confusionMatrix(as.factor(tar_read(classtestpred)),as.factor(tar_read(Y.test)))


###randomforest
tar_read(randomforestTune)
plot(tar_read(randomforestTune))
summary(tar_read(randomforestTune))
confusionMatrix(as.factor(tar_read(rftrainpred)),as.factor(tar_read(Y.train)))
confusionMatrix(as.factor(tar_read(rftestpred)),as.factor(tar_read(Y.test)))



## XGBOOST
tar_read(xgbTune)$bestTune
plot(tar_read(xgbTune))
confusionMatrix(factor(tar_read(xgbtrainpred),levels = c(0,1),labels = c("no","yes")),tar_read(Y.train))
confusionMatrix(factor(tar_read(xgbtestpred),levels = c(0,1),labels = c("no","yes")),tar_read(Y.test))



###ADABOOST
tar_read(adbtune)
plot(tar_read(adbtune))
confusionMatrix(as.factor(tar_read(adbtrainpred)$class),as.factor(tar_read(Y.train)))
confusionMatrix(as.factor(tar_read(adbtestpred)$class),as.factor(tar_read(Y.test)))


####Logistic
tar_read(lgtune)
plot(tar_read(lgtune))
confusionMatrix(as.factor(ifelse(tar_read(lgtrainpred)>0.5,"yes","no")),as.factor(tar_read(Y.train)))
confusionMatrix(as.factor(ifelse(tar_read(lgtestpred)>0.5,"yes","no")),as.factor(tar_read(Y.test)))




###neural network
tar_read(nnettune)
plot(tar_read(nnettune))
confusionMatrix(as.factor(tar_read(nnettrainpred)),as.factor(tar_read(Y.train)))
confusionMatrix(as.factor(tar_read(nnettestpred)),as.factor(tar_read(Y.test)))





###LDA
tar_read(ldatune)
plot(tar_read(ldatune))
confusionMatrix(as.factor(tar_read(ldatrainpred)$class),as.factor(Y.train))
confusionMatrix(as.factort(tar_read(ldatestpred)$class),as.factor(Y.test))






#### agreement of models on test set
#knntp<-read.csv("knntp.csv")
#knntp$KNN<-as.factor(knntp$KNN)

ldatp<-read.csv("ldatp.csv")
ldatp$LDA<-as.factor(ldatp$LDA)

logistictest<-as.factor(ifelse(tar_read(lgtestpred)>0.5,"yes","no"))
xgbtest<-factor(tar_read(xgbtestpred),levels = c(0,1),labels = c("no","yes"))
allprednY<-data.frame(tar_read(Y.test),tar_read(adbtestpred)$class,tar_read(classtestpred),logistictest,
              tar_read(rftestpred),xgbtest,tar_read( nnettestpred),tar_read(knntestpred),ldatp)
colnames(allprednY)<-c("Y","Adaboost","CT","Logistic","RF","Xgboost","Nnetw","KNN","LDA")

data_binary <- allprednY
N<-length(allprednY[,1])
AgreeMat<-matrix(0,nrow=9,ncol=9)
for(i in 1:9) {
  for(j in 1:9){
  AgreeMat[i,j]=sum(allprednY[,i]==allprednY[,j])/N
 }
}
colnames(AgreeMat)<-c("Y","Adaboost","CT","Logistic","RF","Xgboost","Nnetw","KNN","LDA")
rownames(AgreeMat)<-colnames(AgreeMat)
kable(round(AgreeMat, 3),format = "latex")



