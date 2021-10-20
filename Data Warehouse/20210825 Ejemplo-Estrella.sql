/*********************************************************************/
/*						 Tabla de Hechos							 */
/*********************************************************************/
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
--INTO Northwind_dwh_v2.dbo.Sales
FROM Northwind.dbo.[Order Details] AS a
INNER JOIN Northwind.dbo.[Orders] AS b
ON a.OrderID = b.OrderID
INNER JOIN Northwind.dbo.Products AS c
ON a.ProductID = c.ProductID;


/*********************************************************************/
/*								 DHW								 */
/*********************************************************************/
USE master
GO
if exists (select * from sysdatabases where name='Northwind')
		drop database Northwind_dwh_v2
go

DECLARE @device_directory NVARCHAR(520)
SELECT @device_directory = SUBSTRING(filename, 1, CHARINDEX(N'master.mdf', LOWER(filename)) - 1)
FROM master.dbo.sysaltfiles WHERE dbid = 1 AND fileid = 1

EXECUTE (N'CREATE DATABASE Northwind_dwh_v2
  ON PRIMARY (NAME = N''Northwind_dwh_v2'', FILENAME = N''' + @device_directory + N'northwnd_dwh_v2.mdf'')
  LOG ON (NAME = N''Northwind_dwh_v2_log'',  FILENAME = N''' + @device_directory + N'northwnd_dwh_v2.ldf'')')
go

/*********************************************************************/
/*						Construir tablas DWH						 */
/*********************************************************************/

IF OBJECT_ID('Northwind_dwh_v2..Sales') IS NOT NULL DROP TABLE Northwind_dwh_v2.[dbo].[Sales]
CREATE TABLE Northwind_dwh_v2.[dbo].[Sales](
	[Correlativo] [INT] IDENTITY (1,1),
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

IF OBJECT_ID('Northwind_dwh_v2..Dim_Categories') IS NOT NULL DROP TABLE Northwind_dwh_v2.[dbo].[Dim_Categories]
CREATE TABLE Northwind_dwh_v2.[dbo].[Dim_Categories](
	[CategoryID] [int] NOT NULL,
	[CategoryName] [nvarchar](15) NOT NULL,
	[Description] [ntext] NULL,
	[Picture] [image] NULL
)
GO

IF OBJECT_ID('Northwind_dwh_v2..Dim_Customers') IS NOT NULL DROP TABLE Northwind_dwh_v2.[dbo].[Dim_Customers]
CREATE TABLE Northwind_dwh_v2.[dbo].[Dim_Customers](
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

IF OBJECT_ID('Northwind_dwh_v2..Dim_Employees') IS NOT NULL DROP TABLE Northwind_dwh_v2.[dbo].[Dim_Employees]
CREATE TABLE Northwind_dwh_v2.[dbo].[Dim_Employees](
	[EmployeeID] [int] NOT NULL,
	[LastName] [nvarchar](20) NOT NULL,
	[FirstName] [nvarchar](10) NOT NULL,
	[Title] [nvarchar](30) NULL,
	[TitleOfCourtesy] [nvarchar](25) NULL,
	[BirthDate] [datetime] NULL
)
GO


IF OBJECT_ID('Northwind_dwh_v2..Dim_Products') IS NOT NULL DROP TABLE Northwind_dwh_v2.[dbo].[Dim_Products]
CREATE TABLE Northwind_dwh_v2.[dbo].[Dim_Products](
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

/*********************************************************************/
/*						Relación de tablas							 */
/*********************************************************************/

ALTER TABLE Northwind_dwh_v2.dbo.Dim_Categories ADD PRIMARY KEY (CategoryID);
ALTER TABLE Northwind_dwh_v2.dbo.Dim_Customers ADD PRIMARY KEY (CustomerID);
ALTER TABLE Northwind_dwh_v2.dbo.Dim_Employees ADD PRIMARY KEY (EmployeeID);
ALTER TABLE Northwind_dwh_v2.dbo.Dim_Products ADD PRIMARY KEY (ProductID);

ALTER TABLE Northwind_dwh_v2.dbo.Sales ADD CONSTRAINT FK_CategoryID FOREIGN KEY (CategoryID) REFERENCES Northwind_dwh_v2.dbo.Dim_Categories (CategoryID);
ALTER TABLE Northwind_dwh_v2.dbo.Sales ADD CONSTRAINT FK_CustomerID FOREIGN KEY (CustomerID) REFERENCES Northwind_dwh_v2.dbo.Dim_Customers (CustomerID);
ALTER TABLE Northwind_dwh_v2.dbo.Sales ADD CONSTRAINT FK_EmployeeID FOREIGN KEY (EmployeeID) REFERENCES Northwind_dwh_v2.dbo.Dim_Employees (EmployeeID);
ALTER TABLE Northwind_dwh_v2.dbo.Sales ADD CONSTRAINT FK_ProductID FOREIGN KEY (ProductID) REFERENCES Northwind_dwh_v2.dbo.Dim_Products (ProductID);


/*********************************************************************/
/*				Llenado de Dimensiones y de Hechos					 */
/*********************************************************************/

DELETE FROM Northwind_dwh_v2.dbo.Dim_Customers;
INSERT INTO Northwind_dwh_v2.dbo.Dim_Customers
SELECT * 
--INTO Northwind_dwh_v2.dbo.Dim_Customers
FROM Northwind.dbo.Customers;

-----------------------------------------------------------------------

DELETE FROM Northwind_dwh_v2.dbo.Dim_Products;
INSERT INTO Northwind_dwh_v2.dbo.Dim_Products
SELECT * 
--INTO Northwind_dwh_v2.dbo.Dim_Products
FROM Northwind.dbo.Products;

-----------------------------------------------------------------------

DELETE FROM Northwind_dwh_v2.dbo.Dim_Employees;
INSERT INTO Northwind_dwh_v2.dbo.Dim_Employees
SELECT
	EmployeeID,
	LastName,
	FirstName,
	Title,
	TitleOfCourtesy,
	BirthDate
--INTO Northwind_dwh_v2.dbo.Dim_Employees
FROM Northwind.dbo.Employees;

-----------------------------------------------------------------------

DELETE FROM Northwind_dwh_v2.dbo.Dim_Categories;
INSERT INTO Northwind_dwh_v2.dbo.Dim_Categories
SELECT 
* 
--INTO Northwind_dwh_v2.dbo.Dim_Categories
FROM Northwind.dbo.Categories;

-----------------------------------------------------------------------

DELETE FROM Northwind_dwh_v2.dbo.Sales;
INSERT INTO Northwind_dwh_v2.dbo.Sales

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
--INTO Northwind_dwh_v2.dbo.Sales
FROM Northwind.dbo.[Order Details] AS a
INNER JOIN Northwind.dbo.[Orders] AS b
ON a.OrderID = b.OrderID
INNER JOIN Northwind.dbo.Products AS c
ON a.ProductID = c.ProductID;