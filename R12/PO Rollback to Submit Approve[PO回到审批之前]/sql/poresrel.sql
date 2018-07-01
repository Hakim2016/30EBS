REM dbdrv: none
        /*=======================================================================+
         |  Copyright (c) 2009, 2014 Oracle Corporation Redwood Shores, California, USA|
         |                            All rights reserved.                       |
         +=======================================================================*/
 
 /* $Header: poresrel.sql 120.0.12010000.5 2014/09/05 15:00:13 ptulzapu noship $ */

/**************************************************************************************
CHANGE RECORD

CREATED/MODIFIED BY 	|	CREATION DATE	|	COMMENTS			|
Venkata Naga Suresh		 10-Aug-2009	     Script to reset a release. This
                                                     Script will skip the reset action,
						     if encumbrance is enabled.
***************************************************************************************/


-- PLEASE READ NOTE 390023.1 CAREFULLY BEFORE EXECUTING THIS SCRIPT.
/* 

This script will:
- reset the document to incomplete/requires reapproval status
- delete/update action history as desired (refere note 390023.1 for more details).
- abort all the related workflows 

If there is a distribution with wrong encumbrance amount related to this Release, it will:
- skip the reset action on the document.
*/

set serveroutput on size 100000
prompt
prompt
accept sql_po_number prompt 'Please enter the PO number for the release to reset : ';
accept sql_rel_number prompt 'Please enter the Release Number to reset : ';
accept sql_org_id default NULL prompt 'Please enter the organization id to which the PO belongs (Default NULL): ';
accept delete_act_hist prompt 'Do you want to delete the action history since the last approval ? (Y/N) ';
prompt


DECLARE

  /* select only the POs which are in preapproved, in process state and are not finally closed
  cancelled */

  CURSOR reltoreset(x_po_number varchar2, x_release_number number, x_org_id number) is
    SELECT por.wf_item_type,
           por.wf_item_key,
           por.po_header_id,
           por.po_release_id,
           por.release_num,
           por.release_type,
           por.revision_num,
           poh.segment1
      FROM po_headers_all poh, po_releases_all por
     WHERE poh.segment1 = x_po_number
       and por.release_num = x_release_number
       and NVL(por.org_id,-99) = NVL(x_org_id,-99)
       and NVL(por.org_id,-99) = NVL(poh.org_id,-99)
       and por.po_header_id = poh.po_header_id
       and por.authorization_status IN ('IN PROCESS', 'PRE-APPROVED')
       and NVL(por.cancel_flag, 'N') = 'N'
       and NVL(por.closed_code, 'OPEN') <> 'FINALLY_CLOSED';

  /* select the max sequence number with NULL action code */

  CURSOR maxseq(id number, subtype po_action_history.object_sub_type_code%type) is
    SELECT nvl(max(sequence_num), 0)
      FROM po_action_history
     WHERE object_type_code = 'RELEASE'
       AND object_sub_type_code = subtype
       AND object_id = id
       AND action_code is NULL;

  /* select the max sequence number with submit action */

  CURSOR poaction(id number, subtype po_action_history.object_sub_type_code%type) is
    SELECT nvl(max(sequence_num), 0)
      FROM po_action_history
     WHERE object_type_code = 'RELEASE'
       AND object_sub_type_code = subtype
       AND object_id = id
       AND action_code = 'SUBMIT';

  cursor wfstoabort(st_item_type varchar2, st_item_key varchar2) is
    select level, item_type, item_key, end_date
      from wf_items
     start with item_type = st_item_type
            and item_key = st_item_key
    connect by prior item_type = parent_item_type
           and prior item_key = parent_item_key
     order by level desc;

  wf_rec wfstoabort%ROWTYPE;

  submitseq po_action_history.sequence_num%type;
  nullseq   po_action_history.sequence_num%type;

  x_organization_id number;
  x_po_number       varchar2(20);

  rel          reltoreset%ROWTYPE; -- <Release Enc Script>
  x_rel_number number; -- <Release Enc Script>

  po_enc_flag        varchar2(1);
  x_open_notif_exist varchar2(1);

  x_progress         varchar2(500);
  x_cont             varchar2(10);
  x_active_wf_exists varchar2(1);
  l_delete_act_hist  varchar2(1);
  l_res_seq          po_action_history.sequence_num%TYPE;
  l_sub_res_seq      po_action_history.sequence_num%TYPE;
  l_res_act          po_action_history.action_code%TYPE;
  l_change_req_exists varchar2(1);
  l_del_res_hist     varchar2(1);

  /* For encumbrance actions */

  NAME_ALREADY_USED EXCEPTION;
  PRAGMA Exception_Init(NAME_ALREADY_USED, -955);
  X_STMT          VARCHAR2(2000);
  disallow_script VARCHAR2(1);

  TYPE enc_tbl_number is TABLE OF NUMBER;
  TYPE enc_tbl_flag is TABLE OF VARCHAR2(1);

  l_dist_id        enc_tbl_number;
  l_enc_flag       enc_tbl_flag;
  l_enc_amount     enc_tbl_number;
  l_gl_amount      enc_tbl_number;
  l_manual_cand    enc_tbl_flag;
  l_req_dist_id    enc_tbl_number;
  l_req_enc_flag   enc_tbl_flag;
  l_req_enc_amount enc_tbl_number;
  l_req_gl_amount  enc_tbl_number;

  l_ppo_dist_id    enc_tbl_number;
  l_ppo_unenc_qty  enc_tbl_number;
  l_rel_unenc_qty1 enc_tbl_number;
  l_rel_unenc_qty2 enc_tbl_number;
  l_rel_unenc_qty  enc_tbl_number;
  l_ppo_ord_qty    enc_tbl_number;
  l_ppo_price      enc_tbl_number;
  l_ppo_rate       enc_tbl_number;
  l_ppo_enc_amount enc_tbl_number;
  l_ppo_gl_Enc_Amt enc_tbl_number;
  l_req_qty_bill_del  enc_tbl_number;
  l_rate_table	      enc_tbl_number;
  l_price_table       enc_tbl_number;
  l_qty_ordered_table enc_tbl_number;
  l_req_price_table   enc_tbl_number;


  l_timestamp        date;
  l_bill_del_amount  NUMBER;
  l_qty_bill_del     NUMBER;
  l_remainder_qty    NUMBER;
  l_req_bill_del_amount  NUMBER;
  l_eff_quantity     NUMBER;
  l_rate             NUMBER;
  l_price            NUMBER;
  l_ordered_quantity NUMBER;
  l_tax              NUMBER;
  l_amount           NUMBER;
  l_precision        fnd_currencies.precision%type;
  l_min_acc_unit     fnd_currencies.minimum_accountable_unit%TYPE;
  l_approved_flag    po_line_locations_all.approved_flag%TYPE;
  l_req_encumbrance_flag varchar2(1);
  l_purch_encumbrance_flag varchar2(1);
  i                  number;
  j                  number;
  k                  number;

