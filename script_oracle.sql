SELECT
    DATE_COLUMN AS "date",
    TO_CHAR(DATE_COLUMN, 'YYYY-MM-DD') AS formatted_date,
    TO_CHAR(DATE_COLUMN, 'YYYY') AS year,
    TO_CHAR(DATE_COLUMN, 'MM') AS month,
    TO_CHAR(DATE_COLUMN, 'DD') AS day,
    TO_CHAR(DATE_COLUMN, 'DAY') AS day_name,
    TO_CHAR(DATE_COLUMN, 'D') AS day_of_week,
    TO_CHAR(DATE_COLUMN, 'Q') AS quarter
FROM
	(SELECT 
		to_date('1970-01-01','yyyy-mm-dd') + LEVEL - 1 AS DATE_COLUMN
	FROM 
		DUAL
	CONNECT BY LEVEL <= 47846) list_date;

SELECT
	"id" AS DATE_DIM_ID
	,DATUM AS "DATE_ACTUAL"
	,(DATUM - to_date('1970-01-01','yyyy-mm-dd')) * 86400  AS "EPOCH"
	,TO_CHAR(DATUM, 'DAY') AS DAY_NAME
	,TO_CHAR(DATUM, 'D') AS DAY_OF_WEEK_4
FROM
	(SELECT
		LEVEL AS "id"
		,to_date('1970-01-01','yyyy-mm-dd') + LEVEL - 1 AS DATUM
	FROM 
		DUAL
	CONNECT BY LEVEL <= 47846) list_date;
	
SELECT * FROM V$VERSION