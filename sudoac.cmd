::Zetaspace sUdoAC manager.
::Last Update: 2023/7/23
@echo off
cd /d %~dp0
set onetest=%1
set onetest=%onetest:"=""%
if "%onetest:"=""%"=="""=""""" set onetest=
if no"%onetest%"==no"" set a=-
if not no"%onetest%"==no"" set a=%1
if if%a:~0,1%%a:~-2%==if""- set a=%a:~1,-2%
if if%a:~0,1%%a:~-1%==if"" set a=%a:~1,-1%
%2 set aaa=""%a%"" ::
%2 echo ���������ԱȨ������
%2 schtasks /query /tn sUdoAC_%username%>nul 2>nul
%2 if %errorlevel%==0 echo ������ UAC
%2 if %errorlevel%==0 echo "%~s0","%aaa%","%cd%","",^1>%tmp%\~sUdoAC_task%random%%random%.TMP&schtasks /run /tn sUdoAC_%username%>nul&goto :EOF
%2 mshta vbscript:CreateObject("Shell.Application").ShellExecute("%~s0","- ::","","runas",1)(window.close)&goto :EOF
set a?=n
if not no"%a%"==no"-" set a?=y

title [===ZETASPACE===] ������...
echo [sUdoAC] һ���������� UAC ��С����
echo.
::Get cmd host pid.
::[TODO] This powershell is tooooooo slow, try another way.
::(BUG OLD CODE, ONLY GETS PWSH PID.) for /f "usebackq" %%i in (`powershell (Get-CimInstance Win32_Process -Filter """ProcessId = '$pid'"""^).ParentProcessId`) do set thispid=%%i
for /F "usebackq" %%i in (`powershell (Get-CimInstance Win32_Process -Filter ("""ProcessID=""" + (Get-CimInstance Win32_Process -Filter """ProcessId='$pid'"""^).ParentProcessId^)^).ParentProcessId`) do set thispid=%%i
title [sUdoAC ����̨] ������...
::Set window and get admin.
color F0
for /f "tokens=3" %%i in ('tasklist /v /fi "PID eq %thispid%" /fo list^|findstr ���ڱ���') do (echo %%i|findstr ����Ա)>nul
if %errorlevel%==0 (set isadmin=y)else set isadmin=n
title [sUdoAC ����̨]
goto :maim
::maim = main mini

:main
echo [sUdoAC] һ���������� UAC ��С����
echo.
:maim
cd %~dp0
schtasks /query /tn sUdoAC_%username%>nul 2>nul
set t=%errorlevel%
if exist %systemroot%\System32\sudo.cmd (set s=0)else set s=1
if %isadmin%eah==yeah echo �� �Թ���Ա���������
if not %isadmin%eah==yeah echo �� ���û����������
if %t%==0 echo �� sUdoAC_%username% �ƻ������Ѵ��ڡ�
if not %t%==0 echo �� sUdoAC_%username% �ƻ�����δ������
if %s%==0 echo �� sudo ����Ѱ�װ��
if not %s%==0 echo �� sudo ���δ��װ��
if if%3==ifuserinputmode echo �� �û�����ģʽ&echo.&echo ��ȡ�������������롰ȡ������q����&goto :userinputmode
if %a?%==y echo �� ���������%a%
echo.
if not %t%==0 echo ^> C �����ƻ�����
if %t%==0 echo ^> C �ؽ��ƻ�����
if not %t%==0 echo ^> D ɾ���ƻ����� ��
if %t%==0 echo ^> D ɾ���ƻ�����
echo ^> L �г����� sUdoAC �ƻ�����
echo.
if not %s%==0 echo ^> I ��װ sudo ���
if %s%==0 echo ^> I ��װ sudo ���
if not %s%==0 echo ^> U ж�� sudo ��� ��
if %s%==0 echo ^> U ж�� sudo ���
echo.
echo ^> N ������ UAC ��ݷ�ʽ��ѡ��һ���ļ���
echo ^> M ������ UAC ��ݷ�ʽ����ȡ���еĿ�ݷ�ʽ��
echo.
echo ^> X �˳����������Ҳ�У�

echo.
if %a?%==y echo �밴��^> M&echo.&goto :2
choice /c cmdlinux /n /m �밴��^>
echo.
goto :%errorlevel%

::====Actions List====

:0
goto :mainover

:1
::Create task
if %t%==0 schtasks /delete /f /tn sUdoAC_%username%
schtasks /create /tn sUdoAC_%username% /xml .\template\sUdoAC.xml
goto :mainover

:3
::Delete task
schtasks /delete /f /tn sUdoAC_%username%
goto :mainover

:4
::List task
echo "������","�´�����ʱ��","ģʽ"
schtasks /query /fo csv /nh|findstr sUdoAC
if not %errorlevel%==0 echo ���ޣ�
goto :mainover

:5
::Install sudo plugin
echo ----------------------------------------------------------------
echo.
echo ^> sudo ^& skip UAC
echo.
echo ����һ��ʵ���ԵĲ����������һ������ sudo ���������Զ��� UAC ִ�ж�����
echo ��ɶȲ��ߣ����ܻ��и�������ֵֹ� bug ������ȥ̽����
echo.
echo ʹ�÷�����
echo sudo [command]
echo ��ֱ�Ӹ�Ҫִ�еĳ���
echo sudo -h [command]
echo �����ش���
echo ... ^| sudo -p [command]
echo ��֧�ֹܵ����루����֧�ִ�����
echo.
echo ��һЩС���⣺
echo �������ڵ�ǰ����ִ�У���Ϊԭ���� vbs ShellExecute ������������Ҫ���� cmd ָ����� sudo cmd �����С�
::.ShellExecute "application", "parameters", "dir", "verb", window
::   application   The file to execute (required)
::   parameters    Arguments for the executable
::   dir           Working directory
::   verb          The operation to execute (runas����Ա����/open/edit/print)
::   window        View mode application window (0=hide, 1=normal, 2=Min, 3=max, 4=restore, 5=current, 7=min/inactive, 10=default)
echo ��ֻ�ǰ�����˫���Ż�������˫���ţ�Ȼ������� sUdoAC �� ShellExecute ���������ֵ��ַ�ת�����⡣
echo ��Ĭ�ϴ�Ŀ¼Ϊ��ǰĿ¼����Ҫ�޸ĵĻ��Ѵ������ %%cd%% ȥ����
echo.
echo ��ȷ��Ҫ�� .\bin\sudo.cmd ����(����)�� %systemroot%\System32 ��
echo.
choice /c aquickbrwnfxjmpsovthelzydg /n /m "�� Y ȷ����װ"^>
if not %errorlevel%==24 echo ��ȡ��&goto :mainover
echo.
copy /v /y .\bin\sudo.cmd %systemroot%\System32\
goto :mainover

:7
::Uninstall sudo plugin
echo ɾ�� %systemroot%\System32\sudo.cmd ...
del %systemroot%\System32\sudo.cmd
echo OK
goto :mainover

:2
::Make shortcut (cmd restart as user)
::if "%3"==""
if %isadmin%==y if %a?%==n (
schtasks /delete /f /tn CAodUs_%username%>nul 2>nul
schtasks /create /tn CAodUs_%username% /xml .\template\runasuser1.xml>nul
echo "%~s0","- :: userinputmode","","",^1>%tmp%\~CAodUs_task%random%%random%.TMP
schtasks /run /tn CAodUs_%username%>nul
schtasks /delete /f /tn CAodUs_%username%>nul
color
goto :EOF
)
if %a?%==n (
echo.
echo ��ȡ�������������롰ȡ������q����
goto :userinputmode0
)
goto :mklink

:6
::New shortcut (file chooser)
if %a?%==y echo ��ѡ���ļ�^> %a%
if %a?%==n set /p a=��ѡ���ļ�^> <nul&for /f "usebackq delims=" %%i in (`mshta vbscript:CreateObject("Scripting.FileSystemObject"^).GetStandardStream(1^).WriteLine(CStr(CreateObject("WScript.Shell"^).Exec("mshta vbscript:""<input type=file id=a><script>a.click();new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).Write(a.value)[close()];</script>"""^).StdOut.ReadAll^)^)(window.close^)`) do set a=%%i&echo %%i
echo.
if if%a:~0,1%%a:~-1%==if"" set a=%a:~1,-1%
if exist "%a%" set a?=y
if "%a%"=="-" echo.&echo ����δѡ���ļ���&set a?=n&set a=-&goto :mainover
if not exist "%a%" echo �����ļ������ڣ�&echo ("%a%")&set a?=n&set a=-&goto :mainover
goto :mklink

:8
::eXit
color
goto :EOF

:mainover
::For an ending before a new loop start.
echo ----------------------------------------------------------------
echo.
goto :main


:mklink
set ajs=%a:\=\\%
if exist "%a%" for /f "usebackq delims=" %%a in (`echo "%a%"`) do set ap=%%~dpa&set an=%%~na&set ax=%%~xa
::echo %ap% %an% %ax%
echo %a%|findstr \^<����Ա_ 
if %errorlevel%==0 echo ��ݷ�ʽ %a% �Ѿ��Թ���Ա������У������ظ�����&set a?=n&set a=-&goto :mainover
echo a%ax%| findstr /I "\<a.lnk\>" >nul
if exist "%a%" (
if %errorlevel%==0 (call :lnk) else call :file
)else (
if "%a%"=="debug" call :debug
)

if "%a%"=="-" echo ����Ŀ��Ϊ��&goto :mainover
if exist "%a%" echo ��ݷ�ʽ %a% �Ѵ��ڣ�ȡ������&set a?=n&set a=-&goto :mainover
echo ������ݷ�ʽ��%a%
set ajs=%a:\=\\%
set aT=%aT:\=\\%
set aA=%aA:\=\\%
set aS=%aS:\=\\%
set aK=%aK:\=\\%
set aR=%aR:\=\\%
set aO=%aO:\=\\%
set aC=%aC:\=\\%

if %aT?%eah==yeah (set aT=-t.TargetPath='%aT%';)else set aT=-
if %aA?%eah==yeah (set aA=-t.Arguments='%aA%';)else set aA=-
if %aS?%eah==yeah (set aS=-t.WorkingDirectory='%aS%';)else set aS=-
if %aK?%eah==yeah (set aK=-t.Hotkey='%aK%';)else set aK=-
if %aR?%eah==yeah (set aR=-t.WindowStyle=%aR%;)else set aR=-
if %aO?%eah==yeah (set aO=-t.Description='%aO%';)else set aO=-
if %aC?%eah==yeah (set aC=-t.IconLocation='%aC%';)else set aC=-
::mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%');%aT:~1%%aA:~1%%aS:~1%%aK:~1%%aR:~1%%aO:~1%%aC:~1%t.Save();window.execScript('a(window.close)','vbs');"
:: �� Too long to run.
mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%');%aT:~1%t.Save();window.execScript('a(window.close)','vbs');"
mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%');%aA:~1%t.Save();window.execScript('a(window.close)','vbs');"
mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%');%aS:~1%t.Save();window.execScript('a(window.close)','vbs');"
mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%');%aK:~1%t.Save();window.execScript('a(window.close)','vbs');"
mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%');%aR:~1%t.Save();window.execScript('a(window.close)','vbs');"
mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%');%aO:~1%t.Save();window.execScript('a(window.close)','vbs');"
mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%');%aC:~1%t.Save();window.execScript('a(window.close)','vbs');"
::Old
::mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%');t.TargetPath='cmd';%aA:~1%%aS:~1%%aK:~1%%aR:~1%%aO:~1%%aC:~1%t.Save();window.execScript('a(window.close)','vbs');"
::echo "%aT~1%","%aA~1%","%aS~1%","",^1>%tmp%\~sUdoAC_task%random%%random%.TMP&schtasks /run /tn sUdoAC_%username%>nul

set a?=n
set a=-
goto :mainover

:debug
echo ����ģʽ���ֶ����봴������
echo.
echo ��ʾ����
echo ��ݷ�ʽ��C:\Users\%username%\Desktop\cmd.lnk
echo ��Ŀ�꣺C:\Windows\System32\cmd.exe
echo ��������/k echo helloworld!
echo ����ʼλ�ã�C:\Windows\System32
echo ����ݼ���CTRL+SHIFT+F
echo �����з�ʽ��1��(1:���洰�� 3:��� 7:��С��)
echo ����ע��һ��32λ�������г���΢��Windowsϵͳ����Windows�ϵ�������ͳ���������΢���DOS����ϵͳ��
echo ��ͼ�꣺C:\Windows\System32\cmd.exe,0
echo.
set a=-
set aT=-
set aA=-
set aS=-
set aK=-
set aR=-
set aO=-
set aC=-
set a?=n
set aT?=n
set aA?=n
set aS?=n
set aK?=n
set aR?=n
set aO?=n
set aC?=n
set /p a=��ݷ�ʽ��^> 
set /p aT=Ŀ�꣺^> 
set /p aA=������^> 
set /p aS=��ʼλ�ã�^> 
set /p aK=��ݼ���^> 
set /p aR=���з�ʽ��^> 
set /p aO=��ע��^> 
set /p aC=ͼ�꣺^> 
if not no%a%==no- set a?=y
if not no%aT%==no- set aT?=y
if not no%aA%==no- set aA?=y
if not no%aS%==no- set aS?=y
if not no%aK%==no- set aK?=y
if not no%aR%==no- set aR?=y
if not no%aO%==no- set aO?=y
if not no%aC%==no- set aC?=y
goto :EOF

:lnk
echo ��ݷ�ʽ�ļ�^> %an%%ax%
set aT=-
set aA=-
set aS=-
set aK=-
set aR=-
set aO=-
set aC=-
set aT?=n
set aA?=n
set aS?=n
set aK?=n
set aR?=n
set aO?=n
set aC?=n
title [sUdoAC ����̨] ��Ϣ��ѯ��
for /f "usebackq delims=" %%i in (`mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%').TargetPath;new ActiveXObject("Scripting.FileSystemObject").GetStandardStream(1).WriteLine(t);window.execScript('a(window.close)','vbs');"^|findstr .*`) do set aT=%%i&set aT?=y
if %aT?%==y (echo ��Ŀ�꣺%aT%)else echo ��Ŀ�꣺��
title [sUdoAC ����̨] ��Ϣ��ѯ��.
for /f "usebackq delims=" %%i in (`mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%').Arguments;new ActiveXObject("Scripting.FileSystemObject").GetStandardStream(1).WriteLine(t);window.execScript('a(window.close)','vbs');"^|findstr .*`) do set aA=%%i&set aA?=y
if %aA?%==y (echo ��������%aA%)else echo ����������
title [sUdoAC ����̨] ��Ϣ��ѯ��..
for /f "usebackq delims=" %%i in (`mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%').WorkingDirectory;new ActiveXObject("Scripting.FileSystemObject").GetStandardStream(1).WriteLine(t);window.execScript('a(window.close)','vbs');"^|findstr .*`) do set aS=%%i&set aS?=y
if %aS?%==y (echo ����ʼλ�ã�%aS%)else echo ����ʼλ�ã���
title [sUdoAC ����̨] ��Ϣ��ѯ��...
for /f "usebackq delims=" %%i in (`mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%').Hotkey;new ActiveXObject("Scripting.FileSystemObject").GetStandardStream(1).WriteLine(t);window.execScript('a(window.close)','vbs');"^|findstr .*`) do set aK=%%i&set aK?=y
if %aK?%==y (echo ����ݼ���%aK%)else echo ����ݼ�����
title [sUdoAC ����̨] ��Ϣ��ѯ��....
for /f "usebackq delims=" %%i in (`mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%').WindowStyle;new ActiveXObject("Scripting.FileSystemObject").GetStandardStream(1).WriteLine(t);window.execScript('a(window.close)','vbs');"^|findstr .*`) do set aR=%%i&set aR?=y
if %aR?%==y (echo �����з�ʽ��%aR%)else echo �����з�ʽ����
title [sUdoAC ����̨] ��Ϣ��ѯ��.....
for /f "usebackq delims=" %%i in (`mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%').Description;new ActiveXObject("Scripting.FileSystemObject").GetStandardStream(1).WriteLine(t);window.execScript('a(window.close)','vbs');"^|findstr .*`) do set aO=%%i&set aO?=y
if %aO?%==y (echo ����ע��%aO%)else echo ����ע����
title [sUdoAC ����̨] ��Ϣ��ѯ��......
for /f "usebackq delims=" %%i in (`mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%').IconLocation;new ActiveXObject("Scripting.FileSystemObject").GetStandardStream(1).WriteLine(t);window.execScript('a(window.close)','vbs');"^|findstr .*`) do set aC=%%i&set aC?=y
if %aC?%==y (echo ��ͼ�꣺%aC%)else echo ��ͼ�꣺��
title [sUdoAC ����̨]
set a=%ap%����Ա_%an%%ax%
for /f "usebackq delims=" %%a in (`echo "%aT%"`) do set aTp=%%~dpa&set aTn=%%~na&set aTx=%%~xa
echo a%aTx%| findstr /I "\<a.exe\>" >nul
if a"%aC:~,1%"==a"," if %errorlevel%==0 echo ��Ŀ���ļ�Ϊ����(.exe)���ض���ͼ�굽��%aT%%aC%��&set aC=%aT%%aC%
set aSudoT=%aT%
set aSudoA=%aA:"=""%
set aSudoS=%aS%
if %aR%==1 (set aSudoR=1) else if %aR%==3 (set aSudoR=3) else if %aR%==7 (set aSudoR=3) else set aSudoR=2
set aT=%%SystemRoot%%\System32\cmd.exe
set aA=/c echo "%aSudoT%","%aSudoA%","%aSudoS%","",^^^^^^^^^^^^^^^%aSudoR%^^^^^^^>%%tmp%%\~sUdoAC_task%%random%%%%random%%.TMP^^^^^^^&schtasks /run /tn sUdoAC_%%username%%^^^^^^^>nul
set aR=7
set aT?=y
set aA?=y
set aR?=y
goto :EOF

