<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc"
  xmlns:index="http://www.oxygenxml.com/ns/webhelp/index" 
  xmlns:File="java:java.io.File"
  xmlns:oxygen="http://www.oxygenxml.com/functions" 
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:whc="http://www.oxygenxml.com/webhelp/components" xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">

  <!-- Localization of text strings displayed in Webhelp output. -->
  <xsl:import href="../util/relpath_util.xsl"/>
  
  <xsl:import href="../util/fixupNS.xsl"/>
  <!-- Used to expand Webhelp components -->
  <xsl:import href="../template/commonComponentsExpander.xsl"/>
  <xsl:import href="../template/mainPageComponentsExpander.xsl"/>

  <xsl:import href="../util/dita-utilities.xsl"/> 
  <!-- Localization of text strings displayed in Webhelp output. -->
  <xsl:import href="../util/functions.xsl"/>    
  
  <xsl:include href="../util/macroExpander.xsl"/>
  
  <!-- Declares all available parameters -->
  <xsl:include href="params.xsl"/>
  
  <xsl:output 
    method="xhtml" 
    encoding="UTF-8"
    indent="no"
    doctype-public=""
    doctype-system="about:legacy-compat"
    omit-xml-declaration="yes"/>
  
  <xsl:variable name="toc" select="document(oxygen:makeURL($TOC_XML_FILEPATH))/toc:toc"/>

  <xsl:variable name="webhelp_language" select="oxygen:getParameter('webhelp.language')"/>
  
  <xsl:variable name="i18n_context">
    <!-- EXM-36308 - Generate the lang attributes in a temporary element -->
      <i18n_context>
        <xsl:attribute name="xml:lang" select="$webhelp_language"/>
        <xsl:attribute name="lang" select="$webhelp_language"/>
        <xsl:attribute name="dir" select="oxygen:getParameter('webhelp.page.direction')"/>
      </i18n_context>
  </xsl:variable>
  
  <!-- 
    Creates the index.html 
  -->
  <xsl:template match="/">
      <xsl:variable name="mainPageTemplate">
        <xsl:apply-templates select="." mode="fixup_XHTML_NS"/>
      </xsl:variable>
      
      <xsl:apply-templates select="$mainPageTemplate" mode="copy_template">
        <!-- EXM-36737 - Context node used for messages localization -->
        <xsl:with-param name="i18n_context" select="$i18n_context/*" tunnel="yes" as="element()"/>
      </xsl:apply-templates>
  </xsl:template>
</xsl:stylesheet>
