SELECT DISTINCT
DATE_FORMAT(p.date_created,'%d/%m/%Y') AS "Registration Date",
pi.identifier  AS "Patient ID",
concat(pn.given_name,' ',ifnull(pn.middle_name,'')) AS "Patient Name",
p.gender AS "Gender",
floor(datediff(now(), p.birthdate)/365) AS "Age",
pad.STATE_PROVINCE AS "Zone",
pad.COUNTY_DISTRICT AS "Other Zone",
GROUP_CONCAT(DISTINCT (CASE WHEN pat.name='Nationality' THEN c.name ELSE NULL END)) AS "Nationality",
GROUP_CONCAT(DISTINCT (CASE WHEN pat.name='Other Nationality' THEN pa.value ELSE NULL END)) AS "Other Nationality",
GROUP_CONCAT(DISTINCT (CASE WHEN pat.name='Phone1' THEN pa.value ELSE NULL END)) AS "Phone1",
GROUP_CONCAT(DISTINCT (CASE WHEN pat.name='Phone2' THEN pa.value ELSE NULL END)) AS "Phone2",
GROUP_CONCAT(DISTINCT (CASE WHEN pat.name='UN number' THEN pa.value ELSE NULL END)) AS "UN number",
GROUP_CONCAT(DISTINCT (CASE WHEN pat.name='Other ID' THEN pa.value ELSE NULL END)) AS "Other ID",
GROUP_CONCAT(DISTINCT (CASE WHEN pat.name='Language' THEN c.name ELSE NULL END)) AS "Language",
GROUP_CONCAT(DISTINCT (CASE WHEN pat.name='Other Language' THEN pa.value ELSE NULL END)) AS "Other Language",
GROUP_CONCAT(DISTINCT (CASE WHEN pat.name='How reach MSF' THEN c.name ELSE NULL END)) AS "How reach MSF",
GROUP_CONCAT(DISTINCT (CASE WHEN pat.name="Patient's scope" THEN c.name ELSE NULL END)) AS "Patient's scope",
GROUP_CONCAT(DISTINCT (CASE WHEN pat.name='In-scope Date' THEN date_format(pa.value, '%d/%m/%Y') ELSE NULL END)) AS "In-scope Date"

FROM  patient_identifier pi
INNER JOIN person p ON p.person_id=pi.patient_id AND pi.identifier NOT IN ('A00000')/*removing dummy patient from reports*/
INNER JOIN person_name pn ON pn.person_id=p.person_id
LEFT JOIN person_attribute pa ON p.person_id=pa.person_id AND pa.voided=0
LEFT JOIN person_attribute_type pat ON pa.person_attribute_type_id=pat.person_attribute_type_id
LEFT JOIN concept_name c ON c.concept_id=pa.value AND c.voided = 0
LEFT JOIN person_address pad ON pad.person_id=p.person_id
WHERE DATE(p.date_created) BETWEEN date('#startDate#') AND Date('#endDate#')
GROUP BY pi.identifier
ORDER BY pi.identifier;
