--IF42
SELECT * FROM XXOM_MK_SITE_CODE_INTF intf
WHERE 1=1
AND intf.creation_date > TRUNC(SYSDATE)
