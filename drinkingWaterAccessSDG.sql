/* Access to Drinking Water (United Nations Sustainable Development Goal 6)

*/

-- PART ONE: Explore and clean the database

-- 1. Getting to know the data
SHOW TABLES;

SELECT
	* 
FROM 
	location
LIMIT 5;

SELECT
	* 
FROM 
	visits
LIMIT 5;

SELECT
	* 
FROM 
	water_source
LIMIT 5;

SELECT
	* 
FROM 
	data_dictionary;
    
    
-- 2. Diving into the sources
SELECT
	* 
FROM
	water_source;
    
SELECT DISTINCT
	type_of_water_source
FROM
	water_source;
    
    
-- 3. Unpacking the visits
SELECT
	*
FROM
	visits;

SELECT
	*
FROM
	visits
WHERE
	time_in_queue > 500;
    
-- AkKi00881224, SoRu37635224, SoRu36096224, AkRu05234224, HaZa21742224
SELECT
	*
FROM
	water_source
WHERE
	source_id = 'AkKi00881224'
	OR source_id = 'SoRu37635224'
	OR source_id = 'SoRu36096224'
	OR source_id = 'AkRu05234224'
	OR source_id = 'HaZa21742224';
    
    
-- 4. Water source quality
SELECT
	*
FROM
	water_quality;
    
SELECT
	*
FROM
	water_quality
WHERE
	subjective_quality_score = 10
    AND visit_count = 2;
    
    
-- 5. Pollution issues
SELECT
	*
FROM
	well_pollution
LIMIT 5;

SELECT
	*
FROM
	well_pollution
WHERE
	results = 'Clean'
    AND biological > 0.01;
    
SELECT
	*
FROM
	well_pollution
WHERE
	results = 'Clean'
    AND biological > 0.01
    AND description LIKE 'Clean%';

CREATE TABLE
	md_water_services.well_pollution_copy
AS (
	SELECT
		*
	FROM
		md_water_services.well_pollution
	);

UPDATE
	well_pollution_copy
SET
	description = 'Bacteria: E. coli'
WHERE
	description = 'Clean Bacteria: E. coli';

UPDATE
	well_pollution_copy
SET
	description = 'Bacteria: Giardia Lamblia'
WHERE
	description = 'Clean Bacteria: Giardia Lamblia';
    
UPDATE
	well_pollution_copy
SET
	results = 'Contaminated: Biological'
WHERE
	results = 'Clean'
    AND biological > 0.01;
    
SELECT
	*
FROM
	well_pollution_copy
WHERE
	(results = 'Clean'
    AND biological > 0.01)
    OR description LIKE 'Clean%';
    
UPDATE
	well_pollution
SET
	description = 'Bacteria: E. coli'
WHERE
	description = 'Clean Bacteria: E. coli';

UPDATE
	well_pollution
SET
	description = 'Bacteria: Giardia Lamblia'
WHERE
	description = 'Clean Bacteria: Giardia Lamblia';
    
UPDATE
	well_pollution
SET
	results = 'Contaminated: Biological'
WHERE
	results = 'Clean'
    AND biological > 0.01;

DROP TABLE
md_water_services.well_pollution_copy;

SELECT
	*
FROM
	well_pollution
WHERE
	/*(results = 'Clean'
    AND biological > 0.01)
    OR*/ description LIKE 'Clean_%';
    

-- PART TWO: Further cleaning, and drawing insights using aggregations

-- 1. Cleaning our data
SELECT
	REPLACE(employee_name, ' ', '.')
FROM
	employee;

SELECT
	LOWER(REPLACE(employee_name, ' ', '.'))
FROM
	employee;

