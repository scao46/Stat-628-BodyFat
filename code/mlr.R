source("./code/data.R")
#Model 1 simple linear regression
model<-lm(BODYFAT~.,data = train)    
#summary(model)

#Model 2 is using Mallow Cp to find the best variables
X <- model.matrix(model)[,-1]
Y <- train[,1]
#Mallow’s Cp is a criteria based on the Model Error.
g <- leaps(X, Y, nbest = 1)
#Cpplot(g)
#(2,7,11,14)seems to be a good selection
cp.choice <- c(2,7,11,14)+1
#summary(model.cp <- lm(BODYFAT ~ ., data=BodyFat.clean[,c(1,cp.choice)]))
#BODYFAT ~ WEIGHT + ABNOMEN + WRIST + ANKLE 


#Model 3 Stepwise selecting
model.AIC <- step(model, k=2, direction = "both",trace=0)
#BODYFAT ~ AGE + WEIGHT + HEIGHT + ADIPOSITY + ABDOMEN + THIGH + WRIST
m1<-lm(BODYFAT ~ AGE + WEIGHT + HEIGHT + ADIPOSITY + ABDOMEN + THIGH + 
         WRIST,data = train)
#summary(m1)
model.BIC <- step(model, k=log(249),trace=0)
#BODYFAT ~ AGE + ABDOMEN + WRIST
m2<-lm(BODYFAT ~ WEIGHT + ABDOMEN + WRIST,data = train)
## Data from this model
model.BIC.coeff <- round(summary(m2)$coef,3)
Multiple.R.Squared <- round(summary(m2)$r.squared,4)
mlr.MSE.train <- round(mean(m2$residuals^2),4)
mlr.MSE.test <- round(mean((predict(m2, data.frame(test[,-1]))-test$BODYFAT)^2),4);
mlr.vif <- round(vif(m2),3)
##
#summary(m2)

base <- lm(BODYFAT~1,data=train)
AIC.base <- step(base,direction="both", scope=list(lower=~1,upper=model),trace=F)
#BODYFAT ~ ABDOMEN + WEIGHT + WRIST + ANKLE + FOREARM
m3<-lm(BODYFAT ~ ABDOMEN + WEIGHT + WRIST + ANKLE + FOREARM,data = train)
#summary(m3)

#

