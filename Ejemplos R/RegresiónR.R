#Cargamos los datos
dat <- read.csv("../Desktop/Fase 1 R/Data/Día 4/rmse.csv")

#Calcular la raíz del RMSE 
rmse<-sqrt(mean((dat$price - dat$pred)^2))
rmse

#Vamos a graficar los valores tanto de la predicción, cómo de los precios originales. 
plot(dat$price, dat$pred, xlab = "Actual", ylab="Predicho")

#recta con pendiente 1 pasando por cero, lo cual sería lo perfecto lo cual no es factible
abline(0,1)

#crear una función que genere el validador
rmse <- function(actual, predicted){
  return(sqrt(mean((actual-predicted)^2)))
}

#Pasamos los parámetros
rmse(dat$price, dat$pred)


#REGRESIÓN LINEAL
library(caret)

#Cargamos la data
auto <- read.csv("../data/tema4/auto-mpg.csv")

#Convertimos la variable categórica cilindros a factor, para indicarle la etiqueta
auto$cylinders <- factor(auto$cylinders,
                         levels = c(3,4,5,6,8),
                         labels = c("3c", "4c", "5c", "6c", "8c"))

#crearemos la semilla
set.seed(2018)

#crearemos un dataset de entrenamiento aleatorio
t.id <- createDataPartition(auto$mpg, p = 0.7, list = F)

#vemos las variables
names(auto)

#se genera el modelo

mod <- lm(mpg ~ ., data = auto[t.id,-c(1,8,9)])

mod

#me da los coeficientes necesarios para armar mi ecuación lineal

#mpg = 38.607312 +
#     + 7.212652*4c + 5.610350*5c + 3.307172*6c + 6.211343*8c +
#     + 0.006878 * displacement - 0.072209 * horsepower +
#     - 0.005156 * weight + 0.024852 * acceleration


summary(mod)

#diagrama de caja y bigotes

boxplot(mod$residuals)



# calculamos el error

sqrt(mean((mod$fitted.values - auto[t.id,]$mpg)^2))

#elaborar la predicción
pred <- predict(mod, auto[-t.id, -c(1,8,9)])

sqrt(mean((pred - auto[-t.id,]$mpg)^2))

par(mfrow=c(2,2))

plot(mod)
