

/*******************************************************************/
/*                      Tabla de Hechos							   */
/*******************************************************************/

select
	cast(b.OrderDate as date) as OrderDate
	,month(b.OrderDate) as month_sales
	,year(b.OrderDate) as year_sales
	,day(b.OrderDate) as day_sales
	,a.ProductID
	,b.CustomerID
	,b.EmployeeID
	,c.CategoryID
	,a.UnitPrice
	,a.Quantity
	,a.Discount
	,(a.UnitPrice*a.Quantity)-a.Discount as Sales_dolar
--into Northwind_dwh_v2.dbo.sales
from Northwind.dbo.[Order Details] as a
inner join Northwind.dbo.Orders as b
on a.OrderID = b.OrderID
inner join Northwind.dbo.Products as c
on a.ProductID = c.ProductID


/*******************************************************************/
/*							   DHW								   */
/*******************************************************************/

SET NOCOUNT ON
GO

USE master
GO
if exists (select * from sysdatabases where name='Northwind')
		drop database Northwind_dwh_v2
go

DECLARE @device_directory NVARCHAR(520)
SELECT @device_directory = SUBSTRING(filename, 1, CHARINDEX(N'master.mdf', LOWER(filename)) - 1)
FROM master.dbo.sysaltfiles WHERE dbid = 1 AND fileid = 1

EXECUTE (N'CREATE DATABASE Northwind_dwh_v2
  ON PRIMARY (NAME = N''Northwind_dwh_v2'', FILENAME = N''' + @device_directory + N'northwind_dwh_v2.mdf'')
  LOG ON (NAME = N''Northwind_dwh_v2_log'',  FILENAME = N''' + @device_directory + N'northwind_dwh_v2.ldf'')')
go

set quoted_identifier on
GO
/*******************************************************************/
/*		     	Construir tablas DWH							   */
/*******************************************************************/

if OBJECT_ID('Northwind_dwh_v2..sales') IS NOT NULL drop table Northwind_dwh_v2.[dbo].[sales]
CREATE TABLE Northwind_dwh_v2.[dbo].[sales](
	correlativo int identity (1,1) not null,
	[OrderDate] [date] NULL,
	[month_sales] [int] NULL,
	[year_sales] [int] NULL,
	[day_sales] [int] NULL,
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

if OBJECT_ID('Northwind_dwh_v2..Dim_Categories') IS NOT NULL drop table Northwind_dwh_v2.[dbo].Dim_Categories
CREATE TABLE Northwind_dwh_v2.[dbo].[Dim_Categories](
	[CategoryID] [int] NOT NULL,
	[CategoryName] [nvarchar](15) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[Picture] [image] NULL
) 
GO

if OBJECT_ID('Northwind_dwh_v2..Dim_Customers') IS NOT NULL drop table Northwind_dwh_v2.[dbo].Dim_Customers
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

if OBJECT_ID('Northwind_dwh_v2..Dim_Employees') IS NOT NULL drop table Northwind_dwh_v2.[dbo].Dim_Employees
CREATE TABLE Northwind_dwh_v2.[dbo].[Dim_Employees](
	[EmployeeID] [int] NOT NULL,
	[LastName] [nvarchar](20) NOT NULL,
	[FirstName] [nvarchar](10) NOT NULL,
	[Title] [nvarchar](30) NULL,
	[TitleOfCourtesy] [nvarchar](25) NULL,
	[BirthDate] [datetime] NULL
) 
GO

if OBJECT_ID('Northwind_dwh_v2..Dim_Products') IS NOT NULL drop table Northwind_dwh_v2.[dbo].Dim_Products
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

/*******************************************************************/
/*				    Relacion de tablas								   */
/*******************************************************************/

ALTER TABLE Northwind_dwh_v2.dbo.Dim_Categories ADD PRIMARY KEY (CategoryID)
ALTER TABLE Northwind_dwh_v2.dbo.Dim_Customers ADD PRIMARY KEY (CustomerID)
ALTER TABLE Northwind_dwh_v2.dbo.Dim_Employees ADD PRIMARY KEY (EmployeeID)
ALTER TABLE Northwind_dwh_v2.dbo.Dim_Products ADD PRIMARY KEY (ProductID)

ALTER TABLE Northwind_dwh_v2.dbo.sales ADD CONSTRAINT FK_CategoryID FOREIGN KEY (CategoryID) REFERENCES Northwind_dwh_v2.dbo.Dim_Categories (CategoryID)
ALTER TABLE Northwind_dwh_v2.dbo.sales ADD CONSTRAINT FK_CustomerID FOREIGN KEY (CustomerID) REFERENCES Northwind_dwh_v2.dbo.Dim_Customers (CustomerID)
ALTER TABLE Northwind_dwh_v2.dbo.sales ADD CONSTRAINT FK_EmployeeID FOREIGN KEY (EmployeeID) REFERENCES Northwind_dwh_v2.dbo.Dim_Employees (EmployeeID)
ALTER TABLE Northwind_dwh_v2.dbo.sales ADD CONSTRAINT FK_ProductID FOREIGN KEY (ProductID) REFERENCES Northwind_dwh_v2.dbo.Dim_Products (ProductID)

/*******************************************************************/
/*		   Llenado de Dimensiones y de Hechos					   */
/*******************************************************************/

delete from Northwind_dwh_v2.dbo.Dim_Customers

insert into Northwind_dwh_v2.dbo.Dim_Customers
select
*
--into Northwind_dwh_v2.dbo.Dim_Customers
from Northwind.dbo.Customers

----------------------------------------------------------------------
delete from Northwind_dwh_v2.dbo.Dim_Products

insert into Northwind_dwh_v2.dbo.Dim_Products
select
*
--into Northwind_dwh_v2.dbo.Dim_Products
from Northwind.dbo.Products

----------------------------------------------------------------------
delete from Northwind_dwh_v2.dbo.Dim_Employees

insert into Northwind_dwh_v2.dbo.Dim_Employees
select
	EmployeeID
	,LastName
	,FirstName
	,Title
	,TitleOfCourtesy
	,BirthDate
--into Northwind_dwh_v2.dbo.Dim_Employees
from Northwind.dbo.Employees

----------------------------------------------------------------------
delete from Northwind_dwh_v2.dbo.Dim_Categories

insert into Northwind_dwh_v2.dbo.Dim_Categories
select
*
--into Northwind_dwh_v2.dbo.Dim_Categories
from Northwind.dbo.Categories

----------------------------------------------------------------------
delete from Northwind_dwh_v2.dbo.sales

insert into Northwind_dwh_v2.dbo.sales

select
	cast(b.OrderDate as date) as OrderDate
	,month(b.OrderDate) as month_sales
	,year(b.OrderDate) as year_sales
	,day(b.OrderDate) as day_sales
	,a.ProductID
	,b.CustomerID
	,b.EmployeeID
	,c.CategoryID
	,a.UnitPrice
	,a.Quantity
	,a.Discount
	,(a.UnitPrice*a.Quantity)-a.Discount as Sales_dolar
--into Northwind_dwh_v2.dbo.sales
from Northwind.dbo.[Order Details] as a
inner join Northwind.dbo.Orders as b
on a.OrderID = b.OrderID
inner join Northwind.dbo.Products as c
on a.ProductID = c.ProductID
