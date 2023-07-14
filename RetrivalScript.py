import psycopg2
import argparse

HOST = "128.171.168.82"
DATABASE = "uh88weather"
PASSWORD = "jH9tqgZBvp"
USER = "weather_read"
CONNECT_TIMEOUT = 5

#take in export location as argument?

# SELECT (time, ...) FROM table_name WHERE time > unix_time1 AND time < unix_time2

with open("output_file.csv", "w") as f1, psycopg2.connect(host=HOST, dbname=DATABASE, user=USER, password=PASSWORD, connect_timeout=CONNECT_TIMEOUT) as conn:
    with conn.cursor() as cur:
        try:
            query = "SELECT (time, domeaz, ha, dec, slit) FROM tcs WHERE time > (SELECT EXTRACT(epoch FROM now()) - (60 * 60 * 25))"
            cur.execute(query)
            rows = cur.fetchall()
        except:
            print("Error handling not yet implemented")
            raise

    try:
        for row in rows:
            outLine = "{:d}, {:.2f}, {:.6f}, {:.6f}, {:d}\n".format(row[0][0], row[0][1], row[0][2], row[0][3], row[0][4])
            f1.write(outLine)

    except:
        print("Error handling not yet implemented")
        raise
