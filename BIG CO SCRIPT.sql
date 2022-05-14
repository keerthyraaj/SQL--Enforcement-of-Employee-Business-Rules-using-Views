CREATE SCHEMA HR AUTHORIZATION dbo;
GO
CREATE SCHEMA Production AUTHORIZATION dbo;
GO
CREATE SCHEMA Sales AUTHORIZATION dbo;
GO

---------------------------------------------------------------------
-- Create Tables
---------------------------------------------------------------------

-- Create table HR.Employees
CREATE TABLE HR.Employees
(
  empid           INT          NOT NULL IDENTITY,
  lastname        NVARCHAR(20) NOT NULL,
  firstname       NVARCHAR(10) NOT NULL,
  title           NVARCHAR(30) NOT NULL,
  titleofcourtesy NVARCHAR(25) NOT NULL,
  birthdate       DATETIME     NOT NULL,
  hiredate        DATETIME     NOT NULL,
  address         NVARCHAR(60) NOT NULL,
  city            NVARCHAR(15) NOT NULL,
  region          NVARCHAR(15) NULL,
  postalcode      NVARCHAR(10) NULL,
  country         NVARCHAR(15) NOT NULL,
  phone           NVARCHAR(24) NOT NULL,
  mgrid           INT          NULL,
  CONSTRAINT PK_Employees PRIMARY KEY(empid),
  CONSTRAINT FK_Employees_Employees FOREIGN KEY(mgrid)
    REFERENCES HR.Employees(empid),
  CONSTRAINT CHK_birthdate CHECK(birthdate <= CURRENT_TIMESTAMP)
);

CREATE NONCLUSTERED INDEX idx_nc_lastname   ON HR.Employees(lastname);
CREATE NONCLUSTERED INDEX idx_nc_postalcode ON HR.Employees(postalcode);

-- Create table Production.Suppliers
CREATE TABLE Production.Suppliers
(
  supplierid   INT          NOT NULL IDENTITY,
  companyname  NVARCHAR(40) NOT NULL,
  contactname  NVARCHAR(30) NOT NULL,
  contacttitle NVARCHAR(30) NOT NULL,
  address      NVARCHAR(60) NOT NULL,
  city         NVARCHAR(15) NOT NULL,
  region       NVARCHAR(15) NULL,
  postalcode   NVARCHAR(10) NULL,
  country      NVARCHAR(15) NOT NULL,
  phone        NVARCHAR(24) NOT NULL,
  fax          NVARCHAR(24) NULL,
  CONSTRAINT PK_Suppliers PRIMARY KEY(supplierid)
);

CREATE NONCLUSTERED INDEX idx_nc_companyname ON Production.Suppliers(companyname);
CREATE NONCLUSTERED INDEX idx_nc_postalcode  ON Production.Suppliers(postalcode);

-- Create table Production.Categories
CREATE TABLE Production.Categories
(
  categoryid   INT           NOT NULL IDENTITY,
  categoryname NVARCHAR(15)  NOT NULL,
  description  NVARCHAR(200) NOT NULL,
  CONSTRAINT PK_Categories PRIMARY KEY(categoryid)
);

CREATE INDEX categoryname ON Production.Categories(categoryname);

-- Create table Production.Products
CREATE TABLE Production.Products
(
  productid    INT          NOT NULL IDENTITY,
  productname  NVARCHAR(40) NOT NULL,
  supplierid   INT          NOT NULL,
  categoryid   INT          NOT NULL,
  unitprice    MONEY        NOT NULL
    CONSTRAINT DFT_Products_unitprice DEFAULT(0),
  discontinued BIT          NOT NULL 
    CONSTRAINT DFT_Products_discontinued DEFAULT(0),
  CONSTRAINT PK_Products PRIMARY KEY(productid),
  CONSTRAINT FK_Products_Categories FOREIGN KEY(categoryid)
    REFERENCES Production.Categories(categoryid),
  CONSTRAINT FK_Products_Suppliers FOREIGN KEY(supplierid)
    REFERENCES Production.Suppliers(supplierid),
  CONSTRAINT CHK_Products_unitprice CHECK(unitprice >= 0)
);

