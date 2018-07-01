create or replace and compile java source named xxfnd_file_20140708 as
import java.io.*;
import java.util.*;
import java.sql.* ;
import oracle.jdbc.* ;
import oracle.sql.* ;
/**
* Read files in the directionary. The put the file names into the array list
*
*/
public class FileViewer20140708 {
    /**
    *
    * @param path   :File path
    * @param suffix :suffix name
    * @param isdepth : is recursion find
    * @param splitBy: split by character
    * @return
    */
    public static String getListFiles(String path, String suffix, String isdepth, String splitBy)
    {
        File file = new File(path);
        List<String> fileList =  new ArrayList<String>(); 
        fileList = FileViewer20140708.listFile(file ,suffix, isdepth,fileList); 
        String fileName = "";
        //fileName += "The file count is:" + fileList.size() + "\r\n";
        System.out.println(fileName);

        for (Iterator i = fileList.iterator(); i.hasNext();)
        {
          String temp = (String) i.next();
          System.out.println(temp);
          fileName += splitBy + temp;
        }        
        return fileName;
    }

    public static List listFile(File f, String suffix, String isdepth,List fileList)
    {
        
      //is directory and need to recurse find
      if (f.isDirectory() & "TRUE".equals(isdepth))
      {
          File[] t = f.listFiles();
          for (int i = 0; i < t.length; i++)
          {
             listFile(t[i], suffix, isdepth,fileList);
          }
      }
      else
      {
          String filePath = f.getAbsolutePath();

          System.out.println("suffix = "+suffix);
          if(suffix =="" || suffix == null)
          {
              //suffix is null, then get all the files
              System.out.println("----------------");
              fileList.add(filePath);
          }
          else
          {
              int begIndex = filePath.lastIndexOf(".");//the last . character
              String tempsuffix = "";

              if(begIndex != -1)//for case no suffix file
              {
                  tempsuffix = filePath.substring(begIndex + 1, filePath.length());
              }

              if(tempsuffix.equals(suffix))
              {
                  fileList.add(filePath);
              }
              System.out.println("|||||||||||||||||||");
          }

      }
      return fileList;
    }

    /**
    * The method to readFileNames
    * @param fileName
    * @param content
    */
    public static String readFileNames(String fileName,String charset,String splitBy)
    {
        String fileNames = "";
        try
        {
            //open a file writer, if file not exists, creat a new file
            File file = new File(fileName);
            
            if (file.isFile()&&file.exists()){
                InputStreamReader read = new InputStreamReader(new FileInputStream(fileName),charset);
                BufferedReader reader = new BufferedReader(read);
                String line;
                while((line = reader.readLine())!=null){
                    fileNames = fileNames+splitBy+line;
                }
                read.close();
                reader.close();
            }
            else
            {
                fileNames = "File is not exists.";
            }
        }
        catch (IOException e)
        {
            e.printStackTrace();
            fileNames = e.toString();
            //log error
        }
        
        return fileNames;
    }
    
    /** 
    * The method to add plusฃบUse the FileReader 
    * @param fileName 
    * @param content 
    */ 
    public static String uploadFile(String fileId,
                                    String fileName,
                                    String charset) 
    { 
        //open a file writer, if file not exists, creat a new file
       String errorMsg = "";
       try
       {
          int ch = 0;
          Connection conn = DriverManager.getConnection("jdbc:default:connection:") ;
          FileReader reader = new FileReader(fileName);
          BLOB outBlob = BLOB.createTemporary( conn, true , BLOB.DURATION_CALL) ;
          Writer out = new OutputStreamWriter(outBlob.getBinaryOutputStream() , charset);
          FileInputStream fis=new FileInputStream(fileName);
          BufferedInputStream bis=new BufferedInputStream(fis);
          String tempStr;
          byte[] b = new byte[0x500000];
          int i = 0;
          while ((i = bis.read(b)) > 0) {
              tempStr=new String(b,0,i,charset); 
              out.write(tempStr);
              System.out.println(tempStr);
          }
          out.close();          
          fis.close();
          bis.close();
          
          //Insert blob into fnd_lobs  
          CallableStatement cs= conn.prepareCall("begin xxfnd_file_pkg.insert_lob(?,?,?,?); end;");
          cs.setString(1,fileId);
          cs.setString(2,fileName);
          cs.setBlob(3,outBlob);
          cs.setString(4,charset);
          cs.execute();
          //conn.commit();
          cs.close();
          conn.close();
            
        }catch(Exception e){
            errorMsg = e.toString();            
        }
       return errorMsg;
    }
    
   /** 
    * The method to get the file encode 
    * @param fileName 
    */ 
    public static String getFileEncode(String fileName) 
    { 
        //open a file writer, if file not exists, creat a new file
       try
       {
            InputStream inputStream = new FileInputStream(fileName);  
            byte[] head = new byte[3];  
            inputStream.read(head);    
            String code = "";  
            code = "JIS"; //Japanese
            code = head[0]+" "+head[1]+" "+head[2];
            if (head[0] == -1 && head[1] == -2 )  
              code = "UTF16";  
            else if (head[0] == -2 && head[1] == -1 )  
              code = "Unicode"; 
            else if(head[0]==-17 && head[1]==-69 && head[2] ==-65)  
              code = "UTF8"; 
            else if(head[0]==49 && head[1]==13 && head[2] ==10)  
              code = "TIS620"; 
            else if(head[0]==116 && head[1]==101 && head[2] ==115)  
              code = "GBK"; 
            else
              code = "UTF8";
            System.out.println(code); 
            return code;
        }catch(Exception e){
             e.printStackTrace();
             return e.toString();
        }
    }  
    
