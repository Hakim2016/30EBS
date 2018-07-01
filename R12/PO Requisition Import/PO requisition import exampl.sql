
INSERT INTO po_requisitions_interface_all
  (interface_source_code,
   batch_id,
   transaction_id,
   org_id,
   destination_type_code,
   authorization_status,
   preparer_id,
   source_type_code,
   unit_of_measure,
   line_type_id,
   item_id,
   unit_price,
   quantity,
   destination_organization_id,
   deliver_to_location_id,
   deliver_to_requestor_id,
   multi_distributions,
   req_dist_sequence_id,
   need_by_date,
   charge_account_id)
VALUES
  ('PASS', --Interface Source 
   3, -- 1, -- batch_id 
   po_requisitions_interface_s.nextval, -- transaction_id 
   82, --Operating Unit 
   'INVENTORY', --Destination Type 
   'INCOMPLETE', --Status 
   2480, --This comes from per_people_f.person_id 
   'VENDOR', --Source Type 
   'ea', --UOM 
   1, --Line Type of Goods 
   258362, -- Item id 
   21, --Price 
   10, --quantity 
   83, --dcg 
   142, --deliver to location id
   2480, --This is the Deliver to Requestor 
   'Y',
   po_req_dist_interface_s.nextval,
   SYSDATE + 10,
   1009);
/*VALUES
  ('PASS', --Interface Source 
   1, -- batch_id 
   po_requisitions_interface_s.nextval, -- transaction_id 
   204, --Operating Unit 
   'EXPENSE', --Destination Type 
   'INCOMPLETE', --Status 
   25, --This comes from per_people_f.person_id 
   'VENDOR', --Source Type 
   'Each', --UOM 
   1, --Line Type of Goods 
   162744, -- Item id 
   10, --Price 
   10, --quantity 
   204, --dcg 
   204, --deliver to location id 
   25, --This is the Deliver to Requestor 
   'Y',
   po_req_dist_interface_s.nextval,
   SYSDATE + 10);*/

INSERT INTO po_req_dist_interface_all
  (interface_source_code,
   batch_id, --
   transaction_id,
   charge_account_id,
   distribution_number,
   dist_sequence_id,
   quantity)
VALUES
  ('PASS', --
   3, --1,
   po_requisitions_interface_s.currval,
   1009,
   1,
   po_req_dist_interface_s.currval,
   5);

INSERT INTO po_req_dist_interface_all
  (interface_source_code, --
   batch_id,
   transaction_id,
   charge_account_id,
   distribution_number,
   dist_sequence_id,
   quantity)
VALUES
  ('PASS', --
   3, --1,
   po_requisitions_interface_s.currval,
   1009,
   2,
   po_req_dist_interface_s.currval,
   5);
