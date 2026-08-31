/*
	Loading raw data from the source
	--------------------------------------
	1) Using truncate and bulk insert to get data from the files on my computer
	2) Making stored procedure to save time and effort

	NOTES :
	this SP is specific for those files only
*/
use data_warehouse
go
create or alter procedure bronze.load_bronzalayer as	
begin
	declare @start_time datetime , @end_time datetime ;
	print '=================================';
	Print 'loading bronze layer';
	print '=================================';
	print '---------------------------------';
	print 'loading CRM tables';
	print '---------------------------------';
	
	set @start_time = GETDATE();
	Truncate table bronze.crm_cust_info;


	BULK INSERT bronze.crm_cust_info
	from 'E:\datawarehouse  project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
	with (
		FIRSTROW = 2,
		TABLOCK,
		FIELDTERMINATOR = ','
	);
	

	Truncate table bronze.crm_prd_info;

	

	BULK INSERT bronze.crm_prd_info
	from 'E:\datawarehouse  project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
	with (
		FIRSTROW = 2,
		TABLOCK,
		FIELDTERMINATOR = ','
	);
	


	Truncate table bronze.crm_sales_details;

	

	BULK INSERT bronze.crm_sales_details
	from 'E:\datawarehouse  project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
	with (
		FIRSTROW = 2,
		TABLOCK,
		FIELDTERMINATOR = ','
	);
	print '=================================';
	print 'loading CRM tables is done';
	print '=================================';

	print '---------------------------------';
	print 'loading ERP tables';
	print '---------------------------------';

	print '=================================';
	print ' truncating tables';
	print '=================================';

	Truncate table [bronze].[erp_CUST_AZ12];

	

	BULK INSERT [bronze].[erp_CUST_AZ12]
	from 'E:\datawarehouse  project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
	with (
		FIRSTROW = 2,
		TABLOCK,
		FIELDTERMINATOR = ','
	);
	


	Truncate table [bronze].[erp_LOC_A101];

	

	BULK INSERT [bronze].[erp_LOC_A101]
	from 'E:\datawarehouse  project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
	with (
		FIRSTROW = 2,
		TABLOCK,
		FIELDTERMINATOR = ','
	);
	

	Truncate table bronze.erp_PX_CAT_G1V2;

	

	BULK INSERT bronze.erp_PX_CAT_G1V2
	from 'E:\datawarehouse  project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
	with (
		FIRSTROW = 2,
		TABLOCK,
		FIELDTERMINATOR = ','
	);
	
	print '=================================';
	print 'loading ERP tables is done';
	print '=================================';
	
	set @end_time = GETDATE();
	print '>>> Loading duration:'+CAST(datediff(second , @start_time , @end_time) as nvarchar)+'seconds';
END

exec bronze.load_bronzalayer
