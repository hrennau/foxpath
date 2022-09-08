<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">
  
  <xsl:import href="common.xsl"/>
  
  <xsl:template match="/*:Organization[*:Acronym]">
    <xsl:apply-templates select="." mode="select"/>
  </xsl:template>
  <xsl:template match="*:Acronym" mode="select">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>      
      <xsl:text>${caret}</xsl:text>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/*:Organization[not(*:Acronym)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="*:Name"> 
          <xsl:apply-templates select="node()" mode="insertAfterTarget">
            <xsl:with-param name="target" select="(*:Name)[last()]" tunnel="yes"/>
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
    <xsl:element name="Acronym" namespace="{namespace-uri()}">${caret}</xsl:element>
  </xsl:template>
</xsl:stylesheet>
