SELECT *
  FROM alr_distribution_lists lst
 WHERE 1 = 1
   AND lst.name = 'XXAR_G4_IF_BILLING_RECIPIENTS';

UPDATE alr_distribution_lists lst
   SET lst.to_recipients = '', lst.cc_recipients = '', lst.bcc_recipients = ''
 WHERE 1 = 1
   AND lst.name = 'XXAR_G4_IF_BILLING_RECIPIENTS';
