#!/bin/sh

# Oxygen WebHelp Plugin
# Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.


# The path of the Java Virtual Machine
WEBHELP_JAVA=java
if [ -f "${JAVA_HOME}/bin/java" ]
then
  WEBHELP_JAVA="${JAVA_HOME}/bin/java"
fi

PRG=$0
while [ -h "$PRG" ]; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '^.*-> \(.*\)$' 2>/dev/null`
    if expr "$link" : '^/' 2> /dev/null >/dev/null; then
        PRG="$link"
    else
        PRG="`dirname "$PRG"`/$link"
    fi
done

WEBHELP_HOME=`dirname "$PRG"`

# Absolutize dir
oldpwd=`pwd`
cd "${WEBHELP_HOME}"; WEBHELP_HOME=`pwd`
cd "${oldpwd}"; unset oldpwd

# The path of the DITA Open Toolkit install directory
DITA_OT_INSTALL_DIR="$(dirname "$(dirname "${WEBHELP_HOME}")")"

# One of the following three values: 
#      webhelp
#      webhelp-responsive
#      webhelp-feedback
#      webhelp-mobile
TRANSTYPE=webhelp-responsive

# The path of the directory of the input DITA map file
DITA_MAP_BASE_DIR="${HOME}/OxygenXMLEditor/samples/dita/mobile-phone"

# The name of the input DITA map file
DITAMAP_FILE=mobilePhone.ditamap

# The name of the DITAVAL input filter file 
DITAVAL_FILE=x1000.ditaval

# The path of the directory of the DITAVAL input filter file
DITAVAL_DIR="${HOME}/OxygenXMLEditor/samples/dita/mobile-phone/ditaval"

"$WEBHELP_JAVA"\
 -Xmx512m\
 -classpath\
 "$DITA_OT_INSTALL_DIR/tools/ant/lib/ant-launcher.jar:$DITA_OT_INSTALL_DIR/lib/ant-launcher.jar"\
 "-Dant.home=$DITA_OT_INSTALL_DIR/tools/ant" org.apache.tools.ant.launch.Launcher\
  -lib "$DITA_OT_INSTALL_DIR/plugins/com.oxygenxml.webhelp.classic/lib"\
 -lib "$DITA_OT_INSTALL_DIR"\
 -lib "$DITA_OT_INSTALL_DIR/lib"\
 -lib "$DITA_OT_INSTALL_DIR/lib/saxon"\
 -lib "$DITA_OT_INSTALL_DIR/plugins/com.oxygenxml.highlight/lib/xslthl-2.1.1.jar"\
 -f "$DITA_OT_INSTALL_DIR/build.xml"\
 "-Dtranstype=$TRANSTYPE"\
 "-Dbasedir=$DITA_MAP_BASE_DIR"\
 "-Doutput.dir=$DITA_MAP_BASE_DIR/out/$TRANSTYPE"\
 "-Ddita.temp.dir=$DITA_MAP_BASE_DIR/temp/$TRANSTYPE"\
 "-Dargs.hide.parent.link=no"\
 "-Dargs.filter=$DITAVAL_DIR/$DITAVAL_FILE"\
 "-Ddita.dir=$DITA_OT_INSTALL_DIR"\
 "-Dargs.xhtml.classattr=yes"\
 "-Dargs.input=$DITA_MAP_BASE_DIR/$DITAMAP_FILE"\
 "-Dwebhelp.skin.css=$DITA_OT_INSTALL_DIR/plugins/com.oxygenxml.webhelp.classic/predefined-skins/dita/oxygen/skin.css"\
 "-DbaseJVMArgLine=-Xmx384m"