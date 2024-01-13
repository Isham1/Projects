--Create Database
CREATE database Team14_DB;

--Use database
Use Team14_DB;

--Create Tables

-- 1. Flat Mate
CREATE Table dbo.Flat_Mate
(
FlatMateID varchar(10) NOT NULL Primary Key,
FirstName varchar(20) Not Null,
LastName varchar(20) Not Null,
DateOfBirth date Not Null,
Gender varchar(10) Not Null
);

-- 2. Emergency Contact
CREATE Table dbo.Emergency_Contact
(
FlatMateID varchar(10) NOT NULL
	References Flat_Mate(FlatMateID),
EmergencyID varchar(10) NOT NULL,
FirstName varchar(20) Not Null,
LastName varchar(20) Not Null,
Street varchar(20) Not Null,
HouseNo varchar(10) Not Null,
City varchar(15) Not Null,
State varchar(15) Not Null,
Country varchar(15) Not Null,
ZipCode int Not Null,
PhoneNo int Not Null
	Constraint PKEmergency_Contact Primary Key Clustered
		(FlatMateID, EmergencyID)
);

-- 3. Vehicle
CREATE Table dbo.Vehicle
(
NumberPlate varchar(10) Not Null Primary Key,
FlatMateID varchar(10) NOT NULL
	References Flat_Mate(FlatMateID),
MakeAndModel varchar(20) Not Null,
ParkingLotNo int Not Null,
LastFueled date Not Null,
LastServiced date Not Null
);

-- 4. Department
Create Table dbo.Department
(
DepartmentID varchar(10) Not Null Primary Key,
DepartmentName varchar(20) Not Null,
CollegeName varchar(20) Not Null
);

-- 5. Course
Create Table dbo.Course
(
CourseID varchar(10) Not Null Primary Key,
CourseName varchar(20) Not Null,
Professor varchar(20) Not Null,
DepartmentID varchar(10) Not Null
	References Department(DepartmentID),
CourseTimming varchar(20) Not Null
);

-- 6. Course Enrolled
Create Table dbo.Course_Enrolled
(
EnrollmentID varchar(10) NOT NULL Primary Key,
FlatMateID varchar(10) NOT NULL
	References Flat_Mate(FlatMateID),
CourseID varchar(10) NOT NULL
	References Course(CourseID),
Grade varchar(3) Not Null
);

-- 7. Grocery
Create Table dbo.Grocery
(
ItemID varchar(10) NOT NULL Primary Key,
DateOfPurchase date Not Null,
ItemName varchar(20) Not Null,
Department varchar(15) Not Null,
Cost money Not Null,
ExpirationDate date Not Null
);

-- 8. Grocery Record
Create Table dbo.Grocery_Record
(
GroceryRecordID varchar(10) Not Null Primary Key,
ItemID varchar(10) NOT NULL
	References Grocery(ItemID),
FlatMateID varchar(10) NOT NULL
	References Flat_Mate(FlatMateID),
Quantity int Not Null
);

-- 9. Personal Expense
Create Table dbo.Personal_Expense
(
PExpenseID varchar(10) Not Null Primary Key,
FlatMateID varchar(10) NOT NULL
	References Flat_Mate(FlatMateID),
Category varchar(15) Not Null,
ItemName varchar(20) Not Null,
Date date Not Null,
Cost money Not Null
);

-- 10. Common Expense
Create Table dbo.Common_Expense
(
CommonExpenseID varchar(10) Not Null Primary Key,
Name varchar(20) Not Null,
Cost money Not Null,
PaidOn date Not Null,
NextDueDate  date Not Null
);

-- 11. Common Expense For
CREATE Table dbo.Common_Expense_For
(
ExpenseID varchar(10) Not Null Primary Key,
FlatMateID varchar(10) NOT NULL
	References Flat_Mate(FlatMateID),
CommonExpenseID varchar(10) NOT NULL
	References Common_Expense(CommonExpenseID),
);

