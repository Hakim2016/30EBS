SELECT *
  FROM APPS.AP_SUPPLIERS ASP
 WHERE 1 = 1
   AND ASP.SEGMENT1 = 'MDM_106271088';

SELECT IBYBANKS.BANK_PARTY_ID,
       IBYBANKS.BANK_NUMBER,
       IBYBANKS.BANK_NAME,
       IBYBANKS.BRANCH_PARTY_ID,
       IBYBANKS.BRANCH_NUMBER,
       IBYBANKS.BANK_BRANCH_NAME,
       IBYBANKS.BANK_ACCOUNT_ID,
       IBYBANKS.BANK_ACCOUNT_NUMBER,
       IBYBANKS.BANK_ACCOUNT_NAME,
       IBYBANKS.PRIMARY_ACCT_OWNER_NAME,
       IBYBANKS.BANK_ACCOUNT_NUM_ELECTRONIC,
       IBYBANKS.*
  FROM APPS.IBY_EXT_BANK_ACCOUNTS_V IBYBANKS
 WHERE 1 = 1
   AND IBYBANKS.BANK_NAME = '上海浦东发展银行';

/*
1 银行账户表：ap_bank_accounts_all
  分行（支行）表：ap_bank_branches
  在新增银行账户时要选择对应的支行
2 供应商地点和银行账户对应关系表是：
  ap_bank_account_uses_all  
  ap_bank_account_uses_all中的
  vendor_site_id
  
  和external_bank_account_id
  
  
  分别对应供应商地点表
  po_vendor_sites_all中的
  vendor_site_id和
  ap_bank_accounts_all中
  bank_account_id
3 供应商的银行账户不要维护科目组合（应该是地点中存在的ccid关联到了科目组合）
--------------------- 
作者：花椰菜1110 
来源：CSDN 
原文：https://blog.csdn.net/ruihua1021/article/details/41115877 
版权声明：本文为博主原创文章，转载请附上博文链接！

*/
