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

(exportPath <-paste(exportPath, sensorName,"-", sensorLocation, ".csv", sep=""))
