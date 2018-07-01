DECLARE
  l_assign_to_organization_id mtl_system_items_b.inventory_item_id%TYPE;
  l_segment1                  mtl_system_items_b.segment1%TYPE;
  l_return_status             VARCHAR2(10);
  l_msg_data                  VARCHAR2(2000);

  PROCEDURE proc_item_assign_to_org(p_assign_to_organization_id IN NUMBER,
                                    p_segment1                  IN VARCHAR2,
                                    x_return_status             OUT VARCHAR2,
                                    x_msg_data                  OUT VARCHAR2) IS
  
    l_api_version               NUMBER := 1.0;
    l_init_msg_list             VARCHAR2(2) := fnd_api.g_true;
    l_commit                    VARCHAR2(2) := fnd_api.g_false;
    l_segment1                  mtl_system_items_b.segment1%TYPE;
    l_inventory_item_id         mtl_system_items_b.inventory_item_id%TYPE;
    l_primary_uom_code          mtl_system_items_b.primary_uom_code%TYPE;
    l_assign_to_organization_id mtl_system_items_b.organization_id%TYPE;
    l_master_organization_id    mtl_parameters.master_organization_id%TYPE;
    l_organization_code         mtl_parameters.organization_code%TYPE;
  
    x_msg_count NUMBER;
    l_data      VARCHAR2(2000);
    l_idx2      NUMBER;
  
  BEGIN
    l_assign_to_organization_id := p_assign_to_organization_id;
    l_segment1                  := p_segment1;
  
    SELECT mp.master_organization_id,
           mp.organization_code
      INTO l_master_organization_id,
           l_organization_code
      FROM mtl_parameters mp
     WHERE 1 = 1
       AND mp.organization_id = l_assign_to_organization_id;
  
    SELECT msib.inventory_item_id,
           msib.primary_uom_code
      INTO l_inventory_item_id,
           l_primary_uom_code
      FROM mtl_system_items_b msib
     WHERE msib.segment1 = l_segment1
       AND msib.organization_id = l_master_organization_id
       AND NOT EXISTS (SELECT 1
              FROM mtl_system_items_b t
             WHERE 1 = 1
               AND msib.inventory_item_id = t.inventory_item_id
               AND t.organization_id = l_assign_to_organization_id); -- INVENTORY ITEM CODE
  
    ego_item_pub.assign_item_to_org(p_api_version       => l_api_version,
                                    p_init_msg_list     => l_init_msg_list,
                                    p_commit            => l_commit,
                                    p_inventory_item_id => l_inventory_item_id, --(item id from the above Query)    
                                    p_item_number       => l_segment1, --(Item Code from the above Query)
                                    p_organization_id   => l_assign_to_organization_id, --(Organization Id for assingment)
                                    p_organization_code => l_organization_code, --v_organization_code 
                                    p_primary_uom_code  => l_primary_uom_code, --(UOM from the above Query)
                                    x_return_status     => x_return_status,
                                    x_msg_count         => x_msg_count);
  
    FOR i IN 1 .. nvl(x_msg_count, 0)
    LOOP
      fnd_msg_pub.get(p_msg_index     => i, --
                      p_encoded       => fnd_api.g_false,
                      p_data          => l_data,
                      p_msg_index_out => l_idx2);
      x_msg_data := x_msg_data || '[' || l_data || ']';
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      x_msg_data      := x_msg_data || '[SQLERRM : ' || SQLERRM || ']';
      x_return_status := fnd_api.g_ret_sts_error;
  END proc_item_assign_to_org;

BEGIN
  l_assign_to_organization_id := 86;
  l_segment1                  := '32694781-A';
  proc_item_assign_to_org(p_assign_to_organization_id => l_assign_to_organization_id,
                          p_segment1                  => l_segment1,
                          x_return_status             => l_return_status,
                          x_msg_data                  => l_msg_data);

  dbms_output.put_line(' l_return_status : ' || l_return_status);
  dbms_output.put_line(' l_msg_data      : ' || l_msg_data);
END;
