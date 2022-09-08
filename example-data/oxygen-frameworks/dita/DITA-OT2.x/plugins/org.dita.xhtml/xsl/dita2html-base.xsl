<?xml version="1.0" encoding="UTF-8"?><!--
This file is part of the DITA Open Toolkit project.

Copyright 2004, 2005 IBM Corporation

See the accompanying LICENSE file for applicable license.
--><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

<!-- idit2htm.xsl   main stylesheet
 | Convert DITA topic to HTML; "single topic to single web page"-level view
 |
-->

<!-- stylesheet imports -->
<!-- the main dita to xhtml converter -->
<xsl:import href="xslhtml/dita2htmlImpl.xsl"/>

<!-- the dita to xhtml converter for concept documents -->
<xsl:import href="xslhtml/conceptdisplay.xsl"/>

<!-- the dita to xhtml converter for glossentry documents -->
<xsl:import href="xslhtml/glossdisplay.xsl"/>

<!-- the dita to xhtml converter for task documents -->
<xsl:import href="xslhtml/taskdisplay.xsl"/>

<!-- the dita to xhtml converter for reference documents -->
<xsl:import href="xslhtml/refdisplay.xsl"/>

<!-- user technologies domain -->
<xsl:import href="xslhtml/ut-d.xsl"/>
<!-- software domain -->
<xsl:import href="xslhtml/sw-d.xsl"/>
<!-- programming domain -->
<xsl:import href="xslhtml/pr-d.xsl"/>
<!-- ui domain -->
<xsl:import href="xslhtml/ui-d.xsl"/>
<!-- highlighting domain -->
<xsl:import href="xslhtml/hi-d.xsl"/>
<!-- abbreviated-form domain -->
<xsl:import href="xslhtml/abbrev-d.xsl"/>
<xsl:import href="xslhtml/markup-d.xsl"/>
<xsl:import href="xslhtml/xml-d.xsl"/>
<!-- Integrate support for flagging with dita-ot pseudo-domain -->
<xsl:import href="xslhtml/htmlflag.xsl"/>  
  
<xsl:import xmlns:dita="http://dita-ot.sourceforge.net" href="../../mathml/xhtmlMathML.xsl"/><xsl:import href="../../com.oxygenxml.editlink/xhtml.xsl"/><xsl:import href="../../com.oxygenxml.highlight/xhtmlHighlight.xsl"/><xsl:import href="../../com.oxygenxml.html.custom/custom.xsl"/><xsl:import href="../../com.oxygenxml.html.embed/xhtmlEmbed.xsl"/><xsl:import href="../../com.oxygenxml.image.float/customXHTML.xsl"/><xsl:import href="../../com.oxygenxml.media/xhtmlMedia.xsl"/><xsl:import href="../../org.dita-community.common.xslt/xsl/commonXsltExtensionSupport.xsl"/><xsl:import href="../../org.dita-community.dita13.html/xsl/dita13Vocab2Html.xsl"/>

<!-- the dita to xhtml converter for element reference documents - not used now -->
<!--<xsl:import href="elementrefdisp.xsl"/>-->

<!-- root rule -->
<xsl:template match="/">
  <xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>