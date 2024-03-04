-- section 1: script for creating table. if just want to see data using select statement, go to section 2
-- section 1.1: script for creating table dimension date
drop table if exists public.dim_date;
create table public.dim_date as (
	SELECT 
		TO_CHAR(datum, 'yyyymmdd')::INT AS date_dim_id,
	    datum AS date_actual
	    ,EXTRACT(EPOCH FROM datum) AS epoch
	    ,TO_CHAR(datum, 'TMDay') AS day_name
	    ,EXTRACT(ISODOW FROM datum) AS "day_of_week_1" -- iso 8601, starting day from monday to sunday
	    ,(EXTRACT(ISODOW FROM datum) % 7) + 1 AS "day_of_week_2" -- starting day from sunday to saturday
	    ,EXTRACT(DAY FROM datum) AS day_of_month
	    ,datum - DATE_TRUNC('quarter', datum)::DATE + 1 AS day_of_quarter
	    ,EXTRACT(DOY FROM datum) AS day_of_year
	    ,TO_CHAR(datum, 'W')::INT AS week_of_month_1 -- week started from day one of month
	    ,case
	    	when 
	    		datum >= datum + (1 - EXTRACT(DAY FROM datum))::INT
	    		and
	    		datum <= datum + (1 - EXTRACT(DAY FROM datum))::INT + (7 - EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT))::int)::int
	    		and
	    		EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) <= 4
	    		then
	    			1
	    	when 
				datum >= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE))::int + 1
				and 
				datum <= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE
				and
	    		EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE)) < 4
			    then
			    	1
	    	when
	    		datum >= datum + (1 - EXTRACT(DAY FROM datum))::INT
	    		and
	    		datum <= datum + (1 - EXTRACT(DAY FROM datum))::INT + (7 - EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT))::int)
	    		and
	    		EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) > 4
	    		and
	       		extract(isodow from ((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM(datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT)) <= 4
	    		then
					ceil(((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) - ((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT + (7 - extract(isodow from((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT))::int)))/7::float) + 1
			when
				datum >= datum + (1 - EXTRACT(DAY FROM datum))::INT
				and
	    		datum <= datum + (1 - EXTRACT(DAY FROM datum))::INT + (7 - EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)))::int
				and
	    		EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) > 4
				and
	    		extract(isodow from ((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM(datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT)) > 4
				then
					ceil(((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) - ((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT + (7 - extract(isodow from((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT))::int)))/7::float)
			when
				datum >= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE))::int + 1
				and 
				datum <= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE
				and
			    EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE)) >= 4
				and 
				EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) <= 4
			    then
			    	ceil((datum - ((datum + (1 - EXTRACT(DAY FROM datum))::INT) + (7 - extract(isodow from(datum + (1 - EXTRACT(DAY FROM datum))::INT))::int)))/7::float) + 1
		    when
				datum >= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE))::int + 1
				and 
				datum <= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE
				and 
			    EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE)) >= 4
			    and
				EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) > 4
				then
					ceil((datum - ((datum + (1 - EXTRACT(DAY FROM datum))::INT) + (7 - extract(isodow from(datum + (1 - EXTRACT(DAY FROM datum))::INT))::int)))/7::float)
			when
				EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) > 4
				then
					ceil((datum - ((datum + (1 - EXTRACT(DAY FROM datum))::INT) + (7 - extract(isodow from(datum + (1 - EXTRACT(DAY FROM datum))::INT))::int)))/7::float)
			when
				EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) <= 4
				then
					ceil((datum - ((datum + (1 - EXTRACT(DAY FROM datum))::INT) + (7 - extract(isodow from(datum + (1 - EXTRACT(DAY FROM datum))::INT))::int)))/7::float) + 1
	    end as week_of_month_2 -- based on iso 8601, starting day from monday
	    ,case
	    	when 
	    		datum >= datum + (1 - EXTRACT(DAY FROM datum))::INT
	    		and
	    		datum <= (datum + (1 - EXTRACT(DAY FROM datum))::INT) + (7 - ((EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT))::int % 7) + 1))::int
	    		and
	    		((EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT))::int % 7) + 1) <= 4
	    		then
	    			1
			when
				datum >= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - ((EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE))::int % 7) + 1) + 1
				and 
				datum <= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE
				and
	    		((EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE))::int % 7) + 1) < 4
			    then
			    	1
			when
	    		datum >= datum + (1 - EXTRACT(DAY FROM datum))::INT
	    		and
	    		datum <= (datum + (1 - EXTRACT(DAY FROM datum))::INT) + (7 - ((EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT))::int % 7) + 1))::int
	    		and
	    		((EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT))::int % 7) + 1) > 4
	    		and
	       		(extract(isodow from ((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM(datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT)) % 7) + 1 <= 4
	    		then
					ceil(((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) - ((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT + (7 - ((extract(isodow from((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT))::int % 7) + 1))))/7::float) + 1
			when
				datum >= datum + (1 - EXTRACT(DAY FROM datum))::INT
				and
	    		datum <= (datum + (1 - EXTRACT(DAY FROM datum))::INT) + (7 - ((EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT))::int % 7) + 1))::int
				and
	    		((EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) % 7) + 1) > 4
				and
	    		((extract(isodow from ((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM(datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT)) % 7) + 1)> 4
				then
					ceil(((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) - ((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT + (7 - ((extract(isodow from((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT))::int % 7) + 1))))/7::float)
			when
				datum >= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - ((EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE))::int % 7) + 1) + 1
				and 
				datum <= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE
				and
			    ((EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE)) % 7) + 1) >= 4
				and 
				((EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) % 7) + 1) <= 4
			    then
			    	ceil((datum - ((datum + (1 - EXTRACT(DAY FROM datum))::INT) + (7 - ((extract(isodow from(datum + (1 - EXTRACT(DAY FROM datum))::INT))::int % 7) + 1))))/7::float) + 1
	    	when
				datum >= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - ((EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE))::int % 7) + 1) + 1
				and 
				datum <= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE
				and 
			    ((EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE)) % 7) + 1) >= 4
			    and
				((EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) % 7) + 1) > 4
				then
					ceil((datum - ((datum + (1 - EXTRACT(DAY FROM datum))::INT) + (7 - ((extract(isodow from(datum + (1 - EXTRACT(DAY FROM datum))::INT))::int % 7) + 1))))/7::float)
			when
				((EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) % 7) + 1) > 4
				then
					ceil((datum - ((datum + (1 - EXTRACT(DAY FROM datum))::INT) + (7 - ((extract(isodow from(datum + (1 - EXTRACT(DAY FROM datum))::INT))::int % 7) + 1))))/7::float)
			when
				((EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) % 7) + 1) <= 4
				then
					ceil((datum - ((datum + (1 - EXTRACT(DAY FROM datum))::INT) + (7 - ((extract(isodow from(datum + (1 - EXTRACT(DAY FROM datum))::INT))::int % 7) + 1))))/7::float) + 1
	    end as week_of_month_3 -- based on iso 8601, starting day from sunday
		,EXTRACT(WEEK FROM datum) AS "week_of_year_1" -- iso 8601, middle day in thursday because a week starting from monday, first and last week decision based on thursday
	    ,case
			when
			    (EXTRACT(ISODOW FROM (TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'))) % 7) + 1 >= 4
			    and
			    datum >= TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') - (EXTRACT(ISODOW FROM (TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'))) % 7)::int + 1
			    and
			    datum <= TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD')
			    then
			    	EXTRACT(WEEK FROM datum)
		   	when 
				(EXTRACT(ISODOW FROM (TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'))) % 7) + 1 < 4
			    and
			    datum >= TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') - (EXTRACT(ISODOW FROM (TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'))) % 7):: int + 1
			    and
			    datum <= TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD')
			    then
			    	1
			when
			    (EXTRACT(ISODOW FROM (TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD'))) % 7) + 1 <= 4
			    and
			    datum <= TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD') + (7 - ((EXTRACT(ISODOW FROM (TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD')))::int % 7) + 1))
			    and
			    datum >= TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD')
			    then
			    	1
	    	when
	    		(EXTRACT(ISODOW FROM (TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD'))) % 7) + 1 > 4
			    and
			    datum <= TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD') + (7 - ((EXTRACT(ISODOW FROM (TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD')))::int % 7) + 1))
			    and
			    datum >= TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD')
			    then
			    	EXTRACT(WEEK FROM (TO_DATE((EXTRACT(YEAR FROM datum) - 1) || '-12-31', 'YYYY-MM-DD')))
			when
				(EXTRACT(ISODOW FROM datum) % 7) + 1 = 1
				then
					EXTRACT(week FROM (datum + 1))
			else
				extract(week from datum)
		end as "week_of_year_2" -- based on iso 8601 weak of year rule but with middle week at wednesday rather than thursday because day starting from sunday
	    ,EXTRACT(MONTH FROM datum) AS month_actual
	    ,TO_CHAR(datum, 'TMMonth') AS month_name
	    ,EXTRACT(QUARTER FROM datum) AS quarter_actual
	    ,CASE
		    WHEN 
		    	EXTRACT(QUARTER FROM datum) = 1 
	    		THEN 
	    			'First'
		    WHEN 
		    	EXTRACT(QUARTER FROM datum) = 2 
		    	THEN 
		    		'Second'
		    WHEN 
		    	EXTRACT(QUARTER FROM datum) = 3 
		    	THEN 
		    		'Third'
		    WHEN 
		    	EXTRACT(QUARTER FROM datum) = 4 
		    	THEN 
		    		'Fourth'
	    END AS quarter_name
	    ,EXTRACT(YEAR FROM datum) AS year_actual
	    ,datum + (1 - EXTRACT(ISODOW FROM datum))::INT AS "first_day_of_week_1" -- iso 8601, week of year and day starting from monday
	    ,datum + (7 - EXTRACT(ISODOW FROM datum))::INT AS "last_day_of_week_1" -- iso 8601, about week of year and day starting from monday
	    ,datum + (1 - ((EXTRACT(ISODOW FROM datum) % 7) + 1))::INT as "first_day_of_week_2" -- based on iso 8601 weak of year rule but with middle week at wednesday rather than thursday because day starting from sunday
	    ,datum + (7 - ((EXTRACT(ISODOW FROM datum) % 7) + 1))::INT as "last_day_of_week_2" -- based on iso 8601 weak of year rule but with middle week at wednesday rather than thursday because day starting from sunday
	    ,datum + (1 - EXTRACT(DAY FROM datum))::INT AS first_day_of_month
	    ,(DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE AS last_day_of_month
	    ,DATE_TRUNC('quarter', datum)::DATE AS first_day_of_quarter
	    ,(DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE AS last_day_of_quarter
	    ,TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD') AS first_day_of_year
	    ,TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') AS last_day_of_year
	    ,case
	    	when
	    		EXTRACT(week from (TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'))) = 1
				then 
					EXTRACT(week from (TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') - 3))
			else
	    		EXTRACT(week from (TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD')))
	    end as "total_week_1" -- based on iso 8601 about week of year
	    ,CASE
			WHEN 
				EXTRACT(ISODOW FROM datum) IN (6, 7)
				THEN 
					true
			ELSE FALSE
		END AS "is_weekend" -- weekend at saturday and sunday
		,CASE
	        WHEN 
	        	EXTRACT(DOY from (TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'))) = 365
	        	THEN 
	        		true
	        ELSE 
	        	false
	    END AS "is_leap_year"
	FROM 
		(SELECT 
			'1970-01-01'::DATE + SEQUENCE.DAY AS datum
		FROM 
			GENERATE_SERIES(0, 29219) AS SEQUENCE (DAY)) as list_date)
;
comment on column public.dim_date."day_of_week_1" is 'iso 8601, starting day from monday to sunday';
comment on column public.dim_date."day_of_week_2" is 'starting day from sunday to saturday';
comment on column public.dim_date.week_of_month_1 is 'week started from day one of month';
comment on column public.dim_date.week_of_month_2 is 'based on iso 8601, starting day from monday';
comment on column public.dim_date.week_of_month_3 is 'based on iso 8601, starting day from sunday';
comment on column public.dim_date."week_of_year_1" is 'iso 8601, middle day in thursday because a week starting from monday, first and last week decision based on thursday';
comment on column public.dim_date."week_of_year_2" is 'based on iso 8601 weak of year rule but with middle week at wednesday rather than thursday because day starting from sunday';
comment on column public.dim_date."first_day_of_week_1" is 'iso 8601, week of year and day starting from monday';
comment on column public.dim_date."last_day_of_week_1" is 'iso 8601, about week of year and day starting from monday';
comment on column public.dim_date."first_day_of_week_2" is 'based on iso 8601 weak of year rule but with middle week at wednesday rather than thursday because day starting from sunday';
comment on column public.dim_date."last_day_of_week_2" is 'based on iso 8601 weak of year rule but with middle week at wednesday rather than thursday because day starting from sunday';
comment on column public.dim_date."is_weekend" is 'weekend at saturday and sunday';

-- section 2: script to preview data
-- section 2.1: preview for table dimension date
SELECT 
	TO_CHAR(datum, 'yyyymmdd')::INT AS date_dim_id,
    datum AS date_actual
    ,EXTRACT(EPOCH FROM datum) AS epoch
    ,TO_CHAR(datum, 'TMDay') AS day_name
    ,EXTRACT(ISODOW FROM datum) AS "day_of_week_1" -- iso 8601, starting day from monday to sunday
    ,(EXTRACT(ISODOW FROM datum) % 7) + 1 AS "day_of_week_2" -- starting day from sunday to saturday
    ,EXTRACT(DAY FROM datum) AS day_of_month
    ,datum - DATE_TRUNC('quarter', datum)::DATE + 1 AS day_of_quarter
    ,EXTRACT(DOY FROM datum) AS day_of_year
    ,TO_CHAR(datum, 'W')::INT AS week_of_month_1 -- week started from day one of month
    ,case
    	when 
    		datum >= datum + (1 - EXTRACT(DAY FROM datum))::INT
    		and
    		datum <= datum + (1 - EXTRACT(DAY FROM datum))::INT + (7 - EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT))::int)::int
    		and
    		EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) <= 4
    		then
    			1
    	when 
			datum >= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE))::int + 1
			and 
			datum <= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE
			and
    		EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE)) < 4
		    then
		    	1
    	when
    		datum >= datum + (1 - EXTRACT(DAY FROM datum))::INT
    		and
    		datum <= datum + (1 - EXTRACT(DAY FROM datum))::INT + (7 - EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT))::int)
    		and
    		EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) > 4
    		and
       		extract(isodow from ((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM(datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT)) <= 4
    		then
				ceil(((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) - ((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT + (7 - extract(isodow from((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT))::int)))/7::float) + 1
		when
			datum >= datum + (1 - EXTRACT(DAY FROM datum))::INT
			and
    		datum <= datum + (1 - EXTRACT(DAY FROM datum))::INT + (7 - EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)))::int
			and
    		EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) > 4
			and
    		extract(isodow from ((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM(datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT)) > 4
			then
				ceil(((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) - ((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT + (7 - extract(isodow from((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT))::int)))/7::float)
		when
			datum >= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE))::int + 1
			and 
			datum <= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE
			and
		    EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE)) >= 4
			and 
			EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) <= 4
		    then
		    	ceil((datum - ((datum + (1 - EXTRACT(DAY FROM datum))::INT) + (7 - extract(isodow from(datum + (1 - EXTRACT(DAY FROM datum))::INT))::int)))/7::float) + 1
	    when
			datum >= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE))::int + 1
			and 
			datum <= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE
			and 
		    EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE)) >= 4
		    and
			EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) > 4
			then
				ceil((datum - ((datum + (1 - EXTRACT(DAY FROM datum))::INT) + (7 - extract(isodow from(datum + (1 - EXTRACT(DAY FROM datum))::INT))::int)))/7::float)
		when
			EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) > 4
			then
				ceil((datum - ((datum + (1 - EXTRACT(DAY FROM datum))::INT) + (7 - extract(isodow from(datum + (1 - EXTRACT(DAY FROM datum))::INT))::int)))/7::float)
		when
			EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) <= 4
			then
				ceil((datum - ((datum + (1 - EXTRACT(DAY FROM datum))::INT) + (7 - extract(isodow from(datum + (1 - EXTRACT(DAY FROM datum))::INT))::int)))/7::float) + 1
    end as week_of_month_2 -- based on iso 8601, starting day from monday
    ,case
    	when 
    		datum >= datum + (1 - EXTRACT(DAY FROM datum))::INT
    		and
    		datum <= (datum + (1 - EXTRACT(DAY FROM datum))::INT) + (7 - ((EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT))::int % 7) + 1))::int
    		and
    		((EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT))::int % 7) + 1) <= 4
    		then
    			1
		when
			datum >= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - ((EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE))::int % 7) + 1) + 1
			and 
			datum <= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE
			and
    		((EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE))::int % 7) + 1) < 4
		    then
		    	1
		when
    		datum >= datum + (1 - EXTRACT(DAY FROM datum))::INT
    		and
    		datum <= (datum + (1 - EXTRACT(DAY FROM datum))::INT) + (7 - ((EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT))::int % 7) + 1))::int
    		and
    		((EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT))::int % 7) + 1) > 4
    		and
       		(extract(isodow from ((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM(datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT)) % 7) + 1 <= 4
    		then
				ceil(((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) - ((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT + (7 - ((extract(isodow from((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT))::int % 7) + 1))))/7::float) + 1
		when
			datum >= datum + (1 - EXTRACT(DAY FROM datum))::INT
			and
    		datum <= (datum + (1 - EXTRACT(DAY FROM datum))::INT) + (7 - ((EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT))::int % 7) + 1))::int
			and
    		((EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) % 7) + 1) > 4
			and
    		((extract(isodow from ((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM(datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT)) % 7) + 1)> 4
			then
				ceil(((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) - ((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT + (7 - ((extract(isodow from((datum + (1 - EXTRACT(DAY FROM datum))::INT - 1) + (1 - EXTRACT(DAY FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT - 1)))::INT))::int % 7) + 1))))/7::float)
		when
			datum >= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - ((EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE))::int % 7) + 1) + 1
			and 
			datum <= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE
			and
		    ((EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE)) % 7) + 1) >= 4
			and 
			((EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) % 7) + 1) <= 4
		    then
		    	ceil((datum - ((datum + (1 - EXTRACT(DAY FROM datum))::INT) + (7 - ((extract(isodow from(datum + (1 - EXTRACT(DAY FROM datum))::INT))::int % 7) + 1))))/7::float) + 1
    	when
			datum >= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - ((EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE))::int % 7) + 1) + 1
			and 
			datum <= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE
			and 
		    ((EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE)) % 7) + 1) >= 4
		    and
			((EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) % 7) + 1) > 4
			then
				ceil((datum - ((datum + (1 - EXTRACT(DAY FROM datum))::INT) + (7 - ((extract(isodow from(datum + (1 - EXTRACT(DAY FROM datum))::INT))::int % 7) + 1))))/7::float)
		when
			((EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) % 7) + 1) > 4
			then
				ceil((datum - ((datum + (1 - EXTRACT(DAY FROM datum))::INT) + (7 - ((extract(isodow from(datum + (1 - EXTRACT(DAY FROM datum))::INT))::int % 7) + 1))))/7::float)
		when
			((EXTRACT(ISODOW FROM (datum + (1 - EXTRACT(DAY FROM datum))::INT)) % 7) + 1) <= 4
			then
				ceil((datum - ((datum + (1 - EXTRACT(DAY FROM datum))::INT) + (7 - ((extract(isodow from(datum + (1 - EXTRACT(DAY FROM datum))::INT))::int % 7) + 1))))/7::float) + 1
    end as week_of_month_3 -- based on iso 8601, starting day from sunday
	,EXTRACT(WEEK FROM datum) AS "week_of_year_1" -- iso 8601, middle day in thursday because a week starting from monday, first and last week decision based on thursday
    ,case
		when
		    (EXTRACT(ISODOW FROM (TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'))) % 7) + 1 >= 4
		    and
		    datum >= TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') - (EXTRACT(ISODOW FROM (TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'))) % 7)::int + 1
		    and
		    datum <= TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD')
		    then
		    	EXTRACT(WEEK FROM datum)
	   	when 
			(EXTRACT(ISODOW FROM (TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'))) % 7) + 1 < 4
		    and
		    datum >= TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') - (EXTRACT(ISODOW FROM (TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'))) % 7):: int + 1
		    and
		    datum <= TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD')
		    then
		    	1
		when
		    (EXTRACT(ISODOW FROM (TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD'))) % 7) + 1 <= 4
		    and
		    datum <= TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD') + (7 - ((EXTRACT(ISODOW FROM (TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD')))::int % 7) + 1))
		    and
		    datum >= TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD')
		    then
		    	1
    	when
    		(EXTRACT(ISODOW FROM (TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD'))) % 7) + 1 > 4
		    and
		    datum <= TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD') + (7 - ((EXTRACT(ISODOW FROM (TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD')))::int % 7) + 1))
		    and
		    datum >= TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD')
		    then
		    	EXTRACT(WEEK FROM (TO_DATE((EXTRACT(YEAR FROM datum) - 1) || '-12-31', 'YYYY-MM-DD')))
		when
			(EXTRACT(ISODOW FROM datum) % 7) + 1 = 1
			then
				EXTRACT(week FROM (datum + 1))
		else
			extract(week from datum)
	end as "week_of_year_2" -- based on iso 8601 weak of year rule but with middle week at wednesday rather than thursday because day starting from sunday
    ,EXTRACT(MONTH FROM datum) AS month_actual
    ,TO_CHAR(datum, 'TMMonth') AS month_name
    ,EXTRACT(QUARTER FROM datum) AS quarter_actual
    ,CASE
	    WHEN 
	    	EXTRACT(QUARTER FROM datum) = 1 
    		THEN 
    			'First'
	    WHEN 
	    	EXTRACT(QUARTER FROM datum) = 2 
	    	THEN 
	    		'Second'
	    WHEN 
	    	EXTRACT(QUARTER FROM datum) = 3 
	    	THEN 
	    		'Third'
	    WHEN 
	    	EXTRACT(QUARTER FROM datum) = 4 
	    	THEN 
	    		'Fourth'
    END AS quarter_name
    ,EXTRACT(YEAR FROM datum) AS year_actual
    ,datum + (1 - EXTRACT(ISODOW FROM datum))::INT AS "first_day_of_week_1" -- iso 8601, week of year and day starting from monday
    ,datum + (7 - EXTRACT(ISODOW FROM datum))::INT AS "last_day_of_week_1" -- iso 8601, about week of year and day starting from monday
    ,datum + (1 - ((EXTRACT(ISODOW FROM datum) % 7) + 1))::INT as "first_day_of_week_2" -- based on iso 8601 weak of year rule but with middle week at wednesday rather than thursday because day starting from sunday
    ,datum + (7 - ((EXTRACT(ISODOW FROM datum) % 7) + 1))::INT as "last_day_of_week_2" -- based on iso 8601 weak of year rule but with middle week at wednesday rather than thursday because day starting from sunday
    ,datum + (1 - EXTRACT(DAY FROM datum))::INT AS first_day_of_month
    ,(DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE AS last_day_of_month
    ,DATE_TRUNC('quarter', datum)::DATE AS first_day_of_quarter
    ,(DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE AS last_day_of_quarter
    ,TO_DATE(EXTRACT(YEAR FROM datum) || '-01-01', 'YYYY-MM-DD') AS first_day_of_year
    ,TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') AS last_day_of_year
    ,case
    	when
    		EXTRACT(week from (TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'))) = 1
			then 
				EXTRACT(week from (TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') - 3))
		else
    		EXTRACT(week from (TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD')))
    end as "total_week_1" -- based on iso 8601 about week of year
    ,CASE
		WHEN 
			EXTRACT(ISODOW FROM datum) IN (6, 7)
			THEN 
				true
		ELSE FALSE
	END AS "is_weekend" -- weekend at saturday and sunday
	,CASE
        WHEN 
        	EXTRACT(DOY from (TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'))) = 365
        	THEN 
        		true
        ELSE 
        	false
    END AS "is_leap_year"
FROM 
	(SELECT 
		'1970-01-01'::DATE + SEQUENCE.DAY AS datum
	FROM 
		GENERATE_SERIES(0, 29219) AS SEQUENCE (DAY)) as list_date)
;