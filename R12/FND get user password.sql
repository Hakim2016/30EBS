SELECT usr.encrypted_user_password
  FROM fnd_user usr
 WHERE usr.user_name = '70610664'--'SHUANGSHUANG.ZHAO'
 ;

 
 SELECT cux_fnd_web_sec.decrypt('APPS',
                               --'ZH1DB57911A4A41765FA5E578FF196886DFEF0CCD31D8D0F7959699B5ECE1BB8B1E2B4565C327EF43D7BB1FCD9697889A696'
                               'ZHC329D015B8D5EE2194340BD8EB2C995D3DBFEC1D7813729F9E886A043BB64DE57C7E916D8BF93D23BDBFAF309B88C0E7E5'
                               )
  FROM dual;
  
  
--1.得到密钥; --2.解密 得到密码
SELECT cux_fnd_web_sec.decrypt('APPS', usr.encrypted_user_password)
  FROM fnd_user usr
 WHERE usr.user_name = 'HAND_CP';  
