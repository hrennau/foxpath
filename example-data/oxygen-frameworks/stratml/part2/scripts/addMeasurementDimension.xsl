<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">  
  
  <xsl:import href="common.xsl"/>
  
  
  <xsl:template match="/*[*:MeasurementDimension]">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="select"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="*:MeasurementDimension" mode="select">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
      <xsl:text>${caret}</xsl:text>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/*:PerformanceIndicator[not(*:MeasurementDimension)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="*:SequenceIndicator"> 
          <xsl:apply-templates select="node()" mode="insertAfterTarget">
            <xsl:with-param name="target" select="(*:SequenceIndicator)[last()]" tunnel="yes"/>
          </xsl:apply-templates>        
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="addElement"/>
          <xsl:apply-templates select="node()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="addElement">
    <xsl:element name="MeasurementDimension" namespace="{namespace-uri()}">${caret}</xsl:element>
  </xsl:template>
 
</xsl:stylesheet>