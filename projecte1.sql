
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
 UnitPriceOfProduct VARCHAR(255),
 UnitsInStockOfProduct INTEGER,
 ProductReorderLevel INTEGER,
 DiscontinuedProduct BOOLEAN,
 ID_Category INTEGER UNIQUE,
 PRIMARY KEY (ID_Product),
 FOREIGN KEY (ID_Category) REFERENCES Category(ID_Category)
);
INSERT INTO Product (UnitPriceOfProduct, UnitsInStockOfProduct, ProductReorderLevel, DiscontinuedProduct)
SELECT UnitPriceOfProduct, UnitsInStockOfProduct, ProductReorderLevel, DiscontinuedProduct
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
 ID_Country SERIAL,
 Country VARCHAR(255),
 PRIMARY KEY (ID_Country)
);
INSERT INTO Country (Country)
SELECT DISTINCT Country
FROM EmployeesSales;

DROP TABLE IF EXISTS Territory CASCADE;
CREATE TABLE Territory(
 TerritoryID SERIAL,
 TerritoryDescription VARCHAR(255),
 ID_Country INTEGER,
 PRIMARY KEY (TerritoryID),
 FOREIGN KEY (ID_Country) REFERENCES Country(ID_Country)
);
INSERT INTO Territory (TerritoryDescription, ID_Country)
SELECT DISTINCT TerritoryDescription, c.ID_Country
FROM EmployeesSales AS e, Country AS c
WHERE e.Country = c.Country;

SELECT * FROM Country;
SELECT * FROM Territory;

DROP TABLE IF EXISTS Region CASCADE;
CREATE TABLE Region(
 RegionID SERIAL,
 RegionDescription VARCHAR(255),
 Region VARCHAR(255),
 TerritoryID INTEGER,
 PRIMARY KEY(RegionID),
 FOREIGN KEY (TerritoryID) REFERENCES Territory (TerritoryID)
);
INSERT INTO Region (RegionDescription, Region, TerritoryID)
SELECT DISTINCT e.RegionDescription, e.Region, t.TerritoryID
FROM EmployeesSales AS e, Territory AS t
WHERE t.TerritoryDescription = e.TerritoryDescription;

SELECT * FROM Region;
SELECT DISTINCT * FROM EmployeesSales;

DROP TABLE IF EXISTS City CASCADE;
CREATE TABLE City(
 ID_City SERIAL,
 City VARCHAR(255),
 RegionID INTEGER,
 PRIMARY KEY(ID_City),
 FOREIGN KEY (RegionID) REFERENCES Region(RegionID)
);
INSERT INTO City (City, RegionID)
SELECT DISTINCT City, RegionID
FROM EmployeesSales;

SELECT * FROM City;

DROP TABLE IF EXISTS Address CASCADE;
CREATE TABLE Address(
 ID_Address SERIAL,
 ID_Country INTEGER,
 ID_Region INTEGER,
 ID_City INTEGER,
 Address VARCHAR(255),
 PostalCode VARCHAR(255),
 PRIMARY KEY (ID_Address),
 FOREIGN KEY (ID_Country) REFERENCES Country(ID_Country),
 FOREIGN KEY (ID_Region) REFERENCES Region(RegionID),
 FOREIGN KEY (ID_City) REFERENCES City(ID_City)
);
INSERT INTO Address (Address, PostalCode)
SELECT Address, PostalCode
FROM CustomersOrders;


DROP TABLE IF EXISTS Employee CASCADE;
CREATE TABLE Employee(
 EmployeeID SERIAL,
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
 ID_Address INTEGER,
 ReportsTo INTEGER,
 TerritoryID INTEGER,
 PRIMARY KEY (EmployeeID),
 FOREIGN KEY (ID_Address) REFERENCES Address(ID_Address),
 FOREIGN KEY (ReportsTo) REFERENCES Employee(EmployeeID),
 FOREIGN KEY (TerritoryID) REFERENCES Territory(TerritoryID)
);
INSERT INTO Employee (Title, TitleOfCourtesy, HireDate, PhotoPath, FirstName, LastName, BirthDate, HomePhone, Extension, Photo, Notes)
SELECT Title, TitleOfCourtesy, HireDate, PhotoPath, FirstName, LastName, BirthDate, HomePhone, Extension, Photo, Notes
FROM EmployeesSales;