-- 12. Apartment Cleaning Schedule
CREATE Table dbo.Apartment_Cleaning_Schedule
(
FlatMateID varchar(10) NOT NULL
	References Flat_Mate(FlatMateID),
Date date Not Null,
Area varchar(15) Not Null,
Status varchar(10) Not Null
	Constraint PKApartmentCleaningSchedule Primary Key Clustered
	(FlatMateID,Date,Area)
);

-- 13. COVID Test Schedule
CREATE Table dbo.COVID_Test_Schedule
(
FlatMateID varchar(10) NOT NULL
	References Flat_Mate(FlatMateID),
Date date Not Null,
Location varchar(20) Not Null,
Result varchar(10) Not Null
	Constraint PKCovidTestSchedule Primary Key Clustered
	(FlatMateID,Date)
);

-- 14. Laundry Machine
CREATE Table dbo.Laundry_Machine
(
MachineID varchar(10) Not Null Primary Key,
MachineType varchar(20) Not Null,
Status varchar(15) Not Null,
);

-- 15. Laundry Mode
CREATE Table dbo.Laundry_Mode
(
MachineID varchar(10) Not Null
	References Laundry_Machine(MachineID),
ModeID varchar(10) Not Null unique,
ModeName varchar(20) Not Null,
Duration time Not Null
	Constraint PKLaundryMode Primary Key Clustered
	(MachineID,ModeID)	
);

-- 16. Laundry Schedule
Create Table dbo.Laundry_Schedule
(
LaundryScheduleID varchar(10) Not Null Primary Key,
FlatMateID varchar(10) NOT NULL
	References Flat_Mate(FlatMateID),
MachineID varchar(10) NOT NULL
	References Laundry_Machine(MachineID), 
StartTime time Not Null,
ModeID varchar(10) Not Null
	References Laundry_Mode(ModeID)
);

-- 17. Cooking Schedule
CREATE Table dbo.Cooking_Schedule
(
FlatMateID varchar(10) NOT NULL
	References Flat_Mate(FlatMateID),
Date date Not Null,
StartTime time Not Null,
TimeDuration time Not Null,
MealType varchar(20) Not Null
	Constraint PKCookingSchedule Primary Key Clustered
		(FlatMateID,StartTime)
);

---------------------------------------------------------------------------------------------------------------------

--Check Constraint:

--Zip Code - should be only 5 digits.
ALTER TABLE dbo.Emergency_Contact ADD CONSTRAINT ZipCodeCheck CHECK (
ZipCode < 100000 AND ZipCode > 9999);
​
--Phone Number - should be only 10 digits.
ALTER TABLE dbo.Emergency_Contact ADD CONSTRAINT PhoneNoCheck CHECK (
Len(TRIM(PhoneNo)) = 10 AND 
Len(TRIM(TRANSLATE(PhoneNo,'0123456789 ','          a'))) = 0);
​
--Number plate - should be between 5-6 characters.
ALTER TABLE dbo.Vehicle ADD CONSTRAINT NumberPlateSize CHECK 
(Len(NumberPlate) > 4 AND Len(NumberPlate) < 7);
​
--Expiration date - should be after the date of purchase.
ALTER TABLE dbo.Grocery ADD CONSTRAINT GorceryDateCheck CHECK 
(ExpirationDate >= DateOfPurchase);
​
--Cooking Schedule Constraint - In the last 2 months, flatmate who has positive result of Covid-19 cannot cook.
CREATE FUNCTION CheckCovidResult (@FMID varchar(10), @CookingDate date)
RETURNS smallint 
AS 
	BEGIN   
		DECLARE @Count smallint=0;   
			SELECT @Count = COUNT(FlatMateID)           
			FROM dbo.COVID_Test_Schedule       
			WHERE FlatMateID = @FMID         
			AND Result = 'Positive' AND DATEDIFF(mm,Date,@CookingDate) < 2;   
		RETURN @Count;
	END;