CREATE NONCLUSTERED INDEX idx_nc_categoryid  ON Production.Products(categoryid);
CREATE NONCLUSTERED INDEX idx_nc_productname ON Production.Products(productname);
CREATE NONCLUSTERED INDEX idx_nc_supplierid  ON Production.Products(supplierid);

-- Create table Sales.Customers
CREATE TABLE Sales.Customers
(
  custid       INT          NOT NULL IDENTITY,
  companyname  NVARCHAR(40) NOT NULL,
  contactname  NVARCHAR(30) NOT NULL,
  contacttitle NVARCHAR(30) NOT NULL,
  address      NVARCHAR(60) NOT NULL,
  city         NVARCHAR(15) NOT NULL,
  region       NVARCHAR(15) NULL,
  postalcode   NVARCHAR(10) NULL,
  country      NVARCHAR(15) NOT NULL,
  phone        NVARCHAR(24) NOT NULL,
  fax          NVARCHAR(24) NULL,
  CONSTRAINT PK_Customers PRIMARY KEY(custid)
);

CREATE NONCLUSTERED INDEX idx_nc_city        ON Sales.Customers(city);
CREATE NONCLUSTERED INDEX idx_nc_companyname ON Sales.Customers(companyname);
CREATE NONCLUSTERED INDEX idx_nc_postalcode  ON Sales.Customers(postalcode);
CREATE NONCLUSTERED INDEX idx_nc_region      ON Sales.Customers(region);

-- Create table Sales.Shippers
CREATE TABLE Sales.Shippers
(
  shipperid   INT          NOT NULL IDENTITY,
  companyname NVARCHAR(40) NOT NULL,
  phone       NVARCHAR(24) NOT NULL,
  CONSTRAINT PK_Shippers PRIMARY KEY(shipperid)
);

-- Create table Sales.Orders
CREATE TABLE Sales.Orders
(
  orderid        INT          NOT NULL IDENTITY,
  custid         INT          NULL,
  empid          INT          NOT NULL,
  orderdate      DATETIME     NOT NULL,
  requireddate   DATETIME     NOT NULL,
  shippeddate    DATETIME     NULL,
  shipperid      INT          NOT NULL,
  freight        MONEY        NOT NULL
    CONSTRAINT DFT_Orders_freight DEFAULT(0),
  shipname       NVARCHAR(40) NOT NULL,
  shipaddress    NVARCHAR(60) NOT NULL,
  shipcity       NVARCHAR(15) NOT NULL,
  shipregion     NVARCHAR(15) NULL,
  shippostalcode NVARCHAR(10) NULL,
  shipcountry    NVARCHAR(15) NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY(orderid),
  CONSTRAINT FK_Orders_Customers FOREIGN KEY(custid)
    REFERENCES Sales.Customers(custid),
  CONSTRAINT FK_Orders_Employees FOREIGN KEY(empid)
    REFERENCES HR.Employees(empid),
  CONSTRAINT FK_Orders_Shippers FOREIGN KEY(shipperid)
    REFERENCES Sales.Shippers(shipperid)
);

CREATE NONCLUSTERED INDEX idx_nc_custid         ON Sales.Orders(custid);
CREATE NONCLUSTERED INDEX idx_nc_empid          ON Sales.Orders(empid);
CREATE NONCLUSTERED INDEX idx_nc_shipperid      ON Sales.Orders(shipperid);
CREATE NONCLUSTERED INDEX idx_nc_orderdate      ON Sales.Orders(orderdate);
CREATE NONCLUSTERED INDEX idx_nc_shippeddate    ON Sales.Orders(shippeddate);
CREATE NONCLUSTERED INDEX idx_nc_shippostalcode ON Sales.Orders(shippostalcode);

