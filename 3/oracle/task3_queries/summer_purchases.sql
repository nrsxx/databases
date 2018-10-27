SELECT
  ID,
  FULLNAME
FROM "Author"
  INNER JOIN
  (SELECT AuthorID
   FROM
     "BookAuthors"
     INNER JOIN
     (SELECT BookID AS BookID2
      FROM
        "Edition"
        INNER JOIN
        (SELECT EditionId
         FROM
           "OrderItems"
           INNER JOIN (SELECT ID
                       FROM "Order"
                       WHERE EXTRACT(MONTH FROM OpenedDate) > 5 AND EXTRACT(MONTH FROM OpenedDate) < 9)
             ON ID = OrderId) ON ID = EditionID) ON BookID = BOOKID2) ON ID = AuthorId