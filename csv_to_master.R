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
if (length(args)<2) {
  stop("Missing Argument: Required ImportPath, ExportPath", call.=FALSE)
} else if (length(args)==2) {
  importPath=args[1]
  exportPath=args[2]
} else {
  stop("Excess Arguments: Required ImportPath, ExportPath", call.=FALSE)
}

# -------- DATA IMPORTING --------

# ---- Sensors
path=paste(importPath, "cyclone-hx9-telescope_spider_south.csv", sep="")
cyc_df <- read_csv(path, skip=5)
path=paste(importPath, "darkthunder-dome_slit_bottom_horizontal.csv", sep="")
dark_df <- read_csv(path, skip=5)
path=paste(importPath, "freflow-mez_obsroom_horizontal.csv", sep="")
fre_df <- read_csv(path, skip=5)
path=paste(importPath, "picasso-mez_obsroom_vertical.csv", sep="")
pic_df <- read_csv(path, skip=5)
path=paste(importPath, "turbopanda-dome_slit_top_vertical.csv", sep="")
turbo_df <- read_csv(path, skip=5)


# ---- Engineering
# -- adamcomproom table -- 
#contains time, rack1, rack2, rack3
path=paste(importPath, "acrOutput.csv", sep="")
acr_df <- read_csv(path)
# -- adamtube table -- 
#contains time, mirroreast, mirrorwest, uppertubesouth, tubesnifseast
path=paste(importPath, "atOutput.csv", sep="")
at_df <- read_csv(path)
# -- boltwood table -- 
# contains time, temp, windspeed, skytempdiff
path=paste(importPath, "bwOutput.csv", sep="")
bw_df <- read_csv(path)
# -- cfht table -- 
# contains time, temp, pressure, windavgspd, windavgdir, windmaxspd, windmaxdir
path=paste(importPath, "cfhtOutput.csv", sep="")
cfht_df <- read_csv(path)
# -- tcs table -- 
# contains time, domeaz, ha, dec, slit
path=paste(importPath, "tcsOutput.csv", sep="")
tcs_df <- read_csv(path)
# -- ups0 table -- 
# contains time, ambienttemp
path=paste(importPath, "upsOutput.csv", sep="")
ups_df <- read_csv(path)


# -------- DATA TIDYING --------

#Add all the Sensors into one dataframe.
sensorMaster <- rbind(cyc_df, dark_df, fre_df, pic_df, turbo_df)

# unix time to posix time object: 
#Save the time as a Date time (posix) object so we can round it safely later. 
acr_df <- acr_df %>% mutate(dateTime= as_datetime(time)) %>% arrange(dateTime) #every ten seconds 00
at_df  <- at_df %>% mutate(dateTime= as_datetime(time))%>% arrange(dateTime) #every ten seconds 00
bw_df  <- bw_df %>% mutate(dateTime= as_datetime(time))%>% arrange(dateTime) #every minute 00
cfht_df<- cfht_df %>% mutate(dateTime= as_datetime(time))%>% arrange(dateTime) #every five seconds starting at 03
tcs_df <- tcs_df %>% mutate(dateTime= as_datetime(time))%>% arrange(dateTime) #every 16 seconds. (why. just why.)
ups_df <- ups_df %>% mutate(dateTime= as_datetime(time))%>% arrange(dateTime) #every five seconds starting at 01

# round to 5 min intervals
#rounded_date rounds all times to the nearest time interval, in our case, 5 minutes. 
acr_df$dateTime <- round_date(acr_df$dateTime, unit="5 mins")
at_df$dateTime <- round_date(at_df$dateTime, unit="5 mins")
bw_df$dateTime <- round_date(bw_df$dateTime, unit="5 mins")
cfht_df$dateTime <- round_date(cfht_df$dateTime, unit="5 mins")
tcs_df$dateTime <- round_date(tcs_df$dateTime, unit="5 mins")
ups_df$dateTime <- round_date(ups_df$dateTime, unit="5 mins")

# average all the values for the given time
#By grouping by the dateTime, anything we do after that will do it just for each group. 
#We have to hardcode each column of the engineering data for each table so we actually get an average of all of the columns.
acr5_df <- acr_df %>% group_by(dateTime) %>% 
  summarize(rack1=mean(rack1), 
            rack2=mean(rack2), 
            rack3=mean(rack3))
at5_df <- at_df %>% group_by(dateTime) %>% 
  summarize(mirroreast=mean(mirroreast), 
            mirrorwest=mean(mirrorwest), 
            uppertubesouth=mean(uppertubesouth), 
            tubesnifseast=mean(tubesnifseast))
bw5_df <- bw_df %>% group_by(dateTime) %>% 
  summarize(bw_temp=mean(bw_temp), 
            windspeed=mean(windspeed), 
            skytempdiff=mean(skytempdiff))
cfht5_df <- cfht_df %>% group_by(dateTime) %>% 
  summarize(cfht_temp=mean(cfht_temp), 
            pressure=mean(pressure), 
            windavgspd=mean(windavgspd), 
            windavgdir=mean(windavgdir), 
            windmaxspd=mean(windmaxspd), 
            windmaxdir=mean(windmaxdir))
tcs5_df <- tcs_df %>% group_by(dateTime) %>% 
  summarize(domeaz=mean(domeaz), 
            ha=mean(ha), 
            dec=mean(dec), 
            slit=mean(slit))
ups5_df <- ups_df %>% group_by(dateTime) %>% 
  summarize(ambienttemp=mean(ambienttemp) )

# combine all dataframes into one
#Merging the dataframe in an outer style join
engineeringMaster <- merge(acr5_df, at5_df, by="dateTime", all=TRUE)
engineeringMaster <- merge(engineeringMaster, bw5_df, by="dateTime", all=TRUE)
engineeringMaster <- merge(engineeringMaster, cfht5_df, by="dateTime", all=TRUE)
engineeringMaster <- merge(engineeringMaster, tcs5_df, by="dateTime", all=TRUE)
engineeringMaster <- merge(engineeringMaster, ups5_df, by="dateTime", all=TRUE)

#
engineeringSensorMaster <- engineeringMaster %>% mutate(slit=round(slit)) %>%
                                  merge(sensorMaster, by="dateTime", all=TRUE) %>% 
                                  drop_na(sensor)

# -------- DATA EXPORTING --------

#Add the export path to the beginning of the specific .csv name
# -- Additional argument: sep: added to remove the usually added space
exportfPath <-paste(exportPath, "engineeringSensorMaster.csv", sep="")

#Add information such as given import and export path
writeLines(c(paste("Import path:", importPath), 
             paste("Export path:", exportPath), 
             paste("Day Exported: ", date() ) ), exportfPath)

#Export dataframe as a .csv
write.table(dataFrame, exportfPath, row.names=FALSE, col.names=TRUE, append=TRUE, sep=",")
