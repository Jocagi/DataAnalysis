library(caret)
library(rpart)
library(rpart.plot)
library(e1071)
library(randomForest)
library(ROCR)


########## SVM ###########

#Cargar data

datos <- read.csv("C:/Users/Jose/Desktop/vacation-trip-classification.csv", sep = ";")

set.seed(2018)

datos$Result <- factor(datos$Result)

#Entrenamiento

training.ids <- createDataPartition(datos$Result, p=0.7, list = F)

#Clasificación

mod  <- svm(Result~.,data=datos[training.ids,])

#Resultados

#Matriz de resultados
table(datos[training.ids,"Result"],fitted(mod),dnn=c("Actual","Predicted"))      

#Classification plot
plot(mod, data = datos[training.ids,], Income ~ Family_size)
plot(mod, data = datos[-training.ids,], Income ~ Family_size)

probs <- predict(mod, datos[-training.ids,], type = "prob")
head(probs)

pred <- prediction(probs[,2],datos[-training.ids,"class"])
perf <- performance(pred, "tpr","fpr")
plot(perf)