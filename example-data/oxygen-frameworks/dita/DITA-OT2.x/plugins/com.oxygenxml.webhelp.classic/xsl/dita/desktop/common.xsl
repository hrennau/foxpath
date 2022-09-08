<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:oxygen="http://www.oxygenxml.com/functions"
  version="2.0">
  
  <xsl:param name="show.changes.and.comments" select="'no'"/>
  
  <!-- CSS that is set as Webhelp skin in the DITA Webhelp transform. -->
  <xsl:param name="WEBHELP_SKIN_CSS" select="''"/>
  
  <!-- Custom JavaScript code set by param webhelp.head.script -->
  <xsl:param name="WEBHELP_HEAD_SCRIPT" select="''"/>
    
  <!-- Custom JavaScript code set by param webhelp.body.script -->
  <xsl:param name="WEBHELP_BODY_SCRIPT" select="''"/>
    
  <xsl:param name="OUTEXT" select="'.html'"/>
    
  <!-- Oxygen version that created the WebHelp pages. -->
  <xsl:param name="WEBHELP_VERSION"/>
    
  <!-- Oxygen build number that created the WebHelp pages. -->
  <xsl:param name="WEBHELP_BUILD_NUMBER"/>
    
  <xsl:include href="../../feedback.xsl"/>
  <xsl:include href="../../macroExpander.xsl"/>
  
  <!-- 
    Generates the JS and CSS references in the head element of the HTML pages.            
  -->
  <xsl:template name="jsAndCSS">
    <xsl:param name="namespace" select="'http://www.w3.org/1999/xhtml'"/>
    
    <xsl:choose>
          <xsl:when test="contains($WEBHELP_VERSION, '$')">
              <xsl:comment>  Generated with Oxygen build number <xsl:value-of select="$WEBHELP_BUILD_NUMBER"/>.  </xsl:comment>
          </xsl:when>
          <xsl:otherwise>
              <xsl:comment>  Generated with Oxygen version <xsl:value-of select="$WEBHELP_VERSION"/>, build number <xsl:value-of select="$WEBHELP_BUILD_NUMBER"/>.  </xsl:comment>
          </xsl:otherwise>
    </xsl:choose>
      
    <xsl:element name="meta" namespace="{$namespace}">
      <xsl:attribute name="http-equiv">Content-Type</xsl:attribute>
      <xsl:attribute name="content">text/html; charset=utf-8</xsl:attribute>
    </xsl:element>
    
    <!-- Override this template to add custom meta -->
    <xsl:call-template name="addCustomMeta">
      <xsl:with-param name="namespace" select="$namespace"/>
    </xsl:call-template>

    <!-- CSS -->
    <xsl:element name="link" namespace="{$namespace}">
      <xsl:attribute name="rel">stylesheet</xsl:attribute>
      <xsl:attribute name="type">text/css</xsl:attribute>
      <xsl:variable name="whTopicCss">
        <xsl:call-template name="getWHTopicCss"/>
      </xsl:variable>
      <xsl:attribute name="href">        
        <xsl:value-of select="concat($PATH2PROJ, $whTopicCss)"/>
      </xsl:attribute>
      <xsl:comment/>
    </xsl:element>
    
    <xsl:if test="string-length($WEBHELP_SKIN_CSS) > 0">
      <xsl:element name="link" namespace="{$namespace}">
        <xsl:attribute name="rel">stylesheet</xsl:attribute>
        <xsl:attribute name="type">text/css</xsl:attribute>
        <xsl:attribute name="href">
          <xsl:value-of select="concat($PATH2PROJ, $WEBHELP_SKIN_CSS, '?buildId=', $WEBHELP_BUILD_NUMBER)"/>
        </xsl:attribute>
      </xsl:element>
    </xsl:if>
        
    <xsl:if test="$show.changes.and.comments='yes'">
      <xsl:element name="link" namespace="{namespace-uri()}">
        <xsl:attribute name="rel">stylesheet</xsl:attribute>
        <xsl:attribute name="type">text/css</xsl:attribute>
        <xsl:attribute name="href">
          <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/css/p-side-notes.css?buildId=', $WEBHELP_BUILD_NUMBER)"/>
        </xsl:attribute>
        <xsl:comment/>
      </xsl:element>      
    </xsl:if>
            
    <xsl:call-template name="addCustomCSS">
      <xsl:with-param name="namespace" select="$namespace"/>
    </xsl:call-template>

    <xsl:apply-templates 
      select="*[local-name() = 'link' 
      and @rel='stylesheet' 
      and not(contains(@href, 'commonltr.css'))
      and not(contains(@href, 'commonrtl.css'))]"
      mode="fixup_desktop"/>
    
    <!-- JS -->
    <!-- Generates the inline scripts. -->
    
    <xsl:element name="script" namespace="{$namespace}">
      <xsl:attribute name="type">text/javascript</xsl:attribute>
      <xsl:comment>
        <xsl:text><![CDATA[
          
          var prefix = "]]></xsl:text>
        <xsl:value-of select="$PATH2PROJ"/>
        <xsl:text><![CDATA[index]]></xsl:text>
        <xsl:value-of select="$OUTEXT"/>
        <xsl:text><![CDATA[";
          
          ]]></xsl:text>
      </xsl:comment>
    </xsl:element>
    
    <xsl:element name="script" namespace="{$namespace}">
      <xsl:attribute name="type">text/javascript</xsl:attribute>
      <xsl:attribute name="src">
        <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/js/jquery-3.1.1.min.js')"/>
      </xsl:attribute>
      <xsl:comment/>
    </xsl:element>
    
    <xsl:element name="script" namespace="{$namespace}">
      <xsl:attribute name="type">text/javascript</xsl:attribute>
      <xsl:attribute name="src">
        <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/js/jquery.cookie.js')"/>
      </xsl:attribute>
      <xsl:comment/>
    </xsl:element>
    <xsl:element name="script" namespace="{$namespace}">
      <xsl:attribute name="type">text/javascript</xsl:attribute>
      <xsl:attribute name="src">
        <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/js/jquery.highlight-3.js')"/>
      </xsl:attribute>
      <xsl:comment/>
    </xsl:element>
    <xsl:if test="string-length($CUSTOM_RATE_PAGE_URL) > 0">
      <xsl:element name="script" namespace="{$namespace}">
        <xsl:attribute name="type">text/javascript</xsl:attribute>
        <xsl:attribute name="charset">utf-8</xsl:attribute>
        <xsl:attribute name="src">
          <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/js/rate_article.js?buildId=', $WEBHELP_BUILD_NUMBER)"/>
        </xsl:attribute>
        <xsl:comment/>
      </xsl:element>
    </xsl:if>
    
    <!-- Override this template to add custom JS in the page head -->
    <xsl:call-template name="addCustomJS">
      <xsl:with-param name="namespace" select="$namespace"/>
    </xsl:call-template>
    
    
    <!-- Custom JavaScript code set by param webhelp.head.script -->
    <xsl:if test="string-length($WEBHELP_HEAD_SCRIPT) > 0" >
      <xsl:call-template name="includeCustomHTMLContent">
        <xsl:with-param name="hrefURL" select="$WEBHELP_HEAD_SCRIPT"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="getWHTopicCss">
    <xsl:value-of select="concat('oxygen-webhelp/resources/css/webhelp_topic.css?buildId=', $WEBHELP_BUILD_NUMBER)"/>
  </xsl:template>
  
  <!-- Override this template to add custom JS in the page head -->
  <xsl:template name="addCustomJS">
    <xsl:param name="namespace"/>
  </xsl:template>
  

  <!-- Override this template to add custom CSS in the page head -->
  <xsl:template name="addCustomCSS">
    <xsl:param name="namespace"/>
  </xsl:template>
  
  
  <!-- Override this template to add custom meta in the page head -->
  <xsl:template name="addCustomMeta">
    <xsl:param name="namespace"/>
  </xsl:template>
  
  <xsl:template name="jsInBodyStart">
    <!-- Custom JavaScript code set by param webhelp.body.script -->
      <xsl:if test="string-length($WEBHELP_BODY_SCRIPT) > 0">
        <xsl:call-template name="includeCustomHTMLContent">
          <xsl:with-param name="hrefURL" select="$WEBHELP_BODY_SCRIPT"/>
        </xsl:call-template>
      </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>