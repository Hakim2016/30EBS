SELECT gjh.ledger_id,
       gjh.period_name 期间,
       gjh.je_category, --1 手工凭证
       gjh.je_source,
       gjh.doc_sequence_id,
       (SELECT DISTINCT fds.name
          FROM fnd_document_sequences fds
         WHERE 1 = 1
           AND fds.doc_sequence_id = gjh.doc_sequence_id) seq_name,
       (SELECT DISTINCT fds.initial_value
          FROM fnd_document_sequences fds
         WHERE 1 = 1
           AND fds.doc_sequence_id = gjh.doc_sequence_id) initial_value,
       gjh.doc_sequence_value 凭证编号,
       gjh.posting_acct_seq_value 过账凭证 /*,
       gjh.**/
  FROM apps.gl_je_headers_v gjh

 WHERE 1 = 1
   AND gjh.default_effective_date >= to_date('2018-09-01', 'yyyy-mm-dd')
   AND gjh.default_effective_date <=
       to_date('2018-09-30', 'yyyy-mm-dd') + 0.99999
   AND gjh.ledger_id = 2021
 ORDER BY /*gjh.doc_sequence_value*/ gjh.posting_acct_seq_value ASC;

--排序上下文
--有几个OU环境
SELECT fsc.name, fsc.obsolete_flag, fsc.*
  FROM fun_seq_contexts fsc
--WHERE fsc.name = --'cfb01' --分配
;

--FUN_SEQ_HEADERS FunSeqHeaders -- 会计序列表序列
SELECT *
  FROM fun_seq_headers fsh
 WHERE 1 = 1
   AND fsh.header_name LIKE '101%';

--分配序号 与子分类账（日记账来源）关联
SELECT fsh.header_name,fsa.JOURNAL_SOURCE, fsa.JOURNAL_CATEGORY, fsh.*,fsa.*
  FROM fun_seq_headers fsh,fun_seq_assignments fsa
 WHERE 1 = 1
   AND fsa.seq_header_id = fsh.seq_header_id
   AND fsh.header_name LIKE '101%1809%'
   ORDER BY fsh.seq_header_id
   ;
