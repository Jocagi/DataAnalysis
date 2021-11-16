#Análisis de Componentes principales ACP
#Carga de dataset

usarrests <- read.csv("../Data/Día 5/USArrests.csv",stringsAsFactors = F)

rownames(usarrests) <- usarrests$X

usarrests$X <- NULL

head(usarrests)

apply(usarrests,2,var)


acp <- prcomp(usarrests, center = TRUE, scale = TRUE)

print(acp)

plot(acp, type="l")

summary(acp)

biplot(acp, scale = 0)

pc1 <- apply(acp$rotation[,1]*usarrests,1,sum)
pc1

pc2 <- apply(acp$rotation[,2]*usarrests,1,sum)
pc2

usarrests$pc1 <- pc1
usarrests$pc2 <- pc2

usarrests[,1:4]<-NULL


#Curva ROC

install.packages("ROCR")
library(ROCR)

data1 <- read.csv("../Data/Día 5/roc-example-1.csv")

pred1 <- prediction(data1$prob, data1$class)

perf1 <- performance(pred1, "tpr", "fpr")

plot(perf1)
lines(par()$usr[1:2],par()$usr[3:4])

prob.cuts.1 <- data.frame(cut=perf1@alpha.values[[1]],
                          fpr = perf1@x.values[[1]],
                          tpr = perf1@y.values[[1]])

head(prob.cuts.1)

prob.cuts.1[prob.cuts.1$tpr>=0.8,] 
