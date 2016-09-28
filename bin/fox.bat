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
set ISFILE=
set SEP=/
set VARS=
set UTREEDIR=

:NEXTPAR
set name="%~1"
set char1=%name:~1,1%
if "%char1%" neq "-" goto :ENDPAR

rem if this is a paraemeter name, remove quote (by re-assigning to %~1)
rem the quote was needed for argument expressions containing <
set name=%~1

shift
set value=%~1

if "%value%"=="" goto :ENDPAR

if "%name%"=="-p" (
   set PARSE=Y
) else if "%name%"=="-f" (
   set ISFILE=Y
 ) else if "%name%"=="-b" (
   set SEP=\   
 ) else if "%name%"=="-u" (
   set UTREEDIR=!VALUE!
   shift   
 ) else if "%name%"=="-v" (
   set VARS=!VARS!#######!VALUE!   
   shift
) else (
   echo Unknown option: %name%
   echo Supported options: 
   echo    -f -p -b   
   echo Aborted.
   exit /b
)
goto :NEXTPAR
:ENDPAR 
set foxpath=%name%
if %foxpath%=="?" echo NO else (echo YES)

if %FOXPATH%=="?" (
    echo Usage: fox [-f] [-p] [-b] [-u uri-trees-dir] [-v name=value]* foxpath
    echo foxpath : a foxpath expression, or a file containing a foxpath expression
    echo.
    echo -f      : the foxpath parameter is not a foxpath expression, but the path or URI of 
    echo           a file containing the foxpath expression;
    echo.
    echo           if the value of foxpath has a trailing # name, e.g.
    echo              foxlib.xml#niem30
    echo.
    echo           the substring before # identifies a foxpath lib, which is an XML file 
    echo           containing foxpath elements with a name attribute and a foxpath expression 
    echo           as content; the substring after # selects the foxpath element with
    echo           a corresponding @name attribute; example of a foxlib:
    echo.
    echo           ^<foxlib^>                   
    echo               ^<foxpath name="niem30" doc="all niem-30 XSDs"^>
    echo           /xsdbase/niem-3.0//*.xsd
    echo               ^</foxpath^>
    echo               ^<foxpath name="niem30-count doc="a count of all niem-30 XSDs"^>
    echo           count(/xsdbase/niem-3.0//*.xsd^)
    echo               ^/foxpath^>
    echo           ^</foxlib^>
    echo.
    echo -p      : show the parse tree, rather than evaluate the expression
    echo -b      : within the foxpath expression path and foxpath operator are swapped;
    echo           using the option: path operator = / , foxpath operator = \
    echo           without option:   path operator = \ , foxpath operator = /
    echo -v "name=value" 
    echo         : name and value of an external variable
    exit /b
)
if "%PARSE%"=="Y" (set MODE=parse) else (set MODE=eval)
if "%ISFILE%"=="Y" (set ISFILE=true) else (set ISFILE=false)
set OPT_UTREEDIR=
if not "%UTREEDIR%"=="" (set OPT_UTREEDIR=-b utreeDir=%UTREEDIR%)
basex -b isFile=%ISFILE% -b mode=%MODE% -b sep=%SEP% -b foxpath=%foxpath% %OPT_UTREEDIR% -b "vars=%VARS%" %HERE%/fox.xq
