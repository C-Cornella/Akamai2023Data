# mkws_to_csv.R

## Description: 

Developed for IfA, Summer 2023, in conjunction with Akamai Internship, by C. Cornella.

This script scrapes the Maunakea Weather Station Data from `http://mkwc.ifa.hawaii.edu/archive/wx/cfht/` for 2022 and 2023. The format is assumed to be as found in `WeatherStationDataFormat.txt`. 


## How to Run

To execute, run `Rscript mkws_to_csv.R ExportPath` from your command line. 

`ExportPath` is the location to export the .csv file - include a `/` at the end of this path. 

## Usual Errors

Missing Packages: The R libraries needed for this script may require the installation of additional packages. A list of all packages required is provided below.
tidyverse (for dplyr, readr, tidyr)
stringr (for stringr)
knitr (for knitr)
lubridate (for lubridate)

Path errors: The `/` must be included in the export path. 

## Additional Years

The script can be very easily modified to include addtional years. Commented code is included in the script to indicate where and what should be added, under `#ADDITIONAL YEARS TEMPLATE`. Copy this code directly beneath the comment, remove the `#` symbol at the start of the line, and change all `20XX` to the year of your choice. Should you wish to include more than one year, copy and change everything for as many years as you'd like to include. 
