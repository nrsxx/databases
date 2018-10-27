CREATE OR REPLACE VIEW "BookEdition" AS
  SELECT
    BookId,
    Name AS BookName,
    PublisherId,
    PublishYear,
    PagesCount
  FROM "Book", "Edition"
  WHERE BookId = "Book".ID;


CREATE OR REPLACE TRIGGER update_book_edition
  INSTEAD OF UPDATE
  ON BOOKS_ADMIN."BookEdition"
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
  END;

CREATE OR REPLACE TRIGGER insert_book_edition
  INSTEAD OF INSERT
  ON BOOKS_ADMIN."BookEdition"
  DECLARE
  edition_id INT;
  BEGIN
    SELECT MAX(ID) + 1
    INTO edition_id
    FROM "Edition";
    INSERT INTO "Edition" VALUES (edition_id, NEW.BookId, NEW.PublisherId, NEW.PublishYear, NEW.PagesCount);
  END;

CREATE OR REPLACE TRIGGER delete_book_edition
  INSTEAD OF DELETE
  ON BOOKS_ADMIN."BookEdition"
  BEGIN
    DELETE FROM "Edition"
    WHERE BookId = OLD.BookID AND PublisherID = OLD.PublisherID;
  END;