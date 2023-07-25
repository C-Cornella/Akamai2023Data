import psycopg2     #SQL commands
import datetime     #datatime shenanigans
import csv          #csv wrangling
import pandas as pd #dataframe stuff
import argparse     #argument parsing
import os           #File cleanup

HOST = "128.171.168.82"
DATABASE = "uh88weather"
PASSWORD = "grf22newdb"
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

# ---- SETUP FOR EXPORT ----

#Create the export paths for the .csv file. 
exportDF=  exportPath+ "engineeringData.csv"
            
# ---- RUN SQL QUERIES AND EXPORT RESULTS ----

with psycopg2.connect(host=HOST, dbname=DATABASE, user=USER, password=PASSWORD, connect_timeout=CONNECT_TIMEOUT) as conn:
    with conn.cursor() as cur:
        try:
            # -- adamcomproom ---
            acr_query ="SELECT time, rack1, rack2, rack3 FROM adamcomproom WHERE time BETWEEN " + str(timeStart) + " AND " + str(timeEnd) + "LIMIT 5"
            cur.execute(acr_query)
            acr_rows = cur.fetchall()
            # -- adamtube ------ 
            at_query ="SELECT time, mirroreast, mirrorwest, uppertubesouth, tubesnifseast FROM adamtube WHERE time BETWEEN " + str(timeStart) + " AND " + str(timeEnd)+ "LIMIT 5"
            cur.execute(at_query)
            at_rows = cur.fetchall()
            # -- boltwood ------
            bw_query ="SELECT time, temp, windspeed, skytempdiff FROM boltwood WHERE time BETWEEN " + str(timeStart) + " AND " + str(timeEnd)+ "LIMIT 5"
            cur.execute(bw_query)
            bw_rows = cur.fetchall()
            # -- cfht --------
            cfht_query ="SELECT time, temp, pressure, windavgspd, windavgdir, windmaxspd, windmaxdir FROM cfht WHERE time BETWEEN " + str(timeStart) + " AND " + str(timeEnd)+ "LIMIT 5"
            cur.execute(cfht_query)
            cfht_rows = cur.fetchall()
            # -- tcs -------
            tcs_query ="SELECT time, domeaz, ha, dec, slit FROM tcs WHERE time BETWEEN " + str(timeStart) + " AND " + str(timeEnd)+ "LIMIT 5"
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
        
      
        # ---- ROWS TO DATAFRAMES ----
      
        #adamcomproom
        columnslist = ("time" ,"rack1", "rack2", "rack3")
        acr_df=pd.DataFrame(acr_rows, columns=columnslist)
        
        #adamtube
        columnslist = ("time", "mirroreast", "mirrorwest", "uppertubesouth", "tubesnifseast")
        at_df=pd.DataFrame(at_rows, columns=columnslist)     
        
        #boltwood
        columnslist = ("time", "temp", "windspeed", "skytempdiff")
        bw_df=pd.DataFrame(bw_rows, columns=columnslist)
        
        #cfht    
        columnslist = ("time", "temp", "pressure", "windavgspd", "windavgdir", "windmaxspd", "windmaxdir")
        cfht_df=pd.DataFrame(cfht_rows, columns=columnslist)
        
        #tcs
        columnslist = ("time", "domeaz", "ha", "dec", "slit")
        tcs_df=pd.DataFrame(tcs_rows, columns=columnslist)
            
        #ups0
        columnslist = ("time", "ambienttemp")
        ups_df=pd.DataFrame(ups_rows, columns=columnslist)
            
        print("All data retrived.")
        print("Beginning data processing.")
        
        
        
        # ---- COMBINE DATAFRAMES ----
        
        dataFrame=    acr_df.merge(at_df, on="time", how="outer")
        #dataFrame= dataFrame.merge(bw_df, on="time", how="outer")
        #dataFrame= dataFrame.merge(cfht_df, on="time", how="outer")
        #dataFrame= dataFrame.merge(tcs_df, on="time", how="outer")
        #dataFrame= dataFrame.merge(ups_df, on="time", how="outer")
        
        
        
        # ---- EXPORT DATAFRAME ----
        dataFrame.to_csv(exportDF, header=True, index=False)
        
        print("All data parsed, process complete.")
        
    except:
        print("Error exporting data")
        raise
      
        
      
