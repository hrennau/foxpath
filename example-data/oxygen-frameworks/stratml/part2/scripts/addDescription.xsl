<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">  
  
  <xsl:import href="common.xsl"/>
  
  <xsl:template match="/*:PerformancePlanOrReport">
    <xsl:call-template name="addElement"/>
  </xsl:template>
  
  <!-- If we have an existing name we just move the caret at the end of the node -->
  <xsl:template match="/*:Description">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
      <xsl:text>${caret}</xsl:text>
    </xsl:copy>
  </xsl:template>
 
  <xsl:template match="/*:Vision[not(*:Description)]">
    <xsl:call-template name="addElementAsFirstChild"/>
  </xsl:template>
  <xsl:template match="/*:Mission[not(*:Description)]">
    <xsl:call-template name="addElementAsFirstChild"/>
  </xsl:template>
  <xsl:template match="/*:TargetResult[not(*:Description)]">
    <xsl:call-template name="addElementAsFirstChild"/>
  </xsl:template>
  <xsl:template match="/*:ActualResult[not(*:Description)]">
    <xsl:call-template name="addElementAsFirstChild"/>
  </xsl:template>  
 
  <xsl:template match="/*:Organization[not(*:Description)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="*:Name or *:Acronym or *:Identifier"> 
          <xsl:apply-templates select="node()" mode="insertAfterTarget">
            <xsl:with-param name="target" select="(*:Name, *:Acronym, *:Identifier)[last()]" 
              tunnel="yes"/>
          </xsl:apply-templates>        
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="addElement"/>
          <xsl:apply-templates select="node()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/*:Relationship[not(*:Description)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="*:Identifier or *:Name"> 
          <xsl:apply-templates select="node()" mode="insertAfterTarget">
            <xsl:with-param name="target" select="(*:Identifier, *:Name)[last()]" tunnel="yes"/>
          </xsl:apply-templates>        
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="addElement"/>
          <xsl:apply-templates select="node()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/*[self::*:Stakeholder or 
                          self::*:Role or 
                          self::*:Goal or 
                          self::*:Objective or 
                          self::*:Value]
                       [not(*:Description)]">
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
    <xsl:element name="Description" namespace="{namespace-uri()}">${caret}</xsl:element>
  </xsl:template>
 
</xsl:stylesheet>