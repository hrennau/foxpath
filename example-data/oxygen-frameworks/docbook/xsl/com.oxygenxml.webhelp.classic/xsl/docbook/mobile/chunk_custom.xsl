<?xml version="1.0" encoding="UTF-8"?>
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
    <xsl:import href="../../common-mobile.xsl"/>
    <xsl:import href="fixup.xsl"/>
    <xsl:param name="PATH2PROJ" select="''"/>
    
    <xsl:variable name="WEBHELP_DEBUG" select="false()"/>
    
    <xsl:template name="customHeadScriptMobile"/>
    
    <xsl:template name="customBodyScriptMobile"/>
  
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
      
        <xsl:choose>
          <xsl:when test="$WEBHELP_DEBUG">
            <html>
              <!-- Converts the standard HTML output to the mobile version. -->
              <xsl:apply-templates select="saxon:node-set($allContent)" mode="fixup_mobile"/>
              <hr/>
              <h1>Original:</h1>
              <xsl:copy-of select="$allContent"/>
            </html>
          </xsl:when>
          <xsl:otherwise>
            <!-- Converts the standard HTML output to the mobile version. -->
            <xsl:apply-templates select="saxon:node-set($allContent)" mode="fixup_mobile"/>            
          </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
  
</xsl:stylesheet>