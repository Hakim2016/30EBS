/*BEGIN
  fnd_global.APPS_INITIALIZE(user_id      => 4270,
                             resp_id      => 50676,
                             resp_appl_id => 660);
  mo_global.init('M');
END;*/
/*alter session set nls_language='AMERICAN';*/

/*SELECT USERENV('language') FROM dual;*/
SELECT XXPA_COMPLETED_PROJ_INFO_V.PROJECT_ID,
       XXPA_COMPLETED_PROJ_INFO_V.TOP_TASK_ID,
       XXPA_COMPLETED_PROJ_INFO_V.FM,
       XXPA_COMPLETED_PROJ_INFO_V.EQ,
       APPS.XXPA_COMPL_PRJ_PUB.GET_TOTAL_REVENUE_AMOUNT(XXPA_COMPLETED_PROJ_INFO_V.PROJECT_ID,
                                                        XXPA_COMPLETED_PROJ_INFO_V.TOP_TASK_ID,
                                                        'Oct-18',
                                                        'ER Revenue',
                                                        'Y') get_total_er_revenue,
       APPS.XXPA_COMPL_PRJ_PUB.GET_TOTAL_REVENUE_AMOUNT(XXPA_COMPLETED_PROJ_INFO_V.PROJECT_ID,
                                                        XXPA_COMPLETED_PROJ_INFO_V.TOP_TASK_ID,
                                                        'Oct-18',
                                                        'EQ Revenue',
                                                        'Y') get_total_rq_revenue,
       APPS.XXPA_COMPL_PRJ_PUB.GET_TOTAL_REVENUE_AMOUNT(XXPA_COMPLETED_PROJ_INFO_V.PROJECT_ID,
                                                        XXPA_COMPLETED_PROJ_INFO_V.TOP_TASK_ID,
                                                        'Oct-18',
                                                        'ER Revenue',
                                                        'Y'),
       APPS.XXPA_COMPL_PRJ_PUB.GET_SHIPMENT_DESC(XXPA_COMPLETED_PROJ_INFO_V.TOP_TASK_ID),
       APPS.XXPA_COMPL_PRJ_PUB.GET_CONCAT_MODEL_TYPES(XXPA_COMPLETED_PROJ_INFO_V.OE_HEADER_ID),
       APPS.XXPA_COMPL_PRJ_PUB.GET_RECOGNISE_PERIODS(XXPA_COMPLETED_PROJ_INFO_V.PROJECT_ID,
                                                     XXPA_COMPLETED_PROJ_INFO_V.TOP_TASK_ID),
       APPS.XXPA_COMPL_PRJ_PUB.GET_TRX_NUMBERS(XXPA_COMPLETED_PROJ_INFO_V.OE_HEADER_ID),
       XXPA_COMPLETED_PROJ_INFO_V.FC_AMOUNT *
       (APPS.XXPA_COMPL_PRJ_PUB.GET_EXCHANGE_RATE(XXPA_COMPLETED_PROJ_INFO_V.CURRENCY_CODE,
                                                  'Oct-18')),
       (APPS.XXPA_COMPL_PRJ_PUB.GET_INTEREST_AMOUNT(XXPA_COMPLETED_PROJ_INFO_V.ORG_ID,
                                                    XXPA_COMPLETED_PROJ_INFO_V.TASK_ID,
                                                    'EQ',
                                                    'Oct-18')) *
       (APPS.XXPA_COMPL_PRJ_PUB.GET_EXCHANGE_RATE(XXPA_COMPLETED_PROJ_INFO_V.CURRENCY_CODE,
                                                  'Oct-18')),
       APPS.XXPA_COMPL_PRJ_PUB.GET_INTEREST_AMOUNT(XXPA_COMPLETED_PROJ_INFO_V.ORG_ID,
                                                   XXPA_COMPLETED_PROJ_INFO_V.TASK_ID,
                                                   'EQ',
                                                   'Oct-18'),
       DECODE(XXPA_COMPLETED_PROJ_INFO_V.DOMESTIC_FLAG,
              'Y',
              'EQ X(' || XXPA_COMPLETED_PROJ_INFO_V.TRX_QUANTITY || '),ER(' ||
              APPS.XXPA_COMPL_PRJ_PUB.GET_INST_PROGRESS_RATE(XXPA_COMPLETED_PROJ_INFO_V.PROJECT_ID,
                                                             XXPA_COMPLETED_PROJ_INFO_V.TOP_TASK_ID,
                                                             'Oct-18') || '%)',
              XXPA_COMPLETED_PROJ_INFO_V.COUNTRY), 
       DECODE(XXPA_COMPLETED_PROJ_INFO_V.DOMESTIC_FLAG,
              'N',
              (DECODE((XXPA_COMPLETED_PROJ_INFO_V.HAND_OVER_DATE),
                      NULL,
                      XXPA_COMPLETED_PROJ_INFO_V.ORIG_ER *
                      APPS.XXPA_COMPL_PRJ_PUB.GET_INST_PROGRESS_RATE(XXPA_COMPLETED_PROJ_INFO_V.PROJECT_ID,
                                                                     XXPA_COMPLETED_PROJ_INFO_V.TOP_TASK_ID,
                                                                     'Oct-18') / 100,
                      XXPA_COMPLETED_PROJ_INFO_V.ORIG_ER)),
              (DECODE((XXPA_COMPLETED_PROJ_INFO_V.HAND_OVER_DATE),
                      NULL,
                      XXPA_COMPLETED_PROJ_INFO_V.ORIG_ER *
                      APPS.XXPA_COMPL_PRJ_PUB.GET_INST_PROGRESS_RATE(XXPA_COMPLETED_PROJ_INFO_V.PROJECT_ID,
                                                                     XXPA_COMPLETED_PROJ_INFO_V.TOP_TASK_ID,
                                                                     'Oct-18') / 100,
                      XXPA_COMPLETED_PROJ_INFO_V.ORIG_ER)) -
              APPS.XXPA_COMPL_PRJ_PUB.GET_TOTAL_REVENUE_AMOUNT(XXPA_COMPLETED_PROJ_INFO_V.PROJECT_ID,
                                                               XXPA_COMPLETED_PROJ_INFO_V.TOP_TASK_ID,
                                                               'Oct-18',
                                                               'ER Revenue',
                                                               'Y')) actual_er, ------------------------------------------
       DECODE(APPS.XXPA_COMPL_PRJ_PUB.GET_TOTAL_REVENUE_AMOUNT(XXPA_COMPLETED_PROJ_INFO_V.PROJECT_ID,
                                                               XXPA_COMPLETED_PROJ_INFO_V.TOP_TASK_ID,
                                                               'Oct-18',
                                                               'EQ Revenue',
                                                               'Y'),
              0,
              0,
              (XXPA_COMPLETED_PROJ_INFO_V.EQ -
              APPS.XXPA_COMPL_PRJ_PUB.GET_TOTAL_REVENUE_AMOUNT(XXPA_COMPLETED_PROJ_INFO_V.PROJECT_ID,
                                                                XXPA_COMPLETED_PROJ_INFO_V.TOP_TASK_ID,
                                                                'Oct-18',
                                                                'EQ Revenue',
                                                                'Y')) *
              (APPS.XXPA_COMPL_PRJ_PUB.GET_EXCHANGE_RATE(XXPA_COMPLETED_PROJ_INFO_V.CURRENCY_CODE,
                                                         'Oct-18'))) actual_eq, -----------------------------------------------
       APPS.XXPA_COMPL_PRJ_PUB.GET_EXCHANGE_RATE(XXPA_COMPLETED_PROJ_INFO_V.CURRENCY_CODE,
                                                 'Oct-18'),
       DECODE(XXPA_COMPLETED_PROJ_INFO_V.HAND_OVER_PERIOD,
              'Oct-18',
              XXPA_COMPLETED_PROJ_INFO_V.FM,
              0) actual_fm, --------------------------------------------------------------------------
       XXPA_COMPLETED_PROJ_INFO_V.CITY,
       XXPA_COMPLETED_PROJ_INFO_V.CURRENCY_CODE,
       XXPA_COMPLETED_PROJ_INFO_V.CUSTOMER_NAME,
       XXPA_COMPLETED_PROJ_INFO_V.FC_AMOUNT,
       (XXPA_COMPLETED_PROJ_INFO_V.FULLY_DELIVERY_DATE),
       (XXPA_COMPLETED_PROJ_INFO_V.FULLY_PACKING_DATE),
       XXPA_COMPLETED_PROJ_INFO_V.GNG_CODE,
       (XXPA_COMPLETED_PROJ_INFO_V.HAND_OVER_DATE),
       XXPA_COMPLETED_PROJ_INFO_V.HAS_COMM,
       XXPA_COMPLETED_PROJ_INFO_V.ID_NUMBER,
       XXPA_COMPLETED_PROJ_INFO_V.MFG_NUMBER,
       XXPA_COMPLETED_PROJ_INFO_V.ORDER_TYPE,
       XXPA_COMPLETED_PROJ_INFO_V.PROJECT_LONG_NAME,
       XXPA_COMPLETED_PROJ_INFO_V.TL_UNITS,
       XXPA_COMPLETED_PROJ_INFO_V.TRX_QUANTITY,
       XXPA_COMPLETED_PROJ_INFO_V.ORIG_ER
  FROM XXPA_COMPLETED_PROJ_INFO_V XXPA_COMPLETED_PROJ_INFO_V
 WHERE ((((XXPA_COMPLETED_PROJ_INFO_V.FULLY_DELIVERY_DATE) IS NULL OR
       (XXPA_COMPLETED_PROJ_INFO_V.FULLY_DELIVERY_DATE) <=
       APPS.XXPA_COMPL_PRJ_PUB.GET_ACCOUNTING_DATE('Oct-18') OR
       (XXPA_COMPLETED_PROJ_INFO_V.HAND_OVER_DATE) <=
       APPS.XXPA_COMPL_PRJ_PUB.GET_ACCOUNTING_DATE('Oct-18'))))
