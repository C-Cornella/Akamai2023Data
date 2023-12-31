import psycopg2     #SQL commands
import datetime     #datetime shenanigans
import csv          #csv wrangling
import pandas as pd #dataframe stuff
import argparse     #argument parsing

HOST = "128.171.168.82"
DATABASE = "uh88weather"
PASSWORD = "*****" #password redacted for security
USER = "grafana"
CONNECT_TIMEOUT = 5

# ---- PROCESS ARGUMENTS -----
#take in start time, end time, and export location as argument
#Assuming format of type yyyy-mm-dd-hhmm
parser = argparse.ArgumentParser()
parser.add_argument("-st", "--startTime")
parser.add_argument("-et", "--endTime")
parser.add_argument("-ep", "--exportPath")

args = parser.parse_args()
startArg = args.startTime
endArg = args.endTime
exportPath=args.exportPath

#We need to convert the argument passed in to unix time
#Assuming format of type yyyy-mm-dd-hhmm, the slicing excludes the last argument.
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


# ---- SETUP FOR EXPORT ----

#Create the export paths for each individual CSV file. 
exportACR= exportPath+ "acrOutput.csv"
exportAT=  exportPath+ "atOutput.csv"
exportBW=  exportPath+ "bwOutput.csv"
exportCFHT=exportPath+ "cfhtOutput.csv"
exportTCS= exportPath+ "tcsOutput.csv"
exportUPS= exportPath+ "upsOutput.csv"

            
# ---- RUN SQL QUERIES AND EXPORT RESULTS ----

with psycopg2.connect(host=HOST, dbname=DATABASE, user=USER, password=PASSWORD, connect_timeout=CONNECT_TIMEOUT) as conn:
    with conn.cursor() as cur:
        try:
            # -- adamcomproom ---
            acr_query ="SELECT time, rack1, rack2, rack3 FROM adamcomproom WHERE time BETWEEN " + str(timeStart) + " AND " + str(timeEnd)
            cur.execute(acr_query)
            acr_rows = cur.fetchall()
            # -- adamtube ------ 
            at_query ="SELECT time, mirroreast, mirrorwest, uppertubesouth, tubesnifseast FROM adamtube WHERE time BETWEEN " + str(timeStart) + " AND " + str(timeEnd)
            cur.execute(at_query)
            at_rows = cur.fetchall()
            # -- boltwood ------
            bw_query ="SELECT time, temp, windspeed, skytempdiff FROM boltwood WHERE time BETWEEN " + str(timeStart) + " AND " + str(timeEnd)
            cur.execute(bw_query)
            bw_rows = cur.fetchall()
            # -- cfht --------
            cfht_query ="SELECT time, temp, pressure, windavgspd, windavgdir, windmaxspd, windmaxdir FROM cfht WHERE time BETWEEN " + str(timeStart) + " AND " + str(timeEnd)
            cur.execute(cfht_query)
            cfht_rows = cur.fetchall()
            # -- tcs -------
            tcs_query ="SELECT time, domeaz, ha, dec, slit FROM tcs WHERE time BETWEEN " + str(timeStart) + " AND " + str(timeEnd)
            cur.execute(tcs_query)
            tcs_rows = cur.fetchall()
            # -- ups0 -------
            ups_query ="SELECT time, ambienttemp FROM ups0 WHERE time BETWEEN " + str(timeStart) + " AND " + str(timeEnd)
            cur.execute(ups_query)
            ups_rows = cur.fetchall()
            
            print("Data read from database")
        except:
            print("Error reading from database")
            raise

    try:
        
        acr_out =csv.writer(open(exportACR, "w"))
        acr_out.writerow(['time','rack1', 'rack2', 'rack3'])
        for row in acr_rows: #adamcomproom
            #time, rack1, rack2, rack3
            acr_out.writerow(row)
        
        at_out = csv.writer(open(exportAT, "w"))     
        at_out.writerow(['time', 'mirroreast', 'mirrorwest', 'uppertubesouth', 'tubesnifseast'])
        for row in at_rows: #adamtube
            #time, mirroreast, mirrorwest, uppertubesouth, tubesnifseast
            at_out.writerow(row)
            
        bw_out = csv.writer(open(exportBW, "w"))   
        bw_out.writerow(['time', 'bw_temp', 'windspeed', 'skytempdiff'])
        for row in bw_rows: #boltwood
            #time, temp, windspeed, skytempdiff
            bw_out.writerow(row)
        
        cfht_out = csv.writer(open(exportCFHT, "w"))
        cfht_out.writerow(['time', 'cfht_temp', 'pressure', 'windavgspd', 'windavgdir', 'windmaxspd', 'windmaxdir'])
        for row in cfht_rows: #cfht
            #time, temp, pressure, windavgspd, windavgdir, windmaxspd, windmaxdir
            cfht_out.writerow(row)
        
        tcs_out = csv.writer(open(exportTCS, "w"))
        tcs_out.writerow(['time', 'domeaz', 'ha', 'dec', 'slit'])    
        for row in tcs_rows: #tcs
            #time, domeaz, ha, dec, slit
            tcs_out.writerow(row)
        
        ups_out = csv.writer(open(exportUPS, "w"))
        ups_out.writerow(['time', 'ambienttemp'])    
        for row in ups_rows: #ups0
            #time, ambienttemp
            ups_out.writerow(row)
            
            
        print("All data exported")
    except:
        print("Error exporting data")
        raise
