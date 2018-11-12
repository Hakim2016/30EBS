DECLARE

  TYPE apply_rec_type IS RECORD(
    cash_receipt_id       ar_cash_receipts.cash_receipt_id%TYPE,
    customer_trx_id       ra_customer_trx.customer_trx_id%TYPE,
    show_closed_invoices  VARCHAR2(1) DEFAULT 'N',
    amount_applied        ar_receivable_applications.amount_applied%TYPE,
    amount_applied_from   ar_receivable_applications.amount_applied_from%TYPE,
    trans_to_receipt_rate ar_receivable_applications.trans_to_receipt_rate%TYPE,
    apply_date            ar_receivable_applications.apply_date%TYPE,
    apply_gl_date         ar_receivable_applications.gl_date%TYPE);

  l_apply_rec     apply_rec_type;
  l_return_status VARCHAR2(10);
  l_msg_data      VARCHAR2(2000);

  -- ==============================
  -- 创建核销
  -- ==============================
  PROCEDURE create_receipt_apply(x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_data      OUT NOCOPY VARCHAR2,
                                 p_apply_rec     IN OUT NOCOPY apply_rec_type) IS
    l_msg_count NUMBER;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    ar_receipt_api_pub.apply(p_api_version           => 1.0,
                             p_init_msg_list         => fnd_api.g_false,
                             p_commit                => fnd_api.g_false,
                             p_validation_level      => fnd_api.g_valid_level_full,
                             p_cash_receipt_id       => p_apply_rec.cash_receipt_id,
                             p_customer_trx_id       => p_apply_rec.customer_trx_id,
                             p_show_closed_invoices  => p_apply_rec.show_closed_invoices,
                             p_amount_applied        => p_apply_rec.amount_applied,
                             p_amount_applied_from   => p_apply_rec.amount_applied_from,
                             p_trans_to_receipt_rate => p_apply_rec.trans_to_receipt_rate,
                             p_apply_date            => p_apply_rec.apply_date,
                             p_apply_gl_date         => p_apply_rec.apply_gl_date,
                             x_return_status         => x_return_status,
                             x_msg_count             => l_msg_count,
                             x_msg_data              => x_msg_data);
  
    IF x_return_status != fnd_api.g_ret_sts_success THEN
      FOR l_index IN 1 .. l_msg_count
      LOOP
        x_msg_data := x_msg_data || '[' || fnd_msg_pub.get(p_msg_index => l_index, p_encoded => 'F') || ']';
      END LOOP;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data      := x_msg_data || '[Exception : sqlerrm ' || SQLERRM || ']';
    
  END create_receipt_apply;

BEGIN
  -- 核销
  l_apply_rec                       := NULL;
  l_apply_rec.cash_receipt_id       := l_cash_rec.cr_id;
  l_apply_rec.customer_trx_id       := rec_inv.customer_trx_id;
  l_apply_rec.show_closed_invoices  := 'Y';
  l_apply_rec.amount_applied        := rec_inv.amount;
  l_apply_rec.amount_applied_from   := NULL;
  l_apply_rec.trans_to_receipt_rate := NULL;
  l_apply_rec.apply_date            := rec_inv.receipt_date;
  l_apply_rec.apply_gl_date         := rec_inv.gl_date;

  create_receipt_apply(x_return_status => l_return_status, --
                       x_msg_data      => l_msg_data, --
                       p_apply_rec     => l_apply_rec);

  dbms_output.put_line(' x_return_status : ' || l_return_status);
  dbms_output.put_line(' x_msg_data      : ' || l_msg_data);

END;
