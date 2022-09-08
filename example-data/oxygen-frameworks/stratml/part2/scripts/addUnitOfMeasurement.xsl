<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">  
  
  <xsl:import href="common.xsl"/>
  
  <xsl:template match="/*[*:UnitOfMeasurement]">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="select"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="*:UnitOfMeasurement" mode="select">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#default"/>      
      <xsl:text>${caret}</xsl:text>
    </xsl:copy>
  </xsl:template>
  
  
  <xsl:template match="/*:PerformanceIndicator[not(*:UnitOfMeasurement)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="*:SequenceIndicator or *:MeasurementDimension"> 
          <xsl:apply-templates select="node()" mode="insertAfterTarget">
            <xsl:with-param name="target" select="(*:SequenceIndicator, *:MeasurementDimension)[last()]" as="node()" tunnel="yes"/>
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
    <xsl:element name="UnitOfMeasurement" namespace="{namespace-uri()}">${caret}</xsl:element>
  </xsl:template>
 
</xsl:stylesheet>