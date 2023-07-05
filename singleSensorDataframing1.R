# -------- SETUP --------

#include libraries
knitr::opts_chunk$set(echo = TRUE)

library(dplyr)      #General Data wrangling
library(readr)      #File reading and writing
library(stringr)    #String reading
library(knitr)      #Markdown file exporting
library(tidyr)      #Data formatting
library(lubridate)  #Date-Time Wrangling

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
} else {
  stop("Excess Arguments: Required ImportPath, ExportPath, SensorName, SensorLocation", call.=FALSE)
}
  

# -------- DATA IMPORTING --------

#Path to files: provided by argument

#Column Names for sensor data. 
# -- Taken from the Sensor Data Format.txt file -- 
# -- Names provided from the npha_Neo3.pro reduction routine: Shouldn't need to be changed unless the reduction routine is changed -- 
colNames <- c("year", "floatDate", "floattime", "r0_1", "Cn2", "residual_Kolmo", 
              "r0Kalman", "L0Kalman", "residual_Kalman", "r0power", "r0expo", 
              "residual_power", "r0max", "r0min", "Cn2max", "Cn2min",
              "r0noTT(0)", "Cn2noTT", "r0noTT(1)", "residual_KolmonoTT", "imamax", 
              "npixsat", "offsets(0)", "offsets(1)", "flagdata") 


#Creation of lists of Files for each sensor
# -- A single command saves each .txt as a seperate dataframe in a list. -- 
# -- Function Arguments: 
#      path: where to look for files
#      pattern: What to match
#      all.files: Include hidden files in search
#      full.names: Include absolute path name in filename
#      recursive: Search all subFolders
fileList <- list.files(path=importPath, 
                         pattern=".txt", 
                         all.files=TRUE, 
                         full.names=TRUE, 
                         recursive=TRUE) 

#Import data
# -- Runs read.table on every file in the file list, saving each dataframe in a list of dataframes. --
# -- Function Arguments
#    lapply: 
#        fileListExample: List to execute on
#        function to execute: Read.table
#             x: element to read
#             header: Assume no header in the files
#             col.names: Read in data assigning these names to each column
dataList <- lapply(fileList, function(x) read.table(x, header = FALSE, col.names = colNames) )  

#Join individuals into masterDataframe
# -- bind_rows takes a list of dataframes and combines them into one, appending rows to the end of the dataFrame. --
dataFrame <- bind_rows(dataList) 

# -------- DATA TIDYING --------

#Convert from Floatdate and floatTime to date-time object
# -- floatDate is the month.(day/31). We simply reverse the math to get the month and day seperately. 
# -- floatTime is the hour.(minute/60 + seconds/3600)
# -- paste to turn the columns into a string that can be parsed by ymd_hm()
# -- select to drop the excess columns
dataFrame <- dataFrame %>% mutate(month=floor(floatDate), 
                                  day = as.integer((floatDate-month)*31)) %>% 
                           mutate(hour = floor(floattime), 
                                  minute=as.integer(round((floattime-hour)*60)) ) %>% 
                           mutate(dateTime= ymd_hm( paste(year, month, day, hour, minute), tz="HST") ) %>% 
                           select(dateTime, r0_1, Cn2, residual_Kolmo, r0Kalman, L0Kalman, residual_Kalman,
                                  r0power, r0expo, residual_power, r0max, r0min, Cn2max, Cn2min, r0noTT.0.,
                                  Cn2noTT, r0noTT.1., residual_KolmonoTT, imamax, npixsat, offsets.0.,
                                  offsets.1., flagdata) 

#Add the Sensor name as a column
dataFrame <- dataFrame %>% mutate(sensor=sensorName, location=sensorLocation)


# -------- DATA EXPORTING --------

#Add the export path to the beginning of the specific .csv name
# -- Additional argument: sep: added to remove the usually added space
(exportfPath <-paste(exportPath, sensorName, "-", sensorLocation, ".csv", sep=""))

#Add information such as given import and export path
#https://stackoverflow.com/questions/22875967/how-can-i-append-a-header-to-a-csv-file-i-am-writing-out-in-r
writeLines(c(paste("Import path:", importPath), 
             paste("Export path:", exportPath), 
             paste("Sensor:", sensorName), 
             paste("Sensor Location:", sensorLocation) ), exportfPath)
                   
#Export dataframe as a .csv
write.table(dataFrame, exportfPath, row.names=FALSE, col.names=FALSE, append=TRUE, sep=",")
