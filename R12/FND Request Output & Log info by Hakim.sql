--ģ���������
SELECT fnd_webfile.get_url(4, --�������
                           15460236, --����ID
                           'APPLSYSPUB/PUB',
                           'FCWW',
                           10)
  FROM dual;
/*
ֱ�Ӹ�����ID������
��һ������4��ʾrequest��output,���ɸ�����Ҫ������
 Define file types for get_url
 process_log constant number := 1;
 icm_log constant number := 2;
 request_log constant number := 3;        --log��־���
 request_out constant number := 4;        --�������
 request_mgr constant number := 5;
 frd_log constant number := 6;
 generic_log constant number := 7;
 generic_trc constant number := 8;
 generic_ora constant number := 9;
 generic_cfg constant number := 10;
 context_file constant number := 11;
 generic_text constant number := 12;
 generic_binary constant number := 13;
 request_xml_output constant number :=14;    --XML���
 */

--����Output��Log��ŵ�·����ѯ
SELECT t.logfile_name,
       t.outfile_name,
       t.output_file_type --change Output_file_type to 'PS'
       ,t.*
  FROM fnd_concurrent_requests t
 WHERE t.request_id = 15487352--16148068--8882937
   --FOR UPDATE --8882937--27115382 --����ID 8875565
;
