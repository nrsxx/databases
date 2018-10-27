SELECT
  ID,
  FullName
FROM "Author"
  INNER JOIN (SELECT AuthorID
              FROM "BookAuthors"
                INNER JOIN (SELECT BookId
                            FROM "Edition"
                              INNER JOIN (SELECT EditionID
                                          FROM
                                            "OrderItems"
                                            INNER JOIN
                                            (SELECT ID
                                             FROM "Order"
                                             WHERE
                                               EXTRACT(MONTH
                                                       FROM
                                                       OpenedDate)
                                               > 5 AND
                                               EXTRACT(MONTH
                                                       FROM
                                                       OpenedDate)
                                               < 9) AS o
                                              ON o.ID = OrderId) AS e
                                ON e.EditionId = ID) AS b
                  ON b.BookId = "BookAuthors".BookID) AS ba ON ba.AuthorID = ID
GROUP BY "Author".ID, "Author".FullName;
