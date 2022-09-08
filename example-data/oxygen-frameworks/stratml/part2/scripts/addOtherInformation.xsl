<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">  
  
  <xsl:import href="common.xsl"/>
  
  <xsl:template match="/*:PerformancePlanOrReport">
    <xsl:call-template name="addElement"/>
  </xsl:template>
  
  <!-- If we have an existing name we just move the caret at the end of the node -->
  <xsl:template match="/*:OtherInformation">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
      <xsl:text>${caret}</xsl:text>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/*:PerformanceIndicator[not(*:OtherInformation)]">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
      <xsl:call-template name="addElement"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/*[self::*:Goal or self::*:Objective][not(*:OtherInformation)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="*:Name or *:Description or *:Identifier or *:SequenceIndicator or *:Stakeholder"> 
          <xsl:apply-templates select="node()" mode="insertAfterTarget">
            <xsl:with-param name="target" select="(*:Name, *:Description, *:Identifier, *:SequenceIndicator, *:Stakeholder)[last()]" tunnel="yes"/>
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
    <xsl:element name="OtherInformation" namespace="{namespace-uri()}">${caret}</xsl:element>
  </xsl:template>
</xsl:stylesheet>