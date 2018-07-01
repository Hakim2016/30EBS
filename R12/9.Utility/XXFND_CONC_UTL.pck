CREATE OR REPLACE PACKAGE XXFND_CONC_UTL AS
  /*==================================================
  Copyright (C) HAND Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
  /*==================================================
   PROGRAM NAME:
       XXFND_CONC_UTL
   DESCRIPTION:
       This program provide common API for concurrent procedure
   HISTORY:
     1.00   2009-11-04   Hand   Creation

  ==============================================*/

  PROCEDURE log_msg(p_msg IN VARCHAR2);
  PROCEDURE out_msg(p_msg IN VARCHAR2);
  PROCEDURE log_header;
  PROCEDURE log_footer;

  PROCEDURE log_message_list;
  FUNCTION get_message(p_appl_name    IN VARCHAR2,
                       p_message_name IN VARCHAR2,
                       p_token1       IN VARCHAR2 DEFAULT NULL,
                       p_token1_value IN VARCHAR2 DEFAULT NULL,
                       p_token2       IN VARCHAR2 DEFAULT NULL,
                       p_token2_value IN VARCHAR2 DEFAULT NULL,
                       p_token3       IN VARCHAR2 DEFAULT NULL,
                       p_token3_value IN VARCHAR2 DEFAULT NULL,
                       p_token4       IN VARCHAR2 DEFAULT NULL,
                       p_token4_value IN VARCHAR2 DEFAULT NULL,
                       p_token5       IN VARCHAR2 DEFAULT NULL,
                       p_token5_value IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2;

END xxfnd_conc_utl;
/
CREATE OR REPLACE PACKAGE BODY XXFND_CONC_UTL AS
  /*==================================================
  Copyright (C) HAND Enterprise Solutions Co.,Ltd.
             AllRights Reserved
  ==================================================*/
  /*==================================================
   PROGRAM NAME:
       XXFND_CONC_UTL
   DESCRIPTION:
       This program provide common API for concurrent procedure
   HISTORY:
     1.00   2009-11-04   Hand   Creation

  ==============================================*/
  PROCEDURE log_msg(p_msg IN VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.log, p_msg);
  END log_msg;

  PROCEDURE out_msg(p_msg IN VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.output, p_msg);
  END out_msg;

  PROCEDURE log_header IS
    CURSOR c_conc(p_request_id NUMBER) IS
      SELECT fdfcuv.end_user_column_name end_user_column_name
        FROM fnd_descr_flex_col_usage_vl fdfcuv
            ,fnd_concurrent_programs     fcp
            ,fnd_concurrent_requests     fcr
       WHERE fcp.application_id = fcr.program_application_id
         AND fcp.concurrent_program_id = fcr.concurrent_program_id
         AND fdfcuv.application_id = fcp.application_id
         AND fdfcuv.descriptive_flexfield_name =
             '$SRS$.' || fcp.concurrent_program_name
         AND fcr.request_id = p_request_id
       ORDER BY fdfcuv.column_seq_num;

    CURSOR c_arg_val(p_request_id NUMBER) IS
      SELECT fcr.argument1    argument1
            ,fcr.argument2    argument2
            ,fcr.argument3    argument3
            ,fcr.argument4    argument4
            ,fcr.argument5    argument5
            ,fcr.argument6    argument6
            ,fcr.argument7    argument7
            ,fcr.argument8    argument8
            ,fcr.argument9    argument9
            ,fcr.argument10   argument10
            ,fcr.argument11   argument11
            ,fcr.argument12   argument12
            ,fcr.argument13   argument13
            ,fcr.argument14   argument14
            ,fcr.argument15   argument15
            ,fcr.argument16   argument16
            ,fcr.argument17   argument17
            ,fcr.argument18   argument18
            ,fcr.argument19   argument19
            ,fcr.argument20   argument20
            ,fcr.argument21   argument21
            ,fcr.argument22   argument22
            ,fcr.argument23   argument23
            ,fcr.argument24   argument24
            ,fcr.argument25   argument25
            ,fcra.argument26  argument26
            ,fcra.argument27  argument27
            ,fcra.argument28  argument28
            ,fcra.argument29  argument29
            ,fcra.argument30  argument30
            ,fcra.argument31  argument31
            ,fcra.argument32  argument32
            ,fcra.argument33  argument33
            ,fcra.argument34  argument34
            ,fcra.argument35  argument35
            ,fcra.argument36  argument36
            ,fcra.argument37  argument37
            ,fcra.argument38  argument38
            ,fcra.argument39  argument39
            ,fcra.argument40  argument40
            ,fcra.argument41  argument41
            ,fcra.argument42  argument42
            ,fcra.argument43  argument43
            ,fcra.argument44  argument44
            ,fcra.argument45  argument45
            ,fcra.argument46  argument46
            ,fcra.argument47  argument47
            ,fcra.argument48  argument48
            ,fcra.argument49  argument49
            ,fcra.argument50  argument50
            ,fcra.argument51  argument51
            ,fcra.argument52  argument52
            ,fcra.argument53  argument53
            ,fcra.argument54  argument54
            ,fcra.argument55  argument55
            ,fcra.argument56  argument56
            ,fcra.argument57  argument57
            ,fcra.argument58  argument58
            ,fcra.argument59  argument59
            ,fcra.argument60  argument60
            ,fcra.argument61  argument61
            ,fcra.argument62  argument62
            ,fcra.argument63  argument63
            ,fcra.argument64  argument64
            ,fcra.argument65  argument65
            ,fcra.argument66  argument66
            ,fcra.argument67  argument67
            ,fcra.argument68  argument68
            ,fcra.argument69  argument69
            ,fcra.argument70  argument70
            ,fcra.argument71  argument71
            ,fcra.argument72  argument72
            ,fcra.argument73  argument73
            ,fcra.argument74  argument74
            ,fcra.argument75  argument75
            ,fcra.argument76  argument76
            ,fcra.argument77  argument77
            ,fcra.argument78  argument78
            ,fcra.argument79  argument79
            ,fcra.argument80  argument80
            ,fcra.argument81  argument81
            ,fcra.argument82  argument82
            ,fcra.argument83  argument83
            ,fcra.argument84  argument84
            ,fcra.argument85  argument85
            ,fcra.argument86  argument86
            ,fcra.argument87  argument87
            ,fcra.argument88  argument88
            ,fcra.argument89  argument89
            ,fcra.argument90  argument90
            ,fcra.argument91  argument91
            ,fcra.argument92  argument92
            ,fcra.argument93  argument93
            ,fcra.argument94  argument94
            ,fcra.argument95  argument95
            ,fcra.argument96  argument96
            ,fcra.argument97  argument97
            ,fcra.argument98  argument98
            ,fcra.argument99  argument99
            ,fcra.argument100 argument100
        FROM fnd_concurrent_requests fcr, fnd_conc_request_arguments fcra
       WHERE fcr.request_id = fcra.request_id(+)
         AND fcr.request_id = p_request_id;

    TYPE type_argument_tbl IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;

    l_arg_val_tbl type_argument_tbl;
    l_request_id  NUMBER := fnd_global.conc_request_id;

    i          NUMBER := 0;
    l_datetime VARCHAR2(30);
  BEGIN
    IF l_request_id <= 0 THEN
      RETURN;
    END IF;

    FOR i IN 1 .. 100 LOOP
      l_arg_val_tbl(i) := NULL;
    END LOOP;

    OPEN c_arg_val(l_request_id);
    FETCH c_arg_val
      INTO l_arg_val_tbl(1)
          ,l_arg_val_tbl(2)
          ,l_arg_val_tbl(3)
          ,l_arg_val_tbl(4)
          ,l_arg_val_tbl(5)
          ,l_arg_val_tbl(6)
          ,l_arg_val_tbl(7)
          ,l_arg_val_tbl(8)
          ,l_arg_val_tbl(9)
          ,l_arg_val_tbl(10)
          ,l_arg_val_tbl(11)
          ,l_arg_val_tbl(12)
          ,l_arg_val_tbl(13)
          ,l_arg_val_tbl(14)
          ,l_arg_val_tbl(15)
          ,l_arg_val_tbl(16)
          ,l_arg_val_tbl(17)
          ,l_arg_val_tbl(18)
          ,l_arg_val_tbl(19)
          ,l_arg_val_tbl(20)
          ,l_arg_val_tbl(21)
          ,l_arg_val_tbl(22)
          ,l_arg_val_tbl(23)
          ,l_arg_val_tbl(24)
          ,l_arg_val_tbl(25)
          ,l_arg_val_tbl(26)
          ,l_arg_val_tbl(27)
          ,l_arg_val_tbl(28)
          ,l_arg_val_tbl(29)
          ,l_arg_val_tbl(30)
          ,l_arg_val_tbl(31)
          ,l_arg_val_tbl(32)
          ,l_arg_val_tbl(33)
          ,l_arg_val_tbl(34)
          ,l_arg_val_tbl(35)
          ,l_arg_val_tbl(36)
          ,l_arg_val_tbl(37)
          ,l_arg_val_tbl(38)
          ,l_arg_val_tbl(39)
          ,l_arg_val_tbl(40)
          ,l_arg_val_tbl(41)
          ,l_arg_val_tbl(42)
          ,l_arg_val_tbl(43)
          ,l_arg_val_tbl(44)
          ,l_arg_val_tbl(45)
          ,l_arg_val_tbl(46)
          ,l_arg_val_tbl(47)
          ,l_arg_val_tbl(48)
          ,l_arg_val_tbl(49)
          ,l_arg_val_tbl(50)
          ,l_arg_val_tbl(51)
          ,l_arg_val_tbl(52)
          ,l_arg_val_tbl(53)
          ,l_arg_val_tbl(54)
          ,l_arg_val_tbl(55)
          ,l_arg_val_tbl(56)
          ,l_arg_val_tbl(57)
          ,l_arg_val_tbl(58)
          ,l_arg_val_tbl(59)
          ,l_arg_val_tbl(60)
          ,l_arg_val_tbl(61)
          ,l_arg_val_tbl(62)
          ,l_arg_val_tbl(63)
          ,l_arg_val_tbl(64)
          ,l_arg_val_tbl(65)
          ,l_arg_val_tbl(66)
          ,l_arg_val_tbl(67)
          ,l_arg_val_tbl(68)
          ,l_arg_val_tbl(69)
          ,l_arg_val_tbl(70)
          ,l_arg_val_tbl(71)
          ,l_arg_val_tbl(72)
          ,l_arg_val_tbl(73)
          ,l_arg_val_tbl(74)
          ,l_arg_val_tbl(75)
          ,l_arg_val_tbl(76)
          ,l_arg_val_tbl(77)
          ,l_arg_val_tbl(78)
          ,l_arg_val_tbl(79)
          ,l_arg_val_tbl(80)
          ,l_arg_val_tbl(81)
          ,l_arg_val_tbl(82)
          ,l_arg_val_tbl(83)
          ,l_arg_val_tbl(84)
          ,l_arg_val_tbl(85)
          ,l_arg_val_tbl(86)
          ,l_arg_val_tbl(87)
          ,l_arg_val_tbl(88)
          ,l_arg_val_tbl(89)
          ,l_arg_val_tbl(90)
          ,l_arg_val_tbl(91)
          ,l_arg_val_tbl(92)
          ,l_arg_val_tbl(93)
          ,l_arg_val_tbl(94)
          ,l_arg_val_tbl(95)
          ,l_arg_val_tbl(96)
          ,l_arg_val_tbl(97)
          ,l_arg_val_tbl(98)
          ,l_arg_val_tbl(99)
          ,l_arg_val_tbl(100);
    CLOSE c_arg_val;

    i := 1;

    log_msg('Concurrent Parameter :');
    log_msg('----------------------------------------');
    FOR c IN c_conc(l_request_id) LOOP
      fnd_file.put_line(fnd_file.log,
                        rpad(c.end_user_column_name, 30) || ' : ' ||
                        l_arg_val_tbl(i));
      i := i + 1;
    END LOOP;

    -- concurrent begin datetime
    l_datetime := to_char(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'); --to_char(systimestamp,'YYYY-MM-DD HH24:MI:SSXFF5')
    log_msg('----------------------------------------');
    log_msg('Concurrent begin at : ' || l_datetime);

  EXCEPTION
    WHEN OTHERS THEN
      -- don't raise error
      NULL;
  END log_header;

  PROCEDURE log_footer IS
    l_datetime VARCHAR2(30);
  BEGIN
    -- concurrent begin datetime
    l_datetime := to_char(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'); --to_char(systimestamp,'YYYY-MM-DD HH24:MI:SSXFF5')
    log_msg('----------------------------------------');
    log_msg('Concurrent end at : ' || l_datetime);
  END log_footer;

  PROCEDURE log_message_list IS
    l_msg_index NUMBER;
    l_msg_data  VARCHAR2(2000);
  BEGIN
    IF (fnd_msg_pub.count_msg > 0) THEN
      log_msg('Error Message Stack :');
      log_msg('----------------------------------------');
      FOR i IN 1 .. fnd_msg_pub.count_msg LOOP
        fnd_msg_pub.get(p_msg_index     => i,
                        p_encoded       => fnd_api.g_false,
                        p_data          => l_msg_data,
                        p_msg_index_out => l_msg_index);
        fnd_file.put_line(fnd_file.log, l_msg_data);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END log_message_list;

  FUNCTION get_message(p_appl_name    IN VARCHAR2,
                       p_message_name IN VARCHAR2,
                       p_token1       IN VARCHAR2 DEFAULT NULL,
                       p_token1_value IN VARCHAR2 DEFAULT NULL,
                       p_token2       IN VARCHAR2 DEFAULT NULL,
                       p_token2_value IN VARCHAR2 DEFAULT NULL,
                       p_token3       IN VARCHAR2 DEFAULT NULL,
                       p_token3_value IN VARCHAR2 DEFAULT NULL,
                       p_token4       IN VARCHAR2 DEFAULT NULL,
                       p_token4_value IN VARCHAR2 DEFAULT NULL,
                       p_token5       IN VARCHAR2 DEFAULT NULL,
                       p_token5_value IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2 IS
    l_message       VARCHAR2(1000);
    l_data          VARCHAR2(1000);
    l_msg_index_out NUMBER;
  BEGIN
    fnd_message.clear;
    fnd_message.set_name(p_appl_name, p_message_name);

    IF p_token1 IS NOT NULL THEN
      fnd_message.set_token(p_token1, p_token1_value);
    END IF;
    IF p_token2 IS NOT NULL THEN
      fnd_message.set_token(p_token2, p_token2_value);
    END IF;
    IF p_token3 IS NOT NULL THEN
      fnd_message.set_token(p_token3, p_token3_value);
    END IF;
    IF p_token4 IS NOT NULL THEN
      fnd_message.set_token(p_token4, p_token4_value);
    END IF;
    IF p_token5 IS NOT NULL THEN
      fnd_message.set_token(p_token5, p_token5_value);
    END IF;
    fnd_msg_pub.add;
    FOR i IN 1 .. fnd_msg_pub.count_msg LOOP
      fnd_msg_pub.get(p_msg_index     => i,
                      p_encoded       => 'F',
                      p_data          => l_data,
                      p_msg_index_out => l_msg_index_out);
      l_message := l_message || ' ' || l_data;
    END LOOP;
    RETURN l_message;
  END get_message;

END xxfnd_conc_utl;
/
