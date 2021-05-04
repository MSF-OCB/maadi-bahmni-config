SELECT
    identifierOfPatient.identifier AS "Patient ID",
    concat_ws(' ', nameOfTheProviders.given_name, nameOfTheProviders.family_name) AS "Provider",
    serviceAppointment.name AS "Appointment Service",
    serviceTypeAppointment.name AS "Appointment Service Type",
    DATE(pai.start_date_time) AS "Date Of Appointment",
    DATE_FORMAT(pai.start_date_time, '%I:%i %p') AS "Appointment Start Time",
    DATE_FORMAT(pai.end_date_time, '%I:%i %p') AS "Appointment End Time",
    pai.status AS "Status",
    (CASE WHEN pai.status in('Scheduled') then NULL ELSE DATE_FORMAT(CONVERT_TZ(appCheckinTime.notes,'+00:00','+05:30'),'%I:%i %p') END) AS "Start CheckedIn Time",
    (CASE WHEN language.concept_full_name is not null and otherLanguage.value is Not NULL
      then concat_ws(', ',language.concept_full_name,otherLanguage.value)
      WHEN language.concept_full_name is not null and otherLanguage.value is NULL then language.concept_full_name
      WHEN language.concept_full_name is null and otherLanguage.value is NOT NULL THEN otherLanguage.value
      ELSE NULL END) AS "Patient's Language",
  pai.comments AS "Notes"

FROM
  patient pa
  LEFT JOIN patient_appointment pai ON pa.patient_id = pai.patient_id and pai.voided = 0
  LEFT JOIN
            (/*getting checkin time*/
            SELECT
            latest_appointment_audit.appointment_id,
            latest_appointment_audit.notes,
            latest_appointment_audit.date_created,
            pa.patient_id,
            latest_appointment_audit.status
            FROM
            patient_appointment pa
            INNER JOIN
            (
            SELECT
                latest_appointment_audit.appointment_id,
                latest_appointment_audit.notes,
                latest_appointment_audit.date_created,
                pa.patient_id,
                latest_appointment_audit.status
            FROM
                patient_appointment pa
                INNER JOIN
                    (
                        SELECT
                            paa.patient_appointment_audit_id,
                            paa.appointment_id,
                            paa.date_created,
                            paa.notes,
                            paa.status
                        FROM
                            patient_appointment_audit paa
                            INNER JOIN
                                (
                                    /*getting latest status of appointment*/
                                    SELECT
                                        MAX(paa.date_created) AS date_created,
                                        paa.appointment_id,
                                        paa.notes
                                    FROM
                                        patient_appointment_audit paa
                                    WHERE
                                        paa.status = 'CheckedIn'
                                    GROUP BY
                                        paa.appointment_id
                                )
                                latest_audit_for_appointment
                                ON latest_audit_for_appointment.appointment_id = paa.appointment_id
                                AND latest_audit_for_appointment.date_created = paa.date_created
                    )
                    latest_appointment_audit
                    ON pa.patient_appointment_id = latest_appointment_audit.appointment_id
                    AND pa.voided = 0
            )
            latest_appointment_audit
            ON pa.patient_appointment_id = latest_appointment_audit.appointment_id
            AND pa.voided = 0
            ) as appCheckinTime on pai.patient_id = appCheckinTime.patient_id and appCheckinTime.appointment_id = pai.patient_appointment_id
  LEFT JOIN appointment_service serviceAppointment ON   pai.appointment_service_id = serviceAppointment.appointment_service_id AND serviceAppointment.voided = 0
  LEFT JOIN appointment_service_type serviceTypeAppointment ON serviceAppointment.appointment_service_id = serviceTypeAppointment.appointment_service_id  AND pai.appointment_service_type_id = serviceTypeAppointment.appointment_service_type_id AND serviceTypeAppointment.voided = 0
  LEFT JOIN patient_identifier identifierOfPatient ON pai.patient_id = identifierOfPatient.patient_id
  LEFT JOIN visit checkinTime ON pai.patient_id = checkinTime.patient_id AND DATE(checkinTime.date_started) = DATE(pai.start_date_time)/*getting Start visit time*/
  LEFT JOIN provider providerForAppointment ON pai.provider_id = providerForAppointment.provider_id
  LEFT JOIN person_name nameOfTheProviders ON providerForAppointment.person_id = nameOfTheProviders.person_id
  LEFT JOIN person_attribute attributeOfPatient ON pai.patient_id = attributeOfPatient.person_id
  LEFT JOIN person_attribute_type typeOfPatientAttribute ON attributeOfPatient.person_attribute_type_id = typeOfPatientAttribute.person_attribute_type_id
  LEFT JOIN concept_view cv ON cv.concept_id = attributeOfPatient.value
  Left Join
  (/*Getting the value for language*/
        SELECT
        attributeOfPatient.person_id,
        cv.concept_full_name
        FROM
        person_attribute attributeOfPatient
        INNER JOIN
            person_attribute_type typeOfPatientAttribute
            ON attributeOfPatient.person_attribute_type_id = typeOfPatientAttribute.person_attribute_type_id
        INNER JOIN
            concept_view cv
            ON cv.concept_id = attributeOfPatient.VALUE
        WHERE
        typeOfPatientAttribute.name = "Language"
        AND attributeOfPatient.voided = 0
  ) as language on pai.patient_id = language.person_id

  Left join
 (/*Getting the value for Other language*/
        SELECT
        attributeOfPatient.person_id,
        attributeOfPatient.VALUE
        FROM
        person_attribute attributeOfPatient
        INNER JOIN
            person_attribute_type typeOfPatientAttribute
            ON attributeOfPatient.person_attribute_type_id = typeOfPatientAttribute.person_attribute_type_id
        WHERE
        typeOfPatientAttribute.name = "Other Language"
        AND attributeOfPatient.voided = 0
  ) as otherLanguage on pai.patient_id = otherLanguage.person_id

WHERE
  DATE(pai.start_date_time) BETWEEN DATE('#startDate#') AND DATE('#endDate#')
  AND pai.appointment_service_id IN
                                  (
                                    SELECT appointment_service_id
                                    FROM appointment_service
                                    where voided = 0
                                  )
  AND identifierOfPatient.identifier not in ('A00000')/*removing dummy patient from reports*/
GROUP BY pai.patient_appointment_id
ORDER BY pai.start_date_time;
