REM dbdrv: none
        /*=======================================================================+
         |  Copyright (c) 2009, 2014 Oracle Corporation Redwood Shores, California, USA|
         |                            All rights reserved.                       |
         +=======================================================================*/
 
 /* $Header: poresreq.sql 120.0.12010000.5 2014/09/05 14:59:26 ptulzapu noship $ */

--PLEASE READ NOTE 390023.1 CAREFULLY BEFORE EXECUTING THIS SCRIPT.

/*
This script will:
- reset the document to incomplete status
- delete/update action history as desired (refere note 390023.1 for more details).
- abort all the related workflows 

If there is a distribution with wrong encumbrance amount related to this Requisition, it will:
- skip the reset action on the document.
*/

set serveroutput on size 100000
prompt
prompt
accept sql_req_number prompt 'Please enter the Requisition number to reset : ';
accept sql_org_id default NULL prompt 'Please enter the organization id to which the Requisition belongs (Default NULL) : ';
prompt
	

DECLARE

CURSOR reqtoreset (x_req_number varchar2, x_org_id number)
IS
  SELECT wf_item_type, wf_item_key, requisition_header_id , segment1,
         type_lookup_code
    FROM po_requisition_headers_all h
   WHERE h.segment1 = x_req_number
     AND h.org_id = x_org_id
     AND h.authorization_status in ('IN PROCESS','PRE-APPROVED')
     AND NVL(h.closed_code, 'OPEN') <> 'FINALLY_CLOSED'
     AND NVL(h.cancel_flag, 'N') = 'N';



cursor wfstoabort(st_item_type varchar2,st_item_key varchar2) is
select level,item_type,item_key,end_date
from wf_items
start with
    item_type = st_item_type and
    item_key =  st_item_key
connect by
    prior item_type = parent_item_type and
    prior item_key = parent_item_key
order by level desc;

 wf_rec wfstoabort%ROWTYPE;

 TYPE enc_tbl_number is TABLE OF NUMBER;
 TYPE enc_tbl_flag is TABLE OF VARCHAR2(1);

 x_org_id number 		  ;
 x_req_number varchar2(20);
 req_enc_flag varchar2(1);
 x_open_notif_exist varchar2(1);
 ros reqtoreset%ROWTYPE;

 x_progress varchar2(500);
 x_count_po_assoc number;
 x_active_wf_exists varchar2(1);
 l_tax NUMBER;
 l_amount NUMBER;
 nullseq number;
 l_req_dist_id    enc_tbl_number;
 l_req_enc_flag   enc_tbl_flag;
 l_req_enc_amount enc_tbl_number;
 l_req_gl_amount  enc_tbl_number;
 l_req_price	    enc_tbl_number;
 l_req_dist_qty   enc_tbl_number;
 l_req_dist_rate  enc_tbl_number;
 l_manual_cand    enc_tbl_flag;

 g_po_debug       VARCHAR2(1) := 'Y';
 l_timestamp      DATE := sysdate;
 l_precision      fnd_currencies.precision%type;
 l_min_acc_unit   fnd_currencies.minimum_accountable_unit%TYPE;
 l_disallow_script VARCHAR2(1);
 l_req_encumbrance VARCHAR2(1);



BEGIN

select &sql_org_id
  into x_org_id
  from dual;

select '&sql_req_number'
  into x_req_number
  from dual;

dbms_output.put_line ('req '||x_req_number||' in org '||x_org_id);

BEGIN
    select 'Y'
     into x_open_notif_exist
     from dual
     where exists (select 'open notifications'
 		    from wf_item_activity_statuses wias,
 			 wf_notifications wfn,
 			 po_requisition_headers_all porh
 		    where wias.notification_id is not null
 		      and wias.notification_id = wfn.group_id
 		      and wfn.status = 'OPEN'
 		      and wias.item_type = 'REQAPPRV'
 		      and wias.item_key = porh.wf_item_key
 		      and porh.org_id = x_org_id
 		      and porh.segment1=x_req_number
 		      and porh.authorization_status IN ('IN PROCESS', 'PRE-APPROVED'));
