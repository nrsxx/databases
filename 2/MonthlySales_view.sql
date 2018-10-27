DROP VIEW IF EXISTS "MonthlySales";
CREATE OR REPLACE VIEW "MonthlySales" AS
  SELECT
    "Publisher".Name   AS PublisherName,
    date_trunc('month', "Order".OpenedDate)::DATE AS Date,
    SUM("OrderItems".Count) AS Sales
  FROM "Order"
    INNER JOIN "OrderItems" ON "Order".ID = "OrderItems".OrderID
    INNER JOIN "Edition" ON "Edition".ID = "OrderItems".EditionID
    INNER JOIN "Publisher" ON "Publisher".ID = "Edition".PublisherID
  GROUP BY ("Publisher".Name, Date);