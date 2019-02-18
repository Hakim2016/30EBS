SELECT /*t.attribute8
      ,t.**/
 t.secondary_inventory 子库,
 t.item_num 物料编码,
 t.item_des 物料描述,
 t.item_categaty 物料描述,
 t.uom 单位,
 t.quantity 数量,
 t.amount 金额,
 --nvl(to_char(t.inv_date,'yyyy-mm-dd hh24:mi:ss'), '库龄超过四年') 入库时间,
 DECODE(nvl(t.attribute7,'-9999'),'-9999',to_char(t.inv_date,'yyyy-mm-dd hh24:mi:ss'), '库龄超过四年') 入库时间
 --,nvl(t.attribute5, '库龄超过四年') 入库时间,
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
