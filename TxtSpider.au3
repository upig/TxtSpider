#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Change2CUI=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
; Script Start - Add your code below here
#include <MsgBoxConstants.au3>
#include <Array.au3>
#include <Process.au3>



$novel_addr = InputBox("输入","请输入小说网址（例如http://www.biquge.la/book/3590/）", "");

$tok_content_begin = '<div id="list">'
$tok_content_end = '<div id="footer"'

$tok_txt_begin = '<div id="content"><script>readx();</script>'
$tok_txt_end = '</div>'

$tok_strReplace = '欢迎广大书友光临阅读，最新最快最火的连载作品尽在原创！'



Func GetContentURL($str, ByRef $name, ByRef $title, ByRef $url)
    Local $dData = InetRead($str);
    Local $sData = BinaryToString($dData)

    $name = StringRegExp($sData, "<h1>(.+?)</h1>", 1);
	$name = $name[0]

	$i = StringInStr($sData, $tok_content_begin)
	$sData = StringMid($sData, $i)
	$i = StringInStr($sData, $tok_content_end)
	$sData = StringLeft($sData, $i)

    $title = StringRegExp($sData, "<a href="".+?"">(.+?)</a>", 3);
    $url= StringRegExp($sData, "<a href=""(.*?)"">.*?</a>", 3);

 EndFunc   ;==>Example


Func GetSection($section_url)
    Local $dData = InetRead($section_url);
    Local $sData = BinaryToString($dData)
	return $sData
EndFunc



Local $title;
Local $url
Local $name

GetContentURL($novel_addr, $name, $title, $url)



$cnt = UBound($url)
;_ArrayDisplay($title, $name&" 章节数： "& UBound($title))
;_ArrayDisplay($url, "Url "& $cnt)


$file = FileOpen($name&".txt",2+8)
$log = FileOpen("log.txt", 2+8)
For $i=0 To $cnt-1
    $str = GetSection($novel_addr&"/"&$url[$i])
 	$pos = StringInStr($str, $tok_txt_begin)+StringLen($tok_txt_begin)
	$str = StringMid($str, $pos)
	$pos = StringInStr($str, $tok_txt_end)
	$str = StringLeft($str, $pos-1)
	$str= StringReplace($str, "&nbsp;", " ")
	$str= StringReplace($str, "<br />", @CRLF)
	$str= StringReplace($str, $tok_strReplace, '')

   ConsoleWrite("正在下载："&$title[$i]&@CRLF)
   FileWrite($log, "正在下载："&$title[$i]&@CRLF)
   FileWrite($file, @CRLF&@CRLF&$title[$i]&@CRLF&@CRLF)
   FileWrite($file, $str)
Next

FileWrite($log, "全部下载完毕，共"&$cnt&"章")

FileClose($file)
FileClose($log)

;ConsoleWrite($url)

;function one Get Content List URL
;function two Get Every URL and Write to a txt File