EXCEPTION
    when NO_DATA_FOUND then
      null;
END;



IF (x_open_notif_exist = 'Y') THEN
   dbms_output.put_line('      ');
   dbms_output.put_line('An Open notification exists for this document, you may want to use the notification to process this document. Do not commit if you wish to use the notification');
END IF;


select count(*)
  into x_count_po_assoc
  from po_requisition_lines_all prl,
       po_requisition_headers_all prh
 where prh.segment1= x_req_number
   and prh.org_id = x_org_id
   and prh.requisition_header_id = prl.requisition_header_id
   and (prl.line_location_id is not null or
        nvl(prh.transferred_to_oe_flag,'N') = 'Y');

IF (x_count_po_assoc > 0) THEN
   dbms_output.put_line('This requisition is associated with a PO or sales order and hence cannot be reset. Please contact Oracle support');
   return;
END IF;




open reqtoreset(x_req_number, x_org_id);

 fetch reqtoreset into ros;

 if reqtoreset%NOTFOUND then
     dbms_output.put_line('No such requisition with req number '||x_req_number||' exists which requires to be reset');
   return;
 end if;

 IF (g_po_debug = 'Y') then
       dbms_output.put_line('Processing '||ros.type_lookup_code
                             ||' Req Number: '
                             ||ros.segment1);
       dbms_output.put_line('......................................'); --116
 END IF;

 l_disallow_script := 'N'; 
 BEGIN
  SELECT 'Y'
  INTO   l_disallow_script
  FROM   dual
  WHERE  EXISTS (SELECT 'Wrong Encumbrance Amount'
                 FROM   po_requisition_lines_all l,
                               po_req_distributions_all d,
			       gl_ledgers g, fnd_currencies c		--BUG 19254890
                 WHERE  l.requisition_header_id = ros.requisition_header_id
                        AND d.requisition_line_id = l.requisition_line_id
			AND d.set_of_books_id = g.ledger_id AND g.currency_code = c.currency_code	--BUG 19254890
                        AND l.matching_basis = 'QUANTITY'
                        AND Nvl(d.encumbered_flag, 'N') = 'Y'
                        AND Nvl(l.cancel_flag, 'N') = 'N'
                        AND Nvl(l.closed_code, 'OPEN') <> 'FINALLY CLOSED'
                        AND Nvl(d.prevent_encumbrance_flag, 'N') = 'N'
                        AND d.budget_account_id IS NOT NULL
                        AND Round(Nvl(d.encumbered_amount, 0), c.precision) <>
                            Round(l.unit_price * d.req_line_quantity  + Nvl(d.nonrecoverable_tax, 0), c.precision)	--BUG 19254890
                 UNION
                 SELECT 'Wrong Encumbrance Amount'
                 FROM   po_requisition_lines_all l,
                               po_req_distributions_all d,
			       gl_ledgers g, fnd_currencies c		--BUG 19254890
                 WHERE  l.requisition_header_id = ros.requisition_header_id
                        AND d.requisition_line_id = l.requisition_line_id
			AND d.set_of_books_id = g.ledger_id AND g.currency_code = c.currency_code	--BUG 19254890
                        AND l.matching_basis = 'AMOUNT'
                        AND Nvl(d.encumbered_flag, 'N') = 'Y'
                        AND Nvl(l.cancel_flag, 'N') = 'N'
                        AND Nvl(l.closed_code, 'OPEN') <> 'FINALLY CLOSED'
                        AND Nvl(d.prevent_encumbrance_flag, 'N') = 'N'
                        AND d.budget_account_id IS NOT NULL
                        AND Round(Nvl(d.encumbered_amount, 0), c.precision) <>
                            Round(d.req_line_amount  + Nvl(d.nonrecoverable_tax, 0), c.precision));	--BUG 19254890
 EXCEPTION
 when NO_DATA_FOUND THEN
   NULL;
 end;

 if l_disallow_script = 'Y' then
    dbms_output.put_line('This Requisition has at least one distribution with wrong Encumbrance amount.');
    dbms_output.put_line('Hence this Requisition can not be reset');
    CLOSE reqtoreset;
    return;
 end if;


