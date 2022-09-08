<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

 Generates the search results page for the WebHelp Responsive transformation.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc"
  xmlns:index="http://www.oxygenxml.com/ns/webhelp/index" 
  xmlns:File="java:java.io.File"
  xmlns:oxygen="http://www.oxygenxml.com/functions" 
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:whc="http://www.oxygenxml.com/webhelp/components" xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
  
  <xsl:import href="../util/relpath_util.xsl"/>
  <xsl:import href="../util/fixupNS.xsl"/>
    
  <!-- Used to expand Webhelp components -->
  <xsl:import href="../template/commonComponentsExpander.xsl"/>
  
  <!-- Localization of text strings displayed in Webhelp output. -->
  <xsl:import href="../util/dita-utilities.xsl"/> 
 
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
  
  <!--
    A temporary node used to keep @lang and @dir attributes.
  -->
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
    Creates the Search file using the given template.
  -->
  <xsl:template match="/">
      <xsl:apply-templates mode="copy_template">
        <!-- EXM-36737 - Context node used for messages localization -->
        <xsl:with-param name="i18n_context" select="$i18n_context/*" tunnel="yes"/>        
      </xsl:apply-templates>
  </xsl:template>
</xsl:stylesheet>