​
ALTER TABLE dbo.Cooking_Schedule ADD CONSTRAINT BanPositive CHECK 
(dbo.CheckCovidResult(FlatMateID, Date) = 0);
​
---------------------------------------------------------------------------------------------------------------------

--Create views:
-- 1. Expense view - show all the expenses of a flatmate including grocery, personal, common.
CREATE VIEW dbo.ExpenseView 
AS
With temp1 AS (
SELECT fm.FlatMateID, SUM(pe.Cost) AS PersonalExpense
FROM dbo.Flat_Mate fm
JOIN dbo.Personal_Expense pe ON fm.FlatMateID = pe.FlatMateID
GROUP BY fm.FlatMateID
), temp2 AS (
SELECT fm.FlatMateID, SUM(ce.Cost) AS CommonExpense
FROM dbo.Flat_Mate fm
JOIN dbo.Common_Expense_For cef ON fm.FlatMateID = cef.FlatMateID
JOIN dbo.Common_Expense ce ON cef.CommonExpenseID = ce.CommonExpenseID
GROUP BY fm.FlatMateID
), temp3 AS(
SELECT fm.FlatMateID, SUM(g.cost * gr.Quantity) AS GroceryExpense
FROM dbo.Flat_Mate fm
JOIN dbo.Grocery_Record gr ON gr.FlatMateID = fm.FlatMateID
JOIN dbo.Grocery g ON g.ItemID = gr.ItemID
GROUP BY fm.FlatMateID
)
SELECT temp1.FlatMateID, PersonalExpense, CommonExpense, GroceryExpense
FROM temp1, temp2, temp3
WHERE temp1.FlatMateID = temp2.FlatMateID
AND temp1.FlatMateID = temp3.FlatMateID;
--show the view
SELECT * FROM dbo.ExpenseView;
​

--Daily Schedule View
-- 2. Cleaning schedule view - show all the cleaning scheduale, order by date.
CREATE VIEW dbo.CleaningScheduleView
AS
SELECT TOP 100 PERCENT * FROM dbo.Apartment_Cleaning_Schedule
ORDER BY Date DESC;
--show the view
SELECT * FROM dbo.CleaningScheduleView;
​
​
-- 3. Cooking schedule view - show all the cooking scheduale, order by date.
CREATE VIEW dbo.CookingScheduleView
AS
SELECT TOP 100 PERCENT * FROM dbo.Cooking_Schedule
ORDER BY Date DESC;
--show the view
SELECT * FROM dbo.CookingScheduleView;
​
​
-- 4. Laundry schedule view - show all the laundry scheduale, order by startTime.
CREATE VIEW dbo.LaundryScheduleView
AS
SELECT TOP 100 PERCENT * FROM dbo.Laundry_Schedule
ORDER BY StartTime DESC;
--show the view
SELECT * FROM dbo.LaundryScheduleView;
​
---------------------------------------------------------------------------------------------------------------------

--Create Computed Colums Constraint

-- 1. GetNextDueDate - will calculate and populate the NextDueDate by adding 30 days to PaidOn date.
CREATE FUNCTION GetNextDueDate
(@PaidOn DATE)
RETURNS DATE
AS
BEGIN 
	DECLARE @NextDueDate DATE
	SELECT @NextDueDate = DATEADD(day, 30, @PaidOn)
	RETURN @NextDueDate
END;
--Alter column
ALTER table dbo.Common_Expense
ADD NextDueDate AS (dbo.GetNextDueDate(PaidOn));