-- Create table Sales.OrderDetails
CREATE TABLE Sales.OrderDetails
(
  orderid   INT           NOT NULL,
  productid INT           NOT NULL,
  unitprice MONEY         NOT NULL
    CONSTRAINT DFT_OrderDetails_unitprice DEFAULT(0),
  qty       SMALLINT      NOT NULL
    CONSTRAINT DFT_OrderDetails_qty DEFAULT(1),
  discount  NUMERIC(4, 3) NOT NULL
    CONSTRAINT DFT_OrderDetails_discount DEFAULT(0),
  CONSTRAINT PK_OrderDetails PRIMARY KEY(orderid, productid),
  CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY(orderid)
    REFERENCES Sales.Orders(orderid),
  CONSTRAINT FK_OrderDetails_Products FOREIGN KEY(productid)
    REFERENCES Production.Products(productid),
  CONSTRAINT CHK_discount  CHECK (discount BETWEEN 0 AND 1),
  CONSTRAINT CHK_qty  CHECK (qty > 0),
  CONSTRAINT CHK_unitprice CHECK (unitprice >= 0)
)

CREATE NONCLUSTERED INDEX idx_nc_orderid   ON Sales.OrderDetails(orderid);
CREATE NONCLUSTERED INDEX idx_nc_productid ON Sales.OrderDetails(productid);
GO


/***********************************************************************************************************************/


SET IDENTITY_INSERT HR.Employees ON 
INSERT HR.Employees (empid, lastname, firstname, title, titleofcourtesy, birthdate, hiredate, address, city, region, postalcode, country, phone, mgrid) VALUES 
(1, N'Davis', N'sara', N'CEO', N'rs', CAST(N'1994-10-02 00:00:00.000' AS DateTime), CAST(N'2018-09-21 00:00:00.000' AS DateTime), N'212 - 29th ave', N'seatle', N'WA', N'231', N'USA', N'(122) 212 2121', NULL),

(2, N'John', N'deo', N'manger', N'rs', CAST(N'1994-08-25 00:00:00.000' AS DateTime), CAST(N'2018-09-21 00:00:00.000' AS DateTime), N'506 - 206 lester', N'waterloo', N'WA', N'231', N'USA', N'(226) 565 8295', 1),

(3, N'Wyatt', N'Abreu', N'Certified financial planner', N'rs', N'1990-06-02 00:00:00', N'2018-06-02 00:00:00', N'788-65 Westmount', N'WA', N'Waterloo', N'N2l 3W4',N'CA', N'(226) 784 9865', 1),

(4, N'Steve', N'Arai', N'Chartered wealth manager', N'rs', N'1989-04-25 00:00:00', N'2017-07-05 00:00:00', N'23847 36A Ave Langley BC', N'WA', N'Waterloo', N'V2Z 2J6',N'CA', N'(604) 533-2340', 2),

(5, N'Elenora', N'Smiley', N'Service desk analyst.', N'rs', N'1995-02-15 00:00:00', N'2015-06-05 00:00:00', N'43 Connor Lane Guelph ON', N'WA', N'Waterloo', N'N1E 7E9',N'CA', N'(519) 824-2661', 2),

(6, N'Kenisha', N'Yeung', N'Chartered wealth manager', N'rs', N'1992-06-30 00:00:00', N'2012-11-25 00:00:00', N'32-441 Weber', N'WA', N'Waterloo', N'N6g 3W4',N'CA', N'(226) 484 6532', 2),
(7, N'Nikia', N'Curtin', N'Network administrator', N'rs', N'1988-07-07 00:00:00', N'2010-06-09 00:00:00', N'39 Dobbin Lane Kanata ON', N'WA', N'Waterloo', N'K2M 2J5',N'CA', N'(613) 591-0347', 2),
(8, N'Shaunte', N'Romaine', N'Network engineer', N'rs', N'1991-04-15 00:00:00', N'2013-07-08 00:00:00', N'733 Skene Rd Gilmour ON', N'WA', N'Waterloo', N'K0L 1W0', N'CA', N'(613) 474-1027', 2),
(9, N'Quinn', N'Moorehead', N'Network architect', N'rs', N'1990-01-15 00:00:00', N'2014-08-05 00:00:00', N'1470 Pennyfarthing Dr 203 Vancouver BC', N'WA', N'Waterloo', N'V6J 4Y2',N'CA', N'(604) 736-2823', 2),
(10, N'Idell', N'Muck', N'Network manager', N'rs', N'1986-09-16 00:00:00', N'2014-09-09 00:00:00', N'452-2750 Fairlane St , Abbotsford, BC', N'WA', N'Waterloo', N'V2S 7K9',N'CA', N'604-870-9982', 2);
SET IDENTITY_INSERT HR.Employees OFF






