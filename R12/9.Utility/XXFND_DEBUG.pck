CREATE OR REPLACE PACKAGE XXFND_DEBUG AS
/*==================================================
  Copyright (C) HAND Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
/*==================================================
  Program Name:
      XXFND_DEBUG
  Description:
      This program provide API to perform:
           log debug message
  History:
      1.00  2006-06-01  jim.lin    Creation
  ==================================================*/

/*=============================================
  Procedure Name:
      set_indentation
  Description:
      This procedure perform set debug indentation
  Argument:
      p_proc_name :  procedure name, may be package name + '.' + procedure name
  History:
      1.00  2006-06-01  jim.lin    Creation
  =============================================*/
  PROCEDURE set_indentation(p_proc_name IN VARCHAR2);

/*=============================================
  Procedure Name:
      reset_indentation
  Description:
      This procedure perform reset debug indentation
  Argument:
      p_proc_name :  procedure name, may be package name + '.' + procedure name
  History:
      1.00  2006-06-01  jim.lin    Creation
  =============================================*/
  PROCEDURE reset_indentation(p_proc_name IN VARCHAR2);

/*=============================================
  Procedure Name:
      log
  Description:
      This procedure perform log message
  Argument:
      p_msg      : log message
      p_level    : log level
                     1  STATEMENT
                     2  PROCEDURE
                     3  Event
                     4  EXCEPTION
                     5  Error
                     6  Unexpected
      p_module   : log module
  History:
      1.00  2006-06-01  jim.lin    Creation
  =============================================*/
  PROCEDURE log(p_msg      IN VARCHAR2,
                p_level    IN NUMBER   DEFAULT 1,
                p_module   IN VARCHAR2 DEFAULT 'CUX');

