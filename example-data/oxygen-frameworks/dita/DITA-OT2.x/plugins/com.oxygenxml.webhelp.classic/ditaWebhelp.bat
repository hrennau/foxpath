@echo off

REM  Oxygen WebHelp Plugin
REM  Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.


REM The path of the Java Virtual Machine
set WEBHELP_JAVA=java.exe
if exist "%JAVA_HOME%\bin\java.exe" set WEBHELP_JAVA="%JAVA_HOME%\bin\java.exe"

REM The path of the DITA Open Toolkit install directory
set DITA_OT_INSTALL_DIR=%~dp0\..\..

REM One of the following three values: 
REM      webhelp
REM      webhelp-responsive
REM      webhelp-feedback
REM      webhelp-mobile
set TRANSTYPE=webhelp-responsive

REM The path of the directory of the input DITA map file
set DITA_MAP_BASE_DIR="%USERPROFILE%\Documents\OxygenXMLEditor\samples\dita\mobile-phone"

REM The name of the input DITA map file
set DITAMAP_FILE=mobilePhone.ditamap

REM The name of the DITAVAL input filter file 
set DITAVAL_FILE=x1000.ditaval

REM The path of the directory of the DITAVAL input filter file
set DITAVAL_DIR="%USERPROFILE%\Documents\OxygenXMLEditor\samples\dita\mobile-phone\ditaval"

%WEBHELP_JAVA%^
 -Xmx512m^
 -classpath^
 "%DITA_OT_INSTALL_DIR%\tools\ant\lib\ant-launcher.jar;%DITA_OT_INSTALL_DIR%\lib\ant-launcher.jar"^
 "-Dant.home=%DITA_OT_INSTALL_DIR%\tools\ant" org.apache.tools.ant.launch.Launcher^
 -lib "%DITA_OT_INSTALL_DIR%\plugins\com.oxygenxml.webhelp.classic\lib"^
 -lib "%DITA_OT_INSTALL_DIR%"^
 -lib "%DITA_OT_INSTALL_DIR%\lib"^
 -lib "%DITA_OT_INSTALL_DIR%\lib\saxon"^
 -lib "%DITA_OT_INSTALL_DIR%\plugins\com.oxygenxml.highlight\lib\xslthl-2.1.1.jar.jar"^
 -f "%DITA_OT_INSTALL_DIR%\build.xml"^
 "-Dtranstype=%TRANSTYPE%"^
 "-Dbasedir=%DITA_MAP_BASE_DIR%"^
 "-Doutput.dir=%DITA_MAP_BASE_DIR%\out\%TRANSTYPE%"^
 "-Ddita.temp.dir=%DITA_MAP_BASE_DIR%\temp\%TRANSTYPE%"^
 "-Dargs.hide.parent.link=no"^
 "-Dargs.filter=%DITAVAL_DIR%\%DITAVAL_FILE%"^
 "-Ddita.dir=%DITA_OT_INSTALL_DIR%"^
 "-Dargs.xhtml.classattr=yes"^
 "-Dargs.input=%DITA_MAP_BASE_DIR%\%DITAMAP_FILE%"^
 "-Dwebhelp.skin.css=%DITA_OT_INSTALL_DIR%\plugins\com.oxygenxml.webhelp.classic\predefined-skins\dita\oxygen\skin.css"^
 "-DbaseJVMArgLine=-Xmx384m"