/*************************************************************************************************************************/


SET IDENTITY_INSERT Sales.Customers ON;
insert into Sales.Customers(custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone,fax)
values  
(1, N'360Networks Inc.', N'360net', N'360Net', N'506-201 lester', N'WA', N'Waterloo', N'N2l 3W4', N'CA', N'(226) 565 8295', N'(226) 456 2564'),
(2, N'3DLabs Inc. Ltd.', N'3D', N'3D', N'456-84 King St', N'WA', N'Waterloo', N'N2l 3W4',N'CA', N'(226) 784 9865', N'(226) 423 6594'),
(3, N'724 Solutions Inc.', N'724 Solution', N'724 Solution', N'52-489 Albert St', N'WA', N'Waterloo', N'N6g 3W4',N'CA', N'(226) 852 1478', N'(226) 654 9874'),
(4, N'Acme Corporation', N'Millard Bouknight', N'Manager', N'7307 Prasmount Pl', N'BC', N'Agassiz', N'V0M 1A2',N'CA', N'604-796-8304', N'604-796-8304'),
(5, N'Globex Corporation', N'Gilberte Trotta', N'Manager', N'1145 Dakota St 209', N'MB', N'Winnipeg', N'N6g 3W4',N'CA', N'(204) 949-9566', N'(204) 949-9566'),
(6, N'Soylent Corp', N'Rupert Parrilla', N'Manager', N'68 Baycrest Pl SW 5', N'AB', N'Calgary', N'T2V 0K6',N'CA', N'(403) 244-2274', N'(403) 244-2274'),
(7, N'Initech', N'Mari Valladares', N'Manager', N'PO Box 206', N'AB ', N'Breton', N'T0C 0P0',N'CA', N'780-696-3419', N'780-696-3419'),
(8, N'Umbrella Corporation', N'Glayds Parson', N'Manager', N'513A Deer St', N'AB', N'Banff', N'T1L',N'CA', N'403-762-4397', N'403-762-4397'),
(9, N'Hooli', N'Anastasia Rosenfeld', N'Manager', N'2-119 4 Ave W', N'AB', N'Bow Island', N'T0K',N'CA', N'403-545-2395', N'403-545-2395'),
(10, N'Massive Dynamic', N'Katharine Hulme', N'Manager', N'42 Rue Bourbonnais', N'QC', N'Coteau du Lac', N'J0P 1B0',N'CA', N'450-308-0593', N'450-308-0593');

SET IDENTITY_INSERT Sales.Customers OFF;


/*************************************************************************************************************************/


SET IDENTITY_INSERT Sales.Shippers ON;
insert into Sales.Shippers(shipperid, companyname, phone)
values (1, N'Alvarion Ltd.', N'(226) 523 9856'),
	   (2, N'Amarin Corp plc', N'(226) 654 4523'),
	   (3, N'Sphinx Limited', N'(604) 533-2340'),
	   (4, N'Omegacoustics', N'((519) 824-2661'),
	   (5, N'Crypticorps', N'(613) 591-0347'),
	   (6, N'Felinetworks', N'(613) 474-1027'),
	   (7, N'Fairyscape', N'(604) 559-7340'),
	   (8, N'Goldhive', N'(604) 736-2823'),
	   (9, N'Diamondscape', N'(905) 417-4975'),
	   (10, N'Oak Brews', N'(604) 945-6600');

SET IDENTITY_INSERT Sales.Shippers OFF;
/********************************************************************************************************/


