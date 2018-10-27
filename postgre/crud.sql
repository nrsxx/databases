CREATE OR REPLACE FUNCTION CreateAuthor(first IN VARCHAR, middle IN VARCHAR,
                                        last  IN VARCHAR)
  RETURNS INT AS $$
DECLARE v_count INT;
        ins_id  INT;
BEGIN
  SELECT COUNT(*)
  INTO v_count
  FROM "Author"
  WHERE FIRSTNAME = first AND MIDDLENAME = middle AND LASTNAME = last;
  IF v_count >= 1
  THEN
    RAISE EXCEPTION 'Author already exists';
  END IF;

  SELECT INTO ins_id MAX(ID) + 1
  FROM "Author";
  INSERT INTO "Author" (ID, firstname, middlename, lastname) VALUES (ins_id, first, middle, last);
  RETURN ins_id;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION TryCreateAuthor(first IN VARCHAR, middle IN VARCHAR,
                                           last  IN VARCHAR)
  RETURNS INT AS $$
DECLARE v_count INT;
        ins_id  INT;
BEGIN
  SELECT COUNT(*)
  INTO v_count
  FROM "Author"
  WHERE FIRSTNAME = first AND MIDDLENAME = middle AND LASTNAME = last;
  IF v_count >= 1
  THEN
    RETURN -1;
  END IF;

  SELECT INTO ins_id MAX(ID) + 1
  FROM "Author";
  INSERT INTO "Author" (ID, firstname, middlename, lastname) VALUES (ins_id, first, middle, last);
  RETURN ins_id;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION UpdateAuthorFullName(idToUpdate IN INT, first IN VARCHAR, middle IN VARCHAR,
                                                last       IN VARCHAR)
  RETURNS VOID AS $$
BEGIN
  UPDATE "Author"
  SET FIRSTNAME = first, MIDDLENAME = middle, LASTNAME = last
  WHERE ID = idToUpdate;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION UpdateAuthorFirstName(idToUpdate IN INT, first IN VARCHAR)
  RETURNS VOID AS $$
BEGIN
  UPDATE "Author"
  SET FIRSTNAME = first
  WHERE ID = idToUpdate;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION UpdateAuthorMiddleName(idToUpdate IN INT, middle IN VARCHAR)
  RETURNS VOID AS $$
BEGIN
  UPDATE "Author"
  SET MIDDLENAME = middle
  WHERE ID = idToUpdate;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION UpdateAuthorLastName(idToUpdate IN INT, last IN VARCHAR)
  RETURNS VOID AS $$
BEGIN
  UPDATE "Author"
  SET LASTNAME = last
  WHERE ID = idToUpdate;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION DeleteAuthor(idToDelete IN INT)
  RETURNS VOID AS $$
BEGIN
  DELETE FROM "Author"
  WHERE ID = idToDelete;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION GetAuthor(authorId IN INT DEFAULT NULL)
  RETURNS TABLE(ID            INT,
                FirstName     VARCHAR(20),
                MiddleName    VARCHAR(20),
                LastName      VARCHAR(20),
                FullName      VARCHAR,
                ShortFullName VARCHAR) AS $$
BEGIN
  IF authorId IS NULL
  THEN
    RETURN QUERY
    SELECT *
    FROM "Author";
  ELSE RETURN QUERY SELECT *
                    FROM "Author"
                    WHERE "Author".ID = authorId;
  END IF;
END;
$$ LANGUAGE 'plpgsql';
