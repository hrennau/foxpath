<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:relpath="http://dita2indesign/functions/relpath"

  exclude-result-prefixes="xs xd relpath"
  version="2.0">
  <!-- =====================================================
       Top-level XSLT Module for DITA 1.3 FO support
       
       Copyright (c) DITA Community
       ===================================================== -->
  
  <xsl:import href="plugin:org.dita-community.common.xslt:xsl/relpath_util.xsl"/>
  <xsl:import href="plugin:org.dita-community.common.xslt:xsl/dita-support-lib.xsl"/>
  
  <xsl:include href="plugin:org.dita-community.dita13.html:xsl/mathmlSvgCommon.xsl"/>
  <xsl:include href="plugin:org.dita-community.dita13.html:xsl/localFunctions.xsl"/>
  <!-- <xsl:include href="dita13base2fo.xsl"/>  -->
  <xsl:include href="dita-troubleshooting2fo.xsl"/>
  <xsl:include href="equation-d2fo.xsl"/>
  <!--<xsl:include href="hi-d2fo.xsl"/>-->
  <xsl:include href="learning2domain2fo.xsl"/>
  <xsl:include href="mathml-d2fo.xsl"/>
  <xsl:include href="svg-d2fo.xsl"/>
  <!--<xsl:include href="xml-d2fo.xsl"/>-->
  
  <dita:extension id="xsl.dita13pdf" 
    behavior="org.dita.dost.platform.ImportXSLAction" 
    xmlns:dita="http://dita-ot.sourceforge.net"/>

</xsl:stylesheet>