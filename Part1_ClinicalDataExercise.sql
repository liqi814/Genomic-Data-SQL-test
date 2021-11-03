/* 2. Write a SQL query to create a view of all prospective cancer related clinical trials */
SELECT c.*, i.intervention_type, i.name AS intervention_name, i.description
FROM Conditions c
LEFT JOIN Studies s ON c.nct_id = s.nct_id
LEFT JOIN Designs d ON s.nct_id = d.nct_id
LEFT JOIN Interventions i ON d.nct_id = i.nct_id
WHERE c.downcase_name LIKE '%cancer%'
AND s.overall_status='Active, not recruiting';

/* used CREATE VIEW but failed due to 'ERROR:  permission denied for schema ctgov'
I have tried to use code `GRANT ALL ON ALL TABLES IN SCHEMA ctgov TO liqilq95`, but it didn't work.
In the future, might need some help from database admin */

/* 3a. How many unique breast cancer studies are there? */
SELECT COUNT ( DISTINCT nct_id )
FROM
(
	SELECT c.*, i.intervention_type, i.name AS intervention_name, i.description
	FROM Conditions c
	LEFT JOIN Studies s ON c.nct_id = s.nct_id
	LEFT JOIN Designs d ON s.nct_id = d.nct_id
	LEFT JOIN Interventions i ON d.nct_id = i.nct_id
	WHERE c.downcase_name LIKE '%cancer%'
	AND s.overall_status='Active, not recruiting'
) t
WHERE downcase_name LIKE '%breast%';
/* Answer: 843 */

/* 3b. What is the distribution of intervention types? */
SELECT intervention_type,
	   COUNT(*) AS intervention_type_cnt
FROM
(
	SELECT c.*, i.intervention_type, i.name AS intervention_name, i.description
	FROM Conditions c
	LEFT JOIN Studies s ON c.nct_id = s.nct_id
	LEFT JOIN Designs d ON s.nct_id = d.nct_id
	LEFT JOIN Interventions i ON d.nct_id = i.nct_id
	WHERE c.downcase_name LIKE '%cancer%'
	AND s.overall_status='Active, not recruiting'
) t
GROUP BY intervention_type
ORDER BY intervention_type_cnt DESC;


/* 3c. What are 3 patterns and/or interesting interventions
1. Majority of samples (about 46.3%) choose drug intervention, but less than 0.13% of samples 
choose strategies of combining other intervention types.
2. Paclitaxel and carboplatin (6.74% and 6.34% respectively) are the 2 most used medicine. 
And there is no popular medicine that has been used in cancer intervention. */
SELECT intervention_type, intervention_name,
	   COUNT(*) AS intervention_type_cnt
FROM
(
	SELECT c.*, i.intervention_type, LOWER(i.name) AS intervention_name, i.description
	FROM Conditions c
	LEFT JOIN Studies s ON c.nct_id = s.nct_id
	LEFT JOIN Designs d ON s.nct_id = d.nct_id
	LEFT JOIN Interventions i ON d.nct_id = i.nct_id
	WHERE c.downcase_name LIKE '%cancer%'
	AND s.overall_status='Active, not recruiting'
) t
WHERE intervention_type='Drug'
GROUP BY intervention_type, intervention_name
ORDER BY intervention_type_cnt DESC;

/* 3. IV medication (Given IV, given by an intravenous) is most often used. */
SELECT description,
	   COUNT(*) AS description_cnt
FROM
(
	SELECT c.*, i.intervention_type, LOWER(i.name) AS intervention_name, i.description
	FROM Conditions c
	LEFT JOIN Studies s ON c.nct_id = s.nct_id
	LEFT JOIN Designs d ON s.nct_id = d.nct_id
	LEFT JOIN Interventions i ON d.nct_id = i.nct_id
	WHERE c.downcase_name LIKE '%cancer%'
	AND s.overall_status='Active, not recruiting'
) t
GROUP BY description
ORDER BY description_cnt DESC;
