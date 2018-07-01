CREATE OR REPLACE
PROCEDURE CreateMoveOrderLines AS 
        -- Common Declarations
        l_api_version	   NUMBER := 1.0; 
        l_init_msg_list	   VARCHAR2(2) := FND_API.G_TRUE; 
        l_return_values    VARCHAR2(2) := FND_API.G_FALSE; 
        l_commit	   VARCHAR2(2) := FND_API.G_FALSE; 
        x_return_status    VARCHAR2(2);
        x_msg_count	   NUMBER := 0;
        x_msg_data         VARCHAR2(255);
    
        -- WHO columns
        l_user_id	      	NUMBER := -1;
        l_resp_id	        NUMBER := -1;
        l_application_id	NUMBER := -1;
        l_row_cnt	       	NUMBER := 1;
        l_user_name	        VARCHAR2(30) := 'MFG';
        l_resp_name	    	VARCHAR2(50) := 'Manufacturing and Distribution Manager';   
        
        -- API specific declarations
        l_trolin_tbl             INV_MOVE_ORDER_PUB.TROLIN_TBL_TYPE;
        l_trolin_val_tbl         INV_MOVE_ORDER_PUB.TROLIN_VAL_TBL_TYPE;
        x_trolin_tbl             INV_MOVE_ORDER_PUB.TROLIN_TBL_TYPE;
        x_trolin_val_tbl         INV_MOVE_ORDER_PUB.TROLIN_VAL_TBL_TYPE;
        l_validation_flag        VARCHAR2(2) := INV_MOVE_ORDER_PUB.G_VALIDATION_YES; 
  
BEGIN
 
        -- Get the user_id
        SELECT user_id
        INTO l_user_id
        FROM fnd_user
        WHERE user_name = l_user_name;
      
        -- Get the application_id and responsibility_id
        SELECT application_id, responsibility_id
        INTO l_application_id, l_resp_id
        FROM fnd_responsibility_vl
        WHERE responsibility_name = l_resp_name;
      
        FND_GLOBAL.APPS_INITIALIZE(l_user_id, l_resp_id, l_application_id);  
        dbms_output.put_line('Initialized applications context: '|| l_user_id || ' '|| l_resp_id ||' '|| l_application_id );
        
        -- creates lines for every header created before, and provides the line_id        
        -- Initialize the variables
        l_trolin_tbl(l_row_cnt).header_id	    	  :=  4073038;                       
        l_trolin_tbl(l_row_cnt).date_required		  :=  sysdate;                                     
        l_trolin_tbl(l_row_cnt).organization_id 	  :=  207;        
        l_trolin_tbl(l_row_cnt).inventory_item_id	  :=  513963;       
        l_trolin_tbl(l_row_cnt).from_subinventory_code    :=  'Stores';                                        
        l_trolin_tbl(l_row_cnt).to_subinventory_code	  :=  'FGI';    
        l_trolin_tbl(l_row_cnt).quantity		  :=  2;                                          
        l_trolin_tbl(l_row_cnt).status_date		  :=  sysdate;                                      
        l_trolin_tbl(l_row_cnt).uom_code	          :=  'Ea';   
        l_trolin_tbl(l_row_cnt).line_number	          := l_row_cnt;                                   
        l_trolin_tbl(l_row_cnt).line_status		  := INV_Globals.G_TO_STATUS_PREAPPROVED;          
        l_trolin_tbl(l_row_cnt).db_flag		          := FND_API.G_TRUE;                               
        l_trolin_tbl(l_row_cnt).operation		  := INV_GLOBALS.G_OPR_CREATE;                     

        -- Who columns
        l_trolin_tbl(l_row_cnt).created_by		:= l_user_id;                           
        l_trolin_tbl(l_row_cnt).creation_date	  	:= sysdate;                                      
        l_trolin_tbl(l_row_cnt).last_updated_by		:= l_user_id;                           
        l_trolin_tbl(l_row_cnt).last_update_date	:= sysdate;                                      
        l_trolin_tbl(l_row_cnt).last_update_login	:= FND_GLOBAL.login_id;                       
           
       -- call API to create move order lines
       DBMS_OUTPUT.PUT_LINE('==========================================================');
       DBMS_OUTPUT.PUT_LINE('Calling INV_MOVE_ORDER_PUB.Create_Move_Order_Lines API');        

       INV_MOVE_ORDER_PUB.Create_Move_Order_Lines( 
                 P_API_VERSION_NUMBER   => l_api_version
              ,  P_INIT_MSG_LIST        => l_init_msg_list
              ,  P_RETURN_VALUES        => l_return_values
              ,  P_COMMIT               => l_commit
              ,  X_RETURN_STATUS        => x_return_status
              ,  X_MSG_COUNT            => x_msg_count
              ,  X_MSG_DATA             => x_msg_data
              ,  P_TROLIN_TBL           => l_trolin_tbl
              ,  P_TROLIN_VAL_TBL       => l_trolin_val_tbl
              ,  X_TROLIN_TBL           => x_trolin_tbl
              ,  X_TROLIN_VAL_TBL	=> x_trolin_val_tbl
              ,  P_VALIDATION_FLAG	=> l_validation_flag
      ); 
         
     DBMS_OUTPUT.PUT_LINE('==========================================================');
     DBMS_OUTPUT.PUT_LINE('Return Status: '||x_return_status);

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        DBMS_OUTPUT.PUT_LINE('Error Message :'||x_msg_data);
     END IF;
     
     IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        DBMS_OUTPUT.PUT_LINE('Move Order Lines Created Successfully for '||x_trolin_tbl(l_row_cnt).header_id);
     END IF;                 

     DBMS_OUTPUT.PUT_LINE('==========================================================');

EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Exception Occured :');
          DBMS_OUTPUT.PUT_LINE(SQLCODE ||':'||SQLERRM);
          DBMS_OUTPUT.PUT_LINE('=======================================================');
END CreateMoveOrderLines;