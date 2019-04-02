
 DROP TABLE IF EXISTS CustomersOrders CASCADE;
 CREATE TABLE CustomersOrders(
  OrderDate VARCHAR(255),
  RequiredDate VARCHAR(255),
  ShippedDate VARCHAR(255),
  OrderFreight REAL,
  OrderShipName VARCHAR(255),
  OrderShipAddress VARCHAR(255),
  OrderShipCity VARCHAR(255),
  OrderShipRegion VARCHAR(255),
  OrderShipPostalCode VARCHAR(255),
  OrderShipCountry VARCHAR(255),
  CompanyName VARCHAR(255),
  ContactName VARCHAR(255),
  ContactTitle VARCHAR(255),
  Address VARCHAR(255),
  City VARCHAR(255),
  Region VARCHAR(255),
  PostalCode VARCHAR(255),
  Country VARCHAR(255),
  Phone VARCHAR(255),
  Phone2 VARCHAR(255)
 );

 DROP TABLE IF EXISTS EmployeesSales CASCADE;
 CREATE TABLE EmployeesSales(
  OrderDate VARCHAR(255),
  RequiredDate VARCHAR(255),
  ShippedDate VARCHAR(255),
  OrderFreight REAL,
  OrderShipName VARCHAR(255),
  OrderShipAddress VARCHAR(255),
  OrderShipCity VARCHAR(255),
  OrderShipRegion VARCHAR(255),
  OrderShipPostalCode VARCHAR(255),
  OrderShipCountry VARCHAR(255),
  EmployeeID INTEGER,
  LastName VARCHAR(255),
  FirstName VARCHAR(255),
  Title VARCHAR(255),
  TitleOfCourtesy VARCHAR(255),
  BirthDate VARCHAR(255),
  HireDate VARCHAR(255),
  Address VARCHAR(255),
  City VARCHAR(255),
  Region VARCHAR(255),
  PostalCode VARCHAR(255),
  Country VARCHAR(255),
  HomePhone VARCHAR(255),
  Extension VARCHAR(255),
  Photo VARCHAR(255),
  Notes TEXT,
  ReportsTo INTEGER,
  PhotoPath VARCHAR(255),
  EmployeeID2 INTEGER,
  TerritoryID INTEGER,
  TerritoryID2 INTEGER,
  TerritoryDescription VARCHAR(255),
  RegionID INTEGER,
  RegionID2 INTEGER,
  RegionDescription VARCHAR(255)
 );

 DROP TABLE IF EXISTS ProductsOrdered CASCADE;
 CREATE TABLE ProductsOrdered(
  OrderDate VARCHAR(255),
  RequiredDate VARCHAR(255),
  ShippedDate VARCHAR(255),
  OrderFreight REAL,
  OrderShipName VARCHAR(255),
  OrderShipAddress VARCHAR(255),
  OrderShipCity VARCHAR(255),
  OrderShipRegion VARCHAR(255),
  OrderShipPostalCode VARCHAR(255),
  OrderShipCountry VARCHAR(255),
  OrderUnitPrice REAL,
  OrderQuantity INTEGER,
  OrderDiscount REAL,
  shippercompanyname VARCHAR(255),
  ShipperPhone VARCHAR(255),
  ProductName VARCHAR(255),
  QuantityPerUnitOfProduct VARCHAR(255),
  UnitPriceOfProduct VARCHAR(255),
  UnitsInStockOfProduct INTEGER,
  UnitsOnOrderOfProduct VARCHAR(255),
  ProductReorderLevel INTEGER,
  DiscontinuedProduct BOOLEAN,
  SupplierCompanyName VARCHAR(255),
  SupplierContactName VARCHAR(255),
  SupplierContactTitle VARCHAR(255),
  SupplierAddress VARCHAR(255),
  SupplierCity VARCHAR(255),
  SupplierRegion VARCHAR(255),
  supplierpostalcode VARCHAR(255),
  SupplierCountry VARCHAR(255),
  SupplierPhone VARCHAR(255),
  SupplierPhone2 VARCHAR(255),
  SupplierHomePage VARCHAR(255),
  CategoryName VARCHAR(255),
  CategoryDescription TEXT,
  CategoryPicture VARCHAR(255)
 );


 --QUERY PER IMPORTAR LES DADES A LES SEVES TAULES RESPECTIVES
 COPY CustomersOrders FROM 'C:\Users\Public\CustomersOrders.csv' DELIMITER ',' CSV HEADER;
 COPY EmployeesSales FROM 'C:\Users\Public\EmployeesSales.csv' DELIMITER ',' CSV HEADER;
 COPY ProductsOrdered FROM 'C:\Users\Public\ProductsOrdered.csv' DELIMITER ',' CSV HEADER;

 --QUERY PER ELIMINAR ELS ATRIBUTS REPETITS
 ALTER TABLE EmployeesSales
 DROP COLUMN EmployeeID2,
 DROP COLUMN TerritoryID2,
 DROP COLUMN RegionID2;


