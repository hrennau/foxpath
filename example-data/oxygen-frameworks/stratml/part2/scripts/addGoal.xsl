<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">  
  
  <xsl:import href="common.xsl"/>
  
  <xsl:template match="/*:StrategicPlanCore">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
      <xsl:call-template name="addElement"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/*:Goal">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="clear"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="/*:Goal/*:Name" mode="clear">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
      <xsl:text>${caret}</xsl:text>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="addElement">
    <xsl:variable name="ns" select="namespace-uri()"/>
    <xsl:element name="Goal" namespace="{$ns}">
      <xsl:element name="Name" namespace="{$ns}">${caret}</xsl:element>
      <xsl:element name="Description" namespace="{$ns}"/>
    </xsl:element>
  </xsl:template>
  
</xsl:stylesheet>