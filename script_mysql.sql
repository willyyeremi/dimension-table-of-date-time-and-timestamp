select
-- 	cast(date_format(datum,'%Y%m%d') as signed) as date_dim_id,
	datum as date_actual
-- 	,unix_timestamp(datum) AS epoch
	,dayname(datum) as day_name
	,((dayofweek(datum) + 5) % 7) + 1 as day_of_week_1
	,dayofweek(datum) as day_of_week_2
-- 	,dayofmonth(datum) as day_of_month
-- 	,datediff(date_add(datum,interval 1 day) ,case 
-- 		when 
-- 			extract(month from datum) >= 9
-- 			then
-- 				cast(date_format(datum,'%Y-09-01') as date)
-- 		when 
-- 			extract(month from datum) >= 5
-- 			then
-- 				cast(date_format(datum,'%Y-05-01') as date)
-- 		when 
-- 			extract(month from datum) >= 1
-- 			then
-- 				cast(date_format(datum,'%Y-01-01') as date)
-- 	end) as day_of_quarter
-- 	,dayofyear(datum) as day_of_year
	,CEIL(DAYOFMONTH(datum) / 7) as week_of_month_1
	,cast(date_format(datum,'%v') as signed) as  week_of_year_1
	,cast(date_format(datum,'%V') as signed) as  week_of_year_2
	,cast(date_format(datum,'%m') as signed) as month_actual
	,date_format(datum,'%M') as month_name
	,quarter(datum) as quarter_actual
	,case 
		when 
			quarter(datum) = 1
			then 'First'
		when 
			quarter(datum) = 2
			then 'Second'
		when 
			quarter(datum) = 3
			then 'Third'
		when 
			quarter(datum) = 4
			then 'Fourth'
	end as quarter_name
	,cast(date_format(datum,'%Y-%m-01') as date) as first_day_of_month
	,last_day(datum) as last_day_of_month
from
	(SELECT 
		DATE('1970-01-01') + INTERVAL a.i*10000 + b.i*1000 + c.i*100 + d.i*10 + e.i day as datum
	FROM 
		(select 0 i union select 1 i union select 2 i union select 3 i union select 4 i union select 5 i union select 6 i union select 7 i union select 8 i union select 9 i) a
		JOIN 
		(select 0 i union select 1 i union select 2 i union select 3 i union select 4 i union select 5 i union select 6 i union select 7 i union select 8 i union select 9 i) b 
		JOIN 
		(select 0 i union select 1 i union select 2 i union select 3 i union select 4 i union select 5 i union select 6 i union select 7 i union select 8 i union select 9 i) c 
		JOIN 
		(select 0 i union select 1 i union select 2 i union select 3 i union select 4 i union select 5 i union select 6 i union select 7 i union select 8 i union select 9 i) d 
		JOIN 
		(select 0 i union select 1 i union select 2 i union select 3 i union select 4 i union select 5 i union select 6 i union select 7 i union select 8 i union select 9 i) e
	) as date_sequence
order by
	datum
;

