-- ��η���standard API �Ĵ�����Ϣ

--lv_msg_count :  ΪAPI���ز���,Ϊ��Ϣ�ĸ�����

--������Ϣ�ľ��������ѭ������Ҫ����Ӧ�������Ӵ��������Ϣ���ݾͶ࣬��֮����.
BEGIN
  IF lv_msg_count > 0 THEN
    lv_mesg := chr(10) || substr(fnd_msg_pub.get(fnd_msg_pub.g_first, fnd_api.g_false), 1, 512);
    FOR i IN 1 .. (lv_msg_count - 3)
    LOOP
      lv_mesg := lv_mesg || chr(10) || substr(fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_false), 1, 512);
    END LOOP;
  END IF;
  fnd_msg_pub.delete_msg();
END;
