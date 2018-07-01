--SO1-53020400
SELECT ool.attribute4,
       ool.ordered_item,
       ool.project_id,
       ool.task_id,
       (SELECT pt.top_task_id
          FROM pa_tasks pt
         WHERE 1 = 1
           AND pt.task_id = ool.task_id) top_task_id,
       ool.*
  FROM oe_order_headers_all ooh,
       oe_order_lines_all   ool
 WHERE 1 = 1
   AND ooh.header_id = ool.header_id
   AND ooh.order_number = '53020400'
   AND ooh.org_id = 101 --HBS
   AND ool.ordered_item IN ('JED0210-VN', 'JED0211-VN', 'JED0212-VN', 'JED0219-VN', 'JED0220-VN', 'JED0225-VN')
 ORDER BY ool.line_number;

--SO2-53020422
--'JFA0245-VN','JFA0246-VN','JFA0247-VN','JFA0248-VN','JFA0249-VN','JFA0250-VN','JFA0251-VN','JFA0252-VN'
SELECT ool.attribute4,
       ool.ordered_item,
       ool.*
  FROM oe_order_headers_all ooh,
       oe_order_lines_all   ool
 WHERE 1 = 1
   AND ooh.header_id = ool.header_id
   AND ooh.order_number = '53020422'
   AND ooh.org_id = 101
   AND ool.ordered_item IN
       ('JFA0245-VN', 'JFA0246-VN', 'JFA0247-VN', 'JFA0248-VN', 'JFA0249-VN', 'JFA0250-VN', 'JFA0251-VN', 'JFA0252-VN')
 ORDER BY ool.line_number;
