SELECT
  identifierOfPatient.identifier AS "Patient ID",
  concat_ws(' ', nameOfTheProviders.given_name, nameOfTheProviders.family_name)  AS "Provider",
  serviceAppointment.name AS "Appointment Service",
  serviceTypeAppointment.name AS "Appointment Service Type",
  DATE(pai.start_date_time) AS  "Date of Appointment",
  DATE_FORMAT(pai.start_date_time, '%r') AS "Appointment Start Time",
  DATE_FORMAT(pai.end_date_time, '%r') AS "Appointment End Time",
  pai.status AS "Status",
  DATE_FORMAT(checkinTime.date_started,'%d-%b-%Y %r' ) AS "Start Visit Time",
  (CASE WHEN language.concept_full_name ="Other" THEN CONCAT(ifnull(language.concept_full_name,''),case when otherLanguage.value is null then '' else ',' end,ifnull(otherLanguage.value ,'')) ELSE ifnull(language.concept_full_name,'') END) AS "Patient's Language",
  pai.comments AS "Notes"

FROM

  patient pa
  LEFT JOIN patient_appointment pai ON pa.patient_id = pai.patient_id
  LEFT JOIN appointment_service serviceAppointment ON   pai.appointment_service_id = serviceAppointment.appointment_service_id AND serviceAppointment.voided = 0
  LEFT JOIN appointment_service_type serviceTypeAppointment ON serviceAppointment.appointment_service_id = serviceTypeAppointment.appointment_service_id  AND pai.appointment_service_type_id = serviceTypeAppointment.appointment_service_type_id AND serviceTypeAppointment.voided = 0
  LEFT JOIN patient_identifier identifierOfPatient ON pai.patient_id = identifierOfPatient.patient_id
  LEFT JOIN visit checkinTime ON pai.patient_id = checkinTime.patient_id /*getting Start visit time*/
  LEFT JOIN provider providerForAppointment ON pai.provider_id = providerForAppointment.provider_id
  LEFT JOIN person_name nameOfTheProviders ON providerForAppointment.person_id = nameOfTheProviders.person_id
  LEFT JOIN person_attribute attributeOfPatient ON pai.patient_id = attributeOfPatient.person_id
  LEFT JOIN person_attribute_type typeOfPatientAttribute ON attributeOfPatient.person_attribute_type_id = typeOfPatientAttribute.person_attribute_type_id
  LEFT JOIN concept_view cv ON cv.concept_id = attributeOfPatient.value
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

WHERE
  DATE(pai.start_date_time) BETWEEN DATE('#startDate#') AND DATE('#endDate#')
  AND pai.appointment_kind='Scheduled'
  AND pai.appointment_service_id IN
                                  (
                                  SELECT appointment_service_id
                                  FROM appointment_service
                                  WHERE name IN
                                              (
                                              'Blue Team','Green Team','Orange Team','Red Team'
                                              )
                                  )
GROUP BY pai.patient_appointment_id;
