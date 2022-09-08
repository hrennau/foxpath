<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">  
  
  <xsl:import href="common.xsl"/>
    
  <!-- If we have an existing name we just move the caret at the start of the node -->
  <xsl:template match="/*:Submitter">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:text>${caret}</xsl:text>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/*:PerformancePlanOrReport">
    <xsl:call-template name="addElement"/>
  </xsl:template>
 
  <xsl:template name="addElement">
    <xsl:variable name="ns" select="namespace-uri()"/>
    <xsl:element name="Submitter" namespace="{$ns}">
      <xsl:text>${caret}</xsl:text>
      <xsl:element name="FirstName" namespace="{$ns}"/>
      <xsl:element name="LastName" namespace="{$ns}"/>
      <xsl:element name="PhoneNumber" namespace="{$ns}"/>
      <xsl:element name="EmailAddress" namespace="{$ns}"/>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>