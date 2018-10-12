CREATE OR REPLACE PACKAGE xxar_cust_to_hfg_pkg IS
  /*=================================================================
   Copyright (C) HAND Enterprise Solutions Co.,Ltd.
                AllRights Reserved
    =================================================================
  * =================================================================
  *   PROGRAM NAME:
  *         xxar_cust_to_hfg_pkg
  *
  *   DESCRIPTION:
  *         get new customer info outbound to HFG
  *   HISTORY:
  *     1.00 2014-07-31 Jia
  *
  * ===============================================================*/
  FUNCTION get_site_cont_last_update(p_party_site_id      IN NUMBER,
                                     p_contact_point_type IN VARCHAR2,
                                     p_line_type          IN VARCHAR2) RETURN DATE;
  FUNCTION get_site_email_last_update(p_party_site_id IN NUMBER) RETURN DATE;
  FUNCTION get_site_contract(p_party_site_id      IN NUMBER,
                             p_contact_point_type IN VARCHAR2,
                             p_line_type          IN VARCHAR2) RETURN VARCHAR2;
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
  *     1.00 2014-07-31 Jia
  *
  * =============================================*/
  PROCEDURE hfg_main(errbuf           OUT VARCHAR2,
                     retcode          OUT VARCHAR2,
                     p_group_id       IN NUMBER,
                     p_interface_date IN VARCHAR2,
                     p_ledger         IN VARCHAR2 /*,
                                                                                                                                                   p_rerun_flag     IN VARCHAR2*/);

