-- Create table
create table XXINV.XXINV_PROJ_TRANSFER_TODO_FCS
(
  organization_id         NUMBER not null,
  inventory_item_id       NUMBER not null,
  item_num                VARCHAR2(40),
  uom                     VARCHAR2(3),
  sub_inv                 VARCHAR2(10) not null,
  long_name               VARCHAR2(240),
  task_number             VARCHAR2(25) not null,
  task_id                 NUMBER(15) not null,
  project_id              NUMBER(15) not null,
  quantity                NUMBER,
  locator_id              NUMBER,
  concatenated_seg_values VARCHAR2(4000),
  process_status          VARCHAR2(100),
  process_message         VARCHAR2(1000)
)
tablespace APPS_TS_TX_DATA
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