    /** 
    * The method to get the file encode 
    * @param inBlob  : blob data 
    * @param sourcecs: source character set
    * @param fileName: destination character set
    * Return: Blob
    */ 
    public static BLOB convertBlob
        ( BLOB inBlob, String sourcecs, String destcs ) 
        throws SQLException, IOException {

        Reader in = new InputStreamReader( 
           inBlob.getBinaryStream() , sourcecs ); 

        Connection conn = DriverManager.getConnection(
           "jdbc:default:connection:") ;
        BLOB outBlob = BLOB.createTemporary( conn, true , BLOB.DURATION_CALL) ;
        Writer out = new OutputStreamWriter( 
           outBlob.getBinaryOutputStream() , destcs ); 

        int c;

        while ((c = in.read()) != -1)
           out.write(c);

        out.close();
        in.close();

        return outBlob ;
    }
    
    /** 
    * The method to get the file encode 
    * @param inBlob  : blob data 
    * @param sourcecs: source character set
    * @param fileName: destination character set
    * Return: Clob
    */ 
    public static CLOB convertClob
        ( BLOB inBlob, String sourcecs ) 
        throws SQLException, IOException {

        Reader in = new InputStreamReader( 
           inBlob.getBinaryStream() , sourcecs ); 

        Connection conn = DriverManager.getConnection(
           "jdbc:default:connection:") ;
        CLOB outClob = CLOB.createTemporary( conn, true , CLOB.DURATION_CALL) ;
        Writer out = outClob.getCharacterOutputStream() ;
        // Writer out = outClob.getAsciiOutputStream() ;

        int c;

        while ((c = in.read()) != -1)
           out.write(c);

        out.close();
        in.close();

        return outClob ;
    }
    
    /** 
    * The method to get the file encode 
    * @param inBlob  : blob data 
    * @param sourcecs: source character set
    * @param fileName: destination character set
    * Return: String
    */ 
    public static String convertStr
        ( BLOB inBlob, String sourcecs ) 
        throws SQLException, IOException {

        Reader in = new InputStreamReader( 
           inBlob.getBinaryStream() , sourcecs ); 

        StringBuffer outStr = new StringBuffer() ;

        int i, c ;

        i = 0 ;
        while ( ( (c = in.read()) != -1 ) & i < 1000 ) {
           outStr.append((char)c);
           i++ ;
        }

        in.close();

        return outStr.toString() ;
    }
    
    /** 
    * The method to create the file
    * @param fileDir : file dir
    * @param fileName: file name with dir
    * @param charSet : destination character set
    * @param inBlob  : blob data 
    * Return: String
    */ 
    public static String createFile(String fileDir,
                                    String fileName,
                                    String charSet,
                                    BLOB   inBlob) 
        throws SQLException, IOException {
        try
        {         

          File fileDirectory = new File(fileDir);
          if (!fileDirectory.isDirectory()){
             String message = "File dir <"+fileDir+"> doesnot exists.";
             return message;
          }
          
          File file = new File(fileName);
          if (!file.exists()){
              System.out.println("The file "+fileName+" does not exist.");
              file.createNewFile();
          }
          
          Reader in = new InputStreamReader( 
             inBlob.getBinaryStream() , charSet ); 

          Writer writer = 
            new BufferedWriter(new OutputStreamWriter(new FileOutputStream(fileName),charSet));
          int i, c ;

          i = 0 ;
          while ( ( (c = in.read()) != -1 ) ) {
             writer.write((char)c);
             i++ ;
          }

          in.close();
          writer.close();
          return "S";
        }catch(Exception e){
             e.printStackTrace();
             StringBuffer sb = new StringBuffer();
             StackTraceElement[] stackArray = e.getStackTrace();
             for (int i = 0; i < stackArray.length; i++) {
               StackTraceElement element = stackArray[i];
               sb.append(element.toString() + "\n");
              }
             return sb.toString();
/*           } 
             return e.toString();*/
        }
    }
    
    /** 
    * The method to delete the file
    * @param fileName  : file name
    * Return: String
    */ 
    public static String deleteFile(String fileName) 
        throws SQLException, IOException {

        File file = new File(fileName);
        String message = "";
        try
        {
           if (file.isFile()&&file.exists())
           {
              file.delete();
              message = "S";
           }
           else
             message = "File:"+fileName+" does not exists";
        }
        catch(Exception e)
        {
          e.printStackTrace();
          message = e.toString();
        }
        
        return message;
    }
    
    /** 
    * The method to judge the file exists or not
    * @param fileName  : file name
    * Return: String
    */ 
    public static String isFileExists(String fileName) 
        throws SQLException, IOException {

        File file = new File(fileName);
        String message = "";
        try
        {
           if (file.isFile()&&file.exists())
           {
              message = "Y";
           }
           else
             message = "N";
        }
        catch(Exception e)
        {
          e.printStackTrace();
          message = e.toString();
        }
        
        return message;
    }
}
