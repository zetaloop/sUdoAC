::Zetaspace sUdoAC experimental "sudo" plugin.
::Last Update: 2021/4/17
@echo off
if no%1==no goto :help
set sUdoAC_target=%1
set sUdoAC_args=%*
set sUdoAC_args?=0
set sUdoAC_pipe?=0
set sUdoAC_window=1
set arg1test=%1
set arg2test=%2
set arg1test=%arg1test:"=""%
set arg2test=%arg2test:"=""%
if "%arg1test:"=""%"=="""=""""" set arg1test=
if "%arg2test:"=""%"=="""=""""" set arg2test=


if "%arg1test%"=="-h" set sUdoAC_window=0&set sUdoAC_target=%2&set sUdoAC_args=%sUdoAC_args:~3%
if %sUdoAC_window%==1 if "%arg1test%"=="-p" set sUdoAC_pipe?=1&set sUdoAC_target=%2&set sUdoAC_args=%sUdoAC_args:~3%
if %sUdoAC_window%==0 if "%arg2test%"=="-p" set sUdoAC_pipe?=1&set sUdoAC_target=%3&set sUdoAC_args=%sUdoAC_args:~3%
if "%arg2test%"=="-h" set sUdoAC_window=0&set sUdoAC_target=%3&set sUdoAC_args=%sUdoAC_args:~3%
if %sUdoAC_pipe?%==1 if no"%arg2test%"==no goto :help
if %sUdoAC_window%==0 if no"%arg2test%"==no goto :help
if %sUdoAC_pipe?%==1 if %sUdoAC_window%==0 if no%3==no goto :help
if %sUdoAC_pipe?%==1 for /f "delims=" %%p in ('findstr .*') do set sUdoAC_pipe=%%p
set sUdoAC_tegrat=%sUdoAC_target%

:while
set sUdoAC_args=%sUdoAC_args:~1%
set sUdoAC_tegrat=%sUdoAC_tegrat:~1%
set argstest=%sUdoAC_args:"=""%
set tegrattest=%sUdoAC_tegrat:"=""%
if "%argstest:"=""%"=="""=""""" set argstest=
if "%tegrattest:"=""%"=="""=""""" set tegrattest=
if not "no%tegrattest%"=="no" goto :while
if not "no%argstest%"=="no" set sUdoAC_args=%sUdoAC_args:~1%
::if not "no%sUdoAC_tegrat%"=="no" goto :while
::if not "no%sUdoAC_args%"=="no" set sUdoAC_args=%sUdoAC_args:~1%
set sUdoAC_target=%sUdoAC_target:"=""%
if not "no%argstest%"=="no" set sUdoAC_args?=1
if %sUdoAC_args?%==1 set sUdoAC_args=%sUdoAC_args:"=""%

if not %sUdoAC_pipe?%==1 if %sUdoAC_args?%==1 echo "%sUdoAC_target%","%sUdoAC_args%","%cd%","",^%sUdoAC_window%>%tmp%\~sUdoAC_task%random%%random%.TMP
if not %sUdoAC_pipe?%==1 if not %sUdoAC_args?%==1 echo "%sUdoAC_target%","","%cd%","",^%sUdoAC_window%>%tmp%\~sUdoAC_task%random%%random%.TMP
if %sUdoAC_pipe?%==1 echo "cmd","/k cd %cd%&echo %sUdoAC_pipe%^^|%sUdoAC_target% %sUdoAC_args%","%cd%","",^%sUdoAC_window%>%tmp%\~sUdoAC_task%random%%random%.TMP
schtasks /run /tn sUdoAC_%username%>nul

goto :EOF
:help
echo Usage:
echo sudo [command]
echo sudo -h [command] (Hide Window)
echo ... ^| sudo -p [command]
goto :EOF






::OLD VERSIONs
::|||
::vvv





@echo on
if no%1==no echo Usage: sudo [command]&goto :EOF
set sUdoAC_target=%1
set sUdoAC_args=
set sUdoAC_args?=1
if not no%2==no (set sUdoAC_args=%2)else set sUdoAC_args?=0&goto :ok
if not no%3==no (set sUdoAC_args=%sUdoAC_args% %3)else goto :ok
if not no%4==no (set sUdoAC_args=%sUdoAC_args% %4)else goto :ok
if not no%5==no (set sUdoAC_args=%sUdoAC_args% %5)else goto :ok
if not no%6==no (set sUdoAC_args=%sUdoAC_args% %6)else goto :ok
if not no%7==no (set sUdoAC_args=%sUdoAC_args% %7)else goto :ok
if not no%8==no (set sUdoAC_args=%sUdoAC_args% %8)else goto :ok
if not no%9==no (set sUdoAC_args=%sUdoAC_args% %9)
:ok
set sUdoAC_target=%sUdoAC_target:"=""%
if %sUdoAC_args?%==1 set sUdoAC_args=%sUdoAC_args:"=""%

if %sUdoAC_args?%==1 echo "%sUdoAC_target%","%sUdoAC_args%","","",^5>%tmp%\~sUdoAC_task%random%%random%.TMP
if not %sUdoAC_args?%==1 echo "%sUdoAC_target%","","","",^5>%tmp%\~sUdoAC_task%random%%random%.TMP
schtasks /run /tn sUdoAC_%username%>nul





@echo on
if no%1==no echo Usage: sudo [command]&goto :EOF

set sUdoAC_target=
if not no%1==no (set sUdoAC_target=%1)else goto :ok
if not no%2==no (set sUdoAC_target=%sUdoAC_args% %2)else goto :ok
if not no%3==no (set sUdoAC_target=%sUdoAC_args% %3)else goto :ok
if not no%4==no (set sUdoAC_target=%sUdoAC_args% %4)else goto :ok
if not no%5==no (set sUdoAC_target=%sUdoAC_args% %5)else goto :ok
if not no%6==no (set sUdoAC_target=%sUdoAC_args% %6)else goto :ok
if not no%7==no (set sUdoAC_target=%sUdoAC_args% %7)else goto :ok
if not no%8==no (set sUdoAC_target=%sUdoAC_args% %8)else goto :ok
if not no%9==no (set sUdoAC_target=%sUdoAC_args% %9)
:ok
set sUdoAC_target=%sUdoAC_target:"=""%

echo "runas","/user administrator %sUdoAC_target%","","",^1>%tmp%\~sUdoAC_task%random%%random%.TMP
schtasks /run /tn sUdoAC_%username%>nul