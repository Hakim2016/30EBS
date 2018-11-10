/*
refer to SDP#12782
Oracle BI Discover Viewer cannot find the data necessary to display the results of this event. Correct any errors and try again.
这个报错是Discoverer 没有赋权给对应的职责：
登录：http://gscmpsvapt01.gscmt.buil.hitachi.co.jp:8888/discoverer/plus
账号：sysadmin （如果sysadmin找不到这个工作簿，那么这个工作簿所有者不是sysadmin,需要技术更新后台表，
将所有者调整成 sysadmin  < UPDATE xxdis_us.eul5_documents d SET d.doc_eu_id = 100018 WHERE xxx>）

*/

SELECT d.doc_name       AS "Workbook Name",
       u.eu_username    AS "Workbook current Owner",
       fu.user_name,
       doc_created_date,
       doc_updated_by,
       doc_updated_date
  FROM xxdis_us.eul5_eul_users u, xxdis_us.eul5_documents d, fnd_user fu
 WHERE d.doc_eu_id = u.eu_id
   AND u.eu_username = '#' || fu.user_id
   AND d.doc_name = 'XXPO_SUMMARY_REPORT_COMPLETE_CHALISA';

UPDATE xxdis_us.eul5_documents d
   SET d.doc_eu_id = 100018
 WHERE d.doc_created_by = '#1478' FOR UPDATE;

SELECT eul5_documents.doc_name,
       doc_created_by,
       nvl(eul5_eul_users.eu_username, 'Document Not Shared') shared_with,
       (SELECT frv.RESPONSIBILITY_NAME
          FROM fnd_responsibility_vl frv
         WHERE '#' || frv.RESPONSIBILITY_ID || '#' || frv.APPLICATION_ID =
               nvl(eul5_eul_users.eu_username, 'Document Not Shared')) RESPONSIBILITY_NAME
  FROM xxdis_us.eul5_access_privs,
       xxdis_us.eul5_documents,
       xxdis_us.eul5_eul_users
 WHERE (eul5_documents.doc_id = eul5_access_privs.gd_doc_id(+))
   AND (eul5_eul_users.eu_id(+) = eul5_access_privs.ap_eu_id)
      /*  AND doc_created_by like 'USER_NAME'*/
      
   AND (SELECT frv.RESPONSIBILITY_NAME
          FROM fnd_responsibility_vl frv
         WHERE '#' || frv.RESPONSIBILITY_ID || '#' || frv.APPLICATION_ID =
               nvl(eul5_eul_users.eu_username, 'Document Not Shared')) LIKE
       'HEA PA U%'
/*and eul5_documents.doc_name =
'XXGL: ACCOUNTS BALANCES WITH TRANSACTIONS'*/
;

SELECT * FROM xxdis_us.eul5_access_privs;
SELECT * FROM xxdis_us.eul5_eul_users;
SELECT *
  FROM xxdis_us.eul5_documents d
 WHERE d.doc_eu_id=268300;
 
 
 UPDATE xxdis_us.eul5_documents d
   SET d.doc_eu_id = 100018
 WHERE d.doc_created_by = '#1582' FOR UPDATE;
 
 
 SELECT *
  FROM xxdis_us.eul5_documents d where d.doc_developer_key like 'XXWIP%';
