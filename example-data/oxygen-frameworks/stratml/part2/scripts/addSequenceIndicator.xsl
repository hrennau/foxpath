<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">  
  
  <xsl:import href="common.xsl"/>
  
  <xsl:template match="/*[*:SequenceIndicator]">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="select"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="*:SequenceIndicator" mode="select">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>      
      <xsl:text>${caret}</xsl:text>
    </xsl:copy>
  </xsl:template>
  
  
  <xsl:template match="/*:PerformanceIndicator[not(*:SequenceIndicator)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="addElement"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  
  <xsl:template match="/*[self::*:Goal or self::*:Objective][not(*:SequenceIndicator)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="*:Name or *:Description or *:Identifier"> 
          <xsl:apply-templates select="node()" mode="insertAfterTarget">
            <xsl:with-param name="target" select="(*:Name, *:Description, *:Identifier)[last()]" tunnel="yes"/>
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
    <xsl:element name="SequenceIndicator" namespace="{namespace-uri()}">${caret}</xsl:element>
  </xsl:template>
 
</xsl:stylesheet>