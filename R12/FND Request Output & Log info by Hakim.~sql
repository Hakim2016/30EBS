--模拟请求输出
SELECT fnd_webfile.get_url(4, --输出类型
                           16003938, --请求ID
                           'APPLSYSPUB/PUB',
                           'FCWW',
                           10)
  FROM dual;
/*
直接改请求ID就行了
第一个参数4表示request的output,（可根据需要决定）
 Define file types for get_url
 process_log constant number := 1;
 icm_log constant number := 2;
 request_log constant number := 3;        --log日志输出
 request_out constant number := 4;        --报表输出
 request_mgr constant number := 5;
 frd_log constant number := 6;
 generic_log constant number := 7;
 generic_trc constant number := 8;
 generic_ora constant number := 9;
 generic_cfg constant number := 10;
 context_file constant number := 11;
 generic_text constant number := 12;
 generic_binary constant number := 13;
 request_xml_output constant number :=14;    --XML输出
 */

--请求Output和Log存放的路径查询
SELECT t.logfile_name,
       t.outfile_name,
       t.output_file_type --change Output_file_type to 'PS'
  FROM fnd_concurrent_requests t
 WHERE t.request_id = 16148068--8882937
   --FOR UPDATE --8882937--27115382 --请求ID 8875565
;
