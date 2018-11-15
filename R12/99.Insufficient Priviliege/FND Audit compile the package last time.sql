rem -----------------------------------------------------------------------
rem Filename:   auditdll.sql
rem Purpose:    Maintain an audit log of DDL changes (alter/ drop/ create)
rem             within a schema
rem Date:       15-Feb-2002
rem Author:     Frank Naude, Oracle FAQ
rem -----------------------------------------------------------------------

DROP TRIGGER audit_ddl_changes
/
DROP TABLE   dll_audit_log
/

CREATE TABLE dll_audit_log (
   stamp     DATE,
   username  VARCHAR2(30),
   osuser    VARCHAR2(30),
   machine   VARCHAR2(30),
   terminal  VARCHAR2(30),
   operation VARCHAR2(30),
   objtype   VARCHAR2(30),
   objname   VARCHAR2(30))
/

CREATE OR REPLACE TRIGGER audit_ddl_changes
   AFTER create OR drop OR alter
      ON scott.SCHEMA  -- Change SCOTT to your schema name!!!
      -- ON DATABASE
BEGIN
  INSERT INTO dll_audit_log VALUES
        (SYSDATE,
         SYS_CONTEXT('USERENV', 'SESSION_USER'),
         SYS_CONTEXT('USERENV', 'OS_USER'),
         SYS_CONTEXT('USERENV', 'HOST'),
         SYS_CONTEXT('USERENV', 'TERMINAL'),
         ORA_SYSEVENT,
         ORA_DICT_OBJ_TYPE,
         ORA_DICT_OBJ_NAME
        );
END;
/
show errors


-- Now, let's test it
CREATE TABLE my_test_table (col1 DATE)
/
DROP TABLE my_test_table
/
set pages 50000
SELECT * FROM dll_audit_log
/
