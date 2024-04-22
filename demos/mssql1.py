import pyodbc, pandas as pd

customer_data = pd.read_csv('customerdata.csv')
print(customer_data)
orders_data = pd.read_csv('orderdata.csv')
print(orders_data)

# Local Server Settings:
server = 'DESKTOP-QNHJ5Q7'
database = 'db1'
username = 'sa' 
password = 'Password1'
connection = pyodbc.connect('Driver={SQL Server};' 
                      'Server=DESKTOP-QNHJ5Q7;'
                      'Database=db1;'
                      'Trusted_Connection=yes;')

cursor = connection.cursor()
cursor.execute('SELECT TOP 100 * FROM customers')

for i in cursor:
    print(i)

cursor.close()
connection.close()

# Cloud-based Server Settings:
server = 'tcp:nrtsql1.database.windows.net' 
database = 'db1' 
username = 'sqllogin1'
password = 'Password1' 

connection = pyodbc.connect('DRIVER={SQL Server};SERVER='+server+';DATABASE='+database+';ENCRYPT=yes;UID='+username+';PWD='+ password)

cursor = connection.cursor()
cursor.execute('SELECT TOP 100 * FROM customers')

for i in cursor:
    print(i)

cursor.close()

query = pd.read_sql_query("""SELECT * FROM customers""", connection)
type(query)
query

connection.close()

