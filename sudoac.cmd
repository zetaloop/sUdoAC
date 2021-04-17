::Zetaspace sUdoAC manager.
::Last Update: 2021/4/17
@echo off
set onetest=%1
set onetest=%onetest:"=""%
if "%onetest:"=""%"=="""=""""" set onetest=
if no"%onetest%"==no"" set a=-
if not no"%onetest%"==no"" set a=%1
if if%a:~0,1%%a:~-2%==if""- set a=%a:~1,-2%
if if%a:~0,1%%a:~-1%==if"" set a=%a:~1,-1%
%2 set aaa=""%a%"" ::
%2 echo 请允许管理员权限运行
%2 schtasks /query /tn sUdoAC_%username%>nul 2>nul
%2 if %errorlevel%==0 echo 已跳过 UAC
%2 if %errorlevel%==0 echo "%~s0","%aaa%","%cd%","",^1>%tmp%\~sUdoAC_task%random%%random%.TMP&schtasks /run /tn sUdoAC_%username%>nul&goto :EOF
%2 mshta vbscript:CreateObject("Shell.Application").ShellExecute("%~s0","- ::","%cd%","runas",1)(window.close)&goto :EOF
set a?=n
if not no"%a%"==no"-" set a?=y

title [===ZETASPACE===] 加载中...
echo [sUdoAC] 一个用于跳过 UAC 的小工具
echo.
::Get cmd host pid.
::[TODO] This powershell is tooooooo slow, try another way.
::(BUG OLD CODE, ONLY GETS PWSH PID.) for /f "usebackq" %%i in (`powershell (Get-CimInstance Win32_Process -Filter """ProcessId = '$pid'"""^).ParentProcessId`) do set thispid=%%i
for /F "usebackq" %%i in (`powershell (Get-CimInstance Win32_Process -Filter ("""ProcessID=""" + (Get-CimInstance Win32_Process -Filter """ProcessId='$pid'"""^).ParentProcessId^)^).ParentProcessId`) do set thispid=%%i
title [sUdoAC 控制台] 加载中...
::Set window and get admin.
color F0
for /f "tokens=3" %%i in ('tasklist /v /fi "PID eq %thispid%" /fo list^|findstr 窗口标题') do (echo %%i|findstr 管理员)>nul
if %errorlevel%==0 (set isadmin=y)else set isadmin=n
title [sUdoAC 控制台]
goto :maim
::maim = main mini

:main
echo [sUdoAC] 一个用于跳过 UAC 的小工具
echo.
:maim
cd %~dp0
schtasks /query /tn sUdoAC_%username%>nul 2>nul
set t=%errorlevel%
if exist %systemroot%\System32\sudo.cmd (set s=0)else set s=1
if %isadmin%eah==yeah echo ◆ 以管理员身份启动。
if not %isadmin%eah==yeah echo ◇ 以用户身份启动。
if %t%==0 echo ◆ sUdoAC_%username% 计划任务已存在。
if not %t%==0 echo ◇ sUdoAC_%username% 计划任务未创建。
if %s%==0 echo ◆ sudo 插件已安装。
if not %s%==0 echo ◇ sudo 插件未安装。
if if%3==ifuserinputmode echo ◆ 用户输入模式&echo.&echo 【取消并返回请输入“取消”或“q”】&goto :userinputmode
if %a?%==y echo ◆ 传入参数：%a%
echo.
if not %t%==0 echo ^> C 创建计划任务
if %t%==0 echo ^> C 重建计划任务
if not %t%==0 echo ^> D 删除计划任务 ×
if %t%==0 echo ^> D 删除计划任务
echo ^> L 列出所有 sUdoAC 计划任务
echo.
if not %s%==0 echo ^> I 安装 sudo 插件
if %s%==0 echo ^> I 重装 sudo 插件
if not %s%==0 echo ^> U 卸载 sudo 插件 ×
if %s%==0 echo ^> U 卸载 sudo 插件
echo.
echo ^> N 创建免 UAC 快捷方式（选择一个文件）
echo ^> M 创建免 UAC 快捷方式（读取已有的快捷方式）
echo.
echo ^> X 退出（叉掉窗口也行）

echo.
if %a?%==y echo 请按键^> M&echo.&goto :2
choice /c cmdlinux /n /m 请按键^>
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
echo "任务名","下次运行时间","模式"
schtasks /query /fo csv /nh|findstr sUdoAC
if not %errorlevel%==0 echo （无）
goto :mainover

:5
::Install sudo plugin
echo ----------------------------------------------------------------
echo.
echo ^> sudo ^& skip UAC
echo.
echo 这是一个实验性的插件，本质是一个叫做 sudo 的批处理，自动免 UAC 执行东西。
echo 完成度不高，可能还有各种奇奇怪怪的 bug 等着你去探索。
echo.
echo 使用方法：
echo sudo [command]
echo 　直接跟要执行的程序
echo sudo -h [command]
echo 　隐藏窗口
echo ... ^| sudo -p [command]
echo 　支持管道传入（但不支持传出）
echo.
echo 有一些小问题：
echo ·不能在当前窗口执行，因为原理是 vbs ShellExecute 来启动程序。若要运行 cmd 指令，请先 sudo cmd 再运行。
::.ShellExecute "application", "parameters", "dir", "verb", window
::   application   The file to execute (required)
::   parameters    Arguments for the executable
::   dir           Working directory
::   verb          The operation to execute (runas管理员运行/open/edit/print)
::   window        View mode application window (0=hide, 1=normal, 2=Min, 3=max, 4=restore, 5=current, 7=min/inactive, 10=default)
echo ·只是把所有双引号换成两个双引号，然后拆开塞到 sUdoAC 的 ShellExecute 里，可能有奇怪的字符转义问题。
echo ·默认打开目录为当前目录，需要修改的话把代码里的 %%cd%% 去掉。
echo.
echo 你确定要把 .\bin\sudo.cmd 复制(覆盖)到 %systemroot%\System32 吗？
echo.
choice /c aquickbrwnfxjmpsovthelzydg /n /m "按 Y 确定安装"^>
if not %errorlevel%==24 echo 已取消&goto :mainover
echo.
copy /v /y .\bin\sudo.cmd %systemroot%\System32\
goto :mainover

:7
::Uninstall sudo plugin
echo 删除 %systemroot%\System32\sudo.cmd ...
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
echo 【取消并返回请输入“取消”或“q”】
goto :userinputmode0
)
goto :mklink

:6
::New shortcut (file chooser)
if %a?%==y echo 请选择文件^> %a%
if %a?%==n set /p a=请选择文件^> <nul&for /f "usebackq delims=" %%i in (`mshta vbscript:CreateObject("Scripting.FileSystemObject"^).GetStandardStream(1^).WriteLine(CStr(CreateObject("WScript.Shell"^).Exec("mshta vbscript:""<input type=file id=a><script>a.click();new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).Write(a.value)[close()];</script>"""^).StdOut.ReadAll^)^)(window.close^)`) do set a=%%i&echo %%i
echo.
if if%a:~0,1%%a:~-1%==if"" set a=%a:~1,-1%
if exist "%a%" set a?=y
if "%a%"=="-" echo.&echo 错误：未选择文件！&set a?=n&set a=-&goto :mainover
if not exist "%a%" echo 错误：文件不存在！&echo ("%a%")&set a?=n&set a=-&goto :mainover
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
echo %a%|findstr \^<管理员_ 
if %errorlevel%==0 echo 快捷方式 %a% 已经以管理员身份运行，不能重复创建&set a?=n&set a=-&goto :mainover
echo a%ax%| findstr /I "\<a.lnk\>" >nul
if exist "%a%" (
if %errorlevel%==0 (call :lnk) else call :file
)else (
if "%a%"=="debug" call :debug
)

if "%a%"=="-" echo 创建目标为空&goto :mainover
if exist "%a%" echo 快捷方式 %a% 已存在，取消创建&set a?=n&set a=-&goto :mainover
echo 创建快捷方式：%a%
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
:: ↑ Too long to run.
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
echo 调试模式，手动输入创建内容
echo.
echo （示例）
echo 快捷方式：C:\Users\%username%\Desktop\cmd.lnk
echo ·目标：C:\Windows\System32\cmd.exe
echo ·参数：/k echo helloworld!
echo ·起始位置：C:\Windows\System32
echo ·快捷键：CTRL+SHIFT+F
echo ·运行方式：1　(1:常规窗口 3:最大化 7:最小化)
echo ·备注：一个32位的命令行程序，微软Windows系统基于Windows上的命令解释程序，类似于微软的DOS操作系统。
echo ·图标：C:\Windows\System32\cmd.exe,0
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
set /p a=快捷方式：^> 
set /p aT=目标：^> 
set /p aA=参数：^> 
set /p aS=起始位置：^> 
set /p aK=快捷键：^> 
set /p aR=运行方式：^> 
set /p aO=备注：^> 
set /p aC=图标：^> 
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
echo 快捷方式文件^> %an%%ax%
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
title [sUdoAC 控制台] 信息查询中
for /f "usebackq delims=" %%i in (`mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%').TargetPath;new ActiveXObject("Scripting.FileSystemObject").GetStandardStream(1).WriteLine(t);window.execScript('a(window.close)','vbs');"^|findstr .*`) do set aT=%%i&set aT?=y
if %aT?%==y (echo ·目标：%aT%)else echo ×目标：无
title [sUdoAC 控制台] 信息查询中.
for /f "usebackq delims=" %%i in (`mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%').Arguments;new ActiveXObject("Scripting.FileSystemObject").GetStandardStream(1).WriteLine(t);window.execScript('a(window.close)','vbs');"^|findstr .*`) do set aA=%%i&set aA?=y
if %aA?%==y (echo ·参数：%aA%)else echo ×参数：无
title [sUdoAC 控制台] 信息查询中..
for /f "usebackq delims=" %%i in (`mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%').WorkingDirectory;new ActiveXObject("Scripting.FileSystemObject").GetStandardStream(1).WriteLine(t);window.execScript('a(window.close)','vbs');"^|findstr .*`) do set aS=%%i&set aS?=y
if %aS?%==y (echo ·起始位置：%aS%)else echo ×起始位置：无
title [sUdoAC 控制台] 信息查询中...
for /f "usebackq delims=" %%i in (`mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%').Hotkey;new ActiveXObject("Scripting.FileSystemObject").GetStandardStream(1).WriteLine(t);window.execScript('a(window.close)','vbs');"^|findstr .*`) do set aK=%%i&set aK?=y
if %aK?%==y (echo ·快捷键：%aK%)else echo ×快捷键：无
title [sUdoAC 控制台] 信息查询中....
for /f "usebackq delims=" %%i in (`mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%').WindowStyle;new ActiveXObject("Scripting.FileSystemObject").GetStandardStream(1).WriteLine(t);window.execScript('a(window.close)','vbs');"^|findstr .*`) do set aR=%%i&set aR?=y
if %aR?%==y (echo ·运行方式：%aR%)else echo ×运行方式：无
title [sUdoAC 控制台] 信息查询中.....
for /f "usebackq delims=" %%i in (`mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%').Description;new ActiveXObject("Scripting.FileSystemObject").GetStandardStream(1).WriteLine(t);window.execScript('a(window.close)','vbs');"^|findstr .*`) do set aO=%%i&set aO?=y
if %aO?%==y (echo ·备注：%aO%)else echo ×备注：无
title [sUdoAC 控制台] 信息查询中......
for /f "usebackq delims=" %%i in (`mshta "javascript:t=new ActiveXObject("WScript.Shell").CreateShortcut('%ajs%').IconLocation;new ActiveXObject("Scripting.FileSystemObject").GetStandardStream(1).WriteLine(t);window.execScript('a(window.close)','vbs');"^|findstr .*`) do set aC=%%i&set aC?=y
if %aC?%==y (echo ·图标：%aC%)else echo ×图标：无
title [sUdoAC 控制台]
set a=%ap%管理员_%an%%ax%
for /f "usebackq delims=" %%a in (`echo "%aT%"`) do set aTp=%%~dpa&set aTn=%%~na&set aTx=%%~xa
echo a%aTx%| findstr /I "\<a.exe\>" >nul
if a"%aC:~,1%"==a"," if %errorlevel%==0 echo （目标文件为程序(.exe)，重定向图标到：%aT%%aC%）&set aC=%aT%%aC%
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
set a=%ap%管理员_%an%%ax%.lnk
set aT?=y
set aA?=n
set aS?=n
set aK?=n
set aR?=n
set aO?=n
set aC?=n

