# sql_to_csvs.py

## Description: 

Developed for IfA, Summer 2023, in conjunction with Akamai Internship, by C. Cornella.

This script queries the SQL database `uh88weather` under user `graphona` for data from 6 different tables, listed in more detail below. The data is then exported to a different .csv file for each source table. The specified timeframe is given in the arguments, as is the export path to the csvs.

This script requires python 3 installation. 

adamcomproom table - time, rack1, rack2, rack3
adamtube table - time, mirroreast, mirrorwest, uppertubesouth, tubesnifseast
boltwood table - time, temp, windspeed, skytempdiff
cfht table - time, temp, pressure, windavgspd, windavgdir, windmaxspd, windmaxdir
tcs table - time, domeaz, ha, dec, slit
ups0 table - time, ambienttemp

## How to Run


To execute, run `python3 sql_to_csvs.py ImportPath ExportPath` from your command line. 

`startTime` is the beginning of the timeframe for the data - expected yyyy-mm-dd-hhmm format

`endTime` is the end of the timeframe for the data - yyyy-mm-dd-hhmm

`ExportPath` is the location to export the .csv files - include a `/` at the end of this path. 


## Usual Errors

Missing Packages: The python libraries needed for this script may require the installation of additional packages. Check that you have the packages required for the following: 
psycopg2 (SQL queries)
datetime (datetime shenanigans)
csv (csv wrangling)
pandas (dataframe stuff)
argparse (argument parsing)

Path errors: The `/` must be included in the export path, and the import path must direct to the folder containing all the days for that sensor. 

Argument errors: The format for the startTime and endTime is very strict and must match the pattern (yyyy-mm-dd-hhmm) exactly. If this doesn't match, the time won't be processed as equal, and will not return the correct data.

