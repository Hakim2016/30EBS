/*
SELECT t.responsibility_id,
       tl.responsibility_name,
       tl.language,
       t.*
  FROM fnd_responsibility    t,
       fnd_responsibility_tl tl
 WHERE 1 = 1
   AND t.responsibility_id = tl.responsibility_id
   AND tl.language = 'US'
      --AND t.responsibility_key LIKE --'%HBS%SCM_SUPER_USER%'
      --'COST%MANAGEMENT%'
   AND tl.responsibility_name LIKE 'Cost Management%SLA';
--resp_id = 50263
--app_id = 707
--HEA SCM SUPER USER

SELECT *
  FROM fnd_user fu
 WHERE fu.user_name = 'HAND_HKM';
--org_id      Resp_id     Resp_app_id        Organization_id
--HBS 101     51249       660                HB1  121
--HEA 82      50676       660                SG1  83
--HET 141     51272       20005              HE1  161
--SHE 84      50778       20005              TH1  85  TH2 86

SELECT *
  FROM fnd_application xx
 WHERE 1 = 1
   AND xx.application_id = 707;

BEGIN
  fnd_global.apps_initialize(user_id => 4270, resp_id => 50676, resp_appl_id => 660);
  mo_global.init('M');
  --FND_PROFILE.PUT('MFG_ORGANIZATION_ID', 86);

END;
*/
DECLARE
  l_result     BOOLEAN;
  l_request_id NUMBER;
  l_exit       BOOLEAN;
BEGIN
  fnd_global.apps_initialize(user_id => 4270, resp_id => 50263, resp_appl_id => 707);
  mo_global.init('M');
  /*
  template_appl_name in varchar2,
        template_code     in varchar2,
        template_language in varchar2,
        template_territory in varchar2,
        output_format     in varchar2,
              nls_language      in varchar2 default null) return boolean is
   
    */

  l_result := fnd_request.add_layout(template_appl_name => 'BOM',
                                     template_code      => 'CSTCRACC',
                                     template_language  => 'en',
                                     template_territory => 'US',
                                     output_format      => 'XML' --'PDF'
                                     
                                     );
  IF l_result THEN
  
    dbms_output.put_line('success in add layout');
  
  END IF;
  /*
  
          application IN varchar2 default NULL,
        program     IN varchar2 default NULL,
        description IN varchar2 default NULL,
        start_time  IN varchar2 default NULL,
        sub_request IN boolean  default FALSE,
        argument1   IN varchar2 default CHR(0),
        argument2   IN varchar2 default CHR(0),
          argument3   IN varchar2 default CHR(0),
        argument4   IN varchar2 default CHR(0),
        argument5   IN varchar2 default CHR(0),
        argument6   IN varchar2 default CHR(0),
        argument7   IN varchar2 default CHR(0),
  */
  --707, 707, Y, 2021, , 2018/03/31 00:00:00, Y, Y, F, Y, N, D, Y, Y, Y, , , N, , , Cost Management, Cost Management, HEA Ledger, , Yes, Final, No, Detail, Yes, Yes, No, , 83, , , , , , , N, No,
  l_request_id := fnd_request.submit_request(application => 'CST',
                                             program     => 'CSTCRACC',
                                             start_time  => SYSDATE,
                                             sub_request => FALSE,
                                             /*argument1   => xxfnd_interface_transaction_s.nextval,
                                                                                                                                                                                                                                                                              argument2   => SYSDATE,
                                                                                                                                                                                                                                                                              argument3   => 'HEA Ledger'*/
                                             argument1  => 707,
                                             argument2  => 707,
                                             argument3  => 'Y',
                                             argument4  => 2021,
                                             argument5  => '',
                                             argument6  => '2018/3/31  00:00:00',
                                             argument7  => 'Y',
                                             argument8  => 'Y',
                                             argument9  => 'F',
                                             argument10 => 'Y',
                                             argument11 => 'N',
                                             argument12 => 'D',
                                             argument13 => 'Y',
                                             argument14 => 'Y',
                                             argument15 => 'Y',
                                             argument16 => '',
                                             argument17 => '',
                                             argument18 => 'N',
                                             argument19 => '',
                                             argument20 => '',
                                             argument21 => 'Cost Management',
                                             argument22 => 'Cost Management',
                                             argument23 => 'HEA Ledger',
                                             argument24 => '',
                                             argument25 => 'Yes',
                                             argument26 => 'Final',
                                             argument27 => 'No',
                                             argument28 => 'Detail',
                                             argument29 => 'Yes',
                                             argument30 => 'Yes',
                                             argument31 => 'No',
                                             argument32 => '',
                                             argument33 => 83,
                                             argument34 => '',
                                             argument35 => '',
                                             argument36 => '',
                                             argument37 => '',
                                             argument38 => '',
                                             argument39 => '',
                                             argument40 => 'N',
                                             argument41 => 'No',
                                             argument42 => ''
                                             ---
                                             --userenv('sessionid'),
                                             --chr(0)
                                             
                                             );

  IF l_request_id > 0 THEN
    --l_exit := app_form.quietcommit();
    dbms_output.put_line('The request id = ' || l_request_id);
  
  ELSE
    dbms_output.put_line('Fail to submit the request');
  
    --RAISE form_trigger_failure;
  END IF;
END;
