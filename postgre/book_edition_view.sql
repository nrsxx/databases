DROP VIEW IF EXISTS "BookEdition";

CREATE OR REPLACE VIEW "BookEdition" AS
  SELECT
    BookId,
    Name AS BookName,
    PublisherId,
    PublishYear,
    PagesCount
  FROM "Book", "Edition"
  WHERE BookId = "Book".ID;


CREATE OR REPLACE FUNCTION "UpdateBookEdition_trigger"()
  RETURNS TRIGGER AS $$
BEGIN
  IF NEW.BookID != OLD.BookId
  THEN
    IF NEW.PublisherID != OLD.PublisherID
    THEN
      UPDATE "Edition"
      SET BookId   = NEW.BookId, PublisherID = NEW.PublisherID, PublishYear = NEW.PublishYear,
        PagesCount = NEW.PagesCount
      WHERE BookId = OLD.BookId AND PublisherId = OLD.PublisherId;
    ELSE
      UPDATE "Edition"
      SET BookId   = NEW.BookId, PublishYear = NEW.PublishYear,
        PagesCount = NEW.PagesCount
      WHERE BookId = OLD.BookId AND PublisherId = OLD.PublisherId;
    END IF;
  ELSE
    IF NEW.PublisherID != OLD.PublisherId
    THEN
      UPDATE "Edition"
      SET PublisherID = NEW.PublisherID, PublishYear = NEW.PublishYear,
        PagesCount    = NEW.PagesCount
      WHERE BookId = OLD.BookId AND PublisherId = OLD.PublisherId;
    ELSE
      UPDATE "Edition"
      SET PublishYear = NEW.PublishYear,
        PagesCount    = NEW.PagesCount
      WHERE BookId = OLD.BookId AND PublisherId = OLD.PublisherId;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';


CREATE TRIGGER "UpdateBookEdition"
  INSTEAD OF UPDATE
  ON "BookEdition"
  FOR EACH ROW EXECUTE PROCEDURE "UpdateBookEdition_trigger"();

CREATE OR REPLACE FUNCTION "InsertBookEdition_trigger"()
  RETURNS TRIGGER AS $$
DECLARE edition_id INT;
BEGIN
  SELECT MAX(ID) + 1
  INTO edition_id
  FROM "Edition";
  INSERT INTO "Edition" VALUES (edition_id, NEW.BookId, NEW.PublisherId, NEW.PublishYear, NEW.PagesCount);

  RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER "InsertBookEdition"
  INSTEAD OF INSERT
  ON "BookEdition"
FOR EACH  ROW EXECUTE PROCEDURE "InsertBookEdition_trigger"();

CREATE OR REPLACE FUNCTION "DeleteBookEdition_trigger"()
  RETURNS TRIGGER AS $$
BEGIN
  DELETE FROM "Edition"
  WHERE BookId = OLD.BookID AND PublisherID = OLD.PublisherID;

  RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER "DeleteBookEdition"
  INSTEAD OF DELETE
  ON "BookEdition"
FOR EACH ROW EXECUTE PROCEDURE "DeleteBookEdition_trigger"();