END XXFND_DEBUG;
/
CREATE OR REPLACE PACKAGE BODY XXFND_DEBUG AS
/*==================================================
  Copyright (C) HAND Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
/*==================================================
  Program Name:
      XXFND_DEBUG
  Description:
      This program provide API to perform:
           log debug message
  History:
      1.00  2006-06-01  jim.lin    Creation
  ==================================================*/

  -- Constants
  G_DEBUG_MODE         VARCHAR2(30) := NVL(FND_PROFILE.VALUE('XXFND_DEBUG_MODE'),'TABLE');
  G_MAX_INDENT_STR_LEN CONSTANT NUMBER(4) := 1880;

  -- Type define
  TYPE proc_tbl IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;

  -- global variable
  g_debug_init        BOOLEAN := FALSE;      -- Log initialize state
  g_fd                utl_file.file_type;    -- Log file descriptor
  g_file_dbg_on       NUMBER := 0;           -- Log ON state
  g_cp_flag           NUMBER := 0;           -- conc program
  g_file_postfix      VARCHAR2 (100)  := fnd_global.user_name;

  g_indent_str   VARCHAR2(4000)   := NULL;
  g_proc         VARCHAR2(80);
  g_proc_tbl    proc_tbl;
  g_index       Number := 0;

  --  Debug Enabled
  l_debug       VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  Procedure Set_Indentation(p_proc_name Varchar2)
  IS
  Begin
    --
    -- Set the global procedure name
    --
    g_proc := p_proc_name;
    --
    -- Increase the indent string by 2 spaces.
    --
    g_indent_str := g_indent_str || '..';
    If Length(g_indent_str) > G_MAX_INDENT_STR_LEN Then
      g_indent_str := '..';
    End If;
    g_index := g_index + 1;
    g_proc_tbl(g_index) := p_proc_name;

  End Set_Indentation;

  Procedure Reset_Indentation(p_proc_name Varchar2)
  IS
  Begin

    IF p_proc_name = g_proc THEN
      --
      -- Reset the indent string by 2 space.
      --
      g_indent_str := Substr(g_indent_str, 1, Length(g_indent_str) - 2);
      --
      -- Drop the current called procedure name from the stack since
      -- we just exited.
      --
      g_proc_tbl.delete(g_index);
      --
      -- Get the parent calling procedure name from the stack.
      --
      g_index := g_index - 1;
      IF g_index <= 0 THEN
        g_index := 0;
        -- Reset the proc name otherwise it prints the last proc name
        -- if the caller didn't make call to set_indentation.
        g_proc := Null;
      ELSE
        g_proc := g_proc_tbl(g_index);
      END IF;
    END IF;
  End Reset_Indentation;

  PROCEDURE log_init
  IS
  l_dbgfile     varchar2(256) ;
  l_errmsg      varchar2(256);
  l_dbgpath     varchar2(128);
  l_ndx         number;
  l_strlen      number;
  l_dbgdir      varchar2(256);
  l_dir_separator   varchar2(1);
  BEGIN
    g_file_dbg_on := 1;
      select nvl(fnd_profile.value('CONC_REQUEST_ID'), 0) into g_cp_flag from dual;
      select to_char(sysdate, 'YYYY-MM-DD HH24.MI.SS') into l_errmsg from dual;
      if ( g_cp_flag > 0 AND G_DEBUG_MODE <> 'FILEONLY') then
      fnd_file.put_line(fnd_file.log, ' ******** New Session. : '||l_errmsg||' **********');
      else
        select fnd_profile.value('XXFND_DEBUG_FILE') into  l_dbgpath from dual;
        if l_dbgpath is null then
          g_debug_init := true;
          raise utl_file.invalid_path;
        end if;

        -- Seperate the filename from the directory
          l_strlen := length(l_dbgpath);
        l_dbgfile := l_dbgpath;
        l_dir_separator := '/';
        --Check if separator exits, could be different depending on os
        l_ndx := instr(l_dbgfile, l_dir_separator);
        if ( l_ndx = 0 ) then
          l_dir_separator := '\';
        end if;

        loop
          l_ndx := instr(l_dbgfile, l_dir_separator);
        exit when ((l_ndx = 0) or (l_ndx is null));
          l_dbgfile := substr(l_dbgfile, l_ndx+1, l_strlen - l_ndx + 1);
        end loop;

        l_dbgdir := substr(l_dbgpath, 1, l_strlen - length(l_dbgfile) - 1);

                if g_file_postfix is not null THEN
                   l_ndx := instr(l_dbgfile, '.');
                   IF l_ndx > 0 THEN
                       l_dbgfile := substr(l_dbgfile,1,l_ndx-1) || '_' || g_file_postfix || substr(l_dbgfile,l_ndx);
                   ELSE
                       l_dbgfile := l_dbgfile || '_' || g_file_postfix || '.log';
                   END IF;
                end if;
        -- Open Log file
          g_fd := utl_file.fopen(l_dbgdir, l_dbgfile, 'a');
          utl_file.put_line(g_fd, '');
          utl_file.put_line(g_fd, ' ******** New Session. : '||l_errmsg||' **********');
    end if;

      g_debug_init := true;

  exception
    when utl_file.INVALID_PATH then
      g_file_dbg_on := 0;
    when others then
    g_file_dbg_on := 0;
  END log_init;

  PROCEDURE log_file( p_msg       IN  VARCHAR2)
  IS
  BEGIN

    if (g_file_dbg_on = 1) then
    --If called from a concurrent program add msg to FND log
      if ( g_cp_flag > 0 AND g_debug_mode <> 'FILEONLY') then
        FND_FILE.put_line(FND_FILE.LOG, p_msg);
      else
        utl_file.put_line(g_fd, p_msg);
        utl_file.fflush(g_fd);
      end if;
    end if;

  exception
    when others then
    NULL;
  END log_file;

  Procedure log( p_msg      IN VARCHAR2,
                 p_level    IN NUMBER   DEFAULT 1,
                 p_module   IN VARCHAR2 DEFAULT 'CUX')
  IS
  BEGIN
    IF l_debug <> 'Y' THEN
      RETURN;
    END IF;

    IF NOT Fnd_Log.Test(p_level, p_module) THEN
      RETURN;
    END IF;

    IF (g_debug_init = false) THEN
      log_init;
    END IF;

    IF (g_cp_flag > 0) OR (G_DEBUG_MODE = 'FILE' OR G_DEBUG_MODE = 'FILEONLY') THEN
       If instr(p_msg, fnd_api.g_miss_char) > 0 then
          log_file(g_indent_str || g_proc || ' : ' ||Replace(p_msg,fnd_api.g_miss_char,'?'));
       Else
          log_file(g_indent_str || g_proc || ' : ' ||p_msg );
       End if;
    ELSE -- logging into fnd_log_message
       If instr(p_msg, fnd_api.g_miss_char) > 0 then
          Fnd_Log.String(p_level, p_module, g_indent_str || g_proc || ' : ' ||Replace(p_msg,fnd_api.g_miss_char,'?'));
       Else
          Fnd_Log.String(p_level, p_module, g_indent_str || g_proc || ' : ' ||p_msg);
       End if;
    END IF;
  END log;

END XXFND_DEBUG;
/
