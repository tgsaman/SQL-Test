-- "Run on click" scripting --
/* delete this if you don't want my code to add a new databse to your server! */

IF (NOT EXISTS (SELECT * FROM sys.databases where name = 'TomsTestDB')) 
BEGIN
    CREATE DATABASE TomsTestDB;
END;
USE TomsTestDB;
IF (SCHEMA_ID('TomsTest') IS NULL) 
BEGIN
    EXEC ('CREATE SCHEMA [TomsTest] AUTHORIZATION [dbo]')
END

--1--
/* Each query contains logic to create its requisite table before the question. The IF statement enables each table creation to execute independently even if you modify one of the queries */
IF (NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'parkinglot' AND schema_id = SCHEMA_ID('TomsTest')))
BEGIN

    CREATE TABLE TomsTest.parkinglot (
        txt VARCHAR(500) NOT NULL PRIMARY KEY
    );

    INSERT INTO TomsTest.parkinglot (txt) VALUES
        ('354FKH/JKELLER/2022-05-17$64.50'),
        ('BMR3408/RJEFFREY/2022-05-18$101.90'),
        ('KFD478/PMURPHY/2022-05-16$35.85'),
        ('KFD918/JRIMBAUD/2022-05-16$21.50'),
        ('PA42391/RDYLAN/2022-05-17$21.50'),
        ('RA8H5G/AROBINSON/2022-05-17$27.50'),
        ('RX64421/KSMITH/2022-05-16$21.50');

END;
GO

/* 1. Write a query to extract four columns from the above data based on the following assumptions:
vehicle will be the string that comes before the first / character; name the string between the two
/s and immediately before the date; dt the date, which is always in the format YYYY-MM-DD;
amount which is at the end of the string, always preceded by the $ sign.

In your query, convert the amount column to a DECIMAL and the dt column to a DATE. The result of
your query should be:

vehicle  name       dt          amount
-------- ---------- ----------- -------
354FKH   JKELLER    2022-05-17  64.50
BMR3408  RJEFFREY   2022-05-18  101.90
KFD478   PMURPHY    2022-05-16  35.85
KFD918   JRIMBAUD   2022-05-16  21.50
PA42391  RDYLAN     2022-05-17  21.50
RA8H5G   AROBINSON  2022-05-17  27.50
RX64421  KSMITH     2022-05-16  21.50 */

WITH pos_indeces AS (
    SELECT
    txt,
    charindex('/', txt) AS first_slash,
    charindex('/', txt, (charindex('/', txt, 1))+1) AS second_slash,
    charindex('$', txt) AS cashmoney
    from TomsTest.parkinglot)

SELECT
substring(txt, 1, [first_slash]-1) AS vehicle,
substring(txt, [first_slash]+1, [second_slash]-[first_slash]-1) AS cust_name,
CONVERT(DATE, substring(txt, [second_slash]+1, [cashmoney]-[second_slash]-1), 23) AS purchase_date,
CAST(substring(txt, [cashmoney]+1, len(txt)-[cashmoney]+1) AS DECIMAL(6,2)) AS amount_in_$
FROM pos_indeces;

--2--
/* Each query contains logic to create its requisite table before the question. */
IF (NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'region' AND schema_id = SCHEMA_ID('TomsTest')))
BEGIN

    CREATE TABLE TomsTest.region (
        region_code VARCHAR(10) NOT NULL PRIMARY KEY, 
        region_name VARCHAR(50) NOT NULL, 
        population INT NOT NULL
    );

    INSERT INTO TomsTest.region (region_code, region_name, population) VALUES
        ('AA', 'Region 1 (AA)', 457040),
        ('BF', 'Region 2 (BF)', 527280),
        ('CM', 'Region 3 (CM)', 301680);

END;
GO

IF (NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'infection' AND schema_id = SCHEMA_ID('TomsTest')))
BEGIN

    CREATE TABLE TomsTest.infection (
        region_code VARCHAR(10) NOT NULL, 
        dt DATE NOT NULL, 
        new_cases DECIMAL(10, 0) NOT NULL, 
        PRIMARY KEY (region_code, dt),
        FOREIGN KEY (region_code) REFERENCES TomsTest.region (region_code)
    );

    INSERT INTO TomsTest.infection (region_code, dt, new_cases) VALUES
        ('AA', '2021-01-01', 226),
        ('AA', '2021-01-15', 280),
        ('AA', '2021-02-01', 220),
        ('AA', '2021-02-15', 199),
        ('BF', '2021-01-01', 140),
        ('BF', '2021-01-15', 121),
        ('BF', '2021-02-15', 104);