SELECT
	CONCAT(LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov') AS new_email
FROM
	employee;

UPDATE 
	employee
SET 
	email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov');
    
SELECT
	*
FROM
	employee;
    
SELECT
	LENGTH(phone_number)
FROM
	employee;

SELECT
	LENGTH(TRIM(phone_number))
FROM
	employee;
    
UPDATE 
	employee
SET 
	phone_number = TRIM(phone_number);
    

-- 2. Honouring the workers
SELECT
	town_name,
    COUNT(assigned_employee_id) AS emp_in_town
FROM
	employee
GROUP BY
	town_name;

SELECT
	assigned_employee_id,
    SUM(visit_count) AS num_of_visits
FROM
	visits
GROUP BY
	assigned_employee_id
ORDER BY
	num_of_visits DESC
LIMIT 5;

SELECT
	assigned_employee_id,
    employee_name,
    email,
    phone_number
FROM
	employee
WHERE
	assigned_employee_id IN ('1', '30', '34');
    

-- 3. Analysing locations
SELECT
	town_name,
    COUNT(location_id) AS rec_per_town
FROM
	location
GROUP BY
	town_name;

SELECT
	province_name,
    COUNT(location_id) AS rec_per_prov
FROM
	location
GROUP BY
	province_name;

SELECT
	province_name,
    town_name,
    COUNT(location_id) AS records_per_town
FROM
	location
GROUP BY
	province_name,
    town_name
ORDER BY
	province_name,
    records_per_town DESC;

SELECT
	location_type,
    COUNT(location_id) AS rec_per_loc
FROM
	location
GROUP BY
	location_type;
    

-- 4. Diving into the sources
SELECT
    SUM(number_of_people_served) AS tot_people_served
FROM
	water_source;
    
SELECT
	type_of_water_source,
    COUNT(source_id) AS num_water_source
FROM
	water_source
GROUP BY
	type_of_water_source;
    
SELECT
	type_of_water_source,
    ROUND(AVG(number_of_people_served)) AS avg_people_per_water_source
FROM
	water_source
GROUP BY
	type_of_water_source;
    
SELECT
	type_of_water_source,
    SUM(number_of_people_served) AS tot_people_per_water_source,
FROM
	water_source
GROUP BY
	type_of_water_source;
    
SELECT
	type_of_water_source,
    SUM(number_of_people_served) AS tot_people_per_water_source,
    ROUND((SUM(number_of_people_served) / 27628140) * 100) AS pct_people_per_water_source
FROM
	water_source
GROUP BY
	type_of_water_source
ORDER BY
	pct_people_per_water_source DESC;
    

-- 5. Start of a solution
SELECT
	type_of_water_source,
    SUM(number_of_people_served) AS tot_people_per_water_source,
    RANK() OVER(
        ORDER BY SUM(number_of_people_served) DESC
    ) AS rank_by_people_per_water_source
FROM
	water_source
GROUP BY
	type_of_water_source;
    
SELECT
	source_id,
    type_of_water_source,
    SUM(number_of_people_served) AS tot_people_per_source_id,
    RANK() OVER(
        PARTITION BY type_of_water_source
        ORDER BY SUM(number_of_people_served) DESC
    ) AS rank_by_people_per_source_id
FROM
	water_source
GROUP BY
	source_id;
    
    
-- 6. Analysing queues
SELECT
	MIN(time_of_record) AS first_day_survey,
    MAX(time_of_record) AS last_day_survey,
    DATEDIFF(MAX(time_of_record), MIN(time_of_record)) AS survey_duration
FROM
	visits;
    
SELECT
	AVG(NULLIF(time_in_queue, '0'))
FROM
	visits;
    
 SELECT
	DAYNAME(time_of_record) AS day_of_week,
    ROUND(AVG(NULLIF(time_in_queue, '0'))) AS avg_queue_time
FROM
	visits
GROUP BY
	day_of_week;
    
SELECT
	AVG(NULLIF(time_in_queue, '0'))
FROM
	visits;
    
 SELECT
	TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
    ROUND(AVG(NULLIF(time_in_queue, '0'))) AS avg_queue_time
FROM
	visits
GROUP BY
	hour_of_day
ORDER BY
	hour_of_day;
    
SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
DAYNAME(time_of_record),
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END AS Sunday
FROM
visits
WHERE
time_in_queue != 0;
    
SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
-- Sunday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END
),0) AS Sunday,
-- Monday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
ELSE NULL
END
),0) AS Monday,
-- Tuesday
	ROUND(AVG(
	CASE
	WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
	ELSE NULL
	END
	),0) AS Tuesday,
-- Wednesday
	ROUND(AVG(
	CASE
	WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
	ELSE NULL
	END
	),0) AS Wednesday,
-- Thursday
	ROUND(AVG(
	CASE
	WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
	ELSE NULL
	END
	),0) AS Thursday,
-- Friday
	ROUND(AVG(
	CASE
	WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
	ELSE NULL
	END
	),0) AS Friday,
-- Saturday
	ROUND(AVG(
	CASE
	WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
	ELSE NULL
	END
	),0) AS Saturday
FROM
	visits
WHERE
	time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
	hour_of_day
ORDER BY
	hour_of_day;


-- PART THREE: Deeper analyses using multiple sources of data


-- 2. Integrating the auditor report
USE md_water_services;

DROP TABLE IF EXISTS `auditor_report`;

CREATE TABLE `auditor_report` (
`location_id` VARCHAR(32),
`type_of_water_source` VARCHAR(64),
`true_water_source_score` int DEFAULT NULL,
`statements` VARCHAR(255)
);

SELECT
	*
FROM
	auditor_report;

SELECT
	*
FROM
	visits;
    
SELECT
	*
FROM
	employee;


CREATE VIEW Incorrect_records AS (
	SELECT
		auditor_report.location_id,
		visits.record_id,
		employee.employee_name,
		auditor_report.true_water_source_score AS auditor_score,
		wq.subjective_quality_score AS surveyor_score,
		auditor_report.statements AS statements
	FROM
		auditor_report
	JOIN
		visits
		ON auditor_report.location_id = visits.location_id
	JOIN
		water_quality AS wq
		ON visits.record_id = wq.record_id
	JOIN
		employee
		ON employee.assigned_employee_id = visits.assigned_employee_id
	WHERE
		visits.visit_count =1
		AND auditor_report.true_water_source_score != wq.subjective_quality_score);

WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
	SELECT
		employee_name,
		COUNT(employee_name) AS number_of_mistakes
	FROM
		Incorrect_records
	/*
	Incorrect_records is a view that joins the audit report to the database
	for records where the auditor and
	employees scores are different*
	*/

	GROUP BY
		employee_name)
	-- Query
	/*
		SELECT
			AVG(number_of_mistakes)
		FROM
			error_count; */
		SELECT
			* 
        FROM
			error_count;
            
            
-- PART FOUR: Advanced SQL for final analyses and reporting


-- 1. Joining pieces together
SELECT
	loc.province_name,
    loc.town_name,
    src.type_of_water_source,
    loc.location_type,
    src.number_of_people_served,
    vis.time_in_queue
FROM
	location loc
JOIN
    visits vis
	ON loc.location_id = vis.location_id
JOIN
	water_source src
	ON vis.source_id = src.source_id
WHERE
	vis.visit_count = 1;

SELECT
    src.type_of_water_source,
    loc.town_name,
	loc.province_name,
    loc.location_type,
    src.number_of_people_served,
    vis.time_in_queue,
    wel.results
FROM
	visits vis
LEFT JOIN 
	well_pollution wel
	ON vis.source_id = wel.source_id
JOIN
	location loc
	ON vis.location_id = loc.location_id
JOIN
	water_source src
	ON vis.source_id = src.source_id
WHERE
	vis.visit_count = 1;

CREATE VIEW combined_analysis_table AS
-- This view assembles data from different tables into one to simplify analysis
	SELECT
		water_source.type_of_water_source AS source_type,
		location.town_name,
		location.province_name,
		location.location_type,
		water_source.number_of_people_served AS people_served,
		visits.time_in_queue,
		well_pollution.results
	FROM
		visits
	LEFT JOIN
		well_pollution
		ON well_pollution.source_id = visits.source_id
	INNER JOIN
		location
		ON location.location_id = visits.location_id
	INNER JOIN
		water_source
		ON water_source.source_id = visits.source_id
	WHERE
		visits.visit_count = 1;

-- 2. The last analysis
WITH province_totals AS (-- This CTE calculates the population of each province
	SELECT
		province_name,
		SUM(people_served) AS total_ppl_serv
	FROM
		combined_analysis_table
	GROUP BY
		province_name
	)
    
	SELECT
		ct.province_name,
	-- These case statements create columns for each type of source.
	-- The results are aggregated and percentages are calculated
		ROUND((SUM(CASE WHEN source_type = 'river'
		THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
		ROUND((SUM(CASE WHEN source_type = 'shared_tap'
		THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
		ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
		THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
		ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
		THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
		ROUND((SUM(CASE WHEN source_type = 'well'
		THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
	FROM
		combined_analysis_table ct
	JOIN
		province_totals pt
        ON ct.province_name = pt.province_name
	GROUP BY
		ct.province_name
	ORDER BY
		ct.province_name;

SELECT
	*
FROM
	province_totals;

CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS (-- This CTE calculates the population of each town
-- Since there are two Harare towns, we have to group by province_name and town_name
	SELECT
		province_name,
		town_name,
        SUM(people_served) AS total_ppl_serv
	FROM
		combined_analysis_table
	GROUP BY
		province_name,town_name
	)

	SELECT
		t.province_name,
		ct.town_name,
		ROUND((SUM(CASE WHEN source_type = 'river'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
		ROUND((SUM(CASE WHEN source_type = 'shared_tap'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
		ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
		ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
		ROUND((SUM(CASE WHEN source_type = 'well'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
	FROM
		combined_analysis_table ct
	JOIN -- Since the town names are not unique, we have to join on a composite key
		town_totals tt
		ON ct.province_name = tt.province_name
		AND ct.town_name = tt.town_name
	GROUP BY -- We group by province first, then by town.
		ct.province_name,
		ct.town_name
	ORDER BY
		ct.town_name;

SELECT
	*
FROM
	town_aggregated_water_access
ORDER BY 
	province_name,
    town_name,
    river DESC,
    shared_tap DESC,
	tap_in_home DESC,
    tap_in_home_broken DESC,
    well DESC
LIMIT 15;

SELECT
	province_name,
	town_name,
	ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100,0) AS Pct_broken_taps
FROM
	town_aggregated_water_access;

-- 4. A practical plan
CREATE TABLE Project_progress (
	Project_id SERIAL PRIMARY KEY,
	/* Project_id −− Unique key for sources in case we visit the same
    source more than once in the future.
	*/
	source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
	/* source_id −− Each of the sources we want to improve should exist,
    and should refer to the source table. This ensures data integrity.
	*/
	Address VARCHAR(50), -- Street address
	Town VARCHAR(30),
	Province VARCHAR(30),
	Source_type VARCHAR(50),
	Improvement VARCHAR(50), -- What the engineers should do at that place
	Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
	/* Source_status −− We want to limit the type of information engineers can give us, so we
	limit Source_status.
	− By DEFAULT all projects are in the "Backlog" which is like a TODO list.
	− CHECK() ensures only those three options will be accepted. This helps to maintain clean data.
	*/
	Date_of_completion DATE, -- Engineers will add this the day the source has been upgraded.
	Comments TEXT -- Engineers can leave comments. We use a TEXT type that has no limit on char length
	);


