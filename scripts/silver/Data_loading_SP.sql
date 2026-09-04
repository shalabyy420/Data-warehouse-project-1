
create or alter procedure silver.load_silver_layer as
begin
	TRUNCATE table silver.crm_cust_info

	print 'TRUNCATING DONE'
	insert into silver.crm_cust_info
	(
		cst_id,
		cst_key,
		cst_first_name,
		cst_last_name,
		cst_marital_status,
		cst_gndr,
		cst_create_date
	)
	select
	cst_id,
	cst_key,
	TRIM(cst_first_name) as cst_firstname, 
	TRIM (cst_last_name) as cst_lastname,
	case 
		when Upper(trim(cst_marital_status)) = 'M' then 'Married'
		when upper(trim(cst_marital_status)) = 'S' then 'Single'
		else 'n/a'
	end cst_marital_status,
	case 
		when Upper(trim(cst_gndr)) = 'M' then 'Male'
		when upper(trim(cst_gndr)) = 'F' then 'Female'
		else 'n/a'
	end cst_gndr,
	cst_create_date
	from
	(
		select 
		*,
		ROW_NUMBER () over (partition by cst_id order by cst_create_date desc) flag_last
		from
		bronze.crm_cust_info
		where cst_id is not null
	) x where flag_last = 1


	PRINT '*****TABLE 1****silver.crm_cust_info "Transformation" DONE ***********'

	TRUNCATE table silver.crm_prd_info

	insert into silver.crm_prd_info
	(
		prd_id ,
		cat_id ,
		prd_key ,
		prd_nm ,
		prd_cost ,
		prd_line ,
		prd_start_dt ,
		prd_end_dt 
	)
	select
	prd_id,
	replace(left(prd_key,5),'-','_') as cat_id,
	substring(prd_key,7,len(prd_key)) as prd_key,
	prd_nm,
	isnull(prd_cost,0) as prd_cost,
	case 
		when Upper(trim(prd_line)) = 'R' then 'Road'
		when Upper(trim(prd_line)) = 'M' then 'Mountain'
		when Upper(trim(prd_line)) = 'S' then 'Other sales'
		when Upper(trim(prd_line)) = 'T' then 'Touring'
		else 'n/a'
	end as prd_line,
	cast(prd_start_dt as date) as prd_start_dt,
	cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt
	from 
	bronze.crm_prd_info 

	PRINT '*****TABLE 2****silver.crm_prd_info IS DONE********'

	/*
	*********************************TABLE 3(silver.crm_sales_details)*********************************
	*/
	TRUNCATE table silver.crm_sales_details
	PRINT 'TRUNCATING IS DONE'

	insert into silver.crm_sales_details
	(
		sls_ord_num ,
		sls_prd_key ,
		sls_cust_id ,
		sls_order_dt ,
		sls_ship_dt ,
		sls_due_dt ,
		sls_sales ,
		sls_quantity ,
		sls_price
	)
	select
		sls_ord_num ,
		sls_prd_key ,
		sls_cust_id ,
		case 
			when sls_order_dt = 0 or len(sls_order_dt) != 8 then null
			else cast(cast(sls_order_dt as varchar)as date)
		end as sls_order_dt,
		case 
			when sls_ship_dt = 0 or len(sls_ship_dt) != 8 then null
			else cast(cast(sls_ship_dt as varchar)as date)
		end as sls_ship_dt ,
		case 
			when sls_due_dt = 0 or len(sls_due_dt) != 8 then null
			else cast(cast(sls_due_dt as varchar)as date)
		end as sls_due_dt ,
		case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price)
				then sls_quantity * abs(sls_price)
				else sls_sales
		end as sls_sales,
		sls_quantity ,
		case when sls_price is null or sls_price <= 0
				then sls_sales / nullif(sls_quantity , 0)
			 else sls_price
		end as sls_price
	from 
	bronze.crm_sales_details

	PRINT'*********TABLE 3(silver.crm_sales_details) IS LOADED********'

	/*
	*********************************TABLE 4(silver.erp_cust_az12)*********************************
	*/
	TRUNCATE table silver.erp_cust_az12
	PRINT 'TRUNCATING IS DONE'

	insert into silver.erp_cust_az12
	(
		cid,
		bdate,
		gen
	)
	select
	case 
		when CID like 'NAS%' then SUBSTRING(CID,4,len(CID))
		else CID
	end as cid,
	case when BDATE > getdate() then null
		else BDATE
	end as bdate,
	case
		when upper(trim(GEN)) in ('F', 'FEMALE') then 'FEMALE'
		when upper(trim(GEN)) in ('M','MALE') then 'MALE'
		else 'n/a'
	end gen

	from bronze.erp_CUST_AZ12

	PRINT '*****TABLE 4(silver.erp_cust_az12) "Transformation" DONE ***********'

	/*
	*********************************TABLE 5(silver.erp_loc_a101)*********************************
	*/
	TRUNCATE table silver.erp_loc_a101
	PRINT 'TRUNCATING IS DONE'

	insert into silver.erp_loc_a101
	(
		cid,
		cntry
	)
	select 
	case 
		when upper(trim(CNTRY)) in ('USA','US') then 'United States'
		when Upper(trim(CNTRY)) = 'DE' then 'Germany'
		when Upper(trim(CNTRY)) = '' or CNTRY is null then 'n/a'
		else trim(CNTRY)
	end as cntry,
	replace(CID,'-','') as cid 
	from bronze.erp_LOC_A101

	PRINT '*****TABLE 5(silver.erp_loc_a101)"Transformation" DONE ***********'
	/*
	*********************************TABLE 6(silver.erp_px_cat_g1v2)*********************************
	*/

	TRUNCATE table silver.erp_px_cat_g1v2
	PRINT 'TRUNCATING IS DONE'

	insert into silver.erp_px_cat_g1v2
	(
		id ,
		cat ,
		subcat ,
		maintenance
	)
	select
	* 
	from 
	bronze.erp_PX_CAT_G1V2


	PRINT '*****TABLE 6(silver.erp_px_cat_g1v2)"Transformation" DONE ***********'
END

EXEC silver.load_silver_layer;
