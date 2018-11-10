 子功能是实际上是一个特殊的功能，利用子功能的方式其实就是使用了Oracle EBS的功能权限控制来实现安全性的控制，
 其实质就是某个用户能够执行一个被授权的功能，一般情况下会使用子功能来控制某些按钮是否显示，进而实现了用户 
 是否可以操作Form中的某些功能，所以Oracle EBS的开发人员经常使用子功能来通过显示/隐藏或者有效/失效界面上的
 组件来实现功能的有效或无效，如上面常见需求中的1，2使用子功能最适合。

如下我希望只有授权的用户才能看到Book Order这个按钮，看不到的自然也无法进行这个操作了


http://oracleseeker.com/files/2009/09/book_order_example.png


实现步骤
1，为Book Order按钮组件定义一个子功能
http://oracleseeker.com/files/2009/09/define_subfunction.png

2，Form代码中根据功能来控制组件
在PRE-FORM触发器中，来判断用户是否有权限看到这个操作，如果有就显示否则不显示

IF (fnd_function.test('XHUORDER_BOOK_ORDER')) THEN 
  app_item_property.set_property('headers.book_order', DISPLAYED, PROPERTY_ON); 
ELSE 
  app_item_property.set_property('headers.book_order', DISPLAYED, PROPERTY_OFF); 
END IF;

3，将子功能授权给有权的用户
如果某个用户需要显示这个按钮，只要将子功能XHUORDER_BOOK_ORDER添加用户拥有的职责对应的菜单里面，
把子功能 XHUORDER_BOOK_ORDER 添加为一个菜单项，但是Prompt留空就可以

http://oracleseeker.com/files/2009/09/menu_subfunction_define.png

定义的时候需要将Prompt栏位留空，这样在菜单显示的时候就看不到这个菜单项，实际关键的是最后的Grant列，
默认都是勾上的，代表了授权给相关的职责用户
