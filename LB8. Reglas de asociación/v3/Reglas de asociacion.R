install.packages("arules")
install.packages("arulesViz")
library(arules)
library(arulesViz)

#LECTURA DEL ARCHIVO

market_basket <- read.transactions("C:/Users/karen/Downloads/dataset_MB.csv",sep = ";", format="basket")
trans <- as(market_basket,"transactions")

dim(trans)
itemLabels(trans)
summary(trans)
image(trans)

itemFrequencyPlot(trans, topN=10,cex.name=0.7)

#min support 0.001 confidence 0.25
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
plot(regla)


subregla <- head(regla, n=10, by="confidence")
plot(subregla, method="graph", engine = "htmlwidget")