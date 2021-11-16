#paquetes
install.packages(c("rpart","rpart.plot","caret"))
library(caret)
library(rpart)
library(rpart.plot)
library(ROCR)
install.packages("randomForest")
library(caret)
library(randomForest)
install.packages("e1071")
library(caret)
library(e1071)

#Arbol de decision
#cargar data
banca <- read.csv("../Desktop/vacation-trip-classification.csv", sep = ';')
set.seed(2018)
training.ids <- createDataPartition(banca$Result, p=0.7, list = F)

#crear modelo
mod <- rpart(Result~. , 
             data = banca[training.ids,],
             method = "class",
             control = rpart.control(minsplit = 20, cp=0.01))
mod
prp(mod, type = 2, extra = 104, nn=TRUE,
    fallen.leaves = TRUE, faclen = 4, varlen = 8,
    shadow.col = "gray")
mod$cptable
mod.pruned <- prune(mod, mod$cptable[2,"CP"])
prp(mod, type = 2, extra = 104, nn=TRUE,
    fallen.leaves = TRUE, faclen = 4, varlen = 8,
    shadow.col = "gray")
pred.pruned <- predict(mod.pruned, banca[-training.ids,], type = "class")
table(banca[-training.ids,]$Result, pred.pruned,
      dnn = c("Actual","Predicho"))
pred.pruned2 <- predict(mod.pruned, banca[-training.ids,], type = "prob")
head(pred.pruned)
head(pred.pruned2)

pred <- prediction(pred.pruned2[,2], banca[-training.ids,"Result"])
perf <- performance(pred,"tpr","fpr")
plot(perf)

#Random Forest
banca2 <- read.csv("../Desktop/vacation-trip-classification.csv", sep = ';')
banca2$Result <- factor(banca2$Result)

training.ids2 <- createDataPartition(banca2$Result, p=0.7, list = F)

mod <- randomForest(x = banca2[training.ids2,1:2],
                    y= banca2[training.ids2,3],
                    ntree = 500,
                    keep.forest = TRUE)

pred <- predict(mod, banca2[-training.ids2,], type = "class")
table(banca2[-training.ids2,"Result"],pred,dnn = c("Actual","Predicho"))

probs <- predict(mod, banca2[-training.ids2,], type = "prob")
head(probs)

pred <- prediction(probs[,2],banca2[-training.ids2,"Result"])
perf <- performance(pred, "tpr","fpr")
plot(perf)

#SVM
banca3 <- read.csv("../Desktop/vacation-trip-classification.csv", sep = ';')
banca3$Result <- factor(banca3$Result)
set.seed(2018)

t.ids <- createDataPartition(banca3$Result, p=0.7, list = F)

mod  <- svm(Result~.,data=banca3[t.ids,]
)
table(banca3[t.ids,"Result"],fitted(mod),dnn=c("Actual","Predicho"))      

plot(mod, data = banca3[t.ids,], Income ~ Family_size)
plot(mod, data = banca3[-t.ids,], Income ~ Family_size)



