create database CaseStudy1;
use caseStudy1;

#Converting text date to date-format
#Spend table
UPDATE spendtable
SET date=str_to_date(Date, '%M %e, %Y');

UPDATE spendtable
SET Channel_name='Tiktok'
WHERE Channel_name='titok';

select * from spendtable;
describe spendtable;

#Cookie_Table
#Converting text Date to Date Format
UPDATE cookietable
SET date=str_to_date(Date, '%M %e, %Y');


#Splitting the cookie_message column into first_click_channel and last_value_channel
ALTER TABLE cookietable
ADD COLUMN first_click_channel varchar(40),
ADD COLUMN last_click_channel varchar(40),
ADD COLUMN final_replace_value varchar(60),
ADD COLUMN final_cookie_message varchar(40);

UPDATE cookietable
SET last_click_channel=substring_index(final_replace_value,' ',-1);
SET first_click_channel=substring_index(final_replace_value,' ',1);
SET final_replace_value=trim(replace(replace(replace(Cookie_message,right(Cookie_message,1), ''),left(Cookie_message,1), ''), ',', ' '));
SET final_cookie_message=replace(replace(Cookie_message,right(Cookie_message,1), ''),left(Cookie_message,1), '');

select * from cookietable;
describe cookietable;

#Creating the attribution table and adding values into it from the modified cookie table
CREATE TABLE Attribution
(
   Dates DATE,
   cookie_message varchar(60),
   first_click_channel varchar(60),
   last_click_channel varchar(60)
   
);

INSERT INTO Attribution(Dates,cookie_message,first_click_channel,last_click_channel)
select Date,Cookie_message,first_click_channel,last_click_channel
from cookietable;

select * from attribution;

#Analyis on attribution table
select dates,first_click_channel,count(*) as channel_click_per_date
from attribution
group by dates,first_click_channel;

#Creating the KPI table and Adding values into it.
CREATE TABLE KPIS
(
   Dates date,
   Channel_Name varchar(60),
   spend int,
   channel_click_per_date int
);

INSERT INTO KPIS(Dates,Channel_name,spend,channel_click_per_date)
with cte1 as 
(select dates,first_click_channel,count(*) as channel_click_per_date
from attribution
group by dates,first_click_channel
)
select a.dates,b.channel_name,b.spend,a.channel_click_per_date 
from cte1 a 
inner join spendtable b on (a.Dates=b.Date and a.first_click_channel=b.channel_name);

select * from kpis;

#Calculating the Relevant kpis
ALTER TABLE KPIS
ADD COLUMN Cost_per_click float,
ADD COLUMN Click_through_Rate float,
ADD COLUMN Cost_per_Mille float;

UPDATE KPIS
SET Cost_per_Mille=round(spend/channel_click_per_date,2)*1000;
SET Click_through_Rate=round(channel_click_per_date/spend,2);
SET Cost_per_click=round(spend/channel_click_per_date,2);


select * from kpis;

#Calculations on kpi table
#1) Average Cost per click for each channel
select channel_name,round(sum(spend)/sum(channel_click_per_date),2)
from kpis
group by channel_name;

#2)Average spend per day for each channel
select channel_name,avg(spend) as avg_spent_per_day
from kpis
group by channel_name;

#3)Spend percentage for each channel
select channel_name,round(sum(spend)/(select sum(spend) from kpis),2)*100
from kpis
group by channel_name;

#4)Avg click through rate for each channel
select channel_name,avg(click_through_Rate) as Avg_Ctr_Per_Channel
from kpis
group by channel_name;

#5)Average Cost Per Thousand impressions
select channel_name,round(avg(cost_per_mille),2) as Avg_CPM_Per_Channel
from kpis
group by channel_name;

#6)average click per date for each channel
select channel_name,avg(channel_click_per_date) as avg_click_count
from kpis
group by  channel_name








