CREATE OR REPLACE PROCEDURE CreateAuthor(first IN VARCHAR, middle IN VARCHAR,
                                         last  IN VARCHAR, ins_id OUT INT)
AS
  v_count INT;
  BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM "Author"
    WHERE FIRSTNAME = first AND MIDDLENAME = middle AND LASTNAME = last;
    IF v_count >= 1
    THEN
      RAISE VALUE_ERROR;
    END IF;

    SELECT MAX(ID) + 1
    INTO ins_id
    FROM "Author";
    INSERT INTO "Author" (ID, FirstName, MiddleName, LastName) VALUES (ins_id, first, middle, last);
  END;
/

CREATE OR REPLACE PROCEDURE TryCreateAuthor(first IN VARCHAR, middle IN VARCHAR,
                                            last  IN VARCHAR, ins_id OUT INT)
AS
  v_count INT;
  BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM "Author"
    WHERE FIRSTNAME = first AND MIDDLENAME = middle AND LASTNAME = last;
    IF v_count >= 1
    THEN
      ins_id := -1;
    ELSE
      SELECT MAX(ID) + 1
      INTO ins_id
      FROM "Author";
      INSERT INTO "Author" (ID, FirstName, MiddleName, LastName) VALUES (ins_id, first, middle, last);
    END IF;
  END;
/

CREATE OR REPLACE PROCEDURE UpdateAuthorFullName(idToUpdate IN INT, first IN VARCHAR, middle IN VARCHAR,
                                                 last       IN VARCHAR) AS
  BEGIN
    UPDATE "Author"
    SET FIRSTNAME = first, MIDDLENAME = middle, LASTNAME = last
    WHERE ID = idToUpdate;
  END;
/

CREATE OR REPLACE PROCEDURE UpdateAuthorFirstName(idToUpdate IN INT, first IN VARCHAR) AS
  BEGIN
    UPDATE "Author"
    SET FIRSTNAME = first
    WHERE ID = idToUpdate;
  END;
/

CREATE OR REPLACE PROCEDURE UpdateAuthorMiddleName(idToUpdate IN INT, middle IN VARCHAR) AS
  BEGIN
    UPDATE "Author"
    SET MIDDLENAME = middle
    WHERE ID = idToUpdate;
  END;
/

CREATE OR REPLACE PROCEDURE UpdateAuthorLastName(idToUpdate IN INT, last IN VARCHAR) AS
  BEGIN
    UPDATE "Author"
    SET LASTNAME = last
    WHERE ID = idToUpdate;
  END;
/

CREATE OR REPLACE PROCEDURE DeleteAuthor(idToDelete IN INT) AS
  BEGIN
    DELETE FROM "Author"
    WHERE ID = idToDelete;
  END;
/

CREATE OR REPLACE TYPE ROWGETAUTHOR AS OBJECT (
  ID            INT,
  FirstName     VARCHAR(20),
  MiddleName    VARCHAR(20),
  LastName      VARCHAR(20),
  FullName      VARCHAR(62),
  ShortFullName VARCHAR(32)
);

/

CREATE OR REPLACE TYPE TABLEGETAUTHOR IS TABLE OF ROWGETAUTHOR;

/

CREATE OR REPLACE FUNCTION GetAuthor(authorId IN INT DEFAULT NULL)
  RETURN TABLEGETAUTHOR AS
  res TABLEGETAUTHOR := TABLEGETAUTHOR();
  BEGIN
    IF authorId IS NULL
    THEN
      SELECT ROWGETAUTHOR(ID, FIRSTNAME, MIDDLENAME, LASTNAME, FULLNAME, SHORTFULLNAME)
      BULK COLLECT INTO res
      FROM "Author";
    ELSE
      SELECT ROWGETAUTHOR(ID, FIRSTNAME, MIDDLENAME, LASTNAME, FULLNAME, SHORTFULLNAME)
      BULK COLLECT INTO res
      FROM "Author"
      WHERE ID = authorId;
    END IF;
    RETURN res;
  END;
/

