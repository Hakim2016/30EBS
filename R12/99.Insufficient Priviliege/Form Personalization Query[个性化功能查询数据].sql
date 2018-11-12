
-- Personalization FNDLOAD
Download:
FNDLOAD <userid>/<PASSWORD> 0 Y DOWNLOAD $FND_TOP/patch/115/import/affrmcus.lct <filename.ldt> FND_FORM_CUSTOM_RULES function_name=<FUNCTION NAME>

Upload:
FNDLOAD <userid>/<PASSWORD> 0 Y UPLOAD $FND_TOP/patch/115/import/affrmcus.lct <filename.ldt>



-- 个性化做到重新查询数据
在.pll中添加代码



BEGIN
  -- 1. Define Special
  -- 2. turn on/off special  
  -- 3. SPECIAL EVENT
  IF event = 'SPECIAL' THEN
    set_block_property('PO_HEADERS', ONETIME_WHERE, l_new_where);
		app_find.find('PO_HEADERS');
  END IF;  
END;
/
-- But this method will pop a hit error message FRM-40700: NO such trigger SPECIAL
-- the casue is add the statement "set_block_property('PO_HEADERS', ONETIME_WHERE, l_new_where)"
