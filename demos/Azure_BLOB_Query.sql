/* Import CSV from BLOB to SQL Server Table */

USE AdventureWorks2019
GO

CREATE EXTERNAL DATA SOURCE DataFiles
    WITH (
        TYPE = BLOB_STORAGE,
        LOCATION = 'https://55xxx.blob.core.windows.net/labfiles'
		);
GO

SELECT * FROM OPENROWSET(
   BULK 'customerdata.csv',
   DATA_SOURCE = 'DataFiles',
   FORMAT = 'CSV',
   FIRSTROW = 2,
   FORMATFILE='customers.fmt',
   FORMATFILE_DATA_SOURCE = 'DataFiles'
   ) AS customerdata;
GO

SELECT * INTO Customers FROM OPENROWSET(
   BULK 'customerdata.csv',
   DATA_SOURCE = 'DataFiles',
   FORMAT = 'CSV',
   FIRSTROW = 2,
   FORMATFILE='customers.fmt',
   FORMATFILE_DATA_SOURCE = 'DataFiles'
   ) AS customerdata;
GO

SELECT * FROM Customers
GO

SELECT * FROM OPENROWSET(
   BULK 'orderdata.csv',
   DATA_SOURCE = 'DataFiles',
   FORMAT = 'CSV',
   FIRSTROW = 2,
   FORMATFILE='orderdata.fmt',
   FORMATFILE_DATA_SOURCE = 'DataFiles'
   ) AS orderdatadata;
GO

SELECT * INTO Orders FROM OPENROWSET(
   BULK 'orderdata.csv',
   DATA_SOURCE = 'DataFiles',
   FORMAT = 'CSV',
   FIRSTROW = 2,
   FORMATFILE='orderdata.fmt',
   FORMATFILE_DATA_SOURCE = 'DataFiles'
   ) AS orderdatadata;
GO

SELECT * FROM Orders
GO




