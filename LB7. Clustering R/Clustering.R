#########################
#  Ejercicio Clustering #
#  José Girón          #
#######################

#Lectura de archivo csv
proteina <- read.csv("../Desktop/protein.csv")

################
# Clustering R #
###############

#Normalización de los datos
proteina.normal <- as.data.frame(scale(proteina[,-1]))

#Se agrega la variable categórica
proteina.normal$Country = proteina$Country

#Se cambia el nombre a las filas, para su uso en el dendagrama
rownames(proteina.normal) = proteina.normal$Country

###############################
# Cluster método aglomerativo #
##############################

#Creación del clúster
clusterA<- hclust(dist(proteina.normal, method = "euclidean"), method = "ward.D2")
clusterA

#Plot del cluster (dendograma)
plot(clusterA, hang = -0.01,cex=0.7)

#plot con clusters definidos
cut  <- cutree(clusterA, k=5)
table(cut)
rect.hclust(clusterA, k=5, border = "blue") 

###################
# Cluster K-Means #
##################

#factoextra
install.packages("devtools")
library(devtools)
devtools::install_github("kassambara/factoextra")
library(factoextra)

#Clúster con K-means
proteina.normal$Country <- NULL
clusterKM <- kmeans(proteina.normal, 3)
clusterKM
aggregate(proteina.normal, by = list(cluster=clusterKM$cluster), mean)

#plot de cluster con k means
fviz_cluster(clusterKM, data=proteina.normal)


##########################
# Variables Estadísticas #
#########################

#Media
mean(proteina$Milk, na.rm = TRUE)
#Desviación estándar
sd  (proteina$Milk, na.rm = TRUE)
#Moda
Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}
mode(proteina$Milk)

#Resumen
summary(proteina)
