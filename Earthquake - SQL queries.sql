/* DATA WRANGLING WITH MYSQL 
PROJECT GOAL: Ensure that the 'Significant Earthquale Dataset" is reliable and accesible for future analysis.
PROJECT SKILLS: Performed Data Wrangling to transform raw data into a more usable format.

STEPS TO TRANSFORM RAW DATA INTO USABLE FORMAT FOR FUTURE ANALYSIS:
	1. Visualize the Dataset.
		(i) Find the total number of rows in the table of the schema.
        	(ii) Check to see if there were any inconsistent data entry in the date field.
	2. Standarize the Date column.
		(I) Check to see if there were any inconsistent data entry in the date field.
		- 1. let's find the maximum and minimum number of characters in the date field.
                - 2. let's make sure that there are no lengths apart from the min_length 0f 8 and max_length of 24
                - 3. Now, let's get the count of dates in the date column with 24 characters.
                - 4. Let's visualize these three date fields.
                - 5. Run a query, so that "date" column will contain only the date portion of the original date-time data in the 3 date field records.
                - 6. lets check our table to make sure there are no date values less than 8  and more than 24
                - 7. Now the date column is ready, So, next step we will standardize the date column
		(II) Create a new time2 column, and use CAST function to convert the intial time values from text to time.
                - 1. add a new column to the database
                - 2. Let's update the table earthquake and set the date column to date datatype
	3. Standardize the time column
		 (I) Create a new time2 column, and use CAST function to convert the intial time values from text to time.
		- 1. Use CAST to convert the text values in the time column into time datatype.
                - 2. We will use ALTER table to add a new column time2.
                - 3. Now, let's UPDATE the table
	4. Handle the blank values in the Dataset.
		 (I) HANDLE THE EMPTY VALUES
		 - 1. let's update all the numerical columns with 'empty or blank values' to '0'.
			(we will do this for all the supposed numerical values in the dataset before converting them to numerical datatype.)
                 - 2. Update the column 'depth_error', depth_seismic_stations, `magnitude error, magnitude seismic stations, Azimuthal Gap, Horizontal Distance,
		     Horizontal Error,Root Mean Square
			STEPS: (i) first count the rows in this column with empty values.
			       (ii) next, update the table and set the empty values in each column to '0.0'
                               (iii) Then, convert the numerical data that is stored as 'TEXT" to 'DOUBLE'.
	5. Check For Duplicates
		(I) Use CTE to check for duplicates	
	6. Create new columns from the date2 column: Year, Month, Day, Week, Day_of_Week. 
        	(i) Year
        	(ii) Month
        	(iii) Week
        	(iv) Day of Week
	7. Check for Outliers
		(I) First, let's check for any records outside our date range od 1965 to 2016.
        	(II) Next, let's check for any records with magnitude less than 5.5
	8. Drop unwated Columns
	 	(I) Drop the columns Date, Time
*/

USE earthquake;

/*********************************************** STEP 1 Visualize the DataSet **************************************************************************/

SELECT * FROM earthquake;

-- (i) Find the total number of rows in the table of the schema 

SELECT count(*) AS total_rows FROM earthquake;

/*********************************************** STEP 2: STANDARIZE THE DATE COLUMN*********************************************************************/

SELECT date from earthquake;

-- (I) Check to see if there were any inconsistent data entry in the date field 

-- 1. let's find the maximum and minimum number of characters in the date field. 

SELECT 
	MAX(CHAR_LENGTH(date)) AS max_length,
	MIN(CHAR_LENGTH(date)) AS min_length
FROM earthquake;

-- 2. let's make sure that there are no lengths apart from the min_length 0f 8 and max_length of 24

SELECT date
FROM earthquake
WHERE CHAR_LENGTH(date) < 8 AND  CHAR_LENGTH(date) > 24;

-- 3. Now, let's get the count of dates in the date column with 24 characters.

SELECT count(date)
FROM earthquake
where CHAR_LENGTH(date) = 24;

-- 4. Let's visualize these three date fields.

SELECT date 
FROM earthquake
WHERE CHAR_LENGTH(date) = 24;

-- 5. Run a query, so that "date" column will contain only the date portion of the original date-time data in the 3 date field records.

