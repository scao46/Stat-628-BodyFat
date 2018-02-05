library(dplyr)
library(glmnet)
library(ggplot2)
library(car)  # VIF
library(tidyverse)
library(faraway) # Mallow's cp
library(leaps)  # Mallow's cp
source("code/multiplot.R")
set.seed(100)
BodyFat <- read.csv("data/BodyFat.csv", header = T)
# Notice that there are some points not on the line
g1<-ggplot(data=BodyFat)+geom_point(aes(BODYFAT,1/DENSITY))
pHeight <- ggplot(data = BodyFat)+
  geom_histogram(aes(HEIGHT),binwidth = 3,color="white")+
  geom_label(aes(x=35,y=15,
                 label="Weight:205\nHeight:30")) 
pWeight <- ggplot(data = BodyFat)+
  geom_histogram(aes(WEIGHT),binwidth = 10,color="white")+
  geom_label(aes(x=330,y=7,
                 label="Weight:363\nHeight:72")) 

BodyFat.clean <- BodyFat[-c(39,42,182),-c(1,3)]
train_index <- sample(1:249,size=200,replace=F)
train <- BodyFat.clean[train_index,]
test <- BodyFat.clean[-train_index,]