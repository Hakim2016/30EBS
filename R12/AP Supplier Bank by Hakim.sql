SELECT *
  FROM iby_ext_bank_accounts_v v
 WHERE 1 = 1
 AND v.country_code = 'CN'
 ORDER BY v.ext_bank_account_id DESC
