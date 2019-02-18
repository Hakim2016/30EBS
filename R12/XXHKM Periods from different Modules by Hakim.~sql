--Doc ID 552244.1
--------GL（采购用总帐会计期),应收，应付，资产
SELECT p.application_name appl_name,
       p.application_id app_id,
       p.application_short_name app_short,
       p.basepath,
       t.set_of_books_id,
       t.period_name,
       t.closing_status,
       glps.show_status,
       t.start_date,
       t.end_date,
       t.last_update_date,
       t.last_updated_by
  FROM gl.gl_period_statuses        t,
       fnd_application_vl           p,
       gl_lookups_period_statuses_v glps

 WHERE t.application_id = p.application_id
   AND glps.status_flag = t.closing_status
   --AND p.application_id = 222
--and t.set_of_books_id='2026'
--AND t.period_name = 'APR-18'
AND t.start_date = to_date('2018-11-01','yyyy-mm-dd')
AND t.set_of_books_id = 2023--2021--2023--2021--2041--2021
 ORDER BY t.application_id ASC,
          t.start_date     ASC;

SELECT set_of_books_id,
       period_name,
       decode(closing_status, 'O', 'Open', 'C', 'Closed', 'F', 'Future', 'N', 'Never', closing_status) gl_status,
       start_date,
       end_date
  FROM gl_period_statuses
 WHERE trunc(start_date) > SYSDATE - 40 --adjust date as needed
   AND trunc(start_date) < SYSDATE + 1
   AND application_id = 101
 ORDER BY application_id,
          start_date DESC;

SELECT * FROM fnd_application fa WHERE fa.application_id = 101;

--PO Period
SELECT set_of_books_id,
       application_id,
       period_name,
       decode(closing_status, 'O', 'Open', 'C', 'Closed', 'F', 'Future', 'N', 'Never', closing_status) po_status,
       start_date,
       end_date
  FROM gl_period_statuses
 WHERE trunc(start_date) > SYSDATE - 40 --adjust date as needed
   AND trunc(start_date) < SYSDATE + 1
   AND application_id = 201
 ORDER BY application_id,
          start_date DESC;

--INV
SELECT oap.organization_id "Organization ID",
       mp.organization_code "Organization Code",
       oap.period_name "Period Name",
       oap.period_start_date "Start Date",
       oap.period_close_date "Closed Date",
       decode(oap.open_flag,
              'P',
              'P - Period Close is processing',
              'N',
              'N - Period Close process is completed',
              'Y',
              'Y - Period is open if Closed Date is NULL',
              'Unknown') "Period Status"
  FROM org_acct_periods oap,
       mtl_parameters   mp
 WHERE oap.organization_id = mp.organization_id
   --AND trunc(period_start_date) > SYSDATE - 40 --adjust date as needed
   --AND trunc(period_start_date) < SYSDATE + 1
   AND oap.period_start_date =  to_date('2018-04-01','yyyy-mm-dd')
 ORDER BY oap.organization_id,
          oap.period_start_date;

----------库存会计期间－－－－－－

SELECT oap.organization_id,
       oap.period_name,
       oap.period_set_name,
       oap.acct_period_id,
       oap.status
  FROM org_acct_periods_v oap
 WHERE oap.organization_id != 0
   AND oap.organization_id = 86--83
   AND oap.start_date = to_date('2018-09-01','yyyy-mm-dd')
--and oap.period_name=--'MAR-18'
 ORDER BY oap.organization_id,
          oap.start_date;

--------------日历--------

SELECT *
  FROM gl_period_sets;

---------成本期间－－－－－－－－－－

SELECT *
  FROM gmf_calendar_assignments; ---期间分配

SELECT *
  FROM cm_cldr_dtl; ---期间明细

SELECT *
  FROM gl.gl_ledger_config_details; ---- 法人实体

SELECT *
  FROM gmf_period_statuses p
 WHERE p.period_code = '04-10'; ---期间状态

