SELECT qlh.list_header_id,
       qlh.name,
       qlh.description,
       qlh.currency_code,
       qlh.global_flag /*,
       qll.product_attribute_context,
       qll.product_attribute,
       qll.product_attr_value,
       qll.product_attr_val_disp*/
  FROM qp_list_headers_v qlh
 WHERE 1 = 1
   --AND qlh.name = 'Corporate'
   ORDER BY qlh.list_header_id desc
   ;

SELECT qlh.list_header_id,
       qlh.name,
       qlh.description,
       qlh.currency_code,
       qlh.global_flag /*,
       qll.product_attribute_context,
       qll.product_attribute,
       qll.product_attr_value,
       qll.product_attr_val_disp*/
  FROM qp_list_headers_v qlh, qp_list_lines_v qll
 WHERE 1 = 1
   AND qlh.list_header_id = qll.list_header_id
   AND qlh.name = 'Corporate'
 ORDER BY qlh.list_header_id;

SELECT DISTINCT c.list_header_id,
                --c.LIST_SOURCE_CODE,
                --c.
                a.currency_code     currency_code,
                a.name              currency_name,
                a.precision         currency_precision,
                b.start_date_active,
                b.end_date_active
  FROM fnd_currencies_vl a, qp_currency_details b, qp_list_headers_b c
 WHERE 1 = 1
   AND c.list_header_id = 1000 --:b2
   AND b.currency_header_id = c.currency_header_id
   AND a.currency_code = b.to_currency_code
   AND c.list_type_code IN ('PRL', 'AGR')
   AND a.currency_flag = 'Y'
   AND a.enabled_flag = 'Y'
/*AND trunc(:b1) >= trunc(nvl(b.start_date_active, :b1))
AND trunc(:b1) <= trunc(nvl(b.end_date_active, :b1))
AND trunc(:b1) >= trunc(nvl(c.start_date_active, :b1))
AND trunc(:b1) <= trunc(nvl(c.end_date_active, :b1))*/
 ORDER BY a.currency_code;

SELECT *
  FROM qp_list_headers_b t
 WHERE 1 = 1
   AND t.list_header_id = 1000;

SELECT *
  FROM qp_currency_details b
 WHERE 1 = 1
   AND b.currency_header_id = 86;
