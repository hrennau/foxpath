<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">  
  
  <xsl:import href="common.xsl"/>
  
  <xsl:template match="/*:Role[*:RoleType]">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="select"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="*:RoleType" mode="select">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>      
      <xsl:text>${caret}</xsl:text>
    </xsl:copy>
  </xsl:template>
   
  <xsl:template match="/*:Role[not(*:RoleType)]">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
      <xsl:call-template name="addElement"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="addElement">
    <xsl:element name="RoleType" namespace="{namespace-uri()}">Performer${caret}</xsl:element>
  </xsl:template>
  
</xsl:stylesheet>