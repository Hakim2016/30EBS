DECLARE
  l_buffer_varchar2_before VARCHAR2(32767);
  l_buffer_raw_before      RAW(32767);
  l_buffer_varchar2_after  VARCHAR2(32767);
  l_buffer_raw_after       RAW(32767);
BEGIN
  l_buffer_varchar2_before := 'PANJINLONG';

  -- base64_encode
  l_buffer_raw_before     := utl_raw.cast_to_raw(c => l_buffer_varchar2_before);
  l_buffer_raw_after      := utl_encode.base64_encode(r => l_buffer_raw_before);
  l_buffer_varchar2_after := utl_raw.cast_to_varchar2(r => l_buffer_raw_after);
  dbms_output.put_line(rpad(l_buffer_varchar2_before, 20, ' ') || ' BASE64_ENCODE : ' || l_buffer_varchar2_after);

  -- base64_decode
  l_buffer_raw_after       := utl_raw.cast_to_raw(c => l_buffer_varchar2_after);
  l_buffer_raw_before      := utl_encode.base64_decode(r => l_buffer_raw_after);
  l_buffer_varchar2_before := utl_raw.cast_to_varchar2(r => l_buffer_raw_before);
  dbms_output.put_line(rpad(l_buffer_varchar2_after, 20, ' ') || ' BASE64_DECODE : ' || l_buffer_varchar2_before);

END;
