CREATE TABLE XXINV.XXINV_ITEM_CATEGORY_20150129 AS
SELECT *
  FROM mtl_item_categories mic
 WHERE 1 = 1
   AND (mic.organization_id, mic.inventory_item_id, mic.category_set_id, mic.category_id) IN
       (SELECT micv.organization_id,
               micv.inventory_item_id,
               micv.category_set_id,
               micv.category_id
          FROM org_organization_definitions ood,
               mtl_system_items_b           msib,
               mtl_item_categories_v        micv
         WHERE 1 = 1
           AND ood.organization_id = msib.organization_id
           AND msib.organization_id = micv.organization_id
           AND msib.inventory_item_id = micv.inventory_item_id
           AND ood.organization_code = 'SG1'
              --AND msib.segment1 = 'L#GRS0367'
           AND upper(msib.description) LIKE upper('%PANEL BRKT%')
           AND micv.category_set_id = 1100000041
           AND micv.category_concat_segs IN ('Q')
        );



DECLARE
  l_user_name                fnd_user.user_name%TYPE;
  l_user_id                  fnd_user.user_id%TYPE;
  l_new_category_concat_segs VARCHAR2(100);
  l_return_status            VARCHAR2(1);
  l_msg_data                 VARCHAR2(2000);

  CURSOR cur_data IS
    SELECT ood.organization_id,
           ood.organization_code,
           msib.inventory_item_id,
           msib.segment1          item_number,
           msib.description       item_description,
           /*micv.category_set_id,
           micv.category_set_name,
           micv.category_id,*/
           micv.category_concat_segs,
           micv.category_set_id,
           micv.category_set_name,
           micv.structure_id,
           micv.category_id,
           micv.segment1
      FROM org_organization_definitions ood,
           mtl_system_items_b           msib,
           mtl_item_categories_v        micv
     WHERE 1 = 1
       AND ood.organization_id = msib.organization_id
       AND msib.organization_id = micv.organization_id
       AND msib.inventory_item_id = micv.inventory_item_id
       AND ood.organization_code = 'SG1'
          --AND msib.segment1 = 'L#GRS0367'
       AND upper(msib.description) LIKE upper('%PANEL BRKT%')
       AND micv.category_set_id = 1100000041
       AND micv.category_concat_segs IN ('Q')
     ORDER BY ood.organization_code,
              msib.segment1;

  PROCEDURE proc_update_item_category(p_organization_id          IN NUMBER,
                                      p_inventory_item_id        IN NUMBER,
                                      p_category_set_id          IN VARCHAR2,
                                      p_new_category_concat_segs IN VARCHAR2,
                                      x_return_status            OUT VARCHAR2,
                                      x_msg_data                 OUT VARCHAR2) IS
    CURSOR cur_data(p_cur_organization_id   IN NUMBER,
                    p_cur_inventory_item_id IN NUMBER,
                    p_cur_category_set_id   IN VARCHAR2) IS
      SELECT micv.category_set_id,
             micv.category_set_name,
             micv.structure_id,
             micv.category_id,
             micv.category_concat_segs,
             micv.segment1
        FROM mtl_item_categories_v micv
       WHERE 1 = 1
         AND micv.organization_id = p_cur_organization_id
         AND micv.inventory_item_id = p_cur_inventory_item_id
         AND micv.category_set_id = p_cur_category_set_id;
    l_api_version   NUMBER := 1.0;
    l_init_msg_list VARCHAR2(200) := fnd_api.g_false;
    l_commit        VARCHAR2(200) := fnd_api.g_false;
    l_errorcode     NUMBER;
    l_msg_count     NUMBER;
    l_category_rec  inv_item_category_pub.category_rec_type;
    l_category_id   NUMBER;
    l_return_status VARCHAR2(1);
    l_msg_data      VARCHAR2(2000);
  BEGIN
  
    x_return_status := fnd_api.g_ret_sts_success;
  
    FOR rec_data IN cur_data(p_cur_organization_id   => p_organization_id,
                             p_cur_inventory_item_id => p_inventory_item_id,
                             p_cur_category_set_id   => p_category_set_id)
    LOOP
      IF rec_data.category_concat_segs = p_new_category_concat_segs THEN
        continue;
      END IF;
    
      l_category_rec              := inv_item_category_pub.get_category_rec_type;
      l_category_rec.structure_id := rec_data.structure_id;
      l_category_rec.segment1     := p_new_category_concat_segs;
    
      -- validate category
      inv_item_category_pub.get_category_id_from_cat_rec(p_category_rec  => l_category_rec,
                                                         x_category_id   => l_category_id,
                                                         x_return_status => l_return_status,
                                                         x_msg_data      => l_msg_data);
      -- no exists , create category                                     
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        inv_item_category_pub.create_category(p_api_version   => l_api_version,
                                              p_init_msg_list => l_init_msg_list,
                                              p_commit        => l_commit,
                                              x_return_status => l_return_status,
                                              x_errorcode     => l_errorcode,
                                              x_msg_count     => l_msg_count,
                                              x_msg_data      => l_msg_data,
                                              p_category_rec  => l_category_rec,
                                              x_category_id   => l_category_id);
        x_return_status := l_return_status;
        FOR l_index IN 1 .. l_msg_count + 1
        LOOP
          l_msg_data := fnd_msg_pub.get(p_msg_index => l_index, p_encoded => 'F');
          x_msg_data := x_msg_data || '[' || l_msg_data || ']';
        END LOOP;
      END IF;
    
      -- assign category
      IF l_return_status = fnd_api.g_ret_sts_success THEN
        inv_item_category_pub.update_category_assignment(p_api_version       => 1.0,
                                                         p_category_id       => l_category_id,
                                                         p_old_category_id   => rec_data.category_id,
                                                         p_category_set_id   => p_category_set_id,
                                                         p_inventory_item_id => p_inventory_item_id,
                                                         p_organization_id   => p_organization_id,
                                                         x_return_status     => l_return_status,
                                                         x_errorcode         => l_errorcode,
                                                         x_msg_count         => l_msg_count,
                                                         x_msg_data          => l_msg_data);
        x_return_status := l_return_status;
        FOR l_index IN 1 .. l_msg_count
        LOOP
          l_msg_data := fnd_msg_pub.get(p_msg_index => l_index, p_encoded => 'F');
          x_msg_data := x_msg_data || '[' || l_msg_data || ']';
        END LOOP;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data      := x_msg_data || '[ SQLERRM' || SQLERRM || ']';
  END proc_update_item_category;