-- 2. GetFinishTime - will calculate and populate the FinishTime of Laudry Schedule by adding 
--Duration of the respective mode.
CREATE FUNCTION GetFinishTime
(@StartTime time(7), @ModeID varchar(10))
RETURNS time(7)
AS
BEGIN 
	DECLARE  @WorkTime time(7)
	SELECT @WorkTime = Duration 
	from dbo.Laundry_Mode lm 
	where lm.ModeID = @ModeID
	RETURN (dateadd(SECOND , datediff( s,'00:00:00',@WorkTime), @StartTime))
END;
--Alter column
ALTER table dbo.Laundry_Schedule 
ADD FinishTime AS (dbo.GetFinishTime(StartTime,ModeID));
---------------------------------------------------------------------------------------------------------------------

--Housekeeping
ALTER TABLE dbo.Emergency_Contact DROP CONSTRAINT ZipCodeCheck;
ALTER TABLE dbo.Emergency_Contact DROP CONSTRAINT PhoneNoCheck;
AlTER TABLE dbo.Vehicle DROP CONSTRAINT NumberPlateSize;
ALTER TABLE dbo.Grocery DROP CONSTRAINT GorceryDateCheck;
ALTER TABLE dbo.Cooking_Schedule DROP CONSTRAINT BanPositive;
DROP FUNCTION IF EXISTS CheckCovidResult;
​
DROP VIEW dbo.ExpenseView;
DROP VIEW dbo.CleaningScheduleView;
DROP VIEW dbo.CookingScheduleView;
DROP VIEW dbo.LaundryScheduleView;

DROP FUNCTION GetNextDueDate;
DROP FUNCTION GetFinishTime;
ALTER TABLE dbo.Laundry_Schedule DROP COLUMN FinishTime;
---------------------------------------------------------------------------------------------------------------------

--Add data to tables
-- 1. Flat Mates
INSERT INTO dbo.Flat_Mate 
VALUES  ('F1','Prof Simon', 'Wang', '1874-11-12', 'Male'),
		('F2','Haoran','Li','1997-12-25','Male'),
		('F3','Isham','.','1998-03-29','Male'),
		('F4','Jiahao','Shi','1996-08-30','Male'),
		('F5','Xiyuan','Jin','1997-10-22','Male'),
		('F6','Cordell','Emmerson','1916-04-16','Male'),
		('F7','Carmella','Peter','1990-09-25','Female'),
		('F8','Lionel','Emmanuel','1974-10-18','Male'),
		('F9','Kat','Angelle','1989-05-23','Female'),
		('F10','Edwena','Adella','1990-06-23','Female');

-- 2. Emergency Contact
INSERT INTO dbo.Emergency_Contact 
VALUES  ('F1','EM1','Russel','Conrad','Pacific Drive','6','Carmichael','CA','USA','95608','2092000700'),
		('F2','EM2','Reg','Walter','West Court','35','Santa Ana','CA','USA','92701','2092017148'),
		('F3','EM3','Vernon','Richie','Green Hill Drive','8659','Pomona','CA','USA','91766','2092045643'),
		('F4','EM4','Keely','Kamryn','Catherine St','3','San Pablo','CA','USA','94806','2093649264'),
		('F5','EM5','Natasha','Arlene','Bellevue Lane','498','El Monte','CA','USA','91732','2096204610'),
		('F6','EM6','Hilda','Keir','Hillcrest Dr','7306','Hawthorne','CA','USA','90250','2098156827'),
		('F7','EM7','Letha','Kade','Grand Dr','223','Fresno','CA','USA','93722','2090839467'),
		('F8','EM8','Lucia','Kassia','Pacific St','9211','Vacaville','CA','USA','95687','2093984526'),
		('F9','EM9','Rolph','Marideth','Howard St','37','Los Angeles','CA','USA','90001','2093851658'),
		('F10','EM10','Jillian','Winthrop','Baker Street','9632','Union City','CA','USA','94587','2090678943'),
		('F2','EM11','Corrina','Eliot','Penn Drive','7670','Hayward','PA','USA','16001','2091453264'),
		('F6','EM12','Salina','Zane','Chapel St','8584','Hartselle','AL','USA','35640','2096768932');

