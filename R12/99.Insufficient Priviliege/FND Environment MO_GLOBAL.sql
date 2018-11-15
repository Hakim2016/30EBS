BEGIN
  fnd_global.apps_initialize(user_id      => 4270,
                             resp_id      => 50676,
                             resp_appl_id => 660);
  mo_global.init('AR');
  --mo_global.init('M');
  --mo_global.init('AR');
  --MO_GLOBAL.SET_POLICY_CONTEXT(P_ACCESS_MODE => 'S', P_ORG_ID => 84);
  
END;

SELECT * FROM mo_glob_org_access_tmp tmp;

  SELECT mo_global.check_access(101)
    --INTO v_check_access
    FROM dual; 
    --检查Org_id是否存在临时表 mo_glob_org_access_tmp；check_valid_org与check_access类似，check_valid_org可以跑出错误信息
  
  SELECT mo_global.get_current_org_id
    --INTO v_current_org_id
    FROM dual; 
    --获取当前Org_id；若没有init，访问模式为S或A，则返回当前Org_id，若有init，且访问模式为S,则返回init的org_id
  
  SELECT mo_global.get_access_mode
    --INTO v_access_mode
    FROM dual; 
    --获取当前Org访问模式
  
  SELECT mo_global.get_ou_count
    --INTO v_ou_count
    FROM dual; 
    --获取当前多组织访问可访问的OU数;若没有init，则为空
  
  SELECT mo_global.get_valid_org(101)
    --INTO v_org_id
    FROM dual; 
    --验证并返回Org_id；若没有init，且访问模式为S；或者有init，则返回Org_id
  
  SELECT mo_global.is_mo_init_done
    --INTO v_mo_init_done
    FROM dual; 
    --验证MO是否已初始化，Y/N;若有init或者没有init但访问模式为S,则返回Y
  
  SELECT mo_global.get_ou_name(101)
    --INTO v_ou_name
    FROM dual; 
    --获取临时表 mo_glob_org_access_tmp中Org名称