END;
GO

/* 2. Write a query to show regions, dates, new_cases plus a percentage (new_cases as a percentage of
the total population of the region), and the cumulative total of cases (total new_cases for the
region up until that date). The number of decimal places in the percentage is not important - no
need to round it. The result should be as follows:

region_code region_name      dt         new_cases  pct          cumulative_total
----------- ---------------- ---------- ---------- ------------ -----------------
AA          Region 1 (AA)    2021-01-01 226        0.049        226
AA          Region 1 (AA)    2021-01-15 280        0.061        506
AA          Region 1 (AA)    2021-02-01 220        0.048        726
AA          Region 1 (AA)    2021-02-15 199        0.044        925
BF          Region 2 (BF)    2021-01-01 140        0.027        140
BF          Region 2 (BF)    2021-01-15 121        0.023        261
BF          Region 2 (BF)    2021-02-15 104        0.020        365 */

SELECT
    inf.region_code,
    reg.region_name,
    inf.dt,
    inf.new_cases,
    (inf.new_cases / CAST(reg.population AS DECIMAL(10, 5))) AS pct,
    SUM(inf.new_cases) OVER (PARTITION BY inf.region_code ORDER BY inf.dt) AS cumulative_total
FROM TomsTest.region AS reg
JOIN TomsTest.infection AS inf ON reg.region_code = inf.region_code
ORDER BY inf.dt DESC;
GO

--3--
/* Each query contains logic to create its requisite table before the question. */
IF (NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'trade' AND schema_id = SCHEMA_ID('TomsTest')))
BEGIN

   CREATE TABLE TomsTest.trade (
       dt DATETIME2(0) NOT NULL PRIMARY KEY, 
       seller_username VARCHAR(50) NOT NULL, 
       buyer_username VARCHAR(50) NOT NULL
   );

    INSERT INTO TomsTest.trade (dt, seller_username, buyer_username) 
    VALUES
    ('2019-02-01 08:14:31', 'wcollins', 'rjones'),
    ('2019-02-01 09:22:57', 'esmith', 'zchandler'),
    ('2019-02-01 09:31:39', 'kthomas', 'jbennet'),
    ('2019-02-01 10:21:22', 'rjones', 'esmith');

END;
GO

/* 3. Write a query that returns all the buyers and sellers
in a single column with the date and a role column that identifies whether the user is a buyer or a
seller. The required output is shown below.

username   dt                          role
---------- --------------------------- ------
wcollins   2019-02-01 08:14:31         SELLER
esmith     2019-02-01 09:22:57         SELLER
kthomas    2019-02-01 09:31:39         SELLER
rjones     2019-02-01 10:21:22         SELLER
rjones     2019-02-01 08:14:31         BUYER
zchandler  2019-02-01 09:22:57         BUYER
jbennet    2019-02-01 09:31:39         BUYER
esmith     2019-02-01 10:21:22         BUYER */

SELECT 
    buyer_username AS username,
    dt,
    'BUYER' AS role
FROM TomsTest.trade
UNION ALL
SELECT 
    seller_username,
    dt,
    'SELLER' AS role
FROM TomsTest.trade;
GO

--4--
/* Each query contains logic to create its requisite table before the question. */
IF (NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'loc' AND schema_id = SCHEMA_ID('TomsTest')))
BEGIN

    CREATE TABLE TomsTest.loc (
        code VARCHAR(10) NOT NULL PRIMARY KEY, 
        name VARCHAR(20) NOT NULL UNIQUE,
        parent_loc VARCHAR(10) NULL REFERENCES TomsTest.loc (code)
    );

    INSERT INTO TomsTest.loc (code, name, parent_loc) VALUES
        ('USA', 'United States', NULL),
        ('NY', 'New York State', 'USA'),
        ('NYC', 'New York City', 'NY'),
        ('MN', 'Manhattan', 'NYC'),
        ('BX', 'Bronx', 'NYC'),
        ('BK', 'Brooklyn', 'NYC'),
        ('QN', 'Queens', 'NYC'),
        ('SI', 'Staten Island', 'NYC'),
        ('ABY', 'Albany', 'NY');

END;
GO

/* 4. Write a query that returns every location with a count of how many sublocations it has directly within it. Each location except USA has a “parent” location that contains it. 
Your answer should be as follows:

code       name                 cnt
---------- -------------------- -----------
ABY        Albany               0
BK         Brooklyn             0
BX         Bronx                0
MN         Manhattan            0
NY         New York State       2
NYC        New York City        5
QN         Queens               0
SI         Staten Island        0
USA        United States        1 */ 

