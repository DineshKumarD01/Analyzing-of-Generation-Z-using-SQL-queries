USE genzdataset;

SHOW TABLES ;

SELECT * FROM 	learning_aspirations;
SELECT * FROM   manager_aspirations;
SELECT * FROM 	mission_aspirations;
SELECT * FROM 	personalized_info;

SELECT *
FROM learning_aspirations z1
left JOIN manager_aspirations z2 ON z1.ResponseID = z2.ResponseID
left JOIN mission_aspirations z3 ON z2.ResponseID = z3.ResponseID
left JOIN personalized_info z4 ON z3.ResponseID = z4.ResponseID;

#questions and answers

select ResponseID, Gender, CurrentCountry from genzdataset.personalized_info where CurrentCountry = 'India';

select count(*) from genzdataset.personalized_info where Gender like 'Male%' and CurrentCountry = 'India';

select count(*) from genzdataset.personalized_info where Gender like 'Female%' and CurrentCountry = 'India';

select count(Gender) from genzdataset.personalized_info;

select distinct CurrentCountry, 
(select count(*) from learning_aspirations where CareerInfluenceFactor like 'My Parents')
from genzdataset.personalized_info where CurrentCountry like 'India';

SELECT gender, COUNT(*) AS count
FROM learning_aspirations ci
JOIN personalized_info d
ON ci.ResponseID = d.ResponseID
WHERE ci.CareerInfluenceFactor = 'My Parents'
AND d.CurrentCountry = 'India'
GROUP BY Gender;

SELECT
SUM(CASE WHEN d.Gender = 'Male' THEN 1 ELSE 0 END) AS Male_Count,
SUM(CASE WHEN d.Gender = 'Female' THEN 1 ELSE 0 END) AS Female_Count
FROM learning_aspirations ci
JOIN personalized_info d
ON ci.ResponseID = d.ResponseID
WHERE ci.CareerInfluenceFactor = 'My Parents'
AND d.CurrentCountry = 'India';

SELECT COUNT(*) AS Total_Count
FROM learning_aspirations i
JOIN personalized_info c ON i.ResponseID = c.ResponseID
WHERE c.CurrentCountry = 'India'
AND i.CareerInfluenceFactor IN ('Social Media like LinkedIn', 'Influencers who had successful careers')
GROUP BY c.CurrentCountry;

SELECT c.Gender, COUNT(*) AS Total_Count
FROM learning_aspirations i
JOIN personalized_info c ON i.ResponseID = c.ResponseID
WHERE c.CurrentCountry = 'India'
AND i.CareerInfluenceFactor IN ('Social Media like LinkedIn', 'Influencers who had successful careers')
GROUP BY c.Gender;

select count(*) from learning_aspirations where CareerInfluenceFactor = 'Social Media like LinkedIn' and HigherEducationAbroad = 'Yes, I wil' ;

select count(*) from learning_aspirations where CareerInfluenceFactor = 'People from my circle, but not family members' and HigherEducationAbroad = 'Yes, I wil' ;













