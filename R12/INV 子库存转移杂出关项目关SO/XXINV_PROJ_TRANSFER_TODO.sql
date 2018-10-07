-- Create table
create table XXINV.XXINV_PROJ_TRANSFER_TODO
(
  dn_issued         VARCHAR2(240),
  organization_code VARCHAR2(240),
  mfg               VARCHAR2(240),
  item              VARCHAR2(240),
  sub_inv           VARCHAR2(240),
  locator           VARCHAR2(240),
  to_sub_inv        VARCHAR2(240),
  to_locator        VARCHAR2(240),
  quantity          VARCHAR2(10),
  organization_id   NUMBER,
  inventory_item_id NUMBER,
  from_locator_id   NUMBER,
  to_locator_id     NUMBER,
  process_status    VARCHAR2(1),
  process_message   VARCHAR2(4000)
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
