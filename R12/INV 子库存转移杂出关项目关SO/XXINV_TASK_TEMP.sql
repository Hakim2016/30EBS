-- Create table
create table XXINV.XXINV_TASK_TEMP
(
  project_id      NUMBER(15) not null,
  task_id         NUMBER(15) not null,
  process_status  VARCHAR2(100),
  process_message VARCHAR2(1000)
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
-- Create/Recreate indexes 
create unique index XXINV_TASK_TEMP_N1 on XXINV.XXINV_TASK_TEMP (TASK_ID)
  tablespace APPS_TS_TX_IDX
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
create index XXINV_TASK_TEMP_N2 on XXINV.XXINV_TASK_TEMP (PROJECT_ID)
  tablespace APPS_TS_TX_IDX
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

CREATE SYNONYM XXINV_TASK_TEMP FOR XXINV.XXINV_TASK_TEMP;
