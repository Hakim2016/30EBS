/*
XML File Structure:

<PackingList>
  <case>
    <Plant_Code>HEES</Plant_Code> 
    <Mfg_no>XM2203</Mfg_no> 
    <case_no>A1</case_no> 
    <status>G</status> 
    <Outsource>N</Outsource> 
    <Outsource_to>HEES</Outsource_to> 
    <Modified_by>XXCHEN</Modified_by> 
    <Modified_date>2012-10-12T12:30:03.8670000+08:00</Modified_date> 
    <file_name>XM2203201210171228.xml</file_name> 
    <import_count>2</import_count> 
    <Created_by>XXCHEN</Created_by> 
    <Created_date>2012-10-12T11:52:03.5900000+08:00</Created_date> 
  </case>
  <case>
    <Plant_Code>HEES</Plant_Code> 
    <Mfg_no>XM2203</Mfg_no> 
    <case_no>A10</case_no> 
    <status>G</status> 
    <Outsource>N</Outsource> 
    <Outsource_to>HEES</Outsource_to> 
    <Modified_by>XXCHEN</Modified_by> 
    <Modified_date>2012-10-17T09:34:31.2300000+08:00</Modified_date> 
    <file_name>XM2203201210171228.xml</file_name> 
    <Tag_Mfg_no>NULL</Tag_Mfg_no> 
    <Tag_case_no>NULL</Tag_case_no> 
    <Created_by>EPS_spUpdateCase</Created_by> 
    <Created_date>2012-10-17T09:34:31.1070000+08:00</Created_date> 
  </case>
</PackingList>
*/


DECLARE
  l_file_id   NUMBER := 375434;
  l_file_data fnd_lobs.file_data%TYPE;

  l_data_clob    CLOB;
  l_dest_offset  INTEGER := 1;
  l_src_offset   INTEGER := 1;
  l_lang_context INTEGER := dbms_lob.default_lang_ctx;
  l_cvt_warning  INTEGER;

  l_row_number NUMBER;
BEGIN
  SELECT fl.file_data
    INTO l_file_data
    FROM fnd_lobs fl
   WHERE fl.file_id = l_file_id;

  --Convert to CLOB
  dbms_lob.createtemporary(l_data_clob, TRUE, 2);
  dbms_lob.converttoclob(l_data_clob,
                         l_file_data,
                         dbms_lob.lobmaxsize,
                         l_dest_offset,
                         l_src_offset,
                         dbms_lob.default_csid,
                         l_lang_context,
                         l_cvt_warning);
  l_row_number := 0;
  FOR rec IN (SELECT xt.plant_code,
                      xt.mfg_no,
                      xt.case_no,
                      xt.status,
                      xt.net_weight,
                      xt.gross_weight,
                      xt.ext_dimension,
                      xt.int_dimension,
                      xt.volume,
                      xt.outsource,
                      xt.outsource_to,
                      xt.eps_modified_by,
                      xt.eps_modified_date,
                      xt.file_name,
                      xt.eps_created_by,
                      xt.eps_created_date
                 FROM xmltable('for $root in $date
     return $root/PackingList/case' passing xmltype(l_data_clob) AS "date" columns
                               plant_code VARCHAR2(30) path '/case/Plant_Code',
                               mfg_no VARCHAR2(30) path '/case/Mfg_no',
                               case_no VARCHAR2(30) path '/case/case_no',
                               status VARCHAR2(10) path '/case/status',
                               net_weight VARCHAR2(30) path '/case/Net_weight',
                               gross_weight VARCHAR2(30) path '/case/gross_weight',
                               ext_dimension VARCHAR2(30) path '/case/ext_dimension',
                               int_dimension VARCHAR2(30) path '/case/Int_Dimension',
                               volume VARCHAR2(30) path '/case/Volume',
                               outsource VARCHAR2(10) path '/case/Outsource',
                               outsource_to VARCHAR2(30) path '/case/Outsource_to',
                               eps_modified_by VARCHAR2(30) path '/case/Modified_by',
                               eps_modified_date VARCHAR2(50) path '/case/Modified_date',
                               file_name VARCHAR2(30) path '/case/file_name',
                               eps_created_by VARCHAR2(30) path '/case/Created_by',
                               eps_created_date VARCHAR2(50) path '/case/Created_date') xt)
  LOOP
    l_row_number := l_row_number + 1;
    --EXIT WHEN l_row_number = 11;
    dbms_output.put_line(rec.case_no);
  END LOOP;
