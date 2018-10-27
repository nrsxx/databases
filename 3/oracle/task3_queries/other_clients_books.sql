CREATE OR REPLACE TYPE ROWGETBOOKS AS OBJECT (
  BookID   INT,
  BookName VARCHAR(50)
);






/

CREATE OR REPLACE TYPE TABLEGETBOOKS IS TABLE OF ROWGETBOOKS;






/

CREATE OR REPLACE TYPE ROWGETBOOKSID AS OBJECT (
  BookID INT
);






/

CREATE OR REPLACE TYPE TABLEGETBOOKSID IS TABLE OF ROWGETBOOKSID;






/

CREATE OR REPLACE TYPE ROWGETCLIENTSBOOKS AS OBJECT (
  ClientID INT,
  BookID   INT,
  BookName VARCHAR(50)
);






/

CREATE OR REPLACE TYPE TABLEGETCLIENTSBOOKS IS TABLE OF ROWGETCLIENTSBOOKS;






/


CREATE OR REPLACE FUNCTION GetAllBooksFromOrder(order_id IN INT)
  RETURN TABLEGETBOOKSID AS
  res TABLEGETBOOKSID := TABLEGETBOOKSID();
  BEGIN
    SELECT ROWGETBOOKSID("Edition".BookID)
    BULK COLLECT INTO res
    FROM "Edition"
      INNER JOIN "OrderItems" ON "Edition".ID = "OrderItems".editionid
    WHERE "OrderItems".OrderID = order_id;

    RETURN res;
  END;
/


CREATE OR REPLACE FUNCTION GetClientsBooks
  RETURN TABLEGETCLIENTSBOOKS AS
  res TABLEGETCLIENTSBOOKS := TABLEGETCLIENTSBOOKS();
  BEGIN
    SELECT ROWGETCLIENTSBOOKS(client_id, book_id, "Book".Name)
    BULK COLLECT INTO res
    FROM "Book"
      INNER JOIN
      (SELECT
         client_id,
         "Edition".BookId AS book_id
       FROM "Edition"
         INNER JOIN
         (SELECT
            client_id,
            "OrderItems".EditionID AS edition_id
          FROM "OrderItems"
            INNER JOIN
            (SELECT
               "Client".ID AS client_id,
               "Order".ID  AS order_id
             FROM "Client"
               INNER JOIN "Order" ON "Client".ID = "Order".clientid)
              ON order_id = "OrderItems".OrderId)
           ON edition_id = "Edition".ID)
        ON book_id = "Book".ID;

    RETURN res;
  END;
/


CREATE OR REPLACE FUNCTION GetCuttedClientBooks(order_id IN INT)
  RETURN TABLEGETCLIENTSBOOKS AS
  res TABLEGETCLIENTSBOOKS := TABLEGETCLIENTSBOOKS();
  BEGIN
    SELECT ROWGETCLIENTSBOOKS(CLIENTID, BOOKID, BOOKNAME)
    BULK COLLECT INTO res
    FROM TABLE (GetClientsBooks()) INNER JOIN (SELECT BookID AS order_book_id
                                               FROM TABLE (GetAllBooksFromOrder(order_id)))
        ON BookID = order_book_id;

    RETURN res;
  END;
/


CREATE OR REPLACE FUNCTION GetClientsAll(order_id IN INT)
  RETURN TABLEGETBOOKS AS
  res        TABLEGETBOOKS := TABLEGETBOOKS();
  book_count INT;
  BEGIN
    SELECT COUNT(*)
    INTO book_count
    FROM TABLE (GetAllBooksFromOrder(order_id));

    SELECT ROWGETBOOKS(BookID, BookName)
    BULK COLLECT INTO res
    FROM TABLE (GetCuttedClientBooks(order_id))
    WHERE ClientID IN (SELECT ClientID
                       FROM TABLE (GetCuttedClientBooks(order_id))
                       GROUP BY ClientID
                       HAVING COUNT(ClientID) = book_count)
    GROUP BY (BookID, BookName);

    RETURN RES;
  END;
/