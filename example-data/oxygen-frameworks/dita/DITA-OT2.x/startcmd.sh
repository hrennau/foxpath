#!/bin/sh
# Generated file, do not edit manually"
echo "NOTE: The startcmd.sh has been deprecated, use the 'dita' command instead."

realpath() {
  case $1 in
    /*) echo "$1" ;;
    *) echo "$PWD/${1#./}" ;;
  esac
}

if [ "${DITA_HOME:+1}" = "1" ] && [ -e "$DITA_HOME" ]; then
  export DITA_DIR="$(realpath "$DITA_HOME")"
else #elif [ "${DITA_HOME:+1}" != "1" ]; then
  export DITA_DIR="$(dirname "$(realpath "$0")")"
fi

if [ -f "$DITA_DIR"/bin/ant ] && [ ! -x "$DITA_DIR"/bin/ant ]; then
  chmod +x "$DITA_DIR"/bin/ant
fi

export ANT_OPTS="-Xmx512m $ANT_OPTS"
export ANT_OPTS="$ANT_OPTS -Djavax.xml.transform.TransformerFactory=net.sf.saxon.TransformerFactoryImpl"
export ANT_HOME="$DITA_DIR"
export PATH="$DITA_DIR"/bin:"$PATH"

NEW_CLASSPATH="$DITA_DIR/lib:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/ant-apache-resolver-1.10.1.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/ant-launcher.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/ant.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/commons-codec-1.10.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/commons-io-2.5.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/dost-configuration.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/dost-patches.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/dost.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/guava-19.0.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/jsearch.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/logback-classic-1.2.1.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/logback-core-1.2.1.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/slf4j-api-1.7.23.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/xml-apis-1.4.01.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/lib/xml-resolver-1.2.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/com.elovirta.dita.markdown/markdown-1.3.0.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/com.elovirta.dita.markdown/pegdown-1.6.0.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/com.elovirta.dita.markdown/asm-analysis-5.0.3.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/com.elovirta.dita.markdown/asm-tree-5.0.3.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/com.elovirta.dita.markdown/asm-util-5.0.3.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/com.elovirta.dita.markdown/asm-5.0.3.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/com.elovirta.dita.markdown/parboiled-core-1.1.7.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/com.elovirta.dita.markdown/parboiled-java-1.1.7.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/com.elovirta.dita.markdown/snakeyaml-1.18.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2/lib/fo.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/com.oxygenxml.highlight/lib/xslthl-2.1.1.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/com.oxygenxml.webhelp.classic/lib/ant-contrib-1.0b3.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/com.oxygenxml.webhelp.responsive/lib/ant-contrib-1.0b3.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.odt/lib/odt.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.axf/lib/axf.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.fop/lib/avalon-framework-api-4.3.1.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.fop/lib/avalon-framework-impl-4.3.1.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.fop/lib/batik-anim-1.8.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.fop/lib/batik-awt-util-1.8.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.fop/lib/batik-bridge-1.8.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.fop/lib/batik-css-1.8.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.fop/lib/batik-dom-1.8.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.fop/lib/batik-ext-1.8.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.fop/lib/batik-extension-1.8.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.fop/lib/batik-gvt-1.8.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.fop/lib/batik-parser-1.8.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.fop/lib/batik-script-1.8.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.fop/lib/batik-svg-dom-1.8.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.fop/lib/batik-svggen-1.8.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.fop/lib/batik-transcoder-1.8.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.fop/lib/batik-util-1.8.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.fop/lib/batik-xml-1.8.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.fop/lib/commons-logging-1.0.4.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.fop/lib/fop-2.1.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.fop/lib/xmlgraphics-commons-2.1.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.fop/lib/xml-apis-ext-1.3.04.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.pdf2.xep/lib/xep.jar:$NEW_CLASSPATH"
NEW_CLASSPATH="$DITA_DIR/plugins/org.dita.wordrtf/lib/wordrtf.jar:$NEW_CLASSPATH"
if test -n "$CLASSPATH"; then
  export CLASSPATH="$NEW_CLASSPATH":"$CLASSPATH"
else
  export CLASSPATH="$NEW_CLASSPATH"
fi

cd "$DITA_DIR"
"$SHELL"