:file
set aT=%a%
set aA=-
set aS=-
set aK=-
set aR=-
set aO=-
set aC=-
set a=%ap%����Ա_%an%%ax%.lnk
set aT?=y
set aA?=n
set aS?=n
set aK?=n
set aR?=n
set aO?=n
set aC?=n

set a=%ap%����Ա_%an%%ax%.lnk
for /f "usebackq delims=" %%a in (`echo "%aT%"`) do set aTp=%%~dpa&set aTn=%%~na&set aTx=%%~xa
echo a%aTx%| findstr /I "\<a.exe\>" >nul
if a"%aC:~,1%"==a"," if %errorlevel%==0 echo ��Ŀ���ļ�Ϊ����(.exe)���ض���ͼ�굽��%aT%%aC%��&set aC=%aT%%aC%
set aSudoT=%aT%
set aSudoA=%aA:"=""%
set aSudoS=%aS%
if %aR%==1 (set aSudoR=1) else if %aR%==3 (set aSudoR=3) else if %aR%==7 (set aSudoR=3) else set aSudoR=2
set aT=%%SystemRoot%%\System32\cmd.exe
set aA=/c echo "%aSudoT%","%aSudoA%","%aSudoS%","",^^^^^^^^^^^^^^^%aSudoR%^^^^^^^>%%tmp%%\~sUdoAC_task%%random%%%%random%%.TMP^^^^^^^&schtasks /run /tn sUdoAC_%%username%%^^^^^^^>nul
set aR=7
set aT?=y
set aA?=y
set aR?=y

