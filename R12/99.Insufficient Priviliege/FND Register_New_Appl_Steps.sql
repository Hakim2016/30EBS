-- create folder tree
cd $APPL_TOP
mkdir xxeng
cd xxeng
mkdir 12.0.0
cd 12.0.0
mkdir admin
mkdir bin
mkdir forms
mkdir java
mkdir lib
mkdir log
mkdir mesg
mkdir out
mkdir plsql
mkdir resource
mkdir sql
cd forms
mkdir US
cd ..
cd reports
mkdir US


-- create database user
CREATE USER xxeng IDENTIFIED BY xxeng;
ALTER USER xxeng DEFAULT TABLESPACE ADDON_TS_TX_DATA;
ALTER USER xxeng TEMPORARY TABLESPACE TEMP;

-- grant privilege
SELECT t.privilege,
       'grant ' || t.privilege || ' to xxeng;'
  FROM dba_sys_privs t
 WHERE 1 = 1
   AND t.grantee = 'XXINV'
UNION
SELECT 'RESOURCE',
       'grant RESOURCE to xxeng'
  FROM dual;
  
-- build environment avaible
-- UPDATE .xml FILE IN $INST_TOP/appl/admin/
ADD a ROW :
    <XXENG_TOP oa_var="s_xxengtop" oa_type="PROD_TOP" oa_enabled="FALSE">/u01/UAT/apps/apps_st/appl/xxeng/12.0.0</XXENG_TOP>
-- running environment 
run script FILE IN $APPL_TOP    .$APPL_TOP/VIS_syfdemo.env

-- restart appl server
run script FILE IN $INST_TOP/ADMIN/scripts
CLOSE appl server : sh adstpall.sh apps/apps
START appl server : sh adstrtal.sh apps/apps

-- Application register  Application Developer -> Application -> Register
-- Oracle user register  System Administrator -> Security -> ORACLE -> Register
-- Data Groups register  System Administrator -> security -> ORACLE -> DataGroup
-- 
