--------------- get sale order subtotal ---------------
BEGIN
  oe_oe_totals_summary.global_totals(349392);
END;
/
  SELECT oe_oe_totals_summary.order_subtotals(ooh.header_id) order_subtotals,
         oe_oe_totals_summary.price_adjustments(ooh.header_id) price_adjustments,
         oe_oe_totals_summary.charges(ooh.header_id) charges,
         oe_oe_totals_summary.taxes(ooh.header_id) taxes
    FROM oe_order_headers_all ooh
   WHERE 1 = 1
     AND ooh.header_id = 349392;

-------------------------------------------------------

DECLARE
  l_subtotal NUMBER;
  l_discount NUMBER;
  l_charges  NUMBER;
  l_tax      NUMBER;
BEGIN
  -- Call the procedure
  oe_oe_totals_summary.order_totals(p_header_id => 349392,
                                    p_subtotal  => l_subtotal,
                                    p_discount  => l_discount,
                                    p_charges   => l_charges,
                                    p_tax       => l_tax);

  dbms_output.put_line(' l_subtotal : ' || l_subtotal);
  dbms_output.put_line(' l_discount : ' || l_discount);
  dbms_output.put_line(' l_charges  : ' || l_charges);
  dbms_output.put_line(' l_tax      : ' || l_tax);
END;
/
