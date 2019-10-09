import mysql_connect as mysql  # import module to connect to DB
import pandas as pd
import json  # load json file into dictionary
# Normalize semi-structured JSON data into a flat table
from pandas.io.json import json_normalize
with open('interview.json', 'r') as f:
    distros_dict = json.load(f)
df_interview = json_normalize(
    distros_dict[1], record_path='Report')  # load json to dataframe
# create cursor
cursor = mysql.connection.cursor()
# create column list for insertion
cols = "`,`".join([str(i) for i in df_interview.columns.tolist()])
# Insert DataFrame records row by row
for i, row in df_interview.iterrows():
    sql = "INSERT INTO `src_interview` (`" + cols + \
        "`) VALUES (" + "%s," * (len(row) - 1) + "%s)"
    cursor.execute(sql, tuple(row))
    # commit the inserts
    mysql.connection.commit()