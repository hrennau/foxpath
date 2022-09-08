<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">  
  
  <xsl:import href="common.xsl"/>
  
  <xsl:template match="/*:ActualResult">
    <xsl:apply-templates select="." mode="clear"/>
  </xsl:template>
  <xsl:template match="*:Description" mode="clear">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="clear"/>
      <xsl:text>${caret}</xsl:text>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/*:MeasurementInstance">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>      
      <xsl:call-template name="addElement"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="addElement">
    <xsl:element name="ActualResult" namespace="{namespace-uri()}">
      <xsl:element name="Description" namespace="{namespace-uri()}">${caret}</xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>