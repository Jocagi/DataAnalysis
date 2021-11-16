###################################
#         Examen Final            #
#         José Girón              #
###################################

#librerias
library(caret)
library(rpart)
library(rpart.plot)
library(ROCR)
library(randomForest)
library(e1071)



#Cargar datos
datos <- read.csv("C:/Users/Jose/Desktop/BankOnline.csv", sep = ';')

#Estadística general de los datos
summary(datos)

#Semilla para replicar resultados
set.seed(2018)


###
# Modelo: Decision Tree
###

#Cargar datos
datos <- read.csv("C:/Users/Jose/Desktop/BankOnline.csv", sep = ';')


#Data partition
training.ids <- createDataPartition(datos$online, p=0.7, list = F)

#Generación del modelo
mod <- rpart(online~. , 
             data = datos[training.ids,],
             method = "class",
             control = rpart.control(minsplit = 20, cp=0.01))
mod

#Mostrar árbol
prp(mod, type = 2, extra = 104, nn=TRUE,
    fallen.leaves = TRUE, faclen = 5, varlen = 8,
    shadow.col = "gray")
mod$cptable

#Realizar la poda
mod.pruned <- prune(mod, mod$cptable[4,"CP"])

#Mostrar árbol
prp(mod, type = 2, extra = 104, nn=TRUE,
    fallen.leaves = TRUE, faclen = 4, varlen = 8,
    shadow.col = "gray")

#Realizar predicción
pred.pruned <- predict(mod.pruned, datos[-training.ids,], type = "class")

#Resultados
table(datos[-training.ids,]$online, pred.pruned,
      dnn = c("Actual","Predicho"))
pred.pruned2 <- predict(mod.pruned, datos[-training.ids,], type = "prob")
head(pred.pruned)
head(pred.pruned2)

#ROC
pred <- prediction(pred.pruned2[,2], datos[-training.ids,"online"])
perf <- performance(pred,"tpr","fpr")
plot(perf)


###
# Modelo: Random Forest
###

#Cargar datos
datos2 <- read.csv("C:/Users/Jose/Desktop/BankOnline.csv", sep = ';')

datos2$online <- factor(datos2$online)

#Data partition
training.ids2 <- createDataPartition(datos2$online, p=0.7, list = F)

#Generar modelo
mod2 <- randomForest(x = datos2[training.ids2,1:4],
                     y = datos2[training.ids2,5],
                     ntree = 500,
                     keep.forest = TRUE)

#Realizar predicción
pred2 <- predict(mod2, datos2[-training.ids2,], type = "class")
pred2

#Resultados
table(datos2[-training.ids2,"online"],pred2,dnn = c("Actual","Predicho"))

#ROC
probs2 <- predict(mod2, datos2[-training.ids2,], type = "prob")
head(probs2)

pred2 <- prediction(probs2[,2], datos2[-training.ids2,"online"])
perf2 <- performance(pred2, "tpr","fpr")
plot(perf2)


###
# Modelo: SVM
###

#Cargar datos
datos3 <- read.csv("C:/Users/Jose/Desktop/BankOnline.csv", sep = ';')

datos3$online <- factor(datos3$online)

#Data partition
training3.ids <- createDataPartition(datos3$online, p=0.7, list = F)

#Generación del modelo
mod3  <- svm(online~.,data = datos3[training3.ids,])

#Realizar predicción
pred3 <- predict(mod3, datos3[-training3.ids,], type = "class")

#Resultados
table(datos3[-training3.ids,"online"], pred3,dnn = c("Actual","Predicho"))

plot(mod3, data = datos3[training3.ids,], profit ~ income)
plot(mod3, data = datos3[-training3.ids,], profit ~ income)

#ROC
probs3 <- predict(mod2, datos3[-training.ids2,], type = "prob")
head(probs3)

pred2 <- prediction(probs2[,2], datos2[-training.ids2,"online"])
perf2 <- performance(pred2, "tpr","fpr")
plot(perf2)


#Serie 5
#Análisis de Componentes principales

#Carga de datos
bank <- read.csv("C:/Users/Jose/Desktop/BankOnline.csv", sep = ';')

#Transformación de valores
apply(bank, 2, var)

#ACP
acp <- prcomp(bank, center = TRUE, scale = TRUE)
print(acp)

#Plot de resultados
plot(acp, type="l")
summary(acp)

biplot(acp, scale = 0)

#Columnas
pc1 <- apply(acp$rotation[,1]*bank,1,sum)
pc2 <- apply(acp$rotation[,2]*bank,1,sum)

bank$pc1 <- pc1
bank$pc2 <- pc2