SELECT *
  FROM org_organization_definitions ood;
SELECT *
  FROM fnd_application fa
 WHERE 1 = 1
   AND fa.application_id = 201;

--GL & PO
SELECT sob.name "Set of Books",
       fnd.product_code "Porduct Code",
       ps.period_name "Period Name",
       ps.start_date "Period Start Date",
       ps.end_date "Period End Date",
       decode(ps.closing_status,
              'O',
              'O - Open',
              'N',
              'N - Never Opened',
              'F',
              'F - Future Enterable',
              'C',
              'C - Closed',
              'Unknown') "Period Status"
  FROM gl_period_statuses ps,
       gl_sets_of_books   sob,
       fnd_application_vl fnd
 WHERE ps.application_id IN (101, 201) -- GL & PO
   AND sob.set_of_books_id = ps.set_of_books_id
   AND fnd.application_id = ps.application_id
   AND ps.adjustment_period_flag = 'N'
   AND (trunc(SYSDATE-30) -- Comment line if a a date other than SYSDATE is being tested.
       --AND ('01-APR-2011' -- Uncomment line if a date other than SYSDATE is being tested.
       BETWEEN trunc(ps.start_date) AND trunc(ps.end_date))
 ORDER BY ps.set_of_books_id,
          fnd.product_code,
          ps.start_date;

--INV
SELECT mp.organization_id "Organization ID",
       mp.organization_code "Organization Code",
       ood.organization_name "Organization Name",
       oap.period_name "Period Name",
       oap.period_start_date "Start Date",
       oap.period_close_date "Closed Date",
       oap.schedule_close_date "Scheduled Close",
       decode(oap.open_flag,
              'P',
              'P - Period Close is processing',
              'N',
              'N - Period Close process is completed',
              'Y',
              'Y - Period is open if Closed Date is NULL',
              'Unknown') "Period Status"
  FROM org_acct_periods             oap,
       org_organization_definitions ood,
       mtl_parameters               mp
 WHERE oap.organization_id = mp.organization_id
   AND mp.organization_id = ood.organization_id(+)
   AND (trunc(SYSDATE-30) -- Comment line if a a date other than SYSDATE is being tested.
       --AND ('01-APR-2011' -- Uncomment line if a date other than SYSDATE is being tested.
       BETWEEN trunc(oap.period_start_date) AND trunc(oap.schedule_close_date))
 ORDER BY mp.organization_id,
          oap.period_start_date;
          
          
--The reason Organization Name may return NULL is that ORG_ORGANIZATION_DEFINITIONS (OOD) is a View which uses the View HR_ORGANIZATION_UNITS whose HR Security settings may prevent ODD from returning data.

/*有期间的模块：GL、AP、AR、FA、INV、PO、PA、AGIS
对应标准路径
GL：    总账-设置-打开/关闭
AP：    应付-会计科目-控制应付款期间
AR：    应收-控制-会计科目-打开/关闭期间
FA：    资产-折旧-运行折旧
INV：  库存-会计关闭周期-库存会计期
       Inventory->Accounting Close Cycle
PO：   采购管理->设置->财务系统->会计->打开和关闭期间
PA：    PA->Setup->System->PA Periods/GL Periods
AGIS：设置-期间-打开/关闭

TIPS
   PA、PO、INV、AP、AR的期间由GL决定，除PA外自动同步
   ap期间打开必须gl和po期间打开
   inv、fa期间关闭后不允许再打开
  agis期间与事务处理相关，每种事务处理单独进行期间的控制

20150617 更新
    有期间的模块：AGIS
    对应的标准路径：AGIS：设置-期间-打开/关闭
    注：AGIS期间与事务处理相关，每种事务处理单独进行期间的控制
20151124 更新
    一般关期间顺序：AP—PO—FA—AR/INV—GL
    使用PAC一般关期间顺序：AP—PO—FA/AR—INV—PAC—GL*/
