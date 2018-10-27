CREATE OR REPLACE FUNCTION GetAllBooksFromOrder(order_id IN INT)
  RETURNS TABLE(BookID INT) AS $$
BEGIN
  RETURN QUERY
  SELECT "Edition".BookID AS BookId
  FROM "Edition"
    INNER JOIN "OrderItems" ON "Edition".ID = "OrderItems".editionid
  WHERE "OrderItems".OrderID = order_id;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION GetClientsBooks()
  RETURNS TABLE(ClientID INT, BookId INT, BookName VARCHAR(50)) AS $$
BEGIN
  RETURN QUERY
  SELECT
    client_book.client_id AS ClientID,
    client_book.book_id   AS BookID,
    "Book".Name           AS BookName
  FROM "Book"
    INNER JOIN
    (SELECT
       client_edition.client_id,
       "Edition".BookId AS book_id
     FROM "Edition"
       INNER JOIN
       (SELECT
          client_order.client_id,
          "OrderItems".EditionID AS edition_id
        FROM "OrderItems"
          INNER JOIN
          (SELECT
             "Client".ID AS client_id,
             "Order".ID  AS order_id
           FROM "Client"
             INNER JOIN "Order" ON "Client".ID = "Order".clientid) AS client_order
            ON client_order.order_id = "OrderItems".OrderId) AS client_edition
         ON client_edition.edition_id = "Edition".ID) AS client_book
      ON client_book.book_id = "Book".ID;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION GetClientsAll(order_id IN INT)
  RETURNS TABLE(BookID INT, BookName VARCHAR(50)) AS $$
DECLARE book_count INT;
BEGIN
  SELECT COUNT(*)
  INTO book_count
  FROM GetAllBooksFromOrder(order_id);

  RETURN QUERY
  SELECT
    clients_books.BookID,
    clients_books.BookName
  FROM GetClientsBooks() AS clients_books INNER JOIN (SELECT *
                                                      FROM GetAllBooksFromOrder(order_id)) AS books
      ON books.BookID = clients_books.BookID
  WHERE clients_books.ClientID IN (SELECT cb1.ClientID
                                   FROM GetClientsBooks() AS cb1 INNER JOIN (SELECT *
                                                                             FROM GetAllBooksFromOrder(
                                                                                 order_id)) AS cb2
                                       ON cb1.BookID = cb2.BookID
                                   GROUP BY cb1.ClientID
                                   HAVING COUNT(cb1.ClientID) = book_count) GROUP BY clients_books.BookID, clients_books.BookName;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION GetClientsAny(order_id IN INT)
  RETURNS TABLE(BookID INT, BookName VARCHAR(50)) AS $$
BEGIN
  RETURN QUERY
  SELECT
    clients_books.BookID,
    clients_books.BookName
  FROM GetClientsBooks() AS clients_books INNER JOIN (SELECT *
                                                      FROM GetAllBooksFromOrder(order_id)) AS books
      ON books.BookID = clients_books.BookID
  WHERE clients_books.ClientID IN (SELECT cb1.ClientID
                                   FROM GetClientsBooks() AS cb1 INNER JOIN (SELECT *
                                                                             FROM GetAllBooksFromOrder(
                                                                                 order_id)) AS cb2
                                       ON cb1.BookID = cb2.BookID
                                   GROUP BY cb1.ClientID
                                   HAVING COUNT(cb1.ClientID) > 0) GROUP BY clients_books.BookID, clients_books.BookName;
END;
$$ LANGUAGE 'plpgsql';