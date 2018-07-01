CREATE OR REPLACE PACKAGE apps.xxfnd_key_flex_field_util IS

  -- Author  : 70588596
  -- Created : 2015/12/15 10:13:55
  -- Purpose : 

  /*==================================================
  Program Name:
      get_key_concatenated_desc
  Description:
      Get key flex concatenated description.
  History:
      1.00 20/08/2009 hand-china
  ==================================================*/
  FUNCTION get_key_concatenated_desc(p_appl_short_name VARCHAR2,
                                     p_key_flex_code   VARCHAR2,
                                     p_coa_id          NUMBER,
                                     p_accid           NUMBER,
                                     p_data_set        NUMBER DEFAULT NULL) RETURN VARCHAR2;

  /*==================================================
  Program Name:
      get_key_concatenated_value
  Description:
      Get key flex concatenated value.
  History:
      1.00 20/08/2009 hand-china
       2.00  2011-12-15 tyne.zeng Updated
  ==================================================*/
  FUNCTION get_key_concatenated_value(p_appl_short_name  VARCHAR2,
                                      p_key_flex_code    VARCHAR2,
                                      p_structure_number NUMBER,
                                      p_combination_id   NUMBER,
                                      p_data_set         NUMBER DEFAULT NULL) RETURN VARCHAR2;

  /*==================================================
  Program Name:
      get_key_seg_value
  Description:
      Get key flex concatenated value for one segment of all .
  History:
      1.00 20/08/2009 hand-china
       2.00  2011-12-15 tyne.zeng Updated
  ==================================================*/
  FUNCTION get_key_seg_value(p_appl_short_name  VARCHAR2,
                             p_key_flex_code    VARCHAR2,
                             p_structure_number NUMBER,
                             p_combination_id   NUMBER,
                             p_seg_num          NUMBER,
                             p_data_set         NUMBER DEFAULT NULL) RETURN VARCHAR2;

  /*==================================================
  Program Name:
      get_key_seg_desc
  Description:
      Get key flex concatenated description for one segment of all .
  History:
       1.00 20/08/2009 hand-china
       2.00  2011-12-15 tyne.zeng Updated
  ==================================================*/
  FUNCTION get_key_seg_desc(p_appl_short_name  VARCHAR2,
                            p_key_flex_code    VARCHAR2,
                            p_structure_number NUMBER,
                            p_combination_id   NUMBER,
                            p_seg_num          NUMBER,
                            p_data_set         NUMBER DEFAULT NULL) RETURN VARCHAR2;

  /*==================================================
  Program Name:
      get_key_seg_delimiter
  Description:
      Get key flex concatenated segment_delimiter .
  History:
       1.00  2011-12-15 tyne.zeng 
  ==================================================*/
  FUNCTION get_key_seg_delimiter(p_appl_short_name  VARCHAR2,
                                 p_key_flex_code    VARCHAR2,
                                 p_structure_number NUMBER,
                                 p_combination_id   NUMBER,
                                 p_seg_num          NUMBER,
                                 p_data_set         NUMBER DEFAULT NULL) RETURN VARCHAR2;

  /*==================================================
  Program Name:
      get_key_concatenated_desc
  Description:
      Get key flex concatenated description for one segment of all .
  History:
       1.00 20/08/2009 hand-china
       2.00  2011-12-15 tyne.zeng Updated
  ==================================================*/
  FUNCTION get_key_seg_info(p_appl_short_name  VARCHAR2,
                            p_key_flex_code    VARCHAR2,
                            p_structure_number NUMBER,
                            p_column_name      VARCHAR2,
                            p_info_name        VARCHAR2) RETURN VARCHAR2;

  /*==================================================
  Program Name:
      get_key_seg_count
  Description:
      Get key flex segment count.
  History:
       1.00 20/08/2009 hand-china
       2.00  2011-12-15 tyne.zeng Updated
  ==================================================*/
  FUNCTION get_key_seg_count(p_appl_short_name  VARCHAR2,
                             p_key_flex_code    VARCHAR2,
                             p_structure_number NUMBER) RETURN NUMBER;

  /*==================================================
  Program Name:
      proc_test
  Description:
      key flex Test.
  History:
  
  ==================================================*/
  PROCEDURE proc_test;

