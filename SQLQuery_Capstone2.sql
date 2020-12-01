-- Exploring funding_rounds table

SELECT TOP 50 *
FROM funding_rounds;

SELECT Count(*) AS count_funding_rounds
FROM funding_rounds;

SELECT SUM(raised_amount_usd) AS total_raised_amount
FROM funding_rounds;

-- Amount raised per funding type
SELECT funding_round_code, SUM(raised_amount_usd)
FROM funding_rounds
GROUP BY funding_round_code
ORDER BY SUM(raised_amount_usd) DESC;

SELECT * 
FROM funding_rounds
WHERE funding_round_code = 'unattributed';

SELECT 
	CASE funding_round_code WHEN 'unattributed' THEN 'Venture' 
	ELSE funding_round_code END
	AS funding_type,
	SUM(raised_amount_usd) AS total_raised_per_funding
FROM funding_rounds
GROUP BY funding_round_code
ORDER BY SUM(raised_amount_usd) DESC
;  

-- Amount raised per year
SELECT DATEPART (year, funded_at) as year,
	SUM(raised_amount_usd) AS total_raised_per_year
FROM funding_rounds
GROUP BY DATEPART (year, funded_at)
ORDER BY DATEPART (year, funded_at)
;

-- -- Amount raised per year and per type of fundings >> RESULTS saved
SELECT DATEPART (year, funded_at) as year,
	CASE funding_round_code WHEN 'unattributed' THEN 'Venture' 
	ELSE funding_round_code END
	AS funding_type,
	SUM(raised_amount_usd) AS total_raised_per_funding
FROM funding_rounds
WHERE DATEPART (year, funded_at) IS NOT NULL
GROUP BY DATEPART (year, funded_at), funding_round_code
ORDER BY DATEPART (year, funded_at) DESC, SUM(raised_amount_usd) DESC
;  

-- Creating table with amount raised per year and per funding type
SELECT DATEPART (year, funded_at) as year,
	CASE funding_round_code WHEN 'unattributed' THEN 'Venture' 
	ELSE funding_round_code END
	AS funding_type,
	SUM(raised_amount_usd) AS total_raised_per_funding
INTO funding_trend_new
FROM funding_rounds
GROUP BY DATEPART (year, funded_at), funding_round_code
ORDER BY DATEPART (year, funded_at) DESC, SUM(raised_amount_usd) DESC
;  

DROP Table funding_trend_new


-- Exploring objects_table

SELECT TOP 50 *
FROM objects;

SELECT Count(*) AS count_objects
FROM objects;

SELECT DISTINCT category_code
FROM objects;

SELECT DISTINCT country_code, COUNT(*)
FROM objects
WHERE id LIKE '%c%'
GROUP BY country_code
ORDER BY COUNT(*) DESC
;

SELECT *
FROM objects 
WHERE country_code IS NULL
;


-- Mapping funding around the world
SELECT o.country_code, SUM(f.raised_amount_usd) AS raised_amount
FROM objects o
INNER JOIN funding_rounds f
ON o.id = f.object_id 
WHERE o.country_code IS NOT NULL AND o.id LIKE '%c%'
GROUP BY o.country_code
ORDER BY SUM(f.raised_amount_usd) DESC
;



-- highest industries that have had the most investments 
SELECT o.category_code, SUM(f.raised_amount_usd) AS raised_amount
FROM objects o
INNER JOIN funding_rounds f
ON o.id = f.object_id 
WHERE o.category_code IS NOT NULL
GROUP BY o.category_code
ORDER BY SUM(f.raised_amount_usd) DESC
;

-- highest industries that have had the most investments per year >> RESULT saved
SELECT
	DATEPART (year, f.funded_at) as year,
	o.category_code,
	SUM(raised_amount_usd) AS raised_amount
FROM objects o
INNER JOIN funding_rounds f
ON o.id = f.object_id
WHERE DATEPART (year, funded_at) IS NOT NULL AND o.category_code IS NOT NULL
GROUP BY DATEPART (year, funded_at), o.category_code
ORDER BY DATEPART (year, funded_at) DESC, SUM(raised_amount_usd) DESC
;


-- NEED TO HAVE ONE TABLE COMBINING year, funding type, industries FOR DASHBOARD ?!

SELECT DATEPART (year, f.funded_at) as year,
		o.category_code,
		CASE f.funding_round_code WHEN 'unattributed' THEN 'Venture' 
		ELSE f.funding_round_code END
		AS funding_type,
		COUNT(f.funding_round_code) AS count_funding_type,
		SUM(f.raised_amount_usd) AS total_raised
FROM objects o
FULL OUTER JOIN funding_rounds f
	ON o.id = f.object_id
WHERE DATEPART (year, f.funded_at) IS NOT NULL AND o.category_code IS NOT NULL
GROUP BY DATEPART (year, f.funded_at), 
		o.category_code, 
		CASE f.funding_round_code WHEN 'unattributed' THEN 'Venture' 
		ELSE f.funding_round_code END
ORDER BY DATEPART (year, f.funded_at) DESC, 
		SUM(f.raised_amount_usd) DESC
;

-- RESULTS OUTER JOIN SAVED
SELECT DATEPART (year, f.funded_at) as year,
		o.category_code,
		f.funding_round_type,
		COUNT(f.funding_round_type) AS count_funding_type,
		SUM(f.raised_amount_usd) AS total_raised
FROM objects o
FULL OUTER JOIN funding_rounds f
	ON o.id = f.object_id
WHERE DATEPART (year, f.funded_at) IS NOT NULL AND o.category_code IS NOT NULL
GROUP BY DATEPART (year, f.funded_at), 
		o.category_code, 
		f.funding_round_type
ORDER BY DATEPART (year, f.funded_at) DESC, 
		SUM(f.raised_amount_usd) DESC
;


-- Exploring degrees table
SELECT TOP 50 *
FROM degrees
ORDER BY object_id


SELECT DISTINCT institution
FROM degrees

-- Raised amount per schools institution 
--SELECT d.institution, SUM(f.raised_amount_usd) AS raised_amount
--FROM degrees d
--INNER JOIN funding_rounds f
--ON d.object_id = f.object_id 
--GROUP BY d.institution
--ORDER BY SUM(f.raised_amount_usd) DESC

-- >> not working because no same object_id 
-- >> need to join with relationships table


-- Exploring relationships table

SELECT TOP 50 *
FROM relationships 

SELECT DISTINCT relationship_object_id, COUNT(person_object_id) AS nb_people
FROM relationships
GROUP BY relationship_object_id
ORDER BY relationship_object_id
; 


SELECT TOP 20 d.institution, SUM(f.raised_amount_usd)  
FROM degrees d
INNER JOIN relationships r
ON d.object_id = r.person_object_id
INNER JOIN funding_rounds f
ON r.relationship_object_id = f.object_id
GROUP BY d.institution
ORDER BY SUM(f.raised_amount_usd) DESC
;