UPDATE earthquake
SET date = DATE(CONVERT(SUBSTRING_INDEX(date, 'T', 1), DATE))
WHERE date IN ('1975-02-23T02:58:41.000Z', '1985-04-28T02:53:41.530Z', '2011-03-13T02:23:34.520Z');

-- 6. lets check our table to make sure there are no date values less than 8  and more than 24

SELECT date 
FROM earthquake
WHERE CHAR_LENGTH(date) < 8 AND CHAR_LENGTH(date) > 24;

-- 7. Now the date column is ready, So, next step we will standardize the date column

-- (II) Convert the date 'text datatype' to 'date datatype' : Create a new column date2 and use the STR_TO_DATE function.

-- 1. add a new column to the database
ALTER TABLE earthquake
ADD column date2 date after date;

-- 2. Let's update the table earthquake and set the date column to date datatype

UPDATE earthquake
SET date2 = STR_TO_DATE(date, '%d/%m/%y');

-- 3. The above query throws an error: ERROR 1411: Incorrect datetime value.

-- Let's find the cause of this error.

SELECT date, str_to_date(Date, '%m/%d/%y') from earthquake
WHERE str_to_date(Date, '%m/%d/%y') is NULL;

-- The above query shows that we have 3 irregular data entry format that is different from the rest of the date column '01/02/1965'

-- 4.  We will now change these three records using UPDATE AND REPLACE function

-- Identify the rows with invalid date formats (same query as above, as both of them give the 3 invalid date enteries)
SELECT *
FROM earthquake
WHERE STR_TO_DATE(Date, '%m/%d/%Y') IS NULL;

-- Update the rows with the corrected date format
UPDATE earthquake
SET Date = REPLACE(Date, '1975-02-23', '2/23/1975');

UPDATE earthquake
SET Date = REPLACE(Date, '1985-04-28', '4/28/1985');

UPDATE earthquake
SET Date = REPLACE(Date,'2011-03-13' , '3/13/2011');

-- 5.  NOW, lets verify if the incorrect date enteries are corrected

SELECT date, str_to_date(Date, '%m/%d/%y') from earthquake
WHERE str_to_date(Date, '%m/%d/%y') is NULL;

-- 6. We will now standarize the Date column again!

-- Update the new date2 column 

UPDATE earthquake 
SET date2 = str_to_date(Date, '%m/%d/%Y');

select date, date2 from earthquake;

-- We now have a standarized date2 that can be use for future data analysis and visualizations.


/*************************************************** STEP 3. STANDARIZE THE TIME COLUMN  ***************************************************************/

-- (I) Create a new time2 column, and use CAST function to convert the intial time values from text to time.

-- 1. Use CAST to convert the text values in the time column into time datatype

SELECT CAST(Time as time) 
FROM earthquake;

-- 2.  We will use ALTER table to add a new column time2

ALTER TABLE earthquake 
ADD column time2 time AFTER TIME;

-- 3. Now, let's UPDATE the table

UPDATE earthquake 
SET time2 = CAST(Time as time);
		
-- Here, the update throws an error.  Error Code: 1292. Truncated incorrect time value: '1975-02-23T02:58:41.000Z'

-- In order to deal with this error, lets do the following steps: 
-- (i) show the incorrect time length

SELECT Time 
FROM earthquake
WHERE LENGTH(Time) = 24;

-- (ii) Let's clean and update the 3 incorrect enteries in the Time column

-- First, REPLACE the 3 rows with correct time lengths

UPDATE earthquake
SET Time = REPLACE(Time, '1975-02-23T02:58:41.000Z', SUBSTR(Time, 12, 8))
WHERE Time = '1975-02-23T02:58:41.000Z';

UPDATE earthquake
SET Time = REPLACE(Time, '1985-04-28T02:53:41.530Z', SUBSTR(Time, 12, 8))
WHERE Time = '1985-04-28T02:53:41.530Z';

UPDATE earthquake
SET Time = REPLACE(Time,'2011-03-13T02:23:34.520Z' , SUBSTR(Time, 12, 8))
WHERE Time = '2011-03-13T02:23:34.520Z';

-- Finally, we will update the time2 column

UPDATE earthquake
SET time2 = CAST(Time as time);

-- Let's Visualize the Time and time2 columns 
SELECT Time, time2 
FROM earthquake;

