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
set.seed(2018)
training.ids2 <- createDataPartition(banca2$Result, p=0.7, list = F)

mod2 <- randomForest(x = banca2[training.ids2,1:2],
                    y= banca2[training.ids2,3],
                    ntree = 500,
                    keep.forest = TRUE)

pred2 <- predict(mod2, banca2[-training.ids2,], type = "class")
pred2
table(banca2[-training.ids2,"Result"],pred2,dnn = c("Actual","Predicho"))

probs2 <- predict(mod2, banca2[-training.ids2,], type = "prob")
head(probs2)

pred2 <- prediction(probs2[,2],banca2[-training.ids2,"Result"])
perf2 <- performance(pred2, "tpr","fpr")
plot(perf2)

#SVM
banca3 <- read.csv("../Desktop/vacation-trip-classification.csv", sep = ';')
banca3$Result <- factor(banca3$Result)
set.seed(2018)

training3.ids <- createDataPartition(banca3$Result, p=0.7, list = F)

mod3  <- svm(Result~.,data=banca3[training3.ids,])
pred3 <- predict(mod3, banca3[-training3.ids,], type = "class")
table(banca3[-training3.ids,"Result"],pred3,dnn = c("Actual","Predicho"))

plot(mod3, data = banca3[training3.ids,], Income ~ Family_size)
plot(mod3, data = banca3[-training3.ids,], Income ~ Family_size)