BEGIN
  l_user_name                := 'HAND_PJL';
  l_new_category_concat_segs := 'R';
  SELECT fu.user_id
    INTO l_user_id
    FROM fnd_user fu
   WHERE fu.user_name = l_user_name;
  fnd_global.apps_initialize(user_id => l_user_id, resp_id => 50778, resp_appl_id => 20005);
  fnd_msg_pub.initialize;

  dbms_output.put_line(rpad('[ORG]', 5, ' ') || --
                       rpad('[ITEM]', 20, ' ') || --
                       rpad('[CATEGORY SET]', 25, ' ') || --
                       rpad('[OLD CATE]', 10, ' ') || --
                       rpad('[NEW CATE]', 10, ' ') || --
                       rpad('[STATUS]', 10, ' ') || --
                       rpad('[MESSAGE]', 10, ' ') --                       
                       );
  FOR rec_data IN cur_data
  LOOP
    proc_update_item_category(p_organization_id          => rec_data.organization_id,
                              p_inventory_item_id        => rec_data.inventory_item_id,
                              p_category_set_id          => rec_data.category_set_id,
                              p_new_category_concat_segs => l_new_category_concat_segs,
                              x_return_status            => l_return_status,
                              x_msg_data                 => l_msg_data);
  
    dbms_output.put_line(rpad(rec_data.organization_code, 5, ' ') || --
                         rpad(rec_data.item_number, 20, ' ') || --
                         rpad(rec_data.category_set_name, 25, ' ') || --
                         rpad(rec_data.category_concat_segs, 10, ' ') || --
                         rpad(l_new_category_concat_segs, 10, ' ') || --
                         rpad(l_return_status, 10, ' ') || --
                         l_msg_data --                       
                         );
  END LOOP;

END;
