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
    --���Org_id�Ƿ������ʱ�� mo_glob_org_access_tmp��check_valid_org��check_access���ƣ�check_valid_org�����ܳ�������Ϣ
  
  SELECT mo_global.get_current_org_id
    --INTO v_current_org_id
    FROM dual; 
    --��ȡ��ǰOrg_id����û��init������ģʽΪS��A���򷵻ص�ǰOrg_id������init���ҷ���ģʽΪS,�򷵻�init��org_id
  
  SELECT mo_global.get_access_mode
    --INTO v_access_mode
    FROM dual; 
    --��ȡ��ǰOrg����ģʽ
  
  SELECT mo_global.get_ou_count
    --INTO v_ou_count
    FROM dual; 
    --��ȡ��ǰ����֯���ʿɷ��ʵ�OU��;��û��init����Ϊ��
  
  SELECT mo_global.get_valid_org(101)
    --INTO v_org_id
    FROM dual; 
    --��֤������Org_id����û��init���ҷ���ģʽΪS��������init���򷵻�Org_id
  
  SELECT mo_global.is_mo_init_done
    --INTO v_mo_init_done
    FROM dual; 
    --��֤MO�Ƿ��ѳ�ʼ����Y/N;����init����û��init������ģʽΪS,�򷵻�Y
  
  SELECT mo_global.get_ou_name(101)
    --INTO v_ou_name
    FROM dual; 
    --��ȡ��ʱ�� mo_glob_org_access_tmp��Org����
