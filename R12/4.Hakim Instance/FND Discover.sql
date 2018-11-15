SELECT eul5_documents.doc_name,
       doc_created_by,
       nvl(eul5_eul_users.eu_username, 'Document Not Shared') shared_with,
       (select frv.RESPONSIBILITY_NAME
          from fnd_responsibility_vl frv
         where '#' || frv.RESPONSIBILITY_ID || '#' || frv.APPLICATION_ID =
               nvl(eul5_eul_users.eu_username, 'Document Not Shared')) RESPONSIBILITY_NAME
  FROM xxdis_us.eul5_access_privs,
       xxdis_us.eul5_documents,
       xxdis_us.eul5_eul_users
 WHERE (eul5_documents.doc_id = eul5_access_privs.gd_doc_id(+))
   AND (eul5_eul_users.eu_id(+) = eul5_access_privs.ap_eu_id)
