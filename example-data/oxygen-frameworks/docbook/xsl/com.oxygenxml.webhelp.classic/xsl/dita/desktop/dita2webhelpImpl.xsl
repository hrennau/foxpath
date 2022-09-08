<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">
  
  <xsl:import href="../dita2webhelp.xsl"/>  
  <xsl:import href="fixup.xsl"/>
  
  <xsl:include href="../../macroExpander.xsl"/>
  
  <!-- Enable debugging from here. --> 
  <xsl:param name="WEBHELP_DEBUG" select="false()"/>
  <xsl:param name="show.changes.and.comments" select="'no'"/>

  <!--
     This parameter can be used to test the Webhelp distribution.
   -->  
  <xsl:param name="WEBHELP_DISTRIBUTION" select="'classic'"/>
  
  <!-- 
    An unique(timestamp) ID for the current WebHelp transformation 
  -->
  <xsl:param name="WEBHELP_UNIQUE_ID"/>
  
  <!-- 
    Current oXygen build number. 
  -->
  <xsl:param name="WEBHELP_BUILD_NUMBER"/>
  <!-- 
      Move related links improvement is enabled only in the Webhelp Classic. 
      For Responsive variant we have another mechanism that applies over HTML content 
    -->
  <xsl:variable name="moveRelatedLinks" select="true()"/>
  
  <!-- Normal Webhelp transformation, filtered. -->
  <xsl:template match="/">
    
    <xsl:variable name="topicContent">
      <xsl:apply-imports/>
    </xsl:variable>    
    
    <xsl:choose>
      <xsl:when test="$WEBHELP_DEBUG">
        <!-- This generates Invalid HTML, but is OK for debugging. -->
        <html>
          <xsl:apply-templates select="$topicContent" mode="fixup_desktop"/>                 
          <hr/>
          <h1>Original content:</h1>
          <xsl:copy-of select="$topicContent"/>                
        </html>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="fixedTopic">
	        <xsl:apply-templates select="$topicContent" mode="fixup_desktop"/>        
        </xsl:variable>
        <xsl:apply-templates select="$fixedTopic" mode="fixup_XHTML_NS"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Refer webhelp_topic.js that contains the redirect functionality -->
  <xsl:template name="addCustomJS">
    <xsl:param name="namespace"/>
    
    <xsl:element name="script" namespace="{$namespace}">
      <xsl:attribute name="type">text/javascript</xsl:attribute>
      <xsl:attribute name="charset">utf-8</xsl:attribute>
      <xsl:attribute name="src">
        <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/js/log.js?buildId=', $WEBHELP_BUILD_NUMBER)"/>
      </xsl:attribute>
      <xsl:comment/>
    </xsl:element>
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