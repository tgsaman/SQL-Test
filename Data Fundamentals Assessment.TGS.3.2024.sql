--1--

CREATE TABLE parkinglot (txt VARCHAR(500) NOT NULL PRIMARY KEY);
INSERT INTO parkinglot (txt) VALUES
('354FKH/JKELLER/2022-05-17$64.50')
,('BMR3408/RJEFFREY/2022-05-18$101.90')
,('KFD478/PMURPHY/2022-05-16$35.85')
,('KFD918/JRIMBAUD/2022-05-16$21.50')
,('PA42391/RDYLAN/2022-05-17$21.50')
,('RA8H5G/AROBINSON/2022-05-17$27.50')
,('RX64421/KSMITH/2022-05-16$21.50');

select* from parkinglot;

with pos_indeces AS (
    SELECT
    txt,
    charindex('/', txt) AS first_slash,
    charindex('/', txt, (charindex('/', txt, 1))+1) AS second_slash,
    charindex('$', txt) AS cashmoney
    from parkinglot)

select
substring(txt, 1, [first_slash]-1) AS vehicle,
substring(txt, [first_slash]+1, [second_slash]-[first_slash]-1) AS cust_name,
CONVERT(DATE, substring(txt, [second_slash]+1, [cashmoney]-[second_slash]-1), 23) AS purchase_date,
CAST(substring(txt, [cashmoney]+1, len(txt)-[cashmoney]+1) AS DECIMAL(6,2)) AS amount_in_$
from pos_indeces;

--2--

CREATE TABLE region (region_code varchar(10) NOT NULL PRIMARY KEY, region_name varchar(50)
NOT NULL, population int NOT NULL);
CREATE TABLE infection (region_code varchar(10) NOT NULL REFERENCES region (region_code), dt
date NOT NULL, new_cases DECIMAL(10,0) NOT NULL, PRIMARY KEY (region_code, dt));
INSERT INTO region (region_code, region_name ,population)
VALUES
('AA', 'Region 1 (AA)', 457040)
,('BF', 'Region 2 (BF)', 527280)
,('CM', 'Region 3 (CM)', 301680);
INSERT INTO infection (region_code,dt,new_cases)
VALUES
('AA', '2021-01-01', 226)
,('AA', '2021-01-15', 280)
,('AA', '2021-02-01', 220)
,('AA', '2021-02-15', 199)
,('BF', '2021-01-01', 140)
,('BF', '2021-01-15', 121)
,('BF', '2021-02-15', 104);

SELECT
inf.region_code,
region_name,
dt,
new_cases,
(new_cases/population*100) as pct,
sum(new_cases) over (partition by inf.region_code order by dt) as running_total
from region as reg
join infection as inf on reg.region_code = inf.region_code
order by dt desc
;

--3--

CREATE TABLE trade (dt DATETIME2(0) NOT NULL PRIMARY KEY, seller_username VARCHAR(50) NOT
NULL, buyer_username VARCHAR(50) NOT NULL);
INSERT INTO trade (dt, seller_username, buyer_username) VALUES
('2019-02-01 08:14:31','wcollins','rjones')
,('2019-02-01 09:22:57','esmith','zchandler')
,('2019-02-01 09:31:39','kthomas','jbennet')
,('2019-02-01 10:21:22','rjones','esmith');

select* from trade

SELECT 
buyer_username as username,
dt,
'buyer' as role
from trade
union ALL
select seller_username,
dt,
'seller' as role
from trade;

--4--

CREATE TABLE loc (code VARCHAR(10) NOT NULL PRIMARY KEY, name VARCHAR(20) NOT NULL UNIQUE,
parent_loc VARCHAR(10) NULL REFERENCES loc (code));
INSERT INTO loc (code, name, parent_loc) VALUES
('USA', 'United States',NULL)
,('NY', 'New York State','USA')
,('NYC', 'New York City','NY')
,('MN', 'Manhattan','NYC')
,('BX', 'Bronx','NYC')
,('BK', 'Brooklyn','NYC')
,('QN', 'Queens','NYC')
,('SI', 'Staten Island','NYC')
,('ABY', 'Albany','NY');

select top (10) * from loc;

with cnt_codes as (
SELECT
parent_loc,
count(code) as cnt
from loc
group by parent_loc)

select
top (10) * from loc
    join cnt_codes on cnt_codes.parent_loc = loc.parent_loc;
