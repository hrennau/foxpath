<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">
  
  <xsl:import href="../dita2webhelp.xsl"/>  
  <xsl:import href="fixup.xsl"/>
  
  <!-- Enable debugging from here. -->   
  <xsl:param name="WEBHELP_DEBUG" select="false()"/>
  
  <!--
     This parameter can be used to test the Webhelp distribution.
   -->  
  <xsl:param name="WEBHELP_DISTRIBUTION" select="'classic-mobile'"/>
  
  <!-- 
    An unique(timestamp) ID for the current WebHelp transformation 
  -->
  <xsl:param name="WEBHELP_UNIQUE_ID"/>
  
  <!-- 
    Current oXygen build number. 
  -->
  <xsl:param name="WEBHELP_BUILD_NUMBER"/>
  
    <xsl:output 
            method="xhtml" 
            encoding="UTF-8"
            indent="no"
            doctype-public=""
            doctype-system="about:legacy-compat"
            omit-xml-declaration="yes"/>
    
    
  <!-- Normal Webhelp transformation, filtered. -->
  <xsl:template match="/">    

    <xsl:variable name="topicContent">
      <xsl:apply-imports/>
    </xsl:variable>    

    <xsl:choose>
      <xsl:when test="$WEBHELP_DEBUG">
        <!-- This generates Invalid HTML, but is OK for debugging. -->
        <html>
          <xsl:apply-templates select="$topicContent" mode="fixup_mobile"/>                 
          <hr/>
          <h1>Original content:</h1>
          <xsl:copy-of select="$topicContent"/>                
        </html>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="fixedTopic">
          <xsl:apply-templates select="$topicContent" mode="fixup_XHTML_NS"/>        
        </xsl:variable>
        <xsl:apply-templates select="$fixedTopic" mode="fixup_mobile"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>  
  
</xsl:stylesheet>