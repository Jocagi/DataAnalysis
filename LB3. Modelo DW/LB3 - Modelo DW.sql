/*
1.	Cree una nueva base de datos con las siguientes características
	a.	Nombre: ModeloDWH
	b.	Un esquema para las dimensiones y otro para las tablas de hechos
*/

CREATE DATABASE ModeloDWH;

CREATE SCHEMA Dimensiones;
CREATE SCHEMA Hechos;

SELECT * FROM sys.schemas;

/*
2.	Generar las Dimensiones
	i.	Dimensión de Clientes
		1.	Columnas: CustomerID, BuyingGroupName, CityName, StateProvinceCode, StateProvinceName, ContryName, CreditLimit
	ii.	Dimensión de Fecha
		1.	Columnas: CalendarDate, dayOfWeekNum, dayOfWeekName, dayOfCalendarMonthNum, dayOfCalendarYearNum, CalendarWeekNum, calendarMonthNum, calendarMonthName, calendarQuerterNum, calendarYearNum
	iii.	Dimensión de StockItem
		1.	Columnas:  StockItemID, StockItemName, SupplierName, ColorName, UnitPackageTypeName, OuterPackageTypeName, Brand, Size, LeadTimeDays, TaxRate, UnitPrice, RecommendedRetailPrice, TypicalWeightPerUnit, Photo, SupplierName
*/

SELECT 
	C.CustomerID, BG.BuyingGroupName, CT.CityName, SP.StateProvinceName, C.CreditLimit
INTO 
	[ModeloDWH].[Dimensiones].[Clientes]
FROM 
[WideWorldImporters].[Sales].[Customers] C
INNER JOIN [WideWorldImporters].[Sales].[BuyingGroups] BG 
	ON C.BuyingGroupID = BG.BuyingGroupID
INNER JOIN [WideWorldImporters].[Application].[Cities] CT
	ON C.DeliveryCityID = CT.CityID
INNER JOIN [WideWorldImporters].[Application].[StateProvinces] SP
	ON CT.StateProvinceID = SP.StateProvinceID
INNER JOIN [WideWorldImporters].[Application].[Countries] CO
	ON SP.CountryID = Co.CountryID


SELECT 
	InvoiceDate AS CalendarDate, 
	DATEPART(WEEKDAY, InvoiceDate) AS dayOfWeekNum,
	DATENAME(WEEKDAY, DATEPART(WEEKDAY, InvoiceDate)) AS dayOfWeekName,
	DATEPART(DAY, InvoiceDate) AS dayOfCalendarMonthNum,
	DATEPART(DAYOFYEAR, InvoiceDate) AS dayOfCalendarYearNum,
	DATEPART(WEEK, InvoiceDate) AS CalendarWeekNum,
	DATEPART(MONTH, InvoiceDate) AS calendarMonthNum
FROM 
	[WideWorldImporters].[Sales].[Invoices]
