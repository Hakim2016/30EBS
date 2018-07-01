SELECT xdt.application_id,
       xdt.event_class,
       xdt.document_type,
       xdt.*
--INTO l_document_type
  FROM xxgl_hfs_document_types xdt
 WHERE xdt.ledger_id = 2023 --p_ledger_id
      -- AND xdt.application_id = p_application_id
      -- AND xdt.event_class = p_event_class
      --AND xdt.document_type = 'KR'
   AND nvl(xdt.inactive_date, trunc(SYSDATE) + 1) > trunc(SYSDATE);
