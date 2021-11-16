#REGRESIÓN LINEAL

#Carga de datos
dat <- read.csv("C:/Users/Jose/Desktop/articulos_ml.csv")

#Paquetes para regresión
install.packages("caret")
library(caret)

#ver las variables
names(dat)

#crear la semilla
set.seed(2020)

# dataset de entrenamiento aleatorio
# p (Proporción de datos de entrenamiento) 70%
# list (Si lo quieres en una lista) F - False
t.id <- createDataPartition(data$X..Shares, p = 0.7, list = F)

# se genera el modelo
# ~ . (Significa "en función de todo")
# Excluyendo valores que no son útiles
mod <- lm(X..Shares ~ ., data = dat[t.id,-c(1,2)])
mod
summary(mod)

#diagrama de caja y bigotes
boxplot(mod$residuals)

#calcular el error
sqrt(mean((mod$fitted.values - dat[t.id,]$X..Shares)^2))

#elaborar la predicción
pred <- predict(mod, dat[-t.id, -c(1,2)])

sqrt(mean((pred - dat[-t.id,]$X..Shares)^2))

par(mfrow=c(2,2))

plot(mod)






