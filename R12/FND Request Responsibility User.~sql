--本SQL获取的是用户对应职责职责对应请求组、请组下对应“程序”【除程序以外还有 集、应用等】
--本SQL也可以简单理解为 获取用户可以提交什么请求，（请求可以简单理解为报表，但请求不是报表，包含关系）
--SQL addTime 2012-05-14 13：11， create by sunyukun
---------------------------------------------------------------------------------------------------

select fu.user_ID,
       fu.user_name,
       fu.start_date,
       fu.END_DATE,
       fu.description,
       fe.last_name,
       fr.RESPONSIBILITY_NAME,
       fr.description, --职责描述
       fr.start_date,
       fr.END_DATE,
       frg.request_group_name, ---- 请求组名称
       frg.description requestdsc, ---- 请求组描述
       fr.menu_id, ---- 菜单  ID 
       REQUEST_UNIT_TYPE, ---- 请求类型
       fcp.EXECUTION_METHOD_CODE,
       fcp.user_concurrent_program_name, ---请求并发程序名
       decode(fcp.EXECUTION_METHOD_CODE,
              'H',
              '主机',
              'S',
              '立即',
              'J',
              'Java 存储过程',
              'K',
              'Java 并发程序',
              'M',
              '多语言功能',
              'P',
              'Oracle Reports',
              'I',
              'PL/SQL 存储过程',
              'B',
              '请求集阶段函数',
              'A',
              '派生',
              'L',
              'SQL*Loader 程序',
              'Q',
              'SQL*Plus',
              'E',
              'Perl 并发程序')
  from fnd_user                    fu,
       hr_employees                fe,
       FND_USER_RESP_GROUPS_DIRECT ugd,
       FND_RESPONSIBILITY_VL       fr,
       fnd_request_groups          frg,
       FND_REQUEST_GROUP_UNITS     frgu,
       FND_CONCURRENT_PROGRAMS_VL  fcp
where 1=1
   --AND to_char(fu.creation_date, 'yyyy') >= '2008'
   and fu.employee_id = fe.employee_id(+) --用户与职员关系
   and fu.user_id = ugd.user_id
   and ugd.RESPONSIBILITY_ID = fr.responsibility_id
   and ugd.RESPONSIBILITY_APPLICATION_ID = fr.APPLICATION_ID --- 以上用户与职责关系
   and fr.request_group_id = frg.request_group_id(+)
   and fr.group_application_id = frg.application_ID(+) --- 以上是请求组和职责关系
   and frgu.application_id(+) = frg.application_ID
   and frg.request_group_id = frgu.request_group_id(+) --- 以上是请求组中间表与职责
   and fcp.CONCURRENT_PROGRAM_ID = frgu.REQUEST_UNIT_ID
   and frgu.UNIT_application_id = fcp.application_id
   AND fcp.user_concurrent_program_name --= 'Manual Key in Expenditure Report'--'Item categories report'--'Create Accounting'
   --LIKE --'%Manual Key in Expenditure Report%'
   and user_name = 'HAND_HKM' --- 'SUNYUKUN' 登录用户名,可变量
order by User_id,
          Responsibility_name
