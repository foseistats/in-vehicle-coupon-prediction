
#####################
knnTune<- function(m,n){
  train(y=m, x=n, method="knn",preProcess=c("center","scale"), ## standardize input variables 
        tuneGrid=data.frame(k=1:100),
        trControl=trainControl(method="repeatedcv", repeats=10, number=10))  
}





################# classification Tree

treeTune<-function(m,n){
  train(y=m, x=n, method="rpart",
        tuneGrid=data.frame(cp=1:50/10000),
        trControl=trainControl(method="LOOCV"))
}



################## random forest
rfTune<-function (m,n){
  train(y=m, x=n, method="rf",
        tuneGrid=data.frame(mtry=1:83), ntree=2000,
        trControl=trainControl(method="oob"))
}





############## XGboost
#train_set2<-train_set[,-80]
#for (i in 1:83) {
 # train_set2[,i]<-as.double(train_set2[,i])
#}

xgbtune<-function(m,n){
  train(y=m,x=n, method="xgbTree",
        verbose=FALSE, verbosity=0, 
        trControl=trainControl(method="repeatedcv", repeats=20, number=10))}

xgbfit<-function(m,n){
  xgboost(data=m, label=n, objective = "multi:softmax", max.depth = 3, 
        eta = 0.4, nrounds=150, gamma=0, colsample_bytree=0.8, min_child_weight=1, 
        subsample=1,num_class=2)}




######## Adaboost
adaBTune<- function(m,n){
  train(y=m,x=n, method="adaboost", preProc = c("center","scale"),
                tuneGrid=data.frame(nIter=seq(40, 100, 20),method="Adaboost.M1"),
        trControl=trainControl(method="repeatedcv", repeats=5, number=10))  
}

adaBfit<-function(m){
  adaboost(Y.train~.,data=m, nIter=100)
}




####### Logistic classification

logisticTune<- function(m,n,p){
  train(y=m, x=n, tuneGrid=p,
                method="glmnet", family="binomial",
                preProcess=c("center","scale"),
                trControl=trainControl(method="repeatedcv", repeats=10, number=10))
}


logisticfit<-function(m,n){
  glmnet(x=m,y=n,family="binomial", alpha=0.07525, 
       lambda=0.001)
}




###### Neural network

nnetTune<-function(m,n,p){
  train(y=m, x=n, method="avNNet", trace=FALSE,
                  tuneGrid=p, preProc = c("center","scale"), 
                  maxit=100, repeats=2, 
  trControl=trainControl(method="repeatedcv", repeats=5, number=5))
} 

nnet1<-function(m,n){
  avNNet(y=m,x=n,linout=FALSE, repeats=2, 
       maxit=100, size=7.75, decay=0.7, bag=FALSE, trace=FALSE)
}




###### LDA

#ldaTune<-function(m,n,p){
#  train(y=m, x=n, method="stepLDA",
#               preProc = c("center","scale"), tuneGrid=p,
#               improvement=0.0000001, output=FALSE,
#        trControl=trainControl(method="repeatedcv", repeats=1, number=2))
  
#}



