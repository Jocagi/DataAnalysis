# Reglas de Asociación

market_basket <-  
  list(  
    c("apple", "beer", "rice", "meat"),
    c("apple", "beer", "rice"),
    c("apple", "beer"), 
    c("apple", "pear"),
    c("milk", "beer", "rice", "meat"), 
    c("milk", "beer", "rice"), 
    c("milk", "beer"),
    c("milk", "pear")
  )

#renombro las transacciones

names(market_basket) <- paste("T",c(1:8),sep = "")

install.packages("arules")
install.packages("arulesViz")

library(arules)
library(arulesViz)

trans <- as(market_basket,"transactions")

dim(trans)

itemLabels(trans)

summary(trans)

image(trans)

itemFrequencyPlot(trans, topN=10,cex.name=0.7)

#Algoritmo A priori

#min support 0.3 confidence 0.5

regla <- apriori(market_basket,
                 parameter = list(supp=0.3, conf=0.5,
                                  maxlen=10,
                                  target="rules")
                                  )

summary(regla)
inspect(regla)


regla <- apriori(trans,
                 parameter = list(supp=0.3, conf=0.5,
                                  maxlen=10,
                                  minlen=2,
                                  target="rules")
)

inspect(regla)


#analizar una regla específica


regla <- apriori(trans,
                 parameter = list(supp=0.3, conf=0.5,
                                  maxlen=10,
                                  minlen=2),
                                  appearance = list(default="lhs",rhs="beer"))

inspect(regla)


#para evaluar que artículos compran las persona luego de comprar cerveza

regla <- apriori(trans,
                 parameter = list(supp=0.3, conf=0.5,
                                  maxlen=10,
                                  minlen=2),
                 appearance = list(lhs="beer",default="rhs"))


inspect(regla)

#usando arulesViz

plot(regla)

plot(regla, measure = "confidence")

subregla <- head(regla, n=10, by="confidence")
plot(subregla, method="graph", engine = "htmlwidget")
inspect(regla)
