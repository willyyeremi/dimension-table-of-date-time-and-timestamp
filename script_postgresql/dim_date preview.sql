SELECT 
	id AS date_dim_id,
	datum AS date_actual
	,EXTRACT(EPOCH FROM datum)::bigint AS epoch
	,TO_CHAR(datum, 'TMDay') AS day_name
	,case
		when
			datum >= date_trunc('month',datum)::date
			and
			datum <= date_trunc('month',datum)::date + (7 - to_char(date_trunc('month',datum)::date,'id')::int)
			then
				to_char(datum,'dd')::int
		else
			EXTRACT(ISODOW FROM datum)::int
	end day_of_week_1
	,case
		when
			datum >= date_trunc('month',datum)::date
			and
			datum <= date_trunc('month',datum)::date + (7 - to_char(date_trunc('month',datum)::date,'d')::int)
			then
				to_char(datum,'dd')::int
		else
			to_char(datum,'d')::int
	end day_of_week_2
	,EXTRACT(ISODOW FROM datum)::int AS "day_of_week_3" -- iso 8601, starting day from monday to sunday
	,TO_CHAR(datum,'D')::INT AS "day_of_week_4" -- starting day from sunday to saturday
	,EXTRACT(DAY FROM datum)::int AS day_of_month_1
	-- first day from first day of first week. week calculation based on iso 8601.
	,case
		when
			datum >= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - extract(isodow from (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE)::int + 1
			and
			datum <= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE
			and
			extract(isodow from (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE)::int < 4
			then
				extract(isodow from datum)::int
		else
			case
				when
					extract(isodow from date_trunc('month',datum)::date) <= 4
					then
						datum - (date_trunc('month',datum)::date - extract(isodow from date_trunc('month',datum)::date)::int + 1) + 1
				when
					extract(isodow from date_trunc('month',datum)::date) > 4
					then
						case
							when
								datum <= date_trunc('month',datum)::date + (7 - extract(isodow from date_trunc('month',datum)::date)::int)
								then
									case
										when
											extract(isodow from date_trunc('month',date_trunc('month',datum)::date - 1)::date)::int <= 4
											then
												datum - date_trunc('month',date_trunc('month',datum)::date - 1)::date + (extract(isodow from date_trunc('month',date_trunc('month',datum)::date - 1)))::int
										when
											extract(isodow from date_trunc('month',date_trunc('month',datum)::date - 1)::date)::int > 4
											then
												datum - (date_trunc('month',date_trunc('month',datum)::date - 1)::date + (7 - extract(isodow from date_trunc('month',date_trunc('month',datum)::date - 1)))::int)
									end
							when
								datum > date_trunc('month',datum)::date + (7 - extract(isodow from date_trunc('month',datum)::date)::int)
								then
									datum - (date_trunc('month',datum)::date + (7 - extract(isodow from date_trunc('month',datum)::date)::int))
						end		
			end
	end as day_of_month_2
	-- first day from first day of first week. week calculation like iso 8601 but first week day from sunday
	,case
		when
			datum >= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'D')::int + 1
			and
			datum <= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE
			and
			TO_CHAR((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'D')::int < 4
			then
				TO_CHAR(datum,'d')::int
		else
			case
				when
					to_char(date_trunc('month',datum)::date,'d')::int <= 4
					then
						datum - (date_trunc('month',datum)::date - to_char(date_trunc('month',datum)::date,'d')::int + 1) + 1
				when
					to_char(date_trunc('month',datum)::date,'d')::int > 4
					then
						case
							when
								datum <= date_trunc('month',datum)::date + (7 - to_char(date_trunc('month',datum)::date,'d')::int)
								then
									case
										when
											to_char(date_trunc('month',date_trunc('month',datum)::date - 1)::date,'d')::int <= 4
											then
												datum - date_trunc('month',date_trunc('month',datum)::date - 1)::date + to_char(date_trunc('month',date_trunc('month',datum)::date - 1),'d')::int
										when
											to_char(date_trunc('month',date_trunc('month',datum)::date - 1)::date,'d')::int > 4
											then
												datum - (date_trunc('month',date_trunc('month',datum)::date - 1)::date + (7 - to_char(date_trunc('month',date_trunc('month',datum)::date - 1),'d')::int))
									end
							when
								datum > date_trunc('month',datum)::date + (7 - to_char(date_trunc('month',datum)::date,'d')::int)
								then
									datum - (date_trunc('month',datum)::date + (7 - to_char(date_trunc('month',datum)::date,'d')::int))
						end		
			end
	end  as day_of_month_3
	,datum - DATE_TRUNC('quarter', datum)::DATE + 1 AS day_of_quarter_1
	,case
		when
			datum >= (DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE - to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'id')::int + 1
			and
			datum <= (DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE
			and
			to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'id')::int < 4
			then
				to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'id')::int
		when
			datum >= DATE_TRUNC('quarter', datum)::DATE
			and
			datum <= DATE_TRUNC('quarter', datum)::DATE + (7 - to_char(DATE_TRUNC('quarter', datum)::DATE,'id')::int)
			and
			to_char(DATE_TRUNC('quarter', datum)::DATE,'id')::int > 4
			then
				case
					when
						to_char(date_trunc('quarter',(DATE_TRUNC('quarter', datum)::DATE - 1))::date,'id')::int <= 4
						then
							datum - (date_trunc('quarter',(DATE_TRUNC('quarter', datum)::DATE - 1))::date - to_char(date_trunc('quarter',(DATE_TRUNC('quarter', datum)::DATE - 1))::date,'id')::int + 1) + 1
					when
						to_char(date_trunc('quarter',(DATE_TRUNC('quarter', datum)::DATE - 1))::date,'id')::int > 4
						then
							datum - (date_trunc('quarter',(DATE_TRUNC('quarter', datum)::DATE - 1))::date + (7 - to_char(date_trunc('quarter',(DATE_TRUNC('quarter', datum)::DATE - 1))::date,'id')::int))
				end
		else
			case
				when
					to_char(DATE_TRUNC('quarter', datum)::DATE,'id')::int <= 4
					then
						datum - (DATE_TRUNC('quarter', datum)::DATE - to_char(DATE_TRUNC('quarter', datum)::DATE,'id')::int) + 1
				when
					to_char(DATE_TRUNC('quarter', datum)::DATE,'id')::int > 4
					then
						datum - (DATE_TRUNC('quarter', datum)::DATE + (7 - to_char(DATE_TRUNC('quarter', datum)::DATE,'id')::int))
			end	
	end as day_of_quarter_2
	,case
		when
			datum >= (DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE - to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'d')::int + 1
			and
			datum <= (DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE
			and
			to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'d')::int < 4
			then
				to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'d')::int
		when
			datum >= DATE_TRUNC('quarter', datum)::DATE
			and
			datum <= DATE_TRUNC('quarter', datum)::DATE + (7 - to_char(DATE_TRUNC('quarter', datum)::DATE,'d')::int)
			and
			to_char(DATE_TRUNC('quarter', datum)::DATE,'d')::int > 4
			then
				case
					when
						to_char(date_trunc('quarter',(DATE_TRUNC('quarter', datum)::DATE - 1))::date,'d')::int > 4
						then
							datum - (date_trunc('quarter',(DATE_TRUNC('quarter', datum)::DATE - 1))::date - to_char(date_trunc('quarter',(DATE_TRUNC('quarter', datum)::DATE - 1))::date,'d')::int + 1) + 1
					when
						to_char(date_trunc('quarter',(DATE_TRUNC('quarter', datum)::DATE - 1))::date,'d')::int <= 4
						then
							datum - (date_trunc('quarter',(DATE_TRUNC('quarter', datum)::DATE - 1))::date + (7 - to_char(date_trunc('quarter',(DATE_TRUNC('quarter', datum)::DATE - 1))::date,'d')::int))
				end
		else
			case
				when
					to_char(DATE_TRUNC('quarter', datum)::DATE,'d')::int <= 4
					then
						datum - (DATE_TRUNC('quarter', datum)::DATE - to_char(DATE_TRUNC('quarter', datum)::DATE,'d')::int) + 1
				when
					to_char(DATE_TRUNC('quarter', datum)::DATE,'d')::int > 4
					then
						datum - (DATE_TRUNC('quarter', datum)::DATE + (7 - to_char(DATE_TRUNC('quarter', datum)::DATE,'d')::int))
			end	
	end as day_of_quarter_3
	,EXTRACT(DOY FROM datum)::int AS day_of_year_1
	,to_char(datum,'IDDD')::int as day_of_year_2
	,case
		when
			datum >= TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') - to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'d')::int + 1
			and
			datum <= TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD')
			and
			to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'d')::int < 4
			then
				to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'d')::int
		when
			datum >= date_trunc('year',datum)::date
			and
			datum <= date_trunc('year',datum)::date + (7 - to_char(date_trunc('year',datum)::date,'d')::int)
			and
			to_char(date_trunc('year',datum)::date,'d')::int > 4
			then
				case
					when 
						to_char(date_trunc('year',(date_trunc('year',datum)::date - 1))::date,'d')::int <= 4
						then
							datum - (date_trunc('year',(date_trunc('year',datum)::date - 1))::date - to_char(date_trunc('year',(date_trunc('year',datum)::date - 1))::date,'d')::int + 1) + 1
					when
						to_char(date_trunc('year',(date_trunc('year',datum)::date - 1))::date,'d')::int > 4
						then
							datum - (date_trunc('year',(date_trunc('year',datum)::date - 1))::date + (7 - to_char(date_trunc('year',(date_trunc('year',datum)::date - 1))::date,'d')::int))
				end
		else	
			case
				when
					to_char(date_trunc('year',datum)::date,'d')::int <= 4
					then
						datum - (date_trunc('year',datum)::date - (to_char(date_trunc('year',datum)::date,'d')::int - 1))
				when
					to_char(date_trunc('year',datum)::date,'d')::int > 4
					then
						datum - (date_trunc('year',datum)::date + (7 - to_char(date_trunc('year',datum)::date,'d')::int))
			end
	end as day_of_year_3
	-- week started from day one of month. first day is monday.
	,case
		when
			datum >= date_trunc('month',datum)::date
			and
			datum <= date_trunc('month',datum)::date + (7 - EXTRACT(ISODOW FROM date_trunc('month',datum))::int)
			then
				1
		else
			ceil((datum - (date_trunc('month',datum)::date + (7 - extract(isodow from date_trunc('month',datum)::date)::int)))/7::float)::int + 1
	end AS week_of_month_1 
	-- week started from day one of month. first day is sunnday.
	,case
		when
			datum >= date_trunc('month',datum)::date
			and
			datum <= date_trunc('month',datum)::date + (7 - TO_CHAR(date_trunc('month',datum)::date ,'D')::INT)
			then
				1
		else
			ceil((datum - (date_trunc('month',datum)::date + (7 - TO_CHAR(date_trunc('month',datum)::date,'D')::INT)))/7::float)::int + 1
	end as week_of_month_2
	-- based on iso 8601, starting day from monday
	,case
		when 
			datum >= date_trunc('month',datum)::date
			and
			datum <= date_trunc('month',datum)::date + (7 - EXTRACT(ISODOW FROM date_trunc('month',datum))::int)
			then
				case
					when
						EXTRACT(ISODOW FROM (date_trunc('month',datum))) <= 4
						then
							1
					when
						EXTRACT(ISODOW FROM date_trunc('month',datum)::date) > 4
						then
							case
								when
									extract(isodow from ((date_trunc('month',datum)::date - 1) + (1 - EXTRACT(DAY FROM(date_trunc('month',datum)::date - 1)))::INT)) <= 4
									then
										ceil(((date_trunc('month',datum)::date - 1) - ((date_trunc('month',datum)::date - 1) + (1 - EXTRACT(DAY FROM (date_trunc('month',datum)::date - 1)))::INT + (7 - extract(isodow from((date_trunc('month',datum)::date - 1) + (1 - EXTRACT(DAY FROM (date_trunc('month',datum)::date - 1)))::INT))::int)))/7::float) + 1
								when
									extract(isodow from ((date_trunc('month',datum)::date - 1) + (1 - EXTRACT(DAY FROM(date_trunc('month',datum)::date - 1)))::INT)) > 4
									then
										ceil(((date_trunc('month',datum)::date - 1) - ((date_trunc('month',datum)::date - 1) + (1 - EXTRACT(DAY FROM (date_trunc('month',datum)::date - 1)))::INT + (7 - extract(isodow from((date_trunc('month',datum)::date - 1) + (1 - EXTRACT(DAY FROM (date_trunc('month',datum)::date - 1)))::INT))::int)))/7::float)
							end
				end
		when 
			datum >= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE))::int + 1
			and 
			datum <= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE
			then
				case 
					when 
						EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE)) < 4
						then
							1
					when
						EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE)) >= 4
						then
							case
								when
									EXTRACT(ISODOW FROM date_trunc('month',datum)::date) <= 4
									then
										ceil((datum - (date_trunc('month',datum)::date + (7 - extract(isodow from date_trunc('month',datum)::date)::int)))/7::float) + 1
								when
									EXTRACT(ISODOW FROM date_trunc('month',datum)::date) > 4
									then
										ceil((datum - (date_trunc('month',datum)::date + (7 - extract(isodow from date_trunc('month',datum)::date)::int)))/7::float)
							end		
				end	
		when
			EXTRACT(ISODOW FROM date_trunc('month',datum)::date) > 4
			then
				ceil((datum - (date_trunc('month',datum)::date + (7 - extract(isodow from date_trunc('month',datum)::date)::int)))/7::float)
		when
			EXTRACT(ISODOW FROM date_trunc('month',datum)) <= 4
			then
				ceil((datum - (date_trunc('month',datum)::date + (7 - extract(isodow from date_trunc('month',datum)::date)::int)))/7::float) + 1
	end::int as week_of_month_3
	-- based on iso 8601, starting day from sunday
	,case
		when 
			datum >= date_trunc('month',datum)::date
			and
			datum <= date_trunc('month',datum)::date + (7 - ((EXTRACT(ISODOW FROM date_trunc('month',datum))::int % 7) + 1))::int
			then
				case
					when
						((EXTRACT(ISODOW FROM date_trunc('month',datum))::int % 7) + 1) <= 4
						then
							1
					when
						((EXTRACT(ISODOW FROM date_trunc('month',datum))::int % 7) + 1) > 4
						then
							case
								when
									(extract(isodow from ((date_trunc('month',datum)::date - 1) + (1 - EXTRACT(DAY FROM(date_trunc('month',datum)::Date - 1)))::INT)) % 7) + 1 <= 4
									then
										ceil(((date_trunc('month',datum)::date - 1) - ((date_trunc('month',datum)::date - 1) + (1 - EXTRACT(DAY FROM (date_trunc('month',datum)::date - 1)))::INT + (7 - ((extract(isodow from((date_trunc('month',datum)::date - 1) + (1 - EXTRACT(DAY FROM (date_trunc('month',datum)::Date - 1)))::INT))::int % 7) + 1))))/7::float) + 1
								when
									((extract(isodow from ((date_trunc('month',datum)::date - 1) + (1 - EXTRACT(DAY FROM(date_trunc('month',datum)::date - 1)))::INT)) % 7) + 1)> 4
									then
										ceil(((date_trunc('month',datum)::date - 1) - ((date_trunc('month',datum)::date - 1) + (1 - EXTRACT(DAY FROM (date_trunc('month',datum)::date - 1)))::INT + (7 - ((extract(isodow from((date_trunc('month',datum)::date - 1) + (1 - EXTRACT(DAY FROM (date_trunc('month',datum)::date - 1)))::INT))::int % 7) + 1))))/7::float)
							end		
				end
		when
			datum >= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - ((EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE))::int % 7) + 1) + 1
			and 
			datum <= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE
			then 
				case 
					when
						((EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE))::int % 7) + 1) < 4
						then
							1
					when
						((EXTRACT(ISODOW FROM ((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE)) % 7) + 1) >= 4
						then
							case
								when
									((EXTRACT(ISODOW FROM date_trunc('month',datum)::date) % 7) + 1) <= 4
									then
										ceil((datum - (date_trunc('month',datum)::date + (7 - ((extract(isodow from date_trunc('month',datum))::int % 7) + 1))))/7::float) + 1
								when
									((EXTRACT(ISODOW FROM date_trunc('month',datum)::date) % 7) + 1) > 4
									then
										ceil((datum - (date_trunc('month',datum)::date + (7 - ((extract(isodow from date_trunc('month',datum))::int % 7) + 1))))/7::float)
							end	
				end	
		when
			((EXTRACT(ISODOW FROM date_trunc('month',datum)) % 7) + 1) > 4
			then
				ceil((datum - (date_trunc('month',datum)::date+ (7 - ((extract(isodow from date_trunc('month',datum))::int % 7) + 1))))/7::float)
		when
			((EXTRACT(ISODOW FROM date_trunc('month',datum)) % 7) + 1) <= 4
			then
				ceil((datum - (date_trunc('month',datum)::date + (7 - ((extract(isodow from date_trunc('month',datum))::INT % 7) + 1))))/7::float) + 1
	end::int as week_of_month_4
	,TO_CHAR(datum, 'W')::INT as week_of_month_5
	,case
		when
			datum >= date_trunc('quarter',datum)::date
			and
			datum <= date_trunc('quarter',datum)::date + (7 - extract(isodow from date_trunc('quarter',datum)::date)::int)
			then
				1
	else
		ceil((datum - (date_trunc('quarter',datum)::date + (7 - extract(isodow from date_trunc('quarter',datum)::date)::int))) / 7::float)::int + 1
	end as week_of_quarter_1
	,case
		when
			datum >= date_trunc('quarter',datum)::date
			and
			datum <= date_trunc('quarter',datum)::date + (7 - extract(dow from date_trunc('quarter',datum)::date)::int)
			then
				1
	else
		ceil((datum - (date_trunc('quarter',datum)::date + (7 - extract(dow from date_trunc('quarter',datum)::date)::int))) / 7::float)::int + 1
	end as week_of_quarter_2
		,case
		when 
			datum >= date_trunc('quarter',datum)::date
			and
			datum <= date_trunc('quarter',datum)::date + (7 - to_char(date_trunc('quarter',datum)::date,'id')::int)
			then
				case
					when
						to_char(date_trunc('quarter',datum)::date,'id')::int <= 4
						then
							1
					when
						to_char(date_trunc('quarter',datum)::date,'id')::int > 4
						then
							case
								when
									to_char(date_trunc('quarter',(date_trunc('quarter',datum)::date - 1))::date,'id')::int <= 4
									then
										ceil((datum - (date_trunc('quarter',(date_trunc('quarter',datum)::date - 1))::date - to_char(date_trunc('quarter',(date_trunc('quarter',datum)::date - 1))::date,'id')::int )) / 7::float)::int
								when
									to_char(date_trunc('quarter',(date_trunc('quarter',datum)::date - 1))::date,'id')::int > 4
									then
										ceil((datum - (date_trunc('quarter',(date_trunc('quarter',datum)::date - 1))::date + (7 - to_char(date_trunc('quarter',(date_trunc('quarter',datum)::date - 1))::date,'id')::int))) / 7::float)::int
							end
				end
		when 
			datum >= (DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE - to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'id')::int + 1
			and 
			datum <= (DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE
			then
				case 
					when 
						to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'id')::int < 4
						then
							1
					when
						to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'id')::int >= 4
						then
							case
								when
									to_char(DATE_TRUNC('quarter', datum)::date,'id')::int <= 4
									then
										ceil((datum - (DATE_TRUNC('quarter', datum)::date - to_char(DATE_TRUNC('quarter', datum)::date,'id')::int)) / 7::float)::int
								when
									to_char(DATE_TRUNC('quarter', datum)::date,'id')::int > 4
									then
										ceil((datum - (DATE_TRUNC('quarter', datum)::date + (7 - to_char(DATE_TRUNC('quarter', datum)::date,'id')::int))) / 7::float)::int
							end		
				end	
		when
			to_char(date_trunc('quarter',datum)::date,'id')::int > 4
			then
				ceil((datum - (DATE_TRUNC('quarter', datum)::date + (7 - to_char(DATE_TRUNC('quarter', datum)::date,'id')::int))) / 7::float)::int
		when
			to_char(date_trunc('quarter',datum)::date,'id')::int <= 4
			then
				ceil((datum - (DATE_TRUNC('quarter', datum)::date - to_char(DATE_TRUNC('quarter', datum)::date,'id')::int)) / 7::float)::int
	end::int as week_of_quarter_3
		,case
		when 
			datum >= date_trunc('quarter',datum)::date
			and
			datum <= date_trunc('quarter',datum)::date + (7 - to_char(date_trunc('quarter',datum)::date,'d')::int)
			then
				case
					when
						to_char(date_trunc('quarter',datum)::date,'d')::int <= 4
						then
							1
					when
						to_char(date_trunc('quarter',datum)::date,'d')::int > 4
						then
							case
								when
									to_char(date_trunc('quarter',(date_trunc('quarter',datum)::date - 1))::date,'d')::int <= 4
									then
										ceil((datum - (date_trunc('quarter',(date_trunc('quarter',datum)::date - 1))::date - to_char(date_trunc('quarter',(date_trunc('quarter',datum)::date - 1))::date,'d')::int )) / 7::float)::int
								when
									to_char(date_trunc('quarter',(date_trunc('quarter',datum)::date - 1))::date,'d')::int > 4
									then
										ceil((datum - (date_trunc('quarter',(date_trunc('quarter',datum)::date - 1))::date + (7 - to_char(date_trunc('quarter',(date_trunc('quarter',datum)::date - 1))::date,'d')::int))) / 7::float)::int
							end
				end
		when 
			datum >= (DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE - to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'d')::int + 1
			and 
			datum <= (DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE
			then
				case 
					when 
						to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'d')::int < 4
						then
							1
					when
						to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'d')::int >= 4
						then
							case
								when
									to_char(DATE_TRUNC('quarter', datum)::date,'d')::int <= 4
									then
										ceil((datum - (DATE_TRUNC('quarter', datum)::date - to_char(DATE_TRUNC('quarter', datum)::date,'d')::int)) / 7::float)::int
								when
									to_char(DATE_TRUNC('quarter', datum)::date,'d')::int > 4
									then
										ceil((datum - (DATE_TRUNC('quarter', datum)::date + (7 - to_char(DATE_TRUNC('quarter', datum)::date,'d')::int))) / 7::float)::int
							end		
				end	
		when
			to_char(date_trunc('quarter',datum)::date,'d')::int > 4
			then
				ceil((datum - (DATE_TRUNC('quarter', datum)::date + (7 - to_char(DATE_TRUNC('quarter', datum)::date,'d')::int))) / 7::float)::int
		when
			to_char(date_trunc('quarter',datum)::date,'d')::int <= 4
			then
				ceil((datum - (DATE_TRUNC('quarter', datum)::date - to_char(DATE_TRUNC('quarter', datum)::date,'d')::int)) / 7::float)::int
	end::int as week_of_quarter_4
	,ceil(to_char(datum,'q')::int / 7)::int as week_of_quarter_5
	,case
		when
			datum >= date_trunc('year',datum)::date
			and
			datum <= date_trunc('year',datum)::date + (7 - extract(isodow from date_trunc('year',datum)::date)::int)
			then
				1
		else
			ceil((datum - (date_trunc('year',datum)::date + (7 - extract(isodow from date_trunc('year',datum)::date)::int))) / 7::float)::int + 1
	end as "week_of_year_1"
	,case
		when
			datum >= date_trunc('year',datum)::date
			and
			datum <= date_trunc('year',datum)::date + (7 - to_char(date_trunc('year',datum)::date,'D')::int)
			then
				1
		else
			ceil((datum - (date_trunc('year',datum)::date + (7 - to_char(date_trunc('year',datum)::date,'D')::int))) / 7::float)::int + 1
	end as "week_of_year_2"
	-- iso 8601, middle day in thursday because a week starting from monday, first and last week decision based on thursday
	,EXTRACT(WEEK FROM datum)::int AS "week_of_year_3" 
	-- based on iso 8601 weak of year rule but with middle week at wednesday rather than thursday because day starting from sunday
	,case
		-- condition for days from week that have mixed days from next year
		when
			datum >= TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') - to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'d')::int
			and
			datum <= TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD')
			then
				case
					when
						to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'d')::int >= 4
						then
							EXTRACT(WEEK FROM datum)::int
					when
						to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'d')::int < 4
						then
							1
				end
		-- condition for days from week that have mixed days from last year
		when
			datum <= date_trunc('Year',datum)::date + (7 - to_char(date_trunc('Year',datum),'d')::int)
			and
			datum >= date_trunc('Year',datum)
			then
				case 
					when
						to_char(date_trunc('Year',datum),'d')::int <= 4
						then
							1
					when
						to_char(date_trunc('Year',datum),'d')::int > 4
						then
							EXTRACT(WEEK FROM (TO_DATE((EXTRACT(YEAR FROM datum)  - 1) || '-12-31', 'YYYY-MM-DD')))::int
				end
		when
			datum > date_trunc('Year',datum)::date + (7 - to_char(date_trunc('Year',datum),'d')::int)
			and
			datum < TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') - to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'d')::int
			then
				case
					when
						to_char(date_trunc('Year',datum),'d')::int <= 4
						then
							case
								when
									to_char(datum,'d')::int = 1
									then
										extract(week from datum)::int + 1
								else
									extract(week from datum)::int
							end
					when
						to_char(date_trunc('Year',datum),'d')::int > 4
						then
							case
								when
									to_char(datum,'d')::int = 1
									then
										extract(week from datum)::int
								else
									extract(week from datum)::int - 1
							end		
				end	
	end as "week_of_year_4" 
	,ceil(extract(doy from datum) / 7::float)::int as "week_of_year_5"
	,TO_CHAR(datum, 'TMMonth') AS month_actual_name
	,case
		when 
			EXTRACT(MONTH FROM datum)::int in (1,4,7,10)
			then
				1
		when
			EXTRACT(MONTH FROM datum)::int in (2,5,6,11)
			then
				2
		else
			3
	end as month_of_quarter_1
	,case
		when 
			case
				when
					datum >= date_trunc('month',datum)::date
					and
					datum <= date_trunc('month',datum)::date + (7 - to_char(date_trunc('month',datum)::date,'id')::int)
					then
						case
							when
								to_char(date_trunc('month',datum)::date,'id')::int <= 4
								then
									to_char(date_trunc('month',datum)::date,'mm')::int
							when
								to_char(date_trunc('month',datum)::date,'id')::int > 4
								then
									to_char((date_trunc('month',datum)::date - 1),'mm')::int
						end
				when
					datum >= (date_trunc('month',datum) + interval '1 month - 1 day')::date - to_char((date_trunc('month',datum) + interval '1 month - 1 day')::date,'id')::int + 1
					and
					datum <= (date_trunc('month',datum) + interval '1 month - 1 day')::date
					then
						case
							when
								to_char((date_trunc('month',datum) + interval '1 month - 1 day')::date,'id')::int < 4
								then
									to_char(((date_trunc('month',datum) + interval '1 month - 1 day')::date + 1),'mm')::int
							when
								to_char((date_trunc('month',datum) + interval '1 month - 1 day')::date,'id')::int >= 4
								then
									to_char(date_trunc('month',datum),'mm')::int
						end
				else
					to_char(date_trunc('month',datum)::date,'mm')::int
			end in (1,4,7,10)
			then
				1
		when
						case
				when
					datum >= date_trunc('month',datum)::date
					and
					datum <= date_trunc('month',datum)::date + (7 - to_char(date_trunc('month',datum)::date,'id')::int)
					then
						case
							when
								to_char(date_trunc('month',datum)::date,'id')::int <= 4
								then
									to_char(date_trunc('month',datum)::date,'mm')::int
							when
								to_char(date_trunc('month',datum)::date,'id')::int > 4
								then
									to_char((date_trunc('month',datum)::date - 1),'mm')::int
						end
				when
					datum >= (date_trunc('month',datum) + interval '1 month - 1 day')::date - to_char((date_trunc('month',datum) + interval '1 month - 1 day')::date,'id')::int + 1
					and
					datum <= (date_trunc('month',datum) + interval '1 month - 1 day')::date
					then
						case
							when
								to_char((date_trunc('month',datum) + interval '1 month - 1 day')::date,'id')::int < 4
								then
									to_char(((date_trunc('month',datum) + interval '1 month - 1 day')::date + 1),'mm')::int
							when
								to_char((date_trunc('month',datum) + interval '1 month - 1 day')::date,'id')::int >= 4
								then
									to_char(date_trunc('month',datum),'mm')::int
						end
				else
					to_char(date_trunc('month',datum)::date,'mm')::int
			end in (2,5,6,11)
			then
				2
		else
			3
	end as month_of_quarter_2
	,case
		when 
			case
				when
					datum >= date_trunc('month',datum)::date
					and
					datum <= date_trunc('month',datum)::date + (7 - to_char(date_trunc('month',datum)::date,'d')::int)
					then
						case
							when
								to_char(date_trunc('month',datum)::date,'d')::int <= 4
								then
									to_char(date_trunc('month',datum)::date,'mm')::int
							when
								to_char(date_trunc('month',datum)::date,'d')::int > 4
								then
									to_char((date_trunc('month',datum)::date - 1),'mm')::int
						end
				when
					datum >= (date_trunc('month',datum) + interval '1 month - 1 day')::date - to_char((date_trunc('month',datum) + interval '1 month - 1 day')::date,'d')::int + 1
					and
					datum <= (date_trunc('month',datum) + interval '1 month - 1 day')::date
					then
						case
							when
								to_char((date_trunc('month',datum) + interval '1 month - 1 day')::date,'d')::int < 4
								then
									to_char(((date_trunc('month',datum) + interval '1 month - 1 day')::date + 1),'mm')::int
							when
								to_char((date_trunc('month',datum) + interval '1 month - 1 day')::date,'d')::int >= 4
								then
									to_char(date_trunc('month',datum),'mm')::int
						end
				else
					to_char(date_trunc('month',datum)::date,'mm')::int
			end in (1,4,7,10)
			then
				1
		when
						case
				when
					datum >= date_trunc('month',datum)::date
					and
					datum <= date_trunc('month',datum)::date + (7 - to_char(date_trunc('month',datum)::date,'d')::int)
					then
						case
							when
								to_char(date_trunc('month',datum)::date,'d')::int <= 4
								then
									to_char(date_trunc('month',datum)::date,'mm')::int
							when
								to_char(date_trunc('month',datum)::date,'d')::int > 4
								then
									to_char((date_trunc('month',datum)::date - 1),'mm')::int
						end
				when
					datum >= (date_trunc('month',datum) + interval '1 month - 1 day')::date - to_char((date_trunc('month',datum) + interval '1 month - 1 day')::date,'d')::int + 1
					and
					datum <= (date_trunc('month',datum) + interval '1 month - 1 day')::date
					then
						case
							when
								to_char((date_trunc('month',datum) + interval '1 month - 1 day')::date,'d')::int < 4
								then
									to_char(((date_trunc('month',datum) + interval '1 month - 1 day')::date + 1),'mm')::int
							when
								to_char((date_trunc('month',datum) + interval '1 month - 1 day')::date,'d')::int >= 4
								then
									to_char(date_trunc('month',datum),'mm')::int
						end
				else
					to_char(date_trunc('month',datum)::date,'mm')::int
			end in (2,5,6,11)
			then
				2
		else
			3
	end as month_of_quarter_3
	,EXTRACT(MONTH FROM datum)::int AS month_of_year_1
	,case
		when
			datum >= date_trunc('month',datum)::date
			and
			datum <= date_trunc('month',datum)::date + (7 - to_char(date_trunc('month',datum)::date,'id')::int)
			then
				case
					when
						to_char(date_trunc('month',datum)::date,'id')::int <= 4
						then
							to_char(date_trunc('month',datum)::date,'mm')::int
					when
						to_char(date_trunc('month',datum)::date,'id')::int > 4
						then
							to_char((date_trunc('month',datum)::date - 1),'mm')::int
				end
		when
			datum >= (date_trunc('month',datum) + interval '1 month - 1 day')::date - to_char((date_trunc('month',datum) + interval '1 month - 1 day')::date,'id')::int + 1
			and
			datum <= (date_trunc('month',datum) + interval '1 month - 1 day')::date
			then
				case
					when
						to_char((date_trunc('month',datum) + interval '1 month - 1 day')::date,'id')::int < 4
						then
							to_char(((date_trunc('month',datum) + interval '1 month - 1 day')::date + 1),'mm')::int
					when
						to_char((date_trunc('month',datum) + interval '1 month - 1 day')::date,'id')::int >= 4
						then
							to_char(date_trunc('month',datum),'mm')::int
				end
		else
			to_char(date_trunc('month',datum)::date,'mm')::int
	end as month_of_year_2
	,case
		when
			datum >= date_trunc('month',datum)::date
			and
			datum <= date_trunc('month',datum)::date + (7 - to_char(date_trunc('month',datum)::date,'d')::int)
			then
				case
					when
						to_char(date_trunc('month',datum)::date,'d')::int <= 4
						then
							to_char(date_trunc('month',datum)::date,'mm')::int
					when
						to_char(date_trunc('month',datum)::date,'d')::int > 4
						then
							to_char((date_trunc('month',datum)::date - 1),'mm')::int
				end
		when
			datum >= (date_trunc('month',datum) + interval '1 month - 1 day')::date - to_char((date_trunc('month',datum) + interval '1 month - 1 day')::date,'d')::int + 1
			and
			datum <= (date_trunc('month',datum) + interval '1 month - 1 day')::date
			then
				case
					when
						to_char((date_trunc('month',datum) + interval '1 month - 1 day')::date,'d')::int < 4
						then
							to_char(((date_trunc('month',datum) + interval '1 month - 1 day')::date + 1),'mm')::int
					when
						to_char((date_trunc('month',datum) + interval '1 month - 1 day')::date,'d')::int >= 4
						then
							to_char(date_trunc('month',datum),'mm')::int
				end
		else
			to_char(date_trunc('month',datum)::date,'mm')::int
	end as month_of_year_3
	,EXTRACT(QUARTER FROM datum)::int AS quarter_1
	,case
		when
			datum >= date_trunc('quarter',datum)::date
			and
			datum <= date_trunc('quarter',datum)::date + (7 - to_char(date_trunc('quarter',datum)::date,'id')::int)
			then
				case
					when
						to_char(date_trunc('quarter',datum)::date,'id')::int <= 4
						then
							to_char(datum,'q')::int
					when
						to_char(date_trunc('quarter',datum)::date,'id')::int > 4
						then
							to_char((date_trunc('quarter',datum)::date - 1),'q')::int
				end
		when
			datum >= (date_trunc('quarter',datum) + interval '1 month - 1 day')::date - to_char((date_trunc('quarter',datum) + interval '1 month - 1 day')::date,'id')::int + 1
			and
			datum <= (date_trunc('quarter',datum) + interval '1 month - 1 day')::date
			then
				case
					when
						to_char((date_trunc('quarter',datum) + interval '1 month - 1 day')::date,'id')::int >= 4
						then
							to_char(datum,'q')::int
					when
						to_char((date_trunc('quarter',datum) + interval '1 month - 1 day')::date,'id')::int < 4
						then
							to_char((date_trunc('quarter',datum) + interval '1 month')::date,'q')::int
				end
		else
			to_char(datum,'q')::int
	end as quarter_2
	,case
		when
			datum >= date_trunc('quarter',datum)::date
			and
			datum <= date_trunc('quarter',datum)::date + (7 - to_char(date_trunc('quarter',datum)::date,'d')::int)
			then
				case
					when
						to_char(date_trunc('quarter',datum)::date,'d')::int <= 4
						then
							to_char(datum,'q')::int
					when
						to_char(date_trunc('quarter',datum)::date,'d')::int > 4
						then
							to_char((date_trunc('quarter',datum)::date - 1),'q')::int
				end
		when
			datum >= (date_trunc('quarter',datum) + interval '1 month - 1 day')::date - to_char((date_trunc('quarter',datum) + interval '1 month - 1 day')::date,'d')::int + 1
			and
			datum <= (date_trunc('quarter',datum) + interval '1 month - 1 day')::date
			then
				case
					when
						to_char((date_trunc('quarter',datum) + interval '1 month - 1 day')::date,'d')::int >= 4
						then
							to_char(datum,'q')::int
					when
						to_char((date_trunc('quarter',datum) + interval '1 month - 1 day')::date,'d')::int < 4
						then
							to_char((date_trunc('quarter',datum) + interval '1 month')::date,'q')::int
				end
		else
			to_char(datum,'q')::int
	end as quarter_3
	,EXTRACT(YEAR FROM datum)::int AS year_actual
	,case
		when
			datum >= date_trunc('month',datum)::date
			and
			datum <= date_trunc('month',datum)::date + (7 - to_char(date_trunc('month',datum)::date,'id')::int)
			then
				date_trunc('month',datum)::date
		else
			datum + (1 - EXTRACT(ISODOW FROM datum))::INT
	end first_day_of_week_1
	,case
		when
			datum >= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - (to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'id')::int + 1)
			and
			datum <= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE
			then
				(DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE
		else
			datum + (7 - EXTRACT(ISODOW FROM datum))::INT
	end last_day_of_week_1
	,case
		when
			datum >= date_trunc('month',datum)::date
			and
			datum <= date_trunc('month',datum)::date + (7 - to_char(date_trunc('month',datum)::date,'d')::int)
			then
				date_trunc('month',datum)::date
		else
			datum + (1 - ((EXTRACT(ISODOW FROM datum) % 7) + 1))::INT
	end first_day_of_week_2
	,case
		when
			datum >= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - (to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'d')::int + 1)
			and
			datum <= (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE
			then
				(DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE
		else
			datum + (7 - ((EXTRACT(ISODOW FROM datum) % 7) + 1))::INT
	end last_day_of_week_2
	,datum + (1 - EXTRACT(ISODOW FROM datum))::INT AS "first_day_of_week_3" -- iso 8601, week of year and day starting from monday
	,datum + (7 - EXTRACT(ISODOW FROM datum))::INT AS "last_day_of_week_3" -- iso 8601, about week of year and day starting from monday
	,datum + (1 - ((EXTRACT(ISODOW FROM datum) % 7) + 1))::INT as "first_day_of_week_4" -- based on iso 8601 weak of year rule but with middle week at wednesday rather than thursday because day starting from sunday
	,datum + (7 - ((EXTRACT(ISODOW FROM datum) % 7) + 1))::INT as "last_day_of_week_4" -- based on iso 8601 weak of year rule but with middle week at wednesday rather than thursday because day starting from sunday
	,date_trunc('month',datum)::date AS first_day_of_month_1
	,(DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE AS last_day_of_month_1
	,case
		when
			to_char(date_trunc('month',datum)::date,'ID')::int <= 4
			then
				date_trunc('month',datum)::date - to_char(date_trunc('month',datum)::date,'ID')::int + 1
		when
			to_char(date_trunc('month',datum)::date,'ID')::int > 4
			then
				date_trunc('month',datum)::date + (7 - to_char(date_trunc('month',datum)::date,'ID')::int) + 1
	end as first_day_of_month_2
	,case
		when
			to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'ID')::int >= 4
			then
				(DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE + (7 - to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'ID')::int)
		when
			to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'ID')::int < 4
			then
				(DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - (to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'ID')::int + 1)
	end as last_day_of_month_2
	,case
		when
			to_char(date_trunc('month',datum)::date,'D')::int <= 4
			then
				date_trunc('month',datum)::date - to_char(date_trunc('month',datum)::date,'D')::int + 1
		when
			to_char(date_trunc('month',datum)::date,'D')::int > 4
			then
				date_trunc('month',datum)::date + (7 - to_char(date_trunc('month',datum)::date,'D')::int) + 1
	end as first_day_of_month_3
	,case
		when
			to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'d')::int >= 4
			then
				(DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE + (7 - to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'d')::int)
		when
			to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'d')::int < 4
			then
				(DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - (to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'d')::int + 1)
	end as last_day_of_month_3
	,DATE_TRUNC('quarter', datum)::DATE AS first_day_of_quarter_1
	,(DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE AS last_day_of_quarter_1
	,case
		when
			to_char(DATE_TRUNC('quarter', datum)::DATE,'id')::int <= 4
			then
				DATE_TRUNC('quarter', datum)::DATE - to_char(DATE_TRUNC('quarter', datum)::DATE,'id')::int + 1
		when
			to_char(DATE_TRUNC('quarter', datum)::DATE,'id')::int > 4
			then
				DATE_TRUNC('quarter', datum)::DATE + (7 - to_char(DATE_TRUNC('quarter', datum)::DATE,'id')::int) + 1
	end as first_day_of_quarter_2
	,case
		when
			to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'id')::int < 4
			then
				(DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE - to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'id')::int
		when
			to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'id')::int >= 4
			then
				(DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE + (7 - to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'id')::int) + 1
	end last_day_of_quarter_2
	,case
		when
			to_char(DATE_TRUNC('quarter', datum)::DATE,'d')::int <= 4
			then
				DATE_TRUNC('quarter', datum)::DATE - to_char(DATE_TRUNC('quarter', datum)::DATE,'d')::int + 1
		when
			to_char(DATE_TRUNC('quarter', datum)::DATE,'d')::int > 4
			then
				DATE_TRUNC('quarter', datum)::DATE + (7 - to_char(DATE_TRUNC('quarter', datum)::DATE,'d')::int) + 1
	end as first_day_of_quarter_3
	,case
		when
			to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'d')::int < 4
			then
				(DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE - to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'d')::int
		when
			to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'d')::int >= 4
			then
				(DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE + (7 - to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'d')::int) + 1
	end last_day_of_quarter_3
	,date_trunc('Year',datum)::date AS first_day_of_year_1
	,TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') AS last_day_of_year_1
	,case
		when
			to_char(date_trunc('Year',datum)::date,'id')::int <= 4
			then
				date_trunc('Year',datum)::date - to_char(date_trunc('Year',datum)::date,'id')::int + 1
		when
			to_char(date_trunc('Year',datum)::date,'id')::int > 4
			then
				date_trunc('Year',datum)::date + (7 - to_char(date_trunc('Year',datum)::date,'id')::int) + 1
	end as first_day_of_year_2
	,case
		when
			to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'id')::int >= 4
			then
				TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') + (7 - to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'id')::int) + 1
		when
			to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'id')::int < 4
			then
				TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') - to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'id')::int
	end as last_day_of_year_2
	,case
		when
			to_char(date_trunc('Year',datum)::date,'d')::int <= 4
			then
				date_trunc('Year',datum)::date - to_char(date_trunc('Year',datum)::date,'d')::int + 1
		when
			to_char(date_trunc('Year',datum)::date,'d')::int > 4
			then
				date_trunc('Year',datum)::date + (7 - to_char(date_trunc('Year',datum)::date,'d')::int) + 1
	end as first_day_of_year_3
	,case
		when
			to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'d')::int >= 4
			then
				TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') + (7 - to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'d')::int) + 1
		when
			to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'d')::int < 4
			then
				TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') - to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'d')::int
	end as last_day_of_year_3
	,EXTRACT(day FROM (DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE)::int total_day_of_month_1
	,case
		when
			to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'id')::int < 4
			then
				case
					when
						to_char(date_trunc('month',datum)::date,'id')::int <= 4
						then
							((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'id')::int) - (date_trunc('month',datum)::date - to_char(date_trunc('month',datum)::date,'id')::int + 1) + 1
					when
						to_char(date_trunc('month',datum)::date,'id')::int > 4
						then
							((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'id')::int) - (date_trunc('month',datum)::date + (7 - to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'id')::int) + 1) + 1
				end
		when
			to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'id')::int >= 4
			then
				case
					when
						to_char(date_trunc('month',datum)::date,'id')::int <= 4
						then
							((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE + to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'id')::int) - (date_trunc('month',datum)::date - to_char(date_trunc('month',datum)::date,'id')::int + 1) + 1
					when
						to_char(date_trunc('month',datum)::date,'id')::int > 4
						then
							((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE + to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'id')::int) - (date_trunc('month',datum)::date + (7 - to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'id')::int) + 1) + 1
				end
	end as total_day_of_month_2
	,case
		when
			to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'d')::int < 4
			then
				case
					when
						to_char(date_trunc('month',datum)::date,'d')::int <= 4
						then
							((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'d')::int) - (date_trunc('month',datum)::date - to_char(date_trunc('month',datum)::date,'d')::int + 1) + 1
					when
						to_char(date_trunc('month',datum)::date,'d')::int > 4
						then
							((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'d')::int) - (date_trunc('month',datum)::date + (7 - to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'d')::int) + 1) + 1
				end
		when
			to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'d')::int >= 4
			then
				case
					when
						to_char(date_trunc('month',datum)::date,'d')::int <= 4
						then
							((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE + to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'d')::int) - (date_trunc('month',datum)::date - to_char(date_trunc('month',datum)::date,'d')::int + 1) + 1
					when
						to_char(date_trunc('month',datum)::date,'d')::int > 4
						then
							((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE + to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'d')::int) - (date_trunc('month',datum)::date + (7 - to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'d')::int) + 1) + 1
				end
	end as total_day_of_month_3
	,(DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE - DATE_TRUNC('quarter', (DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE)::DATE + 1 as total_day_of_quarter_1
	,case
		when
			to_char(date_trunc('quarter',(DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE)::date,'id')::int < 4
			then
				case
					when
						to_char(DATE_TRUNC('quarter', datum)::DATE,'id')::int <= 4
						then
							((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE - to_char(date_trunc('quarter',(DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE)::date,'id')::int) - (DATE_TRUNC('quarter', datum)::DATE - to_char(DATE_TRUNC('quarter', datum)::DATE,'id')::int + 1) + 1
					when
						to_char(DATE_TRUNC('quarter', datum)::DATE,'id')::int > 4
						then
							((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE - to_char(date_trunc('quarter',(DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE)::date,'id')::int) - (DATE_TRUNC('quarter', datum)::DATE + (7 - to_char(DATE_TRUNC('quarter', datum)::DATE,'id')::int + 1) + 1)
				end
		when
			to_char(date_trunc('quarter',(DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE)::date,'id')::int >= 4
			then
				case
					when
						to_char(DATE_TRUNC('quarter', datum)::DATE,'id')::int <= 4
						then
							((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE + to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'id')::int) - (DATE_TRUNC('quarter', datum)::DATE - to_char(DATE_TRUNC('quarter', datum)::DATE,'id')::int + 1) + 1
					when
						to_char(DATE_TRUNC('quarter', datum)::DATE,'id')::int > 4
						then
							((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE + to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'id')::int) - (DATE_TRUNC('quarter', datum)::DATE + (7 - to_char(DATE_TRUNC('quarter', datum)::DATE,'id')::int + 1) + 1)
				end
	end as total_day_of_quarter_2
	,case
		when
			to_char(date_trunc('quarter',(DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE)::date,'d')::int < 4
			then
				case
					when
						to_char(DATE_TRUNC('quarter', datum)::DATE,'d')::int <= 4
						then
							((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE - to_char(date_trunc('quarter',(DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE)::date,'d')::int) - (DATE_TRUNC('quarter', datum)::DATE - to_char(DATE_TRUNC('quarter', datum)::DATE,'d')::int + 1) + 1
					when
						to_char(DATE_TRUNC('quarter', datum)::DATE,'d')::int > 4
						then
							((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE - to_char(date_trunc('quarter',(DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE)::date,'d')::int) - (DATE_TRUNC('quarter', datum)::DATE + (7 - to_char(DATE_TRUNC('quarter', datum)::DATE,'d')::int + 1) + 1)
				end
		when
			to_char(date_trunc('quarter',(DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE)::date,'d')::int >= 4
			then
				case
					when
						to_char(DATE_TRUNC('quarter', datum)::DATE,'d')::int <= 4
						then
							((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE + to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'d')::int) - (DATE_TRUNC('quarter', datum)::DATE - to_char(DATE_TRUNC('quarter', datum)::DATE,'d')::int + 1) + 1
					when
						to_char(DATE_TRUNC('quarter', datum)::DATE,'d')::int > 4
						then
							((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE + to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'d')::int) - (DATE_TRUNC('quarter', datum)::DATE + (7 - to_char(DATE_TRUNC('quarter', datum)::DATE,'d')::int + 1) + 1)
				end
	end as total_day_of_quarter_3
	,to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'DDD')::int as total_day_of_year_1
	,case
		when
			to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'ID')::int < 4
			then
				case
					when
						to_char(date_trunc('year',datum)::date,'id')::int <= 4
						then
							(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') - to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'ID')::int) - (date_trunc('year',datum)::date - to_char(date_trunc('year',datum)::date,'id')::int + 1) + 1
					when
						to_char(date_trunc('year',datum)::date,'id')::int > 4
						then
							(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') - to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'ID')::int) - (date_trunc('year',datum)::date + (7 - to_char(date_trunc('year',datum)::date,'id')::int) + 1) + 1
				end
		when
			to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'ID')::int >= 4
			then
				case
					when
						to_char(date_trunc('year',datum)::date,'id')::int <= 4
						then
							(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') + (7 - to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'ID')::int)) - (date_trunc('year',datum)::date - to_char(date_trunc('year',datum)::date,'id')::int + 1) + 1
					when
						to_char(date_trunc('year',datum)::date,'id')::int > 4
						then
							(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') + (7 - to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'ID')::int)) - (date_trunc('year',datum)::date + (7 - to_char(date_trunc('year',datum)::date,'id')::int) + 1) + 1
				end
	end as total_day_of_year_2
	,case
		when
			to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'D')::int < 4
			then
				case
					when
						to_char(date_trunc('year',datum)::date,'d')::int <= 4
						then
							(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') - to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'D')::int) - (date_trunc('year',datum)::date - to_char(date_trunc('year',datum)::date,'d')::int + 1) + 1
					when
						to_char(date_trunc('year',datum)::date,'d')::int > 4
						then
							(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') - to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'D')::int) - (date_trunc('year',datum)::date + (7 - to_char(date_trunc('year',datum)::date,'d')::int) + 1) + 1
				end
		when
			to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'D')::int >= 4
			then
				case
					when
						to_char(date_trunc('year',datum)::date,'d')::int <= 4
						then
							(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') + (7 - to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'D')::int)) - (date_trunc('year',datum)::date - to_char(date_trunc('year',datum)::date,'d')::int + 1) + 1
					when
						to_char(date_trunc('year',datum)::date,'d')::int > 4
						then
							(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') + (7 - to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'D')::int)) - (date_trunc('year',datum)::date + (7 - to_char(date_trunc('year',datum)::date,'d')::int) + 1) + 1
				end
	end as total_day_of_year_3
	,ceil(((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - (date_trunc('month',datum)::date + (7 - TO_CHAR(date_trunc('month',datum)::date,'ID')::INT)))/7::float)::int + 1 as total_week_of_month_1
	,ceil(((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - (date_trunc('month',datum)::date + (7 - TO_CHAR(date_trunc('month',datum)::date,'D')::INT)))/7::float)::int + 1 as total_week_of_month_2
	,case
		when
			to_char(date_trunc('month',datum)::date,'id')::int <= 4
			then
				case
					when
						to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE ,'id')::int < 4
						then
							(((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE ,'id')::int) - (date_trunc('month',datum)::date - to_char(date_trunc('month',datum)::date,'id')::int)) / 7
					when
						to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE ,'id')::int >= 4
						then
							(((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE + (7 - to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE ,'id')::int)) - (date_trunc('month',datum)::date - to_char(date_trunc('month',datum)::date,'id')::int)) / 7
				end
		when
			to_char(date_trunc('month',datum)::date,'id')::int > 4
			then
				case
					when
						to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE ,'id')::int < 4
						then
							(((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE ,'id')::int) - (date_trunc('month',datum)::date + (7 - to_char(date_trunc('month',datum)::date,'id')::int))) / 7
					when
						to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE ,'id')::int >= 4
						then
							(((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE + (7 - to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE ,'id')::int)) - (date_trunc('month',datum)::date + (7 - to_char(date_trunc('month',datum)::date,'id')::int))) / 7
				end				
	end as total_week_of_month_3
	,case
		when
			to_char(date_trunc('month',datum)::date,'d')::int <= 4
			then
				case
					when
						to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE ,'d')::int < 4
						then
							(((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE ,'d')::int) - (date_trunc('month',datum)::date - to_char(date_trunc('month',datum)::date,'d')::int)) / 7
					when
						to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE ,'d')::int >= 4
						then
							(((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE + (7 - to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE ,'d')::int)) - (date_trunc('month',datum)::date - to_char(date_trunc('month',datum)::date,'d')::int)) / 7
				end
		when
			to_char(date_trunc('month',datum)::date,'d')::int > 4
			then
				case
					when
						to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE ,'d')::int < 4
						then
							(((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE - to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE ,'d')::int) - (date_trunc('month',datum)::date + (7 - to_char(date_trunc('month',datum)::date,'d')::int))) / 7
					when
						to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE ,'d')::int >= 4
						then
							(((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE + (7 - to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE ,'d')::int)) - (date_trunc('month',datum)::date + (7 - to_char(date_trunc('month',datum)::date,'d')::int))) / 7
				end				
	end as total_week_of_month_4
	,to_char((DATE_TRUNC('MONTH', datum) + INTERVAL '1 MONTH - 1 day')::DATE,'w')::int as total_week_of_month_5
	,ceil((((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE + (7 - to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'id')::int)) - (DATE_TRUNC('quarter', datum)::date - to_char(DATE_TRUNC('quarter', datum)::date,'id')::int )) / 7::float)::int as  total_week_of_quarter_1
	,ceil((((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE + (7 - to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'d')::int)) - (DATE_TRUNC('quarter', datum)::date - to_char(DATE_TRUNC('quarter', datum)::date,'d')::int )) / 7::float)::int as  total_week_of_quarter_2
	,case
		when
			to_char(date_trunc('quarter',datum)::date,'id')::int <= 4
			then
				case
					when
						to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'id')::int >= 4
						then
							ceil((((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE + (7 - to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'id')::int)) - (date_trunc('quarter',datum)::date - to_char(date_trunc('quarter',datum)::date,'id')::int)) / 7::float)::int
					when
						to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'id')::int < 4
						then
							ceil((((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE - to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'id')::int) - (date_trunc('quarter',datum)::date - to_char(date_trunc('quarter',datum)::date,'id')::int)) / 7::float)::int
				end
		when
			to_char(date_trunc('quarter',datum)::date,'id')::int > 4
			then
				case
					when
						to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'id')::int >= 4
						then
							ceil((((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE + (7 - to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'id')::int)) - (date_trunc('quarter',datum)::date + (7 - to_char(date_trunc('quarter',datum)::date,'id')::int) + 1)) / 7::float)::int
					when
						to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'id')::int < 4
						then
							ceil((((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE - to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'id')::int) - (date_trunc('quarter',datum)::date + (7 - to_char(date_trunc('quarter',datum)::date,'id')::int) + 1)) / 7::float)::int
				end
	end as total_week_of_quarter_3
	,case
		when
			to_char(date_trunc('quarter',datum)::date,'d')::int <= 4
			then
				case
					when
						to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'d')::int >= 4
						then
							ceil((((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE + (7 - to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'d')::int)) - (date_trunc('quarter',datum)::date - to_char(date_trunc('quarter',datum)::date,'d')::int)) / 7::float)::int
					when
						to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'d')::int < 4
						then
							ceil((((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE - to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'d')::int) - (date_trunc('quarter',datum)::date - to_char(date_trunc('quarter',datum)::date,'d')::int)) / 7::float)::int
				end
		when
			to_char(date_trunc('quarter',datum)::date,'d')::int > 4
			then
				case
					when
						to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'d')::int >= 4
						then
							ceil((((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE + (7 - to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'d')::int)) - (date_trunc('quarter',datum)::date + (7 - to_char(date_trunc('quarter',datum)::date,'d')::int) + 1)) / 7::float)::int
					when
						to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'d')::int < 4
						then
							ceil((((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE - to_char((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::DATE,'d')::int) - (date_trunc('quarter',datum)::date + (7 - to_char(date_trunc('quarter',datum)::date,'d')::int) + 1)) / 7::float)::int
				end
	end as total_week_of_quarter_4
	,ceil(((DATE_TRUNC('quarter', datum) + INTERVAL '3 MONTH - 1 day')::date - DATE_TRUNC('quarter', datum)::DATE  + 1) / 7::float)::int as total_week_of_quarter_5
	,((TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') + (7 - to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'id')::int)) - (date_trunc('year',datum)::date - to_char(date_trunc('year',datum)::date,'id')::int)) / 7 as total_week_of_year_1
	,((TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') + (7 - to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'d')::int)) - (date_trunc('year',datum)::date - to_char(date_trunc('year',datum)::date,'d')::int)) / 7 as total_week_of_year_2
	,case
		when
			EXTRACT(week from (TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'))) = 1
			then 
				EXTRACT(week from (TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') - 3))::int
		else
			EXTRACT(week from (TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD')))::int
	end as "total_week_of_year_3" -- based on iso 8601 about week of year
	,case
		when
			to_char(date_trunc('year',datum)::date,'d')::int <= 4
			then
				case
					when
						to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'d')::int >= 4
						then
							((TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') + (7 - to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'d')::int)) - (date_trunc('year',datum)::date - to_char(date_trunc('year',datum)::date,'d')::int)) / 7
					when
						to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'d')::int < 4
						then
							((TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') - to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'d')::int) - (date_trunc('year',datum)::date - to_char(date_trunc('year',datum)::date,'d')::int)) / 7
				end
		when
			to_char(date_trunc('year',datum)::date,'d')::int > 4
			then
				case
					when
						to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'d')::int >= 4
						then
							((TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') + (7 - to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'d')::int)) - (date_trunc('year',datum)::date + (7 - to_char(date_trunc('year',datum)::date,'d')::int))) / 7
					when
						to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'d')::int < 4
						then
							((TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD') - to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'d')::int) - (date_trunc('year',datum)::date + (7 - to_char(date_trunc('year',datum)::date,'d')::int))) / 7
				end
	end as total_week_of_year_4
	,to_char(TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'),'ww')::int as total_week_of_year_5
	,CASE
		WHEN 
			EXTRACT(ISODOW FROM datum) IN (6, 7)
			THEN 
				true
		ELSE 
			FALSE
	END AS "is_weekend" -- weekend at saturday and sunday
	,CASE
		WHEN 
			EXTRACT(DOY from (TO_DATE(EXTRACT(YEAR FROM datum) || '-12-31', 'YYYY-MM-DD'))) = 366
			THEN 
				true
		ELSE 
			false
	END AS "is_leap_year"
FROM 
	(SELECT 
		"day" + 1 as "id"
		,'1970-01-01'::DATE + SEQUENCE.DAY AS datum
	FROM 
		GENERATE_SERIES(0, 47846) AS SEQUENCE (DAY)) as list_date
;