goto :EOF

:userinputmode
echo.
set a=-
set /p a=�������ļ������������·����Ȼ��س�^> 
echo.
if no%a%==no- echo ���ļ�&goto :userinputmode
if no%a%==noȡ�� sudoac&goto :EOF
if no%a%==noq sudoac&goto :EOF
if no%a%==nodebug goto :userinputmodeDEBUG
if if%a:~0,1%%a:~-1%==if"" set a=%a:~1,-1%
if not exist "%a%" goto :userinputmodeFILENOTEXIST
:userinputmodeGo
set a?=y
sudoac "%a%"
goto :EOF
:userinputmodeFILENOTEXIST
choice /n /m �ļ������ڣ�ȷ�ϼ�����[Yes/No]
if not %errorlevel%==1 goto :userinputmode
goto :userinputmodeGo
:userinputmodeDEBUG
choice /n /m �����ֶ����ԣ�ȷ�ϼ�����[Yes/No]
if not %errorlevel%==1 goto :userinputmode
goto :userinputmodeGo

:userinputmode0
echo.
set a=-
set /p a=�������ļ������������·����Ȼ��س�^> 
echo.
if no%a%==no- echo ���ļ�&goto :userinputmode0
if no%a%==noȡ�� goto :mainover
if no%a%==noq goto :mainover
if no%a%==nodebug goto :userinputmode0DEBUG
if if%a:~0,1%%a:~-1%==if"" set a=%a:~1,-1%
if not exist "%a%" goto :userinputmode0FILENOTEXIST
:userinputmode0Go
set a?=y
goto :2
:userinputmode0FILENOTEXIST
choice /n /m �ļ������ڣ�ȷ�ϼ�����[Yes/No]
if not %errorlevel%==1 goto :userinputmode0
goto :userinputmode0Go
:userinputmode0DEBUG
choice /n /m �����ֶ����ԣ�ȷ�ϼ�����[Yes/No]
if not %errorlevel%==1 goto :userinputmode0
goto :userinputmode0Go