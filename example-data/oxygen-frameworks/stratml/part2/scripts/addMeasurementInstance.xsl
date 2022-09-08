<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">  
  
  <xsl:import href="common.xsl"/>
  
  <xsl:template match="/*:MeasurementInstance">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="clear"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*:Identifier" mode="clear">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
      <xsl:call-template name="generateID"/>
      <xsl:text>${caret}</xsl:text>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/*:PerformanceIndicator">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="*:SequenceIndicator or *:MeasurementDimension 
          or *:UnitOfMeasurement or *:Identifier or *:Relationship 
          or *:MeasurementInstance"> 
          <xsl:apply-templates select="node()" mode="insertAfterTarget">
            <xsl:with-param name="target" 
              select="(*:SequenceIndicator, *:MeasurementDimension, 
              *:UnitOfMeasurement, *:Identifier, *:Relationship, 
              *:MeasurementInstance)[last()]" as="node()" tunnel="yes"/>
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
    <xsl:variable name="ns" select="namespace-uri()"/>
    <xsl:element name="MeasurementInstance" namespace="{$ns}">
      <xsl:element name="TargetResult" namespace="{$ns}">
        <xsl:element name="Description" namespace="{$ns}">${caret}</xsl:element>
      </xsl:element>
      <xsl:element name="ActualResult" namespace="{$ns}">
        <xsl:element name="Description" namespace="{$ns}"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>
  
</xsl:stylesheet>