set a=%ap%管理员_%an%%ax%.lnk
for /f "usebackq delims=" %%a in (`echo "%aT%"`) do set aTp=%%~dpa&set aTn=%%~na&set aTx=%%~xa
echo a%aTx%| findstr /I "\<a.exe\>" >nul
if a"%aC:~,1%"==a"," if %errorlevel%==0 echo （目标文件为程序(.exe)，重定向图标到：%aT%%aC%）&set aC=%aT%%aC%
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
set /p a=请拖入文件到这里，或输入路径，然后回车^> 
echo.
if no%a%==no- echo 无文件&goto :userinputmode
if no%a%==no取消 sudoac&goto :EOF
if no%a%==noq sudoac&goto :EOF
if no%a%==nodebug goto :userinputmodeDEBUG
if if%a:~0,1%%a:~-1%==if"" set a=%a:~1,-1%
if not exist "%a%" goto :userinputmodeFILENOTEXIST
:userinputmodeGo
set a?=y
sudoac "%a%"
goto :EOF
:userinputmodeFILENOTEXIST
choice /n /m 文件不存在，确认继续吗？[Yes/No]
if not %errorlevel%==1 goto :userinputmode
goto :userinputmodeGo
:userinputmodeDEBUG
choice /n /m 进入手动调试，确认继续吗？[Yes/No]
if not %errorlevel%==1 goto :userinputmode
goto :userinputmodeGo

:userinputmode0
echo.
set a=-
set /p a=请拖入文件到这里，或输入路径，然后回车^> 
echo.
if no%a%==no- echo 无文件&goto :userinputmode0
if no%a%==no取消 goto :mainover
if no%a%==noq goto :mainover
if no%a%==nodebug goto :userinputmode0DEBUG
if if%a:~0,1%%a:~-1%==if"" set a=%a:~1,-1%
if not exist "%a%" goto :userinputmode0FILENOTEXIST
:userinputmode0Go
set a?=y
goto :2
:userinputmode0FILENOTEXIST
choice /n /m 文件不存在，确认继续吗？[Yes/No]
if not %errorlevel%==1 goto :userinputmode0
goto :userinputmode0Go
:userinputmode0DEBUG
choice /n /m 进入手动调试，确认继续吗？[Yes/No]
if not %errorlevel%==1 goto :userinputmode0
goto :userinputmode0Go