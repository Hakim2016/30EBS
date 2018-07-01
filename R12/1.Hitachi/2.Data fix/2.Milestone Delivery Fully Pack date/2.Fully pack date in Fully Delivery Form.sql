--DATA 1
SELECT t.fully_packing_date, t.*
  FROM xxinv_mfg_full_packing_sts t
 WHERE t.mfg_number IN ('JED0210-VN', 'JED0211-VN', 'JED0212-VN', 'JED0219-VN', 'JED0220-VN', 'JED0225-VN') --FOR UPDATE
 AND t.org_id = 101
;

--DATA2
SELECT t.fully_packing_date, t.*
  FROM xxinv_mfg_full_packing_sts t
 WHERE t.mfg_number IN ('JFA0245-VN','JFA0246-VN','JFA0247-VN','JFA0248-VN','JFA0249-VN','JFA0250-VN','JFA0251-VN','JFA0252-VN')
 AND t.org_id = 101
;
