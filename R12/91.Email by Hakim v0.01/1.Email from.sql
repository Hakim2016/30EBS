    --CURSOR cur_from_sender IS
      SELECT MAX(decode(lkp.lookup_code,
                        'OUTBOUND_SERVER_NAME',
                        lkp.meaning)),
             MAX(decode(lkp.lookup_code, 'REPLY_TO', lkp.meaning))
        FROM xxfnd_lookups lkp
       WHERE lkp.lookup_type = 'XXFND_WF_MAILER_PARAMETER'
         AND lkp.enabled_flag = 'Y'
         AND SYSDATE >= nvl(lkp.start_date_active, trunc(SYSDATE))
         AND SYSDATE < nvl(lkp.end_date_active, trunc(SYSDATE) + 1);
         
/*
XXX.XXX.71.231       prodgscmadmin@XXXXX.com
*/
