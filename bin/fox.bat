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
set UTREE_DIRS=
set UGRAPH_ENDPOINTS=
set GITHUB_TOKEN=/git/token

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

if "%name%"=="-p" (
   set PARSE=Y
) else if "%name%"=="-f" (
   set ISFILE=Y
 ) else if "%name%"=="-b" (
   set SEP=\   
 ) else if "%name%"=="-c" (
   set SEP="%%"   
 ) else if "%name%"=="-i" (
   set CONTEXT_ITEM=!VALUE!
   shift   
 ) else if "%name%"=="-t" (
   set UTREE_DIRS=!VALUE!
   shift   
 ) else if "%name%"=="-g" (
   set UGRAPH_ENDPOINTS=!VALUE!
   shift   
 ) else if "%name%"=="-h" (
   set GITHUB_TOKEN=!VALUE!
   shift   
 ) else if "%name%"=="-v" (
   set VARS=!VARS!#######!VALUE!   
   shift
) else (
   echo Unknown option: %name%
   echo Supported options: 
   echo    -b -c -f -g -t -v   
   echo Aborted.
   exit /b
)
goto :NEXTPAR
:ENDPAR 
set foxpath=%name%
if %foxpath%=="?" echo NO else (echo YES)

if %FOXPATH%=="?" (
    echo Usage: fox [-f] [-p] [-b] [-c] [-t utree-dirs] [-g ugraph-endpoints] [-h github-token] [-v name=value]* foxpath
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
    echo -c      : foxpath operator = / , path operator = %%
    echo -h github-token : 
    echo           a text file containing the github API token obtained from here:
    echo             https://github.com/settings/tokens    
    echo           default: /git/token
    echo -t directories : 
    echo           directories containing UTREE documents defining literal file systems;
    echo             directory paths are whitespace-separated; if a directory path
    echo             starts with basex://, the value is interpreted as the
    echo             name of a BaseX data base containing UTREE documents with paths
    echo             dbname/utree-*
    echo -g endpoints : 
    echo           SPARQL endpoints exposing UGRAPH graphs defining literal file systems;
    echo             endpoints are whitespace-separated
    echo -i context-dir : 
    echo           a folder to be used as initial context item    
    echo -v "name=value" 
    echo         : name and value of an external variable
    exit /b
)
if "%PARSE%"=="Y" (set MODE=parse) else (set MODE=eval)
if "%ISFILE%"=="Y" (set ISFILE=true) else (set ISFILE=false)
set OPT_UTREE_DIRS=
set OPT_UGRAPH_ENDPOINTS=
set OPT_CONTEXT_ITEM=
if not "%UTREE_DIRS%"=="" (set OPT_UTREE_DIRS=-b "utreeDirs=%UTREE_DIRS%")
if not "%UGRAPH_ENDPOINTS%"=="" (set OPT_UGRAPH_ENDPOINTS=-b "ugraphEndpoints=%UGRAPH_ENDPOINTS%")
set OPT_GITHUB_TOKEN=-b "{http://www.ttools.org/xquery-functions}githubToken=%GITHUB_TOKEN%"
if not "%CONTEXT_ITEM%"=="" (set OPT_CONTEXT_ITEM=-b "context=%CONTEXT_ITEM%")
rem echo HERE=%HERE%
basex -b isFile=%ISFILE% -b mode=%MODE% -b sep=%SEP% -b foxpath=%foxpath% %OPT_UTREE_DIRS% %OPT_UGRAPH_ENDPOINTS% %OPT_GITHUB_TOKEN% %OPT_CONTEXT_ITEM% -b "vars=%VARS%" %HERE%/fox.xq
