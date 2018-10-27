CREATE OR REPLACE FUNCTION GetAuthorsBefore(client_id IN INT, book_id IN INT)
  RETURNS TABLE(ID            INT,
                FirstName     VARCHAR(20),
                MiddleName    VARCHAR(20),
                LastName      VARCHAR(20),
                FullName      VARCHAR,
                ShortFullName VARCHAR) AS $$
DECLARE buy_date DATE;

BEGIN

  SELECT MIN(orders.OpenedDate)
  INTO buy_date
  FROM ("Order"
    INNER JOIN "OrderItems" ON "Order".ID = "OrderItems".orderid) AS orders INNER JOIN "Edition"
      ON "Edition".ID = orders.EditionID
  WHERE "Edition".BookID = book_id AND orders.ClientID = client_id;

  RETURN QUERY
  SELECT *
  FROM "Author"
  WHERE "Author".ID IN
        (SELECT "BookAuthors".AuthorID
         FROM "BookAuthors"
           INNER JOIN
           (SELECT "Edition".BookID
            FROM "Edition"
              INNER JOIN
              (SELECT "OrderItems".EditionID
               FROM "OrderItems"
                 INNER JOIN (SELECT "Order".ID
                             FROM "Order"
                             WHERE ClientID = client_id AND "Order".OpenedDate < buy_date) AS orders
                   ON orders.ID = "OrderItems".orderid) AS ed
                ON "Edition".id = ed.EditionID) AS ed ON ed.BookID = "BookAuthors".bookid);
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION GetAuthorsAfter(client_id IN INT, book_id IN INT)
  RETURNS TABLE(ID            INT,
                FirstName     VARCHAR(20),
                MiddleName    VARCHAR(20),
                LastName      VARCHAR(20),
                FullName      VARCHAR,
                ShortFullName VARCHAR) AS $$
DECLARE buy_date DATE;

BEGIN

  SELECT MIN(orders.OpenedDate)
  INTO buy_date
  FROM ("Order"
    INNER JOIN "OrderItems" ON "Order".ID = "OrderItems".orderid) AS orders INNER JOIN "Edition"
      ON "Edition".ID = orders.EditionID
  WHERE "Edition".BookID = book_id AND orders.ClientID = client_id;

  RETURN QUERY
  SELECT *
  FROM "Author"
  WHERE "Author".ID IN
        (SELECT "BookAuthors".AuthorID
         FROM "BookAuthors"
           INNER JOIN
           (SELECT "Edition".BookID
            FROM "Edition"
              INNER JOIN
              (SELECT "OrderItems".EditionID
               FROM "OrderItems"
                 INNER JOIN (SELECT "Order".ID
                             FROM "Order"
                             WHERE ClientID = client_id AND "Order".OpenedDate > buy_date) AS orders
                   ON orders.ID = "OrderItems".orderid) AS ed
                ON "Edition".id = ed.EditionID) AS ed ON ed.BookID = "BookAuthors".bookid);
END;
$$ LANGUAGE 'plpgsql';