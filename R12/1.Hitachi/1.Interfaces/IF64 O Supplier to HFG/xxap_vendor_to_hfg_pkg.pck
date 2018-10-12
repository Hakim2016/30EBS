CREATE OR REPLACE PACKAGE xxap_vendor_to_hfg_pkg IS
  /*=================================================================
   Copyright (C) HAND Enterprise Solutions Co.,Ltd.
                AllRights Reserved
    =================================================================
  * =================================================================
  *   PROGRAM NAME: 
  *         XXAP_VENDOR_TO_HFG_PKG
  *                
  *   DESCRIPTION:
  *         get new VENDOR info outbound to HFA
  *   HISTORY:
  *     1.00  2012-05-24   colin.chen  Created
  *
  * ===============================================================*/

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  main
  *   DESCRIPTION:
  *              hfg_main 
  *   ARGUMENT:  p_group_id         
  *              p_interface_date 
  *   RETURN:
  *
  *   HISTORY:
  *     1.00 2012-05-24 colin.chen
  *                 
  * =============================================*/
  PROCEDURE hfg_main(errbuf           OUT VARCHAR2,
                     retcode          OUT VARCHAR2,
                     p_group_id       IN NUMBER,
                     p_interface_date IN VARCHAR2,
                     p_ledger         IN VARCHAR2 /*,
                     p_rerun_flag     IN VARCHAR2*/);

