CREATE OR REPLACE PACKAGE XXFND_UTL_SMTP_HELPER
--==========================================================
--Package Name : xxfnd_utl_smtp_helper
--Discription  : This is a helper package spec. for sending
--               email using smtp and ecapsulate the UTL_SMTP
--               APIs.
--Language     : PL/SQL
--Modify
--  1.0.0
--    Argument : New Development
--    Date     : 10-JUN-2011 11:40
--    Author   : Eric Liu
--    Note     :
--  1.0.1
--    Argument : Update
--    Date     : 14-JUN-2011 11:40
--    Author   : Eric Liu
--    Note     : Refactor code
--  1.0.2
--    Argument : Update
--    Date     : 09-MAY-2012 10:27
--    Author   : Eric Liu
--    Note     : The API now supports multiple recipients 
--==========================================================
AS
    --------------------------------------------------------
    -- PUBLIC: Global variable decalrations
    --------------------------------------------------------
    --
    -- SMTP Connection handle
    --
    SUBTYPE SMTP_CONNECTION IS BINARY_INTEGER;
    --
    -- Content types
    --
    g_HTML_CONTENT  CONSTANT VARCHAR2(10) := 'text/html';
    g_TEXT_CONTENT  CONSTANT VARCHAR2(10) := 'text/plain';
    
    --
    -- Store multiple recipients
    --
    type recipient_type is record(
      recipient     varchar2(120),
      email_address varchar2(200)
    );
    type recipient_list is table of recipient_type index by binary_integer;
    
    -- =======================================
    -- FUNCTION Create_Smtp_Connection
    -- ** Initialize smtp connection data and
    --    open it.
    --
    -- ARGUMENTS
    --   p_smtp_hostname   smtp hostname
    --   p_smtp_port_num   smtp port number
    --   x_smtp_conn       smtp connect handle
    -- =======================================
    FUNCTION Create_Smtp_Connection(p_smtp_hostname IN VARCHAR2,
                                    p_smtp_port_num IN NUMBER DEFAULT 25,
                                    x_smtp_conn     IN OUT NOCOPY SMTP_CONNECTION)
      RETURN BOOLEAN;


    -- =======================================
    -- FUNCTION Set_Header
    -- ** generate a mail header information
    --
    -- ARGUMENTS
    --   p_smtp_conn      smtp handle
    --   p_subject        subject
    --   p_from           sender addr.
    --   p_sender         sender
    --   p_recipient_list a list of recipient information
    --   p_cc1            cc1
    --   p_cc2            cc2
    --   p_charset        mail charset
    --   p_db_charset     database character set
    -- =======================================
    PROCEDURE Set_Header(p_smtp_conn      IN SMTP_CONNECTION,
                         p_subject        IN VARCHAR2,
                         p_from           IN VARCHAR2,
                         p_sender         IN VARCHAR2 DEFAULT NULL,
                         p_recipient_list in recipient_list,
                         p_cc1            IN VARCHAR2 DEFAULT NULL,
                         p_cc2            IN VARCHAR2 DEFAULT NULL,
                         p_charset        IN VARCHAR2 DEFAULT NULL,
                         p_db_charset     IN VARCHAR2 DEFAULT NULL);

    -- =======================================
    -- FUNCTION Add_Body
    -- ** generate the mail body
    --
    -- ARGUMENTS
    --   p_smtp_conn       smtp handle
    --   p_content_type    content type
    --   p_body            text/html body
    -- =======================================
    PROCEDURE Add_Body(p_smtp_conn    IN SMTP_CONNECTION,
                       p_content_type IN VARCHAR2 DEFAULT g_TEXT_CONTENT,
                       p_body         IN VARCHAR2);

    -- =======================================
    -- FUNCTION Add_Attachment
    -- ** generate a mail attachment
    --
    -- ARGUMENTS
    --   p_smtp_conn    smtp handle
    --   p_file_path    file path alias that
    --                  should be defined in
    --                  all_directories table.
    --   p_file_name    file name
    -- =======================================
    PROCEDURE Add_Attachment(p_smtp_conn IN SMTP_CONNECTION,
                             p_file_path IN VARCHAR2,
                             p_file_name IN VARCHAR2);

    -- =======================================
    -- FUNCTION Add_Attachment
    -- ** generate at most 5 attachments, the
    --    source file of which must be in the
    --    same file path.
    --
    -- ARGUMENTS
    --   p_smtp_conn    smtp handle
    --   p_file_path    file path alias that
    --                  should be defined in
    --                  all_directories table.
    --   p_file_name1   file1
    --   p_file_name2   file2
    --   p_file_name3   file3
    --   p_file_name4   file4
    --   p_file_name5   file5
    -- =======================================
    PROCEDURE Add_Attachments(p_smtp_conn  IN SMTP_CONNECTION,
                              p_file_path  IN VARCHAR2,
                              p_file_name1 IN VARCHAR2,
                              p_file_name2 IN VARCHAR2 DEFAULT NULL,
                              p_file_name3 IN VARCHAR2 DEFAULT NULL,
                              p_file_name4 IN VARCHAR2 DEFAULT NULL,
                              p_file_name5 IN VARCHAR2 DEFAULT NULL);

    -- =======================================
    -- FUNCTION Send
    -- ** write data to utl_smtp and send email
    --
    -- ARGUMENTS
    --   p_smtp_conn   smtp handle
    -- =======================================
    PROCEDURE Send(p_smtp_conn IN SMTP_CONNECTION);

    -- =======================================
    -- FUNCTION Disconnect
    -- ** Release one smtp resource back to
    --    the system.
    --
    -- ARGUMENTS
    --   p_smtp_conn   smtp handle
    -- =======================================
    PROCEDURE Disconnect(p_smtp_conn IN SMTP_CONNECTION);

    -- =======================================
    -- FUNCTION html_body
    -- ** Release all smtp resources that has
    --    registered in this package.
    --
    -- ARGUMENTS
    -- =======================================
    PROCEDURE Disconnect_All;