DROP TABLE IF EXISTS Company CASCADE;
CREATE TABLE Company(
 ID_Company SERIAL,
 CompanyName VARCHAR(255),
 ContactName VARCHAR(255),
 ContactSurname VARCHAR(255),
 ContactTitle VARCHAR(255),
 ID_Address INTEGER,
 PRIMARY KEY(ID_Company),
 FOREIGN KEY (ID_Address) REFERENCES Address(ID_Address)
);
INSERT INTO Company (CompanyName, ContactName, ContactSurname, ContactTitle)
SELECT CompanyName, split_part(ContactName,' ',1) AS ContactName, split_part(ContactName,' ',2) AS ContactSurname, ContactTitle
FROM CustomersOrders;

SELECT * FROM Company;


DROP TABLE IF EXISTS Supplier CASCADE;
CREATE TABLE Supplier(
 ID_Supplier SERIAL,
 SupplierHomePage VARCHAR(255),
 PRIMARY KEY (ID_Supplier),
 FOREIGN KEY (ID_Supplier) REFERENCES Company(ID_Company)
);
INSERT INTO Supplier (SupplierHomePage)
SELECT DISTINCT SupplierHomePage
FROM ProductsOrdered;

SELECT * FROM Supplier;

DROP TABLE IF EXISTS Phone CASCADE;
CREATE TABLE Phone(
 ID_Telefon SERIAL,
 Numero VARCHAR(255);
 ID_Shipper INTEGER,
 ID_Supplier INTEGER,
 ID_Customer INTEGER,
 PRIMARY KEY (ID_Telefon),
 FOREIGN KEY (ID_Shipper) REFERENCES Shipper(ID_Shipper),
 FOREIGN KEY (ID_Supplier) REFERENCES Company(ID_Company),
 FOREIGN KEY (ID_Customer) REFERENCES Company(ID_Company)
);
INSERT INTO Phone (Numero)
SELECT Numero
FROM ;

DROP TABLE IF EXISTS Order1 CASCADE;
CREATE TABLE Order1(
 ID_Order SERIAL,
 ID_Shipper INTEGER,
 EmployeeID INTEGER,
 ID_Product INTEGER,
 ID_Company INTEGER,
 OrderDate VARCHAR(255),
 RequiredDate VARCHAR(255),
 ShippedDate VARCHAR(255),
 OrderFreight REAL,
 OrderShipName VARCHAR(255),
 OrderQuantity INTEGER,
 OrderDiscount REAL,
 UnitsOnOrderOfProduct VARCHAR(255),
 ID_Address INTEGER,
 PRIMARY KEY (ID_Order, ID_Shipper, EmployeeID, ID_Product, ID_Company),
 FOREIGN KEY (ID_Shipper) REFERENCES Shipper(ID_Shipper),
 FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
 FOREIGN KEY (ID_Product) REFERENCES Product(ID_Product),
 FOREIGN KEY (ID_Address) REFERENCES Address(ID_Address)
);

INSERT INTO Order1 (OrderDate, RequiredDate, ShippedDate, OrderFreight, OrderShipName, OrderQuantity, OrderDiscount, UnitsOnOrderOfProduct)
SELECT OrderDate, RequiredDate, ShippedDate, OrderFreight, OrderShipName, OrderQuantity, OrderDiscount, UnitsOnOrderOfProduct
FROM ProductsOrdered;

--QUERY PER ELIMINAR TOTES LES TAULES D'IMPORTACIÓ
DROP TABLE IF EXISTS CustomersOrders;
DROP TABLE IF EXISTS EmployeesSales;
DROP TABLE IF EXISTS ProductsOrdered;