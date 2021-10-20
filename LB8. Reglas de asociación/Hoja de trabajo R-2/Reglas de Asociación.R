#importar librerias
install.packages("arules")
install.packages("arulesViz")
library(arules)
library(arulesViz)
#lectura archivo
market_basket <- read.transactions("../Desktop/dataset_MB.csv",sep = ";", format="basket")
trans <- as(market_basket,"transactions")
dim(trans)
itemLabels(trans)
summary(trans)
image(trans)
#reglas
itemFrequencyPlot(trans, topN=10,cex.name=0.7)
regla <- apriori(market_basket,
                 parameter = list(supp=0.001, conf=0.25,
                                  maxlen=10,
                                  target="rules")
)
summary(regla)
inspect(regla)
regla <- apriori(trans,
                 parameter = list(supp=0.001, conf=0.25,
                                  maxlen=10,
                                  minlen=2,
                                  target="rules")
)
inspect(regla)
# plot
plot(regla)
subregla <- head(regla, n=10, by="confidence")
plot(subregla, method="graph", engine = "htmlwidget")