SELECT * FROM EmployeesSales;

--CREACIÓ DE LA BASE DE DADES, NORMALITZACIÓ I DISTRIBUCIÓ DE DADES
DROP TABLE IF EXISTS Category CASCADE;
CREATE TABLE Category(
 ID_Category SERIAL UNIQUE,
 CategoryName VARCHAR(255),
 CategoryDescription VARCHAR(255),
 CategoryPicture VARCHAR(255),
 PRIMARY KEY (ID_Category)
);
INSERT INTO Category (CategoryName, CategoryDescription, CategoryPicture)
SELECT DISTINCT CategoryName, CategoryDescription, CategoryPicture
FROM ProductsOrdered;

SELECT * FROM Category;

DROP TABLE IF EXISTS Product CASCADE;
CREATE TABLE Product(
 ID_Product SERIAL,
 ProductName VARCHAR(255),
 UnitPriceOfProduct VARCHAR(255),
 UnitsInStockOfProduct INTEGER,
 ProductReorderLevel INTEGER,
 DiscontinuedProduct BOOLEAN,
 ID_Category INTEGER UNIQUE,
 PRIMARY KEY (ID_Product),
 FOREIGN KEY (ID_Category) REFERENCES Category(ID_Category)
);
INSERT INTO Product (ProductName, UnitPriceOfProduct, UnitsInStockOfProduct, ProductReorderLevel, DiscontinuedProduct)
SELECT DISTINCT ProductName, UnitPriceOfProduct, UnitsInStockOfProduct, ProductReorderLevel, DiscontinuedProduct
FROM ProductsOrdered;


SELECT * FROM Product;

DROP TABLE IF EXISTS Shipper CASCADE;
CREATE TABLE Shipper(
 ID_Shipper SERIAL,
 ShipperCompanyName VARCHAR(255),
 PRIMARY KEY (ID_Shipper)
);
INSERT INTO Shipper (ShipperCompanyName)
SELECT DISTINCT ShipperCompanyName
FROM ProductsOrdered;

SELECT * FROM Shipper;


DROP TABLE IF EXISTS Country CASCADE;
CREATE TABLE Country(
 ID_Country Serial,
 Country VARCHAR(255),
 PRIMARY KEY (ID_Country)
);
INSERT INTO Country (Country)
    (SELECT DISTINCT Country
      FROM EmployeesSales)
      UNION
    (SELECT DISTINCT OrderShipCountry
    FROM EmployeesSales)
 UNION
    (SELECT DISTINCT Country FROM CustomersOrders)
 UNION
    (SELECT DISTINCT SupplierCountry FROM ProductsOrdered);

DROP TABLE IF EXISTS Region CASCADE;
CREATE TABLE Region(
 RegionID SERIAL,
 Region VARCHAR(255),
 ID_Country INTEGER,
 PRIMARY KEY(RegionID),
 FOREIGN KEY (ID_Country) REFERENCES Country (ID_Country)
);

INSERT INTO Region ( Region, ID_Country)
    (SELECT DISTINCT e.Region, c.ID_Country
FROM EmployeesSales AS e, Country AS c
WHERE c.Country = e.Country AND e.Region IS NOT NULL)
 UNION
    (SELECT DISTINCT CO.OrderShipRegion, ID_Country
    FROM CustomersOrders AS CO, Country AS c
    WHERE c.Country = CO.OrderShipCountry AND CO.OrderShipRegion IS NOT NULL)
 UNION
    (SELECT DISTINCT CO.region, ID_Country
    FROM CustomersOrders AS CO, Country AS c
    WHERE c.Country = CO.Country AND CO.Region IS NOT NULL)
 UNION
    (SELECT DISTINCT p.SupplierRegion, ID_Country
    FROM ProductsOrdered AS p, Country AS c
    WHERE p.SupplierCountry = c.Country AND p.SupplierRegion IS NOT NULL);

 SELECT * FROM Country;
 SELECT * FROM Region;

