install.packages("e1071")
library(caret)
library(e1071)

banca3 <- read.csv("../Data/Día 5/banknote-authentication.csv")
banca3$class <- factor(banca3$class)
set.seed(2018)


t.ids  <- createDataPartition(banca3$class, p=0.7, list = F)

mod  <- svm(class~.,data=banca3[t.ids,]
            )
table(banca3[t.ids,"class"],fitted(mod),dnn=c("Actual","Predicho"))      

plot(mod, data = banca3[t.ids,], skew ~ variance)
plot(mod, data = banca3[-t.ids,], skew ~ variance)
