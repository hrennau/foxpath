<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">  
  
  <xsl:import href="common.xsl"/>
  
  <xsl:template match="/*:PerformancePlanOrReport">
    <xsl:call-template name="addElement"/>
  </xsl:template>
  
  <xsl:template match="/*:AdministrativeInformation">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:text>${caret}</xsl:text>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="addElement">
    <xsl:variable name="ns" select="namespace-uri()"/>
    <xsl:element name="AdministrativeInformation" namespace="{$ns}">
      <xsl:text>${caret}</xsl:text>
      <xsl:element name="StartDate" namespace="{$ns}"><xsl:value-of select="current-date()"/></xsl:element>
      <xsl:element name="EndDate" namespace="{$ns}"><xsl:value-of select="current-date()"/></xsl:element>
      <xsl:element name="PublicationDate" namespace="{$ns}"><xsl:value-of select="current-date()"/></xsl:element>
      <xsl:element name="Source" namespace="{$ns}"/>
    </xsl:element>
  </xsl:template>
 
</xsl:stylesheet>