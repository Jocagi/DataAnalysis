###################################
#  Ejercicio Reglas de asociación #
#  José Girón                     #
###################################

install.packages("arules")
install.packages("arulesViz")

library(arules)
library(arulesViz)

#Leer archivo
data_basket <- read.transactions("../Desktop/dataset_MB.csv",sep = ";", format="basket")

#Transaction

trans <- as(data_basket,"transactions")

dim(trans)

itemLabels(trans)

summary(trans)

itemFrequencyPlot(trans, topN=10,cex.name=0.7)

#Algoritmo A priori

#support 0.001 confidence 0.25, artículos min 2

regla <- apriori(trans,
                 parameter = list(supp=0.001, conf=0.25,
                                  maxlen=5,
                                  minlen=2,
                                  target="rules")
)

inspect(regla)

#Plot

plot(regla)

subregla <- head(regla, n=5, by="confidence")
plot(subregla, method="graph", engine = "htmlwidget")
inspect(regla)


#Reglas de mayor 

subreglaLIFT <- head(regla, n=5, by="lift")
inspect(subreglaLIFT)