END xxfnd_key_flex_field_util;
/
CREATE OR REPLACE PACKAGE BODY apps.xxfnd_key_flex_field_util IS

  /*==================================================
  Program Name:
      get_key_concatenated_desc
  Description:
      Get key flex concatenated description.
  History:
      1.00 20/08/2009 hand-china
  ==================================================*/
  FUNCTION get_key_concatenated_desc(p_appl_short_name VARCHAR2,
                                     p_key_flex_code   VARCHAR2,
                                     p_coa_id          NUMBER,
                                     p_accid           NUMBER,
                                     p_data_set        NUMBER DEFAULT NULL) RETURN VARCHAR2 IS
    lv_desc  VARCHAR2(2000);
    lb_value BOOLEAN;
  BEGIN
  
    lb_value := fnd_flex_keyval.validate_ccid(appl_short_name  => p_appl_short_name,
                                              key_flex_code    => p_key_flex_code,
                                              structure_number => p_coa_id,
                                              combination_id   => p_accid,
                                              data_set         => p_data_set);
  
    IF lb_value THEN
      lv_desc := fnd_flex_keyval.concatenated_descriptions;
    END IF;
  
    RETURN lv_desc;
  END get_key_concatenated_desc;

  /*==================================================
  Program Name:
      get_key_concatenated_value
  Description:
      Get key flex concatenated value.
  History:
      1.00 20/08/2009 hand-china
       2.00  2011-12-15 tyne.zeng Updated
  ==================================================*/
  FUNCTION get_key_concatenated_value(p_appl_short_name  VARCHAR2,
                                      p_key_flex_code    VARCHAR2,
                                      p_structure_number NUMBER,
                                      p_combination_id   NUMBER,
                                      p_data_set         NUMBER DEFAULT NULL) RETURN VARCHAR2 IS
    lv_code  VARCHAR2(2000);
    lb_value BOOLEAN;
  BEGIN
  
    lb_value := fnd_flex_keyval.validate_ccid(appl_short_name  => p_appl_short_name,
                                              key_flex_code    => p_key_flex_code,
                                              structure_number => p_structure_number,
                                              combination_id   => p_combination_id,
                                              data_set         => p_data_set);
  
    IF lb_value THEN
      lv_code := fnd_flex_keyval.concatenated_values;
    END IF;
  
    RETURN lv_code;
  END get_key_concatenated_value;

  /*==================================================
  Program Name:
      get_key_seg_value
  Description:
      Get key flex concatenated value for one segment of all .
  History:
      1.00 20/08/2009 hand-china
       2.00  2011-12-15 tyne.zeng Updated
  ==================================================*/
  FUNCTION get_key_seg_value(p_appl_short_name  VARCHAR2,
                             p_key_flex_code    VARCHAR2,
                             p_structure_number NUMBER,
                             p_combination_id   NUMBER,
                             p_seg_num          NUMBER,
                             p_data_set         NUMBER DEFAULT NULL) RETURN VARCHAR2 IS
    lv_code  VARCHAR2(2000);
    lb_value BOOLEAN;
  BEGIN
  
    lb_value := fnd_flex_keyval.validate_ccid(appl_short_name  => p_appl_short_name,
                                              key_flex_code    => p_key_flex_code,
                                              structure_number => p_structure_number,
                                              combination_id   => p_combination_id,
                                              data_set         => p_data_set);
  
    IF lb_value THEN
      lv_code := fnd_flex_keyval.segment_value(p_seg_num);
    END IF;
  
    RETURN lv_code;
  END get_key_seg_value;

  /*==================================================
  Program Name:
      get_key_seg_desc
  Description:
      Get key flex concatenated description for one segment of all .
  History:
       1.00 20/08/2009 hand-china
       2.00  2011-12-15 tyne.zeng Updated
  ==================================================*/
  FUNCTION get_key_seg_desc(p_appl_short_name  VARCHAR2,
                            p_key_flex_code    VARCHAR2,
                            p_structure_number NUMBER,
                            p_combination_id   NUMBER,
                            p_seg_num          NUMBER,
                            p_data_set         NUMBER DEFAULT NULL) RETURN VARCHAR2 IS
    lv_code  VARCHAR2(2000);
    lb_value BOOLEAN;
  BEGIN
  
    lb_value := fnd_flex_keyval.validate_ccid(appl_short_name  => p_appl_short_name,
                                              key_flex_code    => p_key_flex_code,
                                              structure_number => p_structure_number,
                                              combination_id   => p_combination_id,
                                              data_set         => p_data_set);
  
    IF lb_value THEN
      lv_code := fnd_flex_keyval.segment_description(p_seg_num);
    END IF;
  
    RETURN lv_code;
  END get_key_seg_desc;

  /*==================================================
  Program Name:
      get_key_seg_delimiter
  Description:
      Get key flex concatenated segment_delimiter .
  History:
       1.00  2011-12-15 tyne.zeng 
  ==================================================*/
  FUNCTION get_key_seg_delimiter(p_appl_short_name  VARCHAR2,
                                 p_key_flex_code    VARCHAR2,
                                 p_structure_number NUMBER,
                                 p_combination_id   NUMBER,
                                 p_seg_num          NUMBER,
                                 p_data_set         NUMBER DEFAULT NULL) RETURN VARCHAR2 IS
    lv_code  VARCHAR2(2000);
    lb_value BOOLEAN;
  BEGIN
  
    lb_value := fnd_flex_keyval.validate_ccid(appl_short_name  => p_appl_short_name,
                                              key_flex_code    => p_key_flex_code,
                                              structure_number => p_structure_number,
                                              combination_id   => p_combination_id,
                                              data_set         => p_data_set);
  
    IF lb_value THEN
      lv_code := fnd_flex_keyval.segment_delimiter;
    END IF;
  
    RETURN lv_code;
  END get_key_seg_delimiter;

  /*==================================================
  Program Name:
      get_key_concatenated_desc
  Description:
      Get key flex concatenated description for one segment of all .
  History:
       1.00 20/08/2009 hand-china
       2.00  2011-12-15 tyne.zeng Updated
  ==================================================*/
  FUNCTION get_key_seg_info(p_appl_short_name  VARCHAR2,
                            p_key_flex_code    VARCHAR2,
                            p_structure_number NUMBER,
                            p_column_name      VARCHAR2,
                            p_info_name        VARCHAR2) RETURN VARCHAR2 IS
    CURSOR cur_seg IS
      SELECT MAX(decode(p_info_name,
                        'FLEX_VALUE_SET_ID',
                        to_char(fis.flex_value_set_id),
                        'FLEX_VALUE_SET_NAME',
                        fvs.flex_value_set_name,
                        'SEGMENT_NAME',
                        fis.segment_name,
                        'SEGMENT_NUM',
                        to_char(fis.segment_num),
                        'FORM_ABOVE_PROMPT',
                        fis.form_above_prompt,
                        'FORM_LEFT_PROMPT',
                        fis.form_left_prompt)) res_value
        FROM fnd_flex_value_sets     fvs,
             fnd_id_flex_segments_vl fis,
             fnd_application         fa
       WHERE fvs.flex_value_set_id = fis.flex_value_set_id
         AND fis.application_id = fa.application_id
         AND fa.application_short_name = p_appl_short_name
         AND fis.enabled_flag = 'Y'
         AND fis.id_flex_code = p_key_flex_code
         AND fis.id_flex_num = p_structure_number
         AND fis.application_column_name = p_column_name;
    l_res VARCHAR2(240);
  BEGIN
    OPEN cur_seg;
    FETCH cur_seg
      INTO l_res;
    CLOSE cur_seg;
    RETURN l_res;
  END get_key_seg_info;

  /*==================================================
  Program Name:
      get_key_seg_count
  Description:
      Get key flex segment count.
  History:
       1.00 20/08/2009 hand-china
       2.00  2011-12-15 tyne.zeng Updated
  ==================================================*/
  FUNCTION get_key_seg_count(p_appl_short_name  VARCHAR2,
                             p_key_flex_code    VARCHAR2,
                             p_structure_number NUMBER) RETURN NUMBER IS
    l_count NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO l_count
      FROM fnd_id_flex_segments fis,
           fnd_application      fa
     WHERE fis.application_id = fa.application_id
       AND fis.enabled_flag = 'Y'
       AND fis.id_flex_num = p_structure_number
       AND fis.id_flex_code = p_key_flex_code
       AND fa.application_short_name = p_appl_short_name;
  
    RETURN l_count;
  END get_key_seg_count;

  /*==================================================
  Program Name:
      proc_test
  Description:
      key flex Test.
  History:
  
  ==================================================*/
  PROCEDURE proc_test IS
    l_appl_short_name VARCHAR2(200) := 'INV';
    l_key_flex_code   VARCHAR2(200) := 'MTLL';
    l_coa_id          NUMBER := 101;
    l_locator_id      NUMBER;
  
    l_key_seg_count          NUMBER;
    l_key_concatenated_value VARCHAR2(200);
    l_key_concatenated_desc  VARCHAR2(200);
    l_organization_id        NUMBER;
  
  BEGIN
    -- Locator
    l_appl_short_name := 'INV';
    l_key_flex_code   := 'MTLL';
    l_coa_id          := 101;
    l_locator_id      := 56099;
    l_organization_id := 86;
  
    l_key_seg_count := xxfnd_key_flex_field_util.get_key_seg_count(p_appl_short_name  => l_appl_short_name,
                                                                   p_key_flex_code    => l_key_flex_code,
                                                                   p_structure_number => l_coa_id);
    dbms_output.put_line(' l_key_seg_count : ' || l_key_seg_count);
  
    fnd_profile.put('MFG_ORGANIZATION_ID', to_char(l_organization_id));
    l_key_concatenated_value := xxfnd_key_flex_field_util.get_key_concatenated_value(p_appl_short_name  => l_appl_short_name,
                                                                                     p_key_flex_code    => l_key_flex_code,
                                                                                     p_structure_number => l_coa_id,
                                                                                     p_combination_id   => l_locator_id,
                                                                                     p_data_set         => l_organization_id);
    dbms_output.put_line(' l_key_concatenated_value : ' || l_key_concatenated_value);
    l_key_concatenated_desc := xxfnd_key_flex_field_util.get_key_concatenated_desc(p_appl_short_name => l_appl_short_name,
                                                                                   p_key_flex_code   => l_key_flex_code,
                                                                                   p_coa_id          => l_coa_id,
                                                                                   p_accid           => l_locator_id,
                                                                                   p_data_set        => l_organization_id);
  
    dbms_output.put_line(' l_key_concatenated_desc : ' || l_key_concatenated_desc);
  END proc_test;
END xxfnd_key_flex_field_util;
/