/***************************************************** STEP 4: HANDLE THE BLANK VALUES IN THE DATSET ****************************************************************/

SELECT * FROM earthquake;

-- (I) **HANDLE THE EMPTY VALUES**

-- (i) let's update all the numerical columns with 'empty or blank values' to '0'.
-- (we will do this for all the supposed numerical values in the dataset before converting them to numerical datatype.)

-- First, find the count of rows in Dept_Error column with Blank values:

SELECT COUNT(Depth Error) 
FROM earthquake
WHERE Depth Error = '';
-- This query gives an error because of the gap between the Dept and Error in the column name. So, we will change the column name.

-- Change the name of the column depth error

ALTER TABLE earthquake
CHANGE COLUMN `depth error` depth_error TEXT;

-- Now, Lets update the column 'depth_error': first count the rows in this column with empty values.

SELECT COUNT(depth_error) 
FROM earthquake
WHERE depth_error = '';

-- Now, let's  handle the 18951 empty values in 'depth_error' column, by changing the empty fields to '0'

UPDATE earthquake
SET depth_error = 
		CASE WHEN depth_error = '' then 0.0
                ELSE depth_error
                END;
	-- output:  18951 row(s) affected Rows matched: 23412  Changed: 18951  Warnings: 0


UPDATE earthquake
SET depth_seismic_stations = 
		CASE WHEN depth_seismic_stations = '' then 0
                ELSE depth_seismic_stations
                END;
			
	-- 16315 row(s) affected Rows matched: 23412  Changed: 16315  Warnings: 0

SELECT COUNT(`magnitude error`) 
FROM earthquake
WHERE `magnitude error` = ''; -- 23085 rows are blank.
UPDATE earthquake
SET `magnitude error` = 
		CASE WHEN `magnitude error` = '' then 0
                ELSE `magnitude error`
                END;
                
SELECT COUNT(`magnitude seismic stations`) 
FROM earthquake
WHERE `magnitude seismic stations` = ''; -- 20848 rows are blank.
UPDATE earthquake
SET `magnitude seismic stations` = 
		CASE WHEN `magnitude seismic stations` = '' then 0.0
                ELSE `magnitude seismic stations`
                END;
	-- 20848 row(s) affected Rows matched: 23412  Changed: 20848  Warnings: 0

SELECT COUNT(`Azimuthal Gap`) 
FROM earthquake
WHERE `Azimuthal Gap` = ''; --  16113  rows are blank.
UPDATE earthquake
SET `Azimuthal Gap` = 
		CASE WHEN `Azimuthal Gap` = '' then 0.0
                ELSE `Azimuthal Gap`
                END;
	-- 16113 row(s) affected Rows matched: 23412  Changed: 16113  Warnings: 0

SELECT COUNT(`Horizontal Distance`) 
FROM earthquake
WHERE `Horizontal Distance` = ''; -- 21808 rows are blank.
UPDATE earthquake
SET `Horizontal Distance` = 
		CASE WHEN `Horizontal Distance` = '' then 0.0
                ELSE `Horizontal Distance`
                END;
	-- 21808 row(s) affected Rows matched: 23412  Changed: 21808  Warnings: 0

SELECT COUNT(`Horizontal Error`) 
FROM earthquake
WHERE `Horizontal Error` = ''; -- 22256 rows are blank.
UPDATE earthquake
SET `Horizontal Error` = 
		CASE WHEN `Horizontal Error` = '' then 0.0
                ELSE `Horizontal Error`
                END;
	-- 22256 row(s) affected Rows matched: 23412  Changed: 22256  Warnings: 0

SELECT COUNT(`Root Mean Square`) 
FROM earthquake
WHERE `Root Mean Square` = ''; -- 6060 rows are blank.
UPDATE earthquake
SET `Root Mean Square` = 
		CASE WHEN `Root Mean Square` = '' then 0.0
                ELSE `Root Mean Square`
                END;
	-- 6060 row(s) affected Rows matched: 23412  Changed: 6060  Warnings: 0

-- (II) CONVERTING THE NUMERICAL DATA THAT IS STORED AS TEXT TO DOUBLE

-- Use Alter and Modify functions

