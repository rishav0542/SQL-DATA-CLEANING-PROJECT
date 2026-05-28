USE SELF_PRACTICE;
SELECT * FROM MESSY1;
DESCRIBE MESSY1;

#INITIAL_CLEANING

DELETE FROM MESSY1 WHERE CUSTOMER_ID='C012';  #THIS ROW WAS FILLED WITH NULL VALUES

#FULL_NAME_CLEANING

SELECT FULL_NAME FROM MESSY1;
UPDATE MESSY1 SET FULL_NAME=REGEXP_REPLACE(FULL_NAME,'[.\\s-]+'," "); #REPLACED EXTRA SPACES AND (". \")
UPDATE MESSY1 SET FULL_NAME=REGEXP_REPLACE(FULL_NAME,'K',"") where full_name='K RISHAV SINGH';
UPDATE MESSY1 SET FULL_NAME=LOWER(TRIM(FULL_NAME)); #CONVERTED ALL INTO LOWER CASES
UPDATE MESSY1 SET FULL_NAME = CONCAT(UPPER(SUBSTR(FULL_NAME,1,1)),LOWER(SUBSTR(FULL_NAME,2,LOCATE(' ',FULL_NAME)-1)),
UPPER(SUBSTR(FULL_NAME,LOCATE(' ',FULL_NAME)+1,1)),LOWER(SUBSTR(FULL_NAME,LOCATE(' ',FULL_NAME)+2))); #CONVERTED INTO PROPER CASING
UPDATE MESSY1 SET FULL_NAME=SUBSTR(FULL_NAME,2,1) WHERE FULL_NAME='Ssuresh';
UPDATE MESSY1 SET FULL_NAME='Suresh' WHERE FULL_NAME='s';
UPDATE MESSY1 
SET FULL_NAME='Mary Ann Smith'
WHERE FULL_NAME='Mary Ann smith';
COMMIT;

#CREATED INDEX ON SOME COLUMNS AND CHANGED THE DATA TYPES OF SOME COLUMNS 

describe messy1;
explain SELECT * FROM MESSY1;
alter table messy1 modify customer_id varchar(255);
create index messy_idx on messy1(customer_id asc);
alter table messy1 modify full_name varchar(255);
SELECT * FROM MESSY1;

#CLEANING EMAIL COLUMN 

UPDATE MESSY1 SET EMAIL=REGEXP_REPLACE(EMAIL,'@@','@');
UPDATE MESSY1 SET EMAIL=REPLACE(EMAIL,'email.com','gmail.com');
UPDATE MESSY1 SET EMAIL=LOWER(TRIM(EMAIL));
COMMIT;

#CLEANING PHONE-NUMBER COLUMN 

#REPLACING EVERY UNWANTED CHARACTERS IN PHONE NO. AND REMOVING WHITESPACES
update messy1 set phone=replace(replace(replace(replace(replace(replace(phone,'091','+91'),'+1 (555) ','+555-'),
'(555)','+555'),'-12345','12345'),'+44 ','+44-'),'-1234','1234');
update messy1 set phone=replace(replace(phone,'9876543210','+91-9876543210'),'9876512345','+91-9876512345');
update messy1 set phone=replace(replace(phone,'9999999999','+91-9999999999'),'91-88888-77777','+91-8888877777');
update messy1 set phone=replace(phone,'234-','234');
update messy1 set phone=null where phone='N/A';
update messy1 set phone=null where phone='-';
update messy1 set phone=trim(phone);
commit;

#CLEANING ADDRESS 
select * from messy1;
rollback; 
update messy1 
set address=trim(address);
update messy1
set address=null
where address='';
update messy1
set address=regexp_replace(address,' +',' ');
update messy1
set address=concat(regexp_replace(upper(substring_index(address,' ',1)),
'([0-9]+)([a-z])','$1-$2'),' ',
concat(upper(left(substring_index(substring_index(address,' ',2),' ',-1),1)),
       lower(substring(substring_index(substring_index(address,' ',2),' ',-1),2)),' ',
       upper(left(substring_index(address,' ',-1),1)),
       lower(substring(substring_index(address,' ',-1),2))
       )
       )
       where address in ('221B baker street','742 evergreen terrace','45 wall st.'); 
