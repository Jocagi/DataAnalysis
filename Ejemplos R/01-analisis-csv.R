#URL 2021

#establecer mi carpeta 

setwd("../Fase 1 R/")

getwd()

#lectura de CSV
install.packages("MASS")

auto <- read.csv("../Fase 1 R/Data/data_auto.csv", 
                 header = TRUE, sep = ",", 
                 na.strings = "",
                 stringsAsFactors = FALSE)
names(auto)

#read.csv2 == read.csv("filename", sep = ";", dec = ",") el separador es punto y coma
# sep = "\t" 
#qué pasa si no tengo cabezera

auto_no_header <- read.csv("../Fase 1 R/Data/data_auto.csv", header = FALSE)
head(auto_no_header, 4)

auto_no_sense <- read.csv("../Fase 1 R/Data/data_auto_noheader.csv")
head(auto_no_sense, 4)

auto_custom_header <- 
  read.csv("../Fase 1 R/Data/data_auto_noheader.csv",
           header = F, 
           col.names = c("numero", "millas_por_galeon", "cilindrada", 
                         "desplazamiento", "caballos_de_potencia", 
                         "peso", "aceleracion", "año", "modelo"
                         )
           )

head(auto_custom_header, 2)


from_internet <- read.csv("http://datos.gob.ve/sites/default/files/Cuadro16-Internet.csv.csv", sep=";")

#NA : not available para categoricas se usa na.strings=""
#as.character()
#stringsAsFactors viene por defecto TRUE pero si queremos seguir manejándolo cómo caracter se coloca en false o as.character()

#Cómo extraer la información
lista_de_autos <- auto$car_name

head(auto, 3
    )

#obtnego la fila 1 a la 5 y todas las columnas 
auto[1:5,]

#obtengo las primeras 3 columnas y todas las filas
auto[,1:3]

#LECTURA DE JSON

install.packages("jsonlite")
library(jsonlite)

data <- fromJSON("../Desktop/Fase 1 R/Data/students.json")
data2 <- fromJSON("../Desktop/Fase 1 R/Data/student-courses.json")

#Crear Ficheros

clientes <- c("Juan Gabriel", "Ricardo", "Pedro")
fechas <- as.Date(c("2017-12-27", "2017-11-1", "2018-1-1"))
pago <- c(315, 192.55, 40.15)
pedidos <- data.frame(clientes, fechas, pago)

#Formatos para guardar

save(pedidos, file = "../Desktop/Fase 1 R/pedidos.Rdata")
saveRDS(pedidos, file="../Desktop/Fase 1 R/pedidos.rds")

remove(pedidos)


load("../Desktop/Fase 1 R/pedidos.Rdata")

orders <- readRDS("../Desktop/Fase 1 R/pedidos.rds")

#datos sin valor

data <- read.csv("../Desktop/Fase 1 R/Data/missing-data.csv", na.strings = "")

data.cleaned <- na.omit(data)

#cONTIENE NULL LA FILA 4 COLUMNA 2
is.na(data[4,2]) 
#cONTIENE NULL LA FILA 4 COLUMNA 1
is.na(data[4,1])

#SI SE LO APLICO A TODO UN VECTOR cONTIENE NULL LA FILA 4 COLUMNA 1
is.na(data$Income)

#####LIMPIEZA SELECTIVA

#Limpiar NA de solamente la variable Income
data.income.cleaned <- data[!is.na(data$Income),]

#Filas completas para un data frame
complete.cases(data)
data.cleaned.2 <- data[complete.cases(data), ]

#Convertir los ceros de ingresos en NA
data$Income[data$Income == 0] <- NA

#Medidas de centralizaciÃ³n y dispersiÃ³n
mean(data$Income)
mean(data$Income, na.rm = TRUE)

sd(data$Income)
sd(data$Income, na.rm = TRUE)


###### rEEMPLAZAR NA CON MEDIA O EXTRACCIÓN ALEATORIA

data <- read.csv("../Fase 1 R/Data/missing-data.csv", na.strings = "")

#CREO UNA NUEVA COLUMNA PARA ALMACENAR EL EJERCICIO
data$Income.mean <- ifelse(is.na(data$Income), 
                           mean(data$Income, na.rm = TRUE),
                           data$Income
)

#para casos aleatorios
#x es un vector de datos que puede contener NA (la variable de entrada)
rand.impute <- function(x) {
  # missing contiene un vector de valores booleanos T/F dependiendo del NA de x
  missing <- is.na(x)
  #n.missing contiene cuantos valores son NA dentro de x (me devuelve el número de verdaderos)
  n.missing <- sum(missing)
  #x.obs son los valores conocidos que tienen dato diferente de NA en x. (!=lo contrario)
  x.obs <- x[!missing]
  #por defecto, devolvera lo mismo que había entrado por parÃ¡metro
  imputed <- x
  #en los valores que faltaban, los reemplazamos por una muestra aleatoria simple con reemplazo
  #de los que si conocemos (MAS) donde n.missing me dice cuantos valores voy a obtener
  imputed[missing] <- sample(x.obs, n.missing, replace = TRUE)
  return (imputed)
}

#llama la anterior para cada una de las columnas que se necesita

random.impute.data.frame <- function(dataframe, cols){
#nombres de las columnas que llegan por parámetro a cols
  names <- names(dataframe)
#dentro de cada columna dentro del array de nombre que llegue por parámetro
  for(col in cols){
#concatena el nombre de la columna, con el nombre imputed sin separador EJ. ingresos.imputed
    name <- paste(names[col], "imputed", sep = ".")
    dataframe[name] = rand.impute(dataframe[,col])
  }
  dataframe
}


data <- read.csv("../Desktop/Fase 1 R/Data/missing-data.csv", na.strings = "")
data$Income[data$Income==0]<-NA
data <- random.impute.data.frame(data, c(1,2))
