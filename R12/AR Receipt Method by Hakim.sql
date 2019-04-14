/*BEGIN
  fnd_global.apps_initialize(user_id      => 1014703,
                             resp_id      => 66729,
                             resp_appl_id => 660);
  mo_global.init('M');
  --FND_PROFILE.PUT('MFG_ORGANIZATION_ID', 86);
  
END;*/

SELECT cba.receipt_multi_currency_flag,
       cba.currency_code, --=
       decode(cba.receipt_multi_currency_flag,
              /*:22*/
              'Y',
              cba.currency_code,
              nvl( /*:23*/ 'CNY', cba.currency_code)) curr,
       
       rm.name,
       rm.receipt_method_id,
       substrb(arpt_sql_func_util.get_lookup_meaning( /*:1*/'RECEIPT_CREATION_STATUS',
                                                     rc.creation_status),
               1,
               80) meaning,
               cba.BANK_ACCOUNT_ID,
       ba.bank_acct_use_id "bank_account_id",
       substrb(ce_bank_and_account_util.get_masked_bank_acct_num(cba.bank_account_id),
               1,
               360) bank_account_num,
       bb.bank_name,
       bb.bank_branch_name,
       bb.branch_party_id "bank_branch_id",
       cba.currency_code,
       rc.creation_status,
       rc.name receipt_class_name,
       rc.remit_flag,
       rc.notes_receivable,
       substrb(nvl(rma.override_remit_account_flag, /*:2*/ 'Y'), 1, 1) override_flag,
       rc.creation_method_code,
       rm.payment_type_code,
       cba.receipt_multi_currency_flag receipt_multi_currency_flag,
       rma.org_id org_id,
       substrb(mo_global.get_ou_name(rma.org_id), 1, 360) operating_unit,
       decode(rma.org_id, /*:3*/ 7905, 0, 1) def,
       cba.account_owner_org_id legal_entity_id
  FROM ar_receipt_methods             rm,
       ar_receipt_classes             rc,
       ce_bank_accounts               cba,
       ce_bank_acct_uses_all          ba,
       ce_bank_branches_v             bb,
       ar_receipt_method_accounts_all rma,
       hr_operating_units             hr
 WHERE rm.receipt_class_id = rc.receipt_class_id
   AND rma.org_id = ba.org_id
   AND hr.organization_id = rma.org_id
   AND mo_global.check_access(hr.organization_id) = /*:4*/
       'Y'
      --AND rma.org_id = nvl(:5, rma.org_id)
      --AND (:6 BETWEEN rm.start_date AND nvl(rm.end_date, :7))
   AND ((rc.creation_method_code = /*:8*/
       'MANUAL') OR (rc.creation_method_code = /*:9*/
       'BR_REMIT') OR (rc.creation_method_code = /*:10*/
       'AUTOMATIC' AND rc.remit_flag = /*:11*/
       'Y' AND rc.confirm_flag = /*:12*/
       'N'))
   AND cba.account_classification = /*:13*/
       'INTERNAL'
      /*AND nvl(ba.end_date, to_date(:14) + 1) > :15
      AND nvl(cba.end_date, to_date(:16) + 1) > :17
         \*--Added for bug 13063219 *\ \* Bug 2392508 checking if the bank is 
           inactive*\
      AND nvl(bb.end_date, to_date(:18) + 1) > :19
      AND :20 BETWEEN rma.start_date AND nvl(rma.end_date, :21) */
      /*Bug 6531114 if currency is not 
      entered in the receipt form then all currencies receipt methods are 
      displayed */
      AND cba.currency_code =
      decode(cba.receipt_multi_currency_flag,
             /*:22*/'Y',
             cba.currency_code,
             nvl(/*:23*/'CNY', cba.currency_code))
   AND cba.bank_branch_id = bb.branch_party_id
   AND rm.receipt_method_id = rma.receipt_method_id
   AND rma.remit_bank_acct_use_id = ba.bank_acct_use_id
   AND cba.bank_account_id = ba.bank_account_id
   AND cba.ar_use_allowed_flag = /*:24*/
       'Y'
   AND nvl(ba.ar_use_enable_flag, 'N') = 'Y'
 ORDER BY def, rm.name, cba.bank_account_num, bb.bank_name, operating_unit /* 20-APR-2000 J 
  Rautiainen Created for BR Implementation */
;

SELECT 
cba.PAYMENT_MULTI_CURRENCY_FLAG
,cba.receipt_multi_currency_flag
,cba.*
  FROM ce_bank_accounts cba
 WHERE 1 = 1
   AND cba.bank_account_id IN (19009, 19008)
   
   ;
   
--update cba.receipt_multi_currency_flag from "N" to "Y" for these 2 records
UPDATE ce_bank_accounts cba
SET cba.receipt_multi_currency_flag = 'Y'
WHERE 1=1
AND cba.bank_account_id IN (19009, 19008)
;
