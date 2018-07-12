SELECT decode(ppt.attribute7, 'OVERSEA', 'OVERSEA', 'DOMESTIC') isoversea,
       nvl(dih.last_invoice_flag, 'N') last_invoice_flag,
       dih.transaction_date,
       ool.task_id,
       dih.document_number
  FROM xxom_do_invoice_lines_all   dil,
       oe_order_lines_all          ool, --task_id   project_id
       pa_projects_all             ppa,
       pa_project_types_all        ppt,
       xxom_do_invoice_headers_all dih
 WHERE 1 = 1
   AND dih.header_id = dil.header_id
   AND dil.oe_line_id = ool.line_id
   AND ool.task_id = /*P_TASK_ID*/
       4119176 --TFA0565-TH.EQ
   AND ool.project_id = ppa.project_id
   AND ppa.project_type = ppt.project_type
--AND DIH.TRANSACTION_DATE BETWEEN to_date('2016/12/1', 'yyyy/mm/dd') AND to_date('2016/12/31 23:59:59', 'yyyy/mm/dd hh24:mi:ss')
AND DIH.TRANSACTION_DATE BETWEEN to_date('2017/2/1', 'yyyy/mm/dd') AND to_date('2017/2/28 23:59:59', 'yyyy/mm/dd hh24:mi:ss')
 ORDER BY nvl(dih.last_invoice_flag, 'N') DESC;

(SELECT --DECODE(PPT.ATTRIBUTE7, 'OVERSEA', 'OVERSEA', 'DOMESTIC') ISOVERSEA,
--NVL(DIH.LAST_INVOICE_FLAG, 'N') LAST_INVOICE_FLAG,
--DIH.TRANSACTION_DATE,
 ool.task_id,
 ool.ordered_item,
 COUNT(*)
  FROM xxom_do_invoice_lines_all   dil,
       oe_order_lines_all          ool, --task_id   project_id
       pa_projects_all             ppa,
       pa_project_types_all        ppt,
       xxom_do_invoice_headers_all dih
 WHERE 1 = 1
   AND dih.header_id = dil.header_id
   AND dil.oe_line_id = ool.line_id
      --AND OOL.TASK_ID = /*P_TASK_ID*/
      --4119176--TFA0565-TH.EQ
   AND ool.project_id = ppa.project_id
   AND ppa.project_type = ppt.project_type
   AND ppt.attribute7 <> 'OVERSEA'
   AND dih.last_invoice_flag = 'Y'
   AND dih.org_id = 84
--AND DIH.TRANSACTION_DATE BETWEEN to_date('2017/2/1', 'yyyy/mm/dd') AND to_date('2017/2/28 23:59:59', 'yyyy/mm/dd hh24:mi:ss')
--AND DIH.TRANSACTION_DATE BETWEEN to_date('2017/2/1', 'yyyy/mm/dd') AND to_date('2017/2/28 23:59:59', 'yyyy/mm/dd hh24:mi:ss')
--ORDER BY nvl(DIH.Last_Invoice_Flag, 'N') DESC
 GROUP BY ool.task_id,
          ool.ordered_item
HAVING COUNT(*) > 1
 ORDER BY ool.task_id) t;
 
 
SELECT decode(ppt.attribute7, 'OVERSEA', 'OVERSEA', 'DOMESTIC') isoversea,
       nvl(dih.last_invoice_flag, 'N') last_invoice_flag,
       dih.transaction_date,
       ool.task_id,
       ool.org_id,
       ool.ordered_item,
       dih.document_number, t.xx
  FROM xxom_do_invoice_lines_all   dil,
       oe_order_lines_all          ool, --task_id   project_id
       pa_projects_all             ppa,
       pa_project_types_all        ppt,
       xxom_do_invoice_headers_all dih,
(SELECT --DECODE(PPT.ATTRIBUTE7, 'OVERSEA', 'OVERSEA', 'DOMESTIC') ISOVERSEA,
--NVL(DIH.LAST_INVOICE_FLAG, 'N') LAST_INVOICE_FLAG,
--DIH.TRANSACTION_DATE,
 ool.task_id,
 ool.ordered_item,
 COUNT(*) xx
  FROM xxom_do_invoice_lines_all   dil,
       oe_order_lines_all          ool, --task_id   project_id
       pa_projects_all             ppa,
       pa_project_types_all        ppt,
       xxom_do_invoice_headers_all dih
 WHERE 1 = 1
   AND dih.header_id = dil.header_id
   AND dil.oe_line_id = ool.line_id
      --AND OOL.TASK_ID = /*P_TASK_ID*/
      --4119176--TFA0565-TH.EQ
   AND ool.project_id = ppa.project_id
   AND ppa.project_type = ppt.project_type
   AND ppt.attribute7 <> 'OVERSEA'
   AND dih.last_invoice_flag = 'Y'
   AND dih.org_id = 84
--AND DIH.TRANSACTION_DATE BETWEEN to_date('2017/2/1', 'yyyy/mm/dd') AND to_date('2017/2/28 23:59:59', 'yyyy/mm/dd hh24:mi:ss')
--AND DIH.TRANSACTION_DATE BETWEEN to_date('2017/2/1', 'yyyy/mm/dd') AND to_date('2017/2/28 23:59:59', 'yyyy/mm/dd hh24:mi:ss')
--ORDER BY nvl(DIH.Last_Invoice_Flag, 'N') DESC
 GROUP BY ool.task_id,
          ool.ordered_item
HAVING COUNT(*) > 1
 ORDER BY ool.task_id) t       
       
 WHERE 1 = 1
   AND dih.header_id = dil.header_id
   AND dil.oe_line_id = ool.line_id
   AND ool.task_id = t.task_id/*P_TASK_ID*/
       --4119176 --TFA0565-TH.EQ
   AND ool.project_id = ppa.project_id
   AND ppa.project_type = ppt.project_type
   AND ppt.attribute7 <> 'OVERSEA'
   AND dih.last_invoice_flag = 'Y'
--AND DIH.TRANSACTION_DATE BETWEEN to_date('2017/2/1', 'yyyy/mm/dd') AND to_date('2017/2/28 23:59:59', 'yyyy/mm/dd hh24:mi:ss')
--AND DIH.TRANSACTION_DATE BETWEEN to_date('2017/2/1', 'yyyy/mm/dd') AND to_date('2017/2/28 23:59:59', 'yyyy/mm/dd hh24:mi:ss')
 --ORDER BY nvl(dih.last_invoice_flag, 'N') DESC
 ORDER BY ool.task_id
 ;
