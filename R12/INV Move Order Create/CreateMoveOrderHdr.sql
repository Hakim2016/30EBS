CREATE OR REPLACE
PROCEDURE XX_CreateMoveOrderHeader AS
        -- Common Declarations
        l_api_version		 NUMBER := 1.0; 
        l_init_msg_list		 VARCHAR2(2) := FND_API.G_TRUE; 
        l_return_values		 VARCHAR2(2) := FND_API.G_FALSE; 
        l_commit		 VARCHAR2(2) := FND_API.G_FALSE; 
        x_return_status		 VARCHAR2(2);
        x_msg_count		 NUMBER := 0;
        x_msg_data		 VARCHAR2(255);
    
        -- WHO columns
        l_user_id		NUMBER := -1;
        l_resp_id		NUMBER := -1;
        l_application_id	NUMBER := -1;
        l_user_name		VARCHAR2(30) := 'MFG';
        l_resp_name		VARCHAR2(50) := 'Manufacturing and Distribution Manager';   
        
        -- API specific declarations
        l_trohdr_rec             INV_MOVE_ORDER_PUB.TROHDR_REC_TYPE;
        l_trohdr_val_rec         INV_MOVE_ORDER_PUB.TROHDR_VAL_REC_TYPE;
        x_trohdr_rec             INV_MOVE_ORDER_PUB.TROHDR_REC_TYPE;
        x_trohdr_val_rec         INV_MOVE_ORDER_PUB.TROHDR_VAL_REC_TYPE;
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
      
          -- Initialize the variables
          l_trohdr_rec.date_required              :=   sysdate+2;
          l_trohdr_rec.organization_id            :=   207;	
          l_trohdr_rec.from_subinventory_code     :=   'Stores';
          l_trohdr_rec.to_subinventory_code       :=   'FGI';
          l_trohdr_rec.status_date                :=   sysdate;
          l_trohdr_rec.request_number             :=   'TEST_TRO1';
          l_trohdr_rec.header_status     	  :=   INV_Globals.G_TO_STATUS_PREAPPROVED;   -- preApproved
          l_trohdr_rec.transaction_type_id        :=   INV_GLOBALS.G_TYPE_TRANSFER_ORDER_SUBXFR; -- INV_GLOBALS.G_TYPE_TRANSFER_ORDER_STGXFR;  
          l_trohdr_rec.move_order_type	          :=   INV_GLOBALS.G_MOVE_ORDER_REQUISITION; -- G_MOVE_ORDER_PICK_WAVE;
          l_trohdr_rec.db_flag                    :=   FND_API.G_TRUE;
          l_trohdr_rec.operation                  :=   INV_GLOBALS.G_OPR_CREATE;    
  
          -- Who columns       
          l_trohdr_rec.created_by                 :=  l_user_id;
          l_trohdr_rec.creation_date              :=  sysdate;
          l_trohdr_rec.last_updated_by            :=  l_user_id;
          l_trohdr_rec.last_update_date           :=  sysdate;
             
          -- call API to create move order header
         DBMS_OUTPUT.PUT_LINE('=======================================================');
         DBMS_OUTPUT.PUT_LINE('Calling INV_MOVE_ORDER_PUB.Create_Move_Order_Header API');        
  
         INV_MOVE_ORDER_PUB.Create_Move_Order_Header( 
                   P_API_VERSION_NUMBER   => l_api_version
                ,  P_INIT_MSG_LIST        => l_init_msg_list
                ,  P_RETURN_VALUES        => l_return_values
                ,  P_COMMIT               => l_commit
                ,  X_RETURN_STATUS        => x_return_status
                ,  X_MSG_COUNT            => x_msg_count
                ,  X_MSG_DATA             => x_msg_data
                ,  P_TROHDR_REC           => l_trohdr_rec
                ,  P_TROHDR_VAL_REC	      => l_trohdr_val_rec
                ,  X_TROHDR_REC		        => x_trohdr_rec
                ,  X_TROHDR_VAL_REC	      => x_trohdr_val_rec
                ,  P_VALIDATION_FLAG	    => l_validation_flag
        ); 
             
       DBMS_OUTPUT.PUT_LINE('=======================================================');
       DBMS_OUTPUT.PUT_LINE('Return Status: '||x_return_status);

       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          DBMS_OUTPUT.PUT_LINE('Error Message :'||x_msg_data);
       END IF;

       IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          DBMS_OUTPUT.PUT_LINE('Move Order Created Successfully');
          DBMS_OUTPUT.PUT_LINE('Move Order Header ID : '||x_trohdr_rec.header_id);
       END IF;

       DBMS_OUTPUT.PUT_LINE('=======================================================');
       
EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Exception Occured :');
          DBMS_OUTPUT.PUT_LINE(SQLCODE ||':'||SQLERRM);
          DBMS_OUTPUT.PUT_LINE('=======================================================');
END XX_CreateMoveOrderHeader;