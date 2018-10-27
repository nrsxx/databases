DROP VIEW "MonthlySales";
CREATE OR REPLACE VIEW "MonthlySales" AS
  SELECT
    "Publisher".Name   AS PublisherName,
    trunc("Order".OpenedDate, 'MONTH') AS "Date",
    SUM("OrderItems".Count) AS Sales
  FROM "Order"
    INNER JOIN "OrderItems" ON "Order".ID = "OrderItems".OrderID
    INNER JOIN "Edition" ON "Edition".ID = "OrderItems".EditionID
    INNER JOIN "Publisher" ON "Publisher".ID = "Edition".PublisherID
  GROUP BY ("Publisher".Name, "Order".OpenedDate);