SELECT
  nameOfPatient.given_name AS "First Name",
  identifierOfPatient.identifier AS "Patient ID",
  group_concat(distinct(CASE WHEN typeOfPatientAttribute.name IN ("Phone1") THEN attributeOfPatient.value ELSE NULL END)) AS "Phone1",
  group_concat(distinct(CASE WHEN typeOfPatientAttribute.name IN ("Phone2") THEN attributeOfPatient.value ELSE NULL END)) AS "Phone2",
  concat_ws(' ', nameOfTheProviders.given_name, nameOfTheProviders.family_name)  AS "Provider",
  serviceAppointment.name AS "Appointment Service",
  serviceTypeAppointment.name AS "Appointment Service Type",
  DATE(pai.start_date_time) AS  "Date of Appointment",
  DATE_FORMAT(pai.start_date_time, '%I:%i %p') AS "Appointment Time",
  (CASE WHEN language.concept_full_name is not null and otherLanguage.value is Not NULL
      then concat_ws(', ',language.concept_full_name,otherLanguage.value)
      WHEN language.concept_full_name is not null and otherLanguage.value is NULL then language.concept_full_name
      WHEN language.concept_full_name is null and otherLanguage.value is NOT NULL THEN otherLanguage.value
      ELSE NULL END) AS "Patient's Language",
  pai.comments AS "Notes"

FROM

  patient pa
  LEFT JOIN patient_appointment pai ON pa.patient_id = pai.patient_id
  LEFT JOIN appointment_service serviceAppointment ON   pai.appointment_service_id = serviceAppointment.appointment_service_id
  LEFT JOIN appointment_service_type serviceTypeAppointment ON serviceAppointment.appointment_service_id = serviceTypeAppointment.appointment_service_id  AND pai.appointment_service_type_id = serviceTypeAppointment.appointment_service_type_id AND serviceTypeAppointment.voided = 0
  INNER JOIN patient_identifier identifierOfPatient ON pai.patient_id = identifierOfPatient.patient_id
  INNER JOIN person_name nameOfPatient ON pai.patient_id = nameOfPatient.person_id

  Left Join
  (/*Getting the value for language*/
  Select attributeOfPatient.person_id,cv.concept_full_name from person_attribute attributeOfPatient
  inner JOIN person_attribute_type typeOfPatientAttribute
  ON attributeOfPatient.person_attribute_type_id =typeOfPatientAttribute.person_attribute_type_id
  inner JOIN concept_view cv ON cv.concept_id = attributeOfPatient.value
  where  typeOfPatientAttribute.name = "Language" and attributeOfPatient.voided = 0
  ) as language on pai.patient_id = language.person_id

  Left join
 (/*Getting the value for Other language*/
  Select attributeOfPatient.person_id,attributeOfPatient.value from person_attribute attributeOfPatient
  inner JOIN person_attribute_type typeOfPatientAttribute
  ON attributeOfPatient.person_attribute_type_id =typeOfPatientAttribute.person_attribute_type_id
  where  typeOfPatientAttribute.name = "Other Language" and attributeOfPatient.voided = 0
  ) as otherLanguage on pai.patient_id = otherLanguage.person_id

  /*Getting the value for Phone1 and Phone2*/
  LEFT JOIN person_attribute attributeOfPatient ON pai.patient_id = attributeOfPatient.person_id and attributeOfPatient.voided = 0
  LEFT JOIN person_attribute_type typeOfPatientAttribute ON attributeOfPatient.person_attribute_type_id = typeOfPatientAttribute.person_attribute_type_id
  LEFT JOIN concept_view cv ON cv.concept_id = attributeOfPatient.value

  LEFT JOIN provider providerForAppointment ON pai.provider_id = providerForAppointment.provider_id
  LEFT JOIN person_name nameOfTheProviders ON providerForAppointment.person_id = nameOfTheProviders.person_id

WHERE

  DATE(pai.start_date_time) BETWEEN DATE('#startDate#') AND DATE('#endDate#')

  AND pai.status='Missed'
  AND pai.appointment_kind='Scheduled'
  AND pai.appointment_service_id IN
                                  (
                                    SELECT appointment_service_id
                                    FROM appointment_service
                                    where voided = 0
                                  )
  AND identifierOfPatient.identifier not in ('A00000')/*removing dummy patient from reports*/
GROUP BY pai.patient_appointment_id
ORDER BY pai.start_date_time;
