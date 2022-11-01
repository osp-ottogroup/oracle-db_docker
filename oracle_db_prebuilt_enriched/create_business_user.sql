-- Create user for Panorama-Test if they don't already exists
-- Peter Ramm, OSP Dresden 28.11.2018

DECLARE
  Dummy     NUMBER;
  v_UserName  VARCHAR2(30);
  PDB_Name  VARCHAR2(30);
  Is_PDB    NUMBER;

  PROCEDURE Create_User(p_UserName VARCHAR2) IS
  BEGIN
    SELECT COUNT(*) INTO Dummy FROM All_Users WHERE UserName = p_UserName;
    IF Dummy = 0 THEN                                                             -- User does not exists
      EXECUTE IMMEDIATE 'create user '||p_UserName||' identified by '||p_UserName||' default tablespace sysaux temporary tablespace temp';

      EXECUTE IMMEDIATE 'grant connect, resource to '||p_UserName;
      EXECUTE IMMEDIATE 'GRANT CREATE VIEW TO '||p_UserName;
      EXECUTE IMMEDIATE 'alter profile DEFAULT limit password_life_time UNLIMITED';
      EXECUTE IMMEDIATE 'ALTER USER '||p_UserName||' quota unlimited on sysaux';
    END IF;
  END;

BEGIN
  Is_PDB := 0;                                                                  -- is not a PDB
  BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) from v$pdbs' INTO Dummy;
    IF Dummy > 0 THEN
      Is_PDB := 1;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;

  IF Is_PDB =0 THEN
    Create_User('BUSINESS');
  ELSE
    -- Assuming there is only one user container
    SELECT Name INTO PDB_Name FROM v$Containers WHERE Name NOT IN ('CDB$ROOT', 'PDB$SEED');
    EXECUTE IMMEDIATE 'ALTER SESSION SET container = '||PDB_Name;
    Create_User('BUSINESS');
  END IF;

END;
/