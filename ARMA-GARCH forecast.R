library(timeSeries)
library(forecast)
library(ggplot2)
library(fGarch)
library(rugarch)
library(zoo)
library(xts)
library(tseries)
library(dplyr)

set.seed(101)

setwd("~/MRP/News NLP/Data/Datasets")
i=6
data_train<-read.csv('df_train6_0.75year.csv')
t<-data_train$date
Y_change<-xts(data_train$log_change,order.by = as.Date(t))

#check stationarity using ADF test
adf.test(Y_change,alternative='stationary',k=0)

# function to predict 
predict_ts <- function (filename,testfile,i) {
  data_train<-read.csv(filename)
  data_test<-read.csv(testfile)
  t_test<-data_test$date
  t<-data_train$date
  Y_change<-xts(data_train$log_change,order.by = as.Date(t))
  Y_test<-xts(data_test$log_change,order.by = as.Date(t_test))[1:30] #30 day prediction
  #arma(2,1)-garch(1,1) model using a skewed t-distribution 
  spec<-ugarchspec(variance.model=list(model="sGARCH",garchOrder=c(1,1)),mean.model=list(armaOrder=c(2,1)),distribution.model = "sstd")
  outsample_days<-0
  fitted_garch <- ugarchfit(spec,Y_change,out.sample=outsample_days,solver="hybrid")
  fcast_days<-30
  fcast<-ugarchforecast(fitted_garch,n.ahead=fcast_days,n.roll=0,out.sample=outsample_days) #forecast 30 days ahead
  upper<-fcast@forecast$seriesFor+1.65*fcast@forecast$sigmaFor #upper 90% CI
  lower<-fcast@forecast$seriesFor-1.65*fcast@forecast$sigmaFor #lower 90% CI

  pred_dataset <- data.frame("Date" = index(Y_test),
                      "Y_test" = Y_test,
                      "Y_pred" = fcast@forecast$seriesFor,
                      "Lower_CI" = lower,
                      "Upper_CI" = upper
            )
colnames(pred_dataset) <- c("Date","Y_test","Y_pred",'Lower_CI',"Upper_CI")
write.csv(pred_dataset,paste('pred_dataset',toString(i),'_0.75year_2016.csv',sep=""))
}


# plot prediction with confidence intervals
plot(y=pred_dataset$Y_test,x=pred_dataset$Date,type="l")
lines(y=pred_dataset$Upper_CI,x=pred_dataset$Date,col='red')
lines(y=pred_dataset$Lower_CI,x=pred_dataset$Date,col='red')




#get dates where volume is outside 95% CI of values to determine peak days
get_dates <- function(filename,i) {
  data_train<-read.csv(filename)
  t<-data_train$date
  Y_change<-xts(data_train$log_change,order.by = as.Date(t))
  train_data <- data.frame("Date" = index(Y_change),
                             "Y_change" = coredata(Y_change),
                             "Lower_CI" = as.list(mean(Y_change)-1.96*sd(Y_change),len(Y_change)),
                             "Upper_CI" = as.list(mean(Y_change)+1.96*sd(Y_change),len(Y_change))
  )
  colnames(train_data) <- c("Date", "Y_change",'Lower_CI',"Upper_CI")
  filtered_dates <-dplyr::filter(train_data, (train_data$Y_change < train_data$Lower_CI) | (train_data$Y_change > train_data$Upper_CI))
  write.csv(filtered_dates,paste('filtered_dates',toString(i),'_0.75year_2016.csv',sep=""))
}

#run for all datasets to get prediction and peak days
#peak day dates
get_dates('df_train6_0.75year_2016.csv',6)
get_dates('df_train5_0.75year_2016.csv',5)
get_dates('df_train4_0.75year_2016.csv',4)
get_dates('df_train2_0.75year_2016.csv',2)
get_dates('df_train1_0.75year_2016.csv',1)
get_dates('df_train3_0.75year_2016.csv',3)

#predictions
predict_ts('df_train1_0.75year_2016.csv','df_test1_0.75year_2016.csv',1)
predict_ts('df_train2_0.75year_2016.csv','df_test2_0.75year_2016.csv',2)
predict_ts('df_train3_0.75year_2016.csv','df_test3_0.75year_2016.csv',3)
predict_ts('df_train4_0.75year_2016.csv','df_test4_0.75year_2016.csv',4)
predict_ts('df_train5_0.75year_2016.csv','df_test5_0.75year_2016.csv',5)
predict_ts('df_train6_0.5year_2016.csv','df_test6_0.75year_2016.csv',6)


#residuals diagnostics
par(mfrow=c(2,2))
plot(fitted_garch, which=8)
plot(fitted_garch, which=9)
plot(fitted_garch, which=10)
plot(fitted_garch, which=11)

#plot daily change in trading volumes and confidence intervals to visualize peak days
plot(y=train_data$Y_change,x=train_data$Date,type='l', main = "Daily Change in Trading Volumes",xlab = "Year",ylab = "Change V(t) / V(t-1)")
lines(y=train_data$Lower_CI,x=train_data$Date,col='red')
lines(y=train_data$Upper_CI,x=train_data$Date,col='red')