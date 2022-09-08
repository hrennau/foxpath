<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">

  <xsl:import href="common.xsl"/>

  <xsl:template match="/*:StrategicPlanCore[*:Vision]">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="select"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="*:Vision" mode="select">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#default"/>
      <xsl:text>${caret}</xsl:text>
      <xsl:apply-templates select="node()" mode="#default"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/*:StrategicPlanCore[not(*:Vision)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="*:Organization"> 
          <xsl:apply-templates select="node()" mode="insertAfterTarget">
            <xsl:with-param name="target" select="*:Organization[last()]" as="node()" tunnel="yes"/>
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
    <xsl:element name="Vision" namespace="{$ns}">
      <xsl:element name="Description" namespace="{$ns}">${caret}</xsl:element>
      <xsl:element name="Identifier" namespace="{$ns}"><xsl:call-template name="generateID"/></xsl:element>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
