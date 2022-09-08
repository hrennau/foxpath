<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">  
  
  <xsl:include href="common.xsl"/>
   
  <xsl:template match="/*:Submitter[not(*:EmailAddress)]">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
      <xsl:call-template name="addElement"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="addElement">
      <xsl:element name="EmailAddress" namespace="{namespace-uri()}">${caret}</xsl:element>
  </xsl:template>
  
</xsl:stylesheet>