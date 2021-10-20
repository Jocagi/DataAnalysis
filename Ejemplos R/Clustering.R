#Clustering

proteina <- read.csv("../Desktop/Fase 1 R/Data/Día 3/tema5/protein.csv")

#ignoro la variable categórica y normalizo las variables
data <- as.data.frame(scale(proteina[,-1]))

#agrega la variable categórica

data$Country = proteina$Country

#cambiar el nombre de las filas
rownames(data) = data$Country

#clustering 

hc <- hclust(dist(data,method="euclidean"),
             method = "ward.D2")

hc

#plot de clustering para obtener un dendograma

plot(hc, hang = -0.01,cex=0.7)

#matriz de distancia

md <- dist(data, method = "euclidean")
md

#comparar 2 paises

alb <- data["Albania",-10]
aus <- data["Austria",-10]

#distancia euclidea
sqrt(sum((alb-aus)^2))
#distancia manhattan
sum(abs(alb-aus))

#cluster con método simple

hc2 <- hclust(dist(data, method = "euclidean"),
              method = "single")
plot(hc2, hang = -0.01, cex= 0.7)


#cluster complete

hc3 <- hclust(dist(data, method = "euclidean"),method = "complete")

plot(hc3, hang = -0.01, cex = 0.7)


#cluster average

hc4 <- hclust(dist(data, method = "euclidean"),method = "average")

plot(hc4, hang = -0.01, cex = 0.7)

hc3$merge
hc4$merge

#cluster divisitivo

install.packages("cluster")
library(cluster)

#DIANA (DIvisive ANAlysis)
dv  <- diana(data, metric = "euclidean")
par(mfrow=c(1,1))
plot(dv)

#cortes de cluster o del dendograma
hc
plot(hc, hang = -0.01,cex=0.7)
x  <- cutree(hc,k=4)
table(x)
rect.hclust(hc,k=4,border = "red")
