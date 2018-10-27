CREATE OR REPLACE FUNCTION GetAuthorsBefore(client_id IN INT, book_id IN INT)
  RETURN TABLEGETAUTHOR AS
  buy_date DATE;
  res TABLEGETAUTHOR := TABLEGETAUTHOR();
  BEGIN
    SELECT MIN("Order".OpenedDate)
    INTO buy_date
    FROM ("Order"
      INNER JOIN "OrderItems" ON "Order".ID = "OrderItems".orderid) INNER JOIN "Edition"
        ON "Edition".ID = "OrderItems".EditionID
    WHERE "Edition".BookID = book_id AND "Order".ClientID = client_id;

    SELECT ROWGETAUTHOR(ID, FIRSTNAME, MIDDLENAME, LASTNAME, FULLNAME, SHORTFULLNAME) BULK COLLECT INTO res
    FROM "Author"
    WHERE "Author".ID IN
          (SELECT "BookAuthors".AuthorID
           FROM "BookAuthors"
             INNER JOIN
             (SELECT "Edition".BookID AS book_id
              FROM "Edition"
                INNER JOIN
                (SELECT "OrderItems".EditionID
                 FROM "OrderItems"
                   INNER JOIN (SELECT "Order".ID
                               FROM "Order"
                               WHERE ClientID = client_id AND "Order".OpenedDate < buy_date)
                 ON ID = "OrderItems".orderid)
              ON "Edition".id = EditionID) ON book_id = "BookAuthors".bookid);

    RETURN res;
  END;
/


CREATE OR REPLACE FUNCTION GetAuthorsAfter(client_id IN INT, book_id IN INT)
  RETURN TABLEGETAUTHOR AS
  buy_date DATE;
  res TABLEGETAUTHOR := TABLEGETAUTHOR();
  BEGIN
    SELECT MIN("Order".OpenedDate)
    INTO buy_date
    FROM ("Order"
      INNER JOIN "OrderItems" ON "Order".ID = "OrderItems".orderid) INNER JOIN "Edition"
        ON "Edition".ID = "OrderItems".EditionID
    WHERE "Edition".BookID = book_id AND "Order".ClientID = client_id;

    SELECT ROWGETAUTHOR(ID, FIRSTNAME, MIDDLENAME, LASTNAME, FULLNAME, SHORTFULLNAME) BULK COLLECT INTO res
    FROM "Author"
    WHERE "Author".ID IN
          (SELECT "BookAuthors".AuthorID
           FROM "BookAuthors"
             INNER JOIN
             (SELECT "Edition".BookID AS book_id
              FROM "Edition"
                INNER JOIN
                (SELECT "OrderItems".EditionID
                 FROM "OrderItems"
                   INNER JOIN (SELECT "Order".ID
                               FROM "Order"
                               WHERE ClientID = client_id AND "Order".OpenedDate > buy_date)
                 ON ID = "OrderItems".orderid)
              ON "Edition".id = EditionID) ON book_id = "BookAuthors".bookid);

    RETURN res;
  END;
/