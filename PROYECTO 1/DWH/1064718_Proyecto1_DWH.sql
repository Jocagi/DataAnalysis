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
/*					Creación de Base de Datos						 */
/*********************************************************************/

USE master
GO

IF EXISTS (SELECT * FROM sysdatabases WHERE NAME='1064718_DWH')
		DECLARE @DatabaseName nvarchar(50)
		SET @DatabaseName = N'1064718_DWH'

		DECLARE @SQL varchar(max)
		SELECT @SQL = COALESCE(@SQL,'') + 'Kill ' + Convert(varchar, SPId) + ';'
		FROM MASTER..SysProcesses
		WHERE DBId = DB_ID(@DatabaseName) AND SPId <> @@SPId

		EXEC(@SQL);

		DROP DATABASE [1064718_DWH];
GO

CREATE DATABASE [1064718_DWH];
GO

/*********************************************************************/
/*						Creación de Esquemas						 */
/*********************************************************************/

USE [1064718_DWH];
GO
CREATE SCHEMA Fact;
GO
CREATE SCHEMA Dim;
GO

/*********************************************************************/
/*					Generación de dimensiones						 */
/*********************************************************************/

/*-----------ELIMINAR CONSTRAINTS----------*/

IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_CATALOG='1064718_DWH' AND CONSTRAINT_NAME = 'Customer_FK')
	ALTER TABLE [Fact].[Ventas]  DROP  CONSTRAINT [Customer_FK] 
GO
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_CATALOG='1064718_DWH' AND CONSTRAINT_NAME = 'Currency_FK')
	ALTER TABLE [Fact].[Ventas]  DROP  CONSTRAINT [Currency_FK]
GO
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_CATALOG='1064718_DWH' AND CONSTRAINT_NAME = 'Product_FK')
	ALTER TABLE [Fact].[Ventas]  DROP  CONSTRAINT [Product_FK] 
GO
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_CATALOG='1064718_DWH' AND CONSTRAINT_NAME = 'Calendar_FK')
	ALTER TABLE [Fact].[Ventas]  DROP  CONSTRAINT [Calendar_FK]
GO

--- Nota, a cada columna se asigna un nombre significativo a partir de un alias.

/*-------------FECHA----------*/

USE [1064718_DWH];

IF OBJECT_ID('1064718_DWH.Dim.Fecha') IS NOT NULL 
	DROP TABLE [1064718_DWH].[Dim].[Fecha];

CREATE TABLE [Dim].[Fecha](
	[CalendarKey] [nvarchar](8) NOT NULL,
	[CalendarDate] [date] NOT NULL,
	[dayOfWeekNum] [int] NULL,
	[dayOfWeekName] [nvarchar](30) NULL,
	[dayOfCalendarMonthNum] [int] NULL,
	[dayOfCalendarYearNum] [int] NULL,
	[CalendarWeekNum] [int] NULL,
	[calendarMonthNum] [int] NULL,
	[calendarMonthName] [nvarchar](30) NULL,
	[calendarQuarterNum] [int] NULL,
	[calendarYearNum] [int] NULL,
	PRIMARY KEY (CalendarKey)
)
GO

/*-------------CLIENTE----------*/

USE [1064718_DWH];

IF OBJECT_ID('1064718_DWH.Dim.Cliente') IS NOT NULL 
	DROP TABLE [1064718_DWH].[Dim].[Cliente];

CREATE TABLE [Dim].[Cliente](
	[CustomerKey] [int] NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[BirthDate] [datetime] NULL,
	[Gender] [nvarchar](1) NULL,
	[Phone] [nvarchar](25) NULL,
	PRIMARY KEY (CustomerKey)
)
GO

/*-------------MONEDA----------*/

USE [1064718_DWH];

IF OBJECT_ID('1064718_DWH.Dim.Moneda') IS NOT NULL 
	DROP TABLE [1064718_DWH].[Dim].[Moneda];

CREATE TABLE [Dim].[Moneda](
	[CurrencyKey] [nchar](3) NOT NULL,
	[CurrencyName] [nvarchar](50) NOT NULL,
	PRIMARY KEY (CurrencyKey)
)
GO

/*-------------PRODUCTO----------*/

USE [1064718_DWH];

IF OBJECT_ID('1064718_DWH.Dim.Producto') IS NOT NULL 
	DROP TABLE [1064718_DWH].[Dim].[Producto];

CREATE TABLE [Dim].[Producto](
	[ProductKey] [int] NOT NULL,
	[ProductName] [nvarchar](50) NOT NULL,
	[ProductNumber] [nvarchar](25) NOT NULL,
	PRIMARY KEY (ProductKey)
)
GO

/*********************************************************************/
/*						Surrogate Key								 */
/*********************************************************************/

USE [1064718_DWH];
ALTER TABLE [1064718_DWH].[Dim].[Cliente] ADD SurrogateKey INT IDENTITY(1,1);
ALTER TABLE [1064718_DWH].[Dim].[Moneda] ADD SurrogateKey INT IDENTITY(1,1);
ALTER TABLE [1064718_DWH].[Dim].[Producto] ADD SurrogateKey INT IDENTITY(1,1);
GO

