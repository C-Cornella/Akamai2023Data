# -------- SETUP --------

#include libraries
knitr::opts_chunk$set(echo = TRUE)

library(dplyr)      #General Data wrangling
library(readr)      #File reading and writing
library(knitr)      #Markdown file exporting
library(lubridate)  #Date-Time Wrangling

#Process arguments
args = commandArgs(trailingOnly=TRUE)
#If no argument is supplied
if (length(args)<1) {
  stop("Missing Argument: Required ExportPath", call.=FALSE)
} else if (length(args)==1) {
  exportPath=args[1]
} else {
  stop("Excess Arguments: Required ExportPath", call.=FALSE)
}

# -------- DATA IMPORTING --------
# Data source: 
# Year 2022: http://mkwc.ifa.hawaii.edu/archive/wx/cfht/cfht-wx.2022.dat
# Year 2023: http://mkwc.ifa.hawaii.edu/archive/wx/cfht/cfht-wx.2023.dat
# ADDITIONAL YEARS TEMPLATE
# Year 20XX: http://mkwc.ifa.hawaii.edu/archive/wx/cfht/cfht-wx.20XX.dat
# Data Format can be found in the included (WeatherStationDataFormat.txt) file

source2022 = "http://mkwc.ifa.hawaii.edu/archive/wx/cfht/cfht-wx.2022.dat"
source2023 = "http://mkwc.ifa.hawaii.edu/archive/wx/cfht/cfht-wx.2023.dat"
#ADDITIONAL YEARS TEMPLATE
#source20XX = "http://mkwc.ifa.hawaii.edu/archive/wx/cfht/cfht-wx.20XX.dat"

#It may be possible to create a list of sources, and read all the files into the same dataset
#from the beginning. 
#At this time I don't think that will improve functionality by a significant enough margin to 
#warrant attempting it. 

#Current approach is read each file into a seperate dataframe and combine later. As the file is read in column names are assigned. 
columnNames=c("Year", "Month", "Day", "Hour", "Minute", "WindSpd", "WindDir", "Temp", "RHumid", "Pressure", "NA" )
data2022 <- read.delim(source2022, 
                        sep=" ", 
                        header = FALSE, 
                        col.names = columnNames)
data2023 <- read.delim(source2023, 
                        sep=" ", 
                        header = FALSE, 
                        col.names = columnNames)
#ADDITIONAL YEARS TEMPLATE
# data20XX <- read.delim(source20XX, 
#                        sep=" ", 
#                        header = FALSE, 
#                        col.names = columnNames)

#Combine the rows from the datasets into a master dataframe
dataframe <- bind_rows(data2022, data2023)
#ADDITIONAL YEARS TEMPLATE
#dataframe <- bind_rows(dataframe, data20XX)

# -------- DATA TIDYING --------


#Turn the days and such into Date-time objects with lubridate, drop the other columns, 
#keep as a separate dataframe. 
# create a new column with the concatenated values from the relevant columns
# mutate into a second new column as a dateTime object in Hawaii TimeZone
# Select only the relevant columns, discard the unecessary contributing columns. 
dataframeDT <- dataframe %>% mutate(dateTimeStr = paste(Year, Month, Day, Hour, Minute)) %>% 
    mutate(DateTime = ymd_hm(dateTimeStr, tz="HST")) %>% 
    select(DateTime, WindSpd, WindDir, Temp, RHumid, Pressure, NA.) 

#Change the time interval to every 5 minutes, not every minute, and average the values. 
dataframeDT$DateTime <- round_date(dataframeDT$DateTime, unit="5 mins")
dataframeDT <- dataframeDT %>% group_by(DateTime) %>% 
  summarize(WindSpd=mean(WindSpd), 
            WindDir=mean(WindDir), 
            Temp=mean(Temp), 
            RHumid=mean(RHumid), 
            Pressure=mean(Pressure),
            NA.=mean(NA.))


# -------- DATA EXPORTING --------

#Add the export path to the beginning of the specific .csv name
# -- Additional argument: sep: added to remove the usually added space
exportPath <-paste(exportPath, "mkws_data.csv", sep="")

#Add information such as given import and export path
writeLines(c(paste("Export path:", exportPath), 
             paste("Day Exported: ", date() ) ), exportPath)

#Export the DateTime dataframe (dataframeDT) as a .csv
write.csv(dataframeDT, exportPath, row.names=FALSE)
