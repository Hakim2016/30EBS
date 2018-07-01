-- Create table
create table XXPA.XXPA_COST_GCPM_INT
(
  group_id               NUMBER,
  unique_id              NUMBER not null,
  org_id                 NUMBER not null,
  system                 VARCHAR2(3),
  data_type              VARCHAR2(6),
  additional_flag        VARCHAR2(1),
  cancelation_flag       VARCHAR2(1),
  company_name           VARCHAR2(3),
  gg_code                VARCHAR2(30),
  customer_name          VARCHAR2(240),
  main_contractor        VARCHAR2(240),
  delivered_country      VARCHAR2(16),
  goe_number             VARCHAR2(40),
  order_number           NUMBER,
  line_number            VARCHAR2(40),
  site                   VARCHAR2(240),
  order_received_date    DATE,
  delivery_date          DATE,
  eq_er_category         VARCHAR2(5),
  model_type             VARCHAR2(10),
  model                  VARCHAR2(150),
  units                  NUMBER, 
  project_id             NUMBER,
  top_task_id            NUMBER,
  mfg_num                VARCHAR2(25),
  task_id                NUMBER,
  currency_code          VARCHAR2(3),
  period_start_date      DATE,
  preperiod_sale_amount  NUMBER,
  sale_amount            NUMBER,
  cogs                   NUMBER,
  material               NUMBER,
  expense                NUMBER,
  labour                 NUMBER,
  subcon                 NUMBER,
  packing_freight        NUMBER,
  material_ytd           NUMBER,
  expense_ytd            NUMBER,
  labour_ytd             NUMBER,
  subcon_ytd             NUMBER,
  packing_freight_ytd    NUMBER,
  sg_a                   VARCHAR2(8),
  actual_month           DATE,
  process_status         VARCHAR2(1) not null,
  process_date           DATE,
  process_message        VARCHAR2(2000),
  source_table           VARCHAR2(10),
  source_header_id       NUMBER,
  source_line_id         NUMBER,
  object_version_number  NUMBER default 1 not null,
  creation_date          DATE default sysdate,
  created_by             NUMBER default -1,
  last_updated_by        NUMBER default -1,
  last_update_date       DATE default sysdate,
  last_update_login      NUMBER,
  program_application_id NUMBER,
  program_id             NUMBER,
  program_update_date    DATE,
  request_id             NUMBER,
  reference1             VARCHAR2(240),
  reference2             VARCHAR2(240),
  reference3             VARCHAR2(240),
  reference4             VARCHAR2(240),
  reference5             VARCHAR2(240)
)
tablespace ADDON_TS_TX_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 128K
    next 128K
    minextents 1
    maxextents unlimited
    pctincrease 0
  );
-- Create/Recreate indexes 
create index XXPA.XXPA_COST_GCPM_INT_N1 on XXPA.XXPA_COST_GCPM_INT (GROUP_ID, PROCESS_STATUS)
  tablespace ADDON_TS_TX_IDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 128K
    next 128K
    minextents 1
    maxextents unlimited
    pctincrease 0
  );
create index XXPA.XXPA_COST_GCPM_INT_N2 on XXPA.XXPA_COST_GCPM_INT (SOURCE_TABLE, SOURCE_HEADER_ID, SOURCE_LINE_ID)
  tablespace ADDON_TS_TX_IDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 128K
    next 128K
    minextents 1
    maxextents unlimited
    pctincrease 0
  );
create index XXPA.XXPA_COST_GCPM_INT_N3 on XXPA.XXPA_COST_GCPM_INT (REQUEST_ID)
  tablespace ADDON_TS_TX_IDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 128K
    next 128K
    minextents 1
    maxextents unlimited
    pctincrease 0
  );
create index XXPA.XXPA_COST_GCPM_INT_N4 on XXPA.XXPA_COST_GCPM_INT (TASK_ID, PERIOD_START_DATE)
  tablespace ADDON_TS_TX_DATA
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 128K
    next 128K
    minextents 1
    maxextents unlimited
    pctincrease 0
  );
create unique index XXPA.XXPA_COST_GCPM_INT_U1 on XXPA.XXPA_COST_GCPM_INT (UNIQUE_ID)
  tablespace ADDON_TS_TX_IDX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 128K
    next 128K
    minextents 1
    maxextents unlimited
    pctincrease 0
  );

create synonym XXPA_COST_GCPM_INT for xxpa.XXPA_COST_GCPM_INT;
create sequence xxpa.XXPA_COST_GCPM_INT_S;
create sequence xxpa.XXPA_COST_GCPM_INT_ROW_S;
create synonym XXPA_COST_GCPM_INT_ROW_S for xxpa.XXPA_COST_GCPM_INT_ROW_S;
create synonym XXPA_COST_GCPM_INT_S for xxpa.XXPA_COST_GCPM_INT_S;
