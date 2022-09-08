<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">  
  
  <xsl:import href="common.xsl"/>
  
  <xsl:template match="/*:Objective">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="clear"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="*:Objective/*:Name[1]" mode="clear">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
      <xsl:text>${caret}</xsl:text>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/*:Goal">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
      <xsl:choose>
        <xsl:when test="*:Objective">
          <xsl:apply-templates select="*:Objective[last()]" mode="clear"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="addElement"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="addElement">
    <xsl:variable name="ns" select="namespace-uri()"/>
    <xsl:element name="Objective" namespace="{$ns}">
      <xsl:element name="Name" namespace="{$ns}">${caret}</xsl:element>
      <xsl:element name="Description" namespace="{$ns}"/>
    </xsl:element>
  </xsl:template>
  
</xsl:stylesheet>