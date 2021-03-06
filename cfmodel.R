
setwd("/Users/bikash/repos/kaggle/RestaurantRevenuePrediction/")
#setwd("/home/ekstern/haisen/bikash/kaggle/RestaurantRevenuePrediction/")

library(party)
library(e1071)

#load data
train = read.csv("data/train.csv", header = TRUE, stringsAsFactors = FALSE)
test = read.csv("data/test.csv", header = TRUE, stringsAsFactors = FALSE)

# parse days open from start of competetion
competition_start <- strptime('23.03.2015', format='%d.%m.%Y')
train$days_open <- as.numeric(difftime(competition_start,
                                       strptime(train$Open.Date, format='%m/%d/%Y'), units='days'))
test$days_open <- as.numeric(difftime(competition_start,
                                      strptime(test$Open.Date, format='%m/%d/%Y'), units='days'))

train$weeks_open <- as.numeric(difftime(competition_start,
                                        strptime(train$Open.Date, format='%m/%d/%Y'), units='weeks'))
test$weeks_open <- as.numeric(difftime(competition_start,
                                       strptime(test$Open.Date, format='%m/%d/%Y'), units='weeks'))

train$months_open <- as.numeric(difftime(competition_start,
                                         strptime(train$Open.Date, format='%m/%d/%Y'), units='days')/30)
test$months_open <- as.numeric(difftime(competition_start,
                                        strptime(test$Open.Date, format='%m/%d/%Y'), units='days')/30)


# remove unneeded columns
train$Open.Date <- NULL
train$Type <- NULL
train$City <- NULL
train$City.Group <- NULL
test$Type <- NULL
test$City <- NULL
test$City.Group <- NULL
test$Open.Date <- NULL

# remove outliers
train <- train[train$revenue < 16000000,]

rf = cforest(revenue ~., data = train[,-1], controls=cforest_unbiased(ntree=1000))

Prediction = predict(rf, test[,-1], OOB=TRUE, type = "response")

id<-test[,1]
submission<-cbind(id,Prediction)
colnames(submission)[2] <- "Prediction"

write.csv(submission, "output/conditional_forest_tree_1000.csv", row.names = FALSE, quote = FALSE)