-- 3. Vehicle
INSERT INTO dbo.Vehicle 
VALUES  ('6HJS12','F1','Hennessey Venom Gt',1,'2021-01-22','2016-04-12'),
		('6EPU8X','F2','Ssangyong',4,'2021-03-29','2016-06-05'),
		('1RFS17','F3','BMW X1',5,'2021-03-29','2016-06-09'),
		('3YNZ7X','F4','Volvo XC40',13,'2021-04-22','2017-07-27'),
		('3NBZ89','F5','Peugeot 308',16,'2021-02-25','2018-03-23'),
		('9LYM37','F1','Dodge Charger',2,'2020-11-08','2018-09-22'),
		('8LEB30','F2','Ford Edge',6,'2021-01-23','2018-11-28'),
		('4SXU59','F3','Toyota Yaris',15,'2020-08-10','2018-10-05'),
		('1GZE5Y','F4','BMW i3',20,'2021-03-11','2018-04-19'),
		('1WWB60','F5','Cadillac XT5',11,'2021-04-08','2019-09-14');
		

-- 4. Department
INSERT INTO dbo.Department 
VALUES  ('DP1','Computer Sciences','Hamilton Uni'),
		('DP2','Applied Art','Williams Uni'),
		('DP3','Statistics','Bryn Mawr Uni'),
		('DP4','History','Middlebury Uni'),
		('DP5','Sociology','Northeastern Uni'),
		('DP6','Medicine','Williams Uni'),
		('DP7','Geography','Middlebury Uni'),
		('DP8','Data Sciences','Northeastern Uni'),
		('DP9','Economics','Northeastern Uni'),
		('DP10','Linguistics','Northeastern Uni');

-- 5. Course
INSERT INTO dbo.Course 
VALUES  ('CR1','Lexicology','Prof Winona','DP10','Mon, Fri'),
		('CR2','Central Asian Art','Prof Wilfreda','DP2','Sat'),
		('CR3','Numerical Analysis','Prof Ida','DP3','Sun'),
		('CR4','Sociology of Market','Prof Louis','DP9','Wed, Fri'),
		('CR5','Macrosociology','Prof Phillipa','DP5','Tue, Fri'),
		('CR6','Biomaterials','Prof Natalee','DP6','Mon, Wed'),
		('CR7','Spanish History','Prof Colene','DP4','Mon'),
		('CR8','Machine Learning','Prof Carlyn','DP8','Tue, Fri'),
		('CR9','Post Colonial Art','Prof Andriana','DP2','Sat, Sun'),
		('CR10','Algorithms & DS','Prof Mikki','DP1','Wed, Sun');

-- 6. Course Enrolled
INSERT INTO dbo.Course_Enrolled 
VALUES  ('ENR1','F1','CR1','A'),
		('ENR2','F2','CR2','A+'),
		('ENR3','F3','CR3','A-'),
		('ENR4','F4','CR3','B+'),
		('ENR5','F5','CR4','B-'),
		('ENR6','F4','CR5','A-'),
		('ENR7','F3','CR7','B+'),
		('ENR8','F2','CR9','A-'),
		('ENR9','F1','CR6','A-'),
		('ENR10','F4','CR10','A+');

-- 7. Grocery
INSERT INTO dbo.Grocery 
VALUES  ('ITM1','2021-01-01','Pizza','Frozen Food',8.99,'2023-01-01'),
		('ITM2','2021-02-01','Tomatoes','Produce',2.5,'2021-03-01'),
		('ITM3','2021-03-01','Shampoo','Health & Beuty',10.95,'2022-04-01'),
		('ITM4','2021-04-01','Milk','Dairy',2.49,'2021-05-01'),
		('ITM5','2021-01-01','Ham','Meat',5.5,'2022-02-01'),
		('ITM6','2021-02-01','Lays','Snacks',6.0,'2021-03-01'),
		('ITM7','2021-03-01','Onion','Produce',3.5,'2022-05-01'),
		('ITM8','2021-04-01','Hot Pockets','Frozen Food',5.49,'2021-07-01'),
		('ITM9','2021-01-01','Cheese','Dairy',8.90,'2022-02-01'),
		('ITM10','2021-02-01','Bread','Bakery',2.49,'2022-08-01'),
		('ITM11','2021-04-01','Notebook','Staionary',8.99,'2021-12-01');

