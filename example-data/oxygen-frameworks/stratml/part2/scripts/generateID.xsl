<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">  
  
  <xsl:import href="common.xsl"/>
  
  <xsl:template match="/*:Identifier[not(text())]">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
      <xsl:call-template name="generateID"/>
      <xsl:text>${caret}</xsl:text>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>