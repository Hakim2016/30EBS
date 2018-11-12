DECLARE
  l_new_cs VARCHAR2(200);
  l_coa_id NUMBER;
  l_ccid   NUMBER;
  l_err    VARCHAR2(2000);
BEGIN
  l_coa_id := 50351;
  l_new_cs := 'FB00.000.1145500000.1146011000.10101505.0.0';
  l_ccid   := fnd_flex_ext.get_ccid(application_short_name => 'SQLGL',
                                    key_flex_code          => 'GL#',
                                    structure_number       => l_coa_id,
                                    validation_date        => to_char(SYSDATE, apps.fnd_flex_ext.date_format),
                                    concatenated_segments  => l_new_cs);
  dbms_output.put_line(' l_ccid : ' || l_ccid);
  l_err := fnd_message.get;
  dbms_output.put_line('l_err : ' || l_err);

  dbms_output.put_line(' /////////////////////////////////////////////////// ');
  l_new_cs := 'FB00.000.2161090000.0000.0.0.0';
  l_ccid   := fnd_flex_ext.get_ccid(application_short_name => 'SQLGL',
                                    key_flex_code          => 'GL#',
                                    structure_number       => l_coa_id,
                                    validation_date        => to_char(SYSDATE, apps.fnd_flex_ext.date_format),
                                    concatenated_segments  => l_new_cs);
  dbms_output.put_line(' l_ccid : ' || l_ccid);
  l_err := fnd_message.get;
  dbms_output.put_line('l_err : ' || l_err);

END;