SET IDENTITY_INSERT Sales.Orders ON;
insert into Sales.Orders (orderid, custid, empid, orderdate, requireddate, shippeddate, shipperid, freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry) VALUES 
(1, 1, 2, CAST(N'2018-09-21 00:00:00.000' AS DateTime), CAST(N'2018-09-30 00:00:00.000' AS DateTime), CAST(N'2018-09-25 00:00:00.000' AS DateTime), 1, 100.0000, N'abc shipments', N'52-489 Albert St', N'WA', N'Waterloo', N'N6g 3W4', N'CA'),
(2, 2, 1, CAST(N'2018-09-10 00:00:00.000' AS DateTime), CAST(N'2018-09-25 00:00:00.000' AS DateTime), CAST(N'2018-09-23 00:00:00.000' AS DateTime), 2, 150.0000, N'uhul transports', N'62-894 Erb St', N'WA', N'Waterloo', N'N6g 3W4', N'CA'),
(3, 4, 9, CAST(N'2018-09-12 00:00:00.000' AS DateTime), CAST(N'2018-10-09 00:00:00.000' AS DateTime), CAST(N'2018-10-01 00:00:00.000' AS DateTime), 5, 200.0000, N'Thracian', N'23847 36A Ave', N'Langley ', N'BC', N'V2Z 2J6', N'CA'),
(4, 6, 7, CAST(N'2018-09-24 00:00:00.000' AS DateTime), CAST(N'2018-10-18 00:00:00.000' AS DateTime), CAST(N'2018-10-11 00:00:00.000' AS DateTime), 7, 400.0000, N'The Kildpart', N'43 Connor Lane', N'Guelph', N'ON ', N'N6g 3W4', N'CA'),
(5, 3, 5, CAST(N'2018-09-28 00:00:00.000' AS DateTime), CAST(N'2018-10-31 00:00:00.000' AS DateTime), CAST(N'2018-10-23 00:00:00.000' AS DateTime), 9, 350.0000, N'Colac', N'39 Dobbin Lane', N'Kanata', N'ON', N'K2M 2J5', N'CA'),
(6, 8, 3, CAST(N'2018-09-03 00:00:00.000' AS DateTime), CAST(N'2018-11-05 00:00:00.000' AS DateTime), CAST(N'2018-10-30 00:00:00.000' AS DateTime), 10, 640.0000, N'Gloire', N'733 Skene Rd', N'Gilmour', N'ON', N'K0L 1W0', N'CA'),
(7, 5, 1, CAST(N'2018-09-06 00:00:00.000' AS DateTime), CAST(N'2018-11-07 00:00:00.000' AS DateTime), CAST(N'2018-10-01 00:00:00.000' AS DateTime), 8, 425.0000, N'Wrentham', N'835 7th Ave E 101', N'Vancouver ', N'BC', N'V5T 1P4', N'CA'),
(8, 9, 2, CAST(N'2018-09-07 00:00:00.000' AS DateTime), CAST(N'2018-11-09 00:00:00.000' AS DateTime), CAST(N'2018-10-23 00:00:00.000' AS DateTime), 6, 550.0000, N'Paris', N'1470 Pennyfarthing Dr 203', N'Vancouver', N'BC', N'V6J 4Y2', N'CA'),
(9, 10, 4, CAST(N'2018-08-31 00:00:00.000' AS DateTime), CAST(N'2018-11-16 00:00:00.000' AS DateTime), CAST(N'2018-11-07 00:00:00.000' AS DateTime), 4, 600.0000, N'Prestonian', N'26557 Twp 490 Rd', N'Calmar', N'AB', N'T0C', N'CA'),
(10, 3, 6, CAST(N'2018-09-21 00:00:00.000' AS DateTime), CAST(N'2018-11-26 00:00:00.000' AS DateTime), CAST(N'2018-11-20 00:00:00.000' AS DateTime), 2, 625.0000, N'The Hampshire', N'183 Trudeau Dr', N'Woodbridge', N'ON', N'L4H 0E2', N'CA');
SET IDENTITY_INSERT Sales.Orders OFF;





/*************************************************************************************************************************/

SET IDENTITY_INSERT Production.Categories ON;
INSERT INTO Production.Categories(categoryid, categoryname, description)VALUES 
(1, N'Device', N'Electronics device accessories'),
(2, N'Kindle', N'(226) 654 4523'),
(3, N'Automotive', N'Parts, Tools & Equipment, Accessories'),
(4, N'Baby Prod', N'Nursery, Feeding, Gear'),
(5, N'Beauty', N'Fragrance, Skincare, Makeup, Hair Care, Bath & Shower. See also Health & Personal Care.'),
(6, N'Books', N'Books, Calendars, Card Decks, Sheet Music, Magazines, Journals, Other Publications'),
(7, N'Electronics', N'Electronics devices'),
(8, N'Camera Photo', N'Cameras, Camcorders, Telescopes'),
(9, N'Cell Phones', N'Phones'),
(10, N'Cloth Acces', N'Outerwear, Athletic Wear, Innerwear, Belts, Wallets');
SET IDENTITY_INSERT Production.Categories OFF;

