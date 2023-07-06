#Test script
#Process arguments
args = commandArgs(trailingOnly=TRUE)
#If no argument is supplied
if (length(args)<4) {
  stop("Missing Argument: Required ImportPath, ExportPath, SensorName, SensorLocation", call.=FALSE)
} else if (length(args)==4) {
  importPath=args[1]
  exportPath=args[2]
  sensorName=args[3]
  sensorLocation=args[4]
}

library(dplyr)      #General Data wrangling
library(readr)      #File reading and writing
library(stringr)    #String reading
library(knitr)      #Markdown file exporting
library(tidyr) 

dataframe <-  data.frame (
  Training = c("Strength", "Stamina", "Other"),
  Pulse = c(100, 150, 120),
  Duration = c(60, 30, 45) )

writeLines(c(paste("Import path:", importPath), 
             paste("Export path:", exportPath), 
             paste("Sensor:", sensorName), 
             paste("Sensor Location:", sensorLocation) ), "test.csv")

#Export dataframe as a .csv
write.table(dataframe, "test.csv", row.names=FALSE, col.names=FALSE, append=TRUE, sep=",")


#scratch SQL
query <- dbSendQuery()
dbBind(query, list)
dbFetch(query)

dbClearResults(query)

