USE genzdataset;
SHOW TABLES ;
SELECT * FROM 	learning_aspirations;
SELECT * FROM   manager_aspirations;
SELECT * FROM 	mission_aspirations;
SELECT * FROM 	personalized_info;
SELECT * FROM   india_pincode;

WITH OfficeCounts AS (
    SELECT
	g.Gender,
	COUNT(w.ResponseID) AS total_count,
	SUM(CASE WHEN w.PreferredWorkingEnvironment = 'Every Day Office Environment' THEN 1 ELSE 0 END) AS office_count
    FROM
	personalized_info g
    JOIN
	learning_aspirations w ON g.ResponseID = w.ResponseID
    GROUP BY
	g.Gender)
SELECT
Gender,
(office_count * 100.0 / total_count) AS percentage
FROM
OfficeCounts;

SELECT COUNT(*) AS count_matching_conditions
FROM learning_aspirations
WHERE ClosestAspirationalCareer = 'Business Operations in any organization' 
AND CareerInfluenceFactor = 'My Parents';

SELECT (sum(case when ClosestAspirationalCareer = 'Business Operations in any organization' 
AND CareerInfluenceFactor = 'My Parents' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS percentage
FROM learning_aspirations;

WITH AbroadCounts AS (SELECT g.Gender, COUNT(w.ResponseID) AS total_count,
SUM(CASE WHEN w.HigherEducationAbroad = 'Yes, I wil' THEN 1 ELSE 0 END) AS abroad_count
FROM personalized_info g JOIN learning_aspirations w ON g.ResponseID = w.ResponseID
GROUP BY g.Gender)
SELECT Gender, (abroad_count * 100.0 / total_count) AS percentage
FROM AbroadCounts;

SELECT g.Gender, ws.MisalignedMissionLikelihood, (COUNT(*) * 100.0 / total_count) AS percentage
FROM personalized_info g
JOIN mission_aspirations ws ON g.ResponseID = ws.ResponseID
JOIN (SELECT gender, COUNT(*) AS total_count FROM personalized_info GROUP BY Gender) 
AS gender_totals ON g.Gender = gender_totals.Gender
GROUP BY g.Gender, ws.MisalignedMissionLikelihood;

WITH FemaleCounts AS (
    SELECT w.PreferredWorkingEnvironment, COUNT(*) AS female_count
    FROM personalized_info g
    JOIN learning_aspirations w ON g.ResponseID = w.ResponseID
    WHERE g.Gender = 'Female'
    GROUP BY w.PreferredWorkingEnvironment)
SELECT PreferredWorkingEnvironment
FROM FemaleCounts
WHERE female_count = (SELECT MAX(female_count) FROM FemaleCounts);

SELECT COUNT(*) AS total_female_aspiring_with_social_impact
FROM personalized_info g
JOIN learning_aspirations ac ON g.ResponseID = ac.ResponseID
JOIN mission_aspirations si ON ac.ResponseID= si.ResponseID
WHERE g.Gender = 'Female' AND si.NoSocialImpactLikelihood BETWEEN 1 AND 5;

SELECT g.Gender
FROM personalized_info g
JOIN learning_aspirations iia ON g.ResponseID = iia.ResponseID
WHERE g.Gender like 'Male%' AND iia.HigherEducationAbroad like 'Yes, I wil%'
AND iia.CareerInfluenceFactor = 'My Parents';

SELECT (COUNT(*) * 100.0 / total_count) AS percentage
FROM ( SELECT g.Gender, si.NoSocialImpactLikelihood, iia.HigherEducationAbroad
        FROM personalized_info g
        JOIN mission_aspirations si ON g.ResponseID = si.ResponseID
        JOIN learning_aspirations iia ON g.ResponseID = iia.ResponseID
        WHERE si.NoSocialImpactLikelihood BETWEEN 8 AND 10
		AND iia.HigherEducationAbroad = 'Yes, I wil') AS filtered_data,
(SELECT COUNT(*) AS total_count FROM personalized_info) AS gender_totals;

WITH TeamPreferencesSummary AS (
     SELECT wp.PreferredWorkSetup, COUNT(*) AS count
     FROM manager_aspirations wp
     JOIN personalized_info g ON wp.ResponseID = g.ResponseID
     GROUP BY wp.PreferredWorkSetup),
TotalCounts AS (SELECT COUNT(*) AS total_count FROM personalized_info)
SELECT tps.PreferredWorkSetup, tps.count, (tps.count * 100.0 / tc.total_count) AS percentage,
tc.total_count AS total_count
FROM TeamPreferencesSummary tps
CROSS JOIN TotalCounts tc
ORDER BY PreferredWorkSetup;

WITH WorkLikelihoodSummary AS (
    SELECT w.WorkLikelihood3Years, g.Gender, COUNT(*) AS count
    FROM manager_aspirations w
    JOIN personalized_info g ON w.ResponseID = g.ResponseID
    GROUP BY w.WorkLikelihood3Years, g.Gender),
TotalCounts AS (SELECT Gender, COUNT(*) AS total_count
    FROM personalized_info
    GROUP BY Gender
)
SELECT wls.WorkLikelihood3Years, wls.Gender, wls.count,
(wls.count * 100.0 / tc.total_count) AS percentage,
tc.total_count AS total_gender_count
FROM WorkLikelihoodSummary wls
JOIN TotalCounts tc ON wls.gender = tc.gender
ORDER BY WorkLikelihood3Years, Gender;

SELECT ip.State, 
       COUNT(*) AS total_persons,
       SUM(ma.WorkLikelihood3Years) AS total_work_likelihood
FROM personalized_info pi
JOIN india_pincode ip ON pi.ZipCode = ip.Pincode
LEFT JOIN manager_aspirations ma ON pi.ResponseID = ma.ResponseID
GROUP BY ip.State;

SELECT pi.Gender,
       AVG(CASE
             WHEN ma.ExpectedSalary5Years like '50k to 70k%' THEN 70000
             WHEN ma.ExpectedSalary5Years like '91k to 110k%' THEN 110000
             WHEN ma.ExpectedSalary5Years like '71k to 90k%' THEN 90000
             WHEN ma.ExpectedSalary5Years like '>151k%' THEN 151001
           END) AS average_starting5_salary
FROM personalized_info pi
LEFT JOIN mission_aspirations ma ON pi.ResponseID = ma.ResponseID
GROUP BY pi.Gender;

SELECT pi.Gender,
       AVG(CASE
             WHEN ma.ExpectedSalary3Years = '21k to 25k' THEN 25000
             WHEN ma.ExpectedSalary3Years = '31k to 40k' THEN 40000
             WHEN ma.ExpectedSalary3Years = '26k to 30k' THEN 30000
             WHEN ma.ExpectedSalary3Years = '>50k' THEN 50001
           END) AS average_starting_salary
FROM personalized_info pi
LEFT JOIN mission_aspirations ma ON pi.ResponseID = ma.ResponseID
GROUP BY pi.Gender;

SELECT pi.Gender,
    AVG(
        CASE
			WHEN ma.ExpectedSalary3Years LIKE '% to %' THEN
                CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ma.ExpectedSalary3Years, ' to ', -1), 'k', 1) AS DECIMAL) * 1000
            ELSE NULL
        END
    ) AS average_higher_bar_salary
