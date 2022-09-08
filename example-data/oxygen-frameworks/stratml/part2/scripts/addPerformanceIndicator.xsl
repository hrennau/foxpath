<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">  
  
  <xsl:import href="common.xsl"/>
  
  <xsl:template match="/*:PerformanceIndicator">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="clear"/>
      <xsl:text>${caret}</xsl:text>
      <xsl:apply-templates select="node()" mode="clear"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/*:Objective">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
      <xsl:choose>
        <xsl:when test="*:PerformanceIndicator">
          <xsl:apply-templates select="*:PerformanceIndicator[last()]" mode="clear"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="addElement"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="addElement">
    <xsl:variable name="ns" select="namespace-uri()"/>
    <xsl:element name="PerformanceIndicator" namespace="{$ns}">
      <xsl:element name="MeasurementDimension" namespace="{$ns}">${caret}</xsl:element>
      <xsl:element name="UnitOfMeasurement" namespace="{$ns}"/>
    </xsl:element>
  </xsl:template>
  
</xsl:stylesheet>