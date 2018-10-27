DROP VIEW IF EXISTS "Author";
DROP TABLE IF EXISTS "OrderItems";
DROP TABLE IF EXISTS "Edition";
DROP TABLE IF EXISTS "BookAuthors";
DROP TABLE IF EXISTS "Book";
DROP TABLE IF EXISTS "AuthorBase";
DROP TABLE IF EXISTS "Order";
DROP TABLE IF EXISTS "Client";
DROP INDEX IF EXISTS Publisher_Name_uindex;
DROP TABLE IF EXISTS "Publisher";


CREATE TABLE "AuthorBase"
(
  ID         INT PRIMARY KEY NOT NULL,
  FirstName  VARCHAR(20)     NOT NULL,
  MiddleName VARCHAR(20)     NOT NULL,
  LastName   VARCHAR(20)     NOT NULL
);

CREATE VIEW "Author" AS
  SELECT
    ID,
    FirstName,
    MiddleName,
    LastName,
    getauthorfullname(FirstName, MiddleName, LastName) AS FullName,
    getauthorshortname(FirstName, MiddleName, LastName) AS ShortFullName
  FROM "AuthorBase";


CREATE TABLE "Book"
(
  ID        INT PRIMARY KEY NOT NULL,
  Name      VARCHAR(50)     NOT NULL,
  ShortName VARCHAR(5)
);


CREATE TABLE "BookAuthors"
(
  BookID   INT NOT NULL,
  AuthorID INT NOT NULL,
  PRIMARY KEY (BookID, AuthorID),
  FOREIGN KEY (BookID) REFERENCES "Book" (ID) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (AuthorID) REFERENCES "AuthorBase" (ID) ON UPDATE CASCADE ON DELETE CASCADE
);



CREATE TABLE "Client"
(
  ID    INT PRIMARY KEY NOT NULL,
  Login VARCHAR(20)     NOT NULL,
  Name  VARCHAR(50)
);


CREATE TABLE "Order"
(
  ID         INT PRIMARY KEY NOT NULL,
  ClientId  INT NOT NULL,
  OpenedDate DATE            NOT NULL,
  ClosedDate DATE            NOT NULL,
  CHECK (OpenedDate <= ClosedDate),
  FOREIGN KEY (ClientId) REFERENCES "Client" (ID) ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE "Publisher"
(
  ID   INT PRIMARY KEY NOT NULL,
  Name VARCHAR(50)     NOT NULL,
  City VARCHAR(50)     NOT NULL
);
CREATE UNIQUE INDEX Publisher_Name_uindex
  ON "Publisher" (Name);


CREATE TABLE "Edition"
(
  ID          INT PRIMARY KEY NOT NULL,
  BookID      INT             NOT NULL,
  PublisherID INT             NOT NULL,
  PublishYear INT             NOT NULL,
  PagesCount  INT,
  CHECK (PublishYear >= 0),
  CHECK (PagesCount >= 0),
  FOREIGN KEY (BookID) REFERENCES "Book" (ID) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (PublisherID) REFERENCES "Publisher" (ID) ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE "OrderItems"
(
  OrderId   INT NOT NULL,
  EditionID INT NOT NULL,
  Count     INT NOT NULL,
  PRIMARY KEY (OrderId, EditionID),
  FOREIGN KEY (OrderId) REFERENCES "Order" (ID) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (EditionID) REFERENCES "Edition" (ID) ON UPDATE CASCADE ON DELETE CASCADE
);