FROM personalized_info pi
LEFT JOIN mission_aspirations ma ON pi.ResponseID = ma.ResponseID
GROUP BY pi.gender; 

SELECT pi.Gender,
    AVG(
        CASE
			WHEN ma.ExpectedSalary5Years LIKE '% to %' THEN
                CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ma.ExpectedSalary5Years, ' to ', -1), 'k', 1) AS DECIMAL) * 1000
            ELSE NULL
        END
    ) AS average_higher_bar_salary
FROM personalized_info pi
LEFT JOIN mission_aspirations ma ON pi.ResponseID = ma.ResponseID
GROUP BY pi.gender;

SELECT pi.Gender, ip.State,
    AVG(
        CASE
            WHEN ma.ExpectedSalary3Years LIKE '%k to %k' THEN
                (CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ma.ExpectedSalary3Years, ' to ', -1), 'k', 1) AS DECIMAL) * 1000 +
                 CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ma.ExpectedSalary3Years, ' to ', 1), 'k', 1) AS DECIMAL) * 1000) / 2
            ELSE NULL
        END
    ) AS average_starting_salary
FROM personalized_info pi
JOIN india_pincode ip ON pi.ZipCode = ip.Pincode
LEFT JOIN mission_aspirations ma ON pi.ResponseID = ma.ResponseID
GROUP BY pi.Gender, ip.State;

SELECT pi.Gender, ip.State,
    AVG(
        CASE
            WHEN ma.ExpectedSalary5Years LIKE '%k to %k' THEN
                (CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ma.ExpectedSalary5Years, ' to ', -1), 'k', 1) AS DECIMAL) * 1000 +
                 CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ma.ExpectedSalary5Years, ' to ', 1), 'k', 1) AS DECIMAL) * 1000) / 2
            ELSE NULL
        END
    ) AS average_starting5_salary
FROM personalized_info pi
JOIN india_pincode ip ON pi.ZipCode = ip.Pincode
LEFT JOIN mission_aspirations ma ON pi.ResponseID = ma.ResponseID
GROUP BY pi.Gender, ip.State;

SELECT pi.gender, ip.state,
    AVG(
        CASE
            WHEN ma.ExpectedSalary3Years LIKE '% to %' THEN
                CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ma.ExpectedSalary3Years, ' to ', -1), 'k', 1) AS DECIMAL) * 1000
            ELSE NULL
        END
    ) AS average_higher_bar_salary
FROM personalized_info pi
JOIN India_pincode ip ON pi.ZipCode = ip.Pincode
LEFT JOIN mission_aspirations ma ON pi.ResponseID = ma.ResponseID
GROUP BY pi.gender, ip.state;

SELECT pi.gender, ip.state,
    AVG(
        CASE
            WHEN ma.ExpectedSalary5Years LIKE '% to %' THEN
                CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ma.ExpectedSalary5Years, ' to ', -1), 'k', 1) AS DECIMAL) * 1000
            ELSE NULL
        END
    ) AS average_higher_bar5_salary
FROM personalized_info pi
JOIN India_pincode ip ON pi.ZipCode = ip.Pincode
LEFT JOIN mission_aspirations ma ON pi.ResponseID = ma.ResponseID
GROUP BY pi.gender, ip.state;

SELECT ip.state,
    SUM(CASE WHEN ma.MisalignedMissionLikelihood = 'Will work for them' THEN 1 ELSE 0 END) AS will_work_count,
    SUM(CASE WHEN ma.MisalignedMissionLikelihood = 'Will NOT work for them' THEN 1 ELSE 0 END) AS will_not_work_count,
    COUNT(*) AS total_persons
FROM personalized_info pi
JOIN India_pincode ip ON pi.zipcode = ip.pincode
LEFT JOIN mission_aspirations ma ON pi.ResponseID = ma.ResponseID
GROUP BY ip.state;


























    
    
    







