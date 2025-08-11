@echo off
setlocal EnableDelayedExpansion

set XERE=%~dp0
set XERE=%XERE:~0,-1%
set HERE=%XERE:\=/%

:: ====================================================================================
::
::     evaluate options
::
:: ====================================================================================
REM echo "INPUT1: %1"
REM echo "INPUT2: %2"
REM echo "=========="
:: defaults
set XOPT=
set YOPT=
REM echo "Expression: %1%"

:NEXTPAR
set name="%~1"
set char1=%name:~1,1%
if "%char1%" neq "-" goto :ENDPAR

rem if this is a parameter name, remove quote (by re-assigning to %~1)
rem the quote was needed for argument expressions containing <
set name=%~1

shift
set value=%~1

if "%value%"=="" goto :ENDPAR

if "%name%"=="-x" (
   set XOPT=Y
 ) else if "%name%"=="-y" (
   set CONTEXT_ITEM=!VALUE!
   shift
) else (
   echo Unknown option: %name%
   echo Supported options: 
   echo    -x -y
   echo Aborted.
   exit /b
)
goto :NEXTPAR
:ENDPAR 
set FOXHELP=%name%
REM echo foxpath=%foxpath%
if %FOXHELP%=="?" echo NO else (echo YES)

if %FOXHELP%=="?" (
    echo Usage: foxhelp efunctions
    exit /b
)
set OPT_SER=-s indent=yes

SET OP=%1
SET FILTER=%2
basex %OPT_SER% -b op=%OP% -b filter=%FILTER% %HERE%/foxhelp.xq
