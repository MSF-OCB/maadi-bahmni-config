set @concept_id = 0;
set @concept_short_id = 0;
set @concept_full_id = 0;
set @count = 0;
set @uuid = NULL;

call add_concept(@concept_id,@concept_short_id,@concept_full_id,"Caritas","Caritas",'N/A','Misc',false);
call add_concept(@concept_id,@concept_short_id,@concept_full_id,"Self Referral","Self Referral",'N/A','Misc',false);
call add_concept(@concept_id,@concept_short_id,@concept_full_id,"Saint Andrew","Saint Andrew",'N/A','Misc',false);
call add_concept(@concept_id,@concept_short_id,@concept_full_id,"UNHCR","UNHCR",'N/A','Misc',false);