BEGIN

  select '&delete_act_hist' into l_delete_act_hist from dual;

  select &sql_org_id into x_organization_id from dual;

  select '&sql_po_number' into x_po_number from dual;

  select &sql_rel_number into x_rel_number from dual;

  x_progress := '010: start';

  begin
    select 'Y'
      into x_open_notif_exist
      from dual
     where exists (select 'open notifications'
              from wf_item_activity_statuses wias,
                   wf_notifications          wfn,
                   po_headers_all            poh,
                   po_releases_all           por
             where wias.notification_id is not null
               and wias.notification_id = wfn.group_id
               and wfn.status = 'OPEN'
               and wias.item_type = 'POAPPRV'
               and wias.item_key = por.wf_item_key
               and poh.po_header_id = por.po_header_id
               and nvl(poh.org_id,-99) = nvl(por.org_id,-99)
               and nvl(poh.org_id,-99) = nvl(x_organization_id,-99)
               and poh.segment1 = x_po_number
               and por.release_num = x_rel_number
               and por.authorization_status IN
                   ('IN PROCESS', 'PRE-APPROVED'));
  exception
    when NO_DATA_FOUND then
      null;
  end;

  x_progress := '020: selected open notif';

  if (x_open_notif_exist = 'Y') then
    dbms_output.put_line('  ');
    dbms_output.put_line('An Open notification exists for this document, you may want to use the notification to process this document. Do not commit if you wish to use the notification');
  end if;

  begin
select 'Y'
  into l_change_req_exists
  from dual
  where exists (select 'po with change request'
  		  from po_headers_all h  , po_releases_all r
		  where h.segment1 = x_po_number
        	    and r.release_num = x_rel_number
		    and nvl(r.org_id, -99) = NVL(x_organization_id, -99)
        	    and nvl(h.org_id, -99) = NVL(x_organization_id, -99)
        	    and r.po_header_id = h.po_header_id
		    and r.change_requested_by in ('REQUESTER', 'SUPPLIER'));
exception 
   when NO_DATA_FOUND then
     null;
end;

if (l_change_req_exists = 'Y') then
     dbms_output.put_line('ATTENTION !!! There is an open change request against this Release. You should respond to the notification for the same.');
   --dbms_output.put_line('If you are running this script unaware of the change request, Please ROLLBACK');
   return;