END xxar_cust_to_hfg_pkg;
/
CREATE OR REPLACE PACKAGE BODY xxar_cust_to_hfg_pkg IS
  /*=================================================================
   Copyright (C) HAND Enterprise Solutions Co.,Ltd.
                AllRights Reserved
    =================================================================
  * =================================================================
  *   PROGRAM NAME:
  *         xxar_cust_to_hfg_pkg
  *
  *   DESCRIPTION:
  *         get new customer info outbound to HFG
  *   HISTORY:
  *     1.00 2014-07-31 Jia
  *     1.01 2015-06-18 shengxiang.fan update
  *     2.00 2015-09-07 Jinlong.Pan update Change error handling method from A to B.
  *     3.00 2015-11-22 Jinlong.Pan Update for CR#3412 Interface Branch from GSCM to HFG
        4.00 2016/12/05 liudan update for HET hard coding
        5.00 2018-08-16 baobao.hu modify
  * ===============================================================*/

  g_pkg_name  CONSTANT VARCHAR2(30) := 'xxar_cust_to_hfg_pkg';
  g_seperator CONSTANT VARCHAR2(1) := chr(9);
  g_blank_char VARCHAR2(1);
  g_date_format     CONSTANT VARCHAR2(15) := 'DD-MM-YYYY';
  g_user_id         CONSTANT NUMBER := fnd_global.user_id;
  g_log_id          CONSTANT NUMBER := fnd_global.login_id;
  g_request_id      CONSTANT NUMBER := fnd_global.conc_request_id;
  g_program_id      CONSTANT NUMBER := fnd_global.conc_program_id;
  g_program_appl_id CONSTANT NUMBER := fnd_global.prog_appl_id;
  g_max_length      CONSTANT NUMBER := 2000;
  g_miss_rec xxar_cust_to_hfg_int%ROWTYPE;

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
  *   NAME :  replace_seperator
  *   DESCRIPTION:
  *              replace_seperator
  *   HISTORY:
  *     1.00 2014-07-31 Jia
  *
  * =============================================*/
  FUNCTION replace_seperator(p_string IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN REPLACE(p_string, g_seperator, ' ');
  END replace_seperator;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_g_g_code
  *   DESCRIPTION:
  *              get_g_g_code
  *   HISTORY:
  *     1.00 2016-12-06 liudan
  *
  * =============================================*/
  function get_g_g_code(p_party_id in number) return varchar2 is
    l_g_g_code varchar2(50);
  begin
    select org.duns_number_c
      into l_g_g_code
      from APPS.hz_organization_profiles org
     where org.organization_profile_id =
           (select max(v.organization_profile_id)
              from apps.hz_organization_profiles v
             where v.party_id = p_party_id);

    return l_g_g_code;

  exception
    when others then
      return null;
  end;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_ou_name
  *   DESCRIPTION:
  *              get_ou_name
  *   HISTORY:
  *     1.00 2014-07-31 Jia
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
        FROM xxar_cust_to_hfg_int xcth
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
  *   NAME :  get_file_name
  *   DESCRIPTION:
  *              get_file_name
  *   HISTORY:
  *     1.00 2014-07-31 Jia
  *
  * =============================================*/
  FUNCTION get_file_name RETURN VARCHAR2 IS
    l_date      VARCHAR2(8) := to_char(SYSDATE, 'YYYYMMDD');
    l_execution VARCHAR2(1) := '1';
    -- 2.00 2015-09-07 Jinlong.Pan update Begin
    -- l_error_handling   VARCHAR2(1) := 'A'; --'B';
    l_error_handling VARCHAR2(1) := 'B';
    -- 2.00 2015-09-07 Jinlong.Pan update End
    l_function_id      VARCHAR2(2) := '02';
    l_variant_id       VARCHAR2(2) := '01';
    l_language         VARCHAR2(2) := 'EN';
    l_arbitrary_string VARCHAR2(8) := 'Cust';
    l_extension        VARCHAR2(4) := '.TXT';
    l_sequence_id      NUMBER;
    l_cnt              NUMBER;
  BEGIN
    BEGIN
      SELECT nvl(MAX(to_number(substr(interface_file_name, 21, 4))), 0) --COUNT(1)
        INTO l_sequence_id
        FROM xxar_cust_to_hfg_int
       WHERE substr(interface_file_name, 1, 8) = l_date;
    EXCEPTION
      WHEN OTHERS THEN
        l_sequence_id := 0;
    END;
    l_sequence_id := l_sequence_id + 1;

    /* IF l_cnt = 0 THEN
      EXECUTE IMMEDIATE 'drop sequence xxar.xxar_cust_to_hfg_day_s';
      EXECUTE IMMEDIATE 'create sequence xxar.xxar_cust_to_hfg_day_s start with 1 nocache';
    END IF;
    l_sequence_id := xxar_cust_to_hfg_day_s.nextval;*/

    /*    RETURN l_date || substr(lpad(l_variant_id, 3, '0'), 1, 1) || l_error_handling || l_function_id || substr(lpad(l_variant_id,
                                                                                                                    3,
                                                                                                                    '0'),
                                                                                                               2,
                                                                                                               2) || l_language || l_arbitrary_string || l_extension;
    */
    RETURN l_date || l_execution || l_error_handling || l_function_id || l_variant_id || l_language || l_arbitrary_string || substr(lpad(l_sequence_id,
                                                                                                                                         4,
                                                                                                                                         '0'),
                                                                                                                                    1,
                                                                                                                                    4) || '.TXT';
  END get_file_name;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  print_error_report
  *   DESCRIPTION:
  *              print_error_report
  *   HISTORY:
  *     1.00 2014-07-31 Jia
  *
  * =============================================*/
  PROCEDURE print_error_report(p_group_id IN NUMBER) IS
    CURSOR cur IS
      SELECT *
        FROM xxar_cust_to_hfg_int xch
       WHERE xch.process_status = fnd_api.g_ret_sts_error
         AND xch.group_id = p_group_id;
    l_msg VARCHAR2(20000);
  BEGIN
    log_msg(rpad('-', 300, '-'));
    l_msg := 'OU' || g_seperator || 'Account group' || g_seperator ||
             'Customer Number' || g_seperator || 'Company Code' ||
             g_seperator || 'Name 1' || g_seperator || 'Search term 1' ||
             g_seperator || 'Postal code' || g_seperator ||
             'Street/House number' || g_seperator || 'Country' ||
             g_seperator || 'Recon.account' || g_seperator ||
             'Error Message';
    log_msg(l_msg);
    FOR rec IN cur LOOP
      l_msg := get_ou_name(rec.org_id) || g_seperator || rec.account_group ||
               g_seperator || rec.customer_number || g_seperator ||
               rec.company_code || g_seperator || rec.name1 || g_seperator ||
               rec.search_term1 || g_seperator || rec.postal_code ||
               g_seperator || rec.street_house_number || g_seperator ||
               rec.country || g_seperator || rec.recon_account ||
               g_seperator || rec.process_message;
      log_msg(l_msg);
    END LOOP;
    log_msg(rpad('-', 300, '-'));

    DELETE FROM xxar_cust_to_hfg_int xch
     WHERE xch.process_status = fnd_api.g_ret_sts_error
       AND xch.group_id = p_group_id;
  END print_error_report;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  generate_hfg_file
  *   DESCRIPTION:
  *              generate_hfg_file
  *   HISTORY:
  *     1.00 2014-07-31 Jia
  *
  * =============================================*/
  PROCEDURE generate_hfg_file(p_ledger    IN VARCHAR2,
                              p_group_id  IN NUMBER,
                              p_file_name IN VARCHAR2) IS
    CURSOR cur IS
      SELECT xci.*,
             decode(xci.rerun_flag,
                    'Y',
                    g_blank_char,
                    decode(xci.new_customer_flag,
                           'Y',
                           xci.g_g_code,
                           g_blank_char)) g_g_code_output
        FROM xxar_cust_to_hfg_int xci
       WHERE xci.group_id = p_group_id;
    l_msg               VARCHAR2(32767);
    l_outbound_path_dir VARCHAR2(200);
    l_outbound_path     VARCHAR2(200);
    c_amount CONSTANT BINARY_INTEGER := 32767;
    l_fhandler utl_file.file_type;
    l_cnt      NUMBER;
  BEGIN
    SELECT COUNT(1)
      INTO l_cnt
      FROM xxar_cust_to_hfg_int xci
     WHERE xci.group_id = p_group_id;
    IF l_cnt = 0 THEN
      out_msg('No data get in this request, will not generate file on server.');
    ELSE
      /* l_outbound_path     := '/mt3/IF_Folders/IF63/' ||
                             SUBSTR(P_LEDGER, 1, 3) || '_LEDGER/unprocess';
      l_outbound_path_dir := 'XXARB003_' || SUBSTR(P_LEDGER, 1, 3) ||
                             '_OUTBOUND_DIR';
      execute immediate 'create or replace directory ' ||
                        l_outbound_path_dir || ' AS ''' || l_outbound_path || '''';

      l_fhandler := utl_file.fopen(l_outbound_path_dir,
                                   p_file_name,
                                   'W',
                                   c_amount);
      IF utl_file.is_open(l_fhandler) = FALSE THEN
        out_msg('ERROR OPENING FILE FOR ' || l_outbound_path_dir || ': ' ||
                SQLERRM);
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;*/

      l_msg := 'Customer' || g_seperator || 'Company Code' || g_seperator ||
               'Account group' || g_seperator || 'Title' || g_seperator ||
               'Name1' || g_seperator || 'Name2' || g_seperator || 'Name3' ||
               g_seperator || 'Name4' || g_seperator || 'Search term 1' ||
               g_seperator || 'Street 2' || g_seperator || 'Street 3' ||
               g_seperator || 'Street' || g_seperator || 'House number' ||
               g_seperator || 'supplement' || g_seperator || 'Street 4' ||
               g_seperator || 'Street 5' || g_seperator || 'District' ||
               g_seperator || 'Different City' || g_seperator || 'City' ||
               g_seperator || 'Postal Code' || g_seperator || 'Country' ||
               g_seperator || 'Region' || g_seperator || 'Time zone' ||
               g_seperator || 'Jurisdict. code' || g_seperator ||
               'Transportation zone' || g_seperator || 'PO Box' ||
               g_seperator || 'PO Box without number' || g_seperator ||
               'Delivery Serv' || g_seperator || 'Delivery Service Number' ||
               g_seperator || 'PO Box Lobby' || g_seperator ||
               'Postal code' || g_seperator || 'Other city' || g_seperator ||
               'Other country' || g_seperator || 'Other region' ||
               g_seperator || 'Company postal code' || g_seperator ||
               'Language' || g_seperator || 'Telephone ' || g_seperator ||
               'Extension' || g_seperator || 'Mobile Phone' || g_seperator ||
               'FAX' || g_seperator || 'Extension' || g_seperator ||
               'E-Mail' || g_seperator || 'StandardComm.Mtd' || g_seperator ||
               'Data line' || g_seperator || 'Telebox' || g_seperator ||
               'Comments' || g_seperator || 'Vendor' || g_seperator ||
               'Authorization' || g_seperator || 'Corporate Group' ||
               g_seperator || 'Location no. 1' || g_seperator ||
               'Location no. 2' || g_seperator || 'Check digit' ||
               g_seperator || 'Industry' || g_seperator || 'Train station' ||
               g_seperator || 'Express station' || g_seperator ||
               'Location code' || g_seperator || 'Tax Number 1' ||
               g_seperator || 'Tax Number 2' || g_seperator ||
               'Tax Number 3' || g_seperator || 'Tax Number 4' ||
               g_seperator || 'Tax type' || g_seperator ||
               'Tax number type' || g_seperator || 'Equalization Tax' ||
               g_seperator || 'Natural Person' || g_seperator ||
               'Sales/pur.tax' || g_seperator || 'Fiscal address' ||
               g_seperator || 'County code' || g_seperator ||
               'VAT Reg. No.' || g_seperator || 'City code' || g_seperator ||
               'ICMS law' || g_seperator || 'IPI law' || g_seperator ||
               'CFOP Category' || g_seperator || 'SubTrib group' ||
               g_seperator || 'ICMS-exempt ' || g_seperator || 'IPI-exempt' ||
               g_seperator || 'Rep''s Name' || g_seperator ||
               'Type of Busines' || g_seperator || 'Type of Industr' ||
               g_seperator || 'Bank country key' || g_seperator ||
               'Bank key' || g_seperator || 'Bank Account' || g_seperator ||
               'Acct holder' || g_seperator || 'Control Key' || g_seperator ||
               'IBAN' || g_seperator || 'Valid from' || g_seperator ||
               'Partner Bank Type' || g_seperator ||
               'Reference specifications ' || g_seperator ||
               'collection authorization ' || g_seperator ||
               'Alternative payee' || g_seperator || 'DME Indicator' ||
               g_seperator || 'Instruction key' || g_seperator ||
               'Individual spec.' || g_seperator || 'Recon. account' ||
               g_seperator || 'Sort key' || g_seperator || 'Head office' ||
               g_seperator || 'Preference ind' || g_seperator ||
               'Authorization' || g_seperator || 'Release group' ||
               g_seperator || 'Value adjustment' || g_seperator ||
               'Interest indic.' || g_seperator || 'Last key date' ||
               g_seperator || 'Interest freq.' || g_seperator ||
               'Last interest run' || g_seperator || 'Prev.acct no.' ||
               g_seperator || 'Personnel number' || g_seperator ||
               'Buying Group' || g_seperator || 'Activity Code' ||
               g_seperator || 'Distr. Type' || g_seperator || 'Payt Terms' ||
               g_seperator || 'Tolerance group' || g_seperator ||
               'Cr memo terms' || g_seperator || 'Known/neg.leave' ||
               g_seperator || 'B/e charges payt term' || g_seperator ||
               'AR Pledging Ind' || g_seperator || 'Time until check paid' ||
               g_seperator || 'Payment History Record' || g_seperator ||
               'Payment methods' || g_seperator || 'Payment block' ||
               g_seperator || 'Alternat.payee' || g_seperator ||
               'House Bank' || g_seperator || 'B/exch.limit' || g_seperator ||
               'Grouping key' || g_seperator || 'Single payment' ||
               g_seperator || 'Clearing with Vendor' || g_seperator ||
               'EDI' || g_seperator || 'PmtAdv. XML' || g_seperator ||
               'Different payer in document' || g_seperator || 'Next payee' ||
               g_seperator || 'Lockbox' || g_seperator || 'Rsn code conv.' ||
               g_seperator || 'Selection rule' || g_seperator ||
               'Dunn.Procedure' || g_seperator || 'Dunning Block' ||
               g_seperator || 'Dunn.recipient' || g_seperator ||
               'Legal dunn.proc.' || g_seperator || 'Last Dunned' ||
               g_seperator || 'Dunning Level' || g_seperator ||
               'Dunning clerk' || g_seperator || 'Grouping key' ||
               g_seperator || 'Acctg clerk' || g_seperator ||
               'Account statement' || g_seperator || 'Acct at cust.' ||
               g_seperator || 'Coll. invoice variant' || g_seperator ||
               'Customer user' || g_seperator || 'Local Process' ||
               g_seperator || 'Act.clk tel.no.' || g_seperator ||
               'Clerk''s fax' || g_seperator || 'Clrk''s internet' ||
               g_seperator || 'Account memo' || g_seperator ||
               'Payment notice' || g_seperator || '(with cleared items)' ||
               g_seperator || 'payment notice' || g_seperator ||
               '(sales department)' || g_seperator || 'payment notice' ||
               g_seperator || '(legal department)' || g_seperator ||
               'payment notice' || g_seperator || '(without cleared items)' ||
               g_seperator || 'Paymentnotice' || g_seperator ||
               '(accounting department) ' || g_seperator ||
               'Withholding Tax Country Key' || g_seperator ||
               'withholding tax type' || g_seperator ||
               'withholding tax code' || g_seperator ||
               'Subject to withholding tax' || g_seperator ||
               'Obligated to withhold tax from' || g_seperator ||
               'Obligated to withhold tax until' || g_seperator ||
               'W/tax ID' || g_seperator || 'G&G code';

      out_msg(l_msg);

      -- utl_file.put_line(l_fhandler, l_msg);

      FOR rec IN cur LOOP
        l_msg := replace_seperator(rec.customer_number) || g_seperator ||
                 replace_seperator(rec.company_code) || g_seperator ||
                 replace_seperator(rec.account_group) || g_seperator ||
                 replace_seperator(rec.title) || g_seperator ||
                --replace_seperator(rec.name1) || g_seperator ||
                 substr(replace_seperator(rec.name1), 1, 40) || g_seperator || -- update by huangyan 2015-01-22
                --replace_seperator(rec.name2) || g_seperator ||
                 substr(replace_seperator(rec.name2), 1, 40) || g_seperator || -- update by huangyan 2015-01-22
                 replace_seperator(rec.name3) || g_seperator ||
                 replace_seperator(rec.name4) || g_seperator ||
                 replace_seperator(rec.search_term1) || g_seperator ||
                 replace_seperator(rec.street2) || g_seperator ||
                 replace_seperator(rec.street3) || g_seperator ||
                --replace_seperator(rec.street) || g_seperator ||
                 substr(replace_seperator(rec.street), 1, 40) ||
                 g_seperator || -- update by huangyan 2015-01-22
                 replace_seperator(rec.house_number) || g_seperator ||
                 replace_seperator(rec.supplement) || g_seperator ||
                /*replace_seperator(rec.street4) || g_seperator ||
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 replace_seperator(rec.street5) || g_seperator ||*/
                 substr(replace_seperator(rec.street4), 1, 40) ||
                 g_seperator || -- update by huangyan 2015-01-22
                 substr(replace_seperator(rec.street5), 1, 40) ||
                 g_seperator || -- update by huangyan 2015-01-22
                 replace_seperator(rec.district) || g_seperator ||
                 replace_seperator(rec.different_city) || g_seperator ||
                --replace_seperator(rec.city) || g_seperator ||
                 substr(replace_seperator(rec.city), 1, 40) || g_seperator || -- update by huangyan 2015-01-22
                 replace_seperator(rec.postal_code) || g_seperator ||
                 replace_seperator(rec.country) || g_seperator ||
                 replace_seperator(rec.region) || g_seperator ||
                 replace_seperator(rec.time_zone) || g_seperator ||
                 replace_seperator(rec.jurisdict_code) || g_seperator ||
                 replace_seperator(rec.transportation_zone) || g_seperator ||
                 replace_seperator(rec.po_box) || g_seperator ||
                 replace_seperator(rec.po_box_without_number) ||
                 g_seperator || replace_seperator(rec.delivery_serv) ||
                 g_seperator ||
                 replace_seperator(rec.delivery_service_number) ||
                 g_seperator || replace_seperator(rec.po_box_lobby) ||
                 g_seperator || replace_seperator(rec.postal_code2) ||
                 g_seperator || replace_seperator(rec.other_city) ||
                 g_seperator || replace_seperator(rec.other_country) ||
                 g_seperator || replace_seperator(rec.other_region) ||
                 g_seperator || replace_seperator(rec.company_postal_code) ||
                 g_seperator || replace_seperator(rec.language) ||
                 g_seperator || replace_seperator(rec.telephone) ||
                 g_seperator || replace_seperator(rec.extensio1) ||
                 g_seperator || replace_seperator(rec.mobile_phone) ||
                 g_seperator || replace_seperator(rec.fax) || g_seperator ||
                 replace_seperator(rec.extension2) || g_seperator ||
                 replace_seperator(rec.e_mail) || g_seperator ||
                 replace_seperator(rec.standard_comm_mtd) || g_seperator ||
                 replace_seperator(rec.data_line) || g_seperator ||
                 replace_seperator(rec.telebox) || g_seperator ||
                 replace_seperator(rec.comments) || g_seperator ||
                 replace_seperator(rec.vendor) || g_seperator ||
                 replace_seperator(rec.authorization1) || g_seperator ||
                 replace_seperator(rec.corporate_group) || g_seperator ||
                 replace_seperator(rec.location_no_1) || g_seperator ||
                 replace_seperator(rec.location_no_2) || g_seperator ||
                 replace_seperator(rec.check_digit) || g_seperator ||
                 replace_seperator(rec.industry) || g_seperator ||
                 replace_seperator(rec.train_station) || g_seperator ||
                 replace_seperator(rec.express_station) || g_seperator ||
                 replace_seperator(rec.location_code) || g_seperator ||
                 replace_seperator(rec.tax_number_1) || g_seperator ||
                 replace_seperator(rec.tax_number_2) || g_seperator ||
                 replace_seperator(rec.tax_number_3) || g_seperator ||
                 replace_seperator(rec.tax_number_4) || g_seperator ||
                 replace_seperator(rec.tax_type) || g_seperator ||
                 replace_seperator(rec.tax_number_type) || g_seperator ||
                 replace_seperator(rec.equalization_tax) || g_seperator ||
                 replace_seperator(rec.natural_person) || g_seperator ||
                 replace_seperator(rec.sales_pur_tax) || g_seperator ||
                 replace_seperator(rec.fiscal_address) || g_seperator ||
                 replace_seperator(rec.county_code) || g_seperator ||
                 replace_seperator(rec.vat_reg_no) || g_seperator ||
                 replace_seperator(rec.city_code) || g_seperator ||
                 replace_seperator(rec.icms_law) || g_seperator ||
                 replace_seperator(rec.ipi_law) || g_seperator ||
                 replace_seperator(rec.cfop_category) || g_seperator ||
                 replace_seperator(rec.subtrib_group) || g_seperator ||
                 replace_seperator(rec.icms_exempt) || g_seperator ||
                 replace_seperator(rec.ipi_exempt) || g_seperator ||
                 replace_seperator(rec.rep_name) || g_seperator ||
                 replace_seperator(rec.type_of_business) || g_seperator ||
                 replace_seperator(rec.type_of_industry) || g_seperator ||
                 replace_seperator(rec.bank_country) || g_seperator ||
                 replace_seperator(rec.bank_key) || g_seperator ||
                 replace_seperator(rec.bank_account) || g_seperator ||
                 replace_seperator(rec.acct_holder) || g_seperator ||
                 replace_seperator(rec.control_key) || g_seperator ||
                 replace_seperator(rec.iban) || g_seperator ||
                 replace_seperator(rec.valid_from) || g_seperator ||
                 replace_seperator(rec.partner_bank_type) || g_seperator ||
                 replace_seperator(rec.reference_specifications) ||
                 g_seperator ||
                 replace_seperator(rec.collection_authorization) ||
                 g_seperator || replace_seperator(rec.alternative_payee) ||
                 g_seperator || replace_seperator(rec.dme_indicator) ||
                 g_seperator || replace_seperator(rec.instruction_key) ||
                 g_seperator || replace_seperator(rec.individual_spec) ||
                 g_seperator || replace_seperator(rec.recon_account) ||
                 g_seperator || replace_seperator(rec.sort_key) ||
                 g_seperator || replace_seperator(rec.head_office) ||
                 g_seperator || replace_seperator(rec.preference_ind) ||
                 g_seperator || replace_seperator(rec.authorization2) ||
                 g_seperator || replace_seperator(rec.release_group) ||
                 g_seperator || replace_seperator(rec.value_adjustment) ||
                 g_seperator || replace_seperator(rec.interest_indic) ||
                 g_seperator || replace_seperator(rec.last_key_date) ||
                 g_seperator || replace_seperator(rec.interest_freq) ||
                 g_seperator || replace_seperator(rec.last_interest_run) ||
                 g_seperator || replace_seperator(rec.prev_acct_no) ||
                 g_seperator || replace_seperator(rec.personnel_number) ||
                 g_seperator || replace_seperator(rec.buying_group) ||
                 g_seperator || replace_seperator(rec.activity_code) ||
                 g_seperator || replace_seperator(rec.distr_type) ||
                 g_seperator || replace_seperator(rec.terms_of_payment) ||
                 g_seperator || replace_seperator(rec.tolerance_group) ||
                 g_seperator || replace_seperator(rec.cr_memo_terms) ||
                 g_seperator || replace_seperator(rec.known_neg_leave) ||
                 g_seperator ||
                 replace_seperator(rec.b_e_charges_payt_term) ||
                 g_seperator || replace_seperator(rec.ar_pledging_ind) ||
                 g_seperator ||
                 replace_seperator(rec.time_until_check_paid) ||
                 g_seperator ||
                 replace_seperator(rec.payment_history_record) ||
                 g_seperator || replace_seperator(rec.payment_methods) ||
                 g_seperator || replace_seperator(rec.payment_block) ||
                 g_seperator || replace_seperator(rec.alternat_payee) ||
                 g_seperator || replace_seperator(rec.house_bank) ||
                 g_seperator || replace_seperator(rec.exch_limit) ||
                 g_seperator || replace_seperator(rec.group_key) ||
                 g_seperator || replace_seperator(rec.single_payment) ||
                 g_seperator || replace_seperator(rec.clearing_with_vendor) ||
                 g_seperator || replace_seperator(rec.edi) || g_seperator ||
                 replace_seperator(rec.pmtadv_xml) || g_seperator ||
                 replace_seperator(rec.different_payer_in_document) ||
                 g_seperator || replace_seperator(rec.next_payee) ||
                 g_seperator || replace_seperator(rec.lockbox) ||
                 g_seperator || replace_seperator(rec.rsn_code_conv) ||
                 g_seperator || replace_seperator(rec.selection_rule) ||
                 g_seperator || replace_seperator(rec.dunn_procedure) ||
                 g_seperator || replace_seperator(rec.dunning_block) ||
                 g_seperator || replace_seperator(rec.dunn_recipient) ||
                 g_seperator || replace_seperator(rec.leg_dunn_proc) ||
                 g_seperator || replace_seperator(rec.last_dunned) ||
                 g_seperator || replace_seperator(rec.dunning_level) ||
                 g_seperator || replace_seperator(rec.dunning_clerk) ||
                 g_seperator || replace_seperator(rec.grouping_key2) ||
                 g_seperator || replace_seperator(rec.acctg_clerk) ||
                 g_seperator || replace_seperator(rec.account_statement) ||
                 g_seperator || replace_seperator(rec.acct_at_cust) ||
                 g_seperator || replace_seperator(rec.coll_invoice_variant) ||
                 g_seperator || replace_seperator(rec.customer_user) ||
                 g_seperator || replace_seperator(rec.local_processing) ||
                 g_seperator || replace_seperator(rec.act_clk_tel_no) ||
                 g_seperator || replace_seperator(rec.clerk_fax) ||
                 g_seperator || replace_seperator(rec.clrk_internet) ||
                 g_seperator || replace_seperator(rec.account_memo) ||
                 g_seperator ||
                 replace_seperator(rec.payment_notice_cleared_itm) ||
                 g_seperator ||
                 replace_seperator(rec.payment_notice_sales_dpt) ||
                 g_seperator ||
                 replace_seperator(rec.payment_notice_legal_dpt) ||
                 g_seperator ||
                 replace_seperator(rec.payment_notice_wo_cleared_itm) ||
                 g_seperator ||
                 replace_seperator(rec.payment_notice_acc_dpt) ||
                 g_seperator ||
                 replace_seperator(rec.withholding_tax_country_key) ||
                 g_seperator || replace_seperator(rec.withholding_tax_type) ||
                 g_seperator || replace_seperator(rec.withholding_tax_code) ||
                 g_seperator ||
                 replace_seperator(rec.subject_to_withholding_tax) ||
                 g_seperator ||
                 replace_seperator(rec.obligated_to_wh_tax_from) ||
                 g_seperator ||
                 replace_seperator(rec.obligated_to_wh_tax_until) ||
                 g_seperator || replace_seperator(rec.w_tax_id) ||
                 g_seperator || replace_seperator(rec.g_g_code_output);
        out_msg(l_msg);
        -- utl_file.put_line(l_fhandler, l_msg);
      END LOOP;
      -- utl_file.fclose(l_fhandler);
    END IF;
  END generate_hfg_file;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_site_contract
  *   DESCRIPTION:
  *           get site contact information,
              if contact point type is "PHONE",
              line type has "FAX", "GEN", "MOBILE"
  *   HISTORY:
  *     1.00 2014-07-31 Jia
  *
  * =============================================*/
  FUNCTION get_site_contract(p_party_site_id      IN NUMBER,
                             p_contact_point_type IN VARCHAR2,
                             p_line_type          IN VARCHAR2)
    RETURN VARCHAR2 IS
    CURSOR cur IS
      SELECT hcp.phone_country_code,
             decode(hcp.phone_country_code,
                    '',
                    hcp.phone_area_code,
                    decode(hcp.phone_area_code,
                           '',
                           NULL,
                           '-' || hcp.phone_area_code)) phone_area_code,
             decode(hcp.phone_country_code || hcp.phone_area_code,
                    '',
                    hcp.phone_number,
                    decode(hcp.phone_number,
                           '',
                           NULL,
                           '-' || hcp.phone_number)) phone_number,
             decode(hcp.phone_extension,
                    '',
                    NULL,
                    '-' || hcp.phone_extension) phone_extension
        FROM hz_contact_points hcp
       WHERE hcp.contact_point_type = p_contact_point_type
         AND hcp.status = 'A'
         AND hcp.owner_table_name = 'HZ_PARTY_SITES'
         AND hcp.owner_table_id = p_party_site_id
         AND hcp.phone_line_type = p_line_type;
    /*SELECT decode(hcp.phone_country_code,
                 '',
                 NULL,
                 hcp.phone_country_code || '-') phone_country_code
         ,decode(hcp.phone_area_code,
                 '',
                 NULL,
                 hcp.phone_area_code || '-') phone_area_code
         ,decode(hcp.phone_number, '', NULL, hcp.phone_number || '-') phone_number
         ,hcp.phone_extension
     FROM hz_contact_points hcp
    WHERE hcp.contact_point_type = p_contact_point_type
      AND hcp.status = 'A'
      AND hcp.owner_table_name = 'HZ_PARTY_SITES'
      AND hcp.owner_table_id = p_party_site_id
      AND hcp.phone_line_type = p_line_type;*/
    l_rec cur%ROWTYPE;
  BEGIN
    OPEN cur;
    FETCH cur
      INTO l_rec;
    CLOSE cur;

    RETURN(l_rec.phone_country_code || l_rec.phone_area_code ||
           l_rec.phone_number || l_rec.phone_extension);
  END get_site_contract;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_site_cont_last_update
  *   DESCRIPTION:
  *              get_site_cont_last_update
  *   HISTORY:
  *     1.00 2014-07-31 Jia
  *
  * =============================================*/
  FUNCTION get_site_cont_last_update(p_party_site_id      IN NUMBER,
                                     p_contact_point_type IN VARCHAR2,
                                     p_line_type          IN VARCHAR2)
    RETURN DATE IS
    CURSOR cur IS
      SELECT last_update_date
        FROM hz_contact_points hcp
       WHERE hcp.contact_point_type = p_contact_point_type
         AND hcp.status = 'A'
         AND hcp.owner_table_name = 'HZ_PARTY_SITES'
         AND hcp.owner_table_id = p_party_site_id
         AND hcp.phone_line_type = p_line_type;

    l_rec cur%ROWTYPE;
  BEGIN
    OPEN cur;
    FETCH cur
      INTO l_rec;
    CLOSE cur;

    RETURN l_rec.last_update_date;
  END get_site_cont_last_update;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_site_email
  *   DESCRIPTION:
  *              get_site_email
  *   HISTORY:
  *     1.00 2014-07-31 Jia
  *
  * =============================================*/
  FUNCTION get_site_email(p_party_site_id IN NUMBER) RETURN VARCHAR2 IS
    CURSOR cur IS
      SELECT hcp.email_address
        FROM hz_contact_points hcp
       WHERE hcp.contact_point_type = 'EMAIL'
         AND hcp.status = 'A'
         AND hcp.owner_table_name = 'HZ_PARTY_SITES'
         AND hcp.owner_table_id = p_party_site_id;
    l_rec cur%ROWTYPE;
  BEGIN
    OPEN cur;
    FETCH cur
      INTO l_rec;
    CLOSE cur;

    RETURN(l_rec.email_address);
  END get_site_email;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  get_site_email_last_update
  *   DESCRIPTION:
  *              get_site_email_last_update
  *   HISTORY:
  *     1.00 2014-07-31 Jia
  *
  * =============================================*/
  FUNCTION get_site_email_last_update(p_party_site_id IN NUMBER) RETURN DATE IS
    CURSOR cur IS
      SELECT hcp.last_update_date
        FROM hz_contact_points hcp
       WHERE hcp.contact_point_type = 'EMAIL'
         AND hcp.status = 'A'
         AND hcp.owner_table_name = 'HZ_PARTY_SITES'
         AND hcp.owner_table_id = p_party_site_id;
    l_rec cur%ROWTYPE;
  BEGIN
    OPEN cur;
    FETCH cur
      INTO l_rec;
    CLOSE cur;

    RETURN(l_rec.last_update_date);
  END get_site_email_last_update;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  validate_required
  *   DESCRIPTION:
  *              validate_required
  *   HISTORY:
  *     1.00 2014-07-31 Jia
  *
  * =============================================*/
  PROCEDURE validate_required(p_int_rec IN OUT NOCOPY xxar_cust_to_hfg_int%ROWTYPE) IS
  BEGIN
    --2.00 add start
    IF nvl(p_int_rec.customer_number,'-1') = nvl(g_blank_char,'-1') THEN--baobao.hu add nvl at 20180816
      p_int_rec.process_status  := fnd_api.g_ret_sts_error;
      p_int_rec.process_message := substr(p_int_rec.process_message ||
                                          'Customer Number field is required. ',
                                          1,
                                          g_max_length);
    END IF;
    --2.00 add end

    IF nvl(p_int_rec.company_code,'-1') = nvl(g_blank_char,'-1') THEN--baobao.hu add nvl at 20180816
      p_int_rec.process_status  := fnd_api.g_ret_sts_error;
      p_int_rec.process_message := substr(p_int_rec.process_message ||
                                          'Company Code field is required. ',
                                          1,
                                          g_max_length);
    END IF;
    --2.00 add start
    IF nvl(p_int_rec.account_group,'-1') = nvl(g_blank_char,'-1') THEN--baobao.hu add nvl at 20180816
      p_int_rec.process_status  := fnd_api.g_ret_sts_error;
      p_int_rec.process_message := substr(p_int_rec.process_message ||
                                          'Account Group field is required. ',
                                          1,
                                          g_max_length);
    END IF;
    --2.00 add end

    IF nvl(p_int_rec.name1,'-1') = nvl(g_blank_char,'-1') THEN--baobao.hu add nvl at 20180816
      p_int_rec.process_status  := fnd_api.g_ret_sts_error;
      p_int_rec.process_message := substr(p_int_rec.process_message ||
                                          'Name1 field is required. ',
                                          1,
                                          g_max_length);
    END IF;

    IF nvl(p_int_rec.country,'-1') = nvl(g_blank_char,'-1') THEN--baobao.hu add nvl at 20180816
      p_int_rec.process_status  := fnd_api.g_ret_sts_error;
      p_int_rec.process_message := substr(p_int_rec.process_message ||
                                          'Country field is required. ',
                                          1,
                                          g_max_length);
    END IF;

    IF nvl(p_int_rec.recon_account,'-1') = nvl(g_blank_char,'-1') THEN--baobao.hu add nvl at 20180816
      p_int_rec.process_status  := fnd_api.g_ret_sts_error;
      p_int_rec.process_message := substr(p_int_rec.process_message ||
                                          'Recon.account field is required. ',
                                          1,
                                          g_max_length);
    END IF;
    --2.00 add start
    IF nvl(p_int_rec.language,'-1') = nvl(g_blank_char,'-1') THEN--baobao.hu add nvl at 20180816
      p_int_rec.process_status  := fnd_api.g_ret_sts_error;
      p_int_rec.process_message := substr(p_int_rec.process_message ||
                                          'Language field is required. ',
                                          1,
                                          g_max_length);
    END IF;

    IF nvl(p_int_rec.g_g_code,'-1') = nvl(g_blank_char,'-1') THEN--baobao.hu add nvl at 20180816
      p_int_rec.process_status  := fnd_api.g_ret_sts_error;
      p_int_rec.process_message := substr(p_int_rec.process_message ||
                                          'G&G code field is required. ',
                                          1,
                                          g_max_length);
    END IF;
  END validate_required;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  update_cust_to_hfg_int
  *   DESCRIPTION:
  *              update_cust_to_hfg_int
  *   HISTORY:
  *     1.00 2014-07-31 Jia
  *
  * =============================================*/
  PROCEDURE update_cust_to_hfg_int(p_cust_int_rec xxar_cust_to_hfg_int%ROWTYPE,
                                   p_unique_id    IN NUMBER) IS
    l_name1   VARCHAR2(105);
    l_name2   VARCHAR2(105);
    l_street  VARCHAR2(240);
    l_street4 VARCHAR2(120);
    l_street5 VARCHAR2(120);
    l_city    VARCHAR2(105); -- add by huangyan 2015-01-22
  BEGIN
    UPDATE xxar_cust_to_hfg_int xchi
    /*set xchi.customer_number       = p_cust_int_rec.customer_number,
     xchi.company_code          = p_cust_int_rec.company_code,
     xchi.account_group         = p_cust_int_rec.account_group,
     xchi.language              = p_cust_int_rec.language,
     xchi.name1                 = p_cust_int_rec.name1,
     xchi.name2                 = p_cust_int_rec.name2,
     xchi.search_term1          = p_cust_int_rec.search_term1,
     xchi.postal_code           = p_cust_int_rec.postal_code,
     xchi.city                  = p_cust_int_rec.city,
     xchi.street_house_number   = p_cust_int_rec.street_house_number,
     xchi.street4               = p_cust_int_rec.street4,
     xchi.street5               = p_cust_int_rec.street5,
     xchi.country               = p_cust_int_rec.country,
     xchi.telephone1            = p_cust_int_rec.telephone1,
     xchi.mobile_phone          = p_cust_int_rec.mobfile_phone,
     xchi.fax1                  = p_cust_int_rec.fax1,
     xchi.e_mail                = p_cust_int_rec.e_mail,
     xchi.recon_account         = p_cust_int_rec.recon_account,
     xchi.prev_acct_no          = p_cust_int_rec.prev_acct_no,
     xchi.withholding_tax_type  = p_cust_int_rec.withholding_tax_type,
     xchi.withholding_tax_agent = p_cust_int_rec.withholding_tax_agent,
     xchi.withholding_tax_from  = p_cust_int_rec.withholding_tax_from,
     xchi.withholdomg_tax_until = p_cust_int_rec.withholdomg_tax_until,
     xchi.group_id              = p_cust_int_rec.group_id,
     xchi.org_id                = p_cust_int_rec.org_id,
     xchi.site_use_id           = p_cust_int_rec.site_use_id
     --,xchi.process_status        = 'P'
    ,
     xchi.object_version_number = p_cust_int_rec.object_version_number,
     --xchi.creation_date          = p_cust_int_rec.creation_date,
     --xchi.created_by             = p_cust_int_rec.created_by,
     xchi.last_update_date       = p_cust_int_rec.last_update_date,
     xchi.last_updated_by        = p_cust_int_rec.last_updated_by,
     xchi.last_update_login      = p_cust_int_rec.last_update_login,
     xchi.program_id             = p_cust_int_rec.program_id,
     xchi.request_id             = p_cust_int_rec.request_id,
     xchi.program_application_id = p_cust_int_rec.program_application_id,
     xchi.g_g_code               = g_blank_char,
     xchi.new_customer_flag      = p_cust_int_rec.new_customer_flag,
     xchi.cust_last_update_date  = p_cust_int_rec.cust_last_update_date,
     xchi.interface_file_name    = p_cust_int_rec.interface_file_name,
     xchi.rerun_flag             = p_cust_int_rec.rerun_flag,
     xchi.ledger_name            = p_cust_int_rec.ledger_name*/
       SET xchi.customer_number               = p_cust_int_rec.customer_number,
           xchi.company_code                  = p_cust_int_rec.company_code,
           xchi.account_group                 = p_cust_int_rec.account_group,
           xchi.title                         = p_cust_int_rec.title,
           xchi.name1                         = p_cust_int_rec.name1,
           xchi.name2                         = p_cust_int_rec.name2,
           xchi.name3                         = p_cust_int_rec.name3,
           xchi.name4                         = p_cust_int_rec.name4,
           xchi.search_term1                  = p_cust_int_rec.search_term1,
           xchi.street2                       = p_cust_int_rec.street2,
           xchi.street3                       = p_cust_int_rec.street3,
           xchi.street                        = p_cust_int_rec.street,
           xchi.house_number                  = p_cust_int_rec.house_number,
           xchi.supplement                    = p_cust_int_rec.supplement,
           xchi.street4                       = p_cust_int_rec.street4,
           xchi.street5                       = p_cust_int_rec.street5,
           xchi.district                      = p_cust_int_rec.district,
           xchi.different_city                = p_cust_int_rec.different_city,
           xchi.city                          = p_cust_int_rec.city,
           xchi.postal_code                   = p_cust_int_rec.postal_code,
           xchi.country                       = p_cust_int_rec.country,
           xchi.region                        = p_cust_int_rec.region,
           xchi.time_zone                     = p_cust_int_rec.time_zone,
           xchi.jurisdict_code                = p_cust_int_rec.jurisdict_code,
           xchi.transportation_zone           = p_cust_int_rec.transportation_zone,
           xchi.po_box                        = p_cust_int_rec.po_box,
           xchi.po_box_without_number         = p_cust_int_rec.po_box_without_number,
           xchi.delivery_serv                 = p_cust_int_rec.delivery_serv,
           xchi.delivery_service_number       = p_cust_int_rec.delivery_service_number,
           xchi.po_box_lobby                  = p_cust_int_rec.po_box_lobby,
           xchi.postal_code2                  = p_cust_int_rec.postal_code2,
           xchi.other_city                    = p_cust_int_rec.other_city,
           xchi.other_country                 = p_cust_int_rec.other_country,
           xchi.other_region                  = p_cust_int_rec.other_region,
           xchi.company_postal_code           = p_cust_int_rec.company_postal_code,
           xchi.language                      = p_cust_int_rec.language,
           xchi.telephone                     = p_cust_int_rec.telephone,
           xchi.extensio1                     = p_cust_int_rec.extensio1,
           xchi.mobile_phone                  = p_cust_int_rec.mobile_phone,
           xchi.fax                           = p_cust_int_rec.fax,
           xchi.fax1                          = p_cust_int_rec.fax1,
           xchi.extension2                    = p_cust_int_rec.extension2,
           xchi.e_mail                        = p_cust_int_rec.e_mail,
           xchi.standard_comm_mtd             = p_cust_int_rec.standard_comm_mtd,
           xchi.data_line                     = p_cust_int_rec.data_line,
           xchi.telebox                       = p_cust_int_rec.telebox,
           xchi.comments                      = p_cust_int_rec.comments,
           xchi.vendor                        = p_cust_int_rec.vendor,
           xchi.authorization1                = p_cust_int_rec.authorization1,
           xchi.corporate_group               = p_cust_int_rec.corporate_group,
           xchi.location_no_1                 = p_cust_int_rec.location_no_1,
           xchi.location_no_2                 = p_cust_int_rec.location_no_2,
           xchi.check_digit                   = p_cust_int_rec.check_digit,
           xchi.industry                      = p_cust_int_rec.industry,
           xchi.train_station                 = p_cust_int_rec.train_station,
           xchi.express_station               = p_cust_int_rec.express_station,
           xchi.location_code                 = p_cust_int_rec.location_code,
           xchi.tax_number_1                  = p_cust_int_rec.tax_number_1,
           xchi.tax_number_2                  = p_cust_int_rec.tax_number_2,
           xchi.tax_number_3                  = p_cust_int_rec.tax_number_3,
           xchi.tax_number_4                  = p_cust_int_rec.tax_number_4,
           xchi.tax_type                      = p_cust_int_rec.tax_type,
           xchi.tax_number_type               = p_cust_int_rec.tax_number_type,
           xchi.equalization_tax              = p_cust_int_rec.equalization_tax,
           xchi.natural_person                = p_cust_int_rec.natural_person,
           xchi.sales_pur_tax                 = p_cust_int_rec.sales_pur_tax,
           xchi.fiscal_address                = p_cust_int_rec.fiscal_address,
           xchi.county_code                   = p_cust_int_rec.county_code,
           xchi.vat_reg_no                    = p_cust_int_rec.vat_reg_no,
           xchi.city_code                     = p_cust_int_rec.city_code,
           xchi.icms_law                      = p_cust_int_rec.icms_law,
           xchi.ipi_law                       = p_cust_int_rec.ipi_law,
           xchi.cfop_category                 = p_cust_int_rec.cfop_category,
           xchi.subtrib_group                 = p_cust_int_rec.subtrib_group,
           xchi.icms_exempt                   = p_cust_int_rec.icms_exempt,
           xchi.ipi_exempt                    = p_cust_int_rec.ipi_exempt,
           xchi.rep_name                      = p_cust_int_rec.rep_name,
           xchi.type_of_business              = p_cust_int_rec.type_of_business,
           xchi.type_of_industry              = p_cust_int_rec.type_of_industry,
           xchi.bank_country                  = p_cust_int_rec.bank_country,
           xchi.bank_key                      = p_cust_int_rec.bank_key,
           xchi.bank_account                  = p_cust_int_rec.bank_account,
           xchi.acct_holder                   = p_cust_int_rec.acct_holder,
           xchi.control_key                   = p_cust_int_rec.control_key,
           xchi.iban                          = p_cust_int_rec.iban,
           xchi.valid_from                    = p_cust_int_rec.valid_from,
           xchi.partner_bank_type             = p_cust_int_rec.partner_bank_type,
           xchi.reference_specifications      = p_cust_int_rec.reference_specifications,
           xchi.collection_authorization      = p_cust_int_rec.collection_authorization,
           xchi.alternative_payee             = p_cust_int_rec.alternative_payee,
           xchi.dme_indicator                 = p_cust_int_rec.dme_indicator,
           xchi.instruction_key               = p_cust_int_rec.instruction_key,
           xchi.individual_spec               = p_cust_int_rec.individual_spec,
           xchi.recon_account                 = p_cust_int_rec.recon_account,
           xchi.sort_key                      = p_cust_int_rec.sort_key,
           xchi.head_office                   = p_cust_int_rec.head_office,
           xchi.preference_ind                = p_cust_int_rec.preference_ind,
           xchi.authorization2                = p_cust_int_rec.authorization2,
           xchi.release_group                 = p_cust_int_rec.release_group,
           xchi.value_adjustment              = p_cust_int_rec.value_adjustment,
           xchi.interest_indic                = p_cust_int_rec.interest_indic,
           xchi.last_key_date                 = p_cust_int_rec.last_key_date,
           xchi.interest_freq                 = p_cust_int_rec.interest_freq,
           xchi.last_interest_run             = p_cust_int_rec.last_interest_run,
           xchi.prev_acct_no                  = p_cust_int_rec.prev_acct_no,
           xchi.personnel_number              = p_cust_int_rec.personnel_number,
           xchi.buying_group                  = p_cust_int_rec.buying_group,
           xchi.activity_code                 = p_cust_int_rec.activity_code,
           xchi.distr_type                    = p_cust_int_rec.distr_type,
           xchi.terms_of_payment              = p_cust_int_rec.terms_of_payment,
           xchi.tolerance_group               = p_cust_int_rec.tolerance_group,
           xchi.cr_memo_terms                 = p_cust_int_rec.cr_memo_terms,
           xchi.known_neg_leave               = p_cust_int_rec.known_neg_leave,
           xchi.b_e_charges_payt_term         = p_cust_int_rec.b_e_charges_payt_term,
           xchi.ar_pledging_ind               = p_cust_int_rec.ar_pledging_ind,
           xchi.time_until_check_paid         = p_cust_int_rec.time_until_check_paid,
           xchi.payment_history_record        = p_cust_int_rec.payment_history_record,
           xchi.payment_methods               = p_cust_int_rec.payment_methods,
           xchi.payment_block                 = p_cust_int_rec.payment_block,
           xchi.alternat_payee                = p_cust_int_rec.alternat_payee,
           xchi.house_bank                    = p_cust_int_rec.house_bank,
           xchi.exch_limit                    = p_cust_int_rec.exch_limit,
           xchi.group_key                     = p_cust_int_rec.group_key,
           xchi.single_payment                = p_cust_int_rec.single_payment,
           xchi.clearing_with_vendor          = p_cust_int_rec.clearing_with_vendor,
           xchi.edi                           = p_cust_int_rec.edi,
           xchi.pmtadv_xml                    = p_cust_int_rec.pmtadv_xml,
           xchi.different_payer_in_document   = p_cust_int_rec.different_payer_in_document,
           xchi.next_payee                    = p_cust_int_rec.next_payee,
           xchi.lockbox                       = p_cust_int_rec.lockbox,
           xchi.rsn_code_conv                 = p_cust_int_rec.rsn_code_conv,
           xchi.selection_rule                = p_cust_int_rec.selection_rule,
           xchi.dunn_procedure                = p_cust_int_rec.dunn_procedure,
           xchi.dunning_block                 = p_cust_int_rec.dunning_block,
           xchi.dunn_recipient                = p_cust_int_rec.dunn_recipient,
           xchi.leg_dunn_proc                 = p_cust_int_rec.leg_dunn_proc,
           xchi.last_dunned                   = p_cust_int_rec.last_dunned,
           xchi.dunning_level                 = p_cust_int_rec.dunning_level,
           xchi.dunning_clerk                 = p_cust_int_rec.dunning_clerk,
           xchi.grouping_key2                 = p_cust_int_rec.grouping_key2,
           xchi.acctg_clerk                   = p_cust_int_rec.acctg_clerk,
           xchi.account_statement             = p_cust_int_rec.account_statement,
           xchi.acct_at_cust                  = p_cust_int_rec.acct_at_cust,
           xchi.coll_invoice_variant          = p_cust_int_rec.coll_invoice_variant,
           xchi.customer_user                 = p_cust_int_rec.customer_user,
           xchi.local_processing              = p_cust_int_rec.local_processing,
           xchi.act_clk_tel_no                = p_cust_int_rec.act_clk_tel_no,
           xchi.clerk_fax                     = p_cust_int_rec.clerk_fax,
           xchi.clrk_internet                 = p_cust_int_rec.clrk_internet,
           xchi.account_memo                  = p_cust_int_rec.account_memo,
           xchi.payment_notice_cleared_itm    = p_cust_int_rec.payment_notice_cleared_itm,
           xchi.payment_notice_sales_dpt      = p_cust_int_rec.payment_notice_sales_dpt,
           xchi.payment_notice_legal_dpt      = p_cust_int_rec.payment_notice_legal_dpt,
           xchi.payment_notice_wo_cleared_itm = p_cust_int_rec.payment_notice_wo_cleared_itm,
           xchi.payment_notice_acc_dpt        = p_cust_int_rec.payment_notice_acc_dpt,
           xchi.withholding_tax_country_key   = p_cust_int_rec.withholding_tax_country_key,
           xchi.withholding_tax_type          = p_cust_int_rec.withholding_tax_type,
           xchi.withholding_tax_code          = p_cust_int_rec.withholding_tax_code,
           xchi.subject_to_withholding_tax    = p_cust_int_rec.subject_to_withholding_tax,
           xchi.obligated_to_wh_tax_from      = p_cust_int_rec.obligated_to_wh_tax_from,
           xchi.obligated_to_wh_tax_until     = p_cust_int_rec.obligated_to_wh_tax_until,
           xchi.w_tax_id                      = p_cust_int_rec.w_tax_id,
           xchi.g_g_code                      = g_blank_char, --p_cust_int_rec.g_g_code,
           xchi.ledger_name                   = p_cust_int_rec.ledger_name,
           xchi.street_house_number           = p_cust_int_rec.street_house_number,
           xchi.telephone1                    = p_cust_int_rec.telephone1,
           xchi.withholding_tax_agent         = p_cust_int_rec.withholding_tax_agent,
           xchi.withholding_tax_from          = p_cust_int_rec.withholding_tax_from,
           xchi.withholdomg_tax_until         = p_cust_int_rec.withholdomg_tax_until,
           xchi.group_id                      = p_cust_int_rec.group_id,
           xchi.org_id                        = p_cust_int_rec.org_id,
           xchi.site_use_id                   = p_cust_int_rec.site_use_id,
           xchi.object_version_number         = p_cust_int_rec.object_version_number,
           xchi.last_update_date              = p_cust_int_rec.last_update_date,
           xchi.last_updated_by               = p_cust_int_rec.last_updated_by,
           xchi.last_update_login             = p_cust_int_rec.last_update_login,
           xchi.program_id                    = p_cust_int_rec.program_id,
           xchi.request_id                    = p_cust_int_rec.request_id,
           xchi.program_application_id        = p_cust_int_rec.program_application_id,
           xchi.new_customer_flag             = p_cust_int_rec.new_customer_flag,
           xchi.cust_last_update_date         = p_cust_int_rec.cust_last_update_date,
           xchi.rerun_flag                    = p_cust_int_rec.rerun_flag,
           xchi.interface_file_name           = p_cust_int_rec.interface_file_name
     WHERE xchi.unique_id = p_unique_id;

  END;
  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  set_miss_rec
  *   DESCRIPTION:
  *              set_miss_rec
  *   HISTORY:
  *     1.00 2014-07-31 Jia
  *
  * =============================================*/
  PROCEDURE set_miss_rec IS
  BEGIN
    g_miss_rec.customer_number               := g_blank_char;
    g_miss_rec.company_code                  := g_blank_char;
    g_miss_rec.account_group                 := g_blank_char;
    g_miss_rec.title                         := g_blank_char;
    g_miss_rec.name1                         := g_blank_char;
    g_miss_rec.name2                         := g_blank_char;
    g_miss_rec.name3                         := g_blank_char;
    g_miss_rec.name4                         := g_blank_char;
    g_miss_rec.search_term1                  := g_blank_char;
    g_miss_rec.street2                       := g_blank_char;
    g_miss_rec.street3                       := g_blank_char;
    g_miss_rec.street                        := g_blank_char; --2.00 add
    g_miss_rec.house_number                  := g_blank_char;
    g_miss_rec.supplement                    := g_blank_char;
    g_miss_rec.street4                       := g_blank_char;
    g_miss_rec.street5                       := g_blank_char;
    g_miss_rec.district                      := g_blank_char; --2.00 add
    g_miss_rec.different_city                := g_blank_char; --2.00 add
    g_miss_rec.city                          := g_blank_char;
    g_miss_rec.postal_code                   := g_blank_char;
    g_miss_rec.country                       := g_blank_char;
    g_miss_rec.region                        := g_blank_char;
    g_miss_rec.time_zone                     := g_blank_char;
    g_miss_rec.jurisdict_code                := g_blank_char; --2.00 add
    g_miss_rec.transportation_zone           := g_blank_char; --2.00 add
    g_miss_rec.po_box                        := g_blank_char; --2.00 add
    g_miss_rec.po_box_without_number         := g_blank_char; --2.00 add
    g_miss_rec.delivery_serv                 := g_blank_char; --2.00 add
    g_miss_rec.delivery_service_number       := g_blank_char; --2.00 add
    g_miss_rec.po_box_lobby                  := g_blank_char; --2.00 add
    g_miss_rec.postal_code2                  := g_blank_char; --2.00 add
    g_miss_rec.other_city                    := g_blank_char; --2.00 add
    g_miss_rec.other_country                 := g_blank_char; --2.00 add
    g_miss_rec.other_region                  := g_blank_char; --2.00 add
    g_miss_rec.company_postal_code           := g_blank_char;
    g_miss_rec.language                      := g_blank_char;
    g_miss_rec.telephone                     := g_blank_char; --2.00 add
    g_miss_rec.extensio1                     := g_blank_char; --2.00 add
    g_miss_rec.mobile_phone                  := g_blank_char;
    g_miss_rec.fax                           := g_blank_char; --2.00 add
    g_miss_rec.extension2                    := g_blank_char; --2.00 add
    g_miss_rec.e_mail                        := g_blank_char;
    g_miss_rec.standard_comm_mtd             := g_blank_char; --2.00 add
    g_miss_rec.data_line                     := g_blank_char; --2.00 add
    g_miss_rec.telebox                       := g_blank_char; --2.00 add
    g_miss_rec.comments                      := g_blank_char;
    g_miss_rec.vendor                        := g_blank_char;
    g_miss_rec.authorization1                := g_blank_char;
    g_miss_rec.corporate_group               := g_blank_char; --2.00 add
    g_miss_rec.location_no_1                 := g_blank_char; --2.00 add
    g_miss_rec.location_no_2                 := g_blank_char; --2.00 add
    g_miss_rec.check_digit                   := g_blank_char; --2.00 add
    g_miss_rec.industry                      := g_blank_char;
    g_miss_rec.train_station                 := g_blank_char;
    g_miss_rec.express_station               := g_blank_char;
    g_miss_rec.location_code                 := g_blank_char;
    g_miss_rec.tax_number_1                  := g_blank_char; --2.00 add
    g_miss_rec.tax_number_2                  := g_blank_char; --2.00 add
    g_miss_rec.tax_number_3                  := g_blank_char; --2.00 add
    g_miss_rec.tax_number_4                  := g_blank_char; --2.00 add
    g_miss_rec.tax_type                      := g_blank_char; --2.00 add
    g_miss_rec.tax_number_type               := g_blank_char; --2.00 add
    g_miss_rec.equalization_tax              := g_blank_char;
    g_miss_rec.natural_person                := g_blank_char;
    g_miss_rec.sales_pur_tax                 := g_blank_char;
    g_miss_rec.fiscal_address                := g_blank_char;
    g_miss_rec.county_code                   := g_blank_char; --2.00 add
    g_miss_rec.vat_reg_no                    := g_blank_char;
    g_miss_rec.city_code                     := g_blank_char; --2.00 add
    g_miss_rec.icms_law                      := g_blank_char; --2.00 add
    g_miss_rec.ipi_law                       := g_blank_char; --2.00 add
    g_miss_rec.cfop_category                 := g_blank_char; --2.00 add
    g_miss_rec.subtrib_group                 := g_blank_char; --2.00 add
    g_miss_rec.icms_exempt                   := g_blank_char; --2.00 add
    g_miss_rec.ipi_exempt                    := g_blank_char; --2.00 add
    g_miss_rec.rep_name                      := g_blank_char; --2.00 add
    g_miss_rec.type_of_business              := g_blank_char;
    g_miss_rec.type_of_industry              := g_blank_char;
    g_miss_rec.bank_country                  := g_blank_char;
    g_miss_rec.bank_key                      := g_blank_char;
    g_miss_rec.bank_account                  := g_blank_char;
    g_miss_rec.acct_holder                   := g_blank_char; --2.00 add
    g_miss_rec.control_key                   := g_blank_char;
    g_miss_rec.iban                          := g_blank_char; --2.00 add
    g_miss_rec.valid_from                    := g_blank_char; --2.00 add
    g_miss_rec.partner_bank_type             := g_blank_char; --2.00 add
    g_miss_rec.reference_specifications      := g_blank_char; --2.00 add
    g_miss_rec.collection_authorization      := g_blank_char; --2.00 add
    g_miss_rec.alternative_payee             := g_blank_char; --2.00 add
    g_miss_rec.dme_indicator                 := g_blank_char;
    g_miss_rec.instruction_key               := g_blank_char;
    g_miss_rec.individual_spec               := g_blank_char; --2.00 add
    g_miss_rec.recon_account                 := g_blank_char;
    g_miss_rec.sort_key                      := g_blank_char;
    g_miss_rec.head_office                   := g_blank_char;
    g_miss_rec.preference_ind                := g_blank_char; --2.00 add
    g_miss_rec.authorization2                := g_blank_char;
    g_miss_rec.release_group                 := g_blank_char;
    g_miss_rec.value_adjustment              := g_blank_char;
    g_miss_rec.interest_indic                := g_blank_char;
    g_miss_rec.last_key_date                 := g_blank_char;
    g_miss_rec.interest_freq                 := g_blank_char; --2.00 add
    g_miss_rec.last_interest_run             := g_blank_char;
    g_miss_rec.prev_acct_no                  := g_blank_char;
    g_miss_rec.personnel_number              := g_blank_char;
    g_miss_rec.buying_group                  := g_blank_char;
    g_miss_rec.activity_code                 := g_blank_char; --2.00 add
    g_miss_rec.distr_type                    := g_blank_char; --2.00 add
    g_miss_rec.terms_of_payment              := g_blank_char;
    g_miss_rec.tolerance_group               := g_blank_char;
    g_miss_rec.cr_memo_terms                 := g_blank_char; --2.00 add
    g_miss_rec.known_neg_leave               := g_blank_char;
    g_miss_rec.b_e_charges_payt_term         := g_blank_char; --2.00 add
    g_miss_rec.ar_pledging_ind               := g_blank_char; --2.00 add
    g_miss_rec.time_until_check_paid         := g_blank_char; --2.00 add
    g_miss_rec.payment_history_record        := g_blank_char; --2.00 add
    g_miss_rec.payment_methods               := g_blank_char;
    g_miss_rec.payment_block                 := g_blank_char;
    g_miss_rec.alternat_payee                := g_blank_char; --2.00 add
    g_miss_rec.house_bank                    := g_blank_char;
    g_miss_rec.exch_limit                    := g_blank_char;
    g_miss_rec.group_key                     := g_blank_char;
    g_miss_rec.single_payment                := g_blank_char;
    g_miss_rec.clearing_with_vendor          := g_blank_char;
    g_miss_rec.edi                           := g_blank_char; --2.00 add
    g_miss_rec.pmtadv_xml                    := g_blank_char; --2.00 add
    g_miss_rec.different_payer_in_document   := g_blank_char; --2.00 add
    g_miss_rec.next_payee                    := g_blank_char; --2.00 add
    g_miss_rec.lockbox                       := g_blank_char; --2.00 add
    g_miss_rec.rsn_code_conv                 := g_blank_char;
    g_miss_rec.selection_rule                := g_blank_char;
    g_miss_rec.dunn_procedure                := g_blank_char;
    g_miss_rec.dunning_block                 := g_blank_char;
    g_miss_rec.dunn_recipient                := g_blank_char;
    g_miss_rec.leg_dunn_proc                 := g_blank_char;
    g_miss_rec.last_dunned                   := g_blank_char;
    g_miss_rec.dunning_level                 := g_blank_char;
    g_miss_rec.dunning_clerk                 := g_blank_char;
    g_miss_rec.grouping_key2                 := g_blank_char;
    g_miss_rec.acctg_clerk                   := g_blank_char;
    g_miss_rec.account_statement             := g_blank_char;
    g_miss_rec.acct_at_cust                  := g_blank_char;
    g_miss_rec.coll_invoice_variant          := g_blank_char;
    g_miss_rec.customer_user                 := g_blank_char;
    g_miss_rec.local_processing              := g_blank_char;
    g_miss_rec.act_clk_tel_no                := g_blank_char;
    g_miss_rec.clerk_fax                     := g_blank_char;
    g_miss_rec.clrk_internet                 := g_blank_char;
    g_miss_rec.account_memo                  := g_blank_char;
    g_miss_rec.payment_notice_cleared_itm    := g_blank_char; --2.00 add
    g_miss_rec.payment_notice_sales_dpt      := g_blank_char; --2.00 add
    g_miss_rec.payment_notice_legal_dpt      := g_blank_char; --2.00 add
    g_miss_rec.payment_notice_wo_cleared_itm := g_blank_char; --2.00 add
    g_miss_rec.payment_notice_acc_dpt        := g_blank_char; --2.00 add
    g_miss_rec.withholding_tax_country_key   := g_blank_char; --2.00 add
    g_miss_rec.withholding_tax_type          := g_blank_char;
    g_miss_rec.withholding_tax_code          := g_blank_char;
    g_miss_rec.subject_to_withholding_tax    := g_blank_char; --2.00 add
    g_miss_rec.obligated_to_wh_tax_from      := g_blank_char; --2.00 add
    g_miss_rec.obligated_to_wh_tax_until     := g_blank_char; --2.00 add
    g_miss_rec.w_tax_id                      := g_blank_char; --2.00 add
    g_miss_rec.g_g_code                      := g_blank_char; --2.00 add
    g_miss_rec.ledger_name                   := g_blank_char;

    -- 3.00 2015-11-22 Jinlong.Pan Update Begin
    /*g_miss_rec.deletion_flag        := g_blank_char;
    g_miss_rec.co_cde_deletion_flag := g_blank_char;
    g_miss_rec.posting_block        := g_blank_char;
    g_miss_rec.co_code_post_block   := g_blank_char;
    g_miss_rec.ecc_no               := g_blank_char;
    g_miss_rec.excise_reg_no        := g_blank_char;
    g_miss_rec.excise_range         := g_blank_char;
    g_miss_rec.excise_division      := g_blank_char;
    g_miss_rec.commissionerate      := g_blank_char;
    g_miss_rec.exc_ind_cust         := g_blank_char;
    g_miss_rec.cst_no               := g_blank_char;
    g_miss_rec.lst_no               := g_blank_char;
    g_miss_rec.service_tax_regn_no  := g_blank_char;
    g_miss_rec.pan                  := g_blank_char;
    g_miss_rec.pan_reference        := g_blank_char;
    g_miss_rec.branch_code          := g_blank_char;
    g_miss_rec.default_branch       := g_blank_char;
    g_miss_rec.branch_description   := g_blank_char;*/
    -- 3.00 2015-11-22 Jinlong.Pan Update End
    --2.00 del
    /*   g_miss_rec.search_term2              := g_blank_char;

    g_miss_rec.street_house_number       := g_blank_char;

    g_miss_rec.postal_code1              := g_blank_char;

    g_miss_rec.box                       := g_blank_char;
    g_miss_rec.telephone1                := g_blank_char;
    g_miss_rec.telephone2                := g_blank_char;

    g_miss_rec.fax1                      := g_blank_char;
    g_miss_rec.fax2                      := g_blank_char;

    g_miss_rec.standard_comm_type        := g_blank_char;

    g_miss_rec.trading_partner           := g_blank_char;

    g_miss_rec.location_no               := g_blank_char;

    g_miss_rec.tax_code1                 := g_blank_char;

    g_miss_rec.tax_code2                 := g_blank_char;

    g_miss_rec.account_hold              := g_blank_char;

    g_miss_rec.bank_type                 := g_blank_char;
    g_miss_rec.reference_details         := g_blank_char;
    g_miss_rec.collect_authority         := g_blank_char;
    g_miss_rec.bank_line_item_no         := g_blank_char;
    g_miss_rec.alternative_payer         := g_blank_char;
    g_miss_rec.alternative_payer_allowed := g_blank_char;

    g_miss_rec.nielsen_id                := g_blank_char;
    g_miss_rec.regional_market           := g_blank_char;
    g_miss_rec.classification            := g_blank_char;
    g_miss_rec.industry_code1            := g_blank_char;
    g_miss_rec.annual_sales              := g_blank_char;
    g_miss_rec.currency_of_sales         := g_blank_char;
    g_miss_rec.year_sales                := g_blank_char;
    g_miss_rec.yearly                    := g_blank_char;
    g_miss_rec.year_employees            := g_blank_char;
    g_miss_rec.fiscal_year_variant       := g_blank_char;
    g_miss_rec.legal_status              := g_blank_char;
    g_miss_rec.unloading_point           := g_blank_char;
    g_miss_rec.default_unloading_point   := g_blank_char;
    g_miss_rec.factory_calendar          := g_blank_char;
    g_miss_rec.country_key               := g_blank_char;

    g_miss_rec.export_control1           := g_blank_char;
    g_miss_rec.export_control2           := g_blank_char;
    g_miss_rec.export_control3           := g_blank_char;
    g_miss_rec.export_control4           := g_blank_char;
    g_miss_rec.export_control5           := g_blank_char;
    g_miss_rec.export_control6           := g_blank_char;
    g_miss_rec.non_military_use          := g_blank_char;
    g_miss_rec.legal_control1            := g_blank_char;
    g_miss_rec.legal_control2            := g_blank_char;
    g_miss_rec.legal_control3            := g_blank_char;
    g_miss_rec.legal_control4            := g_blank_char;
    g_miss_rec.name                      := g_blank_char;
    g_miss_rec.first_name                := g_blank_char;
    g_miss_rec.person_department         := g_blank_char;
    g_miss_rec.function                  := g_blank_char;

    g_miss_rec.cash_management_group     := g_blank_char;

    g_miss_rec.interest_cycle            := g_blank_char;

    g_miss_rec.charges_payt_term         := g_blank_char;
    g_miss_rec.ar_factor                 := g_blank_char;
    g_miss_rec.time_until                := g_blank_char;
    g_miss_rec.payment_history           := g_blank_char;

    g_miss_rec.alternat_payer            := g_blank_char;

    g_miss_rec.grouping_key1             := g_blank_char;

    g_miss_rec.customer_ci               := g_blank_char;
    g_miss_rec.sales                     := g_blank_char;
    g_miss_rec.legal_requirement         := g_blank_char;
    g_miss_rec.customer_wo               := g_blank_char;
    g_miss_rec.insurance_number          := g_blank_char;
    g_miss_rec.institution_number        := g_blank_char;
    g_miss_rec.amount_insured            := g_blank_char;
    g_miss_rec.valid_until               := g_blank_char;
    g_miss_rec.lead_months               := g_blank_char;
    g_miss_rec.deductible                := g_blank_char;

    g_miss_rec.withholding_tax_agent     := g_blank_char;
    g_miss_rec.withholding_tax_from      := g_blank_char;
    g_miss_rec.withholdomg_tax_until     := g_blank_char;
    g_miss_rec.withholding_tax_id        := g_blank_char;

    g_miss_rec.representative            := g_blank_char;*/
    --2.00 del

  END set_miss_rec;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :  hfg_process_request
  *   DESCRIPTION:
  *              hfg_process_request
  *   HISTORY:
  *     1.00 2014-07-31 Jia
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
    CURSOR cur_hfg IS
      SELECT acct.attribute5,
             acct.account_number,
             hp.party_name,
             hp.duns_number_c legacy_customer_number,
             h_status.meaning cust_status,
             hou.name ou_name,
             ps.party_site_number site_number,
             s_status.meaning site_status,
             lc.country country_code,
             ft.territory_short_name country,
             lc.address1,
             lc.address2,
             lc.address3,
             lc.city,
             lc.county,
             lc.province,
             lc.state,
             lc.postal_code,
             uses.site_use_code business_purposes,
             uses.tax_code tax,
             xhs.company_code,
             decode(upper(gl.name),
                    'SHE LEDGER',
                    'R1',
                    'HET LEDGER',
                    'R1',
                    NULL) wht_type,
             decode(upper(gl.name),
                    'SHE LEDGER',
                    'X',
                    'HET LEDGER',
                    'X',
                    NULL) wht_agent,
             decode(upper(gl.name),
                    'SHE LEDGER',
                    '20120101',
                    'HET LEDGER',
                    '20120101',
                    NULL) wht_from,
             decode(upper(gl.name),
                    'SHE LEDGER',
                    '99991231',
                    'HET LEDGER',
                    '99991231',
                    NULL) wht_until,
             gcc.segment3,
             rt.segment1 || '.' || rt.segment2 sales_territory,
             -- res.resource_name sales_person,
             (SELECT DISTINCT res.resource_name
                FROM jtf_rs_salesreps jrs, jtf_rs_resource_extns_vl res
               WHERE jrs.resource_id = res.resource_id(+)
                 AND jrs.salesrep_id = uses.primary_salesrep_id
                 AND rownum = 1) sales_person,
             rtt.name payment_terms,
             ship_method.meaning ship_method,
             hp.party_id,
             sites.org_id,
             acct.cust_account_id,
             sites.cust_acct_site_id,
             ps.party_site_id,
             uses.site_use_id,
             greatest(hp.last_update_date,
                      acct.last_update_date,
                      sites.last_update_date,
                      uses.last_update_date,
                      ps.last_update_date,
                      lc.last_update_date,
                      nvl(get_site_cont_last_update(ps.party_site_id,
                                                    'PHONE',
                                                    'GEN'),
                          hp.last_update_date),
                      nvl(get_site_cont_last_update(ps.party_site_id,
                                                    'PHONE',
                                                    'FAX'),
                          hp.last_update_date),
                      nvl(get_site_cont_last_update(ps.party_site_id,
                                                    'PHONE',
                                                    'MOBILE'),
                          hp.last_update_date),
                      nvl(get_site_email_last_update(ps.party_site_id),
                          hp.last_update_date)) cust_last_update_date,
             -- update by shengxiang.fan 2015-06-18  start
             (SELECT MAX(unique_id)
              --update by shengxiang.fan 2015-06-18    end
                FROM xxar_cust_to_hfg_int xcth
               WHERE xcth.customer_number = acct.account_number
                 AND xcth.site_use_id = uses.site_use_id) unique_id,
             -- 3.00 2015-11-22 Jinlong.Pan Update Begin
             ps.attribute3 tax_id,
             ps.attribute4 branch_number,
             ps.attribute5 branch_code

      /*
      decode(upper(gl.name), 'SHE LEDGER', ps.attribute3, NULL) tax_id,
      decode(upper(gl.name), 'SHE LEDGER', ps.attribute4, NULL) branch_number,
      decode(upper(gl.name), 'SHE LEDGER', nvl(ps.attribute5, '99999'), NULL) branch_code
      */
      -- 3.00 2015-11-22 Jinlong.Pan Update End

        FROM apps.hz_parties             hp,
             apps.hz_cust_accounts       acct,
             apps.hz_cust_acct_sites_all sites,
             apps.hz_cust_site_uses_all  uses,
             apps.hz_party_sites         ps,
             apps.hz_locations           lc,
             apps.hr_operating_units     hou,
             fnd_lookup_values           h_status,
             fnd_lookup_values           s_status,
             fnd_territories_vl          ft,
             gl_code_combinations        gcc,
             xxgl_hfs_system_options     xhs,
             gl_ledgers                  gl,
             ra_territories              rt,
             /*jtf_rs_salesreps            jrs,
             jtf_rs_resource_extns_vl    res,*/
             ra_terms_tl       rtt,
             fnd_lookup_values ship_method
       WHERE hp.party_id = acct.party_id
         AND acct.cust_account_id = sites.cust_account_id
         AND sites.cust_acct_site_id = uses.cust_acct_site_id(+)
         AND sites.party_site_id = ps.party_site_id(+)
         AND ps.location_id = lc.location_id(+)
         AND sites.org_id = hou.organization_id(+)
         AND acct.status = h_status.lookup_code
         AND h_status.lookup_type = 'HZ_CPUI_REGISTRY_STATUS'
         AND h_status.language = userenv('LANG')
         AND sites.status = s_status.lookup_code
         AND s_status.lookup_type = 'HZ_CPUI_REGISTRY_STATUS'
         AND s_status.language = userenv('LANG')
         AND lc.country = ft.territory_code
         AND to_number(hou.set_of_books_id) = xhs.ledger_id
         AND xhs.ledger_id = gl.ledger_id
         AND nvl(xhs.inactive_date, SYSDATE + 1) >= SYSDATE
         AND uses.gl_id_rec = gcc.code_combination_id(+)
         AND uses.territory_id = rt.territory_id(+)
            /*AND uses.primary_salesrep_id = jrs.salesrep_id(+)
            AND jrs.resource_id = res.resource_id(+)*/
         AND uses.payment_term_id = rtt.term_id(+)
         AND rtt.language(+) = userenv('LANG')
         AND uses.ship_via = ship_method.lookup_code(+)
         AND ship_method.lookup_type(+) = 'SHIP_METHOD'
         AND ship_method.language(+) = userenv('LANG')
         AND uses.site_use_code = 'BILL_TO'
         AND uses.primary_flag = 'Y'
         AND gl.name = p_ledger
         AND acct.status = 'A'
         AND sites.status = 'A'
         AND greatest(hp.last_update_date,
                      acct.last_update_date,
                      sites.last_update_date,
                      uses.last_update_date,
                      ps.last_update_date,
                      lc.last_update_date,
                      nvl(xxar_cust_to_hfg_pkg.get_site_cont_last_update(ps.party_site_id,
                                                                         'PHONE',
                                                                         'GEN'),
                          hp.last_update_date),
                      nvl(xxar_cust_to_hfg_pkg.get_site_cont_last_update(ps.party_site_id,
                                                                         'PHONE',
                                                                         'FAX'),
                          hp.last_update_date),
                      nvl(xxar_cust_to_hfg_pkg.get_site_cont_last_update(ps.party_site_id,
                                                                         'PHONE',
                                                                         'MOBILE'),
                          hp.last_update_date),
                      nvl(xxar_cust_to_hfg_pkg.get_site_email_last_update(ps.party_site_id),
                          hp.last_update_date)) BETWEEN p_date_from AND
             p_date_to;
    /*         AND (hp.last_update_date between p_date_from and p_date_to OR
                 acct.last_update_date between p_date_from and p_date_to OR
                 sites.last_update_date between p_date_from and p_date_to OR
                 uses.last_update_date between p_date_from and p_date_to OR
                 ps.last_update_date between p_date_from and p_date_to or
                 lc.last_update_date between p_date_from and p_date_to or
                 nvl(get_site_cont_last_update(ps.party_site_id,
                                                'PHONE',
                                                'GEN'),
                      hp.last_update_date) between p_date_from and p_date_to or
                 nvl(get_site_cont_last_update(ps.party_site_id,
                                                'PHONE',
                                                'FAX'),
                      hp.last_update_date) between p_date_from and p_date_to or
                 nvl(get_site_cont_last_update(ps.party_site_id,
                                                'PHONE',
                                                'MOBILE'),
                      hp.last_update_date) between p_date_from and p_date_to or
                 nvl(get_site_email_last_update(ps.party_site_id),
                      hp.last_update_date) between p_date_from and p_date_to);
    */
    TYPE tbl_cust_int IS TABLE OF xxar_cust_to_hfg_int%ROWTYPE INDEX BY PLS_INTEGER;
    l_cust_int_rec xxar_cust_to_hfg_int%ROWTYPE; --row record
    l_cust_int_tbl tbl_cust_int; --table record
    l_count        NUMBER;
    l_phone        VARCHAR2(300) /*(100)*/
    ; --
    l_fax          VARCHAR2(300) /*(100)*/
    ;
    l_mobile       VARCHAR2(300) /*(100)*/
    ;
    l_email        VARCHAR2(300) /*(241)*/
    ;
    l_error_count  NUMBER;
    l_file_name    VARCHAR2(300) /*(200)*/
    ;
    l_cnt          NUMBER;
  BEGIN
    /*dbms_output.enable(200000);*/

    SAVEPOINT before_process;
    x_ret_status  := fnd_api.g_ret_sts_success;
    l_count       := 0;
    l_error_count := 0;
    l_cust_int_tbl.delete;
    -- set_miss_rec;

    IF p_rerun_flag = 'N' THEN

      log_msg('p_rerun_flag:' || p_rerun_flag);

      FOR rec IN cur_hfg LOOP

        IF l_file_name IS NULL THEN
          l_file_name := get_file_name;
        ELSE
          NULL;
        END IF;

        l_count := l_count + 1;
        IF rec.unique_id IS NULL THEN
          --create
          g_blank_char := NULL;
        ELSE
          --update
          g_blank_char := '#';
        END IF;
        set_miss_rec;
        l_cust_int_rec                := g_miss_rec;
        l_cust_int_rec.process_status := fnd_api.g_ret_sts_success;

        --
        l_cust_int_rec.customer_number := substr(rec.account_number, 1, 10);
        l_cust_int_rec.company_code    := substr(rec.company_code, 1, 4);
        l_cust_int_rec.account_group   := substr(rec.company_code, 1, 2) || 'C';

        /*l_cust_int_rec.name1        := substr(rec.party_name, 1, 35);
        l_cust_int_rec.name2        := \*nvl(substr(rec.party_name, 36, 35),
                                           g_blank_char);*\ nvl(substr(rec.party_name, 35, 70),null); -- update by huangyan 2015-01-23*/

        IF (rec.party_name = NULL OR TRIM(rec.party_name) = '#') AND
           l_cust_int_rec.name1 <> NULL THEN
          l_cust_int_rec.name1 := NULL;
        ELSE
          l_cust_int_rec.name1 := substr(rec.party_name, 1, 35); -- update by huangyan 2015-02-12
        END IF;

        IF (rec.party_name = NULL OR TRIM(rec.party_name) = '#') AND
           l_cust_int_rec.name2 <> NULL THEN
          l_cust_int_rec.name2 := NULL;
        ELSE
          l_cust_int_rec.name2 := substr(rec.party_name, 36, 35); -- update by huangyan 2015-02-12
        END IF;

        l_cust_int_rec.search_term1 := nvl(substr(rec.attribute5, 1, 10),
                                           l_cust_int_rec.search_term1);

        /*  l_cust_int_rec.street := \*nvl(substr(rec.address1, 1, 60),
        g_blank_char);*\ nvl(substr(rec.address1, 1, 60),
        null);  -- update by huangyan 2015-01-23*/

        IF (rec.address1 = NULL OR TRIM(rec.address1) = '#') AND
           l_cust_int_rec.street <> NULL THEN
          l_cust_int_rec.street := NULL;
        ELSE
          l_cust_int_rec.street := substr(rec.address1, 1, 60); -- update by huangyan 2015-02-12
        END IF;

        /*l_cust_int_rec.street_house_number := nvl(substr(rec.address1,
               1,
               35),
        l_cust_int_rec.street_house_number);*/

        /*  -- add by huangyan 2015-01-30
        if p_ledger = 'SHE Ledger' then
           if rec.address2 = chr(45) then
             l_cust_int_rec.address2 := null;
           else
             l_cust_int_rec.address2 := rec.address2;
           end if;

           if rec.address3 = chr(45) then
             l_cust_int_rec.address3 := null;
           else
             l_cust_int_rec.address3 := rec.address3;
           end if;
         end if;
          --end add by huangyan 2015-01-30*/

        SELECT decode(p_ledger,
                      'SHE Ledger',
                      'EN',
                      'HEA Ledger',
                      'EN',
                      'HET Ledger',
                      'EN', /*add by liudan v4.00*/
                      g_blank_char)
          INTO l_cust_int_rec.language
          FROM dual;

        -- add by huangyan 2015-01-30
        IF (p_ledger = 'SHE Ledger' OR p_ledger = 'HET Ledger') THEN

          IF (rec.address2 = NULL OR TRIM(rec.address2) = '#') AND
             l_cust_int_rec.street4 <> NULL THEN
            l_cust_int_rec.street4 := NULL;
          ELSE
            l_cust_int_rec.street4 := substr(rec.address2, 1, 40);
          END IF;

          IF (rec.address3 = NULL OR TRIM(rec.address3) = '#') AND
             l_cust_int_rec.street5 <> NULL THEN
            l_cust_int_rec.street5 := NULL;
          ELSE
            l_cust_int_rec.street5 := substr(rec.address3, 1, 40);
          END IF;

        ELSE
          --end add by huangyan 2015-01-30

          l_cust_int_rec.street4 := nvl(substr(rec.address2, 1, 40),
                                        /*g_blank_char*/
                                        NULL); -- update by huangyan 2015-01-23
          l_cust_int_rec.street5 := nvl(substr(rec.address3, 1, 40),
                                        /*g_blank_char*/
                                        NULL); -- update by huangyan 2015-01-23
        END IF;

        /*l_cust_int_rec.city        := nvl(substr(rec.city, 1, 35),
        l_cust_int_rec.city);*/

        IF l_cust_int_rec.city IS NOT NULL AND
           (rec.city IS NULL OR TRIM(rec.city) = '#') THEN
          l_cust_int_rec.city := NULL;
        ELSE
          l_cust_int_rec.city := substr(rec.city, 1, 35);
        END IF;

        l_cust_int_rec.postal_code := nvl(substr(rec.postal_code, 1, 10),
                                          l_cust_int_rec.postal_code);
        l_cust_int_rec.country     := nvl(substr(rec.country_code, 1, 3),
                                          l_cust_int_rec.country);
        SELECT decode(p_ledger,
                      'SHE Ledger',
                      'EN',
                      'HEA Ledger',
                      'EN',
                      'HET Ledger',
                      'EN', /*add by liudan v4.00*/
                      g_blank_char)
          INTO l_cust_int_rec.language
          FROM dual;
        --get contact information
        l_phone  := get_site_contract(rec.party_site_id, 'PHONE', 'GEN');
        l_fax    := get_site_contract(rec.party_site_id, 'PHONE', 'FAX');
        l_mobile := get_site_contract(rec.party_site_id, 'PHONE', 'MOBILE');
        l_email  := get_site_email(rec.party_site_id);

        l_cust_int_rec.telephone                  := nvl(substrb(l_phone,
                                                                 1,
                                                                 30),
                                                         substrb(l_cust_int_rec.telephone1,
                                                                 1,
                                                                 30) /*l_cust_int_rec.telephone1*/);
        l_cust_int_rec.mobile_phone               := nvl(substr(l_mobile,
                                                                1,
                                                                30),
                                                         substr(l_cust_int_rec.mobile_phone,
                                                                1,
                                                                30) /*l_cust_int_rec.mobile_phone*/);
        l_cust_int_rec.fax                        := nvl(substrb(l_fax,
                                                                 1,
                                                                 30),
                                                         substrb(l_cust_int_rec.fax1,
                                                                 1,
                                                                 30) /*l_cust_int_rec.fax1*/);
        l_cust_int_rec.e_mail                     := nvl(substr(l_email,
                                                                1,
                                                                241),
                                                         substr(l_cust_int_rec.e_mail,
                                                                1,
                                                                30) /*l_cust_int_rec.e_mail*/);
        l_cust_int_rec.recon_account              := nvl(substr(rec.segment3,
                                                                1,
                                                                10),
                                                         substrb(l_cust_int_rec.recon_account,
                                                                 1,
                                                                 30) /*l_cust_int_rec.recon_account*/);
        l_cust_int_rec.prev_acct_no               := nvl(substr(rec.account_number,
                                                                -6,
                                                                6),
                                                         l_cust_int_rec.prev_acct_no);
        l_cust_int_rec.withholding_tax_type       := nvl(substr(rec.wht_type,
                                                                1,
                                                                2),
                                                         NULL);
        l_cust_int_rec.subject_to_withholding_tax := rec.wht_agent;
        l_cust_int_rec.obligated_to_wh_tax_from   := substr(rec.wht_from,
                                                            1,
                                                            8);
        l_cust_int_rec.obligated_to_wh_tax_until  := substr(rec.wht_until,
                                                            1,
                                                            8);
        l_cust_int_rec.group_id                   := p_group_id;
        l_cust_int_rec.org_id                     := rec.org_id;
        l_cust_int_rec.site_use_id                := rec.site_use_id;
        --l_cust_int_rec.process_status        := 'P';
        l_cust_int_rec.object_version_number := 1;
        --who
        l_cust_int_rec.creation_date          := SYSDATE;
        l_cust_int_rec.created_by             := g_user_id;
        l_cust_int_rec.last_update_date       := SYSDATE;
        l_cust_int_rec.last_updated_by        := g_user_id;
        l_cust_int_rec.last_update_login      := g_log_id;
        l_cust_int_rec.program_id             := g_program_id;
        l_cust_int_rec.request_id             := g_request_id;
        l_cust_int_rec.program_application_id := g_program_appl_id;
        --update by liudan 2016/12/06  begin

        if p_ledger = 'HET Ledger' then
          l_cust_int_rec.g_g_code := nvl(get_g_g_code(rec.party_id),
                                         'DUMMYCODE');
        else
          l_cust_int_rec.g_g_code := 'DUMMYCODE';

        end if;
        --end update by liudan 2016/12/06

        l_cust_int_rec.cust_last_update_date := rec.cust_last_update_date;
        l_cust_int_rec.interface_file_name   := l_file_name;
        l_cust_int_rec.rerun_flag            := p_rerun_flag;
        l_cust_int_rec.ledger_name           := p_ledger;
        l_cust_int_rec.bank_country          := NULL;
        l_cust_int_rec.bank_key              := NULL;
        l_cust_int_rec.acct_holder           := NULL;
        l_cust_int_rec.control_key           := NULL;
        l_cust_int_rec.bank_account          := NULL;

        l_cust_int_rec.iban                        := NULL;
        l_cust_int_rec.valid_from                  := NULL;
        l_cust_int_rec.partner_bank_type           := NULL;
        l_cust_int_rec.reference_specifications    := NULL;
        l_cust_int_rec.collection_authorization    := NULL;
        l_cust_int_rec.withholding_tax_country_key := NULL;
        l_cust_int_rec.withholding_tax_code        := NULL;
        l_cust_int_rec.w_tax_id                    := NULL;

        -- 3.00 2015-11-22 Jinlong.Pan Update Begin
        IF (p_ledger = 'SHE Ledger' or p_ledger = 'HET Ledger') THEN
          l_cust_int_rec.tax_number_3 := rec.tax_id;

          l_cust_int_rec.branch_code        := nvl(rec.branch_code, '99999');
          l_cust_int_rec.default_branch     := nvl(rec.branch_code, '99999');
          l_cust_int_rec.branch_description := rec.branch_number;

          IF rec.branch_code IS NULL THEN
            l_cust_int_rec.branch_description := 'Dummy Code';
          END IF;

          DECLARE
            l_exist_count NUMBER;
          BEGIN
            SELECT COUNT(1)
              INTO l_exist_count
              FROM xxar_cust_to_hfg_int t
             WHERE 1 = 1
               AND t.customer_number = rec.account_number
               AND t.branch_code = l_cust_int_rec.branch_code;
            IF l_exist_count > 0 THEN
              l_cust_int_rec.branch_code := NULL;
            END IF;
          END;
        ELSE
          l_cust_int_rec.branch_code        := NULL;
          l_cust_int_rec.default_branch     := NULL;
          l_cust_int_rec.branch_description := NULL;
        END IF;
        -- 3.00 2015-11-22 Jinlong.Pan Update End

        validate_required(l_cust_int_rec);

        IF l_cust_int_rec.process_status = fnd_api.g_ret_sts_error THEN
          l_error_count := l_error_count + 1;
        END IF;
        --update by shengxiang.fan 2015-06-18  start
        --CRATE or Update record in table
        IF rec.unique_id IS NOT NULL THEN
          SELECT xxar_cust_to_hfa_int_s.nextval
            INTO l_cust_int_rec.unique_id
            FROM dual;
          --l_cust_int_rec.unique_id         := rec.unique_id;
          l_cust_int_rec.new_customer_flag := 'N';

          INSERT INTO xxar_cust_to_hfg_int VALUES l_cust_int_rec;
          --update_cust_to_hfg_int(l_cust_int_rec, rec.unique_id);
          --update by shengxiang.fan 2015-06-18  end
        ELSE
          SELECT xxar_cust_to_hfa_int_s.nextval
            INTO l_cust_int_rec.unique_id
            FROM dual;
          l_cust_int_rec.new_customer_flag := 'Y';
          INSERT INTO xxar_cust_to_hfg_int VALUES l_cust_int_rec;
        END IF;

      END LOOP;

    ELSIF p_rerun_flag = 'Y' THEN

      SELECT COUNT(1)
        INTO l_cnt
        FROM xxar_cust_to_hfg_int xcth
       WHERE 1 = 1
            --AND xcth.rerun_flag = 'N'
         AND EXISTS (SELECT 1
                FROM gl_period_statuses gls
               WHERE gls.closing_status IN ('O')
                 AND gls.ledger_id =
                     (SELECT ledger_id
                        FROM gl_ledgers gl
                       WHERE gl.name = p_ledger)
                 AND gls.application_id = 222
                 AND gls.adjustment_period_flag = 'N'
                 AND xcth.cust_last_update_date BETWEEN
                     gls.start_date AND gls.end_date);
      IF l_cnt > 0 THEN
        l_file_name := get_file_name;
        UPDATE xxar_cust_to_hfg_int xctho
           SET xctho.group_id            = p_group_id,
               xctho.interface_file_name = l_file_name,
               xctho.rerun_flag          = p_rerun_flag
         WHERE EXISTS (SELECT 1
                  FROM gl_period_statuses gls
                 WHERE gls.closing_status IN ('O')
                   AND gls.ledger_id =
                       (SELECT ledger_id
                          FROM gl_ledgers gl
                         WHERE gl.name = p_ledger)
                   AND gls.application_id = 222
                   AND gls.adjustment_period_flag = 'N'
                   AND xctho.cust_last_update_date BETWEEN
                       gls.start_date AND gls.end_date);
      END IF;

    END IF;
    log_msg('l_count = ' || l_count);
    log_msg('l_error_count = ' || l_error_count);
    print_error_report(p_group_id);

    generate_hfg_file(p_ledger, p_group_id, l_file_name);
    --  COMMIT;
    IF l_error_count > 0 THEN
      --ROLLBACK TO before_process;
      RAISE fnd_api.g_exc_error;
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
  *   HISTORY:
  *     1.00 2014-07-31 Jia
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
    l_cnt           NUMBER;
  BEGIN
    SELECT COUNT(1) INTO l_cnt FROM xxar_cust_to_hfg_int;
    fnd_file.put_line(fnd_file.log, 'lltest0001 l_cnt=' || l_cnt);
    retcode := '0';
    -- concurrent header log
    --  xxfnd_conc_utl.log_header;
    fnd_file.put_line(fnd_file.log, 'lltest0002');
    -- conc body
    IF p_group_id IS NULL THEN
      SELECT xxar_cust_to_hfa_int_group_s.nextval
        INTO l_group_id
        FROM dual;
    ELSE
      l_group_id := p_group_id;
    END IF;
    fnd_file.put_line(fnd_file.log, 'lltest0003');
    IF p_ledger IS NULL THEN
      log_msg('GL_ACCESS_SET_ID :' ||
              fnd_profile.value('GL_ACCESS_SET_ID'));
      fnd_file.put_line(fnd_file.log, 'lltest0004');
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

    --    if p_rerun_flag is null then
    l_rerun_flag := 'N';
    /*    ELSE
      l_rerun_flag := p_rerun_flag;
    END IF;*/
    /*  IF p_interface_date IS NOT NULL THEN
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

    log_msg('l_date_from:' ||
            to_char(l_date_from, 'yyyy-mm-dd hh24:mi:ss'));
    log_msg('l_date_to:' || to_char(l_date_to, 'yyyy-mm-dd hh24:mi:ss'));

    /*dbms_output.put_line('before!');
    dbms_output.put_line('l_date_from:' || l_date_from);
    dbms_output.put_line('l_date_to:' || l_date_to);*/

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
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count   => l_msg_count,
                                p_data    => l_msg_data);
      IF l_msg_count > 1 THEN
        l_msg_data := fnd_msg_pub.get_detail(p_msg_index => fnd_msg_pub.g_first,
                                             p_encoded   => fnd_api.g_false);
      END IF;
      errbuf := l_msg_data;
    WHEN fnd_api.g_exc_unexpected_error THEN
      xxfnd_conc_utl.log_message_list;
      retcode := '2';
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count   => l_msg_count,
                                p_data    => l_msg_data);
      IF l_msg_count > 1 THEN
        l_msg_data := fnd_msg_pub.get_detail(p_msg_index => fnd_msg_pub.g_first,
                                             p_encoded   => fnd_api.g_false);
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

END xxar_cust_to_hfg_pkg;
/