dbms_output.put_line(l_row_number);
END;

-- /////////////////////////////////////////////////////////////////////////////////////////////


DECLARE

  l_row_number NUMBER;
BEGIN

  l_row_number := 0;
  FOR rec IN (SELECT xt.plant_code,
                     xt.mfg_no,
                     xt.case_no,
                     xt.status,
                     xt.net_weight,
                     xt.gross_weight,
                     xt.ext_dimension,
                     xt.int_dimension,
                     xt.volume,
                     xt.outsource,
                     xt.outsource_to,
                     xt.eps_modified_by,
                     xt.eps_modified_date,
                     xt.file_name,
                     xt.eps_created_by,
                     xt.eps_created_date
                FROM xmltable('for $root in $date
     return $root/PackingList/case' passing xmltype('<PackingList>
  <case>
    <Plant_Code>HEES</Plant_Code> 
    <Mfg_no>XM2203</Mfg_no> 
    <case_no>A1</case_no> 
    <status>G</status> 
    <Outsource>N</Outsource> 
    <Outsource_to>HEES</Outsource_to> 
    <Modified_by>XXCHEN</Modified_by> 
    <Modified_date>2012-10-12T12:30:03.8670000+08:00</Modified_date> 
    <file_name>XM2203201210171228.xml</file_name> 
    <import_count>2</import_count> 
    <Created_by>XXCHEN</Created_by> 
    <Created_date>2012-10-12T11:52:03.5900000+08:00</Created_date> 
  </case>
  <case>
    <Plant_Code>HEES</Plant_Code> 
    <Mfg_no>XM2203</Mfg_no> 
    <case_no>A10</case_no> 
    <status>G</status> 
    <Outsource>N</Outsource> 
    <Outsource_to>HEES</Outsource_to> 
    <Modified_by>XXCHEN</Modified_by> 
    <Modified_date>2012-10-17T09:34:31.2300000+08:00</Modified_date> 
    <file_name>XM2203201210171228.xml</file_name> 
    <Tag_Mfg_no>NULL</Tag_Mfg_no> 
    <Tag_case_no>NULL</Tag_case_no> 
    <Created_by>EPS_spUpdateCase</Created_by> 
    <Created_date>2012-10-17T09:34:31.1070000+08:00</Created_date> 
  </case>
</PackingList>') AS "date" columns plant_code VARCHAR2(30) path '/case/Plant_Code',
                               mfg_no VARCHAR2(30) path '/case/Mfg_no',
                               case_no VARCHAR2(30) path '/case/case_no',
                               status VARCHAR2(10) path '/case/status',
                               net_weight VARCHAR2(30) path '/case/Net_weight',
                               gross_weight VARCHAR2(30) path '/case/gross_weight',
                               ext_dimension VARCHAR2(30) path '/case/ext_dimension',
                               int_dimension VARCHAR2(30) path '/case/Int_Dimension',
                               volume VARCHAR2(30) path '/case/Volume',
                               outsource VARCHAR2(10) path '/case/Outsource',
                               outsource_to VARCHAR2(30) path '/case/Outsource_to',
                               eps_modified_by VARCHAR2(30) path '/case/Modified_by',
                               eps_modified_date VARCHAR2(50) path '/case/Modified_date',
                               file_name VARCHAR2(30) path '/case/file_name',
                               eps_created_by VARCHAR2(30) path '/case/Created_by',
                               eps_created_date VARCHAR2(50) path '/case/Created_date') xt)
  LOOP
    l_row_number := l_row_number + 1;
    --EXIT WHEN l_row_number = 11;
    dbms_output.put_line(rec.case_no);
  END LOOP;
  -- dbms_output.put_line(l_row_number);
END;
