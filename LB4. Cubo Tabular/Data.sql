/*-------------CREACIÓN DE BASE----------*/
USE ModeloDWH

/*------------------DIMENSIONES-------------------*/
		/*-------------CLIENTES----------*/
INSERT INTO [dbo].[Clientes](
	[CustomerID],
	[BuyingGroupName],
	[CityName],
	[StateProvinceCode],
	[StateProvinceName],
	[CountryName],
	[CreditLimit])
SELECT DISTINCT CUS.CustomerID, BG.BuyingGroupName, CITIES.CityName, Provinces.StateProvinceCode, Provinces.StateProvinceName, COUNTRY.CountryName, CUS.CreditLimit
FROM WideWorldImporters.Sales.Customers as CUS 
inner join WideWorldImporters.sales.BuyingGroups as BG on (CUS.BuyingGroupID = BG.BuyingGroupID)
INNER JOIN WideWorldImporters.Application.Cities as CITIES on(CITIES.CityID = CUS.DeliveryCityID)
INNER JOIN WideWorldImporters.Application.StateProvinces as PROVINCES on(CITIES.StateProvinceID = Provinces.StateProvinceID)
INNER JOIN WideWorldImporters.Application.Countries as COUNTRY on (Provinces.CountryID = COUNTRY.CountryID)
GO

		/*-------------FECHAS----------*/
INSERT INTO 
[dbo].[Fecha](
	[CalendarDate],
	[dayOfCalendarMonthNum],
	[CalendarWeekNum],
	[dayOfWeekNum],
	[dayOfCalendarYearNum],
	[calendarMonthNum],
	[calendarYearNum],
	[calendarQuerterNum],
	[dayOfWeekName],
	[calendarMonthName]
)
SELECT DISTINCT InvoiceDate as CalendarDate, 
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
GO

		/*----------StockItem----------*/
INSERt INTO [dbo].[StockItem](
	[StockItemID],
	[StockItemName],
	[SupplierName],
	[ColorName],
	[UnitPackageTypeName],
	[OuterPackageTypeName],
	[Brand],
	[Size],
	[LeadTimeDays],
	[TaxRate],
	[UnitPrice],
	[RecommendedRetailPrice],
	[TypicalWeightPerUnit],
	[Photo]
)
SELECT DISTINCT SI.StockItemID, SI.StockItemName, suppliers.SupplierName, color.ColorName, TP.PackageTypeName AS UnitPackageTypeName, PT.PackageTypeName AS OuterPackageTypeName, SI.Brand, SI.Size, SI.LeadTimeDays, SI.TaxRate, SI.UnitPrice, SI.RecommendedRetailPrice, si.TypicalWeightPerUnit, SI.Photo
FROM  WideWorldImporters.Warehouse.StockItems as SI 
INNER JOIN WideWorldImporters.Purchasing.Suppliers as suppliers on (SI.SupplierID = suppliers.SupplierID)
INNER JOIN WideWorldImporters.Warehouse.Colors as color on (color.ColorID = SI.ColorID)
INNER JOIN WideWorldImporters.Warehouse.PackageTypes as TP on (TP.PackageTypeID = SI.UnitPackageID)
INNER JOIN WideWorldImporters.Warehouse.PackageTypes as PT on(PT.PackageTypeID =  SI.OuterPackageID)
GO

/*------------------TABLA DE HECHOS-------------------*/
			/*----------Invoices----------*/

INSERT INTO dbo.Invoices (
	[InvoiceID],
	[CustomerID],
	[InvoiceDate],
	[StockItemID],
	[Quantity],
	[UnitPrice],
	[TaxRate],
	[TaxAmount],
	[LineProfit],
	[ExtendedPrice],
	[CreatedDate]
)
SELECT  DISTINCT
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
		inner join ModeloDWH.dbo.Clientes C ON ins.CustomerID = C.CustomerID
		inner join ModeloDWH.dbo.Fecha F ON F.CalendarDate = ins.InvoiceDate
		inner join ModeloDWH.dbo.StockItem S ON S.StockItemID = insL.StockItemID 