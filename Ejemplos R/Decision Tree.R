#paquetes

install.packages(c("rpart","rpart.plot","caret"))
library(caret)
library(rpart)
library(rpart.plot)

#cargar data

banca <- read.csv("../Data/Día 5/banknote-authentication.csv")

set.seed(2018)

training.ids <- createDataPartition(banca$class, p=0.7, list = F)

#crear modelo
mod <- rpart(class~. , 
             data = banca[training.ids,],
             method = "class",
             control = rpart.control(minsplit = 20, cp=0.01))

mod

prp(mod, type = 2, extra = 104, nn=TRUE,
    fallen.leaves = TRUE, faclen = 4, varlen = 8,
    shadow.col = "gray")

mod$cptable

mod.pruned <- prune(mod, mod$cptable[8,"CP"])


prp(mod, type = 2, extra = 104, nn=TRUE,
    fallen.leaves = TRUE, faclen = 4, varlen = 8,
    shadow.col = "gray")

pred.pruned <- predict(mod.pruned, banca[-training.ids,], type = "class")

table(banca[-training.ids,]$class, pred.pruned,
      dnn = c("Actual","Predicho"))

pred.pruned2 <- predict(mod.pruned, banca[-training.ids,], type = "prob")

head(pred.pruned)
head(pred.pruned2)

library(ROCR)

pred <- prediction(pred.pruned2[,2], banca[-training.ids,"class"])
perf <- performance(pred,"tpr","fpr")
plot(perf)

#Random Forest

install.packages("randomForest")
library(caret)
library(randomForest)


