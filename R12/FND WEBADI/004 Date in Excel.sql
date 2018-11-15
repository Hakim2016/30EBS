--LOV4 End Date

BEGIN  
 bne_integrator_utils.create_calendar_lov(p_application_id    =>20009,--Your custom application  
                                          p_interface_code    =>'ITMFRCST_XINTG_INTF1',--Your custom interface code  
                                          p_interface_col_name=>'P_RATE_END_DATE',--Your date_item ininterface  
                                          p_window_caption    =>'Forecast End Date',--Window Prompt  
                                          p_window_width      =>NULL,--Use default  
                                          p_window_height     =>NULL,--Use default  
                                          p_table_columns     =>'ADI_DATE',--Your table date_fields  
                                          p_user_id           =>4170);  
END; 