-- 8. Grocery Record
INSERT INTO dbo.Grocery_Record 
VALUES  ('GR1','ITM1','F1',1),
		('GR2','ITM2','F2',2),
		('GR3','ITM3','F3',3),
		('GR4','ITM4','F4',4),
		('GR5','ITM5','F5',3),
		('GR6','ITM6','F1',2),
		('GR7','ITM4','F2',1),
		('GR8','ITM3','F3',2),
		('GR9','ITM8','F4',3),
		('GR10','ITM1','F5',4);

-- 9. Personal Expense
INSERT INTO dbo.Personal_Expense 
VALUES  ('PE1','F1','Clothing','T-Shirt','2020-03-01',16.99),
		('PE2','F2','Gym','Yearly Membership','2019-01-15',110.99),
		('PE3','F3','Mobile Bill','Data Recharge','2021-11-18',15.39),
		('PE4','F4','Furniture','Table','2020-06-20',80.49),
		('PE5','F5','Furniture','Chair','2021-08-22',40.89),
		('PE6','F1','Electronics','Mobile','2019-05-29',990.90),
		('PE7','F2','Home Decor','Curtains','2018-04-13',20.98),
		('PE8','F3','Electronics','Laptop','2019-03-12',1400.49),
		('PE9','F4','Clothing','Jacket','2021-10-15',58.89),
		('PE10','F5','Gym','Monthly Membership','2020-12-25',25.99);

-- 10. Common Expense
INSERT INTO dbo.Common_Expense 
VALUES  ('CEX1','Electricity Bill',68.69,'2021-01-01'),
		('CEX2','Water Bill',35.49,'2021-01-01'),
		('CEX3','WiFi Bill',79.99,'2021-01-01'),
		('CEX4','Gas Bill',20.25,'2021-04-01'),
		('CEX5','Utilities',50.45,'2021-03-01'),
		('CEX6','Cable Bill',79.99,'2021-03-01'),
		('CEX7','Cleaner',80.90,'2021-03-01'),
		('CEX8','Electricity Bill',75.46,'2021-02-01'),
		('CEX9','Water Bill',48.47,'2021-02-01'),
		('CEX10','WiFi Bill',79.99,'2021-02-01');

-- 11. Common Expense For
INSERT INTO dbo.Common_Expense_For 
VALUES  ('EXP1','F1','CEX1'),
		('EXP2','F2','CEX1'),
		('EXP3','F3','CEX1'),
		('EXP4','F4','CEX2'),
		('EXP5','F5','CEX2'),
		('EXP6','F1','CEX3'),
		('EXP7','F2','CEX4'),
		('EXP8','F3','CEX4'),
		('EXP9','F4','CEX6'),
		('EXP10','F5','CEX6');

-- 12. Apartment Cleaning Schedule
INSERT INTO dbo.Apartment_Cleaning_Schedule 
VALUES  ('F1','2021-03-01','Master Bedroom','Remaining'),
		('F2','2021-03-01','Common Bathroom','Complete'),
		('F3','2021-03-15','Hall','Remaining'),
		('F4','2021-03-15','Lobby','Complete'),
		('F5','2021-03-01','Kitchen','Remaining'),
		('F5','2021-04-01','Master Bedroom','Complete'),
		('F4','2021-04-15','Common Bathroom','Complete'),
		('F3','2021-04-15','Hall','Remaining'),
		('F2','2021-04-01','Lobby','Remaining'),
		('F1','2021-04-01','Kitchen','Complete');

