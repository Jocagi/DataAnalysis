###################################
#       Examen Parcial 2          #
#         José Girón              #
###################################

####################################################
# a.	De la base de datos llamada "intensos_db"    #
#   i.	Genere la estadística General de los datos #
####################################################


#Lectura de archivos csv
intensos_db <- read.csv("../Desktop/intensos_db.csv", sep = ";")

#Resumen
summary(intensos_db)

#####################################################
#b.	Por medio del algoritmo K-Means realizar los    #
#    cluster que mejor agrupen la información dada. #
#####################################################

#librerías
library(devtools)
library(factoextra)

#Colocar columna en null
intensos_db$Cliente <- NULL

#Normalizar los datos
intensos_db.norm <- as.data.frame(scale(intensos_db))

#Crear clúster con K-means
KM <- kmeans(intensos_db.norm, 3)
KM

#Resumir las variables
aggregate(intensos_db.norm, by = list(cluster=KM$cluster),mean)


#Clúster jerárquico
clusterA<- hclust(dist(intensos_db.norm, method = "euclidean"), method = "ward.D2")
clusterA


################################
# c.	Debe de crear los plots  #
################################


#Plot del cluster (dendograma)
plot(clusterA, hang = -0.01,cex=0.7)

#plot con clusters definidos
cut  <- cutree(clusterA, k=3)
table(cut)
rect.hclust(clusterA, k=3, border = "blue") 

#Visualizar el cluster k-means
fviz_cluster(KM, data=intensos_db.norm)


####################################################################
# e.	Generar las reglas de asociación del dataset (intensos_pdr). #
####################################################################

#leer archivo csv
intensos_pdr <- read.transactions("../Desktop/intensos_pdr.csv" ,sep = ";", format="basket")

#Transaction
trans <- as(intensos_pdr, "transactions")

dim(trans)

itemLabels(trans)

summary(trans)

itemFrequencyPlot(trans, topN=10,cex.name=0.7)


############################################################
# f.	Utilizar un support = 0.001 y un confidence de 0.3   #
# g.	El mínimo de artículos para la regla será de 2       #
############################################################

#librerías
library(arules)
library(arulesViz)


#Algoritmo A priori
#Support 0.001, confidence 0.3, artículos min 2

regla <- apriori(trans,
                 parameter = list(supp=0.001, conf=0.3,
                                  maxlen=5,
                                  minlen=2,
                                  target="rules"))

inspect(regla)

#Reglas de mayor 
subreglaLIFT <- head(regla, n=5, by="lift")
inspect(subreglaLIFT)
plot(subreglaLIFT, method="graph", engine = "htmlwidget")
