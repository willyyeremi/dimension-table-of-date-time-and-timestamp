drop table if exists public.dim_time;
create table public.dim_time as(
	select
		id
		,datum as actual_time_1
		,TO_CHAR(datum, 'HH12:MI:SS AM') as actual_time_2
		,EXTRACT(EPOCH FROM datum)::bigint AS epoch
		,to_char(datum,'HH24')::int as hour_1
		,to_char(datum,'HH12')::int as hour_2
		,to_char(datum,'mi')::int as "minute"
		,to_char(datum,'ss')::int as "second"
		,to_char(datum,'AM') as "meridiem_indicator_1"
		,to_char(datum,'am') as "meridiem_indicator_2"
		,to_char(datum,'A.M.') as "meridiem_indicator_3"
		,to_char(datum,'a.m.') as "meridiem_indicator_4"
	FROM
		(SELECT 
			"second" + 1 as "id"
			,time '00:00:01' + (SEQUENCE.second||'seconds')::interval AS datum
		FROM 
			GENERATE_SERIES(0, 86400) AS SEQUENCE(second)) as list_second
);
comment on column public.dim_time."id" is 'unique identifier for each row';
comment on column public.dim_time."actual_time_1" is 'time with 24 hour format and hh:mi:ss format';
comment on column public.dim_time."actual_time_2" is 'time with 12 hour format and hh:mi:ss format';
comment on column public.dim_time."epoch" is 'epoch value for each date';
comment on column public.dim_time."hour_1" is 'hour from 24 hour time format';
comment on column public.dim_time."hour_2" is 'hour from 12 hour time format';
comment on column public.dim_time."minute" is 'minute from time';
comment on column public.dim_time."second" is 'second from time';
comment on column public.dim_time."meridiem_indicator_1" is 'meridiem indicator with uppercase and without dot';
comment on column public.dim_time."meridiem_indicator_2" is 'meridiem indicator with lowercase and without dot';
comment on column public.dim_time."meridiem_indicator_3" is 'meridiem indicator with uppercase and with dot';
comment on column public.dim_time."meridiem_indicator_4" is 'meridiem indicator with lowercase and with dot';