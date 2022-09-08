<?xml version="1.0" encoding="UTF-8" ?>
<!--
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"     
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:saxon="http://icl.com/saxon"
  xmlns="http://www.w3.org/1999/xhtml" 
  exclude-result-prefixes="d saxon"
  version="1.0">
  
  <xsl:import href="../chunk_custom.xsl"/>
  <xsl:import href="fixup.xsl"/>
  <xsl:param name="PATH2PROJ" select="''"/>
  
  <!-- Standard template from the docbook chunker. The output is post-processed. -->
  <xsl:template name="chunk-element-content">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="nav.context"/>
    
    <xsl:param name="content">
      <xsl:apply-templates/>
    </xsl:param>
    
    <xsl:variable name="allContent">
      <xsl:call-template name="getAllPageContent">
        <xsl:with-param name="prev" select="$prev"/>
        <xsl:with-param name="next" select="$next"/>
        <xsl:with-param name="nav.context" select="$nav.context"/>
        <xsl:with-param name="content" select="$content"/>
      </xsl:call-template>
    </xsl:variable>

    
    <!-- Converts the standard HTML output to the desktop version. -->
    <xsl:apply-templates select="saxon:node-set($allContent)" mode="fixup_desktop"/>          
  </xsl:template>
  
  <!-- Refer webhelp_topic.js that contains the redirect functionality -->
  <xsl:template name="addCustomJS">
    <xsl:param name="namespace"/>
    
    <xsl:element name="script" namespace="{$namespace}">
      <xsl:attribute name="type">text/javascript</xsl:attribute>
      <xsl:attribute name="charset">utf-8</xsl:attribute>
      <xsl:attribute name="src">
        <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/js/webhelp_topic.js?buildId=', $WEBHELP_BUILD_NUMBER)"/>
      </xsl:attribute>
      <xsl:comment/>
    </xsl:element>
    
  </xsl:template>
</xsl:stylesheet>
