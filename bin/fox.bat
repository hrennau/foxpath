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

:: defaults
set PARSE=
set SEP=/

:NEXTPAR
set name=%~1
set char1=%name:~0,1%
if "%char1%" neq "-" goto :ENDPAR
shift
set value=%~1

if "%value%"=="" goto :ENDPAR

if "%name%"=="-p" (
   set PARSE=Y
) else if "%name%"=="-b" (
   set SEP=\   
) else (
   echo Unknown option: %name%
   echo Supported options: 
   echo    -p  
   echo Aborted.
   exit /b
)
goto :NEXTPAR
:ENDPAR
  
set FOXPATH=%~1

if "%FOXPATH%"=="?" (
    echo Usage: foxpath [-p] [-b] foxpath
    echo foxpath : a foxpath expression
    echo -p      : show the parse tree, rather than evaluate the expression
    echo -b      : within the foxpath expression path and foxpath operator are swapped;
    echo           using the option: path operator = / , foxpath operator = \
    echo           without option:   path operator = \ , foxpath operator = /
    exit /b
)
if "%PARSE%"=="Y" (set MODE=parse) else (set MODE=eval)
set CMD=basex -b mode=%MODE% -b sep=%SEP% -b "foxpath=%FOXPATH%" %HERE%/fox.xq
rem echo %CMD%
%CMD%
