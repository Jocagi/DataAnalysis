#K-means

proteina <- read.csv("../../Clustering/protein.csv")

#convertir el nombre de las columnas
rownames(proteina) <- proteina$Country

#null country
proteina$Country <- NULL

#normalizar los datos
proteina.norm <- as.data.frame(scale(proteina))

#factoextra
install.packages("devtools")
library(devtools)

devtools::install_github("kassambara/factoextra")
library(factoextra)

#cluster con K-means

KM <- kmeans(proteina.norm,3)
KM

#resumir las variables

aggregate(proteina.norm, by = list(cluster=KM$cluster),mean)

#visualizar el cluster
fviz_cluster(KM, data=proteina.norm)
