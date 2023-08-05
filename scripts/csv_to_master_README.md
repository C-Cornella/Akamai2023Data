# csv_to_master.R

## Description: 

Developed for IfA, Summer 2023, in conjunction with Akamai Internship, by C. Cornella.

This script compiles csv files for AIRFLOW sensors as processed by `sensor_to_csv1.R`, and csv files for engineering data as processed by `RetrivalScript1.6.py`. The resulting csv includes a header with the import path and export path, and date exported. 


## How to Run


To execute, run `Rscript csv_to_master.R ImportPath ExportPath` from your command line. 

`ImportPath` is the location to begin looking for the .txt files - include a / at the end of this path

`ExportPath` is the location to export the .csv files - include a `/` at the end of this path. 


## Usual Errors

Missing Packages: The R libraries needed for this script may require the installation of additional packages. A list of all packages required is provided below.
tidyverse (for dplyr, readr, tidyr)
stringr (for stringr)
knitr (for knitr)
lubridate (for lubridate)

Path errors: The `/` must be included in the export path, and the import path must direct to the folder containing all the days for that sensor. 

Import errors: The script expects the data in the form of the csv files produced by `sensor_to_csv1.R` and `RetrivalScript1.6.py`. Any other script is not compatible. 

