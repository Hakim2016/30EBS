SELECT t.secondary_inventory �ӿ�
      ,t.item_num ���ϱ���
      ,t.item_des ��������
      ,t.item_categaty ��������
      ,t.uom ��λ
      
      ,t.quantity ����
      ,t.amount ���
      ,nvl(t.attribute5
          ,'���䳬������') ���ʱ��
          ,trunc(SYSDATE) - trunc(to_date(t.attribute5,'yyyy-mm-dd hh24:mi:ss')) days
      ,t.*
  FROM cux_hnet_inv_huoling_skye t
 WHERE 1 = 1
  -- AND t.quantity <> 0
      --AND t.ITEM_ID = 1768747
   --AND t.group_id = 207
AND t.attribute8 = 9184721--9184597--9183281--9180926--request id
 ORDER BY t.group_id DESC;
