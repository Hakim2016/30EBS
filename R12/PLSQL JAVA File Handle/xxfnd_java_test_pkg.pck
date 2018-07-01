CREATE OR REPLACE PACKAGE xxfnd_java_test_pkg IS

  FUNCTION getlistfiles(path    IN VARCHAR2,
                        suffix  IN VARCHAR2,
                        isdepth IN VARCHAR2,
                        splitby IN VARCHAR2) RETURN VARCHAR2 AS
    LANGUAGE JAVA NAME 'FileViewer20140708.getListFiles( java.lang.String, java.lang.String, java.lang.String, java.lang.String) return java.lang.String';

END xxfnd_java_test_pkg;
/
CREATE OR REPLACE PACKAGE BODY xxfnd_java_test_pkg IS


END xxfnd_java_test_pkg;
/