end if;


  open reltoreset(x_po_number, x_rel_number, x_organization_id);

  fetch reltoreset
    into rel;
  if reltoreset%NOTFOUND then
    dbms_output.put_line('No Release with Release Number ' || x_po_number ||
                         ' - ' || x_rel_number || ' exists in org ' ||
                         to_char(x_organization_id) ||
                         ' which requires to be reset');
    return;
  end if;

  dbms_output.put_line('Processing ' || rel.release_type || ' Release ' ||
                       rel.segment1 || '-' || to_char(rel.release_num));
  dbms_output.put_line('......................................');
  close reltoreset;

 x_progress := '030 checking enc action ';

 disallow_script := 'N'; 
 BEGIN
  SELECT 'Y'
  INTO   disallow_script
  FROM   dual
  WHERE  EXISTS (SELECT 'Wrong Encumbrance Amount'
                 FROM   po_lines_all l,
                        po_line_locations_all s,
                        po_distributions_all d,
			gl_ledgers g, fnd_currencies c		--BUG 19254890
                 WHERE  s.line_location_id = d.line_location_id
                        AND l.po_line_id = s.po_line_id
                        AND d.po_release_id = rel.po_release_id
			AND d.set_of_books_id = g.ledger_id AND g.currency_code = c.currency_code	--BUG 19254890
                        AND l.matching_basis = 'QUANTITY'
                        AND Nvl(d.encumbered_flag, 'N') = 'Y'
                        AND Nvl(s.cancel_flag, 'N') = 'N'
                        AND Nvl(s.closed_code, 'OPEN') <> 'FINALLY CLOSED'
                        AND Nvl(d.prevent_encumbrance_flag, 'N') = 'N'
                        AND d.budget_account_id IS NOT NULL
                        AND Round(Nvl(d.encumbered_amount, 0), c.precision) <>
                            Round((s.price_override * d.quantity_ordered *
                                   Nvl(d.rate, 1) + Nvl(d.nonrecoverable_tax, 0) *
                                   Nvl(d.rate, 1) ), c.precision)		--BUG 19254890
                 UNION
                 SELECT 'Wrong Encumbrance Amount'
                 FROM   po_lines_all l,
                        po_line_locations_all s,
                        po_distributions_all d,
			gl_ledgers g, fnd_currencies c		--BUG 19254890
                 WHERE  s.line_location_id = d.line_location_id
                        AND l.po_line_id = s.po_line_id
                        AND d.po_release_id = rel.po_release_id
			AND d.set_of_books_id = g.ledger_id AND g.currency_code = c.currency_code	--BUG 19254890
                        AND l.matching_basis = 'AMOUNT'
                        AND Nvl(d.encumbered_flag, 'N') = 'Y'
                        AND Nvl(s.cancel_flag, 'N') = 'N'
                        AND Nvl(s.closed_code, 'OPEN') <> 'FINALLY CLOSED'
                        AND Nvl(d.prevent_encumbrance_flag, 'N') = 'N'
                        AND d.budget_account_id IS NOT NULL
                        AND Round(Nvl(d.encumbered_amount, 0), c.precision) <>
                            Round((d.amount_ordered + Nvl(d.nonrecoverable_tax, 0) ) *
                                   Nvl(d.rate, 1),c.precision));		--BUG 19254890
 EXCEPTION
 when NO_DATA_FOUND THEN
   NULL;
 end;

 if disallow_script = 'Y' then
    dbms_output.put_line('This Release has at least one distribution with wrong Encumbrance amount.');
    dbms_output.put_line('Hence this PO can not be reset.');
    return;
 end if;     

  dbms_output.put_line('Processing ' || rel.release_type || ' Release ' ||
                       rel.segment1 || '-' || to_char(rel.release_num));
  dbms_output.put_line('......................................');

  begin
    select 'Y'
      into x_active_wf_exists
      from wf_items wfi
     where wfi.item_type = rel.wf_item_type
       and wfi.item_key = rel.wf_item_key
       and wfi.end_date is null;

  exception
    when NO_DATA_FOUND then
      x_active_wf_exists := 'N';
  end;

  if (x_active_wf_exists = 'Y') then
    dbms_output.put_line('Aborting Workflow...');
    open wfstoabort(rel.wf_item_type, rel.wf_item_key);
    loop
      fetch wfstoabort
        into wf_rec;
      if wfstoabort%NOTFOUND then
        close wfstoabort;
        exit;
      end if;

      if (wf_rec.end_date is null) then
        BEGIN
          WF_Engine.AbortProcess(wf_rec.item_type, wf_rec.item_key);
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line(' workflow not aborted :' ||
                                 wf_rec.item_type || '-' ||
                                 wf_rec.item_key);

        END;

      end if;
    end loop;
  end if;

  dbms_output.put_line('Updating Release Status...');
  UPDATE po_releases_all
     set authorization_status = decode(rel.revision_num,
                                       0,
                                       'INCOMPLETE',
                                       'REQUIRES REAPPROVAL'),
         approved_flag        = decode(rel.revision_num, 0, 'N', 'R'),
         wf_item_type         = NULL,
         wf_item_key          = NULL
   where po_release_id = rel.po_release_id;

  OPEN maxseq(rel.po_release_id, rel.release_type);
  FETCH maxseq
    into nullseq;
  CLOSE maxseq;

  OPEN poaction(rel.po_release_id, rel.release_type);
  FETCH poaction
    into submitseq;
  CLOSE poaction;
  IF nullseq > submitseq THEN

    if nvl(l_delete_act_hist, 'N') = 'N' then
      Update po_action_history
         set action_code = 'NO ACTION',
             action_date = trunc(sysdate),
             note        = 'updated by reset script on ' ||
                           to_char(trunc(sysdate))
       WHERE object_id = rel.po_release_id
         AND object_type_code = 'RELEASE'
         AND object_sub_type_code = rel.release_type
         AND sequence_num = nullseq
         AND action_code is NULL;
    else

      Delete po_action_history
       where object_id = rel.po_release_id
         and object_type_code = 'RELEASE'
         and object_sub_type_code = rel.release_type
         and sequence_num >= submitseq
         and sequence_num <= nullseq;

    end if;

  END IF;

  dbms_output.put_line('Done Approval Processing.');


  select nvl(req_encumbrance_flag,'N'), nvl(purch_encumbrance_flag,'N')
   into l_req_encumbrance_flag, l_purch_encumbrance_flag
   from financials_system_params_all fspa
   where NVL(fspa.org_id,-99) = NVL(x_organization_id,-99);
   
   if (l_purch_encumbrance_flag='N') then
   
      dbms_output.put_line('document reset successfully');
      dbms_output.put_line('encumbrance processing not required');
      dbms_output.put_line('please COMMIT data');
      return;
   end if;

  -- reserve action history stuff
  -- check the action history and delete any reserve to submit actions if all the distributions
  -- are now unencumbered, this should happen only if we are deleting the action history

  if l_delete_act_hist = 'Y' then

    -- first get the last sequence and action code from action history
    begin
      select sequence_num, action_code
        into l_res_seq, l_res_act
        from po_action_history pah
       WHERE pah.object_id = rel.po_release_id
         AND pah.object_type_code = 'RELEASE'
         AND pah.object_sub_type_code = rel.release_type
         AND sequence_num in
             (select max(sequence_num)
                from po_action_history pah1
               where pah1.object_id = pah.object_id
                 AND pah1.object_type_code = pah.object_type_code
                 AND pah1.object_sub_type_code = pah.object_sub_type_code);
    exception
      when TOO_MANY_ROWS then
        dbms_output.put_line('action history needs to be corrected separately ');
      when NO_DATA_FOUND then
        null;
    end;

    -- now if the last action is reserve get the last submit action sequence

    if (l_res_act = 'RESERVE') then
      begin
        select max(sequence_num)
          into l_sub_res_seq
          from po_action_history pah
         where action_code = 'SUBMIT'
           and pah.object_id = rel.po_release_id
           and pah.object_type_code = 'RELEASE'
           and pah.object_sub_type_code = rel.release_type;
      exception
        when NO_DATA_FOUND then
          null;
      end;

      -- check if we need to delete the action history, ie. if all the distbributions
      -- are unreserved

      if ((l_sub_res_seq is not null) and (l_res_seq > l_sub_res_seq)) then

        begin
          select 'Y'
            into l_del_res_hist
            from dual
           where not exists
           (select 'encumbered dist'
                    from po_distributions_all pod
                   where nvl(pod.po_release_id, -1) = rel.po_release_id
                     and nvl(pod.encumbered_flag, 'N') = 'Y'
                     and nvl(pod.prevent_encumbrance_flag, 'N') = 'N');
        exception
          when NO_DATA_FOUND then
            l_del_res_hist := 'N';
        end;

        if l_del_res_hist = 'Y' THEN

          dbms_output.put_line('deleting reservation action history ... ');

          delete po_action_history pah
           where pah.object_id = rel.po_release_id
             and pah.object_type_code = 'RELEASE'
             and pah.object_sub_type_code = rel.release_type
             and sequence_num >= l_sub_res_seq
             and sequence_num <= l_res_seq;
        end if;

      end if; -- l_res_seq > l_sub_res_seq

    end if;

  end if;

  dbms_output.put_line('.................................');
  dbms_output.put_line('.................................');
  dbms_output.put_line('.................................');
  dbms_output.put_line('.................................');
  dbms_output.put_line('                                 ');
  dbms_output.put_line('RESET ACTION COMPLETED, PLEASE COMMIT DATA..');

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('some exception occured ' || sqlerrm ||
                         ' rolling back' || x_progress);
    rollback;
END;
/