END xxap_vendor_to_hfg_pkg;
/
CREATE OR REPLACE PACKAGE BODY xxap_vendor_to_hfg_pkg IS
  /*=================================================================
   Copyright (C) HAND Enterprise Solutions Co.,Ltd.
                AllRights Reserved
    =================================================================
  * =================================================================
  *   PROGRAM NAME:
  *         xxap_vendor_to_hfg_pkg
  *
  *   DESCRIPTION:
  *         get new vendor info outbound to hfg
  *   HISTORY:
  *     1.00  2012-05-24   colin.chen  Created
  *     2.00  2015-04-17 11:27:00 jinlong.pan update column recipient_type logic
  *     2.01  2015-06-19 shengxiang.fan update for insert record
  *     2.10  2015-09-07 Jinlong.Pan    Update Change error handling method from A to B.
  *     3.00  2015-11-21 Jinlong.Pan    Update for CR#3412 Branch from GSCM to HFG
        4.00  2016/12/06 LIUDAN         update for HET cr
  * ===============================================================*/

  g_pkg_name  CONSTANT VARCHAR2(30) := 'XXAP_VENDOR_TO_HFG_PKG';
  g_seperator CONSTANT VARCHAR2(1) := chr(9);
  g_blank_char VARCHAR2(1);
  g_max_length CONSTANT NUMBER := 2000;
  --g_date_format     CONSTANT VARCHAR2(15) := 'DD-MM-YYYY';
  g_user_id         CONSTANT NUMBER := fnd_global.user_id;
  g_log_id          CONSTANT NUMBER := fnd_global.login_id;
  g_request_id      CONSTANT NUMBER := fnd_global.conc_request_id;
  g_program_id      CONSTANT NUMBER := fnd_global.conc_program_id;
  g_program_appl_id CONSTANT NUMBER := fnd_global.prog_appl_id;
  g_miss_rec xxap_vendor_to_hfg_int%ROWTYPE;

  PROCEDURE out_msg(p_msg IN VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.output, p_msg);
  END out_msg;

  PROCEDURE log_msg(p_msg IN VARCHAR2) IS
  BEGIN
    fnd_file.put_line(fnd_file.log, p_msg);
  END log_msg;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_ou_name
  *   DESCRIPTION:
  *              get_ou_name
  *   ARGUMENT:  p_org_id
  *
  *   RETURN:
  *              varchar2
  *   HISTORY:
  *     1.00 2012-06-12 colin.chen
  *
  * =============================================*/
  FUNCTION get_ou_name(p_org_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR cur IS
      SELECT hou.name
        FROM hr_operating_units hou
       WHERE hou.organization_id = p_org_id;
    l_rec cur%ROWTYPE;
  BEGIN
    OPEN cur;
    FETCH cur
      INTO l_rec;
    CLOSE cur;

    RETURN l_rec.name;
  END get_ou_name;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :     replace_seperator
  *   DESCRIPTION:
  *              replace seperator with one space
  *   ARGUMENT:  p_string
  *
  *   RETURN:
  *              return string without seperator
  *   HISTORY:
  *     1.00 2012-05-24 colin.chen
  *
  * =============================================*/
  FUNCTION replace_seperator(p_string IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN REPLACE(p_string, g_seperator, ' ');
  END replace_seperator;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_last_run_date
  *   DESCRIPTION:
  *              get_last_run_date
  *   HISTORY:
  *     1.00 2014-07-31 Jia
  *
  * =============================================*/
  FUNCTION get_last_run_date(p_ledger_name IN VARCHAR2) RETURN DATE IS
    CURSOR cur IS
      SELECT MAX(last_update_date) last_update_date
        FROM xxap_vendor_to_hfg_int xcth
       WHERE xcth.ledger_name = p_ledger_name;
    l_rec cur%ROWTYPE;
  BEGIN
    OPEN cur;
    FETCH cur
      INTO l_rec;
    CLOSE cur;

    RETURN l_rec.last_update_date;

  END get_last_run_date;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  print_error_report
  *   DESCRIPTION:
  *              print_error_report
  *   ARGUMENT:  p_group_id
  *
  *   RETURN:
  *
  *   HISTORY:
  *     1.00 2012-06-12 colin.chen
  *
  * =============================================*/
  PROCEDURE print_error_report(p_group_id IN NUMBER) IS
    CURSOR cur IS
      SELECT *
        FROM xxap_vendor_to_hfg_int xvh
       WHERE xvh.process_status = fnd_api.g_ret_sts_error
         AND xvh.group_id = p_group_id;
    l_msg VARCHAR2(20000);
  BEGIN
    log_msg(rpad('-', 300, '-'));
    l_msg := 'OU' || g_seperator || 'Account assgnt group' || g_seperator || 'Vendor' || g_seperator || 'Company Code' ||
             g_seperator || 'Name 1' || g_seperator || 'Search term 1' || g_seperator || 'City' || g_seperator ||
             'Country' || g_seperator || 'Recon.account' || g_seperator || 'Error message';
    log_msg(l_msg);
    FOR rec IN cur
    LOOP
      l_msg := get_ou_name(rec.org_id) || g_seperator || rec.account_assgnt_group || g_seperator || rec.vendor_number ||
               g_seperator || rec.company_code || g_seperator || rec.name1 || g_seperator || rec.search_term1 ||
               g_seperator || rec.city || g_seperator || rec.country || g_seperator || rec.recon_account || g_seperator ||
               rec.process_message;
      log_msg(l_msg);
    END LOOP;
    log_msg(rpad('-', 300, '-'));

    DELETE FROM xxap_vendor_to_hfg_int xvh
     WHERE xvh.process_status = fnd_api.g_ret_sts_error
       AND xvh.group_id = p_group_id;
  END print_error_report;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  generate_goe_file
  *   DESCRIPTION:
  *              generate_goe_file
  *   ARGUMENT:  p_group_id
  *
  *   RETURN:
  *
  *   HISTORY:
  *     1.00 2012-05-10 colin.chen
  *
  * =============================================*/
  PROCEDURE generate_hfg_file(p_ledger    IN VARCHAR2,
                              p_group_id  IN NUMBER,
                              p_file_name IN VARCHAR2) IS
    CURSOR cur IS
      SELECT xci.*,
             decode(xci.rerun_flag, 'Y', g_blank_char, decode(xci.new_vendor_flag, 'Y', xci.g_g_code, g_blank_char)) g_g_code_output
        FROM xxap_vendor_to_hfg_int xci
       WHERE xci.group_id = p_group_id;
    l_msg               VARCHAR2(32767);
    l_outbound_path_dir VARCHAR2(200);
    l_outbound_path     VARCHAR2(200);
    c_amount CONSTANT BINARY_INTEGER := 32767;
    l_fhandler utl_file.file_type;
    l_cnt      NUMBER;
  BEGIN
    out_msg('p_group_id:' || p_group_id);
    SELECT COUNT(1)
      INTO l_cnt
      FROM xxap_vendor_to_hfg_int xci
     WHERE xci.group_id = p_group_id;
    IF l_cnt = 0 THEN
      out_msg('No data get in this request, will not generate file on server.');
    ELSE
      /*l_outbound_path     := '/mt3/IF_Folders/IF64/' ||
                             substr(p_ledger, 1, 3) || '_LEDGER/unprocess';
      l_outbound_path_dir := 'XXAPB002_' || substr(p_ledger, 1, 3) ||
                             '_OUTBOUND_DIR';
      EXECUTE IMMEDIATE 'create or replace directory ' ||
                        l_outbound_path_dir || ' AS ''' || l_outbound_path || '''';
      l_fhandler := utl_file.fopen(l_outbound_path_dir,
                                   p_file_name,
                                   'W',
                                   c_amount);
      IF utl_file.is_open(l_fhandler) = FALSE THEN
        out_msg('ERROR OPENING FILE FOR ' || l_outbound_path_dir || ':' ||
                SQLERRM);
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;*/
      l_msg := 'Vendor' || g_seperator || 'Company Code' || g_seperator || 'Account group' || g_seperator || 'Title' ||
               g_seperator || 'Name1' || g_seperator || 'Name2' || g_seperator || 'Name3' || g_seperator || 'Name4' ||
               g_seperator || 'Search term 1' || g_seperator || 'Street 2' || g_seperator || 'Street 3' || g_seperator ||
               'Street' || g_seperator || 'House number' || g_seperator || 'supplement' || g_seperator || 'Street 4' ||
               g_seperator || 'Street 5' || g_seperator || 'District' || g_seperator || 'Different City' || g_seperator ||
               'City' || g_seperator || 'Postal Code' || g_seperator || 'Country' || g_seperator || 'Region' ||
               g_seperator || 'Time zone' || g_seperator || 'Jurisdict. code' || g_seperator || 'PO Box' || g_seperator ||
               'PO Box without number' || g_seperator || 'Delivery Serv' || g_seperator || 'Delivery Service Number' ||
               g_seperator || 'PO Box Lobby' || g_seperator || 'Postal code' || g_seperator || 'Other city' ||
               g_seperator || 'Other country' || g_seperator || 'Other region' || g_seperator || 'Company postal code' ||
               g_seperator || 'Language' || g_seperator || 'Telephone' || g_seperator || 'Extension' || g_seperator ||
               'Mobile Phone' || g_seperator || 'FAX' || g_seperator || 'Extension' || g_seperator || 'E-Mail' ||
               g_seperator || 'StandardComm.Mtd' || g_seperator || 'Data line' || g_seperator || 'Telebox' ||
               g_seperator || 'Comments' || g_seperator || 'Customer' || g_seperator || 'Corporate Group' ||
               g_seperator || 'Tax Number 1' || g_seperator || 'Tax Number 2' || g_seperator || 'Tax Number 3' ||
               g_seperator || 'Tax Number 4' || g_seperator || 'Fiscal address' || g_seperator || 'VAT Reg. No.' ||
               g_seperator || 'Rep''s Name' || g_seperator || 'Type of Busines' || g_seperator || 'Tax office' ||
               g_seperator || 'Type of Industr' || g_seperator || 'Tax Number' || g_seperator || 'Tax number type' ||
               g_seperator || 'Tax type' || g_seperator || 'Tax base' || g_seperator || 'Soc. Ins. Code' || g_seperator ||
               'Equalization Tax' || g_seperator || 'Sole Proprietr' || g_seperator || 'Liable for VAT' || g_seperator ||
               'Tax Split' || g_seperator || 'Soc. Insurance' || g_seperator || 'Location no. 1' || g_seperator ||
               'Location no. 2' || g_seperator || 'Check digit' || g_seperator || 'Cred.info no' || g_seperator ||
               'Last ext.review' || g_seperator || 'Industry' || g_seperator || 'Train station' || g_seperator ||
               'SCAC' || g_seperator || 'Car.freight grp' || g_seperator || 'ServAgntProcGrp' || g_seperator ||
               'Stat.gr.tra.ser' || g_seperator || 'POD-relevant' || g_seperator || 'Actual QM sys.' || g_seperator ||
               'QM system to' || g_seperator || 'External manuf' || g_seperator || 'Date of birth' || g_seperator ||
               'Place of birth' || g_seperator || 'Sex' || g_seperator || 'Profession' || g_seperator ||
               'Bank country key' || g_seperator || 'Bank key' || g_seperator || 'Bank Account' || g_seperator ||
               'Acct holder' || g_seperator || 'Control Key' || g_seperator || 'IBAN' || g_seperator || 'Valid from' ||
               g_seperator || 'Partner Bank Type' || g_seperator || 'Reference specifications ' || g_seperator ||
               'collection authorization ' || g_seperator || 'Alternative payee' || g_seperator || 'DME Indicator' ||
               g_seperator || 'Instruction key' || g_seperator || 'ISR Number' || g_seperator || 'Individual spec.' ||
               g_seperator || 'Recon. account' || g_seperator || 'Sort key' || g_seperator || 'Head office' ||
               g_seperator || 'Subsidy indic.' || g_seperator || 'Release group' || g_seperator || 'Minority indic.' ||
               g_seperator || 'Certificatn date' || g_seperator || 'Interest indic.' || g_seperator || 'Last key date' ||
               g_seperator || 'Interest freq.' || g_seperator || 'Last interest run' || g_seperator || 'Prev.acct no.' ||
               g_seperator || 'Personnel number' || g_seperator || 'Activity Code' || g_seperator || 'Distr. Type' ||
               g_seperator || 'Payt Terms' || g_seperator || 'Tolerance group' || g_seperator || 'Cr memo terms' ||
               g_seperator || 'Chk double inv.' || g_seperator || 'Payment methods' || g_seperator || 'Payment block' ||
               g_seperator || 'Alternat.payee' || g_seperator || 'House Bank' || g_seperator || 'Individual payment' ||
               g_seperator || 'Grouping key' || g_seperator || 'Clearing with Customer' || g_seperator ||
               'B/exch.limit' || g_seperator || 'EDI' || g_seperator || 'PmtAdv. XML' || g_seperator ||
               'Tolerance group' || g_seperator || 'Prepayment' || g_seperator || 'Local Process' || g_seperator ||
               'Acct statement' || g_seperator || 'Acctg clerk' || g_seperator || 'Acct w/ vendor' || g_seperator ||
               'Clerk at vendor' || g_seperator || 'Act.clk tel.no.' || g_seperator || 'Clerk''s fax' || g_seperator ||
               'Clrk''s internet' || g_seperator || 'Account memo' || g_seperator || 'Withholding Tax Country Key' ||
               g_seperator || 'withholding tax type' || g_seperator || 'withholding tax code' || g_seperator ||
               'Subject to withholding tax' || g_seperator || 'Type of recipient' || g_seperator || 'W/tax ID' ||
               g_seperator || 'Excemption number' || g_seperator || 'Excemption %' || g_seperator || 'Excempt reason' ||
               g_seperator || 'Excempt From' || g_seperator || 'Excempt To' || g_seperator || 'G&G code' || g_seperator ||
               'Authorization';
      out_msg(l_msg);
      -- utl_file.put_line(l_fhandler, l_msg);
      FOR rec IN cur
      LOOP
        l_msg := replace_seperator(rec.vendor_number) || g_seperator || replace_seperator(rec.company_code) ||
                 g_seperator || replace_seperator(rec.account_assgnt_group) || g_seperator ||
                 replace_seperator(rec.title) || g_seperator || replace_seperator(rec.name1) || g_seperator ||
                 replace_seperator(rec.name2) || g_seperator || replace_seperator(rec.name3) || g_seperator ||
                 replace_seperator(rec.name4) || g_seperator || replace_seperator(rec.search_term1) || g_seperator ||
                 replace_seperator(rec.street2) || g_seperator || replace_seperator(rec.street3) || g_seperator ||
                 replace_seperator(rec.street) || g_seperator || replace_seperator(rec.house_number) || g_seperator ||
                 replace_seperator(rec.supplement) || g_seperator || replace_seperator(rec.street4) || g_seperator ||
                 replace_seperator(rec.street5) || g_seperator || replace_seperator(rec.district) || g_seperator ||
                 replace_seperator(rec.different_city) || g_seperator || replace_seperator(rec.city) || g_seperator ||
                 replace_seperator(rec.postal_code) || g_seperator || replace_seperator(rec.country) || g_seperator ||
                 replace_seperator(rec.region) || g_seperator || replace_seperator(rec.time_zone) || g_seperator ||
                 replace_seperator(rec.jurisdict_code) || g_seperator || replace_seperator(rec.po_box) || g_seperator ||
                 replace_seperator(rec.po_box_without_number) || g_seperator ||
                 replace_seperator(rec.delivery_service_number) || g_seperator || replace_seperator(rec.po_box_lobby) ||
                 g_seperator || replace_seperator(rec.postal_code1) || g_seperator || replace_seperator(rec.other_city) ||
                 g_seperator || replace_seperator(rec.other_country) || g_seperator ||
                 replace_seperator(rec.other_region) || g_seperator || replace_seperator(rec.company_postal_code) ||
                 g_seperator || replace_seperator(rec.language) || g_seperator || replace_seperator(rec.telephone) ||
                 g_seperator || replace_seperator(rec.extension) || g_seperator ||
                 replace_seperator(rec.mobile_telephone) || g_seperator || replace_seperator(rec.fax) || g_seperator ||
                 replace_seperator(rec.fax_extension) || g_seperator || replace_seperator(rec.e_mail) || g_seperator ||
                 replace_seperator(rec.std_comm_method) || g_seperator || replace_seperator(rec.data_line) ||
                 g_seperator || replace_seperator(rec.telebox) || g_seperator || replace_seperator(rec.comments) ||
                 g_seperator || replace_seperator(rec.customer) || g_seperator ||
                 replace_seperator(rec.corporate_group) || g_seperator || replace_seperator(rec.tax_number1) ||
                 g_seperator || replace_seperator(rec.tax_number2) || g_seperator || replace_seperator(rec.tax_number3) ||
                 g_seperator || replace_seperator(rec.tax_number_4) || g_seperator ||
                 replace_seperator(rec.fiscal_address) || g_seperator || replace_seperator(rec.vat_reg_no) ||
                 g_seperator || replace_seperator(rec.representative) || g_seperator ||
                 replace_seperator(rec.business_type) || g_seperator || replace_seperator(rec.tax_office) ||
                 g_seperator || replace_seperator(rec.industry_type) || g_seperator ||
                 replace_seperator(rec.tax_number) || g_seperator || replace_seperator(rec.tax_type) || g_seperator ||
                 replace_seperator(rec.tax_base) || g_seperator || replace_seperator(rec.soc_ins_code) || g_seperator ||
                 replace_seperator(rec.equalization_tax) || g_seperator || replace_seperator(rec.sole_proprietr) ||
                 g_seperator || replace_seperator(rec.liable) || g_seperator || replace_seperator(rec.tax_split) ||
                 g_seperator || replace_seperator(rec.social_insurance1) || g_seperator ||
                 replace_seperator(rec.location_no_1) || g_seperator || replace_seperator(rec.location_no_2) ||
                 g_seperator || replace_seperator(rec.check_digit) || g_seperator ||
                 replace_seperator(rec.cred_info_no) || g_seperator || replace_seperator(rec.last_ext_review) ||
                 g_seperator || replace_seperator(rec.industry) || g_seperator || replace_seperator(rec.train_station) ||
                 g_seperator || replace_seperator(rec.scac) || g_seperator || replace_seperator(rec.car_freight_grp) ||
                 g_seperator || replace_seperator(rec.serv_agnt_proc_grp) || g_seperator ||
                 replace_seperator(rec.stat_gr_tra_ser) || g_seperator || replace_seperator(rec.pod_relevant) ||
                 g_seperator || replace_seperator(rec.actual_qm_sys) || g_seperator ||
                 replace_seperator(rec.qm_system_to) || g_seperator || replace_seperator(rec.external_manufacturer) ||
                 g_seperator || replace_seperator(rec.date_of_birth) || g_seperator ||
                 replace_seperator(rec.place_of_birth) || g_seperator || replace_seperator(rec.sex) || g_seperator ||
                 replace_seperator(rec.profession) || g_seperator || replace_seperator(rec.bank_country_key) ||
                 g_seperator || replace_seperator(rec.bank_key) || g_seperator || replace_seperator(rec.bank_account) ||
                 g_seperator || replace_seperator(rec.acct_holder) || g_seperator || replace_seperator(rec.ck) ||
                 g_seperator || replace_seperator(rec.iban) || g_seperator || replace_seperator(rec.valid_from) ||
                 g_seperator || replace_seperator(rec.partner_bank_type) || g_seperator ||
                 replace_seperator(rec.reference_specifications) || g_seperator ||
                 replace_seperator(rec.collection_authorization) || g_seperator ||
                 replace_seperator(rec.alternative_payee) || g_seperator || replace_seperator(rec.dme_indicator) ||
                 g_seperator || replace_seperator(rec.instruction_key) || g_seperator ||
                 replace_seperator(rec.isr_number) || g_seperator || replace_seperator(rec.individual_spec) ||
                 g_seperator || replace_seperator(rec.recon_account) || g_seperator || replace_seperator(rec.sort_key) ||
                 g_seperator || replace_seperator(rec.head_office) || g_seperator ||
                 replace_seperator(rec.subsidy_indic) || g_seperator || replace_seperator(rec.release_group) ||
                 g_seperator || replace_seperator(rec.minority_indicators) || g_seperator ||
                 replace_seperator(rec.certification_date) || g_seperator || replace_seperator(rec.interest_indic) ||
                 g_seperator || replace_seperator(rec.last_key_date) || g_seperator ||
                 replace_seperator(rec.interest_freq) || g_seperator || replace_seperator(rec.last_interest_run) ||
                 g_seperator || replace_seperator(rec.prev_acct_no) || g_seperator ||
                 replace_seperator(rec.personnel_number) || g_seperator || replace_seperator(rec.activity_code) ||
                 g_seperator || replace_seperator(rec.distr_type) || g_seperator ||
                 replace_seperator(rec.payment_terms) || g_seperator || replace_seperator(rec.tolerance_group1) ||
                 g_seperator || replace_seperator(rec.cr_memo_terms) || g_seperator ||
                 replace_seperator(rec.chk_double_inv) || g_seperator || replace_seperator(rec.payment_methods) ||
                 g_seperator || replace_seperator(rec.payment_block) || g_seperator ||
                 replace_seperator(rec.alternat_payee) || g_seperator || replace_seperator(rec.house_bank) ||
                 g_seperator || replace_seperator(rec.individual_payment) || g_seperator ||
                 replace_seperator(rec.group_key) || g_seperator || replace_seperator(rec.clearing_with_customer) ||
                 g_seperator || replace_seperator(rec.b_exch_limit) || g_seperator || replace_seperator(rec.edi) ||
                 g_seperator || replace_seperator(rec.pmtadv_xml) || g_seperator ||
                 replace_seperator(rec.tolerance_group2) || g_seperator || replace_seperator(rec.prepayment) ||
                 g_seperator || replace_seperator(rec.local_process) || g_seperator ||
                 replace_seperator(rec.acct_statement) || g_seperator || replace_seperator(rec.acctg_clerk) ||
                 g_seperator || replace_seperator(rec.acc_with_vendor) || g_seperator ||
                 replace_seperator(rec.clerk_at_vendor) || g_seperator || replace_seperator(rec.act_clk_tel_no) ||
                 g_seperator || replace_seperator(rec.clerk_fax) || g_seperator || replace_seperator(rec.clrk_internet) ||
                 g_seperator || replace_seperator(rec.account_memo) || g_seperator ||
                 replace_seperator(rec.withholdingtax4) || g_seperator || replace_seperator(rec.withholdingtax5) ||
                 g_seperator || replace_seperator(rec.withholding_tax_code) || g_seperator ||
                 replace_seperator(rec.subject_to_withholding_tax) || g_seperator ||
                 replace_seperator(rec.recipient_type) || g_seperator || replace_seperator(rec.w_tax_id) || g_seperator ||
                 replace_seperator(rec.excemption_number) || g_seperator || replace_seperator(rec.excemption) ||
                 g_seperator || replace_seperator(rec.excempt_reason) || g_seperator ||
                 replace_seperator(rec.excempt_from) || g_seperator || replace_seperator(rec.excempt_to) || g_seperator ||
                 replace_seperator(rec.g_g_code_output) || g_seperator || replace_seperator(rec.authorization);
        out_msg(l_msg);
        -- utl_file.put_line(l_fhandler, l_msg);
      END LOOP;
      --  utl_file.fclose(l_fhandler);
    END IF;
  END generate_hfg_file;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_g_g_code
  *   DESCRIPTION:
  *              get_g_g_code
  *   HISTORY:
  *     1.00 2016-12-06 liudan
  *
  * =============================================*/
  FUNCTION get_g_g_code(p_party_id IN NUMBER) RETURN VARCHAR2 IS
    l_g_g_code VARCHAR2(50);
  BEGIN
    SELECT org.duns_number_c
      INTO l_g_g_code
      FROM apps.hz_organization_profiles org
     WHERE org.organization_profile_id = (SELECT MAX(v.organization_profile_id)
                                            FROM apps.hz_organization_profiles v
                                           WHERE v.party_id = p_party_id);

    RETURN l_g_g_code;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_bank_info
  *   DESCRIPTION:
  *              get_bank_info
  *   ARGUMENT:
  *
  *   RETURN:
  *
  *   HISTORY:
  *     1.00 2012-05-29 colin.chen
  *
  * =============================================*/
  PROCEDURE get_bank_info(p_party_id    IN NUMBER,
                          x_country     OUT VARCHAR2,
                          x_bank_key    OUT VARCHAR2,
                          x_bank_number OUT VARCHAR2) IS
    CURSOR cur IS
      SELECT ft.nls_territory,
             cbb.bank_name || cbb.bank_branch_name bank_key,
             cbb.bank_number
        FROM iby_ext_bank_accounts ieb,
             iby_account_owners    iao,
             ce_bank_branches_v    cbb,
             fnd_territories       ft
       WHERE ieb.ext_bank_account_id = iao.ext_bank_account_id
         AND ieb.branch_id = cbb.branch_party_id(+)
         AND ieb.country_code = ft.territory_code
         AND iao.account_owner_party_id = p_party_id;
    l_rec cur%ROWTYPE;
  BEGIN
    OPEN cur;
    FETCH cur
      INTO l_rec;
    CLOSE cur;

    x_country     := l_rec.nls_territory;
    x_bank_key    := l_rec.bank_key;
    x_bank_number := l_rec.bank_number;
  END get_bank_info;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_file_name
  *   DESCRIPTION:
  *              get_ou_name
  *   ARGUMENT:  p_org_id
  *
  *   RETURN:
  *              varchar2
  *   HISTORY:
  *     1.00 2012-08-04 Jia
  *
  * =============================================*/
  FUNCTION get_file_name RETURN VARCHAR2 IS
    l_date      VARCHAR2(8) := to_char(SYSDATE, 'YYYYMMDD');
    l_execution VARCHAR2(1) := '1';
    -- 2.10  2015-09-07 Jinlong.Pan    Update Begin
    --l_error_handling   VARCHAR2(1) := 'A'; --'B';
    l_error_handling VARCHAR2(1) := 'B';
    -- 2.10  2015-09-07 Jinlong.Pan    Update End
    l_function_id      VARCHAR2(2) := '01';
    l_variant_id       VARCHAR2(2) := '01';
    l_language         VARCHAR2(2) := 'EN';
    l_arbitrary_string VARCHAR2(8) := 'Vend';
    l_extension        VARCHAR2(4) := '.TXT';
    l_sequence_id      NUMBER;
    l_cnt              NUMBER;
  BEGIN
    BEGIN
      SELECT nvl(MAX(to_number(substr(interface_file_name, 21, 4))), 0) --COUNT(1)
        INTO l_sequence_id
        FROM xxap_vendor_to_hfg_int
       WHERE substr(interface_file_name, 1, 8) = l_date;
    EXCEPTION
      WHEN OTHERS THEN
        l_sequence_id := 0;
    END;
    l_sequence_id := l_sequence_id + 1;
    /*    IF l_cnt = 0 THEN
      EXECUTE IMMEDIATE 'drop sequence xxar.xxar_vendor_to_hfg_day_s';
      EXECUTE IMMEDIATE 'create sequence xxar.xxar_vendor_to_hfg_day_s start with 1 nocache';
    END IF;
    l_sequence_id := xxar_vendor_to_hfg_day_s.nextval;*/

    /* RETURN l_date || substr(lpad(l_variant_id, 3, '0'), 1, 1) || l_error_handling || l_function_id || substr(lpad(l_variant_id,
         3,
         '0'),
    2,
    2) || l_language || l_arbitrary_string || l_extension;*/
    RETURN l_date || l_execution || l_error_handling || l_function_id || l_variant_id || l_language || l_arbitrary_string || substr(lpad(l_sequence_id,
                                                                                                                                         4,
                                                                                                                                         '0'),
                                                                                                                                    1,
                                                                                                                                    4) || '.TXT';
  END get_file_name;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  set_miss_rec
  *   DESCRIPTION:
  *              get_ou_name
  *   ARGUMENT:  p_org_id
  *
  *   RETURN:
  *              varchar2
  *   HISTORY:
  *     1.00 2012-08-04 Jia
  *
  * =============================================*/
  PROCEDURE set_miss_rec IS
  BEGIN
    g_miss_rec.vendor_number              := g_blank_char;
    g_miss_rec.company_code               := g_blank_char;
    g_miss_rec.account_assgnt_group       := g_blank_char;
    g_miss_rec.title                      := g_blank_char;
    g_miss_rec.name1                      := g_blank_char;
    g_miss_rec.name2                      := g_blank_char;
    g_miss_rec.name3                      := g_blank_char;
    g_miss_rec.name4                      := g_blank_char;
    g_miss_rec.search_term1               := g_blank_char;
    g_miss_rec.street2                    := g_blank_char;
    g_miss_rec.street3                    := g_blank_char;
    g_miss_rec.street                     := g_blank_char; --2.00 add
    g_miss_rec.house_number               := g_blank_char;
    g_miss_rec.supplement                 := g_blank_char; --2.00 add
    g_miss_rec.street4                    := g_blank_char;
    g_miss_rec.street5                    := g_blank_char;
    g_miss_rec.district                   := g_blank_char; --2.00 add
    g_miss_rec.different_city             := g_blank_char; --2.00 add
    g_miss_rec.city                       := g_blank_char;
    g_miss_rec.postal_code                := g_blank_char;
    g_miss_rec.country                    := g_blank_char;
    g_miss_rec.region                     := g_blank_char;
    g_miss_rec.time_zone                  := g_blank_char;
    g_miss_rec.jurisdict_code             := g_blank_char; --2.00 add
    g_miss_rec.po_box                     := g_blank_char; --2.00 add
    g_miss_rec.po_box_without_number      := g_blank_char; --2.00 add
    g_miss_rec.delivery_serv              := g_blank_char;
    g_miss_rec.delivery_service_number    := g_blank_char; --2.00 add
    g_miss_rec.po_box_lobby               := g_blank_char; --2.00 add
    g_miss_rec.postal_code1               := g_blank_char;
    g_miss_rec.other_city                 := g_blank_char; --2.00 add
    g_miss_rec.other_country              := g_blank_char; --2.00 add
    g_miss_rec.other_region               := g_blank_char; --2.00 add
    g_miss_rec.company_postal_code        := g_blank_char;
    g_miss_rec.language                   := g_blank_char;
    g_miss_rec.telephone                  := g_blank_char;
    g_miss_rec.extension                  := g_blank_char;
    g_miss_rec.mobile_telephone           := g_blank_char;
    g_miss_rec.fax                        := g_blank_char;
    g_miss_rec.fax_extension              := g_blank_char;
    g_miss_rec.e_mail                     := g_blank_char;
    g_miss_rec.std_comm_method            := g_blank_char;
    g_miss_rec.data_line                  := g_blank_char; --2.00 add
    g_miss_rec.telebox                    := g_blank_char; --2.00 add
    g_miss_rec.comments                   := g_blank_char;
    g_miss_rec.customer                   := g_blank_char;
    g_miss_rec.corporate_group            := g_blank_char; --2.00 add
    g_miss_rec.tax_number1                := g_blank_char;
    g_miss_rec.tax_number2                := g_blank_char;
    g_miss_rec.tax_number3                := g_blank_char;
    g_miss_rec.tax_number_4               := g_blank_char;
    g_miss_rec.fiscal_address             := g_blank_char;
    g_miss_rec.vat_reg_no                 := g_blank_char; --2.00 add
    g_miss_rec.representative             := g_blank_char;
    g_miss_rec.business_type              := g_blank_char;
    g_miss_rec.tax_office                 := g_blank_char;
    g_miss_rec.industry_type              := g_blank_char;
    g_miss_rec.tax_number                 := g_blank_char;
    g_miss_rec.tax_number_type            := g_blank_char;
    g_miss_rec.tax_type                   := g_blank_char;
    g_miss_rec.tax_base                   := g_blank_char;
    g_miss_rec.soc_ins_code               := g_blank_char; --2.00 add
    g_miss_rec.equalization_tax           := g_blank_char;
    g_miss_rec.sole_proprietr             := g_blank_char; --2.00 add
    g_miss_rec.liable                     := g_blank_char;
    g_miss_rec.tax_split                  := g_blank_char;
    g_miss_rec.social_insurance1          := g_blank_char;
    g_miss_rec.location_no_1              := g_blank_char; --2.00 add
    g_miss_rec.location_no_2              := g_blank_char; --2.00 add
    g_miss_rec.check_digit                := g_blank_char; --2.00 add
    g_miss_rec.cred_info_no               := g_blank_char;
    g_miss_rec.last_ext_review            := g_blank_char; --2.00 add
    g_miss_rec.industry                   := g_blank_char;
    g_miss_rec.train_station              := g_blank_char;
    g_miss_rec.scac                       := g_blank_char; --2.00 add
    g_miss_rec.car_freight_grp            := g_blank_char; --2.00 add
    g_miss_rec.serv_agnt_proc_grp         := g_blank_char; --2.00 add
    g_miss_rec.stat_gr_tra_ser            := g_blank_char; --2.00 add
    g_miss_rec.pod_relevant               := g_blank_char; --2.00 add
    g_miss_rec.actual_qm_sys              := g_blank_char; --2.00 add
    g_miss_rec.qm_system_to               := g_blank_char; --2.00 add
    g_miss_rec.external_manufacturer      := g_blank_char;
    g_miss_rec.date_of_birth              := g_blank_char; --2.00 add
    g_miss_rec.place_of_birth             := g_blank_char; --2.00 add
    g_miss_rec.sex                        := g_blank_char; --2.00 add
    g_miss_rec.profession                 := g_blank_char;
    g_miss_rec.bank_country_key           := g_blank_char; --2.00 add
    g_miss_rec.bank_key                   := g_blank_char;
    g_miss_rec.bank_account               := g_blank_char;
    g_miss_rec.acct_holder                := g_blank_char;
    g_miss_rec.ck                         := g_blank_char;
    g_miss_rec.iban                       := g_blank_char; --2.00 add
    g_miss_rec.valid_from                 := g_blank_char; --2.00 add
    g_miss_rec.partner_bank_type          := g_blank_char; --2.00 add
    g_miss_rec.reference_specifications   := g_blank_char; --2.00 add
    g_miss_rec.collection_authorization   := g_blank_char; --2.00 add
    g_miss_rec.alternative_payee          := g_blank_char;
    g_miss_rec.dme_indicator              := g_blank_char; --2.00 add
    g_miss_rec.instruction_key            := g_blank_char;
    g_miss_rec.isr_number                 := g_blank_char; --2.00 add
    g_miss_rec.individual_spec            := g_blank_char;
    g_miss_rec.recon_account              := g_blank_char;
    g_miss_rec.sort_key                   := g_blank_char;
    g_miss_rec.head_office                := g_blank_char; --2.00 add
    g_miss_rec.subsidy_indic              := g_blank_char; --2.00 add
    g_miss_rec.release_group              := g_blank_char; --2.00 add
    g_miss_rec.minority_indicators        := g_blank_char;
    g_miss_rec.certification_date         := g_blank_char;
    g_miss_rec.interest_indic             := g_blank_char; --2.00 add
    g_miss_rec.last_key_date              := g_blank_char; --2.00 add
    g_miss_rec.interest_freq              := g_blank_char; --2.00 add
    g_miss_rec.last_interest_run          := g_blank_char; --2.00 add
    g_miss_rec.prev_acct_no               := g_blank_char;
    g_miss_rec.personnel_number           := g_blank_char; --2.00 add
    g_miss_rec.activity_code              := g_blank_char; --2.00 add
    g_miss_rec.distr_type                 := g_blank_char; --2.00 add
    g_miss_rec.payment_terms              := g_blank_char;
    g_miss_rec.tolerance_group1           := g_blank_char;
    g_miss_rec.cr_memo_terms              := g_blank_char; --2.00 add
    g_miss_rec.chk_double_inv             := g_blank_char; --2.00 add
    g_miss_rec.payment_methods            := g_blank_char;
    g_miss_rec.payment_block              := g_blank_char;
    g_miss_rec.alternat_payee             := g_blank_char; --2.00 add
    g_miss_rec.house_bank                 := g_blank_char;
    g_miss_rec.individual_payment         := g_blank_char; --2.00 add
    g_miss_rec.group_key                  := g_blank_char;
    g_miss_rec.clearing_with_customer     := g_blank_char; --2.00 add
    g_miss_rec.b_exch_limit               := g_blank_char; --2.00 add
    g_miss_rec.edi                        := g_blank_char; --2.00 add
    g_miss_rec.pmtadv_xml                 := g_blank_char; --2.00 add
    g_miss_rec.tolerance_group2           := g_blank_char;
    g_miss_rec.prepayment                 := g_blank_char; --2.00 add
    g_miss_rec.local_process              := g_blank_char; --2.00 add
    g_miss_rec.acct_statement             := g_blank_char; --2.00 add
    g_miss_rec.acctg_clerk                := g_blank_char; --2.00 add
    g_miss_rec.acc_with_vendor            := g_blank_char;
    g_miss_rec.clerk_at_vendor            := g_blank_char;
    g_miss_rec.act_clk_tel_no             := g_blank_char; --2.00 add
    g_miss_rec.clerk_fax                  := g_blank_char; --2.00 add
    g_miss_rec.clrk_internet              := g_blank_char; --2.00 add
    g_miss_rec.account_memo               := g_blank_char; --2.00 add
    g_miss_rec.withholdingtax4            := g_blank_char;
    g_miss_rec.withholdingtax5            := g_blank_char;
    g_miss_rec.withholding_tax_code       := g_blank_char; --2.00 add
    g_miss_rec.subject_to_withholding_tax := g_blank_char; --2.00 add
    g_miss_rec.recipient_type             := g_blank_char;
    g_miss_rec.w_tax_id                   := g_blank_char; --2.00 add
    g_miss_rec.excemption_number          := g_blank_char; --2.00 add
    g_miss_rec.excemption                 := g_blank_char; --2.00 add
    g_miss_rec.excempt_reason             := g_blank_char; --2.00 add
    g_miss_rec.excempt_from               := g_blank_char; --2.00 add
    g_miss_rec.excempt_to                 := g_blank_char; --2.00 add
    g_miss_rec.g_g_code                   := g_blank_char; --2.00 add
    g_miss_rec.authorization              := g_blank_char; --2.00 add

    --
    -- 3.00  2015-11-21 Jinlong.Pan    Update Begin
    /*g_miss_rec.deletion_flag                 := g_blank_char;
    g_miss_rec.co_cde_deletion_flag          := g_blank_char;
    g_miss_rec.posting_block                 := g_blank_char;
    g_miss_rec.co_code_post_block            := g_blank_char;
    g_miss_rec.central_sales_tax_number      := g_blank_char;
    g_miss_rec.local_sales_tax_number        := g_blank_char;
    g_miss_rec.service_tax_registration_num  := g_blank_char;
    g_miss_rec.ecc_number                    := g_blank_char;
    g_miss_rec.excise_registration_number    := g_blank_char;
    g_miss_rec.excise_range                  := g_blank_char;
    g_miss_rec.excise_division               := g_blank_char;
    g_miss_rec.excise_commissionerate        := g_blank_char;
    g_miss_rec.type_of_vendor                := g_blank_char;
    g_miss_rec.excise_tax_indicator_for_vndr := g_blank_char;
    g_miss_rec.ssi_status                    := g_blank_char;
    g_miss_rec.cenvat_scheme_participant     := g_blank_char;
    g_miss_rec.permanent_account_number      := g_blank_char;
    g_miss_rec.pan_reference_number          := g_blank_char;
    g_miss_rec.branch_code                   := g_blank_char;
    g_miss_rec.default_branch                := g_blank_char;
    g_miss_rec.branch_description            := g_blank_char;*/
    -- 3.00  2015-11-21 Jinlong.Pan    Update End

    /*    g_miss_rec.search_term2           := g_blank_char;

    g_miss_rec.street_house_number    := g_blank_char;

    g_miss_rec.authorization1         := g_blank_char;
    g_miss_rec.trading_partner        := g_blank_char;



    g_miss_rec.natural_person         := g_blank_char;

    g_miss_rec.social_insurance2      := g_blank_char;
    g_miss_rec.vat                    := g_blank_char;

    g_miss_rec.location_no            := g_blank_char;

    g_miss_rec.last_review            := g_blank_char;

    g_miss_rec.standard_carrier       := g_blank_char;
    g_miss_rec.forwarding_group       := g_blank_char;
    g_miss_rec.service_group          := g_blank_char;
    g_miss_rec.delivery               := g_blank_char;
    g_miss_rec.qm_system              := g_blank_char;
    g_miss_rec.certification          := g_blank_char;

    g_miss_rec.withholding_tax1       := g_blank_char;
    g_miss_rec.withholding_tax2       := g_blank_char;
    g_miss_rec.withholding_tax3       := g_blank_char;

    g_miss_rec.medium_exchange        := g_blank_char;

    g_miss_rec.subscriber_number      := g_blank_char;
    g_miss_rec.country1               := g_blank_char;

    g_miss_rec.bnkt                   := g_blank_char;
    g_miss_rec.reference_details      := g_blank_char;
    g_miss_rec.collectaut             := g_blank_char;
    g_miss_rec.bank_line_item         := g_blank_char;
    g_miss_rec.first_name             := g_blank_char;
    g_miss_rec.name5                  := g_blank_char;
    g_miss_rec.contact_department     := g_blank_char;
    g_miss_rec.contact_function       := g_blank_char;

    g_miss_rec.head_office_account    := g_blank_char;
    g_miss_rec.authorization_group    := g_blank_char;
    g_miss_rec.cash_mgmnt_group       := g_blank_char;
    g_miss_rec.release_approval_group := g_blank_char;

    g_miss_rec.interest_calculation1  := g_blank_char;
    g_miss_rec.interest_calculation2  := g_blank_char;
    g_miss_rec.interest_calculation3  := g_blank_char;
    g_miss_rec.interest_calculation4  := g_blank_char;

    g_miss_rec.billing_entry          := g_blank_char;
    g_miss_rec.probable_time          := g_blank_char;

    g_miss_rec.indicator1             := g_blank_char;
    g_miss_rec.payment_grouping       := g_blank_char;
    g_miss_rec.clearing1              := g_blank_char;
    g_miss_rec.exchange_limit         := g_blank_char;

    g_miss_rec.dunning_procedure      := g_blank_char;
    g_miss_rec.dunning_block          := g_blank_char;
    g_miss_rec.dunning_recipient      := g_blank_char;
    g_miss_rec.dunning_proceedings    := g_blank_char;
    g_miss_rec.last_dunned            := g_blank_char;
    g_miss_rec.dunning_level          := g_blank_char;
    g_miss_rec.dunning_clerk          := g_blank_char;
    g_miss_rec.dunning_notice         := g_blank_char;
    g_miss_rec.indicator2             := g_blank_char;
    g_miss_rec.accounting_clerk1      := g_blank_char;

    g_miss_rec.accounting_clerk2      := g_blank_char;
    g_miss_rec.fax_no                 := g_blank_char;
    g_miss_rec.internet_address       := g_blank_char;
    g_miss_rec.memo                   := g_blank_char;

    g_miss_rec.withholdingtax6        := g_blank_char;
    g_miss_rec.liable_for_vat              := g_blank_char;

    g_miss_rec.withholdingtax7        := g_blank_char;
    g_miss_rec.tax_line_item_no       := g_blank_char;*/
  END set_miss_rec;

  PROCEDURE update_vendor_to_hfg_int(p_vendor_int_rec xxap_vendor_to_hfg_int%ROWTYPE,
                                     p_unique_id      IN NUMBER) IS
  BEGIN

    UPDATE xxap_vendor_to_hfg_int xvhi
       SET xvhi.vendor_number              = p_vendor_int_rec.vendor_number,
           xvhi.company_code               = p_vendor_int_rec.company_code,
           xvhi.account_assgnt_group       = p_vendor_int_rec.account_assgnt_group,
           xvhi.title                      = p_vendor_int_rec.title,
           xvhi.name1                      = p_vendor_int_rec.name1,
           xvhi.name2                      = p_vendor_int_rec.name2,
           xvhi.name3                      = p_vendor_int_rec.name3,
           xvhi.name4                      = p_vendor_int_rec.name4,
           xvhi.search_term1               = p_vendor_int_rec.search_term1,
           xvhi.street2                    = p_vendor_int_rec.street2,
           xvhi.street3                    = p_vendor_int_rec.street3,
           xvhi.street                     = p_vendor_int_rec.street,
           xvhi.house_number               = p_vendor_int_rec.house_number,
           xvhi.supplement                 = p_vendor_int_rec.supplement,
           xvhi.street4                    = p_vendor_int_rec.street4,
           xvhi.street5                    = p_vendor_int_rec.street5,
           xvhi.district                   = p_vendor_int_rec.district,
           xvhi.different_city             = p_vendor_int_rec.different_city,
           xvhi.city                       = p_vendor_int_rec.city,
           xvhi.postal_code                = p_vendor_int_rec.postal_code,
           xvhi.country                    = p_vendor_int_rec.country,
           xvhi.region                     = p_vendor_int_rec.region,
           xvhi.time_zone                  = p_vendor_int_rec.time_zone,
           xvhi.jurisdict_code             = p_vendor_int_rec.jurisdict_code,
           xvhi.po_box                     = p_vendor_int_rec.po_box,
           xvhi.po_box_without_number      = p_vendor_int_rec.po_box_without_number,
           xvhi.delivery_serv              = p_vendor_int_rec.delivery_serv,
           xvhi.delivery_service_number    = p_vendor_int_rec.delivery_service_number,
           xvhi.po_box_lobby               = p_vendor_int_rec.po_box_lobby,
           xvhi.postal_code1               = p_vendor_int_rec.postal_code1,
           xvhi.other_city                 = p_vendor_int_rec.other_city,
           xvhi.other_country              = p_vendor_int_rec.other_country,
           xvhi.other_region               = p_vendor_int_rec.other_region,
           xvhi.company_postal_code        = p_vendor_int_rec.company_postal_code,
           xvhi.language                   = p_vendor_int_rec.language,
           xvhi.telephone                  = p_vendor_int_rec.telephone,
           xvhi.extension                  = p_vendor_int_rec.extension,
           xvhi.mobile_telephone           = p_vendor_int_rec.mobile_telephone,
           xvhi.fax                        = p_vendor_int_rec.fax,
           xvhi.fax_extension              = p_vendor_int_rec.fax_extension,
           xvhi.e_mail                     = p_vendor_int_rec.e_mail,
           xvhi.std_comm_method            = p_vendor_int_rec.std_comm_method,
           xvhi.data_line                  = p_vendor_int_rec.data_line,
           xvhi.telebox                    = p_vendor_int_rec.telebox,
           xvhi.comments                   = p_vendor_int_rec.comments,
           xvhi.customer                   = p_vendor_int_rec.customer,
           xvhi.corporate_group            = p_vendor_int_rec.corporate_group,
           xvhi.tax_number1                = p_vendor_int_rec.tax_number1,
           xvhi.tax_number2                = p_vendor_int_rec.tax_number2,
           xvhi.tax_number3                = p_vendor_int_rec.tax_number3,
           xvhi.tax_number_4               = p_vendor_int_rec.tax_number_4,
           xvhi.fiscal_address             = p_vendor_int_rec.fiscal_address,
           xvhi.vat_reg_no                 = p_vendor_int_rec.vat_reg_no,
           xvhi.representative             = p_vendor_int_rec.representative,
           xvhi.business_type              = p_vendor_int_rec.business_type,
           xvhi.tax_office                 = p_vendor_int_rec.tax_office,
           xvhi.industry_type              = p_vendor_int_rec.industry_type,
           xvhi.tax_number                 = p_vendor_int_rec.tax_number,
           xvhi.tax_number_type            = p_vendor_int_rec.tax_number_type,
           xvhi.tax_type                   = p_vendor_int_rec.tax_type,
           xvhi.tax_base                   = p_vendor_int_rec.tax_base,
           xvhi.soc_ins_code               = p_vendor_int_rec.soc_ins_code,
           xvhi.equalization_tax           = p_vendor_int_rec.equalization_tax,
           xvhi.sole_proprietr             = p_vendor_int_rec.sole_proprietr,
           xvhi.liable                     = p_vendor_int_rec.liable,
           xvhi.tax_split                  = p_vendor_int_rec.tax_split,
           xvhi.social_insurance1          = p_vendor_int_rec.social_insurance1,
           xvhi.location_no_1              = p_vendor_int_rec.location_no_1,
           xvhi.location_no_2              = p_vendor_int_rec.location_no_2,
           xvhi.check_digit                = p_vendor_int_rec.check_digit,
           xvhi.cred_info_no               = p_vendor_int_rec.cred_info_no,
           xvhi.last_ext_review            = p_vendor_int_rec.last_ext_review,
           xvhi.industry                   = p_vendor_int_rec.industry,
           xvhi.train_station              = p_vendor_int_rec.train_station,
           xvhi.scac                       = p_vendor_int_rec.scac,
           xvhi.car_freight_grp            = p_vendor_int_rec.car_freight_grp,
           xvhi.serv_agnt_proc_grp         = p_vendor_int_rec.serv_agnt_proc_grp,
           xvhi.stat_gr_tra_ser            = p_vendor_int_rec.stat_gr_tra_ser,
           xvhi.pod_relevant               = p_vendor_int_rec.pod_relevant,
           xvhi.actual_qm_sys              = p_vendor_int_rec.actual_qm_sys,
           xvhi.qm_system_to               = p_vendor_int_rec.qm_system_to,
           xvhi.external_manufacturer      = p_vendor_int_rec.external_manufacturer,
           xvhi.date_of_birth              = p_vendor_int_rec.date_of_birth,
           xvhi.place_of_birth             = p_vendor_int_rec.place_of_birth,
           xvhi.sex                        = p_vendor_int_rec.sex,
           xvhi.profession                 = p_vendor_int_rec.profession,
           xvhi.bank_country_key           = p_vendor_int_rec.bank_country_key,
           xvhi.bank_key                   = p_vendor_int_rec.bank_key,
           xvhi.bank_account               = p_vendor_int_rec.bank_account,
           xvhi.acct_holder                = p_vendor_int_rec.acct_holder,
           xvhi.ck                         = p_vendor_int_rec.ck,
           xvhi.iban                       = p_vendor_int_rec.iban,
           xvhi.valid_from                 = p_vendor_int_rec.valid_from,
           xvhi.partner_bank_type          = p_vendor_int_rec.partner_bank_type,
           xvhi.reference_specifications   = p_vendor_int_rec.reference_specifications,
           xvhi.collection_authorization   = p_vendor_int_rec.collection_authorization,
           xvhi.alternative_payee          = p_vendor_int_rec.alternative_payee,
           xvhi.dme_indicator              = p_vendor_int_rec.dme_indicator,
           xvhi.instruction_key            = p_vendor_int_rec.instruction_key,
           xvhi.isr_number                 = p_vendor_int_rec.isr_number,
           xvhi.individual_spec            = p_vendor_int_rec.individual_spec,
           xvhi.recon_account              = p_vendor_int_rec.recon_account,
           xvhi.sort_key                   = p_vendor_int_rec.sort_key,
           xvhi.head_office                = p_vendor_int_rec.head_office,
           xvhi.subsidy_indic              = p_vendor_int_rec.subsidy_indic,
           xvhi.release_group              = p_vendor_int_rec.release_group,
           xvhi.minority_indicators        = p_vendor_int_rec.minority_indicators,
           xvhi.certification_date         = p_vendor_int_rec.certification_date,
           xvhi.interest_indic             = p_vendor_int_rec.interest_indic,
           xvhi.last_key_date              = p_vendor_int_rec.last_key_date,
           xvhi.interest_freq              = p_vendor_int_rec.interest_freq,
           xvhi.last_interest_run          = p_vendor_int_rec.last_interest_run,
           xvhi.prev_acct_no               = p_vendor_int_rec.prev_acct_no,
           xvhi.personnel_number           = p_vendor_int_rec.personnel_number,
           xvhi.activity_code              = p_vendor_int_rec.activity_code,
           xvhi.distr_type                 = p_vendor_int_rec.distr_type,
           xvhi.payment_terms              = p_vendor_int_rec.payment_terms,
           xvhi.tolerance_group1           = p_vendor_int_rec.tolerance_group1,
           xvhi.cr_memo_terms              = p_vendor_int_rec.cr_memo_terms,
           xvhi.chk_double_inv             = p_vendor_int_rec.chk_double_inv,
           xvhi.payment_methods            = p_vendor_int_rec.payment_methods,
           xvhi.payment_block              = p_vendor_int_rec.payment_block,
           xvhi.alternat_payee             = p_vendor_int_rec.alternat_payee,
           xvhi.house_bank                 = p_vendor_int_rec.house_bank,
           xvhi.individual_payment         = p_vendor_int_rec.individual_payment,
           xvhi.group_key                  = p_vendor_int_rec.group_key,
           xvhi.clearing_with_customer     = p_vendor_int_rec.clearing_with_customer,
           xvhi.b_exch_limit               = p_vendor_int_rec.b_exch_limit,
           xvhi.edi                        = p_vendor_int_rec.edi,
           xvhi.pmtadv_xml                 = p_vendor_int_rec.pmtadv_xml,
           xvhi.tolerance_group2           = p_vendor_int_rec.tolerance_group2,
           xvhi.prepayment                 = p_vendor_int_rec.prepayment,
           xvhi.local_process              = p_vendor_int_rec.local_process,
           xvhi.acct_statement             = p_vendor_int_rec.acct_statement,
           xvhi.acctg_clerk                = p_vendor_int_rec.acctg_clerk,
           xvhi.acc_with_vendor            = p_vendor_int_rec.acc_with_vendor,
           xvhi.clerk_at_vendor            = p_vendor_int_rec.clerk_at_vendor,
           xvhi.act_clk_tel_no             = p_vendor_int_rec.act_clk_tel_no,
           xvhi.clerk_fax                  = p_vendor_int_rec.clerk_fax,
           xvhi.clrk_internet              = p_vendor_int_rec.clrk_internet,
           xvhi.account_memo               = p_vendor_int_rec.account_memo,
           xvhi.withholdingtax4            = p_vendor_int_rec.withholdingtax4,
           xvhi.withholdingtax5            = p_vendor_int_rec.withholdingtax5,
           xvhi.withholding_tax_code       = p_vendor_int_rec.withholding_tax_code,
           xvhi.subject_to_withholding_tax = p_vendor_int_rec.subject_to_withholding_tax,
           xvhi.recipient_type             = p_vendor_int_rec.recipient_type,
           xvhi.w_tax_id                   = p_vendor_int_rec.w_tax_id,
           xvhi.excemption_number          = p_vendor_int_rec.excemption_number,
           xvhi.excemption                 = p_vendor_int_rec.excemption,
           xvhi.excempt_reason             = p_vendor_int_rec.excempt_reason,
           xvhi.excempt_from               = p_vendor_int_rec.excempt_from,
           xvhi.excempt_to                 = p_vendor_int_rec.excempt_to,
           xvhi.g_g_code                   = g_blank_char,
           xvhi.authorization              = p_vendor_int_rec.authorization,
           xvhi.org_id                     = p_vendor_int_rec.org_id,
           xvhi.street_house_number        = p_vendor_int_rec.street_house_number,
           xvhi.creation_date              = p_vendor_int_rec.creation_date,
           xvhi.last_update_date           = p_vendor_int_rec.last_update_date,
           xvhi.created_by                 = p_vendor_int_rec.created_by,
           xvhi.last_updated_by            = p_vendor_int_rec.last_updated_by,
           xvhi.last_update_login          = p_vendor_int_rec.last_update_login,
           xvhi.program_id                 = p_vendor_int_rec.program_id,
           xvhi.request_id                 = p_vendor_int_rec.request_id,
           xvhi.program_application_id     = p_vendor_int_rec.program_application_id,
           xvhi.new_vendor_flag            = p_vendor_int_rec.new_vendor_flag,
           xvhi.vendor_last_update_date    = p_vendor_int_rec.vendor_last_update_date,
           xvhi.interface_file_name        = p_vendor_int_rec.interface_file_name,
           xvhi.rerun_flag                 = p_vendor_int_rec.rerun_flag,
           xvhi.vendor_id                  = p_vendor_int_rec.vendor_id,
           xvhi.ledger_name                = p_vendor_int_rec.ledger_name,
           xvhi.group_id                   = p_vendor_int_rec.group_id,
           xvhi.process_status             = p_vendor_int_rec.process_status,
           xvhi.object_version_number      = p_vendor_int_rec.object_version_number,
           xvhi.bank_line_item             = p_vendor_int_rec.bank_line_item,
           xvhi.country1                   = p_vendor_int_rec.country1
     WHERE xvhi.unique_id = p_unique_id;
  END;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  validate_required
  *   DESCRIPTION:
  *              validate_required
  *   ARGUMENT:
  *
  *   RETURN:
  *
  *   HISTORY:
  *     1.00 2012-06-12 colin.chen
  *
  * =============================================*/
  PROCEDURE validate_required(p_int_rec IN OUT NOCOPY xxap_vendor_to_hfg_int%ROWTYPE) IS
  BEGIN

    IF p_int_rec.vendor_number = g_blank_char THEN
      p_int_rec.process_status  := fnd_api.g_ret_sts_error;
      p_int_rec.process_message := substr(p_int_rec.process_message || 'Vendor Number field is required. ',
                                          1,
                                          g_max_length);
    END IF;
    IF p_int_rec.company_code = g_blank_char THEN
      p_int_rec.process_status  := fnd_api.g_ret_sts_error;
      p_int_rec.process_message := substr(p_int_rec.process_message || 'Company Code field is required. ',
                                          1,
                                          g_max_length);
    END IF;
    IF p_int_rec.account_assgnt_group = g_blank_char THEN
      p_int_rec.process_status  := fnd_api.g_ret_sts_error;
      p_int_rec.process_message := substr(p_int_rec.process_message || 'Account Group field is required. ',
                                          1,
                                          g_max_length);
    END IF;

    IF p_int_rec.name1 = g_blank_char THEN
      p_int_rec.process_status  := fnd_api.g_ret_sts_error;
      p_int_rec.process_message := substr(p_int_rec.process_message || 'Name1 field is required. ', 1, g_max_length);
    END IF;

    /*  IF p_int_rec.city = g_blank_char THEN
      p_int_rec.process_status  := fnd_api.g_ret_sts_error;
      p_int_rec.process_message := substr(p_int_rec.process_message || 'City field is required. '
                                         ,1
                                         ,g_max_length);
    END IF;*/

    IF p_int_rec.country = g_blank_char THEN
      p_int_rec.process_status  := fnd_api.g_ret_sts_error;
      p_int_rec.process_message := substr(p_int_rec.process_message || 'Country field is required. ', 1, g_max_length);
    END IF;
    IF p_int_rec.language = g_blank_char THEN
      p_int_rec.process_status  := fnd_api.g_ret_sts_error;
      p_int_rec.process_message := substr(p_int_rec.process_message || 'Language field is required. ', 1, g_max_length);
    END IF;

    IF p_int_rec.recon_account = g_blank_char THEN
      p_int_rec.process_status  := fnd_api.g_ret_sts_error;
      p_int_rec.process_message := substr(p_int_rec.process_message || 'Recon.account field is required. ',
                                          1,
                                          g_max_length);
    END IF;
  END validate_required;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  hfg_process_request
  *   DESCRIPTION:
  *              hfg_process_request
  *   ARGUMENT:  p_group_id
  *              p_interface_date
  *   RETURN:
  *
  *   HISTORY:
  *     1.00 2012-05-24 colin.chen
  *
  * =============================================*/
  PROCEDURE hfg_process_request(p_group_id   IN NUMBER,
                                p_date_from  IN DATE,
                                p_date_to    IN DATE,
                                p_ledger     IN VARCHAR2,
                                p_rerun_flag IN VARCHAR2,
                                x_ret_status OUT VARCHAR2,
                                x_msg_count  OUT NUMBER,
                                x_msg_data   OUT VARCHAR2) IS
    CURSOR cur_h IS
      SELECT sup.vendor_id,
             sup.segment1,
             sup.vendor_name,
             aps.org_id,
             -- 2.00  2015-04-17 11:27:00 jinlong.pan Add
             gl.name ledger_name,
             -- 2.00  2015-04-17 11:27:00 jinlong.pan Add
             decode(upper(gl.name), 'SHE LEDGER', sup.attribute3, NULL) attribute3,
             sup.attribute7,
             sup.attribute8,
             sup.attribute6,
             sup.attribute9,
             hp.duns_number_c,
             sup.vat_registration_num,
             decode(sup.organization_type_lookup_code,
                    'INDIVIDUAL',
                    sup.individual_1099,
                    'FOREIGN INDIVIDUAL',
                    sup.individual_1099,
                    hp.jgzz_fiscal_code) taxpayer_id,
             ieb.country_code,
             -- ,cbb.bank_name || cbb.bank_branch_name bank_key--2.00 del
             cbb.bank_number,
             greatest(sup.last_update_date,
                      aps.last_update_date,
                      hp.last_update_date,
                      nvl(ieb.last_update_date, sup.last_update_date)) vendor_last_update_date,
             --update by shengxiang.fan 2015-06-19  start
             (SELECT MAX(unique_id)
              --update by shengxiang.fan 2015-06-19 end
                FROM xxap_vendor_to_hfg_int xcth
               WHERE xcth.vendor_id = sup.vendor_id
                 AND xcth.org_id = aps.org_id) unique_id,
             aps.vendor_site_id,
             --,ieb.check_digits
             -- 3.00  2015-11-21 Jinlong.Pan    Update Begin
             sup.attribute10 branch_code,
             sup.attribute11 branch_number,
             sup.attribute15,
             -- 3.00  2015-11-21 Jinlong.Pan    Update End
             hp.party_id --add by liudan 2016/12/06
        FROM ap_suppliers          sup,
             ap_supplier_sites_all aps,
             hr_operating_units    hou,
             gl_ledgers            gl,
             hz_parties            hp,
             iby_ext_bank_accounts ieb,
             iby_account_owners    iao,
             ce_bank_branches_v    cbb
       WHERE sup.vendor_id = aps.vendor_id
         AND sup.party_id = hp.party_id
         AND aps.org_id = hou.organization_id
         AND hou.set_of_books_id = gl.ledger_id
         AND gl.name = p_ledger
         AND iao.ext_bank_account_id = ieb.ext_bank_account_id(+)
         AND ieb.branch_id = cbb.branch_party_id(+) --2.00 del
         AND hp.party_id = iao.account_owner_party_id(+)
            --AND nvl(substr(sup.segment1, 3, 1), '*') <> 'B'
         AND sup.enabled_flag = 'Y'
         AND SYSDATE BETWEEN nvl(sup.start_date_active, SYSDATE - 1) AND nvl(sup.end_date_active, SYSDATE + 1)
            --AND sup.vendor_id = 71002
            /*AND (sup.last_update_date between p_date_from and p_date_to OR
            aps.last_update_date between p_date_from and p_date_to OR
            hp.last_update_date between p_date_from and p_date_to OR
            nvl(ieb.last_update_date, sup.last_update_date) between
            p_date_from and p_date_to)*/
         AND greatest(sup.last_update_date,
                      aps.last_update_date,
                      hp.last_update_date,
                      nvl(ieb.last_update_date, sup.last_update_date)) BETWEEN p_date_from AND p_date_to
         AND (aps.vendor_site_id, aps.org_id) IN (SELECT MIN(apsi.vendor_site_id),
                                                         org_id
                                                    FROM ap_supplier_sites_all apsi
                                                   WHERE apsi.vendor_id = sup.vendor_id
                                                     AND nvl(apsi.inactive_date, SYSDATE) >= SYSDATE
                                                   GROUP BY apsi.vendor_id,
                                                            apsi.org_id);

    CURSOR cur_site(p_vendor_id      IN NUMBER,
                    p_vendor_site_id IN NUMBER,
                    p_org_id         IN NUMBER) IS
      SELECT aps.vendor_site_code,
             xhs.company_code,
             aps.zip,
             aps.city,
             aps.address_line1,
             aps.address_line2,
             aps.address_line3,
             aps.country,
             decode(aps.area_code, '', '', aps.area_code || '-') area_code,
             aps.phone,
             aps.telex,
             decode(aps.fax_area_code, '', '', aps.fax_area_code || '-') fax_area_code,
             aps.fax,
             gcc.segment3,
             decode(upper(gl.name), 'SHE LEDGER', 'TH', 'HET LEDGER', 'TH', NULL) wht4,
             decode(upper(gl.name), 'SHE LEDGER', '11', 'HET LEDGER', '11', NULL) wht5,
             decode(upper(gl.name), 'SHE LEDGER', 'X', 'HET LEDGER', 'X', NULL) liable,
             decode(upper(gl.name), 'SHE LEDGER', '1', 'HET LEDGER', '1', NULL) tax_line_item_no,
             aps.email_address,
             gl.name ledger_name
        FROM ap_supplier_sites_all   aps,
             hr_operating_units      hou,
             xxgl_hfs_system_options xhs,
             gl_ledgers              gl,
             gl_code_combinations    gcc
       WHERE aps.vendor_id = p_vendor_id
         AND aps.org_id = p_org_id
         AND aps.vendor_site_id = p_vendor_site_id
         AND hou.organization_id = aps.org_id
         AND xhs.ledger_id = hou.set_of_books_id
         AND xhs.ledger_id = gl.ledger_id
         AND gl.name = p_ledger
         AND nvl(xhs.inactive_date, SYSDATE) >= SYSDATE
         AND nvl(aps.inactive_date, SYSDATE) >= SYSDATE
         AND aps.accts_pay_code_combination_id = gcc.code_combination_id(+)
       ORDER BY aps.vendor_site_id;
    l_site_rec cur_site%ROWTYPE;

    TYPE tbl_vendor_int IS TABLE OF xxap_vendor_to_hfg_int%ROWTYPE INDEX BY PLS_INTEGER;
    l_vendor_int_rec xxap_vendor_to_hfg_int%ROWTYPE; --row record
    l_vendor_int_tbl tbl_vendor_int; --table record
    l_count          NUMBER;
    l_error_count    NUMBER;
    l_bank_line_no   NUMBER := 0;
    l_pre_vendor_id  NUMBER;
    l_file_name      VARCHAR2(200);
    l_cnt            NUMBER;
    l_recipient_type VARCHAR2(6); -- add by huangyan 2015-01-13
    l_ou_name        VARCHAR2(20); --add by liudan 2016/12/06
  BEGIN
    x_ret_status  := fnd_api.g_ret_sts_success;
    l_count       := 0;
    l_error_count := 0;
    l_vendor_int_tbl.delete;
    -- set_miss_rec;
    IF p_rerun_flag = 'N' THEN
      FOR rec IN cur_h
      LOOP
        l_ou_name := get_ou_name(rec.org_id); --add by liudan 2016/12/06
        l_count   := l_count + 1;
        IF rec.unique_id IS NULL THEN
          --create
          g_blank_char := NULL;
        ELSE
          --update
          g_blank_char := '#';
        END IF;
        set_miss_rec;
        l_vendor_int_rec := g_miss_rec;

        IF l_file_name IS NULL THEN
          l_file_name := get_file_name; --2.00 add
        ELSE
          NULL;
        END IF;

        /*        SELECT xxap_vendor_to_hfg_int_s.nextval
        INTO l_vendor_int_rec.unique_id
        FROM dual;*/

        OPEN cur_site(rec.vendor_id, rec.vendor_site_id, rec.org_id);
        FETCH cur_site
          INTO l_site_rec;
        CLOSE cur_site;

        --full fix record
        l_vendor_int_rec.org_id := rec.org_id;
        IF substr(rec.segment1, 3, 1) = 'E' THEN
          l_vendor_int_rec.account_assgnt_group := substr(rec.segment1, 1, 3);
          l_vendor_int_rec.authorization        := substr(l_site_rec.company_code, 1, 4);
        ELSE
          l_vendor_int_rec.account_assgnt_group := substr(rec.segment1, 1, 2) || 'C'; -- 2.00 change
        END IF;
        l_vendor_int_rec.vendor_number := substr(rec.segment1, 1, 10);
        l_vendor_int_rec.company_code  := substr(l_site_rec.company_code, 1, 4);
        --update by liudan 2016/12/06 begin
        IF l_ou_name = 'HET_OU' THEN
          IF substr(rec.vendor_name, 1, 1) = '.' THEN
            l_vendor_int_rec.name1 := substr(rec.vendor_name, 2, 35);
          ELSE
            l_vendor_int_rec.name1 := substr(rec.vendor_name, 1, 35);
          END IF;
        ELSE
          l_vendor_int_rec.name1 := substr(rec.vendor_name, 1, 35);
        END IF;
        -- l_vendor_int_rec.name1        := substr(rec.vendor_name, 1, 35);
        --end update by liudan 2016/12/06

        l_vendor_int_rec.name2        := nvl(substr(rec.vendor_name, 36, 35), g_blank_char);
        l_vendor_int_rec.search_term1 := nvl(substr(rec.attribute6, 1, 10), l_vendor_int_rec.search_term1);
        l_vendor_int_rec.street       := nvl(substr(l_site_rec.address_line1, 1, 35), g_blank_char);
        l_vendor_int_rec.street4      := nvl(substr(l_site_rec.address_line2, 1, 35), g_blank_char);
        l_vendor_int_rec.street5      := nvl(substr(l_site_rec.address_line3, 1, 35), g_blank_char);
        l_vendor_int_rec.city         := nvl(substr(l_site_rec.city, 1, 35), l_vendor_int_rec.city);
        l_vendor_int_rec.postal_code  := nvl(substr(l_site_rec.zip, 1, 10), l_vendor_int_rec.postal_code);
        l_vendor_int_rec.country      := nvl(substr(l_site_rec.country, 1, 3), l_vendor_int_rec.country);
        /*        l_vendor_int_rec.street_house_number := nvl(substr(l_site_rec.address_line1,
               1,
               35),
        l_vendor_int_rec.street_house_number);*/
        SELECT decode(p_ledger,
                      'SHE Ledger',
                      'EN',
                      'HEA Ledger',
                      'EN',
                      'HET Ledger',
                      'EN', /*add by liudan 2016/12/06*/
                      g_blank_char)
          INTO l_vendor_int_rec.language
          FROM dual; --2.00 add

        l_vendor_int_rec.telephone        := nvl(substr(l_site_rec.area_code || l_site_rec.phone, 1, 30),
                                                 l_vendor_int_rec.telephone);
        l_vendor_int_rec.mobile_telephone := nvl(substr(l_site_rec.telex, 1, 30), l_vendor_int_rec.mobile_telephone);
        l_vendor_int_rec.fax              := nvl(substr(l_site_rec.fax_area_code || l_site_rec.fax, 1, 30),
                                                 l_vendor_int_rec.fax);
        l_vendor_int_rec.e_mail           := nvl(substr(l_site_rec.email_address, 1, 241), l_vendor_int_rec.e_mail);
        /*IF rec.attribute3 = '53' THEN
          l_vendor_int_rec.tax_number1 := nvl(substr(rec.taxpayer_id, 1, 16),
                                              l_vendor_int_rec.tax_number1);
        ELSIF rec.attribute3 = '03' THEN
          l_vendor_int_rec.tax_number2 := nvl(substr(rec.vat_registration_num,
                                                     1,
                                                     16),
                                              l_vendor_int_rec.tax_number2);
        END IF;*/

        -- modify by zhaoshi.chu  2017-01-20 begin
        /*    IF upper(rec.ledger_name) = 'HET LEDGER' THEN
           l_vendor_int_rec.tax_number1 := NVL(l_vendor_int_rec.tax_number1,NULL);
         ELSE
             l_vendor_int_rec.tax_number1 := nvl(rec.duns_number_c,
                                        l_vendor_int_rec.tax_number1);
        END IF;*/
        -- modiy by zhaoshi.chu  2017-01-20 end

        l_vendor_int_rec.tax_number1 := nvl(rec.duns_number_c, l_vendor_int_rec.tax_number1);
        l_vendor_int_rec.tax_number2 := nvl(rec.taxpayer_id, l_vendor_int_rec.tax_number2);
        l_vendor_int_rec.tax_number3 := nvl(rec.vat_registration_num, l_vendor_int_rec.tax_number3);
        -- update by huangyan 2015-01-12
        --l_vendor_int_rec.subject_to_withholding_tax := l_site_rec.liable;
        IF l_vendor_int_rec.account_assgnt_group = 'FBE' THEN
          l_vendor_int_rec.subject_to_withholding_tax := NULL;
        ELSIF l_vendor_int_rec.account_assgnt_group = 'GSE' OR l_vendor_int_rec.account_assgnt_group = 'GTE' THEN
          l_vendor_int_rec.subject_to_withholding_tax := 'X' /*l_site_rec.liable*/
           ; --update by huangyan 2015-04-16
        ELSE
          l_vendor_int_rec.subject_to_withholding_tax := l_site_rec.liable;
        END IF;
        -- end update by huangyan 2015-01-12
        /*IF upper(l_site_rec.ledger_name) = 'HEA LEDGER' THEN
          l_vendor_int_rec.acct_holder := nvl(substr(rec.vendor_name, 1, 60),
                                              l_vendor_int_rec.acct_holder);
        END IF;*/
        l_vendor_int_rec.recon_account   := nvl(substr(l_site_rec.segment3, 1, 10), l_vendor_int_rec.recon_account);
        l_vendor_int_rec.payment_methods := nvl(substr(rec.attribute9, 1, 10), l_vendor_int_rec.payment_methods);
        l_vendor_int_rec.house_bank      := nvl(substr(rec.attribute8, 1, 5), l_vendor_int_rec.house_bank);

        -- update by huangyan 2015-01-12
        --  l_vendor_int_rec.withholdingtax4 := l_site_rec.wht4;
        --  l_vendor_int_rec.withholdingtax5 := l_site_rec.wht5;

        -- 2.00  2015-04-17 11:27:00 jinlong.pan Add Begin
        IF upper(rec.ledger_name) = 'SHE LEDGER' OR upper(rec.ledger_name) = 'HET LEDGER' THEN
          IF rec.attribute3 LIKE '53%' OR rec.attribute3 LIKE '03%' THEN
            l_vendor_int_rec.recipient_type := substr(rec.attribute3, 1, 2);
          ELSIF rec.segment1 LIKE 'GSE%' OR rec.segment1 LIKE 'GTE%' THEN
            l_vendor_int_rec.recipient_type := '03';
          ELSE
            l_vendor_int_rec.recipient_type := '53';
          END IF;
        ELSE
          l_vendor_int_rec.recipient_type := NULL;
        END IF;
        -- 2.00  2015-04-17 11:27:00 jinlong.pan Add End

        IF l_vendor_int_rec.account_assgnt_group = 'GSE' OR l_vendor_int_rec.account_assgnt_group = 'GTE' THEN
          l_vendor_int_rec.withholdingtax4 := 'TH' /*NULL*/
           ; --update by huangyan 2015-04-16
          l_vendor_int_rec.withholdingtax5 := '11' /*NULL*/
           ; --update by huangyan 2015-04-16
          SELECT decode(rec.attribute3, NULL, '53', substr(rec.attribute3, 1, 2))
            INTO l_recipient_type
            FROM dual;
          --l_vendor_int_rec.recipient_type := l_recipient_type; --update by huangyan 2015-04-16
          --l_vendor_int_rec.recipient_type  := NULL;
        ELSIF l_vendor_int_rec.account_assgnt_group = 'FBE' THEN
          l_vendor_int_rec.withholdingtax4 := NULL /*l_site_rec.wht4*/
           ; --update by huangyan 2015-04-16
          l_vendor_int_rec.withholdingtax5 := NULL /*l_site_rec.wht5*/
           ;
          /*SELECT decode(rec.attribute3, NULL, '53', substr(rec.attribute3, 1, 2))
            INTO l_recipient_type
            FROM dual;
          l_vendor_int_rec.recipient_type := l_recipient_type;*/
          --l_vendor_int_rec.recipient_type := NULL; --update by huangyan 2015-04-16

        ELSE
          l_vendor_int_rec.withholdingtax4 := l_site_rec.wht4;
          l_vendor_int_rec.withholdingtax5 := l_site_rec.wht5;
        END IF;
        -- end update by huangyan 2015-01-12

        -- added by Jaron.li@2014-12-12
        /*IF rec.attribute3 IS NOT NULL THEN
          l_vendor_int_rec.recipient_type := substr(rec.attribute3, 1, 2);
        ELSIF rec.attribute3 IS NULL AND rec.segment1 LIKE 'GSE%' THEN
          l_vendor_int_rec.recipient_type := '03';
        END IF;*/
        -- end added
        --- cancel  by huangyan 2015-01-13
        /*l_vendor_int_rec.tax_line_item_no := nvl(substr(l_site_rec.tax_line_item_no
               ,1
               ,1)
        ,l_vendor_int_rec.tax_line_item_no);*/ --2.00 DEL

        l_vendor_int_rec.group_id              := p_group_id;
        l_vendor_int_rec.process_status        := fnd_api.g_ret_sts_success;
        l_vendor_int_rec.object_version_number := 1;
        --add bank info
        IF nvl(l_pre_vendor_id, -1) <> rec.vendor_id THEN
          l_bank_line_no := 0;
        END IF;
        IF l_count = 1 AND rec.bank_number IS NOT NULL THEN
          l_vendor_int_rec.bank_line_item := 1;
          l_bank_line_no                  := 1;
        ELSIF l_pre_vendor_id <> rec.vendor_id AND l_pre_vendor_id IS NOT NULL AND rec.bank_number IS NOT NULL THEN
          l_vendor_int_rec.bank_line_item := 1;
          l_bank_line_no                  := 1;
        ELSIF l_pre_vendor_id = rec.vendor_id AND l_pre_vendor_id IS NOT NULL AND rec.bank_number IS NOT NULL THEN
          l_bank_line_no                  := l_bank_line_no + 1;
          l_vendor_int_rec.bank_line_item := l_bank_line_no;
        END IF;
        l_vendor_int_rec.country1 := nvl(substr(rec.country_code, 1, 3), l_vendor_int_rec.country1);
        /*l_vendor_int_rec.bank_key     := nvl(substr(rec.bank_key
                                                   ,1
                                                   ,15)
                                            ,l_vendor_int_rec.bank_key);
        l_vendor_int_rec.bank_account := nvl(substr(rec.bank_number
                                                   ,1
                                                   ,15)
                                            ,l_vendor_int_rec.bank_account);*/ --2.00 del
        /*l_vendor_int_rec.bnkt         := nvl(substr(rec.check_digits, 1, 4),
        l_vendor_int_rec.bnkt);*/

        /*l_vendor_int_rec.ck := nvl(substr(rec.attribute7, 1, 2),
        l_vendor_int_rec.ck);*/
        --
        --who
        l_vendor_int_rec.creation_date          := SYSDATE;
        l_vendor_int_rec.created_by             := g_user_id;
        l_vendor_int_rec.last_update_date       := SYSDATE;
        l_vendor_int_rec.last_updated_by        := g_user_id;
        l_vendor_int_rec.last_update_login      := g_log_id;
        l_vendor_int_rec.program_id             := g_program_id;
        l_vendor_int_rec.request_id             := g_request_id;
        l_vendor_int_rec.program_application_id := g_program_appl_id;
        --update by liudan 2016/12/06 begin
        IF p_ledger = 'HET Ledger' THEN

          l_vendor_int_rec.g_g_code := nvl(rec.attribute15, 'DUMMYCODE');
        ELSE
          l_vendor_int_rec.g_g_code := 'DUMMYCODE';
        END IF;
        --end update by liudan 2016/12/06
        l_vendor_int_rec.vendor_last_update_date := rec.vendor_last_update_date;
        l_vendor_int_rec.interface_file_name     := l_file_name;
        l_vendor_int_rec.rerun_flag              := p_rerun_flag;
        l_vendor_int_rec.ledger_name             := p_ledger;
        l_vendor_int_rec.bank_country_key        := NULL;
        l_vendor_int_rec.bank_key                := NULL;
        l_vendor_int_rec.acct_holder             := NULL;
        l_vendor_int_rec.ck                      := NULL;
        l_vendor_int_rec.bank_account            := NULL;
        --withholdingtax5
        l_vendor_int_rec.iban                     := NULL;
        l_vendor_int_rec.valid_from               := NULL;
        l_vendor_int_rec.partner_bank_type        := NULL;
        l_vendor_int_rec.reference_specifications := NULL;
        l_vendor_int_rec.collection_authorization := NULL;
        l_vendor_int_rec.withholding_tax_code     := NULL;
        --l_vendor_int_rec.OBLIGATED_TO_WH_TAX_FROM := null;
        --l_vendor_int_rec.OBLIGATED_TO_WH_TAX_UNTILL := null;
        l_vendor_int_rec.w_tax_id := NULL;
        -- IF p_ledger = 'HEA Ledger' AND l_vendor_int_rec.account_assgnt_group = 'GSE' THEN
        -- add by huangyan 2015-01-13
        l_vendor_int_rec.excemption_number := NULL;
        l_vendor_int_rec.excemption        := NULL;
        l_vendor_int_rec.excempt_reason    := NULL;
        l_vendor_int_rec.excempt_from      := NULL;
        l_vendor_int_rec.excempt_to        := NULL;
        -- END IF;

        -- 3.00  2015-11-21 Jinlong.Pan    Update Begin
        IF (p_ledger = 'SHE Ledger' OR p_ledger = 'HET Ledger') THEN
          l_vendor_int_rec.branch_code        := nvl(rec.branch_code, '99999');
          l_vendor_int_rec.default_branch     := nvl(rec.branch_code, '99999');
          l_vendor_int_rec.branch_description := rec.branch_number;

          IF rec.branch_code IS NULL THEN
            l_vendor_int_rec.branch_description := 'Dummy Code';
          END IF;

          DECLARE
            l_exist_count NUMBER;
          BEGIN
            SELECT COUNT(1)
              INTO l_exist_count
              FROM xxap_vendor_to_hfg_int t
             WHERE 1 = 1
               AND t.vendor_number = l_vendor_int_rec.vendor_number
               AND t.branch_code = l_vendor_int_rec.branch_code;
            IF l_exist_count > 0 THEN
              l_vendor_int_rec.branch_code := NULL;
            END IF;
          END;

        ELSE
          l_vendor_int_rec.branch_code        := NULL;
          l_vendor_int_rec.default_branch     := NULL;
          l_vendor_int_rec.branch_description := NULL;
        END IF;
        -- 3.00  2015-11-21 Jinlong.Pan    Update End
        validate_required(l_vendor_int_rec);
        IF l_vendor_int_rec.process_status = fnd_api.g_ret_sts_error THEN
          l_error_count := l_error_count + 1;
        END IF;
        l_vendor_int_rec.vendor_id := rec.vendor_id;
        -- l_vendor_int_tbl(l_count) := l_vendor_int_rec;
        --CRATE or Update record in table

        -- update by shengxiang.fan 2015-06-18 start
        IF rec.unique_id IS NOT NULL THEN
          SELECT xxap_vendor_to_hfa_int_s.nextval
            INTO l_vendor_int_rec.unique_id
            FROM dual;
          /*l_vendor_int_rec.unique_id       := rec.unique_id;*/
          l_vendor_int_rec.new_vendor_flag := 'N';

          INSERT INTO xxap_vendor_to_hfg_int
          VALUES l_vendor_int_rec;
          --update_vendor_to_hfg_int(l_vendor_int_rec, rec.unique_id);
          -- update by shengxiang.fan 2015-06-18 end
        ELSE
          SELECT xxap_vendor_to_hfa_int_s.nextval
            INTO l_vendor_int_rec.unique_id
            FROM dual;
          l_vendor_int_rec.new_vendor_flag := 'Y';
          INSERT INTO xxap_vendor_to_hfg_int
          VALUES l_vendor_int_rec;
        END IF;

        l_pre_vendor_id := rec.vendor_id;
      END LOOP;

    ELSIF p_rerun_flag = 'Y' THEN

      SELECT COUNT(1)
        INTO l_cnt
        FROM xxap_vendor_to_hfg_int xcth
       WHERE 1 = 1
         AND xcth.rerun_flag = 'N'
         AND EXISTS (SELECT 1
                FROM gl_period_statuses gls
               WHERE gls.closing_status IN ('O')
                 AND gls.ledger_id = (SELECT ledger_id
                                        FROM gl_ledgers gl
                                       WHERE gl.name = p_ledger)
                 AND gls.application_id = 222
                 AND gls.adjustment_period_flag = 'N'
                 AND xcth.vendor_last_update_date BETWEEN gls.start_date AND gls.end_date);
      IF l_cnt > 0 THEN
        l_file_name := get_file_name;
        UPDATE xxap_vendor_to_hfg_int xctho
           SET xctho.group_id = p_group_id, xctho.interface_file_name = l_file_name, xctho.rerun_flag = 'Y'
         WHERE EXISTS (SELECT 1
                  FROM gl_period_statuses gls
                 WHERE gls.closing_status IN ('O')
                   AND gls.ledger_id = (SELECT ledger_id
                                          FROM gl_ledgers gl
                                         WHERE gl.name = p_ledger)
                   AND gls.application_id = 222
                   AND gls.adjustment_period_flag = 'N'
                   AND xctho.vendor_last_update_date BETWEEN gls.start_date AND gls.end_date);
      END IF;

    END IF;

    FORALL result_idx IN 1 .. l_vendor_int_tbl.count
      INSERT INTO xxap_vendor_to_hfg_int
      VALUES l_vendor_int_tbl
        (result_idx);

    log_msg('l_count = ' || l_count);
    log_msg('l_error_count = ' || l_error_count);

    print_error_report(p_group_id);
    generate_hfg_file(p_ledger, p_group_id, l_file_name);
    COMMIT;
    IF l_error_count > 0 THEN
      x_ret_status := fnd_api.g_ret_sts_error;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_ret_status := fnd_api.g_ret_sts_error;
      x_msg_data   := SQLERRM;
      x_msg_count  := 1;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_ret_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_data   := SQLERRM;
      x_msg_count  := 1;
    WHEN OTHERS THEN
      x_ret_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_data   := SQLERRM;
      log_msg('Sqlerrm : ' || SQLERRM);
      x_msg_count := 1;
  END hfg_process_request;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  main
  *   DESCRIPTION:
  *              hfg_main
  *   ARGUMENT:  p_group_id
  *              p_interface_date
  *   RETURN:
  *
  *   HISTORY:
  *     1.00 2012-05-24 colin.chen
  *     2.00 2014-07-31 Jia
  * =============================================*/
  PROCEDURE hfg_main(errbuf           OUT VARCHAR2,
                     retcode          OUT VARCHAR2,
                     p_group_id       IN NUMBER,
                     p_interface_date IN VARCHAR2,
                     p_ledger         IN VARCHAR2 /*,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                p_rerun_flag     IN VARCHAR2*/) IS
    l_return_status VARCHAR2(30);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_group_id      NUMBER;
    l_ledger        VARCHAR2(200);
    l_rerun_flag    VARCHAR2(10);
    l_date_from     DATE;
    l_date_to       DATE;
  BEGIN
    retcode := '0';
    -- concurrent header log
    -- xxfnd_conc_utl.log_header;
    -- conc body

    IF p_group_id IS NULL THEN
      SELECT xxap_vendor_to_hfa_group_int_s.nextval
        INTO l_group_id
        FROM dual;
    ELSE
      l_group_id := p_group_id;
    END IF;
    --2.00 add start
    IF p_ledger IS NULL THEN
      log_msg('GL_ACCESS_SET_ID :' || fnd_profile.value('GL_ACCESS_SET_ID'));
      BEGIN
        SELECT NAME
          INTO l_ledger
          FROM gl_access_sets
         WHERE access_set_id = fnd_profile.value('GL_ACCESS_SET_ID')
           AND rownum = 1;
      EXCEPTION
        WHEN OTHERS THEN
          log_msg('Can not get default ledger :' || SQLERRM);
      END;
    ELSE
      l_ledger := p_ledger;
    END IF;
    log_msg('l_ledger :' || l_ledger);

    /*IF p_rerun_flag IS NULL THEN
      l_rerun_flag := 'N';
    ELSE
      l_rerun_flag := p_rerun_flag;
    END IF;*/
    l_rerun_flag := 'N';
    /*IF p_interface_date IS NOT NULL THEN
      IF trunc(fnd_conc_date.string_to_date(p_interface_date)) = trunc(SYSDATE) THEN
        l_date_from := nvl(get_last_run_date(l_ledger), to_date('0001-01-01', 'yyyy-mm-dd'));
        l_date_to   := SYSDATE;
      ELSE
        l_date_from := trunc(fnd_conc_date.string_to_date(p_interface_date));
        l_date_to   := trunc(fnd_conc_date.string_to_date(p_interface_date)) + 99999 / 100000;
      END IF;
    ELSE
      l_date_from := nvl(get_last_run_date(l_ledger), to_date('0001-01-01', 'yyyy-mm-dd'));
      l_date_to   := SYSDATE;
    END IF;*/
    l_date_from := fnd_conc_date.string_to_date(p_interface_date);
    l_date_to   := SYSDATE;
    log_msg('l_date_from:' || to_char(l_date_from, 'yyyy-mm-dd hh24:mi:ss'));
    log_msg('l_date_to:' || to_char(l_date_to, 'yyyy-mm-dd hh24:mi:ss'));
    --2.00 add end
    hfg_process_request(p_group_id   => l_group_id,
                        p_date_from  => l_date_from,
                        p_date_to    => l_date_to,
                        p_ledger     => l_ledger,
                        p_rerun_flag => l_rerun_flag,
                        x_ret_status => l_return_status,
                        x_msg_count  => l_msg_count,
                        x_msg_data   => l_msg_data);

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- conc end body
    -- concurrent footer log
    xxfnd_conc_utl.log_footer;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      xxfnd_conc_utl.log_message_list;
      retcode := '1';
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => l_msg_data);
      IF l_msg_count > 1 THEN
        l_msg_data := fnd_msg_pub.get_detail(p_msg_index => fnd_msg_pub.g_first, p_encoded => fnd_api.g_false);
      END IF;
      errbuf := l_msg_data;
    WHEN fnd_api.g_exc_unexpected_error THEN
      xxfnd_conc_utl.log_message_list;
      retcode := '2';
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => l_msg_data);
      IF l_msg_count > 1 THEN
        l_msg_data := fnd_msg_pub.get_detail(p_msg_index => fnd_msg_pub.g_first, p_encoded => fnd_api.g_false);
      END IF;
      errbuf := l_msg_data;
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg(p_pkg_name       => g_pkg_name,
                              p_procedure_name => 'MAIN',
                              p_error_text     => substrb(SQLERRM, 1, 240));
      xxfnd_conc_utl.log_message_list;
      retcode := '2';
      errbuf  := SQLERRM;
  END hfg_main;

END xxap_vendor_to_hfg_pkg;
/
