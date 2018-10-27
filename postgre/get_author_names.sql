CREATE OR REPLACE FUNCTION GetAuthorFullName(firstName IN VARCHAR, middleName IN VARCHAR,
                                              lastName IN VARCHAR)
  RETURNS VARCHAR AS $$
BEGIN
  RETURN FirstName || ' ' || MiddleName || ' ' || LastName;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION GetAuthorShortName(firstName IN VARCHAR, middleName IN VARCHAR,
                                              lastName IN VARCHAR)
  RETURNS VARCHAR AS $$
BEGIN
  RETURN SUBSTR(FirstName, 1, 1) || '. ' || SUBSTR(MiddleName, 1, 1) || '. ' || LastName;
END;
$$ LANGUAGE 'plpgsql';