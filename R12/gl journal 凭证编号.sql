SELECT gjh.ledger_id,
       gjh.period_name �ڼ�,
       gjh.je_category, --1 �ֹ�ƾ֤
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
       gjh.doc_sequence_value ƾ֤���,
       gjh.posting_acct_seq_value ����ƾ֤ /*,
       gjh.**/
  FROM apps.gl_je_headers_v gjh

 WHERE 1 = 1
   AND gjh.default_effective_date >= to_date('2018-09-01', 'yyyy-mm-dd')
   AND gjh.default_effective_date <=
       to_date('2018-09-30', 'yyyy-mm-dd') + 0.99999
   AND gjh.ledger_id = 2021
 ORDER BY /*gjh.doc_sequence_value*/ gjh.posting_acct_seq_value ASC;

--����������
--�м���OU����
SELECT fsc.name, fsc.obsolete_flag, fsc.*
  FROM fun_seq_contexts fsc
--WHERE fsc.name = --'cfb01' --����
;

--FUN_SEQ_HEADERS FunSeqHeaders -- ������б�����
SELECT *
  FROM fun_seq_headers fsh
 WHERE 1 = 1
   AND fsh.header_name LIKE '101%';

--������� ���ӷ����ˣ��ռ�����Դ������
SELECT fsh.header_name,fsa.JOURNAL_SOURCE, fsa.JOURNAL_CATEGORY, fsh.*,fsa.*
  FROM fun_seq_headers fsh,fun_seq_assignments fsa
 WHERE 1 = 1
   AND fsa.seq_header_id = fsh.seq_header_id
   AND fsh.header_name LIKE '101%1809%'
   ORDER BY fsh.seq_header_id
   ;
