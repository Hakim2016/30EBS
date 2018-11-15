Oracle EBS:"不存在可用的有效责任"解决办法 

案例：用户的职责中存在一个form，从Web页面登录后点击form，出来错误信息：“对不起，不存在可用的有效责任”，

英文信息为：“Sorry, no valid responsibilities available”。如果cgi模式下，从其他职责切换过去则正常。

检查职责定义发现Responsibility Key（责任关键字）值是中文——这是很糟糕的习惯，任何key-like的存在都不应该出现ASCII（如英文字母、数字、下划线等）之外的字符。Oracle数据库虽然支持索引字段使用中文，甚至字段名都可以用中文，但是对于EBS这种大型应用而言，使用中文便存在风险。在此案例中，职责Responsibility Key用中文貌似正常，但是职责信息需要被同步到其他地方，而同步程序，你不能保证它会正常工作。

这其实是一个常见问题。

解决办法也很简单，

正常途径

新建职责（使用英文责任关键字），然后替换下用户的职责即可。

非正常途径

1.在数据表(FND_RESPONSIBILITY)中将RESPONSIBILITY_KEY修改为英文字符。

2.执行并发请求Sync responsibility role data into the WF table(使责任职责数据与 WF 表同步)

3.清理缓存。路径：Functional Administrator -> Core Services -> Caching Framework -> Global Configuration -> Clear All Cache
