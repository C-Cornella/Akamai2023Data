import psycopg2
import datetime
import csv
#import argparse

HOST = "128.171.168.82"
DATABASE = "uh88weather"
PASSWORD = "grf22newdb"
USER = "grafana"
CONNECT_TIMEOUT = 5

# ---- PROCESS ARGUMENTS -----
#take in export location as argument?
#https://stackoverflow.com/questions/22846858/python-pass-arguments-to-a-script

#parser = argparse.ArgumentParser()
#parser.add_argument("-e", "--export", type=int)

#args = parser.parse_args()
#col = args.position
#sample = args.sample

# SELECT (time, ...) FROM table_name WHERE time > unix_time1 AND time < unix_time2

#If we prompt the user for the time period they want the data, 
#then we need to convert the argument passed in to unix time
#
timeStart= datetime.datetime(2022, 8, 17, 23, 59, 55 ).timestamp()
timeEnd= datetime.datetime(2023, 4, 17).timestamp()
exportPath="csvs/"

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
            ups_query ="SELECT time, ambienttemp FROM ups0 WHERE time BETWEEN " + str(timeStart) + " AND " + str(timeEnd) + " LIMIT 5"
            cur.execute(ups_query)
            ups_rows = cur.fetchall()
            
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
