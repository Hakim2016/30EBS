-- Add columns
ALTER TABLE xxinv.xxinv_packing_lists_int ADD test_column varchar2(100) ;
-- Drop columns 
alter table XXINV.XXINV_PACKING_LISTS_INT drop column test_column;
