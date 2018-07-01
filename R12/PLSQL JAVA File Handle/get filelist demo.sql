DECLARE
  l_file_names        VARCHAR2(32767);
  l_data_file_path    VARCHAR2(32767);
  g_if_path_separator VARCHAR2(1) := fnd_profile.value('XXFND_IF_PATH_SEPARATOR');
  g_if_base_path      VARCHAR2(400) := fnd_profile.value('XXFND_IF_BASE_PATH');
  g_split_by          VARCHAR2(1) := ':';
  l_lengthb           NUMBER;
  l_data_clob         CLOB;
BEGIN
  /*l_data_file_path := g_if_base_path || g_if_path_separator || p_int_rec.interface_folder || g_if_path_separator ||
  l_ledger_path || p_int_rec.unprocess_subfdr;*/
  dbms_lob.createtemporary(l_data_clob, TRUE);
  dbms_lob.open(l_data_clob, --
                dbms_lob.lob_readwrite);

  dbms_output.put_line(' g_if_base_path : ' || g_if_base_path);
  l_data_file_path := g_if_base_path || g_if_path_separator || /*p_int_rec.interface_folder*/
                      'IF01' || g_if_path_separator || /*l_ledger_path*/
                      NULL || 'unprocess' /*p_int_rec.unprocess_subfdr*/
   ;
  dbms_output.put_line(' g_if_base_path   : ' || g_if_base_path);
  dbms_output.put_line(' l_data_file_path : ' || l_data_file_path);
  --list file in directory
  l_file_names := xxfnd_java_test_pkg.getlistfiles(path    => l_data_file_path || g_if_path_separator,
                                                   suffix  => NULL,
                                                   isdepth => 'TRUE',
                                                   splitby => g_split_by);
  dbms_lob.writeappend(lob_loc => l_data_clob, --
                       amount  => length(l_file_names),
                       buffer  => l_file_names);
  dbms_output.put_line(' length(l_file_names) : ' || length(l_file_names));

  dbms_output.put_line(' l_file_names : ' || l_file_names);
  SELECT --length(l_file_names) -- lengthb 最多只能计算 4000个字符的长度
   dbms_lob.getlength(l_data_clob)
    INTO l_lengthb
    FROM dual;
  dbms_output.put_line(' l_lengthb : ' || l_lengthb);
  dbms_lob.close(lob_loc => l_data_clob);
END;