/*************************************************************************************************************************/





SET IDENTITY_INSERT Production.Suppliers ON;
insert into Production.Suppliers (supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone, fax) VALUES 
(1, N'A B Electrolux', N'Darin Palmeri', N'CEO', N'456-84 King St', N'WA', N'Waterloo', N'N2l 3W4', N'CA', N'(226) 784 9865', N'(226) 423 6594'),
(2, N'A B SKF', N'Elise Criddle', N'CEO', N'52-489 Albert St', N'WA', N'Waterloo', N'N6g 3W4', N'CA', N'(226) 852 1478', N'(226) 654 9874'),
(3, N'Openlane', N'Jerlene Orris', N'CEO', N'42 Rue Bourbonnais', N'Coteau du Lac', N'QC', N'J0P 1B0', N'CA', N'416-555-0149', N'+1-416-555-0149'),
(4, N'Yearin', N'Jamal Hart', N'CEO', N'15 Ave anjou', N'Candiac', N'QC', N'J5R 3K2', N'CA', N'416-555-0145', N'416-555-0145'),
(5, N'Goodsilron', N'Albina Metoyer', N'CEO', N'429 SW. Bald Hill St.', N'Buckingham', N'QC', N'J8L B4P', N'CA', N'416-555-0161', N'416-555-0161'),
(6, N'Condax', N'Julietta Leasur', N'Manager', N'196 Glendale St', N'Chatham', N'QC', N'J8G Y2X', N'CA', N'(226) 852 1478', N'(226) 654 9874'),
(7, N'Opentech', N'ATameika Wegener', N'Manager', N'24 E. Edgewater Drive', N'Bayfield', N'NB', N'E4M Y4N', N'CA', N'416-555-0130', N'416-555-0130'),
(8, N'Gogozoom', N'Nikia Curtin', N'Manager', N'712 Pine Dr', N'Bromont', N'QC', N'J2L E9H', N'CA', N'416-555-0191', N'416-555-0191'),
(9, N'Warephase', N'Quinn Moorehead', N'Manager', N'8300 Canterbury Court', N'Cocagne', N'NB', N'E4R Y8N', N'CA', N'416-555-0124', N'(416-555-0124'),
(10, N'Donware', N'Millard Bouknight', N'Manager', N'7187 Courtland Street', N'St-Louis-de', N'NB', N'E4X T6R', N'CA', N'416-555-0111', N'416-555-0111');
SET IDENTITY_INSERT Production.Suppliers OFF;

/*************************************************************************************************************************/



SET IDENTITY_INSERT Production.Products ON; 

INSERT Production.Products (productid, productname, supplierid, categoryid, unitprice, discontinued) 
VALUES 
(1, N'HP',1, 7, 800, 0),
(2, N'Samsung',3, 9, 500, 0),
(3, N'Lewis',5, 10, 500, 0),
(4, N'Nikon',7, 8, 500, 0),
(5, N'Dove',9, 5, 500, 0),
(6, N'New York Times',2, 6, 500, 0),
(7, N'Wi-Fi Routers',4, 1, 500, 0),
(8, N'Baby Cosmetics',6, 4, 500, 0),
(9, N'Winter Tires',8, 3, 500, 0),
(10, N'Hedsets',6, 2, 500, 0);
SET IDENTITY_INSERT Production.Products OFF;

/*************************************************************************************************************************/

 
INSERT Sales.OrderDetails (orderid, productid, unitprice, qty, discount) 
VALUES
(1, 1, 800, 20, 0.1),
(2, 6, 600, 20, 0.1),
(3, 4, 450, 20, 0.1),
(4, 8, 456, 20, 0.1),
(5, 9, 620, 20, 0.1),
(6, 2, 350, 20, 0.1),
(7, 5, 450, 20, 0.1),
(8, 7, 450, 20, 0.1),
(9, 3, 750, 20, 0.1),
(10, 1, 250, 20, 0.1);