AND ((((DECODE(APPS.XXPA_COMPL_PRJ_PUB.GET_TOTAL_REVENUE_AMOUNT(XXPA_COMPLETED_PROJ_INFO_V.PROJECT_ID,
                                                            XXPA_COMPLETED_PROJ_INFO_V.TOP_TASK_ID,
                                                            'Oct-18',
                                                            'EQ Revenue',
                                                            'Y'),
           0,
           0,
           (XXPA_COMPLETED_PROJ_INFO_V.EQ -
           APPS.XXPA_COMPL_PRJ_PUB.GET_TOTAL_REVENUE_AMOUNT(XXPA_COMPLETED_PROJ_INFO_V.PROJECT_ID,
                                                             XXPA_COMPLETED_PROJ_INFO_V.TOP_TASK_ID,
                                                             'Oct-18',
                                                             'EQ Revenue',
                                                             'Y')) *
           (APPS.XXPA_COMPL_PRJ_PUB.GET_EXCHANGE_RATE(XXPA_COMPLETED_PROJ_INFO_V.CURRENCY_CODE,
                                                      'Oct-18')))) > 0 OR
(DECODE(XXPA_COMPLETED_PROJ_INFO_V.DOMESTIC_FLAG,
           'N',
           (DECODE((XXPA_COMPLETED_PROJ_INFO_V.HAND_OVER_DATE),
                   NULL,
                   XXPA_COMPLETED_PROJ_INFO_V.ORIG_ER *
                   APPS.XXPA_COMPL_PRJ_PUB.GET_INST_PROGRESS_RATE(XXPA_COMPLETED_PROJ_INFO_V.PROJECT_ID,
                                                                  XXPA_COMPLETED_PROJ_INFO_V.TOP_TASK_ID,
                                                                  'Oct-18') / 100,
                   XXPA_COMPLETED_PROJ_INFO_V.ORIG_ER)),
           (DECODE((XXPA_COMPLETED_PROJ_INFO_V.HAND_OVER_DATE),
                   NULL,
                   XXPA_COMPLETED_PROJ_INFO_V.ORIG_ER *
                   APPS.XXPA_COMPL_PRJ_PUB.GET_INST_PROGRESS_RATE(XXPA_COMPLETED_PROJ_INFO_V.PROJECT_ID,
                                                                  XXPA_COMPLETED_PROJ_INFO_V.TOP_TASK_ID,
                                                                  'Oct-18') / 100,
                   XXPA_COMPLETED_PROJ_INFO_V.ORIG_ER)) -
           APPS.XXPA_COMPL_PRJ_PUB.GET_TOTAL_REVENUE_AMOUNT(XXPA_COMPLETED_PROJ_INFO_V.PROJECT_ID,
                                                            XXPA_COMPLETED_PROJ_INFO_V.TOP_TASK_ID,
                                                            'Oct-18',
                                                            'ER Revenue',
                                                            'Y'))) > 0 OR
(DECODE(XXPA_COMPLETED_PROJ_INFO_V.HAND_OVER_PERIOD,
           'Oct-18',
           XXPA_COMPLETED_PROJ_INFO_V.FM,
           0)) > 0)))
