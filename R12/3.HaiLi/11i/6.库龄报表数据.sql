SELECT /*t.attribute8
      ,t.**/
 t.secondary_inventory �ӿ�,
 t.item_num ���ϱ���,
 t.item_des ��������,
 t.item_categaty ��������,
 t.uom ��λ,
 t.quantity ����,
 t.amount ���,
 --nvl(to_char(t.inv_date,'yyyy-mm-dd hh24:mi:ss'), '���䳬������') ���ʱ��,
 DECODE(nvl(t.attribute7,'-9999'),'-9999',to_char(t.inv_date,'yyyy-mm-dd hh24:mi:ss'), '���䳬������') ���ʱ��
 --,nvl(t.attribute5, '���䳬������') ���ʱ��,
 --trunc(SYSDATE) - trunc(to_date(t.attribute5, 'yyyy-mm-dd hh24:mi:ss')) days1
 ,trunc(SYSDATE) - trunc(t.inv_date) days2
 
,
 to_char(t.inv_date, 'yyyy-mm-dd') from_date,
 t.*
  FROM cux_hnet_hl_zhangmb_skye t
 WHERE 1 = 1
   AND t.attribute8 = 9184723 --9184701--9184599--9141354--9141347--9180981--9141322--9141320
--AND t.item_id = 1770847
 ORDER BY t.item_id;
