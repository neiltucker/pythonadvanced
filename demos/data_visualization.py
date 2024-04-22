# This script can be used to test visualization features in Python
# pip install --upgrade pandas, pandas_datareader, scipy, matplotlib, pyodbc, pycountry, azure
# workfolder = 'c:\\tmp'

import os, numpy as np, pandas as pd, pandas_datareader as dr, datetime
import matplotlib.pyplot as plt
# dir(pd)
# help(pd)

# Test Plot for Sales Figures
years = [2011,2012,2013,2014,2015,2016,2017,2018,2019,2020]
sales = [15000,18000,17000,17500,42000,32000,39000,89000,121000,289000]
plt.bar(years,sales)
plt.show()

# Configure Modules and Variables
fig = plt.figure()
now = datetime.datetime.now()
begindate = now - datetime.timedelta(days=730)
workfolder = 'c:\\tmp'
os.chdir(workfolder)
os.getcwd()
stock1 = 'GM' 
stock2 = 'TSLA' 
stock3 = 'AMZN' 
datestr = datetime.datetime.today().strftime("%Y%m%d%H%M")

# Download stock data for the last two year
stockprice1 = dr.DataReader(stock1,"yahoo",begindate,now)   
stockprice2 = dr.DataReader(stock2,"yahoo",begindate,now)  
stockprice3 = dr.DataReader(stock3,"yahoo",begindate,now)    

# Test datasets
stockprice1
stockprice1.columns
stockprice1.head()
stockprice1.head(10)
stockprice1.shape
stockprice1.size
stockprice1.describe
stockprice1.describe()
stockprice1.describe(include='all')
stockprice1.isnull().sum()

# Export data to CSV files
file1 = datestr+'_'+stock1
file2 = datestr+'_'+stock2
file3 = datestr+'_'+stock3
stockprice1.to_csv(file1+'.csv',encoding='utf-8')
stockprice2.to_csv(file2+'.csv',encoding='utf-8')
stockprice3.to_csv(file3+'.csv',encoding='utf-8')

# Create lists to be used by Matplotlib
x1 = pd.read_csv(file1+'.csv',sep=',').Date  
x1 = [datetime.datetime.strptime(dates,'%Y-%m-%d').date() for dates in x1]
x2 = pd.read_csv(file2+'.csv',sep=',').Date 
x2 = [datetime.datetime.strptime(dates,'%Y-%m-%d').date() for dates in x2]
x3 = pd.read_csv(file3+'.csv',sep=',').Date
x3 = [datetime.datetime.strptime(dates,'%Y-%m-%d').date() for dates in x3]
y1 = pd.read_csv(file1+'.csv',sep=',').Close
y2 = pd.read_csv(file2+'.csv',sep=',').Close
y3 = pd.read_csv(file3+'.csv',sep=',').Close

# Create Chart
plt.title('Stock Prices for Chosen Companies')
plt.xlabel('Dates')
plt.ylabel('Stock Price')
plt.plot(x1,y1,label=stock1)
plt.plot(x2,y2,label=stock2)
plt.plot(x3,y3,label=stock3)
plt.grid()
plt.legend()

# Save and Display Chart
fig.savefig(datestr+'_'+stock1+'_'+stock2+'_'+stock3+'.pdf')
plt.show()

### Load and Clean data
### orderdata.csv file is included in the repository
### pip install lxml or os.system('pip install lxml')
### import lxml

import lxml, pyodbc, numpy as np, pandas as pd, matplotlib.pyplot as plt

list1 = [1,2,3,4,5,6,7,8,9,10]
array1 = np.array(list1)

dir(list1)
dir(array1)

len(dir(list1))
len(dir(array1))

===   
dir(pd)
orders = pd.read_csv('orderdata.csv')
orders
orders.head(20)
orders.dtypes
dir(orders)
len(dir(orders))
pd.set_option('display.max_rows', 100)

# Add new column
orders["Total"] = orders["Quantity"] * orders["Price"] + orders["Freight"]
orders.head(10)

# Modify existing column
orders["Freight"] = round(orders["Freight"] / 2)
orders.head(10)
orders["Total"] = orders["Quantity"] * orders["Price"] + orders["Freight"]
orders.head(10)

# Remove column
orders = orders.drop(columns=['OrderDate'])
orders.head(10)

# Sort by column
orders = orders.sort_values(by=['Total'], ascending=False)
orders

# Reorder columns
orders = orders.iloc[:,[0,1,2,3,4,5,7,6]]
orders

# Rename column
orders = orders.rename(columns={"ManagerID":"EmployeeID"})
orders

# Remove rows
orders = orders.drop(range(5000,10000))
orders

### Save results
orders.to_csv('orderdata_clean.csv')
orders.to_xml('orderdata_clean.xml')
orders.to_html('orderdata_clean.html')


=== 
import matplotlib.pyplot as plt

# Test Plot for Sales Figures
x = [2011,2012,2013,2014,2015,2016,2017,2018,2019,2020]
y = [15000,18000,17000,17500,42000,32000,39000,89000,121000,289000]
plt.title("Yearly Sales")
plt.xlabel('Years')
plt.ylabel('Sales')
plt.plot(x,y)
plt.show()
plt.bar(x,y)
plt.show()

===   
import pyodbc, pandas as pd

conn_string = "Driver={SQL Server}; Server=DESKTOP-QNHJ5Q7\SQLEXPRESS; Trusted_Connection=yes;"
connsrv = pyodbc.connect(conn_string)
connsrv.autocommit = True

cursorsrv = connsrv.cursor()
sql = "CREATE DATABASE db11"
cursorsrv.execute(sql)
cursorsrv.close()
connsrv.commit()
connsrv.close()


conndb_string = "Driver={SQL Server}; Server=DESKTOP-QNHJ5Q7\SQLEXPRESS; Trusted_Connection=yes; Database=db2;"
conndb = pyodbc.connect(conndb_string)

cursordb = conndb.cursor()
cursordb.execute("SELECT * FROM dbo.customers")
query = cursordb.fetchall()
type(query)
query

cursordb.close()
conndb.close()

======
======

### READ_SQL_QUERY (PARAMETERS):
import pyodbc, pandas as pd
connection = pyodbc.connect('Driver={SQL Server};' 
                      'Server=DESKTOP-QNHJ5Q7\SQLEXPRESS;'
                      'Database=db1;'
                      'Trusted_Connection=yes;')

id = "BP47"
select = "SELECT * FROM customers WHERE CustomerID = ?"
df = pd.read_sql_query(select, connection, params = [id])


===  

### INSERT DATA INTO DATABASE TABLE

customer_data = pd.read_csv('sample_customer.csv')
print(customer_data)
orders_data = pd.read_csv('sample_orders.csv')

# Connect to MySQL connector.
mydb = mysql.connector.connect(
    host="localhost",
    user="root",
    password="password",
    database="mypythonPRJ")

mycursor = mydb.cursor()

for row in customer_data.itertuples():
    print( (row.CustomerID, row.FirstName, row.LastName, row.Phone, row.City, row.State, row.CustomerName, row.emails))
    mycursor.execute("INSERT INTO sample_customer (CustomerID, FirstName, LastName, Phone, City, State, CustomerName, emails) VALUES (%s,%s,%s,%s,%s,%s,%s,%s)", 
                    (row.CustomerID, row.FirstName, row.LastName, row.Phone, row.City, row.State, row.CustomerName, row.emails))

mydb.commit()
mydb.close()




