library(ggplot2)
library(dplyr)

df <- read.csv("C:/Users/karol/Pulpit/Inf_sem1/wizualizacja/modified_data.csv")

#piechart z typem ataków 
df_attackType <- df$Attack.Type
pie(table(df_attackType))

#piechart z typem podjętej akcji 
df_actionTaken <- df$Action.Taken
pie(table(df_actionTaken))

#wykres liniowy z rozkładem ataków w czasie
df$Timestamp <- as.Date(df$Timestamp)
df$Timestamp <- format(df$Timestamp, "%Y-%m")
df_attackTime <- data.frame(table(df$Timestamp))
df_attackTime$Var1 <- as.Date(paste(df_attackTime$Var1, "-01", sep = ""), 
                              format = "%Y-%m-%d")

ggplot(df_attackTime, aes(x = Var1, y = Freq)) + 
  geom_point(size = 1) + geom_line() +
  labs(x = "Czas", y = "Ilość ataków") + theme_minimal()
 

#procent krajów w których source = destination 
df <- mutate(df, is.same = Destination.Country == Source.Country)
pie(table(df$is.same))
