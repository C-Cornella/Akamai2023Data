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

colNames <- c("year", "floatDate", "floattime", "r0_1", "Cn2", "residual_Kolmo", 
              "r0Kalman", "L0Kalman", "residual_Kalman", "r0power", "r0expo", 
              "residual_power", "r0max", "r0min", "Cn2max", "Cn2min",
              "r0noTT(0)", "Cn2noTT", "r0noTT(1)", "residual_KolmonoTT", "imamax", 
              "npixsat", "offsets(0)", "offsets(1)", "flagdata") 

fileList <- list.files(path=importPath, 
                       pattern=".txt", 
                       all.files=TRUE, 
                       full.names=TRUE, 
                       recursive=TRUE) 

dataList <- lapply(fileList, function(x) read.table(x, header = FALSE, col.names = colNames) )
dataFrame <- bind_rows(dataList) 


parse_day <- function(floatDate, month){
  #temp=as.numeric(paste(floor(floatDate), ".00000", sep=""))
  ifelse({as.integer(round((floatDate-floor(floatDate))*31))==0}, 
         {return(31)}, 
         { return(as.integer(round((floatDate-month)*31)))} )
}

# -- parse_month simply checks, and if it's a 31, just subtract one from the value.
parse_month <- function(floatDate) {
  ifelse({as.integer(round((floatDate-floor(floatDate))*31))==0},
         {return(floor(floatDate)-1)},
         {return(floor(floatDate)) })
  
}

(month <- parse_month(8.5) )
(day <- parse_day(8.5, month) )


#scratch SQL
#query <- dbSendQuery()
#dbBind(query, list)
#dbFetch(query)

#dbClearResults(query)
