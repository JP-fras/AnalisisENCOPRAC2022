#las siguientes lineas son para limpieza
rm(list=ls())
gc()

library(ggplot2)
library(dplyr)

datos <- read.delim("base_usuario_encoprac2022.txt", sep = "|")

datos
str(datos)

#Analisis a variables Cuantitativa Edad de primer consumo de alcohol
edades_primer_consumo_alc<-datos$AL_03
edades_primer_consumo_alc<-na.omit(edades_primer_consumo_alc)
edades <- data.frame(edades_primer_consumo_alc)

#ANALISIS UNIVARIADO DE UNA CUALITATIVA
#Analizo quienes se acuerdan y quienes no
#Elimino a los que no contestaron
no_recuerdan <- edades[edades$edades_primer_consumo_alc !=999, ]
#Factorizo a recuerda no recuerda
recuerdan <- edades %>% mutate(edades_primer_consumo_alc = ifelse(edades_primer_consumo_alc==998, "No se acuerda", "Se acuerda"))
recuerdan$edades_primer_consumo_alc<-as.factor(recuerdan$edades_primer_consumo_alc)

#Grafico
# Contamos cuántos hay de cada categoría
datos_pie <- recuerdan %>%
  group_by(edades_primer_consumo_alc) %>%
  summarise(cantidad = n()) %>%
  ungroup() %>%
  mutate(pct = round(cantidad / sum(cantidad) * 100, 1),
         etiqueta = paste0(edades_primer_consumo_alc, " (", pct, "%)"))

# Gráfico de torta
ggplot(datos_pie, aes(x = "", y = cantidad, fill = edades_primer_consumo_alc)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar(theta = "y") +
  theme_void() +
  geom_text(aes(label = etiqueta), position = position_stack(vjust = 0.5)) +
  labs(fill = "Recuerda o no")


#ANALISIS UNIVARIADO DE UNA CUALITATIVA
#Ahora analizo las edades de los que se acuerdan
#Elimino no contesta y no recuerda
edades <- edades[edades$edades_primer_consumo_alc != 998 & edades$edades_primer_consumo_alc != 999,]
class(edades)
summary(edades)
edades <- data.frame(edades)

ggplot(edades, aes(x = edades)) +
  geom_histogram(binwidth = 3, fill = "tomato", color = "black") +
  scale_x_continuous(breaks = seq(0, max(edades$edades), 3),
                     labels = function(x) paste0(x, "-", x+2)) +
  labs(title = "Distribución de edad al primer consumo de alcohol",
       x = "Edad",
       y = "Frecuencia") +
  theme_minimal()

summary(edades)

#ANALISIS BIVARIADO DE 2 CUANTITATIVAS
#CUANTITATIVA CON CUANTITATIVA
#EDAD CON DIAS QUE BEBIO AL MES
edad_persona<-datos$EDAD_SEL
dias_bebidos_mes<-datos$AL_23
edad_dias_bebidos<-data.frame(edad_persona, dias_bebidos_mes)
edad_dias_bebidos<-na.omit(edad_dias_bebidos)
edad_dias_bebidos<-edad_dias_bebidos[edad_dias_bebidos$dias_bebidos_mes!=999 & edad_dias_bebidos$dias_bebidos_mes!=998, ]

summary(edad_dias_bebidos)
summary(edad_dias_bebidos$dias_bebidos_mes)

corre<-cor(edad_dias_bebidos$edad_persona, edad_dias_bebidos$dias_bebidos_mes)

#nube de punto
ggplot(edad_dias_bebidos, aes(x = edad_persona, y = dias_bebidos_mes)) +
  geom_point(alpha = 0.6, color = "steelblue") +
  geom_smooth(method = "lm", color = "red", se = TRUE) +
  labs(title = "Relación entre Edad Actual y Dias que bebe Alcohol",
       y = "Dias al mes que bebe Alcohol",
       x = "Edad actual (años)") +
  scale_x_continuous(breaks = seq(15, 100, 5))+
  scale_y_continuous(breaks = seq(0, 31, 5)) +
  theme_bw()

#Ahora con edad y dias al mes que fuman
dias_fumados<-datos$TA_10
edad_dias_fumados<-data.frame(edad_persona, dias_fumados)
edad_dias_fumados<-na.omit(edad_dias_fumados)
edad_dias_fumados<-edad_dias_fumados %>% filter(edad_dias_fumados$dias_fumados!=999 & edad_dias_fumados$dias_fumados!=998 & edad_dias_fumados$dias_fumados!=99 & edad_dias_fumados$dias_fumados!=98)
corre<-cor(edad_dias_fumados$edad_persona, edad_dias_fumados$dias_fumados)
summary(edad_dias_fumados$dias_fumados)
#nube de punto
ggplot(edad_dias_fumados, aes(x = edad_persona, y = dias_fumados)) +
  geom_point(alpha = 0.6, color = "steelblue") +
  geom_smooth(method = "lm", color = "red", se = TRUE) +
  labs(title = "Relación entre Edad Actual y Dias que fuma Tabaco",
       y = "Dias al mes que fuma Tabaco",
       x = "Edad actual (años)") +
  scale_x_continuous(breaks = seq(15, 100, 5))+
  scale_y_continuous(breaks = seq(0, 31, 5)) +
  theme_bw()


#GRAFICO DE BARRAS BIVARIADO CUALITATIVA NOMINAL Y CUALITATIVA NO NOMINAL
#RELACION ENTRE NIVEL DE ACTIVIDAD FISICA Y CONSUMO DE ALCOHOL COMO HABITO
actividad<-datos$SA_06
toma_habito<-datos$AL_18__7

actividad_toma<-na.omit(data.frame(actividad,toma_habito))

actividad_toma<-actividad_toma[actividad_toma$actividad !=99,]

actividad_toma$actividad[actividad_toma$actividad == 5] <- 0

actividad_toma$actividad <- factor(actividad_toma$actividad,
                                   levels = 0:4,
                                   labels = c("0","1","2","3","4"))
actividad_toma$toma_habito <- factor(actividad_toma$toma_habito,
                                     levels = 0:1,
                                     labels = c("No","Si"))

labels_fill <- paste0(
  "0 = No realiza regularmente\n",
  "1 = Algunas veces al mes\n",
  "2 = 1 o 2 veces por semana\n",
  "3 = Más de 2 veces por semana\n",
  "4 = Todos los días\n\n",
  "Toma por hábito"
)

ggplot(actividad_toma, aes(x = actividad, fill = toma_habito)) +
  geom_bar(position = position_dodge(width = 0.9)) +
  geom_text(
    stat = "count",
    aes(label = ..count..),
    position = position_dodge(width = 0.9),
    vjust = -0.2
  ) +
  labs(
    title = "Relación entre actividad física y hábito de beber",
    x = "Nivel de actividad física (0-4)",
    y = "Cantidad de personas",
    fill = labels_fill
  ) +
  theme_minimal()
