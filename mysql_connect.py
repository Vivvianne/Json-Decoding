# Import pymysql module
import pymysql
​
# Connect to the database
connection = pymysql.connect(host='localhost',
                             user='root',
                             password='password',
                             db='test',
                             charset='utf8mb4',
                             cursorclass=pymysql.cursors.DictCursor)
