 �ӹ�����ʵ������һ������Ĺ��ܣ������ӹ��ܵķ�ʽ��ʵ����ʹ����Oracle EBS�Ĺ���Ȩ�޿�����ʵ�ְ�ȫ�ԵĿ��ƣ�
 ��ʵ�ʾ���ĳ���û��ܹ�ִ��һ������Ȩ�Ĺ��ܣ�һ������»�ʹ���ӹ���������ĳЩ��ť�Ƿ���ʾ������ʵ�����û� 
 �Ƿ���Բ���Form�е�ĳЩ���ܣ�����Oracle EBS�Ŀ�����Ա����ʹ���ӹ�����ͨ����ʾ/���ػ�����Ч/ʧЧ�����ϵ�
 �����ʵ�ֹ��ܵ���Ч����Ч�������泣�������е�1��2ʹ���ӹ������ʺϡ�

������ϣ��ֻ����Ȩ���û����ܿ���Book Order�����ť������������ȻҲ�޷��������������


http://oracleseeker.com/files/2009/09/book_order_example.png


ʵ�ֲ���
1��ΪBook Order��ť�������һ���ӹ���
http://oracleseeker.com/files/2009/09/define_subfunction.png

2��Form�����и��ݹ������������
��PRE-FORM�������У����ж��û��Ƿ���Ȩ�޿����������������о���ʾ������ʾ

IF (fnd_function.test('XHUORDER_BOOK_ORDER')) THEN 
  app_item_property.set_property('headers.book_order', DISPLAYED, PROPERTY_ON); 
ELSE 
  app_item_property.set_property('headers.book_order', DISPLAYED, PROPERTY_OFF); 
END IF;

3�����ӹ�����Ȩ����Ȩ���û�
���ĳ���û���Ҫ��ʾ�����ť��ֻҪ���ӹ���XHUORDER_BOOK_ORDER����û�ӵ�е�ְ���Ӧ�Ĳ˵����棬
���ӹ��� XHUORDER_BOOK_ORDER ���Ϊһ���˵������Prompt���վͿ���

http://oracleseeker.com/files/2009/09/menu_subfunction_define.png

�����ʱ����Ҫ��Prompt��λ���գ������ڲ˵���ʾ��ʱ��Ϳ���������˵��ʵ�ʹؼ���������Grant�У�
Ĭ�϶��ǹ��ϵģ���������Ȩ����ص�ְ���û�
