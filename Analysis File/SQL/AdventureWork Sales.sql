--1)---------------------------------------------Product Analysis---------------------------------------------------

--Totals Revenue Of Products
SELECT
	P.Name as ProductName ,sum(SA.LineTotal) as TotalSales 
From
	Production.Product as P join Sales.SalesOrderDetail as SA on P.ProductID = SA.ProductID
group by
	P.Name
Order By
	TotalSales Desc;

--Most Product Sales
SELECT 
    P.Name AS ProductName,
    SUM(SOD.OrderQty) AS TotalUnitsSold,
    SUM(SOD.LineTotal) AS TotalRevenue
FROM Sales.SalesOrderDetail AS SOD JOIN Production.Product AS P ON SOD.ProductID = P.ProductID
GROUP BY P.Name
ORDER BY TotalUnitsSold DESC;

--Category & Subcategory Revenue
SELECT 
    PC.Name AS CategoryName,
    PSC.Name AS SubCategoryName,
    P.Name AS ProductName,
    SUM(SOD.LineTotal) AS TotalRevenue
FROM 
    Sales.SalesOrderDetail AS SOD
    JOIN Production.Product AS P ON SOD.ProductID = P.ProductID
    JOIN Production.ProductSubcategory AS PSC ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
    JOIN Production.ProductCategory AS PC ON PSC.ProductCategoryID = PC.ProductCategoryID
GROUP BY 
    PC.Name, PSC.Name, P.Name
ORDER BY 
    PC.Name, PSC.Name, TotalRevenue DESC

--Price & Discount Rate
SELECT 
    P.Name AS ProductName,
    AVG(SOD.UnitPrice) AS AvgUnitPrice,
    AVG(SOD.UnitPriceDiscount)*100 AS AvgDiscount
FROM 
    Sales.SalesOrderDetail AS SOD
    JOIN Production.Product AS P ON SOD.ProductID = P.ProductID
GROUP BY 
    P.Name
ORDER BY 
    AvgUnitPrice DESC;

--Offers
SELECT 
    P.Name AS ProductName,
    SO.Description AS OfferDescription,
    SUM(SOD.LineTotal) AS TotalRevenue
FROM 
    Sales.SalesOrderDetail AS SOD
    JOIN Production.Product AS P ON SOD.ProductID = P.ProductID
    JOIN Sales.SpecialOfferProduct AS SOP ON P.ProductID = SOP.ProductID
    JOIN Sales.SpecialOffer AS SO ON SOP.SpecialOfferID = SO.SpecialOfferID
GROUP BY 
    P.Name, SO.Description
ORDER BY 
    TotalRevenue DESC;

--Sales Per Time
SELECT 
    P.Name AS ProductName,
    FORMAT(SOH.OrderDate, 'MM-yyyy') AS OrderMonth,
    SUM(SOD.OrderQty) AS TotalUnitsSold
FROM 
    Sales.SalesOrderDetail AS SOD
    JOIN Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID = SOH.SalesOrderID
    JOIN Production.Product AS P ON SOD.ProductID = P.ProductID
GROUP BY 
    P.Name, FORMAT(SOH.OrderDate, 'MM-yyyy')
ORDER BY 
    ProductName;

--AVG Days To ship
SELECT 
    SM.Name AS ShipMethod,
    AVG(DATEDIFF(DAY, SOH.OrderDate, SOH.ShipDate)) AS AvgDaysToShip,
    COUNT(SOH.SalesOrderID) AS OrderCount
FROM 
    Sales.SalesOrderHeader AS SOH
    JOIN Purchasing.ShipMethod AS SM ON SOH.ShipMethodID = SM.ShipMethodID
GROUP BY 
    SM.Name
ORDER BY 
    AvgDaysToShip;

--Sales By Region
SELECT 
    ST.Name AS SalesTerritory,
    SUM(SOD.LineTotal) AS TotalSales
FROM 
    Sales.SalesOrderHeader AS SOH
    JOIN Sales.SalesOrderDetail AS SOD ON SOH.SalesOrderID = SOD.SalesOrderID
    JOIN Sales.SalesTerritory AS ST ON SOH.TerritoryID = ST.TerritoryID
GROUP BY 
    ST.Name
ORDER BY 
    TotalSales DESC;

---------------------------------------------------------------2) Customer Analysis----------------------------------------------------------------
--Total Customers Spent
SELECT 
    C.CustomerID,
    SUM(SOD.LineTotal) AS TotalSpent
FROM 
    Sales.Customer AS C
    JOIN Sales.SalesOrderHeader AS SOH ON C.CustomerID = SOH.CustomerID
    JOIN Sales.SalesOrderDetail AS SOD ON SOH.SalesOrderID = SOD.SalesOrderID
GROUP BY 
    C.CustomerID
ORDER BY 
    TotalSpent DESC;

--Retention Rate
SELECT 
    CASE 
        WHEN OrderCount = 1 THEN 'One-time Buyer'
        ELSE 'Repeat Buyer'
    END AS CustomerType,
    COUNT(*) AS NumberOfCustomers
FROM 
(
    SELECT 
        CustomerID,
        COUNT(*) AS OrderCount
    FROM 
        Sales.SalesOrderHeader
    GROUP BY 
        CustomerID
) AS OrdersPerCustomer
GROUP BY 
    CASE 
        WHEN OrderCount = 1 THEN 'One-time Buyer'
        ELSE 'Repeat Buyer'
    END;

--Customers By Region
SELECT 
    ST.Name AS TerritoryName,
    COUNT(DISTINCT C.CustomerID) AS CustomerCount
FROM 
    Sales.Customer AS C
    JOIN Sales.SalesTerritory AS ST ON C.TerritoryID = ST.TerritoryID
GROUP BY 
    ST.Name
ORDER BY 
    CustomerCount DESC;

--Store OR Individual?
SELECT 
    CASE 
        WHEN StoreID IS NOT NULL THEN 'Store'
        ELSE 'Individual'
    END AS CustomerType,
    COUNT(*) AS CustomerCount
FROM 
    Sales.Customer
GROUP BY 
    CASE 
        WHEN StoreID IS NOT NULL THEN 'Store'
        ELSE 'Individual'
    END;


--Number of Orders & Total Sales by Customer
SELECT 
    C.CustomerID,
    COUNT(DISTINCT SOH.SalesOrderID) AS OrderCount,
    SUM(SOD.LineTotal) AS TotalSales,
    SUM(SOD.LineTotal) / COUNT(DISTINCT SOH.SalesOrderID) AS AvgOrderValue
FROM 
    Sales.Customer AS C
    JOIN Sales.SalesOrderHeader AS SOH ON C.CustomerID = SOH.CustomerID
    JOIN Sales.SalesOrderDetail AS SOD ON SOH.SalesOrderID = SOD.SalesOrderID
GROUP BY 
    C.CustomerID
ORDER BY 
    AvgOrderValue DESC;