END XXFND_UTL_SMTP_HELPER;
/
CREATE OR REPLACE PACKAGE BODY XXFND_UTL_SMTP_HELPER
--==========================================================
--Package Name : XXFND_UTL_SMTP_HELPER
--Discription  : This is a helper package body for sending
--               email using smtp and ecapsulate the UTL_SMTP
--               APIs.
--Language     : PL/SQL
--Modify
--  1.0.0
--    Argument : New Development
--    Date     : 10-JUN-2011 11:40
--    Author   : Eric Liu
--    Note     :
--  1.0.1
--    Argument : Update
--    Date     : 14-JUN-2011 11:40
--    Author   : Eric Liu
--    Note     : Refactor code
--  1.0.2
--    Argument : Update
--    Date     : 09-MAY-2012 10:27
--    Author   : Eric Liu
--    Note     : The API now supports multiple recipients 
--==========================================================
AS

  --------------------------------------------
  -- PRIVATE: global variables/types declare
  --------------------------------------------
  --
  -- SMTP STRUCT TYPE
  --
  TYPE SMTP_TYPE IS RECORD (
     CONNECTION UTL_SMTP.CONNECTION,           -- connection object
       CHARSET   VARCHAR2(50),                   -- mail charset
       DB_CHARSET VARCHAR2(50),                  -- database character set
       DATA       BLOB                            -- data to be sent
  );
  --
  -- cache type that store all smtp instances
  --
  TYPE SMTP_TYPES IS TABLE OF SMTP_TYPE
       INDEX BY BINARY_INTEGER;

  --
  -- smtp cache that stores all instances
  --
  smtp_instances              SMTP_TYPES;

  --
  -- Constant values
  --
  QUOTES           CONSTANT   CHAR(1)        := CHR(34);
  BOUNDARY         CONSTANT   VARCHAR2(30)   := 'DMW.Boundary.605592468';
  BUFFER_SIZE      CONSTANT   PLS_INTEGER    := 1900;
  SPLITTER         CONSTANT   CHAR(1)        := ',';
	BASE64_LINE_SIZE CONSTANT   BINARY_INTEGER := 57;


  -- =======================================
  -- FUNCTION html_body
  -- ** generate a basic html struct
  --
  -- ARGUMENTS
  --   p_title   the html title
  --   p_body    the html body
  -- =======================================
  FUNCTION html_body(p_charset IN VARCHAR2,
                     p_title   IN VARCHAR2 DEFAULT NULL,
                     p_body    IN VARCHAR2)
  RETURN VARCHAR2 IS
  BEGIN
    RETURN
    '<!doctype html><html>
       <head>
          <title>' || p_title || '</title>
          <meta http-equiv="content-type" content="text/html; charset=' || p_charset || '"/>
       </head>
       <body>
         ' || p_body || '
       </body>
     </html>
    ';

  END html_body;

  -- =======================================
  -- FUNCTION inst_exists
  -- ** test if specified smtp connection is
  --    available.
  --
  -- ARGUMENTS
  --   which     the smtp handle
  -- =======================================
  FUNCTION inst_exists(which IN SMTP_CONNECTION) RETURN BOOLEAN
  IS
  BEGIN

      IF smtp_instances(which).connection.host IS NOT NULL THEN
        RETURN (TRUE);
      ELSE
        RETURN (FALSE);
      END IF;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN (FALSE);
  END inst_exists;

  -- =======================================
  -- PROCEDURE get_connection
  -- ** get the real utl_smtp connection
  --    object.
  --
  -- ARGUMENTS
  --   which     the smtp handle
  -- =======================================
  FUNCTION get_connection(which IN SMTP_CONNECTION)
    RETURN utl_smtp.connection
  IS
      x_conn    utl_smtp.connection := NULL;
  BEGIN
      IF inst_exists(which) THEN
        x_conn := smtp_instances(which).connection;
      END IF;

      RETURN (x_conn);
  END get_connection;

  -- =======================================
  -- PROCEDURE append_data
  -- ** append a piece of data to the blob
  --    data owned by current smtp handle.
  --
  -- ARGUMENTS
  --   which     the smtp handle
  --   r_data    piece of raw data
  -- =======================================
  PROCEDURE append_data(which IN smtp_connection, r_data IN RAW)
  IS
  BEGIN
      IF inst_exists(which) THEN
        dbms_lob.writeappend(
          lob_loc => smtp_instances(which).data
        , amount  => utl_raw.length(r_data)
        , buffer  => r_data
        );
      END IF;
  END append_data;

  -- =======================================
  -- PROCEDURE append_data
  -- ** append a piece of data to the blob
  --    data owned by current smtp handle.
  --
  -- ARGUMENTS
  --   which     the smtp handle
  --   data      piece of string data
  -- =======================================
  PROCEDURE append_data(which IN smtp_connection, data IN VARCHAR2)
  IS
      r_data RAW(32767);
  BEGIN
      r_data := utl_raw.cast_to_raw(data);
      Append_Data(which, r_data => r_data);
  END append_data;

  -- =======================================
  -- PROCEDURE set_charset
  -- ** push charset into SMTP_TYPE of current
  --    handle. this procedure is called in
  --    Set_Header
  --
  -- ARGUMENTS
  --   which        the smtp handle
  --   charset      mail charset
  --   db_charset   database charset
	--
	-- HISTORY
	--   1.1   eric.liu   04-OCT-2012   Update
	--   -------------------------------------
	--   Set default value for charset
  -- =======================================
  PROCEDURE set_charset(which      IN SMTP_CONNECTION,
                        charset    IN VARCHAR2,
                        db_charset IN VARCHAR2 DEFAULT NULL)
  IS
      v_db_charset VARCHAR2(50);
  BEGIN
    IF inst_exists(which) THEN
      smtp_instances(which).CHARSET := 
			  nvl(charset,fnd_profile.value('ICX_CLIENT_IANA_ENCODING'));

      SELECT NVL(db_charset, NDP.VALUE)
        INTO v_db_charset
        FROM NLS_DATABASE_PARAMETERS NDP
       WHERE NDP.parameter = 'NLS_CHARACTERSET'
      ;
      smtp_instances(which).DB_CHARSET := v_db_charset;
    END IF;
  END set_charset;

  -- =======================================
  -- FUNCTION Create_Smtp_Connection
  -- ** Initialize smtp connection data and
  --    open it.
  --
  -- ARGUMENTS
  --   p_smtp_hostname   smtp hostname
  --   p_smtp_port_num   smtp port number
  --   x_smtp_conn       smtp connect handle
  -- =======================================
  FUNCTION Create_Smtp_Connection(p_smtp_hostname IN VARCHAR2,
                                  p_smtp_port_num IN NUMBER DEFAULT 25,
                                  x_smtp_conn     IN OUT NOCOPY SMTP_CONNECTION)
    RETURN BOOLEAN
  IS
      l_inst   smtp_type; -- smtp connect instance
      b_data   BLOB;
  BEGIN
      IF p_smtp_hostname IS NULL THEN
        RETURN (FALSE);
      END IF;

      -- open smtp connection
      l_inst.CONNECTION :=
      utl_smtp.open_connection(
                 host => p_smtp_hostname
               , port => p_smtp_port_num
               );
      utl_smtp.helo(l_inst.CONNECTION, p_smtp_hostname);

      -- initialize blob data
      dbms_lob.createtemporary(b_data, FALSE);
      l_inst.DATA := b_data;

      -- save it to the cache object
      x_smtp_conn := smtp_instances.count + 1;
      smtp_instances(x_smtp_conn) := l_inst;

      RETURN (TRUE);
  EXCEPTION
      WHEN OTHERS THEN
        RETURN (FALSE);
  END Create_Smtp_Connection;

  -- =======================================
  -- FUNCTION Disconnect
  -- ** Release one smtp resource back to
  --    the system.
  --
  -- ARGUMENTS
  --   p_smtp_conn   smtp handle
  -- =======================================
  PROCEDURE Disconnect(p_smtp_conn IN SMTP_CONNECTION)
  IS
  BEGIN
      IF inst_exists(p_smtp_conn) THEN
        dbms_lob.freetemporary(smtp_instances(p_smtp_conn).DATA);
        utl_smtp.quit(smtp_instances(p_smtp_conn).CONNECTION);
        smtp_instances(p_smtp_conn) := NULL;
      END IF;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        raise_application_error(
          -20001, 'Unexpected Error when disconnecting: ' || SQLERRM
        );
  END Disconnect;

  -- =======================================
  -- FUNCTION html_body
  -- ** Release all smtp resources that has
  --    registered in this package.
  --
  -- ARGUMENTS
  -- =======================================
  PROCEDURE Disconnect_All
  IS
  BEGIN
      FOR i IN 1..smtp_instances.count LOOP
        Disconnect(i);
      END LOOP;

      smtp_instances.delete;
  END Disconnect_All;

  -- =======================================
  -- FUNCTION Set_Header
  -- ** generate a mail header information
  --
  -- ARGUMENTS
  --   p_smtp_conn   smtp handle
  --   p_subject     subject
  --   p_from        sender addr.
  --   p_sender      sender
  --   p_to          receiver addr.
  --   p_receiver    receiver
  --   p_cc1         cc1
  --   p_cc2         cc2
  --   p_charset     mail charset
  --   p_db_charset  database character set
  -- =======================================
  PROCEDURE Set_Header(p_smtp_conn      IN SMTP_CONNECTION,
                       p_subject        IN VARCHAR2,
                       p_from           IN VARCHAR2,
                       p_sender         IN VARCHAR2 DEFAULT NULL,
                       p_recipient_list in recipient_list,
                       p_cc1            IN VARCHAR2 DEFAULT NULL,
                       p_cc2            IN VARCHAR2 DEFAULT NULL,
                       p_charset        IN VARCHAR2 DEFAULT NULL,
                       p_db_charset     IN VARCHAR2 DEFAULT NULL)
  IS
      l_conn        utl_smtp.connection;
      v_data        VARCHAR2(32767);

  BEGIN
    IF inst_exists(p_smtp_conn) THEN
        l_conn := get_connection(p_smtp_conn);
        utl_smtp.mail( l_conn, p_from );
        --
        -- Set character set
        --
        set_charset(p_smtp_conn, p_charset, p_db_charset);

        v_data := v_data || 'MIME-Version: 1.0' || utl_tcp.CRLF;
        v_data := v_data || 'Date: ' ||
                  to_char( SYSDATE, 'dd Mon yy hh24:mi:ss' ) || utl_tcp.CRLF;
                  
        --
        -- Receiver inf
        --
        if p_recipient_list.count > 0 then
          v_data := v_data || 'To: ';
        end if;
        for idx in p_recipient_list.first..p_recipient_list.last loop
          if p_recipient_list(idx).email_address is not null then
            utl_smtp.rcpt( l_conn, p_recipient_list(idx).email_address );
            
            if p_recipient_list(idx).recipient is not null then
             v_data := v_data ||
                       QUOTES ||
                       CONVERT(p_recipient_list(idx).recipient,
                               smtp_instances(p_smtp_conn).db_charset) || 
                       QUOTES ||
                       '<' || p_recipient_list(idx).email_address || '>' || SPLITTER;
            else
              v_data := v_data || p_recipient_list(idx).email_address || SPLITTER;
            end if;
          end if;
        end loop;
        v_data := rtrim(v_data, SPLITTER) || utl_tcp.CRLF;
        
        --
        -- Sender Inf
        --
        IF p_sender IS NOT NULL THEN
           v_data := v_data || 'From: ' ||
                       QUOTES ||
                       CONVERT( p_sender,
                              smtp_instances(p_smtp_conn).db_charset
                            ) || QUOTES ||
                       '<' || p_from || '>' || utl_tcp.CRLF;
        ELSE
           v_data := v_data || 'From: ' || p_from || utl_tcp.CRLF;
        END IF;

        --
        -- subject inf
        --
        v_data := v_data || 'Subject: ' ||
                  CONVERT( p_subject,
                           smtp_instances(p_smtp_conn).db_charset
                         ) || utl_tcp.CRLF;
        --v_data := v_data || 'Reply-To: ' || nvl( p_reply_to, p_from ) || utl_tcp.CRLF;
        v_data := v_data || 'Content-Type: multipart/mixed; boundary=' || -- mixed, alternative
                    QUOTES  || BOUNDARY || QUOTES || utl_tcp.CRLF; -- chr(34) is the double quoate

        --
        -- Append data
        --
        Append_Data(p_smtp_conn, data => v_data);
    END IF;
  END Set_Header;

  -- =======================================
  -- FUNCTION Add_Body
  -- ** generate the mail body
  --
  -- ARGUMENTS
  --   p_smtp_conn       smtp handle
  --   p_content_type    content type
  --   p_body            text/html body
	--
	-- HISTORY
	--   1.1   eric.liu   04-OCT-2012   Update
	--   -------------------------------------
	--   Handle text content display
  -- =======================================
  PROCEDURE Add_Body(p_smtp_conn    IN SMTP_CONNECTION,
                     p_content_type IN VARCHAR2 DEFAULT g_TEXT_CONTENT,
                     p_body         IN VARCHAR2)
  IS
      v_data   VARCHAR2(32767);
  BEGIN
      IF inst_exists(p_smtp_conn) THEN
        -- write the text/html boundary
        v_data := '--' || BOUNDARY || utl_tcp.CRLF;
        v_data := v_data || 'content-type: ' || p_content_type ||   -- content type
                  '; charset=' || smtp_instances(p_smtp_conn).charset ||    -- text encoding
                  utl_tcp.CRLF || utl_tcp.CRLF;

        Append_Data(p_smtp_conn, data => v_data);
        
				IF p_content_type = g_HTML_CONTENT THEN
					-- get html body content
          v_data := convert(
                      html_body(p_body => p_body,
                                p_charset => smtp_instances(p_smtp_conn).charset
                                ),
                      smtp_instances(p_smtp_conn).db_charset
                    ) ||
                    utl_tcp.CRLF || utl_tcp.CRLF;
        ELSE
					-- get plain text body content
					v_data := convert(
											p_body,
											smtp_instances(p_smtp_conn).db_charset
										) ||
										utl_tcp.CRLF || utl_tcp.CRLF;
        END IF;
        -- write body content
        Append_Data(p_smtp_conn, data => v_data);
      END IF;
  END Add_Body;

  -- =======================================
  -- FUNCTION Add_Attachment
  -- ** generate a mail attachment
  --
  -- ARGUMENTS
  --   p_smtp_conn    smtp handle
  --   p_file_path    file path alias that
  --                  should be defined in
  --                  all_directories table.
  --   p_file_name    file name
  -- =======================================
  PROCEDURE Add_Attachment(p_smtp_conn IN SMTP_CONNECTION,
                           p_file_path IN VARCHAR2,
                           p_file_name IN VARCHAR2)
  IS
      v_data         VARCHAR2(32767);
      n_mount        PLS_INTEGER      := BASE64_LINE_SIZE;
      n_offset       PLS_INTEGER      := 1;

      f_handle       utl_file.file_type;                        -- file handle
      b_fexists      BOOLEAN;                                   -- indicates if file exists
      n_flength      PLS_INTEGER;                               -- file size (in bytes)
      n_fblock_size  PLS_INTEGER;

      v_dummy        VARCHAR2(1);
      r_buffer       RAW(57);                                   -- buffer to store one piece of file data
                                                                -- that is about to inserted each time.

      -- ---------------------------------
      -- Cursor that used to check if
      -- specified dicectory alias name
      -- exists in ALL_DIRECTOIES.
      -- ---------------------------------
      CURSOR dir_exists IS
      SELECT 'X'
        FROM ALL_DIRECTORIES
       WHERE DIRECTORY_NAME = p_file_path
      ;
  BEGIN
    IF inst_exists(p_smtp_conn) THEN

      -- ---------------------------------
      -- check if specified directory is
      -- defined in ALL_DIRECTORIES
      -- ---------------------------------
      OPEN   dir_exists;
      FETCH  dir_exists INTO v_dummy;
      IF dir_exists%NOTFOUND THEN
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE dir_exists;

      -- ---------------------------------
      -- open target file attributes and
      -- get file handle
      -- ---------------------------------
      utl_file.fgetattr(
                 location => p_file_path
               , filename => p_file_name
               , fexists  => b_fexists
               , file_length => n_flength
               , block_size => n_fblock_size
               );

      IF b_fexists THEN
          -- ---------------------------------
          -- construct meta data for attachment
          -- ---------------------------------
          v_data := '--' || BOUNDARY || utl_tcp.CRLF;
          v_data := v_data || 'Content-Type: application/octet-stream; name=' || QUOTES ||
                    p_file_name || QUOTES || utl_tcp.CRLF;
          v_data := v_data || 'Content-Disposition: attachment; filename=' || QUOTES ||
                    p_file_name || QUOTES || utl_tcp.CRLF;
          v_data := v_data || 'Content-Transfer-Encoding: base64' ||
                    utl_tcp.CRLF || utl_tcp.CRLF;
          Append_Data(which => p_smtp_conn,
                      data  => convert(v_data, smtp_instances(p_smtp_conn).db_charset));

          -- open file
          f_handle :=
          utl_file.fopen(LOCATION => p_file_path,
					               filename => p_file_name,
                         open_mode => 'rb'); -- change to binary read
          
          -- write data
					-- Bug fix: add equal sign in order to avoid
					-- missing the last character while reading.
          WHILE (n_offset <= n_flength ) 
            LOOP
              utl_file.get_raw(FILE   => f_handle,
                               buffer => r_buffer,
                               len    => n_mount);
							-- fix the mount
							n_mount := utl_raw.length(r_buffer);
							/*fnd_file.put_line(fnd_file.LOG, 
							  utl_raw.cast_to_varchar2(r_buffer) || '->' || n_mount
							);*/
							Append_Data(which  => p_smtp_conn,
							            r_data => utl_encode.base64_encode(r_buffer));
							Append_Data(which  => p_smtp_conn,
							            data   => utl_tcp.CRLF);
							n_offset := n_offset + n_mount;
              n_mount  := LEAST(BASE64_LINE_SIZE, n_flength - BASE64_LINE_SIZE);
            END LOOP;

          -- release file resource
          IF utl_file.is_open(f_handle) THEN
            utl_file.fclose(f_handle);
          END IF;
       END IF;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_application_error(
        -20001
      , 'Directory is not defined'
      );
    WHEN OTHERS THEN
      -- release file resource
      IF utl_file.is_open(f_handle) THEN
        utl_file.fclose(f_handle);
      END IF;
      -- rasie exception
      raise_application_error(
        -20002
      , 'Failed to cast due to the following error: ' || SQLERRM
      );
  END Add_Attachment;

  -- =======================================
  -- FUNCTION Add_Attachment
  -- ** generate at most 5 attachments, the
  --    source file of which must be in the
  --    same file path.
  --
  -- ARGUMENTS
  --   p_smtp_conn    smtp handle
  --   p_file_path    file path alias that
  --                  should be defined in
  --                  all_directories table.
  --   p_file_name1   file1
  --   p_file_name2   file2
  --   p_file_name3   file3
  --   p_file_name4   file4
  --   p_file_name5   file5
  -- =======================================
  PROCEDURE Add_Attachments(p_smtp_conn  IN SMTP_CONNECTION,
                            p_file_path  IN VARCHAR2,
                            p_file_name1 IN VARCHAR2,
                            p_file_name2 IN VARCHAR2 DEFAULT NULL,
                            p_file_name3 IN VARCHAR2 DEFAULT NULL,
                            p_file_name4 IN VARCHAR2 DEFAULT NULL,
                            p_file_name5 IN VARCHAR2 DEFAULT NULL)
  IS
  BEGIN
    IF inst_exists(p_smtp_conn) THEN
      Add_Attachment(p_smtp_conn, p_file_path, p_file_name1);

      IF p_file_name2 IS NOT NULL THEN
        Add_Attachment(p_smtp_conn, p_file_path, p_file_name2);
      END IF;

      IF p_file_name3 IS NOT NULL THEN
        Add_Attachment(p_smtp_conn, p_file_path, p_file_name3);
      END IF;

      IF p_file_name4 IS NOT NULL THEN
        Add_Attachment(p_smtp_conn, p_file_path, p_file_name4);
      END IF;

      IF p_file_name5 IS NOT NULL THEN
        Add_Attachment(p_smtp_conn, p_file_path, p_file_name5);
      END IF;
    END IF;
  END;

  -- =======================================
  -- FUNCTION Send
  -- ** write data to utl_smtp and send email
  --
  -- ARGUMENTS
  --   p_smtp_conn   smtp handle
  -- =======================================
  PROCEDURE Send(p_smtp_conn IN SMTP_CONNECTION)
  IS
      b_blob          BLOB;
      l_conn          utl_smtp.connection;
      n_offset        BINARY_INTEGER  := 1;
      n_amount        BINARY_INTEGER  := BUFFER_SIZE;
      r_buffer        RAW(1900);
			l_lob_len       BINARY_INTEGER;
  BEGIN
      IF inst_exists(p_smtp_conn) THEN
        l_conn := smtp_instances(p_smtp_conn).CONNECTION;
        b_blob := smtp_instances(p_smtp_conn).DATA;
        l_lob_len := dbms_lob.getlength(b_blob);
        utl_smtp.open_data(l_conn);

        WHILE (n_offset <= l_lob_len) LOOP
          dbms_lob.read(b_blob, n_amount, n_offset, r_buffer);
          utl_smtp.write_raw_data(l_conn, r_buffer);
          --fnd_file.put_line(fnd_file.LOG, utl_raw.cast_to_varchar2(r_buffer)); -- for debug
          n_offset := n_offset + n_amount;
          n_amount := least(BUFFER_SIZE, l_lob_len - BUFFER_SIZE);
        END LOOP;

        utl_smtp.write_data(l_conn,utl_tcp.CRLF || '--' || BOUNDARY || '--' || utl_tcp.CRLF);
        utl_smtp.close_data(l_conn);
      END IF;
  END Send;

END XXFND_UTL_SMTP_HELPER;
/
