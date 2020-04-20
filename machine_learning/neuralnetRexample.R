

library(MASS)
data <- Boston
head(data)
dim(data)

# Check that no data is missing
apply(data,2,function(x) sum(is.na(x)))

# Train-test random splitting for linear model
index <- sample(1:nrow(data),round(0.75*nrow(data))) # draws a sample without replacement; 2/3 for training, 1/3 for testing
train <- data[index,]
test <- data[-index,]

# Fitting linear model
lm.fit <- glm(medv~., data=train)
summary(lm.fit)
lm.fit2=stepAIC(lm.fit) ## many variables, not all significant so can use a variable selection procedure


# Predicted data from lm in the test set
test$pr.lm <- predict(lm.fit,test)
test$pr.lm2 <- predict(lm.fit2,test)

par(mfrow=c(1,2))
plot(test$medv,test$pr.lm, type="p", pch=19, xlab="Actual value", ylab="Predicted value", col="blue")
abline(0,1, col="red")
title("all variables")
plot(test$medv,test$pr.lm2, type="p", pch=19, col="blue", xlab="Actual value", ylab="Predicted value")
abline(0,1, col="red")
title("select variables")

# Test MSE
MSE.lm <- sum((test$pr.lm - test$medv)^2)/nrow(test)
MSE.lm
MSE.lm2 <- sum((test$pr.lm2 - test$medv)^2)/nrow(test)
MSE.lm2

#-------------------------------------------------------------------------------
# Neural net fitting

# Set a seed
set.seed(500)

# Scaling data for the NN
maxs <- apply(data, 2, max) 
mins <- apply(data, 2, min)
scaled <- as.data.frame(scale(data, center = mins, scale = maxs - mins)) ## removes the minimum and divides by (max-min)

# Train-test split (same split as before, but now using the scaled data)
train_ <- scaled[index,]
test_ <- scaled[-index,]

# NN training
library(neuralnet)
n <- names(train_)
f <- as.formula(paste("medv ~", paste(n[!n %in% "medv"], collapse = " + "))) ## nerdy way of lining up all the variables
nn <- neuralnet(f,data=train_,hidden=c(5,3),linear.output=T)
## uses 13:5:3:1, ie 13 variables as input layer, 2 hidden layers of 5 and 3 nodes each, and 1 output layer wich is the regression result

# Visual plot of the model
plot(nn)
print(nn) ### this gives you a bunch of details on model fitting!

# Predict
pr.nn <- compute(nn,test_[,1:13]) ## need to indicate the column to use for input layer, here 1:13

# Results from NN are normalized (scaled)
# Descaling for comparison
pr.nn_ <- pr.nn$net.result*(max(data$medv)-min(data$medv))+min(data$medv)
test.r <- (test_$medv)*(max(data$medv)-min(data$medv))+min(data$medv)

# Calculating MSE
MSE.nn <- sum((test.r - pr.nn_)^2)/nrow(test_)
MSE.nn

# Compare the two MSEs
print(paste("Linear model:", round(MSE.lm2,1),"Neural net:", round(MSE.nn,1)))

# Plot predictions
par(mfrow=c(1,2))

plot(test$medv,pr.nn_,col='blue',main='Real vs predicted NN',pch=19,cex=1)
abline(0,1,lwd=2, col="red")
legend('bottomright',legend='NN',pch=19,col='blue', bty='n')

plot(test$medv,pr.lm2,col='blue',main='Real vs predicted lm',pch=19, cex=1)
abline(0,1,lwd=2, col="red")
legend('bottomright',legend='LM',pch=19,col='blue', bty='n')

# Compare predictions on the same plot
plot(test$medv,pr.nn_,col='red',main='Real vs predicted NN',pch=18,cex=0.7)
points(test$medv,pr.lm,col='blue',pch=18,cex=0.7)
abline(0,1,lwd=2)
legend('bottomright',legend=c('NN','LM'),pch=18,col=c('red','blue'))

#-------------------------------------------------------------------------------
# Cross validating

library(boot)
set.seed(200)

# Linear model cross validation
lm.fit <- glm(medv~.,data=data)
cv.glm(data,lm.fit,K=10)$delta[1]


# Neural net cross validation
set.seed(450)
cv.error <- NULL
k <- 10

# Initialize progress bar
library(plyr) 
pbar <- create_progress_bar('text')
pbar$init(k)

for(i in 1:k){
    index <- sample(1:nrow(data),round(0.9*nrow(data)))
    train.cv <- scaled[index,]
    test.cv <- scaled[-index,]
    
    nn <- neuralnet(f,data=train.cv,hidden=c(5,2),linear.output=T)
    
    pr.nn <- compute(nn,test.cv[,1:13])
    pr.nn <- pr.nn$net.result*(max(data$medv)-min(data$medv))+min(data$medv)
    
    test.cv.r <- (test.cv$medv)*(max(data$medv)-min(data$medv))+min(data$medv)
    
    cv.error[i] <- sum((test.cv.r - pr.nn)^2)/nrow(test.cv)
    
    pbar$step()
}

# Average MSE
mean(cv.error)

# MSE vector from CV
cv.error

# Visual plot of CV results
boxplot(cv.error,xlab='MSE CV',col='cyan',
        border='blue',names='CV error (MSE)',
        main='CV error (MSE) for NN',horizontal=TRUE)