/* abort workflow processes if they exists */

       -- first check whether the wf process exists or not



       begin
        select 'Y'
          into x_active_wf_exists
          from wf_items wfi
         where wfi.item_type = ros.wf_item_type
    	  and wfi.item_key = ros.wf_item_key
 	  and wfi.end_date is null;

       exception
    	   when NO_DATA_FOUND then
       	   x_active_wf_exists := 'N';
       end;



       -- if the wf process is not already aborted then abort it.

       if (x_active_wf_exists = 'Y') THEN

          IF (g_po_debug = 'Y') then
             dbms_output.put_line('Aborting Workflow...');
          END IF;

          open wfstoabort(ros.wf_item_type,ros.wf_item_key);

          loop
             fetch wfstoabort into wf_rec;
             IF (g_po_debug = 'Y') then
	              dbms_output.put_line(wf_rec.item_type||wf_rec.item_key);
             END IF;
 	           if wfstoabort%NOTFOUND then
 	              close wfstoabort;
 	              exit;
 	           end if;

 	          if (wf_rec.end_date is null) then
 	          	BEGIN
 	      	       WF_Engine.AbortProcess(wf_rec.item_type, wf_rec.item_key);
          	  EXCEPTION
                   WHEN OTHERS THEN
                      dbms_output.put_line('Could not abort the workflow for PO :'
 		                                       ||ros.segment1 ||' Please contact Oracle Support ');
                      rollback;
 		                  return;
          	  END;

 	          end if;
 	      end loop;
       end if;


/* Update the authorization status of the requisition to incomplete */
      IF (g_po_debug = 'Y') then
          dbms_output.put_line('Updating Requisition Status...');
      END IF;

       UPDATE po_requisition_headers_all
       set authorization_status = 'INCOMPLETE',
           wf_item_type = NULL,
           wf_item_key = NULL
       where requisition_header_id = ros.requisition_header_id;



/* Update Action history setting the last null action code to NO ACTION */
         IF (g_po_debug = 'Y') then
            dbms_output.put_line('Updating PO Action History...');
         END IF;

         SELECT nvl(max(sequence_num), 0)
         into nullseq
	 FROM   po_action_history
	 WHERE  object_type_code = 'REQUISITION'
	 AND    object_sub_type_code = ros.type_lookup_code
	 AND    object_id = ros.requisition_header_id
	 AND    action_code is NULL;


 	Update po_action_history
 	set action_code = 'NO ACTION',
 	    action_date = trunc(sysdate),
 	    note = 'updated by reset script on '||to_char(trunc(sysdate))
         WHERE object_id = ros.requisition_header_id
         AND  object_type_code = 'REQUISITION'
         AND object_sub_type_code = ros.type_lookup_code
         AND sequence_num = nullseq
         AND action_code is NULL;


SELECT NVL(req_encumbrance_flag ,'N')
INTO l_req_encumbrance
FROM financials_system_params_all
WHERE org_id =  x_org_id;



IF l_req_encumbrance  = 'N' then
	dbms_output.put_line('Done Processing.');
	dbms_output.put_line('................');
	dbms_output.put_line('Please issue commit, if no errors found.');
	RETURN;
END IF;

close reqtoreset;

dbms_output.put_line('Done Processing.');
dbms_output.put_line('................');
dbms_output.put_line('Please issue commit, if no errors found.');

 EXCEPTION
 WHEN OTHERS THEN
   dbms_output.put_line('some exception occured '||sqlerrm||' rolling back'||x_progress);
   rollback;
   close reqtoreset;
   return;
 END;
/
