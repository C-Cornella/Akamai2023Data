#test for python arguments
import argparse
import datetime

#take in start time, end time, and export location as argument
#https://stackoverflow.com/questions/22846858/python-pass-arguments-to-a-script

parser = argparse.ArgumentParser()
parser.add_argument("-st", "--startTime")
parser.add_argument("-et", "--endTime")
parser.add_argument("-ep", "--exportPath")

args = parser.parse_args()
startArg = args.startTime
endArg = args.endTime
exportPath=args.exportPath

#We prompt the user for the time period they want the data, 
#then we need to convert the argument passed in to unix time
#Assuming format of type yyyy-mm-dd-hhmm (0123-56-78-1011)
year=int(startArg[0:4])
month=int(startArg[5:7])
day=int(startArg[8:10])
hour=int(startArg[11:13])
minute=int(startArg[13:15])
timeStart= datetime.datetime(year, month, day, hour, minute).timestamp()
year=int(endArg[0:4]) 
month=int(endArg[5:7])
day=int(endArg[8:10]) 
hour=int(endArg[11:13])
minute=int(endArg[13:15])
timeEnd= datetime.datetime(year, month, day, hour, minute).timestamp()
