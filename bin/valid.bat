@echo off
setlocal EnableDelayedExpansion

set XERE=%~dp0
set XERE=%XERE:~0,-1%
set HERE=%XERE:\=/%
rem echo HERE=%HERE%

:: ====================================================================================
::
::     evaluate options
::
:: ====================================================================================

:: defaults
set ENAME=
set XPATH=
set ELEM_PAR=
set XPATH_PAR=
set PARSE=
set PARSE_PAR=
set MODE=val
set MODE_PAR=


:NEXTPAR
set name=%~1
set char1=%name:~0,1%
if "%char1%" neq "-" goto :ENDPAR
shift
set value=%~1

if "%value%"=="" goto :ENDPAR
rem echo NAME:%name%.
rem echo VALUE:%value: =%

if "%name%"=="-e" (
   set ENAME=%value: =%
   set ENAME_PAR= -b ename=%value: =%
   shift
) else if "%name%"=="-x" (
   echo BRANCH:-X
   set XPATH=%value: =%
   set XPATH_PAR= -b "xpath=%value: =%"
   goto :NEXTPAR
   shift
) else if "%name%"=="-p" (
   set XPATH=true   
   set XPATH_PAR= -b parse=true
) else if "%name%"=="-m" (
   set MODE=%value: =%
   shift
) else (
   echo Unknown option: %name%
   echo Supported options: 
   echo    -e ename  
   echo    -x xpath
   echo    -m mode
   echo    -p   
   echo Aborted.
   exit /b
)
rem echo MODE SET #2
rem echo XPATH_PAR=%XPATH_PAR%
goto :NEXTPAR
:ENDPAR
set MODE_PAR= -b mode=%MODE%
  
set DOC=%~1
set XSD=%~2
rem if "%MODE%"=="val" (
rem     if "%DOC%"=="" set /prompt DOC=Enter doc(s^) to be validated (e.g. /a/b/foo.xml /a/b/c/*.xml^): 
rem     if "%XSD%"=="" set /prompt XSD=Enter xsd(s^) to be validated (e.g. /a/b/foo.xsd /a/b/c/*.xsd^):
rem     echo DOC=!DOC!
rem     echo XSD=!XSD! 
rem )

rem echo basex %MODE_PAR% %ENAME_PAR% %XPATH_PAR% -b "doc=%DOC%" -b "xsd=!XSD!" %HERE%/valid.xq
call basex %MODE_PAR% %ENAME_PAR% %XPATH_PAR% -b "doc=%DOC%" -b "xsd=!XSD!" %HERE%/valid.xq