SELECT DISTINCT region FROM EmployeesSales;

 DROP TABLE IF EXISTS RegionDescription CASCADE;
 CREATE TABLE RegionDescription(
  RegionID INTEGER,
  RegionDescription VARCHAR(255),
  FOREIGN KEY (RegionID) REFERENCES Region(RegionID)
 );

 INSERT INTO RegionDescription(RegionID, RegionDescription)
     (SELECT DISTINCT r.RegionID, e.RegionDescription FROM Region AS r, EmployeesSales AS e WHERE r.Region = e.Region AND e.Region IS NOT NULL);

 SELECT * FROM Region WHERE RegionID = 23;
 SELECT * FROM RegionDescription;
 SELECT DISTINCT * FROM EmployeesSales WHERE Region LIKE '%WA%';

DROP TABLE IF EXISTS Territory CASCADE;
CREATE TABLE Territory(
 TerritoryID SERIAL,
 TerritoryDescription VARCHAR(255),
 RegionID INTEGER,
 PRIMARY KEY (TerritoryID),
 FOREIGN KEY (RegionID) REFERENCES Region (RegionID)
);
INSERT INTO Territory (TerritoryDescription, RegionID)
SELECT DISTINCT TerritoryDescription, r.RegionID
FROM EmployeesSales AS e, Region AS r
WHERE r.Region = e.Region;

SELECT * FROM Country;
SELECT * FROM Territory;

SELECT * FROM Region;

DROP TABLE IF EXISTS City CASCADE;
CREATE TABLE City(
 ID_City SERIAL,
 City VARCHAR(255),
 RegionID INTEGER,
 PRIMARY KEY(ID_City),
 FOREIGN KEY (RegionID) REFERENCES Region(RegionID)
);
INSERT INTO City (City, RegionID)
    (SELECT DISTINCT e.OrderShipCity, r.RegionID
    FROM EmployeesSales AS e, Region AS r
    WHERE e.OrderShipRegion = r.Region)
 UNION
    (SELECT DISTINCT CO.OrderShipCity, r.RegionID
    FROM CustomersOrders AS CO, Region AS r
    WHERE r.Region = CO.OrderShipRegion AND CO.OrderShipCity IS NOT NULL)
 UNION
    (SELECT DISTINCT CO.City, r.RegionID
    FROM CustomersOrders AS CO, Region AS r
    WHERE r.Region = CO.Region AND CO.City IS NOT NULL)
 UNION
    (SELECT DISTINCT p.SupplierCity, r.RegionID
    FROM ProductsOrdered AS p, Region AS r
    WHERE p.SupplierRegion = r.Region AND p.SupplierCity IS NOT NULL);


SELECT * FROM City;

DROP TABLE IF EXISTS Address CASCADE;
CREATE TABLE Address(
 ID_Address SERIAL,
 ID_Country INTEGER,
 ID_Region INTEGER,
 ID_City INTEGER,
 AddressName VARCHAR(255),
 PostalCode VARCHAR(255),
 PRIMARY KEY (ID_Address),
 FOREIGN KEY (ID_Country) REFERENCES Country(ID_Country),
 FOREIGN KEY (ID_Region) REFERENCES Region(RegionID),
 FOREIGN KEY (ID_City) REFERENCES City(ID_City)
);
INSERT INTO Address (AddressName, PostalCode, ID_Country, ID_Region, ID_City)
SELECT DISTINCT co.Address, co.PostalCode, c.ID_Country, r.RegionID, cy.ID_City
FROM CustomersOrders AS co, Country AS c, Region AS r, City AS cy
WHERE cy.City = co.City AND c.Country = co.Country AND r.Region = co.Region;

 INSERT INTO Address (AddressName, PostalCode, ID_Country, ID_Region, ID_City)
 SELECT DISTINCT es.Address, es.PostalCode, c.ID_Country, r.RegionID, cy.ID_City
 FROM EmployeesSales AS es, Country AS c, Region AS r, City AS cy
 WHERE es.City = cy.City AND c.Country = es.Country AND r.Region = es.RegionDescription;


 --NOT EXISTS(SELECT DISTINCT co.Address, co.PostalCode, c.ID_Country, r.RegionID, cy.ID_City FROM CustomersOrders AS co, Country AS c, Region AS r, City AS cy WHERE cy.City = co.City AND c.Country = co.Country AND r.Region = co.Region);
 SELECT * FROM Address;
 SELECT * FROM EmployeesSales;

