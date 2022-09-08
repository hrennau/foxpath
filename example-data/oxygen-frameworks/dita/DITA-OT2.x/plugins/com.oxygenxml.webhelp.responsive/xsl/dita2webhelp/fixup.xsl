<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<!--
  Contains a set of patches that are applied over the generated HTML. 
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:File="java:java.io.File" 
  exclude-result-prefixes="xs xhtml File"
  version="2.0">

  <!-- Oxygen version that created the WebHelp pages. -->
  <xsl:param name="WEBHELP_VERSION"/>
  
  <!-- Oxygen build number that created the WebHelp pages. -->
  <xsl:param name="WEBHELP_BUILD_NUMBER"/>
  
  <!-- 
    Flag indicating the output is feedback enabled. 
  -->
  <xsl:variable name="IS_FEEDBACK_ENABLED" select="string-length($WEBHELP_PRODUCT_ID) > 0"/>
    
  <xsl:include href="../util/fixupNS.xsl"/>
  
  <!-- 
    Create the meta element for the description. 
    De reverificat:
    - EXM-18345  
    - De verificat ca merge paramentrul CSS prin care se specifica un CSS aditional.    
  -->
  <!-- If it already has a description, normalize it.-->
  <xsl:template match="*:meta[@name='description']" mode="fixup">
    <xsl:element name="meta" namespace="{namespace-uri()}">
      <xsl:attribute name="name">description</xsl:attribute>
      <xsl:attribute name="content">
        <xsl:variable name="origContent" select="normalize-space(@content)"/>
        <xsl:choose>
          <xsl:when test="string-length($origContent) > 0">
            <xsl:value-of select="$origContent"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- Compute a description from the text body. -->
            <xsl:call-template name="getContentForShortdesc"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>
  
  
  <!-- 
    Has no description. Compute one. 
  -->
  <xsl:template match="*:head[not(*:meta[@name='description'])]" mode="fixup">
    <xsl:copy>
      <xsl:element name="meta" namespace="{namespace-uri()}">
        <xsl:attribute name="name">description</xsl:attribute>
        <xsl:attribute name="content">
          <!-- Compute a description from the text body. -->
          <xsl:call-template name="getContentForShortdesc"/>
        </xsl:attribute>
      </xsl:element>

      <!-- Add the webhelp standard CSS and JS-->
      <xsl:call-template name="generateHeadContent"/>      
    </xsl:copy>
  </xsl:template>
  
  <!-- 
    Compute a description from the text body. 
  -->
  <xsl:template name="getContentForShortdesc">
    <xsl:variable name="text" select="normalize-space(string-join(//*:div[contains(@class, 'body')]//text(), ' '))"/>
    <xsl:variable name="textStart">
      <xsl:choose>
        <xsl:when test="string-length($text) &lt; 200">
          <xsl:value-of select="$text"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="description" select="string-join(tokenize(substring($text, 1, 201), ' ')[position() &lt; last()], ' ')"/>
          <xsl:value-of select="concat($description, ' ...')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="translate($textStart, '&#xA;&#xD;&#x9;', '')"/>
  </xsl:template>
  
  <!-- 
    Add the webhelp standard CSS and JS 
  -->
  <xsl:template match="*:head" mode="fixup">
    <xsl:copy>
      <xsl:apply-templates mode="fixup" select="@*"/>
      <xsl:text xml:space="preserve">        
      </xsl:text>
      <xsl:call-template name="generateHeadContent"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="generateHeadContent">
      <xsl:apply-templates select="*" mode="fixup"/>
      <xsl:choose>
        <xsl:when test="contains($WEBHELP_VERSION, '$')">
          <xsl:comment>  Generated with Oxygen build number <xsl:value-of select="$WEBHELP_BUILD_NUMBER"/>.  </xsl:comment>
        </xsl:when>
        <xsl:otherwise>
          <xsl:comment>  Generated with Oxygen version <xsl:value-of select="$WEBHELP_VERSION"/>, build number <xsl:value-of select="$WEBHELP_BUILD_NUMBER"/>.  </xsl:comment>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
      
  <!-- 
    Removes the classes that conflict with bootstrap. 
    For instance the 'row' has different meaning in bootstrap.
  -->
  <xsl:template match="*:tr/@class" mode="fixup">
    <xsl:variable name="clv" select="normalize-space(replace(concat(' ',., ' '), ' row ', ' '))"/>
    <xsl:if test="string-length($clv)">
      <xsl:attribute name="class" select="$clv"/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="*:tr" mode="fixup">
    <xsl:copy>
      <xsl:apply-templates mode="fixup" select="@*"/>
      <xsl:apply-templates mode="fixup"/>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- 
    Adds the highlight/initializing JavaScript to the body element. 
  -->
  <xsl:template match="*:body" mode="fixup">
    <xsl:copy>
      <xsl:if test="not($IS_FEEDBACK_ENABLED)">
        <xsl:attribute name="onload">highlightSearchTerm()</xsl:attribute>
      </xsl:if>
      <xsl:attribute name="class">frmBody</xsl:attribute>
      <xsl:apply-templates mode="fixup" select="@*"/>
        
      <xsl:apply-templates mode="fixup"/>      
    </xsl:copy>
  </xsl:template>
  
    <xsl:template match="//*[contains(@class,'relinfo')]/*:div
                                   | //*[contains(@class,'linklist')]/*:div" 
                      mode="fixup">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="fixup"/>
      <xsl:choose>
        <xsl:when test="@class">
          <xsl:attribute name="class"><xsl:value-of select="concat(@class, ' related_link')"/></xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">related_link</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates mode="fixup"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- 
        Generic copy. 
  -->
  <xsl:template match="node() | @*" mode="fixup">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="fixup" />
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>