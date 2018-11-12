/*select *  from BOM.BOM_EXPLOSION_TEMP t;*/

DECLARE
  l_session_id   NUMBER;
  g_mfg_group_id NUMBER;
  l_err_msg      VARCHAR2(100);
  l_error_code   VARCHAR2(100);
BEGIN
  SELECT bom_explosion_temp_s.nextval INTO g_mfg_group_id FROM dual;
  SELECT bom_explosion_temp_session_s.nextval INTO l_session_id FROM dual;

  bompexpl.exploder_userexit(verify_flag       => 0,
                             org_id            => 86,
                             order_by          => 1,
                             grp_id            => g_mfg_group_id,
                             session_id        => l_session_id,
                             levels_to_explode => 10,
                             bom_or_eng        => 1, --l_bom_or_eng,
                             impl_flag         => 1,
                             plan_factor_flag  => 2,
                             explode_option    => 2,
                             module            => 2,
                             cst_type_id       => -1,
                             std_comp_flag     => 2,
                             expl_qty          => 1,
                             item_id           => 428659,
                             alt_desg          => '',
                             comp_code         => '',
                             rev_date          => to_char(SYSDATE,
                                                          'DD-MON-YY HH24:MI'),
                             err_msg           => l_err_msg,
                             ERROR_CODE        => l_error_code);

  IF l_error_code <> '0' THEN
    xxfnd_api.set_message(p_app_name     => 'FND',
                          p_msg_name     => 'FND_GENERIC_MESSAGE',
                          p_token1       => 'MESSAGE',
                          p_token1_value => l_err_msg);
    RAISE fnd_api.g_exc_error;
  END IF;
END;
