<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  exclude-result-prefixes="xs"
  >
  <!-- Math and equation domain elements to XSL-FO -->
  
  <xsl:template match="*[contains(@class, ' equation-d/equation-inline ')]">
    <fo:inline><xsl:apply-templates>
      <xsl:with-param name="blockOrInline" tunnel="yes" select="'inline'"/>
    </xsl:apply-templates></fo:inline>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' equation-d/equation-block ')]">
    <fo:block>
      <xsl:apply-templates>
        <xsl:with-param name="blockOrInline" tunnel="yes" select="'block'"/>
      </xsl:apply-templates>
    </fo:block>
  </xsl:template>
  

  <xsl:template match="*[contains(@class, ' equation-d/equation-figure ')]/*[contains(@class, ' mathml-d/mathml ')]"
    priority="10"
    >
    <fo:block>
      <xsl:apply-templates>
        <xsl:with-param name="blockOrInline" tunnel="yes" select="'block'"/>
      </xsl:apply-templates>
    </fo:block>
  </xsl:template>
  
  
</xsl:stylesheet>
