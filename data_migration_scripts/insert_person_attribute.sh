#!/bin/bash

while read line
do
    IFS=',' read -r -a row <<< "$line"
person_address=" insert into person_address (person_id,city_village,state_province,creator,date_created,voided,county_district,uuid) values ((select patient_id from patient_identifier where identifier = '${row[0]}' and voided = 0), IFNULL('${row[7]}',''),IFNULL('${row[9]}',''), (select user_id from users where username='admin'), now(), 0, IFNULL('${row[8]}',''), uuid()); "

person_attribute_nationality=" insert into person_attribute (person_id,value,person_attribute_type_id,creator,date_created,voided,uuid) values((select patient_id from patient_identifier where identifier = '${row[0]}' and voided = 0),IFNULL((SELECT concept_id from concept_view where concept_full_name = '${row[10]}' and retired = 0),''),(select person_attribute_type_id from person_attribute_type where name = 'Nationality' and retired = 0),(select user_id from users where username='admin'), now(), 0, uuid()); "

person_attribute_otherNationality=" insert into person_attribute (person_id,value,person_attribute_type_id,creator,date_created,voided,uuid) values((select patient_id from patient_identifier where identifier = '${row[0]}' and voided = 0),IFNULL('${row[11]}',''),(select person_attribute_type_id from person_attribute_type where name = 'Other Nationality' and retired = 0),(select user_id from users where username='admin'), now(), 0, uuid()); "

person_attribute_phone1=" insert into person_attribute (person_id,value,person_attribute_type_id,creator,date_created,voided,uuid) values((select patient_id from patient_identifier where identifier = '${row[0]}' and voided = 0),IFNULL('${row[12]}',''),(select person_attribute_type_id from person_attribute_type where name = 'Phone1' and retired = 0),(select user_id from users where username='admin'), now(), 0, uuid()); "

person_attribute_phone2=" insert into person_attribute (person_id,value,person_attribute_type_id,creator,date_created,voided,uuid) values((select patient_id from patient_identifier where identifier = '${row[0]}' and voided = 0),IFNULL('${row[13]}',''),(select person_attribute_type_id from person_attribute_type where name = 'Phone2' and retired = 0),(select user_id from users where username='admin'), now(), 0, uuid()); "

person_attribute_UNnumber=" insert into person_attribute (person_id,value,person_attribute_type_id,creator,date_created,voided,uuid) values((select patient_id from patient_identifier where identifier = '${row[0]}' and voided = 0),IFNULL('${row[14]}',''),(select person_attribute_type_id from person_attribute_type where name = 'UN number' and retired = 0),(select user_id from users where username='admin'), now(), 0, uuid()); "

person_attribute_otherID=" insert into person_attribute (person_id,value,person_attribute_type_id,creator,date_created,voided,uuid) values((select patient_id from patient_identifier where identifier = '${row[0]}' and voided = 0),IFNULL('${row[15]}',''),(select person_attribute_type_id from person_attribute_type where name = 'Other ID' and retired = 0),(select user_id from users where username='admin'), now(), 0, uuid()); "

person_attribute_Language=" insert into person_attribute (person_id,value,person_attribute_type_id,creator,date_created,voided,uuid) values((select patient_id from patient_identifier where identifier = '${row[0]}' and voided = 0),IFNULL((SELECT concept_id from concept_view where concept_full_name = '${row[16]}' and retired = 0),''),(select person_attribute_type_id from person_attribute_type where name = 'Language' and retired = 0),(select user_id from users where username='admin'), now(), 0, uuid()); "

person_attribute_OtherLanguage=" insert into person_attribute (person_id,value,person_attribute_type_id,creator,date_created,voided,uuid) values((select patient_id from patient_identifier where identifier = '${row[0]}' and voided = 0),IFNULL('${row[17]}',''),(select person_attribute_type_id from person_attribute_type where name = 'Other Language' and retired = 0),(select user_id from users where username='admin'), now(), 0, uuid()); "

person_attribute_patScope=" insert into person_attribute (person_id,value,person_attribute_type_id,creator,date_created,voided,uuid) values((select patient_id from patient_identifier where identifier = '${row[0]}' and voided = 0),IFNULL((SELECT concept_id from concept_view where concept_full_name = '${row[18]}' and retired = 0),''),(select person_attribute_type_id from person_attribute_type where name = \"Patient's scope\" and retired = 0),(select user_id from users where username='admin'), now(), 0, uuid()); "

person_attribute_inScopeDate=" insert into person_attribute (person_id,value,person_attribute_type_id,creator,date_created,voided,uuid) values((select patient_id from patient_identifier where identifier = '${row[0]}' and voided = 0),IFNULL('${row[19]}',''),(select person_attribute_type_id from person_attribute_type where name = 'In-scope Date' and retired = 0),(select user_id from users where username='admin'), now(), 0, uuid()); "

person_attribute_hrMSF=" insert into person_attribute (person_id,value,person_attribute_type_id,creator,date_created,voided,uuid) values((select patient_id from patient_identifier where identifier = '${row[0]}' and voided = 0),IFNULL((SELECT concept_id from concept_view where concept_full_name = '${row[20]}' and retired = 0),''),(select person_attribute_type_id from person_attribute_type where name = 'How reach MSF' and retired = 0),(select user_id from users where username='admin'), now(), 0, uuid()); "

delete_empty_attributes=" DELETE from person_attribute where value=''; "

    insertQuery+="$person_address $person_attribute_nationality $person_attribute_otherNationality $person_attribute_phone1 $person_attribute_phone2 $person_attribute_UNnumber $person_attribute_otherID $person_attribute_Language $person_attribute_OtherLanguage $person_attribute_patScope $person_attribute_inScopeDate $person_attribute_hrMSF $delete_empty_attributes"
done < $1
echo $insertQuery
echo $insertQuery | mysql -uroot -p$PleaseEnterPassword  openmrs