/*********************************************************************/
/*						Valores por defecto							 */
/*********************************************************************/

USE [1064718_DWH];
ALTER TABLE [1064718_DWH].[Dim].[Cliente] ADD  DEFAULT ('1995-01-01') FOR [BirthDate];
ALTER TABLE [1064718_DWH].[Dim].[Cliente] ADD  DEFAULT ('O') FOR [Gender];
ALTER TABLE [1064718_DWH].[Dim].[Cliente] ADD  DEFAULT ('555-555') FOR [Phone];
GO

/*********************************************************************/
/*						Tabla de Hechos								 */
/*********************************************************************/

USE [1064718_DWH];

IF OBJECT_ID('1064718_DWH.Fact.Ventas') IS NOT NULL 
	DROP TABLE [1064718_DWH].[Fact].[Ventas];

CREATE TABLE [Fact].[Ventas](
	[ID] [int] identity(1,1) NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[CurrencyKey] [nchar](3) NOT NULL,
	[ProductKey] [int] NOT NULL,
	[CalendarKey] [nvarchar](8) NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[OrderQuantity] [smallint] NOT NULL,
	[TotalProductCost] [money] NULL,
	[OrderDate] [datetime] NOT NULL,
	[DueDate] [datetime] NOT NULL,
	PRIMARY KEY(ID)
); 
GO

/*********************************************************************/
/*							Referencias								 */
/*********************************************************************/

USE [1064718_DWH]
GO
ALTER TABLE [Fact].[Ventas]  WITH CHECK ADD  CONSTRAINT [Customer_FK] FOREIGN KEY([CustomerKey])
REFERENCES [Dim].[Cliente] ([CustomerKey])
GO
ALTER TABLE [Fact].[Ventas]  WITH CHECK ADD  CONSTRAINT [Currency_FK] FOREIGN KEY([CurrencyKey])
REFERENCES [Dim].[Moneda] ([CurrencyKey])
GO
ALTER TABLE [Fact].[Ventas]  WITH CHECK ADD  CONSTRAINT [Product_FK] FOREIGN KEY([ProductKey])
REFERENCES [Dim].[Producto] ([ProductKey])
GO
ALTER TABLE [Fact].[Ventas]  WITH CHECK ADD  CONSTRAINT [Calendar_FK] FOREIGN KEY([CalendarKey])
REFERENCES [Dim].[Fecha] ([CalendarKey])
GO

/*********************************************************************/
/*				Queries para creación de tablas						 */
/*********************************************************************/

/*

-------------CLIENTE----------

USE [AdventureWorks2019];

SELECT DISTINCT
	C.CustomerID AS CustomerKey,
	P.FirstName AS FirstName,
	P.LastName AS LastName,
	PD.BirthDate AS BirthDate,
	PD.Gender AS Gender,
	PP.PhoneNumber AS Phone
	--INTO [1064718_DWH].[Dim].[Cliente]
FROM Sales.Customer C
INNER JOIN Person.Person P 
	ON C.PersonID=P.BusinessEntityID
LEFT JOIN Sales.vPersonDemographics PD 
	ON P.BusinessEntityID=PD.BusinessEntityID
LEFT JOIN Person.PersonPhone PP
	ON P.BusinessEntityID=PP.BusinessEntityID;

GO


-------------MONEDA----------

USE [AdventureWorks2019];

SELECT DISTINCT 
	CurrencyCode AS CurrencyKey,
	Name AS CurrencyName
	--INTO [1064718_DWH].[Dim].[Moneda]
FROM Sales.Currency;


-------------PRODUCTO----------

USE [AdventureWorks2019];

SELECT 
	ProductID AS ProductKey,
	Name AS ProductName,
	ProductNumber AS ProductNumber
	--INTO [1064718_DWH].[Dim].[Producto]
FROM Production.Product;


-------------VENTAS----------

USE [AdventureWorks2019];
SELECT 
	CustomerID AS CustomerKey,
	CurrencyCode AS CurrencyKey,
	ProductID AS ProductKey,
	OrderDate AS CalendarKey,
	UnitPrice AS UnitPrice,
	OrderQty AS OrderQuantity,
	(UnitPrice * OrderQty) AS TotalProductCost,
	OrderDate AS OrderDate,
	DueDate AS DueDate
	--INTO [1064718_DWH].[Fact].[Ventas]
FROM Sales.SalesOrderDetail SOD
INNER JOIN Sales.SalesOrderHeader SOH 
	ON SOD.SalesOrderID = SOH.SalesOrderID
INNER JOIN Sales.SalesTerritory ST
	ON SOH.TerritoryID = ST.TerritoryID
INNER JOIN Sales.CountryRegionCurrency CRC
	ON ST.CountryRegionCode = CRC.CountryRegionCode;

*/