DROP TABLE IF EXISTS Employee CASCADE;
CREATE TABLE Employee(
 ID_SERIAL SERIAL,
 EmployeeID INTEGER,
 Title VARCHAR(255),
 TitleOfCourtesy VARCHAR(255),
 HireDate VARCHAR(255),
 PhotoPath VARCHAR(255),
 FirstName VARCHAR(255),
 LastName VARCHAR(255),
 BirthDate VARCHAR(255),
 HomePhone VARCHAR(255),
 Extension VARCHAR(255),
 Photo VARCHAR(255),
 Notes TEXT,
 ReportsTo INTEGER,
 Address VARCHAR(255),
 PRIMARY KEY (EmployeeID),
 FOREIGN KEY (ReportsTo) REFERENCES Employee(EmployeeID)
);
INSERT INTO Employee (EmployeeID, Title, TitleOfCourtesy, HireDate, PhotoPath, FirstName, LastName, BirthDate, HomePhone, Extension, Photo, Notes, ReportsTo, Address)
SELECT DISTINCT es.EmployeeID, es.Title, es.TitleOfCourtesy, es.HireDate, es.PhotoPath, es.FirstName, es.LastName, es.BirthDate, es.HomePhone, es.Extension, es.Photo, es.Notes, ReportsTo, a.AddressName
FROM EmployeesSales AS es, Address AS a
WHERE es.Address = a.AddressName;
--WHERE es.TerritoryID = t.TerritoryID; --AND a.ID_City = c.ID_City AND c.City = es.City;

SELECT * FROM Employee;
SELECT Address FROM EmployeesSales;
 SELECT * FROM Address;
SELECT Address FROM  CustomersOrders;
 SELECT ID_City FROM City;



DROP TABLE IF EXISTS Company CASCADE;
CREATE TABLE Company(
 ID_Company SERIAL,
 CompanyName VARCHAR(255),
 ContactName VARCHAR(255),
 ContactSurname VARCHAR(255),
 ContactTitle VARCHAR(255),
 PRIMARY KEY(ID_Company)
);
INSERT INTO Company (CompanyName, ContactName, ContactSurname, ContactTitle)
SELECT DISTINCT CompanyName, split_part(ContactName,' ',1) AS ContactName, split_part(ContactName,' ',2) AS ContactSurname, ContactTitle
FROM CustomersOrders AS co;

INSERT INTO Company (CompanyName, ContactName, ContactSurname)
SELECT DISTINCT po.SupplierCompanyName, split_part(SupplierContactName,' ',1) AS ContactName, split_part(SupplierContactName,' ',2) AS ContactSurname
FROM ProductsOrdered AS po;
    --po.OrderShipAddress = a.Address;

SELECT DISTINCT * FROM Company;
SELECT DISTINCT SupplierContactName, SupplierCompanyName FROM ProductsOrdered;

SELECT CompanyName, split_part(ContactName,' ',1) AS ContactName, split_part(ContactName,' ',2) AS ContactSurname, ContactTitle, ID_Address
FROM CustomersOrders AS co, Address AS a;

DROP TABLE IF EXISTS Supplier CASCADE;
CREATE TABLE Supplier(
 ID_Supplier Integer,
 SupplierHomePage VARCHAR(255),
 PRIMARY KEY (ID_Supplier),
 FOREIGN KEY (ID_Supplier) REFERENCES Company(ID_Company)
);
INSERT INTO Supplier (ID_Supplier, SupplierHomePage)
SELECT DISTINCT c.ID_Company AS ID_Supplier, SupplierHomePage
FROM ProductsOrdered AS po, Company AS c
WHERE c.CompanyName = po.SupplierCompanyName;

SELECT * FROM Supplier;

SELECT DISTINCT SupplierHomePage FROM ProductsOrdered;

DROP TABLE IF EXISTS Phone CASCADE;
CREATE TABLE Phone(
 ID_Telefon SERIAL,
 Numero VARCHAR(255),
 Numero2 VARCHAR(255),
 ID_Shipper INTEGER,
 ID_Supplier INTEGER,
 ID_Customer INTEGER,
 PRIMARY KEY (ID_Telefon),
 FOREIGN KEY (ID_Shipper) REFERENCES Shipper(ID_Shipper),
 FOREIGN KEY (ID_Supplier) REFERENCES Company(ID_Company),
 FOREIGN KEY (ID_Customer) REFERENCES Company(ID_Company)
);
INSERT INTO Phone (Numero, Numero2, ID_Customer)
SELECT DISTINCT Phone AS Numero, Phone2 AS Numero2, c.ID_Company AS ID_Customer
FROM Company AS c, CustomersOrders AS co, Supplier AS s
WHERE c.CompanyName = co.CompanyName AND c.ID_Company <> s.ID_Supplier;

