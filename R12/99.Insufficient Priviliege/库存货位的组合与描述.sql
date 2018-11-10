--Get Stock Locators(MTLL) 库存货位的组合与描述
--SELECT cux_flex_pkg.get_mtll_flexfields(p_locator_id => 3950, p_organization_id => 7890, p_return => 'S') locator_name FROM dual;
/*FUNCTION get_mtll_flexfields(p_locator_id      NUMBER,
                             p_organization_id NUMBER,
                             p_return          VARCHAR2 DEFAULT 'S')
  RETURN VARCHAR2 IS
*/
DECLARE
  p_locator_id      NUMBER := 10700;
  p_organization_id NUMBER := 86;
  p_return          VARCHAR2(1) DEFAULT 'S';

  l_concatenated_descriptions VARCHAR2(2000);
  l_success                   BOOLEAN;
  l_concatenated_segments     VARCHAR2(2000);
  c_structure_number          NUMBER;
  c_key_flex_code             VARCHAR2(20);
  c_appl_short_name           VARCHAR2(20);
  l_application_id            NUMBER;
  -- Keeps track of the current delimiter
  l_delim         VARCHAR2(1) := '';
  l_error_message VARCHAR2(1000);
BEGIN
  --
  --Bug: Value &VALUE for the flexfield segment Subinventory does not exist in the value set @VALUE_SET.
  --如果在健弹性域定义的值集中使用了PROFILE，需要初始化赋值之后才行，否则会出现以上错误
  --SELECT FND_PROFILE.VALUE_WNPS('MFG_ORGANIZATION_ID') FROM DUAL;
  --fnd_global.apps_initialize(resp_appl_id => 401, resp_id => 65780, user_id => 1013436);
  IF fnd_profile.value_wnps('MFG_ORGANIZATION_ID') IS NULL THEN
    fnd_profile.put('MFG_ORGANIZATION_ID', p_organization_id);
  END IF;
  c_key_flex_code    := 'MTLL';
  c_appl_short_name  := 'INV';
  c_structure_number := 101;

  SELECT application_id
    INTO l_application_id
    FROM fnd_application_vl a
   WHERE a.application_short_name = c_appl_short_name;

  -- Get the delimiter
  l_delim := fnd_flex_apis.get_segment_delimiter(x_application_id => l_application_id,
                                                 x_id_flex_code   => c_key_flex_code,
                                                 x_id_flex_num    => c_structure_number);
  --参数DATA_SET一定要设置，和物料的键弹性域定义的原理一样：因为INVENTORY_LOCATION_ID在数据库的基表中不是唯一的值
  --SELECT set_defining_column_name,unique_id_column_name,application_table_name FROM fnd_id_flexs WHERE id_flex_code IN ('MTLL', 'MSTK');
  l_success := fnd_flex_keyval.validate_ccid(appl_short_name  => c_appl_short_name,
                                             key_flex_code    => c_key_flex_code,
                                             structure_number => c_structure_number,
                                             data_set         => to_char(p_organization_id), -- Requied
                                             combination_id   => p_locator_id);
  dbms_output.put_line('l_success = ' ||
                       to_char(sys.diutil.bool_to_int(l_success)));
  l_error_message := fnd_flex_keyval.error_message;
  IF l_success THEN
    l_concatenated_descriptions := fnd_flex_keyval.concatenated_descriptions;
    --dbms_output.put_line('Concatenated Descriptions : ' || l_concatenated_descriptions);
  
    l_concatenated_segments := fnd_flex_keyval.concatenated_values;
    --dbms_output.put_line('Concatenated Segments : ' || l_concatenated_segments);
  ELSE
    l_concatenated_segments     := NULL;
    l_concatenated_descriptions := NULL;
    fnd_message.set_name('FND', 'FLEX-SSV EXCEPTION');
    fnd_message.set_token('MSG', l_error_message);
    dbms_output.put_line(fnd_message.get);
    RAISE app_exceptions.application_exception;
  END IF;
  IF p_return = 'S' THEN
    --RETURN(l_concatenated_segments);
    dbms_output.put_line(l_concatenated_segments);
  ELSIF p_return = 'D' THEN
    --RETURN(l_concatenated_descriptions);
    dbms_output.put_line(l_concatenated_descriptions);
  ELSE
    --RETURN(l_concatenated_segments);
    dbms_output.put_line(l_concatenated_segments);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    -- RETURN NULL;
    --dbms_output.put_line(l_concatenated_segments);
    app_exception.raise_exception;
END get_mtll_flexfields;
