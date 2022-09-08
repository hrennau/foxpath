<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">  
  
  <xsl:import href="common.xsl"/>
  
  <xsl:template match="/*:PerformancePlanOrReport" priority="10">
    <xsl:call-template name="addElement"/>
  </xsl:template>
  
  <xsl:template match="/*:Relationship[not(*:Name)]" priority="10">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="*:Identifier"> 
          <xsl:apply-templates select="node()" mode="insertAfterTarget">
            <xsl:with-param name="target" select="(*:Identifier)[last()]" as="node()" tunnel="yes"/>
          </xsl:apply-templates>        
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="addElement"/>
          <xsl:apply-templates select="node()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <!-- If we have an existing name we just move the caret at the end of the node -->
  <xsl:template match="/*:Name">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
      <xsl:text>${caret}</xsl:text>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/*[*:Name]">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="select"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/*/*:Name[1]" mode="select">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
      <xsl:text>${caret}</xsl:text>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/*[not(*:Name)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:call-template name="addElement"/>      
      <xsl:apply-templates select="node()" mode="#default"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="addElement">
    <xsl:element name="Name" namespace="{namespace-uri()}">${caret}</xsl:element>
  </xsl:template>
</xsl:stylesheet>