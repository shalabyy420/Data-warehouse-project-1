/*
	---------------------------------------------------
	Data base creation and its schemas
	---------------------------------------------------
	script purpose:
		deleting database warehouse if exists and cutting all connections of it if they are found then creating it
		and its schemas of bronze, silver and gold

	Warning:
		Running the code will destroy data connections and also drop the data base so take care and have backups for that 
		data to prevent its loss

*/


use master ;

go

if exists (select 1 from sys.databases where name = 'data_warehouse')
	begin
		alter database data_warehouse set single_user with rollback immediate;
		drop database data_warehouse;
	end;

go
-- Creating DWH
create database data_warehouse;
go

use data_warehouse;
go

-- Schemas creation
create schema bronze
go
create schema silver
go 
create schema gold
