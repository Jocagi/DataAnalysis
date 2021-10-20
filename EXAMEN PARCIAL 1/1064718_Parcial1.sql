
/*
						EXAMEN PARCIAL 1
						José Carlos Girón
							1064718
*/

/*********************************************************************/
/*								 DHW								 */
/*********************************************************************/
USE master
GO
if exists (select * from sysdatabases where name='Parcial1_dwh_JoseGiron')
		drop database Parcial1_dwh_JoseGiron
go

create database Parcial1_dwh_JoseGiron;
go

USE Parcial1_dwh_JoseGiron;
GO

/*********************************************************************/
/*						 Tabla de Hechos							 */
/*********************************************************************/

IF OBJECT_ID('Parcial1_dwh_JoseGiron..H_Sales') IS NOT NULL DROP TABLE Parcial1_dwh_JoseGiron.[dbo].[H_Sales]
CREATE TABLE Parcial1_dwh_JoseGiron.[dbo].[H_Sales](
	[ID] [INT] IDENTITY (1,1),
	[OrderDate] [date] NULL,
	[Month_sales] [int] NULL,
	[Year_sales] [int] NULL,
	[Day_sales] [int] NULL,
	[ProductID] [int] NOT NULL,
	[CustomerID] [nchar](5) NULL,
	[EmployeeID] [int] NULL,
	[CategoryID] [int] NULL,
	[UnitPrice] [money] NOT NULL,
	[Quantity] [smallint] NOT NULL,
	[Discount] [real] NOT NULL,
	[Sales_dolar] [real] NULL
)
GO

/*********************************************************************/
/*						Tabla de Dimensiones						 */
/*********************************************************************/

IF OBJECT_ID('Parcial1_dwh_JoseGiron..Dim_Customers') IS NOT NULL DROP TABLE Parcial1_dwh_JoseGiron.[dbo].[Dim_Customers]
CREATE TABLE Parcial1_dwh_JoseGiron.[dbo].[Dim_Customers](
	[CustomerID] [nchar](5) NOT NULL,
	[CompanyName] [nvarchar](40) NOT NULL,
	[ContactName] [nvarchar](30) NULL,
	[ContactTitle] [nvarchar](30) NULL,
	[Address] [nvarchar](60) NULL,
	[City] [nvarchar](15) NULL,
	[Region] [nvarchar](15) NULL,
	[PostalCode] [nvarchar](10) NULL,
	[Country] [nvarchar](15) NULL,
	[Phone] [nvarchar](24) NULL,
	[Fax] [nvarchar](24) NULL
)
GO

IF OBJECT_ID('Parcial1_dwh_JoseGiron..Dim_Categories') IS NOT NULL DROP TABLE Parcial1_dwh_JoseGiron.[dbo].[Dim_Categories]
CREATE TABLE Parcial1_dwh_JoseGiron.[dbo].[Dim_Categories](
	[CategoryID] [int] NOT NULL,
	[CategoryName] [nvarchar](15) NOT NULL,
	[Description] [ntext] NULL,
	[Picture] [image] NULL
)
GO

IF OBJECT_ID('Parcial1_dwh_JoseGiron..Dim_Products') IS NOT NULL DROP TABLE Parcial1_dwh_JoseGiron.[dbo].[Dim_Products]
CREATE TABLE Parcial1_dwh_JoseGiron.[dbo].[Dim_Products](
	[ProductID] [int] NOT NULL,
	[ProductName] [nvarchar](40) NOT NULL,
	[SupplierID] [int] NULL,
	[CategoryID] [int] NULL,
	[QuantityPerUnit] [nvarchar](20) NULL,
	[UnitPrice] [money] NULL,
	[UnitsInStock] [smallint] NULL,
	[UnitsOnOrder] [smallint] NULL,
	[ReorderLevel] [smallint] NULL,
	[Discontinued] [bit] NOT NULL
)
GO

IF OBJECT_ID('Parcial1_dwh_JoseGiron..Dim_Fecha') IS NOT NULL DROP TABLE Parcial1_dwh_JoseGiron.[dbo].[Dim_Fecha]
CREATE TABLE Parcial1_dwh_JoseGiron.[dbo].[Dim_Fecha](
	[CalendarDate] [date] NOT NULL,
	[dayOfCalendarMonthNum] [int] NULL,
	[CalendarWeekNum] [int] NULL,
	[dayOfWeekNum] [int] NULL,
	[dayOfCalendarYearNum] [int] NULL,
	[calendarMonthNum] [int] NULL,
	[calendarYearNum] [int] NULL,
	[calendarQuerterNum] [int] NULL,
	[dayOfWeekName] [nvarchar](30) NULL,
	[calendarMonthName] [nvarchar](30) NULL
) ON [PRIMARY]
GO

