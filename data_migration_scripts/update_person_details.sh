#!/bin/bash
while read line
do
    IFS=',' read -r -a row <<< "$line"
                person_name_details=" update person_name set given_name = '${row[2]}' , middle_name = '${row[3]}' ,
                family_name = '' where person_id = (select patient_id from patient_identifier where identifier = '${row[0]}'
                and voided = 0 ); "

                person_details=" update person set gender = '${row[5]}' , birthdate = '${row[6]}' , date_created = '${row[1]}'
                where person_id = (select patient_id from patient_identifier where identifier = '${row[0]}' and voided = 0 ); "
                
                patient_datecreated=" update patient set  date_created = '${row[1]}'  where patient_id = (select patient_id from
                patient_identifier where identifier = '${row[0]}' and voided = 0 ); "
 
    updateQuery+="$person_name_details $person_details $patient_datecreated"

done < $1
echo $updateQuery
echo $updateQuery | mysql -uroot -p$PleaseEnterPassword  openmrs
