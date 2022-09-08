<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">
  
  <xsl:import href="common.xsl"/>
  
  <xsl:template match="/*:Value">
    <xsl:apply-templates mode="clear" select="."/>
  </xsl:template>
  <xsl:template match="text()" mode="clear"/>
  
  <xsl:template match="/*:StrategicPlanCore">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="*:Organization | *:Vision | *:Mission | *:Value"> 
          <xsl:apply-templates select="node()" mode="insertAfterTarget">
            <xsl:with-param name="target" select="(*:Organization, *:Vision, *:Mission, *:Value)[last()]" tunnel="yes"/>
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
    <xsl:element name="Value" namespace="{$ns}">
      <xsl:element name="Name" namespace="{$ns}">${caret}</xsl:element>
      <xsl:element name="Description" namespace="{$ns}"/>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
