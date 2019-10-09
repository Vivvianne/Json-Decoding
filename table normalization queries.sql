DROP TABLE IF EXISTS `T`;
CREATE TABLE `T` (
`n` int(11)
);

INSERT INTO `T`(n) SELECT @row := @row + 1 as rowx FROM
(select 0 union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) t,
(select 0 union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) t2,
(select 0 union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) t3,
(select 0 union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) t4,
(select 0 union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) t5,
(select 0 union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) t6,
(SELECT @row:=0) t7;

# time span
SET @d0 = "2019-01-01";
SET @d1 = "2020-12-31";
 
SET @date = date_sub(@d0, interval 1 day);
 
# set up the time dimension table
DROP TABLE IF EXISTS dim_date;
CREATE TABLE `dim_date` (
  `date` date DEFAULT NULL,
  `date_id` int NOT NULL,
  `year_id` smallint DEFAULT NULL,
  `year_cal` smallint DEFAULT NULL,
  `week_cal` smallint DEFAULT NULL,
  `quarter_cal` smallint DEFAULT NULL,
  `day_of_week` smallint DEFAULT NULL,
  `month_name`  char(10) DEFAULT NULL,
  `week_name` char(10) DEFAULT NULL,
  PRIMARY KEY (`date_id`)
);
 
# populate the table with dates
INSERT INTO dim_date
SELECT @date := date_add(@date, interval 1 day) as date,
    # integer ID that allows immediate understanding
    date_format(@date, "%Y%m%d") as date_id,
    year(@date) as year_id,
    date_format(@date, "%x") as year_cal,
    week(@date, 3) as week_cal,
    quarter(@date) as quarter_cal,
    weekday(@date)+1 as day_of_week,
    monthname(@date) as month_name,
    dayname(@date) as week_name
FROM T
WHERE date_add(@date, interval 1 day) <= @d1
ORDER BY date DESC
;

# client table
DROP TABLE IF EXISTS dim_client;
CREATE TABLE dim_client (
    clientid int NOT NULL AUTO_INCREMENT,
    clientname varchar(255) NOT NULL,
    mobileno varchar(255),
    contactype varchar(255),
    PRIMARY KEY (clientid,clientname,mobileno)
);

INSERT INTO dim_client (clientname, mobileno, contactype)
SELECT DISTINCT CLIENTNAME, MOBILENO,contactType FROM SRC_INTERVIEW;

# question table
DROP TABLE IF EXISTS dim_question;
CREATE TABLE dim_question (
    questionid int NOT NULL AUTO_INCREMENT,
    questionsubtype varchar(255) NOT NULL,
    questiontype varchar(255),
    PRIMARY KEY (questionid,questionsubtype)
);

INSERT INTO dim_question (questionsubtype, questiontype)
select distinct  questionsubtype, questiontype from test.src_interview;

# store table
DROP TABLE IF EXISTS dim_store;
CREATE TABLE dim_store (
    storeid int NOT NULL AUTO_INCREMENT,
    storename varchar(255) NOT NULL,
    PRIMARY KEY (storeid,storename)
);

INSERT INTO dim_store (storename)
select distinct  storename from test.src_interview;

# fact table 
DROP TABLE IF EXISTS fct_interview;
CREATE TABLE `fct_interview` (
  `dateCreated` datetime NOT NULL,
  `date_id` int(8) NOT NULL,
  `ticketID` int(11) NOT NULL,
  `clientID` int(11) NOT NULL,
  `questionID` int(11) NOT NULL,
  `storeid` int(11) NOT NULL,
  `callType` varchar(45) DEFAULT NULL,
  `sourceName` varchar(45) DEFAULT NULL,
  `dispositionName` varchar(45) DEFAULT NULL  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
