CREATE OR REPLACE FUNCTION GetAuthorFullName(firstName IN VARCHAR, middleName IN VARCHAR,
                                              lastName IN VARCHAR)
  RETURN VARCHAR AS
  BEGIN
    RETURN FirstName || ' ' || MiddleName || ' ' || LastName;
  END;
/

CREATE OR REPLACE FUNCTION GetAuthorShortName(firstName IN VARCHAR, middleName IN VARCHAR,
                                              lastName IN VARCHAR)
  RETURN VARCHAR AS
  BEGIN
    RETURN SUBSTR(FirstName, 0, 1) || '. ' || SUBSTR(MiddleName, 0, 1) || '. ' || LastName;
  END;
/