/*************************************************************************************************************************/

SELECT * FROM HR.Employees;

SELECT * FROM Production.Suppliers;

SELECT * FROM Production.Categories;

SELECT * FROM Production.Products;

SELECT * FROM Sales.Customers;

SELECT * FROM Sales.Shippers;

SELECT * FROM Sales.Orders;

SELECT * FROM Sales.OrderDetails;







--set identity_insert HR.Employees on;
-- insert into HR.Employees (empid,lastname,firstname,title,titleofcourtesy,birthdate,hiredate,address,city,region,postalcode,country,phone,mgrid) 
-- values (1,'Wilson','Tom','editor','Mr.','07-02-1980','01-01-1999','33 west ave','brampton','ontario','K3E 2L3','Canada','223-334-4433','5');

--  insert into HR.Employees (empid,lastname,firstname,title,titleofcourtesy,birthdate,hiredate,address,city,region,postalcode,country,phone,mgrid) 
-- values (2,'Cabott','John','accountant','Sir','07-23-1975','06-01-1993','384 west ave','waterloo','ontario','K3W 2L4','Canada','293-334-4833','3');
 
--  insert into HR.Employees (empid,lastname,firstname,title,titleofcourtesy,birthdate,hiredate,address,city,region,postalcode,country,phone,mgrid) 
-- values (3,'Fred','Garry','manager','Mr.','11-18-1978','04-01-1998','66 river road','Kitchener','ontario','M9E 2L5','Canada','253-388-9933',Null);

--  insert into HR.Employees (empid,lastname,firstname,title,titleofcourtesy,birthdate,hiredate,address,city,region,postalcode,country,phone,mgrid) 
-- values (4,'Hanks','Henry','supervisor','Mr.','03-21-2000','05-01-2016','1345 bridge st','waterloo','ontario','K3D 4C4','Canada','293-334-0433','8');

--  insert into HR.Employees (empid,lastname,firstname,title,titleofcourtesy,birthdate,hiredate,address,city,region,postalcode,country,phone,mgrid) 
-- values (5,'Ford','Doug','manager','Mr.','12-22-1980','06-15-1999','876 falls road','Niagara','ontario','B3E 2Q3','Canada','513-334-4433',Null);

--  insert into HR.Employees (empid,lastname,firstname,title,titleofcourtesy,birthdate,hiredate,address,city,region,postalcode,country,phone,mgrid) 
-- values (6,'Cannon','Lora','editor','Mrs.','11-30-1990','11-01-2008','33 east ave','brampton','ontario','P2E 2L3','Canada','203-334-4123','5');

--  insert into HR.Employees (empid,lastname,firstname,title,titleofcourtesy,birthdate,hiredate,address,city,region,postalcode,country,phone,mgrid) 
-- values (7,'Jonson','James','CEO','Mr.','07-02-1970','01-01-1988','892 west ave','Guelph','ontario','K5M 2L1','Canada','523-309-0123',Null);

--  insert into HR.Employees (empid,lastname,firstname,title,titleofcourtesy,birthdate,hiredate,address,city,region,postalcode,country,phone,mgrid) 
-- values (8,'Obama','Barak','manager','Mr.','07-28-1976','01-01-1999','990 North ave','Kitchener','ontario','P2E 9B6','Canada','447-324-4433','3');

--  insert into HR.Employees (empid,lastname,firstname,title,titleofcourtesy,birthdate,hiredate,address,city,region,postalcode,country,phone,mgrid) 
-- values (9,'Day','Jessica','trainer','Miss','06-21-1991','12-01-2011','456 west ave','brampton','ontario','A3E 5L3','Canada','437-334-4423','8');

--  insert into HR.Employees (empid,lastname,firstname,title,titleofcourtesy,birthdate,hiredate,address,city,region,postalcode,country,phone,mgrid) 
-- values (10,'Hemsted','Fred','sales','Mr.','01-06-1984','08-01-1999','33 south ave','cambridge','ontario','K3X 2R3','Canada','237-534-9873','5');
-- set identity_insert HR.Employees off;


