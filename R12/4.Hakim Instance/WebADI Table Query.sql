select * from bne_integrators_b bib where bib.integrator_code='GENERAL_182_INTG';
select * from bne_integrators_tl bib where bib.integrator_code='GENERAL_182_INTG';
select * from bne_integrator_viewers bib where bib.integrator_code='GENERAL_182_INTG';
select * from bne_interfaces_b a where a.integrator_code='GENERAL_182_INTG';
select * from bne_interfaces_tl a where a.interface_code='GENERAL_182_INTF';
select * from bne_interface_cols_b a where a.interface_code='GENERAL_182_INTF';
select * from bne_interface_cols_tl a where a.interface_code  like 'GENERAL_181%';
select * from bne_interface_keys a where a.interface_code  like 'GENERAL_181%';
select * from bne_interface_key_cols a where a.interface_code='GENERAL_182_INTF';
select * from bne_import_programs a where a.integrator_code='GENERAL_182_INTG';
select * from bne_contents_b a where a.integrator_code='GENERAL_182_INTG';--GENERAL_182_CNT_PL
select * from bne_content_cols_b a where a.content_code like 'GENERAL_181%';
select * from bne_content_cols_tl a where a.content_code like 'GENERAL_181%';
select * from bne_layouts_b a where a.integrator_code like 'GENERAL_181%';
select * from bne_layout_cols a where a.layout_code='LAYOUT_BH1RQ';
select * from bne_layout_blocks_b a where a.layout_code='LAYOUT_BH1RQ';
select * from bne_mapping_lines a where a.content_code LIKE 'GENERAL_281%';
select * from bne_mappings_b a where a.integrator_code LIKE 'GENERAL_281%';
select * from bne_param_list_items a where a.param_list_code  LIKE 'GENERAL_281%'  ;
select * from bne_param_list_ a where a.param_list_code  LIKE 'GENERAL_281%'  ;

select * from bne_param_lists_b a where a.param_list_code LIKE 'GENERAL_281%' ;
select * from bne_param_group_items b where b.param_list_code='GENERAL_182_CNT_PL';
select * from bne_param_groups_b a where a.param_list_code='GENERAL_182_CNT_PL';
select * from bne_param_defns_b a where a.param_defn_code='CAT_SET_NAME' FOR UPDATE;
select * from bne_param_defns_tl a where a.param_defn_code='CAT_SET_NAME' FOR UPDATE;
select * from bne_stored_sql a where a.content_code='GENERAL_182_CNT';






select * from bne_components_b a where a.param_list_code='';--
select * from bne_components_tl a where a.component_code='';--


select * from bne_attributes a;
select * from bne_async_upload_jobs a;--history
select * from bne_admin_actions a;--admin
select * from bne_cache_directives_b a;
select * from bne_documents ;--run history
select * from bne_doc_actions;--run history
select * from bne_doc_creation_params;--run history
select * from bne_doc_user_params; --run history
select * from bne_files a where a.content_code='GENERAL_182_CNT';--
select * from bne_dup_interface_cols a where a.interface_code='GENERAL_182_INTF';--
select * from bne_layout_lobs a where a.layout_code='GENERAL_182_CNT';
select * from bne_menus_b a where a.integrator_code='GENERAL_182_INTG';
select * from bne_param_overrides ;
select * from bne_queries_b a;
select * from bne_simple_query;
select * from bne_stored_sql;



select * from bne_interface_cols_b bic where bic.integrator_code='GENERAL_182_INTG';
select * from bne_interfaces_vl a where a.application_id=20006;
SELECT * FROM fnd_application a where a.application_short_name='XXBOM';