AND ((((((((XXPA_COMPLETED_PROJ_INFO_V.FULLY_DELIVERY_DATE) <=
APPS.XXPA_COMPL_PRJ_PUB.GET_ACCOUNTING_DATE('Oct-18') OR
(XXPA_COMPLETED_PROJ_INFO_V.FULLY_DELIVERY_DATE) IS NULL)) AND
APPS.XXPA_COMPL_PRJ_PUB.GET_LAST_MONTH_OF_QUARTER('Oct-18') = 'Y' OR
(XXPA_COMPLETED_PROJ_INFO_V.HAND_OVER_DATE) <=
APPS.XXPA_COMPL_PRJ_PUB.GET_ACCOUNTING_DATE('Oct-18'))) AND
XXPA_COMPLETED_PROJ_INFO_V.DOMESTIC_FLAG = 'Y' OR
XXPA_COMPLETED_PROJ_INFO_V.DOMESTIC_FLAG = 'N' AND
(((XXPA_COMPLETED_PROJ_INFO_V.HAND_OVER_DATE) <=
APPS.XXPA_COMPL_PRJ_PUB.GET_ACCOUNTING_DATE('Oct-18') OR
(XXPA_COMPLETED_PROJ_INFO_V.FULLY_DELIVERY_DATE) <=
APPS.XXPA_COMPL_PRJ_PUB.GET_ACCOUNTING_DATE('Oct-18') OR
(XXPA_COMPLETED_PROJ_INFO_V.FULLY_DELIVERY_DATE) IS NULL)))))

AND
 XXPA_COMPLETED_PROJ_INFO_V.mfg_number IN
 ('SHA0516-PH',
  'SHA0515-PH',
  'SHA0518-PH',
  'SHA0517-PH',
  'SDB0167-SG',
  'SDB0184-SG',
  'SDB0182-SG',
  'SDB0177-SG',
  'SEB0685-SG',
  'SCD0124-ID',
  'SCD0125-ID',
  'SCD0126-ID',
  'SCD0123-ID')
 ORDER BY XXPA_COMPLETED_PROJ_INFO_V.ORDER_TYPE ASC,
          XXPA_COMPLETED_PROJ_INFO_V.ID_NUMBER  ASC;
SELECT APPS.XXPA_COMPL_PRJ_PUB.GET_ACCOUNTING_DATE('Oct-18') FROM dual;

SELECT xgp.start_date, xgp.end_date
  FROM xxpa_gl_periods_v xgp
 WHERE xgp.period_name = /*p_period_name*/
       'Oct-18';
/*SELECT fnd_global.USER_ID FROM dual;*/
