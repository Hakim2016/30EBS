SELECT *
  FROM xxfnd.xxfnd_common_file_all t
 ORDER BY t.file_id,
          t.line_number;
/*
create table XXFND.XXFND_COMMON_FILE_ALL
(
  file_id     NUMBER,
  file_name   VARCHAR2(200),
  upload_date DATE,
  line_number NUMBER,
  row_data    VARCHAR2(4000),
  character1  VARCHAR2(4000),
  character2  VARCHAR2(4000),
  character3  VARCHAR2(4000),
  character4  VARCHAR2(4000),
  character5  VARCHAR2(4000),
  character6  VARCHAR2(4000),
  character7  VARCHAR2(4000),
  character8  VARCHAR2(4000),
  character9  VARCHAR2(4000),
  character10 VARCHAR2(4000),
  character11 VARCHAR2(4000),
  character12 VARCHAR2(4000),
  character13 VARCHAR2(4000),
  character14 VARCHAR2(4000),
  character15 VARCHAR2(4000)
)
*/
DECLARE
  c_chr10 CONSTANT VARCHAR2(1) := chr(10);
  c_chr13 CONSTANT VARCHAR2(1) := chr(13);
  c_chr34 CONSTANT VARCHAR2(1) := chr(34); -- "
  c_chr44 CONSTANT VARCHAR2(1) := chr(44); -- ,
  l_file_id     NUMBER := 795568;
  n_src_offset  INTEGER := 1;
  n_dest_offset INTEGER := 1;
  n_lang_ctx    INTEGER := dbms_lob.default_lang_ctx;
  n_warn        VARCHAR2(30000);

  l_file_data      fnd_lobs.file_data%TYPE;
  l_file_name      fnd_lobs.file_name%TYPE;
  l_oracle_charset fnd_lobs.oracle_charset%TYPE;
  l_upload_date    fnd_lobs.upload_date%TYPE;
  l_clob_data      CLOB := NULL;
  l_clob_size      INTEGER;
  l_row_buf        VARCHAR2(30000);
  l_offset         INTEGER;
  l_position       INTEGER;
  l_line_number    INTEGER;

  l_row_data xxfnd.xxfnd_common_file_all%ROWTYPE;
  l_element  VARCHAR2(32767);

  -- 截取数据
  FUNCTION split_string(p_row_data      IN VARCHAR2,
                        p_col_seq       IN NUMBER,
                        p_col_separator IN VARCHAR2) RETURN VARCHAR2 IS
    l_row_data VARCHAR2(32767);
    l_element  VARCHAR2(32767);
  
  BEGIN
    l_row_data := p_row_data || p_col_separator;
    IF p_col_seq = 1 THEN
      l_element := substrb(l_row_data, 1, instrb(l_row_data, p_col_separator, 1, 1) - 1);
    ELSIF p_col_seq > 1 THEN
      l_element := substrb(l_row_data,
                           instrb(l_row_data, p_col_separator, 1, p_col_seq - 1) + lengthb(p_col_separator),
                           instrb(l_row_data, p_col_separator, 1, p_col_seq) -
                           instrb(l_row_data, p_col_separator, 1, p_col_seq - 1) - lengthb(p_col_separator));
    END IF;
    IF substrb(l_element, 1, 1) = substrb(l_element, lengthb(l_element), 1) AND --
       substrb(l_element, 1, 1) = c_chr34 THEN
      l_element := substrb(l_element, 2, lengthb(l_element) - 2);
    END IF;
    l_element := REPLACE(l_element, c_chr34 || c_chr34, c_chr34);
    RETURN l_element;
  END split_string;