update messy1
set address='Plot No-5,Sector 21' where address='sector 21, plot no-5';  
  

select * from messy1;     
update messy1
set address=if(locate(' ',address)>0,concat(upper(left(substring_index(address,' ',1),1)),
lower(substring(substring_index(address,' ',1),2)),' ',
upper(left(substring_index(address,' ',-1),1)),
lower(substring(substring_index(address,' ',-1),2))),'Indirapuram') 
where address not in ('221-B Baker Street','742 Evergreen Terrace','45 Wall St.','Plot No-5,Sector 21'); 

#CLEANING CITY 
update messy1
set city=lower(trim(city));
update messy1
set city=regexp_replace(city,' +',' '); 

update messy1
set city=concat(upper(substring(city,1,1)),if(locate(' ',city)>0,concat(lower(substring(city,2,locate(' ',city)-1)),
upper(substring(city,locate(' ',city)+1,1)),lower(substring(city,locate(' ',city)+2))),lower(substring(city,2))));

commit;  

#CLEANING STATE-ABBREVIATIONS

select * from messy1;
update messy1
set state=null
where state=' ';

update messy1
set state=trim(state);

update messy1
set state='Maharashtra'
where state='MH';
update messy1
set state='Karnataka'
where state='ka';
update messy1
set state='New York'
where state='NY';
update messy1
set state='Telangana'
where state='ts'; 
update messy1
set state='Uttar Pradesh'
where state='UP';
update messy1
set state='Illinois'
where state='il';
update messy1
set state='Delhi'
where state='delhi';
update messy1
set state=concat(upper(left(state,1)),lower(substring(state,2)));
commit;

#DATE_CLEANING

select order_date from messy1;
select order_date, str_to_date(order_date,'%d-%m-%Y') as Normal_Date from messy1;
alter table messy1 modify column order_date date;

update messy1
set order_date='3/25/2023'
where order_date='25/03/2023';
update messy1
set order_date=case when order_date like '%/%/%'then date_format(str_to_date(order_date,'%m/%d/%Y'),'%d-%m-%Y') 
when order_date like '%.%.%'then date_format(str_to_date(order_date,'%Y.%m.%d'),'%d-%m-%Y')
when order_date like '%-%-%'then date_format(str_to_date(order_date,'%d-%m-%y'),'%d-%m-%Y')
else order_date
end;
commit; 
 
 #CLEANING ORDER_AMOUNT
select * from messy1;

update messy1 
set order_amount=replace(regexp_replace(order_amount,'[$?,£A-Za-z//s-]+',''),'. 2300','2300');

update messy1 
set order_amount=trim(order_amount);

update messy1 
set order_amount=null
where order_amount='';
commit;

#CLEANED_PAYMENT_MODE
update messy1
set payment_mode=lower(trim(payment_mode));

update messy1
set payment_mode=if(locate(' ',payment_mode)>0,
concat(upper(left(payment_mode,1)),
lower(substring(payment_mode,2,locate(' ',payment_mode)-1)),
upper(substring(payment_mode,locate(' ',payment_mode)+1,1)),
lower(substring(payment_mode,locate(' ',payment_mode)+2))),
concat(upper(left(payment_mode,1)),
lower(substring(payment_mode,2))));

#CLEANED_CUSTOMER_STATUS
update messy1
set customer_status=concat(upper(left(trim(customer_status),1)),lower(substring(trim(customer_status),2)));

#CLEANED_NOTES 
update messy1
set notes=trim(notes);
select notes from messy1;
update messy1
set notes=null
where notes in ('-','');

update messy1
set notes=if(locate(' ',notes)>0,
concat(upper(left(notes,1)),
lower(substring(notes,2,locate(' ',notes)-1)),
upper(substring(notes,locate(' ',notes)+1,1)),
lower(substring(notes,locate(' ',notes)+2))),
concat(upper(left(notes,1)),
lower(substring(notes,2))));

#CHANGED THE COLUMN TITLES WITH STORED PROCEDURE
CALL CAPITALIZECOLUMNS('MESSY1');


SELECT * FROM MESSY1;