WITH cnt_codes AS (
SELECT
parent_loc,
COUNT(code) AS cnt
FROM TomsTest.loc
GROUP BY parent_loc
)

SELECT
    loc.code,
    loc.name,
    ISNULL(cnt_codes.cnt, 0) AS cnt
FROM TomsTest.loc
LEFT JOIN cnt_codes ON loc.code = cnt_codes.parent_loc;
GO

--5-- 
/* Each query contains logic to create its requisite table before the question. */
IF (NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'asset' AND schema_id = SCHEMA_ID('TomsTest')))
BEGIN

    CREATE TABLE TomsTest.asset (
        asset_num INTEGER NOT NULL PRIMARY KEY, 
        account_num VARCHAR(10) NOT NULL,
        currency_code CHAR(3) NOT NULL, 
        amount DECIMAL(10,2) NOT NULL
    );

    INSERT INTO TomsTest.asset (asset_num, account_num, currency_code, amount)
    VALUES
    (11,'A32814','GBP', 82470),
    (12,'A70155','EUR', 92230),
    (13,'A83866','USD', 268105),
    (14,'A32814','USD', 191400),
    (15,'A70155','EUR', 129000),
    (16,'A16786','HKD', 300400),
    (17,'A70155','GBP', 601000),
    (18,'A32814','EUR', 45500),
    (19,'A83866','EUR', 23850),
    (20,'A83866','EUR',118090);

END;
GO

/* 5. Write a query that returns one row per account_num and currency code, but filter results to just the accounts where both EUR and
GBP currency_codes are present. Include the total amount and a count of the number of rows in the original table. 

Your result should have 5 rows as follows:

account_num currency_code amount       cnt
----------- ------------- ------------ -----
A32814      EUR           45500.00     1
A32814      GBP           82470.00     1
A32814      USD           191400.00    1
A70155      EUR           221230.00    2
A70155      GBP           601000.00    1 */

SELECT 
    account_num, 
    currency_code, 
    SUM(amount) AS totalamount, 
    COUNT(*) AS cnt 
FROM 
    TomsTest.asset
WHERE 
    account_num IN (
        SELECT account_num 
        FROM tomstest.asset 
        WHERE currency_code IN ('EUR', 'GBP')
        GROUP BY account_num
        HAVING COUNT(DISTINCT currency_code) = 2
    )
GROUP BY 
    account_num, 
    currency_code;

--6--
/* Table relationship practice; see ERD in question PDF */

IF (NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'currency' AND schema_id = SCHEMA_ID('TomsTest')))
BEGIN
    CREATE TABLE TomsTest.currency (
        CurrencyCode NVARCHAR(3) NOT NULL PRIMARY KEY,
        CurrencyName NVARCHAR(36)
    );
END;
GO

IF (NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'transact' AND schema_id = SCHEMA_ID('TomsTest')))
BEGIN
    CREATE TABLE TomsTest.transact (
        TransactID VARCHAR(25) NOT NULL PRIMARY KEY,
        TransactDate DATE
    );
END;
GO

IF (NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'invoice' AND schema_id = SCHEMA_ID('TomsTest')))
BEGIN
    CREATE TABLE TomsTest.invoice (
        InvoiceNum VARCHAR(20) NOT NULL PRIMARY KEY,
        InvoiceDate DATE,
        InvoiceAmount DECIMAL(10,2),
        CurrencyCode NVARCHAR(3) NOT NULL,
        FOREIGN KEY (CurrencyCode) REFERENCES TomsTest.currency(CurrencyCode)
    );
END;
GO

IF (NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'payment' AND schema_id = SCHEMA_ID('TomsTest')))
BEGIN
    CREATE TABLE TomsTest.payment (
        InvoiceNum VARCHAR(20) NOT NULL,
        TransactID VARCHAR(25) NOT NULL,
        PaymentAmount DECIMAL(12,2),
        CurrencyCode NVARCHAR(3),
        PRIMARY KEY (InvoiceNum, TransactID),
        FOREIGN KEY (InvoiceNum) REFERENCES TomsTest.invoice(InvoiceNum),
        FOREIGN KEY (TransactID) REFERENCES TomsTest.transact(TransactID),
        FOREIGN KEY (CurrencyCode) REFERENCES TomsTest.currency(CurrencyCode)
    );
END;
GO