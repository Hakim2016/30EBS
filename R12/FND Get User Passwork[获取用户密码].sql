SELECT xxfnd_fnd_web_sec.decrypt('APPS', fu.encrypted_user_password),
       fu.*
  FROM fnd_user fu
 WHERE fu.user_name = '70236270' --'70265069'--'71364171'--'70610664'--'HAND_HKM'--'70271678'

;

/* 
CREATE OR REPLACE PACKAGE xxfnd_fnd_web_sec AUTHID CURRENT_USER AS
  --Jianhua.Huang 2005.10.14
  FUNCTION encrypt(key IN VARCHAR2, VALUE IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION decrypt(key IN VARCHAR2, VALUE IN VARCHAR2) RETURN VARCHAR2;
END;


CREATE OR REPLACE PACKAGE BODY xxfnd_fnd_web_sec AS

  FUNCTION encrypt(key IN VARCHAR2, VALUE IN VARCHAR2) RETURN VARCHAR2 AS
    LANGUAGE JAVA NAME 'oracle.apps.fnd.security.WebSessionManagerProc.encrypt(java.lang.String,java.lang.String) return java.lang.String';

  FUNCTION decrypt(key IN VARCHAR2, VALUE IN VARCHAR2) RETURN VARCHAR2 AS
    LANGUAGE JAVA NAME 'oracle.apps.fnd.security.WebSessionManagerProc.decrypt(java.lang.String,java.lang.String) return java.lang.String';

END;
*/

SELECT *
  FROM fnd_objects fo
 WHERE 1 = 1
   AND fo.obj_name LIKE upper('xxfnd_fnd_web_sec');
