use hospital_db

-- check the data
SELECT * FROM encounters LIMIT 5
SELECT * FROM patients LIMIT 5
SELECT * FROM payers LIMIT 5
SELECT * FROM procedures LIMIT 5

-- OBJECTIVE 1: ENCOUNTERS OVERVIEW
--a. How many total encounters occurred each year?
SELECT 
	YEAR(START) AS Year,
    COUNT(Id) AS Total_Count
FROM 
	encounters
GROUP BY 
	Year
ORDER BY 
	Year;
    
-- b. Percentage of encounters by ENCOUNTERCLASS (e.g., ambulatory, emergency, etc.) per year

SELECT
	Class_Data.Year,
    Class_Data.Encounter_list,
    Class_Data.Encounter_Total,
    ROUND(Class_Data.Encounter_Total * 100/ En_data.Total_Encounter,2) AS Percentage_encounter
FROM
		(SELECT 
			YEAR(START) AS Year,
			ENCOUNTERCLASS AS Encounter_list,
			COUNT(*) AS Encounter_Total
		FROM
			encounters
		GROUP BY 
			Year, Encounter_list
		ORDER BY
			Year, Encounter_list) AS Class_Data
		JOIN (SELECT 
			YEAR(START) AS Year,
			COUNT(*) AS Total_Encounter
		FROM
			encounters
		GROUP BY 
			Year
		ORDER BY
			Year) AS En_data
		ON Class_Data.Year = En_data.Year
ORDER BY
	Class_Data.Year, Class_Data.Encounter_list
    
-- c. What % of encounters lasted over 24 hours vs. under 24 hours?
-- SELECT * FROM encounters LIMIT 5

SELECT 
	SUM(TIMESTAMPDIFF(HOUR, START, STOP)>24) AS Encounter_over_24,
    SUM(TIMESTAMPDIFF(HOUR, START, STOP)<=24) AS Encounter_under_24,
    COUNT(*) AS Total_encounters,
    ROUND(SUM(TIMESTAMPDIFF(HOUR, START, STOP)>24) * 100 / COUNT(*),2) AS Encounter_over_24_percentage,
    ROUND(SUM(TIMESTAMPDIFF(HOUR, START, STOP)<=24) * 100 / COUNT(*),2) AS Encounter_under_24_percentage
FROM
	encounters;

-- OBJECTIVE 2: Cost & Coverage Insights
-- a. Average BASE_ENCOUNTER_COST and TOTAL_CLAIM_COST by payer

SELECT 
	payers.NAME AS Payer_Name,
	ROUND(AVG(BASE_ENCOUNTER_COST),2) AS Avg_Base_cost,
    ROUND(AVG(TOTAL_CLAIM_COST),2) AS Avg_Total_cost
FROM 
	encounters
JOIN 
	payers ON encounters.PAYER = payers.id
GROUP BY 
	payers.NAME
ORDER BY
	Avg_Total_cost DESC
    
-- b. How many encounters had zero payer coverage, and what percentage of total encounters does this represent?

SELECT
	SUM(PAYER_COVERAGE=0) AS Zero_coverage,
    COUNT(*) AS Total_encounter,
    ROUND(SUM(PAYER_COVERAGE=0) * 100 / COUNT(*),2) AS Zero_covergae_encoutner_percetage
FROM
	encounters
    
-- c.What are the top 10 most frequent procedures performed and the average base cost for each?

SELECT
	CODE AS Procedure_code,
    COUNT(CODE) AS Most_frequent_procedures,
    ROUND(AVG(BASE_COST),2) AS Avg_base_cost
FROM
	procedures
GROUP BY
	CODE
ORDER BY
	Most_frequent_procedures DESC LIMIT 10
    
-- d.How much cost (%) was covered by insurance (PAYER_COVERAGE)?

SELECT
	SUM(TOTAL_CLAIM_COST) AS Total_Cost,
    SUM(PAYER_COVERAGE) AS Coverage_cost,
    ROUND(SUM(PAYER_COVERAGE) * 100 / SUM(TOTAL_CLAIM_COST), 2) AS Percentage_cost_covered
FROM
	encounters
    
-- e. What are the top 10 procedures with the highest average base cost and the number of times they were performed?

SELECT 
	CODE AS Procedure_code,
    COUNT(CODE) AS No_of_time_performed,
    AVG(BASE_COST) AS Avg_base_cost
FROM
	procedures
GROUP BY
	CODE
ORDER BY
	AVG(BASE_COST) DESC
LIMIT 10

-- OBJECTIVE 3: PATIENT BEHAVIOR ANALYSIS

-- a. Patient count by gender, age group, and marital status

SELECT
	GENDER AS Gender,
    MARITAL AS Marital_status,
    CASE
		WHEN TIMESTAMPDIFF(YEAR, BIRTHDATE, CURDATE())<18 THEN "Under 18"
        WHEN TIMESTAMPDIFF(YEAR, BIRTHDATE, CURDATE()) BETWEEN 18 AND 35 THEN "18 to 35"
        WHEN TIMESTAMPDIFF(YEAR, BIRTHDATE, CURDATE()) BETWEEN 35 AND 60 THEN "35to 60"
        ELSE "60+"
	END AS Age_group,
    COUNT(*) AS Total_patients
FROM
	patients
GROUP BY
	GENDER, MARITAL, Age_group
ORDER BY
	Age_group,GENDER, MARITAL
    
-- B. How many unique patients were admitted each quarter over time?

SELECT
	YEAR(START) AS Year,
    QUARTER(START) AS Quarter,
    COUNT(DISTINCT PATIENT) AS Total_patient
FROM
	encounters
GROUP BY
	YEAR(START), QUARTER(START)
ORDER BY
	YEAR(START), QUARTER(START)
    
-- C. How many patients were readmitted within 30 days of a previous encounter?

SELECT
	COUNT(DISTINCT en1.PATIENT) AS Readmitted_patient_count
FROM
	encounters en1
JOIN
	encounters en2
    ON en2.PATIENT = en1.PATIENT
    AND en2.START > en1.STOP
    AND TIMESTAMPDIFF(DAY, en1.STOP, en2.START) <= 30
    
-- d.Which patients had the most readmissions?

SELECT
	PATIENT AS Patient_id,
    COUNT(PATIENT) AS Readmission_Count
FROM
	encounters
GROUP BY
	PATIENT
ORDER BY
	Readmission_Count DESC
    

    

    










