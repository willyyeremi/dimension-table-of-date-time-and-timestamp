select
	id
	,datum as actual_time_1
	,TO_CHAR(datum, 'HH12:MI:SS AM') as actual_time_2
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
;