
#Random Forest

install.packages("randomForest")
library(caret)
library(randomForest)

banca2 <- read.csv("../Data/Día 5/banknote-authentication.csv")
banca2$class <- factor(banca2$class)


set.seed(2018)

training.ids2 <- createDataPartition(banca2$class, p=0.7, list = F)

mod <- randomForest(x = banca2[training.ids2,1:4],
                    y= banca2[training.ids2,5],
                    ntree = 500,
                    keep.forest = TRUE)

pred <- predict(mod, banca2[-training.ids2,], type = "class")
table(banca2[-training.ids2,"class"],pred,dnn = c("Actual","Predicho"))

library(ROCR)
probs <- predict(mod, banca2[-training.ids2,], type = "prob")
head(probs)

pred <- prediction(probs[,2],banca2[-training.ids2,"class"])
perf <- performance(pred, "tpr","fpr")
plot(perf)