/*********************************************************************/
/*						Relación de tablas							 */
/*********************************************************************/

ALTER TABLE Parcial1_dwh_JoseGiron.dbo.Dim_Categories ADD PRIMARY KEY (CategoryID);
ALTER TABLE Parcial1_dwh_JoseGiron.dbo.Dim_Customers ADD PRIMARY KEY (CustomerID);
ALTER TABLE Parcial1_dwh_JoseGiron.dbo.Dim_Products ADD PRIMARY KEY (ProductID);
ALTER TABLE Parcial1_dwh_JoseGiron.dbo.Dim_Fecha ADD PRIMARY KEY (CalendarDate);

ALTER TABLE Parcial1_dwh_JoseGiron.dbo.H_Sales ADD CONSTRAINT FK_CategoryID FOREIGN KEY (CategoryID) REFERENCES Parcial1_dwh_JoseGiron.dbo.Dim_Categories (CategoryID);
ALTER TABLE Parcial1_dwh_JoseGiron.dbo.H_Sales ADD CONSTRAINT FK_CustomerID FOREIGN KEY (CustomerID) REFERENCES Parcial1_dwh_JoseGiron.dbo.Dim_Customers (CustomerID);
ALTER TABLE Parcial1_dwh_JoseGiron.dbo.H_Sales ADD CONSTRAINT FK_ProductID FOREIGN KEY (ProductID) REFERENCES Parcial1_dwh_JoseGiron.dbo.Dim_Products (ProductID);
ALTER TABLE Parcial1_dwh_JoseGiron.dbo.H_Sales ADD CONSTRAINT FK_Date FOREIGN KEY (OrderDate) REFERENCES Parcial1_dwh_JoseGiron.dbo.Dim_Fecha (CalendarDate);

GO

/*********************************************************************/
/*				Llenado de Dimensiones y de Hechos					 */
/*********************************************************************/

DELETE FROM Parcial1_dwh_JoseGiron.dbo.Dim_Customers;
INSERT INTO Parcial1_dwh_JoseGiron.dbo.Dim_Customers
SELECT * 
FROM Northwind.dbo.Customers;
GO

-----------------------------------------------------------------------

DELETE FROM Parcial1_dwh_JoseGiron.dbo.Dim_Products;
INSERT INTO Parcial1_dwh_JoseGiron.dbo.Dim_Products
SELECT * 
FROM Northwind.dbo.Products;
GO

-----------------------------------------------------------------------

DELETE FROM Parcial1_dwh_JoseGiron.dbo.Dim_Categories;
INSERT INTO Parcial1_dwh_JoseGiron.dbo.Dim_Categories
SELECT 
* 
FROM Northwind.dbo.Categories;
GO

-----------------------------------------------------------------------

DELETE FROM Parcial1_dwh_JoseGiron.dbo.Dim_Fecha;
DECLARE @StartDate DATETIME
DECLARE @EndDate DATETIME
SET @StartDate = '1996-01-01'
SET @EndDate = '2001-12-31'

WHILE @StartDate <= @EndDate
      BEGIN
             INSERT INTO [Dim_Fecha]
             (
                   CalendarDate
             )
             SELECT
                   @StartDate

             SET @StartDate = DATEADD(dd, 1, @StartDate)
      END
GO
-----------------------------------------------------------------------

DELETE FROM Parcial1_dwh_JoseGiron.dbo.H_Sales;
INSERT INTO Parcial1_dwh_JoseGiron.dbo.H_Sales
SELECT
	CAST(b.OrderDate AS DATE) AS OrderDate,
	MONTH(b.OrderDate) AS Month_sales,
	YEAR(b.OrderDate) AS Year_sales,
	DAY(b.OrderDate) AS Day_sales,
	a.ProductID,
	b.CustomerID,
	b.EmployeeID,
	c.CategoryID,
	a.UnitPrice,
	a.Quantity,
	a.Discount,
	(a.UnitPrice * a.Quantity) - a.Discount AS Sales_dolar
FROM Northwind.dbo.[Order Details] AS a
INNER JOIN Northwind.dbo.[Orders] AS b
ON a.OrderID = b.OrderID
INNER JOIN Northwind.dbo.Products AS c
ON a.ProductID = c.ProductID;

GO