source("./code/data.R")
color1 = function(alpha=0.5){
  return(rgb(red = 0/255, green = 49/255, blue = 79/255, alpha = alpha))
}
## Modeling ##
full.model <- lm(BODYFAT~., train)
X <- model.matrix(full.model)
l <-  glmnet(x = X[,-1], y = train$BODYFAT, alpha = 1)
test.slr <- lm(BODYFAT~., test)
test.X <- model.matrix(test.slr)
Yhat <- predict.glmnet(l, test.X[,-1], s = l$lambda)
mse <- (test$BODYFAT - Yhat)^2 %>% colMeans
## Visualizing ##
# color blind friendly palette
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
gg <- data.frame(log_lambda = log(l$lambda), mse = mse, df = l$df)
gg$title <- "LASSO"
for(i in length(gg$df):2){
  if(gg$df[i] == gg$df[i-1])
    gg$df[i] = NA
}
x.break <- gg$log_lambda[!is.na(gg$df)]
i=1
for(i in 1:(length(x.break)-1)){
  x.break[i] <- (x.break[i]+x.break[i+1])/2
}
x.break[i+1] <- (x.break[i+1]+min(gg$log_lambda))/2
p <- ggplot(gg, aes(x=log_lambda, y=mse)) + 
  geom_point(col =cbPalette[6])+
  geom_point(aes(x=log_lambda[39],y=mse[39]),
             col = cbPalette[2],size=1.5,pch=19)+
  geom_vline(xintercept=gg$log_lambda[!is.na(gg$df)], 
             col=cbPalette[1]) + 
  geom_label(aes(x=x.break, 
                 y=seq(min(mse), max(mse), length.out = i+1),
                 label=gg$df[!is.na(gg$df)]), 
             data = data.frame(gg$df[!is.na(gg$df)]),
             label.padding = unit(0.1, "lines")) 
p <- p + facet_grid(. ~ title)+
  theme(strip.background = element_rect(fill=color1()),
        strip.text = element_text(size=15, colour="white"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank())
## lambda and coefficient
lambda <- l$lambda[39]
coeff <- coef(l)[,39]
coeff <- coeff[coeff!=0]
lasso.mse <- (Yhat[,39]-test$BODYFAT)^2 %>% mean
lasso.result <- cbind(round(t(coeff),3),lambda=lambda,MSE=lasso.mse)

m <- lm(BODYFAT ~ WEIGHT + ABDOMEN + WRIST,data = train)
df <- data.frame(p=predict(m),r=rstandard(m))
df$title<-"Standardized Residual Plot"
d1<-ggplot(df,aes(p,r))+
  geom_point(col =cbPalette[6],size=2,pch=20)+
  geom_hline(yintercept = 0,col="black",lwd=0.5)+
  xlab("Predicted BodyFat%")+
  ylab("Standardized Residuals")
d1<-d1 + facet_grid(. ~ title)+
  theme(strip.background = element_rect(fill=color1()),
           strip.text = element_text(size=15, colour="white"),
           panel.grid.major.x = element_blank(),
           panel.grid.minor.x = element_blank())

y <- sort(m$resid[!is.na(m$resid)])
x <- qnorm((1:200-0.5)/200)
qq <- data.frame(x=x, y=y)
qq$title = "Normal Q-Q Plot"
slope <- diff(quantile(y,c(.25,.75)))/(qnorm(0.75)-qnorm(0.25))
int <- quantile(y,.25) - slope * qnorm(0.25)

d2<-ggplot(qq, aes(x=x,y=y)) +
  geom_point(col =cbPalette[6],size=2,pch=20)+
  geom_abline(slope = slope, intercept = int,
              col="black",lwd=.8) +
  xlab("Theoretical Quantile") +
  ylab("Sample")
d2<-d2 + facet_grid(. ~ title)+
  theme(strip.background = element_rect(fill=color1()),
        strip.text = element_text(size=15, colour="white"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank())

