/*alter session set nls_language='AMERICAN';*/
SELECT DISTINCT pv.segment1             supplier_num,
                pv.VENDOR_NAME          supplier_name,
                ipm.PAYMENT_METHOD_NAME
  FROM HZ_PARTIES              hp,
       po_vendors              pv,
       IBY_EXTERNAL_PAYEES_ALL iepa,
       IBY_PAYMENT_METHODS_VL  ipm,
       IBY_EXT_PARTY_PMT_MTHDS iepp
 WHERE 1 = 1
   AND hp.party_id = pv.PARTY_ID
   AND iepa.PAYEE_PARTY_ID = hp.party_id
   AND ipm.payment_method_code = iepp.payment_method_code(+)
   AND iepp.Payment_flow = 'DISBURSEMENTS'
   AND NVL(ipm.inactive_date, trunc(SYSDATE + 1)) > trunc(SYSDATE)
   AND iepp.EXT_PMT_PARTY_ID = iepa.ext_payee_id

 ORDER BY pv.segment1;


/*alter session set nls_language='AMERICAN';*/
SELECT DISTINCT pv.segment1 supplier_num,
                pv.VENDOR_NAME supplier_name,
                (SELECT ipm.payment_method_name
                   FROM IBY_PAYMENT_METHODS_VL ipm
                  WHERE ipm.PAYMENT_METHOD_CODE = iepp.payment_method_code) PAYMENT_METHOD
  FROM HZ_PARTIES              hp,
       po_vendors              pv,
       IBY_EXTERNAL_PAYEES_ALL iepa,
       IBY_PAYMENT_METHODS_VL  ipm,
       IBY_EXT_PARTY_PMT_MTHDS iepp
 WHERE 1 = 1
   AND hp.party_id = pv.PARTY_ID
   AND iepa.PAYEE_PARTY_ID = hp.party_id
   AND (iepp.Payment_flow = 'DISBURSEMENTS' OR iepp.Payment_flow IS NULL)
   AND NVL(ipm.inactive_date, trunc(SYSDATE + 1)) > trunc(SYSDATE)
   AND iepp.EXT_PMT_PARTY_ID(+) = iepa.ext_payee_id
   --AND pv.segment1 = 'HL00000003' --'FB00003722'--'FB00003016'
   AND (iepp.primary_flag = 'Y' OR iepp.primary_flag IS NULL)
   AND iepa.org_id IS NULL
   --AND pv.ATTRIBUTE_CATEGORY = 'HEA Ledger'
AND    pv.segment1 LIKE 'FB%'
 ORDER BY pv.segment1;
