<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">  
  
  <xsl:import href="common.xsl"/>
  
  
  <xsl:template match="/*:AdministrativeInformation/*:StartDate | 
                       /*:TargetResult[*:StartDate] | 
                       /*:ActualResult[*:StartDate]">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="select"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="*:StartDate" mode="select">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>      
      <xsl:text>${caret}</xsl:text>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/*:AdministrativeInformation[not(*:StartDate)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="*:Identifier"> 
          <xsl:apply-templates select="node()" mode="insertAfterTarget">
            <xsl:with-param name="target" select="(*:Identifier)[last()]" tunnel="yes"/>
          </xsl:apply-templates>        
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="addElement"/>
          <xsl:apply-templates select="node()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  
  <xsl:template match="/*[self::*:TargetResult or self::*:ActualResult][not(*:StartDate)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="*:Description or *:NumberOfUnits"> 
          <xsl:apply-templates select="node()" mode="insertAfterTarget">
            <xsl:with-param name="target" select="(*:Description, *:NumberOfUnits)[last()]" tunnel="yes"/>
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
    <xsl:element name="StartDate" namespace="{namespace-uri()}"><xsl:value-of select="current-date()"/>${caret}</xsl:element>
  </xsl:template>
 
</xsl:stylesheet>