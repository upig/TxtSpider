#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Xiang Wei  31531640@qq.com  http://xiangwei.cc


todo
自动选择编译成DOS格式
如果没有INI，自动生成一个，给出INI的版本与更新日期
给出官网网址，可以访问与更新，更新INI文件
通过读取ini文件，给出下拉框，可以提示支持哪些网站



#ce ----------------------------------------------------------------------------
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Change2CUI=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
; Script Start - Add your code below here
#include <MsgBoxConstants.au3>
#include <Array.au3>
#include <Process.au3>

FileInstall("TxtSpider.ini", @ScriptDir & "\TxtSpider.ini")

$section_name_list = IniReadSectionNames ("TxtSpider.ini")
;~  _ArrayDisplay($section_name_list,"kdk")
 $str_list = ''
 For $i = 1  to UBound($section_name_list)-1
   $str_list = $str_list & @CRLF & $section_name_list[$i]
 Next

; Display an open dialog to select a file.
Local $novel_addr = FileOpenDialog("Select WebNovel Link File", @WorkingDir & "\", "All (*.csv)")

        FileChangeDir(@ScriptDir)

;~ $novel_addr = InputBox( _
;~ "TxtSpider by XIANG Wei","官网：https://github.com/upig/TxtSpider " _
;~ &@CRLF&@CRLF&"请输入小说目录页网址（例如 http://www.biquge.la/book/3590/）"&@CRLF&@CRLF&"支持的小说网站列表："&@CRLF&$str_list, _
;~ "https://www.webnovel.com/book/6831850602000905/Library-of-Heaven's-Path", "", _
;~ 600,300);

;$section_name_arr  = StringRegExp($novel_addr, "http.*//(.+?)/", 1)

If @error<>0 Then
   MsgBox(0, "警告", "没有找到匹配的网址标识")
   Exit
EndIf

$section_key = IniReadSection("TxtSpider.ini", "www.webnovel.com")

$tok_name_reg 		=$section_key[1][1]
$tok_content_begin 	=$section_key[2][1]
$tok_content_end	=$section_key[3][1]
$tok_title_reg 		=$section_key[4][1]
$tok_url_reg 		=$section_key[5][1]
$tok_txt_begin 		=$section_key[6][1]
$tok_txt_end 		=$section_key[7][1]
$tok_strReplace 	=$section_key[8][1]
$tok_strReplace2	=$section_key[9][1]


Func GetContentURL($str, ByRef $name, ByRef $title, ByRef $url)
    Local $dData = FileRead($str);'webnovel.com_13th_Dec_2017 - 副本.csv');
    Local $sData = $dData

   $name = 'webnovel'
   $title = 'webnovel'
   $name = StringRegExp($sData, $tok_name_reg, 1);
   $name = $name[0]

;~ 	$i = StringInStr($sData, $tok_content_begin)
;~ 	$sData = StringMid($sData, $i)
;~ 	$i = StringInStr($sData, $tok_content_end)
;~ 	$sData = StringLeft($sData, $i)


   $title = StringRegExp($sData, $tok_title_reg, 3);
   $url= StringRegExp($sData, $tok_url_reg, 3);

 EndFunc   ;==>Example


Func GetSection($section_url)
    Local $dData = InetRead($section_url);
    Local $sData = BinaryToString($dData, $SB_UTF8 )
	return $sData
EndFunc



Local $title;
Local $url
Local $name

GetContentURL($novel_addr, $name, $title, $url)

$cnt = UBound($url)
_ArrayDisplay($title, $name&" 章节数： "& UBound($title))
;_ArrayDisplay($url, "Url "& $cnt)
;ConsoleWrite($tok_title_reg)
ConsoleWrite($name&" 章节数： "& UBound($title))
;Exit

$file = FileOpen($name&".html",2+8)
$log = FileOpen("log.txt", 2+8)
ConsoleWrite("开始下载："&$name&@CRLF)
FileWrite($log, "开始下载："&$name&@CRLF)

FileWrite($file, "<h1>"& $name &"</h1>")
For $i=1 To $cnt-1
    $str = GetSection($url[$i])

 	$pos = StringInStr($str, $tok_txt_begin)+StringLen($tok_txt_begin)
	$str = StringMid($str, $pos)
	$pos = StringInStr($str, $tok_txt_end)
	$str = StringLeft($str, $pos-1)
	$str= StringRegExpReplace($str, "<p>\s*</p>", '')
	$str= StringRegExpReplace($str, $tok_strReplace, '')
	$str= StringRegExpReplace($str, $tok_strReplace2, '')

   ConsoleWrite("已经下载："&$title[$i]&@CRLF)
   FileWrite($log, "已经下载："&$title[$i]&@CRLF)
   FileWrite($file, @CRLF&@CRLF&"<h1>"&$i&" "&$title[$i]&"</h1>"&@CRLF&@CRLF)
   FileWrite($file, $str)
   ;ExitLoop
Next

FileWrite($log, "全部下载完毕，共"&$cnt&"章")

FileClose($file)
FileClose($log)

;ConsoleWrite($url)

;function one Get Content List URL
;function two Get Every URL and Write to a txt File
