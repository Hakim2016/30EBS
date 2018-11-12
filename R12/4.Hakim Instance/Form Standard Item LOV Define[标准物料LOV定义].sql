
-- Standard Item LOV Define
-- Item : XCP_V.ITEM_CODE 
--        List of Values      : ENABLE_LIST_LAMP
--        Validate from List  : No

-- Trigger : WHEN-NEW-FORM-INSTANCE
      fnd_key_flex.define(BLOCK                 => 'XCP_V',
                          field                 => 'ITEM_CODE', --'INVENTORY_ITEM',
                          id                    => 'PART_ITEM_ID',
                          appl_short_name       => 'INV',
                          code                  => 'MSTK',
                          longlist              => 'Y',
                          validate              => 'FULL',
                          updateable            => 'ALL',
                          required              => 'N',
                          data_set              => :parameter.org_id,
                          select_comb_from_view => 'MTL_SYSTEM_ITEMS_FVL',
                          column                => 'DESCRIPTION \\\"' || 'Description' || '\\\"(*) into XCP_V.ITEM_DESC',
                          where_clause          => 'nvl(ATTRIBUTE11,''N'') = ''N'' AND enabled_flag = ''Y'' and sysdate between nvl(start_date_active,sysdate) and nvl(end_date_active,sysdate) and mtl_transactions_enabled_flag = ''Y''');