ALTER TABLE earthquake
MODIFY COLUMN depth_error double;
ALTER TABLE earthquake
MODIFY COLUMN depth_seismic_stations double;
ALTER TABLE earthquake
MODIFY COLUMN `magnitude error` double;
ALTER TABLE earthquake
MODIFY COLUMN `magnitude seismic stations` double;
ALTER TABLE earthquake
MODIFY COLUMN `Azimuthal Gap` double;
ALTER TABLE earthquake
MODIFY COLUMN `Horizontal Distance` double;
ALTER TABLE earthquake
MODIFY COLUMN `Horizontal Error` double;
ALTER TABLE earthquake
MODIFY COLUMN `Root Mean Square` double;


-- Let's look at our well-formatted columns

SELECT * FROM earthquake;

/**************************************************** STEP 5. CHECKING FOR DUPLICATES *************************************************************************/

-- (I) Use CTE to check for duplicates

WITH temp_1 AS (
		SELECT *,
			ROW_NUMBER() OVER(PARTITION BY date2, time2, Latitude, Longitude ORDER BY ID) rownum
		FROM earthquake)
SELECT COUNT(*) FROM temp_1 WHERE rownum > 1;  

	-- output is 0 : which means there are NO duplicate values.

/*******************************STEP 6: CREATE NEW COLUMNS FROM THE DATE2 COLUMN: year, month, day, week , day_of_week ***************************************/ 
						-- This columns will be helpful during analysis phase.

-- (i) Year

SELECT EXTRACT(Year FROM date2) 
FROM earthquake;
ALTER TABLE earthquake
ADD COLUMN Year INT AFTER time2;
UPDATE earthquake
SET Year = EXTRACT(Year From date2);


-- (ii) Month
SELECT EXTRACT(Month FROM date2) 
FROM earthquake;   -- output is 1, 2, 3,... for the months january, february, etc
ALTER TABLE earthquake
ADD COLUMN Month INT AFTER Year;
UPDATE earthquake
SET MONTH = EXTRACT(Month From date2);

-- (iii) WEEK
SELECT WEEK(date2,0) -- 0 indicates the week starts on Monday
FROM earthquake;   
ALTER TABLE earthquake
ADD COLUMN Week INT AFTER Month;
UPDATE earthquake
SET Week = WEEK(date2,0);

-- (iv) DAY OF WEEK

SELECT dayname(date2) 
FROM earthquake;   
ALTER TABLE earthquake
ADD COLUMN Day_of_Week INT AFTER Month;

ALTER TABLE earthquake
MODIFY COLUMN Day_of_Week VARCHAR(20);  -- Adjust the length (20) as needed


UPDATE earthquake
SET Day_of_Week = DAYOFWEEK(date2); -- update the "Day_of_Week" column with integer values representing the day of the week.


UPDATE earthquake
SET Day_of_Week = DAYNAME(date2);


SELECT WEEK(date2, 0) AS Week_Number, DAYOFWEEK(date2) AS Day_Of_Week, dayname(date2) AS weekday
FROM earthquake;

-- NOTE: Error Code: 1366. Incorrect integer value: 'Saturday' for column 'Day_of_Week' at row 1
-- This error is correct by altering the table and MODIFYING COLUMN Day_of_Week  as  VARCHAR(20)


select * from earthquake;

/*********************************************** STEP 7. CHECKING FOR OUTLIERS **************************************************************************/

-- For our dataset: the data is collected between the years 1965 to 2016. And the magnitude of earthquakes recorded are above 5.5. 
-- Hence, we can say that any date that is out of the range of our date range, would be considered as an outlier.
-- And, any magnitude less than 5.5 would be also an outlier.

-- (I) First, let's check for any records outside our date range:
SELECT Year
FROM earthquake
WHERE Year < 1965 AND Year > 2016;  -- No records found

-- (II) Next, let's check for any records with magnitude less than 5.5
SELECT * 
FROM earthquake
WHERE Magnitude < 5.5;  -- No records found

-- We can Conclude that there are NO OUTLIERS found in our dataset.

/********************************************** STEP 8. DROP UNUSED COLUMNS **********************************/

ALTER TABLE earthquake
DROP COLUMN Date,
DROP COLUMN Time;

/********************************************** VISUALIZE THE CLEAN DATASET ************************************************/
SELECT * FROM earthquake;

/****************************************************************************************************************************/

