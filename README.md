# SensorDataframing1.R

## Description: 

Developed for IfA, Summer 2023, in conjunction with Akamai Internship, by C. Cornella.

This script compiles the reduced data from an AIRFLOW sensor into a single .csv file. 
The data is expected to be reduced by `npha_Neo3b.pro` reduction script. 


## How to Run


To execute, run `Rscript sensorDataframing1.R ImportPath ExportPath SensorName SensorLocation` from your command line. 

`ImportPath` is the location to begin looking for the .txt files

`ExportPath` is the location to export the .csv files - include a `/` at the end of this path. 

`SensorName` is required to export the name of the sensor to the .csv file. 

`Location` is the location of the sensor, also exported to the .csv file. 


## Usual Errors

Path errors: The `/` must be included in the export path, and the import path must direct to the folder containing all the days for that sensor. 

Import errors: The script expects the data in the form of .txt files, as produced by `npha_Neo3b.pro`. The difference between `npha_Neo3.pro` and `npha_Neo3b.pro` is the addition of the exporting of `month` and `day` to the latter. `npha_Neo3b.pro` was edited specifically to address the difficulties of `floatDate` parsing by simply adding the information in another format. `floatDate` was included as a precautionary measure. 

