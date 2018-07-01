    --l_email_lookup_type VARCHAR2(40) := 'XXWIP_PULL_ITEM_ONHAND_MAIL';
    --CURSOR cur_to_receiver IS
      SELECT emadd.lookup_code, emadd.meaning, emadd.description
        FROM fnd_lookup_values_vl emadd
       WHERE emadd.lookup_type = 'XXWIP_PULL_ITEM_ONHAND_MAIL'--l_email_lookup_type
         AND emadd.enabled_flag = 'Y'
         AND trunc(SYSDATE) BETWEEN
             nvl(emadd.start_date_active, trunc(SYSDATE)) AND
             nvl(emadd.end_date_active, trunc(SYSDATE))
       ORDER BY emadd.lookup_code;
/*

LOOKUP_CODE	MEANING	DESCRIPTION
001	001	huasheng.ding@itg.hitachi.cn
002	002	chaochao.shi@itg.hitachi.cn
003	003	bingyan.wang@itg.hitachi.cn

*/
