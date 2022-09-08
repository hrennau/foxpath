<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">  
  
  <xsl:import href="common.xsl"/>
  
  <xsl:template match="/*:AdministrativeInformation[*:EndDate] | 
                       /*:TargetResult[*:EndDate] | 
                       /*:ActualResult[*:EndDate]">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="select"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="*:EndDate" mode="select">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#default"/>
      <xsl:text>${caret}</xsl:text>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/*:AdministrativeInformation[not(*:EndDate)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="*:Identifier or *:StartDate"> 
          <xsl:apply-templates select="node()" mode="insertAfterTarget">
            <xsl:with-param name="target" select="(*:Identifier, *:StartDate)[last()]" as="node()" tunnel="yes"/>
          </xsl:apply-templates>        
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="addElement"/>
          <xsl:apply-templates select="node()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  
  <xsl:template match="/*[self::*:TargetResult or self::*:ActualResult][not(*:EndDate)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="*:Description or *:NumberOfUnits or *:StartDate"> 
          <xsl:apply-templates select="node()" mode="insertAfterTarget">
            <xsl:with-param name="target" select="(*:Description, *:NumberOfUnits, *:StartDate)[last()]" as="node()" tunnel="yes"/>
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
    <xsl:element name="EndDate" namespace="{namespace-uri()}">
      <xsl:value-of select="current-date()"/>
      <xsl:text>${caret}</xsl:text>
    </xsl:element>
  </xsl:template>
  
 
</xsl:stylesheet>