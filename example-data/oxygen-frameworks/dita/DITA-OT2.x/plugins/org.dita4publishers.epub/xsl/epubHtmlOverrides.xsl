<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:related-links="http://dita-ot.sourceforge.net/ns/200709/related-links"
  xmlns:epubtrans="urn:d4p:epubtranstype"
  exclude-result-prefixes="xs related-links epubtrans"
  version="2.0">
  
  <!-- Overrides of built-in HTML generation templates -->
  
  <!-- this template is copied from dita2htmlImpl.xsl in the DITA-OT's xhtml plugin -->
  <xsl:template name="generateCssLinks">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:variable name="childlang">
      <xsl:choose>
        <!-- Update with DITA 1.2: /dita can have xml:lang -->
        <xsl:when test="self::dita[not(@xml:lang)]">
          <xsl:for-each select="*[1]"><xsl:call-template name="getLowerCaseLang"/></xsl:for-each>
        </xsl:when>
        <xsl:otherwise><xsl:call-template name="getLowerCaseLang"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="direction">
      <xsl:apply-templates select="." mode="get-render-direction">
        <xsl:with-param name="lang" select="$childlang"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:variable name="urltest"> <!-- test for URL -->
      <xsl:call-template name="url-string">
        <xsl:with-param name="urltext">
          <xsl:value-of select="concat($CSSPATH, $CSS)"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="$copySystemCssNoBoolean">
        <!-- do not use default CSS files -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="($direction = 'rtl') and ($urltest = 'url') ">
            <link rel="stylesheet" type="text/css" href="{$CSSPATH}{$bidi-dita-css}" />
          </xsl:when>
          <xsl:when test="($direction = 'rtl') and ($urltest = '')">
            <link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$CSSPATH}{$bidi-dita-css}" />
          </xsl:when>
          <xsl:when test="($urltest = 'url')">
            <link rel="stylesheet" type="text/css" href="{$CSSPATH}{$dita-css}" />
          </xsl:when>
          <xsl:otherwise>
            <link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$CSSPATH}{$dita-css}" />
          </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$newline"/>
      </xsl:otherwise>
    </xsl:choose>
    
    <!-- Add user's style sheet if requested to -->
    <xsl:if test="string-length($CSS) > 0">
      <xsl:choose>
        <xsl:when test="$urltest = 'url'">
          <link rel="stylesheet" type="text/css" href="{$CSSPATH}{$CSS}" />
        </xsl:when>
        <xsl:otherwise>
          <link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$CSSPATH}{$CSS}" />
        </xsl:otherwise>
      </xsl:choose><xsl:value-of select="$newline"/>
    </xsl:if>
    
    <xsl:apply-templates select="." mode="epubtrans:add-additional-css">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    
  </xsl:template>
  
  <xsl:template match="text()" mode="epubtrans:add-additional-css"/>
    
  
  
</xsl:stylesheet>
