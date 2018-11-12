CREATE OR REPLACE PACKAGE cux_base64_encode_util IS

  -- ==========================
  -- varchar2 base64_encode
  -- ==========================
  FUNCTION func_base64_encode(p_varchar2 IN VARCHAR2) RETURN VARCHAR2;

  -- ==========================
  -- varchar2 base64_decode
  -- ==========================
  FUNCTION func_base64_decode(p_varchar2 IN VARCHAR2) RETURN VARCHAR2;

  -- ==========================
  -- clob base64_encode
  -- ==========================
  FUNCTION func_base64_encode(p_clob IN CLOB) RETURN CLOB;

  -- ==========================
  -- clob base64_decode
  -- ==========================
  FUNCTION func_base64_decode(p_clob IN CLOB) RETURN CLOB;

  -- ==========================
  -- blob base64_encode
  -- ==========================
  FUNCTION func_base64_encode(p_blob IN BLOB) RETURN BLOB;

  -- ==========================
  -- blob base64_decode
  -- ==========================
  FUNCTION func_base64_decode(p_blob IN BLOB) RETURN BLOB;

  -- proc_test
  PROCEDURE proc_test;
END cux_base64_encode_util;
/
CREATE OR REPLACE PACKAGE BODY cux_base64_encode_util IS

  -- CONSTANT
  c_read_length CONSTANT NUMBER := 4000;

  -- ==========================
  -- varchar2 base64_encode
  -- ==========================
  FUNCTION func_base64_encode(p_varchar2 IN VARCHAR2) RETURN VARCHAR2 IS
    l_buffer_varchar2_before VARCHAR2(32767);
    l_buffer_raw_before      RAW(32767);
    l_buffer_varchar2_after  VARCHAR2(32767);
    l_buffer_raw_after       RAW(32767);
  BEGIN
    -- base64_encode
    IF p_varchar2 IS NULL THEN
      RETURN NULL;
    END IF;
    l_buffer_varchar2_before := p_varchar2;
    l_buffer_raw_before      := utl_raw.cast_to_raw(c => l_buffer_varchar2_before);
    l_buffer_raw_after       := utl_encode.base64_encode(r => l_buffer_raw_before);
    l_buffer_varchar2_after  := utl_raw.cast_to_varchar2(r => l_buffer_raw_after);
    RETURN l_buffer_varchar2_after;
  END func_base64_encode;

  -- ==========================
  -- varchar2 base64_decode
  -- ==========================
  FUNCTION func_base64_decode(p_varchar2 IN VARCHAR2) RETURN VARCHAR2 IS
    l_buffer_varchar2_before VARCHAR2(32767);
    l_buffer_raw_before      RAW(32767);
    l_buffer_varchar2_after  VARCHAR2(32767);
    l_buffer_raw_after       RAW(32767);
  BEGIN
    -- base64_encode
    IF p_varchar2 IS NULL THEN
      RETURN NULL;
    END IF;
    l_buffer_varchar2_after  := p_varchar2;
    l_buffer_raw_after       := utl_raw.cast_to_raw(c => l_buffer_varchar2_after);
    l_buffer_raw_before      := utl_encode.base64_decode(r => l_buffer_raw_after);
    l_buffer_varchar2_before := utl_raw.cast_to_varchar2(r => l_buffer_raw_before);
    RETURN l_buffer_varchar2_before;
  END func_base64_decode;

  -- ==========================
  -- clob base64_encode
  -- ==========================
  FUNCTION func_base64_encode(p_clob IN CLOB) RETURN CLOB IS
    l_varchar2_before VARCHAR2(32767);
    l_varchar2_after  VARCHAR2(32767);
    l_encode_clob     CLOB;
    l_total_length    NUMBER;
    l_offset          NUMBER;
    l_read_length     NUMBER := 4000;
  BEGIN
    -- base64_encode
    IF p_clob IS NULL THEN
      RETURN NULL;
    END IF;
  
    dbms_lob.createtemporary(lob_loc => l_encode_clob, cache => TRUE);
    l_total_length := dbms_lob.getlength(lob_loc => p_clob);
    l_offset       := 1;
    FOR i IN 1 .. ceil(l_total_length / l_read_length)
    LOOP
      dbms_lob.read(lob_loc => p_clob, --
                    amount  => l_read_length,
                    offset  => l_offset,
                    buffer  => l_varchar2_before);
      l_varchar2_after := func_base64_encode(p_varchar2 => l_varchar2_before);
      dbms_lob.writeappend(lob_loc => l_encode_clob, --
                           amount  => length(l_varchar2_after),
                           buffer  => l_varchar2_after);
    END LOOP;
    RETURN l_encode_clob;
  END func_base64_encode;

  -- ==========================
  -- clob base64_decode
  -- ==========================
  FUNCTION func_base64_decode(p_clob IN CLOB) RETURN CLOB IS
    l_varchar2_before VARCHAR2(32767);
    l_varchar2_after  VARCHAR2(32767);
    l_decode_clob     CLOB;
    l_total_length    NUMBER;
    l_offset          NUMBER;
    l_read_length     NUMBER := 4000;
  BEGIN
    -- base64_decode
    IF p_clob IS NULL THEN
      RETURN NULL;
    END IF;
  
    dbms_lob.createtemporary(lob_loc => l_decode_clob, cache => TRUE);
    l_total_length := dbms_lob.getlength(lob_loc => p_clob);
    l_offset       := 1;
    FOR i IN 1 .. ceil(l_total_length / l_read_length)
    LOOP
      dbms_lob.read(lob_loc => p_clob, --
                    amount  => l_read_length,
                    offset  => l_offset,
                    buffer  => l_varchar2_after);
      l_varchar2_before := func_base64_decode(p_varchar2 => l_varchar2_after);
      dbms_lob.writeappend(lob_loc => l_decode_clob, --
                           amount  => length(l_varchar2_before),
                           buffer  => l_varchar2_before);
    END LOOP;
    RETURN l_decode_clob;
  END func_base64_decode;

  -- ==========================
  -- blob base64_encode
  -- ==========================
  FUNCTION func_base64_encode(p_blob IN BLOB) RETURN BLOB IS
    l_encode_clob CLOB;
    l_encode_blob BLOB;
  
    l_dest_lob CLOB;
    -- l_src_blob     BLOB;
    l_amount       INTEGER;
    l_dest_offset  INTEGER := 1;
    l_src_offset   INTEGER := 1;
    l_blob_csid    NUMBER := nls_charset_id('UTF8');
    l_lang_context INTEGER := dbms_lob.default_lang_ctx;
    l_warning      INTEGER;
  BEGIN
    IF p_blob IS NULL THEN
      RETURN NULL;
    END IF;
    dbms_lob.createtemporary(lob_loc => l_encode_blob, cache => TRUE);
    dbms_lob.createtemporary(lob_loc => l_dest_lob, cache => TRUE);
    l_amount      := dbms_lob.getlength(lob_loc => p_blob);
    l_dest_offset := 1;
    l_src_offset  := 1;
    dbms_lob.converttoclob(dest_lob     => l_dest_lob,
                           src_blob     => p_blob,
                           amount       => l_amount,
                           dest_offset  => l_dest_offset,
                           src_offset   => l_src_offset,
                           blob_csid    => l_blob_csid,
                           lang_context => l_lang_context,
                           warning      => l_warning);
  
    l_encode_clob := func_base64_encode(p_clob => l_dest_lob);
  
    l_amount      := dbms_lob.getlength(lob_loc => l_encode_clob);
    l_dest_offset := 1;
    l_src_offset  := 1;
    dbms_lob.converttoblob(dest_lob     => l_encode_blob,
                           src_clob     => l_encode_clob,
                           amount       => l_amount,
                           dest_offset  => l_dest_offset,
                           src_offset   => l_src_offset,
                           blob_csid    => l_blob_csid,
                           lang_context => l_lang_context,
                           warning      => l_warning);
    dbms_lob.freetemporary(lob_loc => l_dest_lob);
    dbms_lob.freetemporary(lob_loc => l_encode_clob);
    RETURN l_encode_blob;
  END func_base64_encode;

  -- ==========================
  -- blob base64_decode
  -- ==========================
  FUNCTION func_base64_decode(p_blob IN BLOB) RETURN BLOB IS
    l_decode_clob CLOB;
    l_decode_blob BLOB;
  
    l_dest_lob CLOB;
    -- l_src_blob     BLOB;
    l_amount       INTEGER;
    l_dest_offset  INTEGER := 1;
    l_src_offset   INTEGER := 1;
    l_blob_csid    NUMBER := nls_charset_id('UTF8'); -- dbms_lob.default_csid
    l_lang_context INTEGER := dbms_lob.default_lang_ctx;
    l_warning      INTEGER;
  BEGIN
    IF p_blob IS NULL THEN
      RETURN NULL;
    END IF;
    dbms_lob.createtemporary(lob_loc => l_decode_blob, cache => TRUE);
    dbms_lob.createtemporary(lob_loc => l_dest_lob, cache => TRUE);
    l_amount      := dbms_lob.getlength(lob_loc => p_blob);
    l_dest_offset := 1;
    l_src_offset  := 1;
    dbms_lob.converttoclob(dest_lob     => l_dest_lob,
                           src_blob     => p_blob,
                           amount       => l_amount,
                           dest_offset  => l_dest_offset,
                           src_offset   => l_src_offset,
                           blob_csid    => l_blob_csid,
                           lang_context => l_lang_context,
                           warning      => l_warning);
  
    l_decode_clob := func_base64_decode(p_clob => l_dest_lob);
  
    l_amount      := dbms_lob.getlength(lob_loc => l_decode_clob);
    l_dest_offset := 1;
    l_src_offset  := 1;
    dbms_lob.converttoblob(dest_lob     => l_decode_blob,
                           src_clob     => l_decode_clob,
                           amount       => l_amount,
                           dest_offset  => l_dest_offset,
                           src_offset   => l_src_offset,
                           blob_csid    => l_blob_csid,
                           lang_context => l_lang_context,
                           warning      => l_warning);
    dbms_lob.freetemporary(lob_loc => l_dest_lob);
    dbms_lob.freetemporary(lob_loc => l_decode_clob);
    RETURN l_decode_blob;
  END func_base64_decode;

  -- ==========================
  -- proc_test
  -- ==========================
  PROCEDURE proc_test IS
    l_buffer_varchar2_before VARCHAR2(32767);
    l_buffer_varchar2_after  VARCHAR2(32767);
    l_raw_before             RAW(32767);
    l_raw_after              RAW(32757);
    l_clob_before            CLOB;
    l_clob_after             CLOB;
    l_blob_before            BLOB;
    l_blob_after             BLOB;
    l_read_length            NUMBER := 4000;
    l_offset                 NUMBER := 1;
  BEGIN
    -- Varchar2
    l_buffer_varchar2_before := 'PANJINLONG';
    -- Varchar2 base64_encode
    l_buffer_varchar2_after := func_base64_encode(p_varchar2 => l_buffer_varchar2_before);
    dbms_output.put_line(rpad(l_buffer_varchar2_before, 30, ' ') || ' VARCHAR2 BASE64_ENCODE : ' ||
                         l_buffer_varchar2_after);
  
    -- Varchar2 base64_decode
    l_buffer_varchar2_before := func_base64_decode(p_varchar2 => l_buffer_varchar2_after);
    dbms_output.put_line(rpad(l_buffer_varchar2_after, 30, ' ') || ' VARCHAR2 BASE64_DECODE : ' ||
                         l_buffer_varchar2_before);
  
    -- Clob
    l_buffer_varchar2_before := 'PAN jinlong';
    dbms_lob.createtemporary(lob_loc => l_clob_before, cache => TRUE);
    dbms_lob.writeappend(lob_loc => l_clob_before, --
                         amount  => length(l_buffer_varchar2_before),
                         buffer  => l_buffer_varchar2_before);
    -- Clob encode
    l_clob_after  := func_base64_encode(p_clob => l_clob_before);
    l_read_length := c_read_length;
    l_offset      := 1;
    dbms_lob.read(lob_loc => l_clob_after, --
                  amount  => l_read_length,
                  offset  => l_offset,
                  buffer  => l_buffer_varchar2_after);
    dbms_output.put_line(rpad(l_buffer_varchar2_before, 30, ' ') || ' CLOB BASE64_ENCODE : ' ||
                         l_buffer_varchar2_after);
    -- Clob decode
    l_clob_before := func_base64_decode(p_clob => l_clob_after);
    l_read_length := c_read_length;
    l_offset      := 1;
    dbms_lob.read(lob_loc => l_clob_before, --
                  amount  => l_read_length,
                  offset  => l_offset,
                  buffer  => l_buffer_varchar2_before);
    dbms_output.put_line(rpad(l_buffer_varchar2_after, 30, ' ') || ' CLOB BASE64_DECODE : ' ||
                         l_buffer_varchar2_before);
  
    -- Blob
    l_buffer_varchar2_before := 'Jinlong.Pan';
    dbms_lob.createtemporary(lob_loc => l_blob_before, cache => TRUE);
    l_raw_before := utl_raw.cast_to_raw(c => l_buffer_varchar2_before);
    dbms_lob.writeappend(lob_loc => l_blob_before, --
                         amount  => utl_raw.length(l_raw_before),
                         buffer  => l_raw_before);
    -- Blob encode
    l_blob_after  := func_base64_encode(p_blob => l_blob_before);
    l_read_length := c_read_length;
    l_offset      := 1;
    dbms_lob.read(lob_loc => l_blob_after, --
                  amount  => l_read_length,
                  offset  => l_offset,
                  buffer  => l_raw_after);
    l_buffer_varchar2_after := utl_raw.cast_to_varchar2(r => l_raw_after);
    dbms_output.put_line(rpad(l_buffer_varchar2_before, 30, ' ') || ' BLOB BASE64_ENCODE : ' ||
                         l_buffer_varchar2_after);
    -- Blob decode
    l_blob_before := func_base64_decode(p_blob => l_blob_after);
    l_read_length := c_read_length;
    l_offset      := 1;
    dbms_lob.read(lob_loc => l_blob_before, --
                  amount  => l_read_length,
                  offset  => l_offset,
                  buffer  => l_raw_before);
    l_buffer_varchar2_before := utl_raw.cast_to_varchar2(r => l_raw_before);
    dbms_output.put_line(rpad(l_buffer_varchar2_after, 30, ' ') || ' BLOB BASE64_DECODE : ' ||
                         l_buffer_varchar2_before);
  END proc_test;

END cux_base64_encode_util;
/
