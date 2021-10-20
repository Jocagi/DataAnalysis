/*
______                          _          __                            
| ___ \                        | |        /  |                           
| |_/ / __ ___  _   _  ___  ___| |_ ___   `| |                           
|  __/ '__/ _ \| | | |/ _ \/ __| __/ _ \   | |                           
| |  | | | (_) | |_| |  __/ (__| || (_) | _| |_                          
\_|  |_|  \___/ \__, |\___|\___|\__\___/  \___/                          
                 __/ |                                                   
                |___/                                                    
  ___              _ _     _           _            _       _            
 / _ \            | (_)   (_)         | |          | |     | |           
/ /_\ \_ __   __ _| |_ ___ _ ___    __| | ___    __| | __ _| |_ ___  ___ 
|  _  | '_ \ / _` | | / __| / __|  / _` |/ _ \  / _` |/ _` | __/ _ \/ __|
| | | | | | | (_| | | \__ \ \__ \ | (_| |  __/ | (_| | (_| | || (_) \__ \
\_| |_/_| |_|\__,_|_|_|___/_|___/  \__,_|\___|  \__,_|\__,_|\__\___/|___/
                                                                         
                                                                         
	José Carlos Girón Márquez
	1064718

*/


/*********************************************************************/
/*						Eliminado de Datos							 */
/*********************************************************************/

USE [1064718_DWH];
GO
DELETE FROM [1064718_DWH].[Fact].[Ventas];
DBCC CHECKIDENT ('[1064718_DWH].[Fact].[Ventas]',RESEED, 0);
GO
DELETE FROM [1064718_DWH].[Dim].[Cliente];
DBCC CHECKIDENT ('[1064718_DWH].[Dim].[Cliente]',RESEED, 0);
GO
DELETE FROM [1064718_DWH].[Dim].[Moneda];
DBCC CHECKIDENT ('[1064718_DWH].[Dim].[Moneda]',RESEED, 0);
GO
DELETE FROM [1064718_DWH].[Dim].[Producto];
DBCC CHECKIDENT ('[1064718_DWH].[Dim].[Producto]',RESEED, 0);
GO
DELETE FROM [1064718_DWH].[Dim].[Fecha];
GO

/*********************************************************************/
/*						Llenado de Datos							 */
/*********************************************************************/

USE [AdventureWorks2019]
GO

-------------CLIENTE----------

INSERT INTO 
	[1064718_DWH].[Dim].[Cliente]
SELECT DISTINCT
	C.CustomerID AS CustomerKey,
	P.FirstName AS FirstName,
	P.LastName AS LastName,
	PD.BirthDate AS BirthDate,
	PD.Gender AS Gender,
	PP.PhoneNumber AS Phone
FROM Sales.Customer C
INNER JOIN Person.Person P 
	ON C.PersonID=P.BusinessEntityID
LEFT JOIN Sales.vPersonDemographics PD 
	ON P.BusinessEntityID=PD.BusinessEntityID
LEFT JOIN Person.PersonPhone PP
	ON P.BusinessEntityID=PP.BusinessEntityID
GO

-------------MONEDA----------

INSERT INTO 
	[1064718_DWH].[Dim].[Moneda]
SELECT DISTINCT 
	CurrencyCode AS CurrencyKey,
	Name AS CurrencyName
FROM Sales.Currency;

GO

-------------PRODUCTO----------

INSERT INTO 
	[1064718_DWH].[Dim].[Producto]
SELECT 
	ProductID AS ProductKey,
	Name AS ProductName,
	ProductNumber AS ProductNumber
FROM Production.Product;

GO

-------------FECHA----------

DECLARE @StartDate DATETIME
DECLARE @EndDate DATETIME
SET @StartDate = '2010-01-01'
SET @EndDate = '2015-12-31'
SET DATEFIRST 1;

WHILE @StartDate <= @EndDate
      BEGIN
             INSERT INTO [1064718_DWH].[Dim].[Fecha]
             (
                    [CalendarDate]
				   ,[CalendarKey]
				   ,[dayOfWeekNum]
				   ,[dayOfWeekName]
				   ,[dayOfCalendarMonthNum]
				   ,[dayOfCalendarYearNum]
				   ,[CalendarWeekNum]
				   ,[calendarMonthNum]
				   ,[calendarMonthName]
				   ,[calendarQuarterNum]
				   ,[calendarYearNum]
             )
             SELECT
                   @StartDate,
				   CONVERT(nvarchar(8), @StartDate, 112),
				   DATEPART(WEEKDAY, @StartDate),
				   DATENAME(WEEKDAY, ( DATEPART(WEEKDAY, @StartDate)  + @@DATEFIRST + 5) % 7),
				   DATEPART(DAY, @StartDate),
				   DATEPART(DAYOFYEAR, @StartDate),
				   DATEPART(WEEK, @StartDate),
				   DATEPART(MONTH, @StartDate),
				   DATENAME(MONTH, DATEPART(MONTH, @StartDate)),
				   DATEPART(QUARTER, @StartDate),
				   DATEPART(YEAR, @StartDate)

             SET @StartDate = DATEADD(dd, 1, @StartDate)
      END
GO

-------------VENTAS----------

INSERT INTO 
	[1064718_DWH].[Fact].[Ventas]
(
	   [CustomerKey]
      ,[CurrencyKey]
      ,[ProductKey]
      ,[CalendarKey]
      ,[UnitPrice]
      ,[OrderQuantity]
      ,[TotalProductCost]
      ,[OrderDate]
      ,[DueDate]
)
SELECT
	C.CustomerID AS CustomerKey,
	CurrencyCode AS CurrencyKey,
	ProductID AS ProductKey,
	CONVERT(nvarchar(8), OrderDate, 112) AS CalendarKey,
	UnitPrice AS UnitPrice,
	OrderQty AS OrderQuantity,
	(UnitPrice * OrderQty) AS TotalProductCost,
	OrderDate AS OrderDate,
	DueDate AS DueDate
FROM Sales.SalesOrderDetail SOD
INNER JOIN Sales.SalesOrderHeader SOH 
	ON SOD.SalesOrderID = SOH.SalesOrderID
INNER JOIN Sales.SalesTerritory ST
	ON SOH.TerritoryID = ST.TerritoryID
INNER JOIN Sales.CountryRegionCurrency CRC
	ON ST.CountryRegionCode = CRC.CountryRegionCode
INNER JOIN Sales.Customer C 
	ON SOH.CustomerID = C.CustomerID;

GO