INSERT INTO Phone (Numero, Numero2, ID_Supplier, ID_Customer)
SELECT DISTINCT po.SupplierPhone, po.SupplierPhone2, s.ID_Supplier, c.ID_Company
FROM Company AS c, ProductsOrdered AS po, Supplier AS s
WHERE c.ID_Company = s.ID_Supplier AND c.CompanyName = po.SupplierCompanyName;

INSERT INTO Phone (Numero, Numero2, ID_Shipper)
SELECT DISTINCT SupplierPhone AS Numero, SupplierPhone2 AS Numero2, sh.ID_Shipper AS ID_Shipper
FROM Shipper AS sh, ProductsOrdered AS po
WHERE sh.ShipperCompanyName = po.shippercompanyname;

SELECT * FROM Phone;
SELECT * FROM ProductsOrdered;

DROP TABLE IF EXISTS Order1 CASCADE;
CREATE TABLE Order1
(
 ID_Order   SERIAL,
 ID_Shipper INTEGER,
 EmployeeID INTEGER,
 ID_Product INTEGER,
 OrderDate  VARCHAR(255),
 RequiredDate VARCHAR(255),
 ShippedDate VARCHAR(255),
 OrderFreight REAL,
 OrderShipName VARCHAR(255),
 OrderQuantity INTEGER,
 OrderDiscount REAL,
 UnitsOnOrderOfProduct VARCHAR(255),
 AddressName VARCHAR(255),
 PRIMARY KEY (ID_Order),
 FOREIGN KEY (ID_Shipper) REFERENCES Shipper(ID_Shipper),
 FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
 FOREIGN KEY (ID_Product) REFERENCES Product(ID_Product)

);

INSERT INTO Order1 (ID_Shipper, EmployeeID, ID_Product, OrderDate, RequiredDate, ShippedDate, OrderFreight,  OrderShipName, OrderQuantity, OrderDiscount, UnitsOnOrderOfProduct, AddressName)
SELECT DISTINCT sh.ID_Shipper, emp.EmployeeID, p.ID_Product, po.OrderDate, po.RequiredDate, po.ShippedDate, po.OrderFreight, po.OrderShipName, po.OrderQuantity, po.OrderQuantity, po.UnitsOnOrderOfProduct, a.AddressName
FROM Shipper AS sh, Employee AS emp, Product AS p, ProductsOrdered AS po, Address AS a, EmployeesSales AS es
WHERE  po.shippercompanyname = sh.ShipperCompanyName AND es.FirstName = emp.FirstName AND es.LastName = emp.LastName AND po.ProductName = p.ProductName AND po.OrderShipAddress = a.AddressName AND es.EmployeeID = emp.EmployeeID;
--a.Address = po.OrderShipAddress AND
SELECT * FROM Product;
SELECT * FROM Shipper;
SELECT * FROM Order1;
SELECT HomePhone FROM Employee;
SELECT SupplierPhone, SupplierPhone2 FROM ProductsOrdered;
SELECT * FROM EmployeesSales;
SELECT * FROM Employee;
select * FROM Company;
--INSERT INTO Order1 (ID_Order, ID_Shipper, EmployeeID, ID_Product, ID_Company, OrderDate, RequiredDate, ShippedDate, OrderFreight,  OrderShipName, OrderQuantity, OrderDiscount, UnitsOnOrderOfProduct, ID_Address)
--SELECT o.ID_Order, sh.ID_Shipper, e.EmployeeID, p.ID_Product, comp.ID_Company,co.OrderDate, co.RequiredDate, co.ShippedDate, co.OrderFreight, co.OrderShipName, po.OrderQuantity, po.OrderDiscount, po.UnitsOnOrderOfProduct, a.ID_Address
--FROM CustomersOrders AS co, ProductsOrdered AS po, EmployeesSales AS es, Address AS a, Order1 AS o, Shipper as sh, Employee AS e, Product AS p, Company AS comp
--WHERE a.Address = po.OrderShipAddress;
SELECT * FROM CustomersOrders;
SELECT * FROM ProductsOrdered;
SELECT * FROM EmployeesSales;


--INSERT INTO Order1 (ID_Shipper, EmployeeID, ID_Product, ID_Company, OrderDate, RequiredDate, ShippedDate, OrderFreight,  OrderShipName, OrderQuantity)
--SELECT sh.ID_Shipper, emp.EmployeeID, p.ID_Product, comp.ID_Company, po.OrderDate, po.RequiredDate, po.ShippedDate, po.OrderFreight, po.OrderShipName, po.OrderQuantity
--FROM Shipper AS sh, Employee AS emp, Product AS p, Company AS comp, ProductsOrdered AS po, Address AS a
--WHERE a.Address = po.OrderShipAddress ;



