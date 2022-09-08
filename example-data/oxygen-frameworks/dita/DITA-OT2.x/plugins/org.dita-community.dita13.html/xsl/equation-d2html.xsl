<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  >
  <!-- Math and equation domain elements to HTML 
  
  -->
  
  <xsl:template match="*[contains(@class, ' equation-d/equation-inline ')]">
    <span class="eqn-inline {@outputclass}"><xsl:apply-templates>
      <xsl:with-param name="blockOrInline" tunnel="yes" select="'inline'"/>
    </xsl:apply-templates></span>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' equation-d/equation-block ')]">
    <div class="eqn-block {@outputclass}">
      <xsl:apply-templates>
        <xsl:with-param name="blockOrInline" tunnel="yes" select="'block'"/>
      </xsl:apply-templates>
    </div>
  </xsl:template>
  
  
  <xsl:template match="*[contains(@class, ' equation-d/equation-figure ')]/*[contains(@class, ' mathml-d/mathml ')]"
    priority="10"
    >
    <div style="display: block">
      <xsl:apply-templates>
        <xsl:with-param name="blockOrInline" tunnel="yes" select="'block'"/>
      </xsl:apply-templates>
    </div>
  </xsl:template>
  
  
</xsl:stylesheet>
