DECLARE
  PROCEDURE proc_upgradesequence(v_seqname VARCHAR2, -- 序列的名称  
                                 v_newnum  NUMBER) IS
    -- 需要的NEXTVAL  
    v_error   VARCHAR2(1000);
    ldebug    VARCHAR2(200);
    v_currval NUMBER;
  BEGIN
    ldebug := '1. Get sequnce current value';
    EXECUTE IMMEDIATE 'select ' || v_seqname || '.nextval from dual'
      INTO v_currval;
    dbms_output.put_line(' EXECUTE : ' || 'select ' || v_seqname || '.nextval from dual');
  
    ldebug := '2. Alter this sequence nocache';
    EXECUTE IMMEDIATE 'alter sequence ' || v_seqname || ' nocache';
    dbms_output.put_line(' EXECUTE : ' || 'alter sequence ' || v_seqname || ' nocache');
  
    ldebug := '3. Alter this sequence current value';
    EXECUTE IMMEDIATE 'alter SEQUENCE ' || v_seqname || ' increment by ' || to_char(v_newnum - v_currval - 1) ||
                      ' nocache';
    dbms_output.put_line(' EXECUTE : ' || 'alter SEQUENCE ' || v_seqname || ' increment by ' ||
                         to_char(v_newnum - v_currval - 1) || ' nocache');
  
    ldebug := '4. Get this sequence next value';
    EXECUTE IMMEDIATE 'select ' || v_seqname || '.nextval from dual'
      INTO v_currval;
    dbms_output.put_line(' EXECUTE : ' || 'select ' || v_seqname || '.nextval from dual');
  
    ldebug := '5. Recover this original sequence increment step';
    EXECUTE IMMEDIATE 'alter SEQUENCE ' || v_seqname || ' increment by 1 nocache';
    dbms_output.put_line(' EXECUTE : ' || 'alter SEQUENCE ' || v_seqname || ' increment by 1 nocache');
  EXCEPTION
    WHEN OTHERS THEN
      v_error := SQLERRM;
      dbms_output.put_line(v_error);
  END;

BEGIN
  proc_upgradesequence(v_seqname => 'XXOM.XXOM_CUSTOMER_HFG_INTF_ROW_S', -- 序列的名称  
                       v_newnum  => 27644);
END;
