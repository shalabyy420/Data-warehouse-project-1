/*
  Stored procedure to do every day load of files you get
  ------------------------------------------------------
  this stored procedure saves so much time and effort you just give it the table name and its path and it will do the loading

  NOTE:
  this SP is UNIVERSAL so you can choose it for any files you just put file path and table name.
*/


CREATE OR ALTER PROCEDURE bronze.load_csv
    @table_name NVARCHAR(128),
    @file_path NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql NVARCHAR(MAX);

    -- 1. Truncate the target table
    SET @sql = N'TRUNCATE TABLE bronze.' + QUOTENAME(@table_name) + N';';

    EXEC sp_executesql @sql;

    -- 2. Bulk insert the CSV data
    SET @sql = N'
        BULK INSERT bronze.' + QUOTENAME(@table_name) + N'
        FROM ''' + REPLACE(@file_path, '''', '''''') + N'''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''0x0a'',
            TABLOCK
        );';

    EXEC sp_executesql @sql;
END;
GO

EXEC bronze.load_csv
    @table_name = 'crm_cust_info',
    @file_path = 'E:\datawarehouse  project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv';
GO

select * from bronze.crm_cust_info
