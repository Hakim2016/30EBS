SELECT path_name,att_value, jdr_mds_internal.getDocumentName(path_docid)
  FROM jdr_paths, jdr_attributes
 WHERE path_docid = att_comp_docid
   AND att_comp_seq = 0
   AND att_name = 'customizes'
   and jdr_mds_internal.getDocumentName(path_docid) like '%1495%';
   
   
   /oracle/apps/fnd/wf/worklist/webui/customizations/user/1495/AdvancWorklistPG
