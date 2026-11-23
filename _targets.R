# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = c("tibble","dplyr","ggplot2","caret","rpart","xgboost","randomForest","xgboost",
               "fastAdaboost","glmnet","nnet","MASS","klaR") # Packages that your targets need for their tasks.
  # format = "qs", # Optionally set the default storage format. qs is fast.
  #
  # Pipelines that take a long time to run may benefit from
  # optional distributed computing. To use this capability
  # in tar_make(), supply a {crew} controller
  # as discussed at https://books.ropensci.org/targets/crew.html.
  # Choose a controller that suits your needs. For example, the following
  # sets a controller that scales up to a maximum of two workers
  # which run as local R processes. Each worker launches when there is work
  # to do and exits if 60 seconds pass with no tasks to run.
  #
  #   controller = crew::crew_controller_local(workers = 2, seconds_idle = 60)
  #
  # Alternatively, if you want workers to run on a high-performance computing
  # cluster, select a controller from the {crew.cluster} package.
  # For the cloud, see plugin packages like {crew.aws.batch}.
  # The following example is a controller for Sun Grid Engine (SGE).
  # 
  #   controller = crew.cluster::crew_controller_sge(
  #     # Number of workers that the pipeline can scale up to:
  #     workers = 10,
  #     # It is recommended to set an idle time so workers can shut themselves
  #     # down if they are not running tasks.
  #     seconds_idle = 120,
  #     # Many clusters install R as an environment module, and you can load it
  #     # with the script_lines argument. To select a specific verison of R,
  #     # you may need to include a version string, e.g. "module load R/4.3.2".
  #     # Check with your system administrator if you are unsure.
  #     script_lines = "module load R"
  #   )
  #
  # Set other options as needed.
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source("functions.R")
# tar_source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
list(
  tar_target(Train.dat,read.csv("train_set1.csv")),
  tar_target(Train.datn,Train.dat[,1:83]),
  tar_target(Train.datn1,as.data.frame(lapply(Train.datn, as.numeric))),
  tar_target(Y.train,as.factor(Train.dat[,84])),
  tar_target(Train.all,cbind(Train.datn1,Y.train)),
  tar_target(Test.dat,read.csv("test_set1.csv")),
  tar_target(Test.datn,Test.dat[,1:83]),
  tar_target(Test.datn1,as.data.frame(lapply(Test.datn, as.numeric))),
  tar_target(Y.test,as.factor(Test.dat[,84])),
  tar_target(Test.all,cbind(Test.datn1,Y.test)),#,
  #############classification tree
  tar_target(classtree,treeTune(Y.train,Train.datn1)),
 tar_target(classtreefit,rpart(Y.train~., data=Train.all, method="class",
                                control=rpart.control(cp=0.0012)) ),
 tar_target(classtrainpred,predict(classtreefit,newdata=Train.datn1,type="class")),
 tar_target(classtestpred,predict(classtreefit,newdata=Test.datn1,type="class")),
 ########## random forest
 tar_target(randomforestTune,rfTune(Y.train,Train.datn1)),
 tar_target(rffit,randomForest(x=Train.datn1,y=Y.train, 
                                       type="classification",ntree=2000,mtry=46)),
 tar_target(rftrainpred,predict(rffit,newdata=Train.datn1,type="class")),
 tar_target(rftestpred,predict(rffit,newdata=Test.datn1,type="class")),
 #########xgboost
 tar_target(xgbTune,xgbtune(Y.train,Train.datn1)),
 tar_target(YxgbTrain,ifelse(Y.train=="no",0,1)),
 tar_target(xgbfit1,xgbfit(as.matrix(Train.datn1),YxgbTrain)),
 tar_target(xgbtrainpred,predict(xgbfit1,newdata=as.matrix(Train.datn1))),
 tar_target(xgbtestpred,predict(xgbfit1,newdata=as.matrix(Test.datn1))),
 ################ adaboost
 tar_target(adbtune,adaBTune(Y.train,Train.datn1)),
 tar_target(adbfit,adaBfit(Train.all)),
 tar_target(adbtrainpred,predict(adbfit,newdata=Train.datn1)),
 tar_target(adbtestpred,predict(adbfit,newdata=Test.datn1)),
 ##### logistics
 tar_target(Enet.grid,expand.grid(alpha=seq(0.001,0.10,length.out=25),
                                   lambda=seq(0.001,0.05,length.out=50))),
 tar_target(lgtune,logisticTune(Y.train,Train.datn1,Enet.grid)),
 tar_target(lgfit,logisticfit(Train.datn1,Y.train)),
 tar_target(lgtrainpred,predict(lgfit,newx=as.matrix(Train.datn1),
                               type="response")),
 tar_target(lgtestpred,predict(lgfit,newx=as.matrix(Test.datn1),
                                type="response")),
 ###### neural network
 tar_target(nnetgrid,expand.grid(size=seq(1,10,length.out=5), 
                                            decay= seq(0.3,0.8,length.out=6), bag=FALSE)),
            tar_target(nnettune,nnetTune(Y.train,as.matrix(Train.datn1),nnetgrid)),
 tar_target(nnetfit,nnet1(Y.train,Train.datn1)),
 tar_target(nnettrainpred,predict(nnetfit,newdata=Train.datn1,type="class")),
 tar_target(nnettestpred,predict(nnetfit,newdata=Test.datn1,type="class"))#,
 ##### lda
 #tar_target(lda.grid,expand.grid(maxvar=1:83, direction=c("both","forward","backward"))),
 #tar_target(ldatune,ldaTune(Y.train,Train.datn1,lda.grid)),
 #tar_target(ldafit,stepclass(x=Train.datn1,grouping=Y.train,improvement=0.0000001,
#                             maxvar=2,direction="both",fold=10,method="lda",output=FALSE)),
# tar_target(ldafit2,lda(ldafit$formula,data=Train.all)),
 #tar_target(ldatrainpred,predict(ldafit2,newdata=Train.datn1)),
 #tar_target(ldatestpred,predict(ldafit2,newdata=Test.datn1)),
,
#,#,knn
tar_target(knntune,knnTune(Train.dat[,84],Train.dat[,1:83])),
tar_target(knntrainpred,predict(knntune,newdata=Train.dat[,1:83])),
tar_target(knntestpred,predict(knntune,newdata=Test.datn1))

 
)




