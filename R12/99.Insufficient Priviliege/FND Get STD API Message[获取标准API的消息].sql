-- 如何返回standard API 的错误信息

--lv_msg_count :  为API返回参数,为消息的个数。

--根据消息的具体情况，循环次数要做相应调整。加大次数，消息内容就多，反之则少.
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
