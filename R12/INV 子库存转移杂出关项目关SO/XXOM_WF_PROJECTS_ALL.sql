-- Create table
create table XXOM.XXOM_WF_PROJECTS_ALL
(
  project_number VARCHAR2(240),
  task_number    VARCHAR2(360),
  project_id     NUMBER,
  task_id        NUMBER,
  enabled_flag   VARCHAR2(1)
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
create index XXOM.XXOM_WF_PROJECTS_ALL_N1 on XXOM.XXOM_WF_PROJECTS_ALL (PROJECT_ID, TASK_ID)
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

CREATE SYNONYM XXOM_WF_PROJECTS_ALL FOR XXOM.XXOM_WF_PROJECTS_ALL;