-- 13. COVID Test Schedule
INSERT INTO dbo.COVID_Test_Schedule 
VALUES  ('F1','2020-12-25','University','Positive'),
		('F2','2021-01-10','University','Negative'),
		('F1','2021-01-01','CVS','Negative'),
		('F4','2020-01-01','University','Positive'),
		('F3','2021-01-01','University','Negative'),
		('F5','2021-02-01','University','Negative'),
		('F4','2021-02-01','University','Negative'),
		('F1','2021-02-01','CVS','Negative'),
		('F2','2021-03-01','University','Negative'),
		('F5','2021-03-01','CVS','Negative'),
		('F3','2021-03-01','CVS','Negative');

-- 14. Laundry Machine
INSERT INTO dbo.Laundry_Machine 
VALUES  ('MCH1','GE 20SX','Functional'),
		('MCH2','LG F56GH','Functional'),
		('MCH3','Samsung I09HG','Broken Down'),
		('MCH4','Whirlpool SXF77H','Functional'),
		('MCH5','LG F88X','Functional'),
		('MCH6','Samsung SS980T','Broken Down'),
		('MCH7','LG F56GH','Functional'),
		('MCH8','IFB Smart23X','Broken Down'),
		('MCH9','GE 20SX','Broken Down'),
		('MCH10','Bosch BS65','Functional');

-- 15. Laundry Mode
INSERT INTO dbo.Laundry_Mode 
VALUES  ('MCH1','FLL','Full Load','01:35:00'),
		('MCH2','CLL','Full Load','01:30:00'),
		('MCH3','FL','Full Load','01:20:00'),
		('MCH4','CL','Full Load','01:25:00'),
		('MCH5','FULL','Full Load','01:15:00'),
		('MCH1','QCK','Quick Load','00:35:00'),
		('MCH2','QK','Quick Load','00:25:00'),
		('MCH3','QUCK','Quick Load','00:25:00'),
		('MCH4','QUICK','Quick Load','00:20:00'),
		('MCH5','QUK','Quick Load','00:30:00');

-- 16. Laundry Schedule
INSERT INTO dbo.Laundry_Schedule 
VALUES  ('LS1','F1','MCH1','07:20:00','FLL'),
		('LS2','F2','MCH2','08:34:00','CLL'),
		('LS3','F3','MCH4','12:12:00','QUICK'),
		('LS4','F4','MCH5','10:09:00','FULL'),
		('LS5','F5','MCH5','09:30:00','QUK'),
		('LS6','F1','MCH5','18:43:00','QCK'),
		('LS7','F2','MCH4','15:41:00','CLL'),
		('LS8','F3','MCH1','20:23:00','FLL'),
		('LS9','F4','MCH2','08:45:00','CLL'),
		('LS10','F5','MCH2','06:12:00','QK');

--17. Cooking Schedule
INSERT INTO dbo.Cooking_Schedule 
VALUES  ('F1','2021-04-01','13:45:00','01:30:00','Lunch'),
		('F2','2021-04-01','19:23:00','01:20:00','Dinner'),
		('F3','2021-04-02','08:34:00','00:10:00','Breakfast'),
		('F4','2021-04-02','20:45:00','01:21:00','Dinner'),
		('F5','2021-04-03','21:21:00','01:23:00','Dinner'),
		('F1','2021-04-03','14:54:00','01:22:00','Lunch'),
		('F2','2021-04-04','13:14:00','01:10:00','Lunch'),
		('F3','2021-04-04','22:50:00','01:02:00','Dinner'),
		('F4','2021-04-05','14:13:00','01:14:00','Lunch'),
		('F5','2021-04-06','09:53:00','00:30:00','Breakfast');


---------------------------------------------------------------------------------------------------------------------




​