/*-------------CREACIÓN DE BASE----------*/
USE master
GO
IF  EXISTS (select *from sys.databases where name = 'ModeloDWH')
drop database ModeloDWH
IF  NOT EXISTS (select *from sys.databases where name = 'ModeloDWH')
create database ModeloDWH

/*------------------DIMENSIONES-------------------*/
		/*-------------CLIENTES----------*/
SELECT ROW_NUMBER()OVER(ORDER BY CUS.CustomerID) AS ID, CUS.CustomerID, BG.BuyingGroupName, CITIES.CityName, Provinces.StateProvinceCode, Provinces.StateProvinceName, COUNTRY.CountryName, CUS.CreditLimit
FROM WideWorldImporters.Sales.Customers as CUS 
inner join WideWorldImporters.sales.BuyingGroups as BG on (CUS.BuyingGroupID = BG.BuyingGroupID)
INNER JOIN WideWorldImporters.Application.Cities as CITIES on(CITIES.CityID = CUS.DeliveryCityID)
INNER JOIN WideWorldImporters.Application.StateProvinces as PROVINCES on(CITIES.StateProvinceID = Provinces.StateProvinceID)
INNER JOIN WideWorldImporters.Application.Countries as COUNTRY on (Provinces.CountryID = COUNTRY.CountryID)
USE [ModeloDWH]
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Clientes](
	[ID] [int] IDENTITY,
	[CustomerID] [int] NOT NULL,
	[BuyingGroupName] [nvarchar](50) NOT NULL,
	[CityName] [nvarchar](50) NOT NULL,
	[StateProvinceCode] [nvarchar](5) NOT NULL,
	[StateProvinceName] [nvarchar](50) NOT NULL,
	[CountryName] [nvarchar](60) NOT NULL,
	[CreditLimit] [decimal](18, 2) NULL,
 CONSTRAINT [Cliente_PK_CID] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [Cliente_NOTNULL_CID2] UNIQUE NONCLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
		/*-------------FECHAS----------*/
SELECT  InvoiceDate as CalendarDate, 
		DAY(InvoiceDate) as dayOfCalendarMonthNum, 
		DATEPART(ISO_WEEK, InvoiceDate) as CalendarWeekNum, 
		DATEPART(DW, InvoiceDate) as dayOfWeekNum, 
		DATEPART ( DAYOFYEAR, InvoiceDate) as dayOfCalendarYearNum, 
		MONTH(InvoiceDate) AS calendarMonthNum, 
		YEAR(InvoiceDate) AS calendarYearNum,
		DATEPART(QUARTER, InvoiceDate) AS calendarQuerterNum,
		DATENAME(dw,InvoiceDate) as dayOfWeekName,
		DATENAME (MONTH, InvoiceDate) AS calendarMonthName
FROM WideWorldImporters.Sales.Invoices 

USE [ModeloDWH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Fecha](
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

		/*----------StockItem----------*/
SELECT ROW_NUMBER()OVER(ORDER BY SI.STOCKITEMID) AS ID, SI.StockItemID, SI.StockItemName, suppliers.SupplierName, color.ColorName, TP.PackageTypeName AS UnitPackageTypeName, PT.PackageTypeName AS OuterPackageTypeName, SI.Brand, SI.Size, SI.LeadTimeDays, SI.TaxRate, SI.UnitPrice, SI.RecommendedRetailPrice, si.TypicalWeightPerUnit, SI.Photo
FROM  WideWorldImporters.Warehouse.StockItems as SI 
INNER JOIN WideWorldImporters.Purchasing.Suppliers as suppliers on (SI.SupplierID = suppliers.SupplierID)
INNER JOIN WideWorldImporters.Warehouse.Colors as color on (color.ColorID = SI.ColorID)
INNER JOIN WideWorldImporters.Warehouse.PackageTypes as TP on (TP.PackageTypeID = SI.UnitPackageID)
INNER JOIN WideWorldImporters.Warehouse.PackageTypes as PT on(PT.PackageTypeID =  SI.OuterPackageID)

USE [ModeloDWH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[StockItem](
	[ID][int] Identity,
	[StockItemID] [int] NOT NULL,
	[StockItemName] [nvarchar](100) NOT NULL,
	[SupplierName] [nvarchar](100) NOT NULL,
	[ColorName] [nvarchar](20) NOT NULL,
	[UnitPackageTypeName] [nvarchar](50) NOT NULL,
	[OuterPackageTypeName] [nvarchar](50) NOT NULL,
	[Brand] [nvarchar](50) NULL,
	[Size] [nvarchar](20) NULL,
	[LeadTimeDays] [int] NOT NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[UnitPrice] [decimal](18, 2) NOT NULL,
	[RecommendedRetailPrice] [decimal](18, 2) NULL,
	[TypicalWeightPerUnit] [decimal](18, 3) NOT NULL,
	[Photo] [varbinary](max) NULL,
 CONSTRAINT [StockItem_PK_ID] PRIMARY KEY CLUSTERED 
(
	[StockItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [StockItem_NOTNULL_ID] UNIQUE NONCLUSTERED 
(
	[StockItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/*------------------LLAVE PRIMARIA-------------------*/
		/*----------CLIENTES----------*/



		/*----------StockItem----------*/
alter table ModeloDWH.DBO.StockItem
alter column ID int not null;
GO

alter table ModeloDWH.DBO.Fecha
alter column CalendarDate date not null;
GO
ALTER TABLE ModeloDWH.dbo.Fecha ADD CONSTRAINT Fecha_PK_UNIQUE UNIQUE (CalendarDate);
ALTER TABLE ModeloDWH.dbo.Fecha ADD CONSTRAINT FCEHA_PK_CalendarDate PRIMARY KEY (CalendarDate);
GO
/*--------------------VISTAS-------------------*/
		/*----------CLIENTES----------*/
CREATE VIEW V_Dim_Clientes AS 
SELECT C.ID as Identificador, 
		C.CustomerID as [Identificador del consumidor], 
		ISNULL(CreditLimit,0) AS [límite de crédito], 
		C.CountryName AS [País], 
		C.CityName as [Ciudad], 
		C.BuyingGroupName as [Nombre del grupo comprador], 
		C.StateProvinceCode as [Código de provincia], 
		C.StateProvinceName as [Nombre de provincia]
FROM ModeloDWH.dbo.Clientes C
GO

		/*----------FECHA----------*/
CREATE VIEW V_Dim_Fecha AS 
SELECT F.CalendarDate as [Fecha],
		F.calendarMonthName as [Mes(nombre)],
		F.calendarMonthNum as [Mes(número)],
		F.calendarQuerterNum as [Número de cuatrimestre],
		F.CalendarWeekNum as [Semana(número)],
		F.calendarYearNum as [Año],
		F.dayOfCalendarMonthNum as [Día(número del mes)],
		F.dayOfCalendarYearNum as [Día(número del año)],
		F.dayOfWeekName as [Día(nombre)],
		F.dayOfWeekNum as [Día(número de la semana)]
FROM ModeloDWH.dbo.Fecha F
GO

		/*----------StockItem----------*/
CREATE VIEW V_Dim_StockItem AS 
		SELECT S.ID as [Identificador],
		S.StockItemID AS[identificador del stock],
		S.StockItemName AS [Nombre del item],
		S.SupplierName AS [Nombre del distribuidor],
		S.ColorName AS Color,
		S.UnitPackageTypeName AS [Nombre del tipo de paquete],
		S.OuterPackageTypeName AS[Tipo de paquete exterior],
		ISNULL(Brand,'Northwind') AS Marca,
		ISNULL(Size,'S') AS Talla,
		S.LeadTimeDays AS [Días de promoción],
		S.TaxRate AS [Tasa de impuesto],
		S.UnitPrice AS [Precio por unidad],
		S.RecommendedRetailPrice AS [Precio recomendado de venta],
		S.TypicalWeightPerUnit AS [Peso por unidad],
		ISNULL(Photo,010101) AS Foto
FROM ModeloDWH.dbo.StockItem s
GO

/*------------------TABLA DE HECHOS-------------------*/
			/*----------Invoices----------*/

SELECT ROW_NUMBER()OVER(ORDER BY ins.InvoiceID) AS ID, 
		ins.InvoiceID,
		ins.CustomerID,
		ins.InvoiceDate,
		insL.StockItemID,
		insL.Quantity,
		insL.UnitPrice,
		insL.TaxRate,
		insL.TaxAmount,
		insL.LineProfit,
		insL.ExtendedPrice,
		GETDATE() AS CreatedDate
FROM WideWorldImporters.Sales.Invoices AS ins
		inner join WideWorldImporters.Sales.InvoiceLines AS insL on(ins.InvoiceID = insl.InvoiceID)

USE [ModeloDWH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Invoices](
	[ID] [bigint] IDENTITY,
	[InvoiceID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[InvoiceDate] [date] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[TaxAmount] [decimal](18, 2) NOT NULL,
	[LineProfit] [decimal](18, 2) NOT NULL,
	[ExtendedPrice] [decimal](18, 2) NOT NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Invoices] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[Invoices]  WITH CHECK ADD  CONSTRAINT [StockItem_FK] FOREIGN KEY([StockItemID])
REFERENCES [dbo].[StockItem] ([StockItemID])
GO

ALTER TABLE [dbo].[Invoices]  WITH CHECK ADD  CONSTRAINT [Clientes_FK] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Clientes] ([CustomerID])
GO

ALTER TABLE [dbo].[Invoices] CHECK CONSTRAINT [Clientes_FK]
GO

ALTER TABLE [dbo].[Invoices] CHECK CONSTRAINT [StockItem_FK]
GO

ALTER TABLE [dbo].[Invoices]  WITH CHECK ADD  CONSTRAINT [Date_FK] FOREIGN KEY([InvoiceDate])
REFERENCES [dbo].[Fecha] ([CalendarDate])
GO 
ALTER TABLE ModeloDWH.dbo.INVOICES ADD CONSTRAINT Cliente_NOTNULL_Invoices UNIQUE (ID);
ALTER TABLE ModeloDWH.dbo.INVOICES ADD CONSTRAINT Cliente_PK_invoices PRIMARY KEY (ID);
GO

/*--------------------VISTAS-------------------*/
		/*----------CLIENTES----------*/
CREATE VIEW V_FACT_Invoices AS 
SELECT I.ID as Identificador, 
		I.InvoiceID AS [Identificador de la factura],
		I.CustomerID as [Identificador del consumidor], 
		I.InvoiceDate AS [Fecha de la factura],
		I.StockItemID AS [Identificador Stock item],
		I.Quantity AS Cantidad,
		I.UnitPrice as [Precio unitario],
		I.TaxRate AS [Tasa de impuestos],
		I.TaxAmount as [Monto de impuestos],
		I.LineProfit as [Ganancia],
		I.ExtendedPrice AS [Precio extendido],
		I.CreatedDate as [Fecha de registro]
FROM ModeloDWH.dbo.Invoices AS i
GO
/************************PREGUNTAS****************************/
/*PREGUNTA 1*/
/*
¿Qué columnas son de tipo llave?
	R:// ID - Surrogate key
			CustomerID - Llave foránea
			StockItemID - Llave foránea
			InvoiceDate - Llave foránea
*/
/*PREGUNTA 2*/
/*
¿Qué columnas son Medidas y de que tipo es cada columna (aditiva, semi-aditiva o no aditiva)?
	R:// Todas son NO aditivas, ya que no se utilizan funciones de agregación.

*/
/*PREGUNTA 3*/
/*
¿El diagrama final es un modelo estrella o copo de nieve?
	R:// Diagrama de estrella. 
*/
