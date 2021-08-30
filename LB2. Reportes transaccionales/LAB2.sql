-- LABORATORIO 2

-- a.	Ventas por Cliente
--	i.	Columnas: Nombre cliente, región, total de $ de venta

SELECT c.CompanyName,  c.Region, SUM(ExtendedPrice) AS Total
FROM [Customers] c
INNER JOIN [Orders] o ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details Extended] d ON d.OrderID = o.OrderID
GROUP BY c.CompanyName,  c.Region;

-- b.	Ventas por Producto
--	i.	Columnas: Nombre de producto, Región, total de productos ordenados

SELECT p.ProductName, o.ShipRegion, SUM(d.Quantity) AS Qty
FROM [Products] p
INNER JOIN [Order Details Extended] d ON d.ProductID = p.ProductID
INNER JOIN [Orders] o ON o.OrderID = d.OrderID
GROUP BY p.ProductName, o.ShipRegion;

-- c.	Listado de clientes que compraron en el 1996 y no compraron en el 1997
--	i.	Columnas: Nombre de cliente, ultima fecha de compra y últimos productos adquiridos

PRINT CURRENT_TIMESTAMP;
SELECT DISTINCT 
c.CompanyName, cc.MostRecentDate, STUFF(
         (SELECT DISTINCT ',' + pp.ProductName
          FROM Products pp
		  INNER JOIN [Order Details Extended] pd ON pd.ProductID = pp.ProductID
          INNER JOIN [Orders] po ON po.OrderID = pd.OrderID
		  INNER JOIN [Customers] pc ON po.CustomerID = pc.CustomerID
          WHERE c.CompanyName = pc.CompanyName AND cc.MostRecentDate = po.OrderDate
          FOR XML PATH (''))
          , 1, 1, '')  AS Products
FROM [Orders] o
INNER JOIN [Customers] c 
	ON c.CustomerID = o.CustomerID
INNER JOIN 
(
	SELECT CustomerID, MAX(OrderDate) As MostRecentDate
	FROM Orders
	GROUP BY CustomerID
) cc
	ON cc.CustomerID = o.CustomerID
INNER JOIN [Order Details] d ON d.OrderID = o.OrderID
WHERE YEAR(o.OrderDate) = 1996
AND c.CustomerID NOT IN
(
	SELECT CustomerID 
	FROM [Orders]
	WHERE YEAR(OrderDate) = 1997
)
GROUP BY c.CompanyName, cc.MostRecentDate;

-- d.	Listado de los 5 productos más vendidos
--	i.	Columnas: Nombre de la ciudad, cantidad de ordenes, cantidad total de ventas

SELECT  TOP 5 p.ProductName, o.ShipCity, COUNT(*) AS QtyOrders, SUM( ExtendedPrice) AS Total
FROM Products p
INNER JOIN [Order Details Extended] ode ON p.ProductID=ode.ProductID
INNER JOIN Orders o ON ode.OrderID=o.OrderID
GROUP BY p.ProductName, o.ShipCity
ORDER BY QtyOrders DESC

-- e.	Listado de los 5 mejores vendedores

--mejores vendedores por cantidad de ventas
select top 5 o.EmployeeID, e.FirstName, e.LastName, count(o.EmployeeID) as [Canitdad ventas]
from Employees e
inner join Orders o on e.EmployeeID = o.EmployeeID
group by o.EmployeeID, e.FirstName, e.LastName
order by [Canitdad ventas] desc

--mejores vendedores por total de ventas
select top 5 o.EmployeeID, e.FirstName, e.LastName, sum(ode.ExtendedPrice) as [Total Venta]
from Employees e
inner join Orders o on e.EmployeeID = o.EmployeeID
inner join [Order Details Extended] ode on o.OrderID = ode.OrderID
group by o.EmployeeID, e.FirstName, e.LastName
order by [Total Venta] desc