BEGIN
  -- EXECUTE IMMEDIATE 'truncate TABLE xxfnd.xxfnd_common_file_all';

  DELETE FROM xxfnd.xxfnd_common_file_all t
   WHERE t.file_id = l_file_id;
  dbms_lob.createtemporary(l_clob_data, FALSE, dbms_lob.session);

  SELECT fl.file_data,
         fl.file_name,
         fl.oracle_charset,
         fl.upload_date
    INTO l_file_data,
         l_file_name,
         l_oracle_charset,
         l_upload_date
    FROM fnd_lobs fl
   WHERE fl.file_id = l_file_id;

  --dbms_output.put_line(dbms_lob.getlength(l_file_data));
  --dbms_output.put_line(l_file_name);
  --dbms_output.put_line(l_oracle_charset);
  --dbms_output.put_line(l_upload_date);

  dbms_lob.converttoclob(dest_lob     => l_clob_data,
                         src_blob     => l_file_data,
                         amount       => dbms_lob.lobmaxsize,
                         dest_offset  => n_dest_offset,
                         src_offset   => n_src_offset,
                         blob_csid    => nls_charset_id(l_oracle_charset),
                         lang_context => n_lang_ctx,
                         warning      => n_warn);

  l_clob_size := dbms_lob.getlength(l_clob_data);
  -- 截取最后一个字符
  l_row_buf := dbms_lob.substr(lob_loc => l_clob_data, --
                               amount  => 1,
                               offset  => l_clob_size - 1);

  IF l_row_buf <> c_chr10 AND l_row_buf <> c_chr13 AND l_clob_size > 0 THEN
    --Last row has no chr(10)
    -- 确保最后一个字符是 chr(10)
    l_clob_data := l_clob_data || c_chr10;
    l_clob_size := dbms_lob.getlength(l_clob_data);
  END IF;

  l_offset      := 1;
  l_line_number := 0;
  LOOP
    l_line_number := l_line_number + 1;
    l_row_data    := NULL;
    l_position    := dbms_lob.instr(lob_loc => l_clob_data, --
                                    pattern => c_chr10,
                                    offset  => l_offset,
                                    nth     => 1);
  
    IF nvl(l_position, 0) = 0 THEN
      l_position := l_clob_size + 1;
    END IF;
    EXIT WHEN l_position > l_clob_size;
  
    --dbms_output.put_line('l_line_number : ' || l_line_number);
    --dbms_output.put_line('l_position : ' || l_position);
    --dbms_output.put_line('l_offset : ' || l_offset);
    l_row_buf := dbms_lob.substr(lob_loc => l_clob_data, --
                                 amount  => l_position - l_offset,
                                 offset  => l_offset);
    l_row_buf := REPLACE(l_row_buf, c_chr10, '');
    l_row_buf := REPLACE(l_row_buf, c_chr13, '');
    --dbms_output.put_line('l_row_buf : ' || l_row_buf);
    l_offset := l_position + 1;
  
    l_row_data.file_id     := l_file_id;
    l_row_data.file_name   := l_file_name;
    l_row_data.upload_date := l_upload_date;
    l_row_data.line_number := l_line_number;
    l_row_data.row_data    := l_row_buf;
    l_row_data.character1  := split_string(l_row_data.row_data, 1, c_chr44);
    l_row_data.character2  := split_string(l_row_data.row_data, 2, c_chr44);
    l_row_data.character3  := split_string(l_row_data.row_data, 3, c_chr44);
    l_row_data.character4  := split_string(l_row_data.row_data, 4, c_chr44);
    l_row_data.character5  := split_string(l_row_data.row_data, 5, c_chr44);
    l_row_data.character6  := split_string(l_row_data.row_data, 6, c_chr44);
    l_row_data.character7  := split_string(l_row_data.row_data, 7, c_chr44);
    l_row_data.character8  := split_string(l_row_data.row_data, 8, c_chr44);
    l_row_data.character9  := split_string(l_row_data.row_data, 9, c_chr44);
    l_row_data.character10 := split_string(l_row_data.row_data, 10, c_chr44);
    l_row_data.character11 := split_string(l_row_data.row_data, 11, c_chr44);
    l_row_data.character12 := split_string(l_row_data.row_data, 12, c_chr44);
    l_row_data.character13 := split_string(l_row_data.row_data, 13, c_chr44);
    l_row_data.character14 := split_string(l_row_data.row_data, 14, c_chr44);
    l_row_data.character15 := split_string(l_row_data.row_data, 15, c_chr44);
    INSERT INTO xxfnd.xxfnd_common_file_all
    VALUES l_row_data;
  END LOOP;

END;
