knitr::opts_chunk$set(echo = TRUE)

library(dplyr)      #General Data wrangling
library(readr)      #File reading and writing
library(stringr)    #String reading
library(knitr)      #Markdown file exporting
library(tidyr)      #Data formatting
library(lubridate)  #Date-Time Wrangling
library(FITSio)     #Fits file parsing -- Probably unecessary, will likely remove later

# -------- DATA IMPORTING --------

#Path to files: unique path for each airflow unit
# -- This way the script navigates directly to the appropriate directory and doesn't need to be copied into the R script folder --
# -- Shouldn't need to change any of these unless the file organization changes
filePathCy <- "/data/airflow/reduce/cyclone-hx9"
filePathDark <- "/data/airflow/reduce/darkthunder"
filePathFre <- "/data/airflow/reduce/freflow"
filePathPic <- "/data/airflow/reduce/picasso"
filePathTurbo <- "/data/airflow/reduce/turbopanda"


#Column Names for sensor data. 
# -- Taken from the Sensor Data Format.txt file -- 
# -- Names provided from the npha_Neo3.pro reduction routine: Shouldn't need to be changed unless the reduction routine is changed -- 
colNames <- c("floatDate", "floattime", "r0_1", "Cn2", "residual_Kolmo", 
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
fileListCy <- list.files(path=filePathCy, 
                         pattern=".txt", 
                         all.files=TRUE, 
                         full.names=TRUE, 
                         recursive=TRUE)
fileListDark <- list.files(path=filePathDark, 
                           pattern=".txt", 
                           all.files=TRUE, 
                           full.names=TRUE, 
                           recursive=TRUE)
fileListFre <- list.files(path=filePathFre, 
                          pattern=".txt", 
                          all.files=TRUE, 
                          full.names=TRUE, 
                          recursive=TRUE)
fileListPic <- list.files(path=filePathPic, 
                          pattern=".txt", 
                          all.files=TRUE, 
                          full.names=TRUE, 
                          recursive=TRUE)
fileListTurbo <- list.files(path=filePathTurbo, 
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
dataListCy <- lapply(fileListCy, function(x) read.table(x, header = FALSE, col.names = colNames) )  
dataListDark <- lapply(fileListDark, function(x) read.table(x, header = FALSE, col.names = colNames) )
dataListFre <- lapply(fileListFre, function(x) read.table(x, header = FALSE, col.names = colNames) )
dataListPic <- lapply(fileListPic, function(x) read.table(x, header = FALSE, col.names = colNames) )
dataListTurbo <- lapply(fileListTurbo, function(x) read.table(x, header = FALSE, col.names = colNames) )

#Join individuals into masterDataframe
# -- bind_rows takes a list of dataframes and combines them into one, appending rows to the end of the dataFrame. --
dataFrameCy <- bind_rows(dataListCy) 
dataFrameDark <- bind_rows(dataListDark) 
dataFrameFre <- bind_rows(dataListFre) 
dataFramePic <- bind_rows(dataListPic) 
dataFrameTurbo <- bind_rows(dataListTurbo)

# -------- DATA TIDYING --------



# -------- DATA EXPORTING --------

#Default value of path
exportPath <- ""

# -- INSERT DESIRED PATH HERE --
#exportPath <- "/data/airflow/reduce/csv"

#Add the export path to the beginning of the specific .csv name
# -- Additional argument: sep: added to remove the usually added space
exportPathCy <-paste(exportPath, "cyclone-hx9Data.csv", sep="")
exportPathDark <-paste(exportPath, "darkthunderData.csv", sep="")
exportPathFre <-paste(exportPath, "freflowData.csv", sep="")
exportPathPic <-paste(exportPath, "picassoData.csv", sep="")
exportPathTurbo <-paste(exportPath, "turbopandaData.csv", sep="")

#Export dataframe as a .csv
write.csv(dataFrameCy, exportPathCy, row.names=FALSE)
write.csv(dataFrameDark, exportPathDark, row.names=FALSE)
write.csv(dataFrameFre, exportPathFre, row.names=FALSE)
write.csv(dataFramePic, exportPathPic, row.names=FALSE)
write.csv(dataFrameTurbo, exportPathTurbo, row.names=FALSE)