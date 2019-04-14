SELECT *
  FROM ap_checks_all apc, ap_suppliers sup
 WHERE 1 = 1
   AND apc.vendor_id = sup.vendor_id
   AND apc.check_number = '165'
   AND apc.org_id = 81
   AND sup.VENDOR_NAME = '上海励成营养产品科技股份有限公司'
