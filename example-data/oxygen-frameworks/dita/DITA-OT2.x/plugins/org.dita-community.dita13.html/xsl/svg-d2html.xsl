<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:local="urn:namespace:functions:local"
  exclude-result-prefixes="xs local"
  >
  
  <xsl:template match="*[contains(@class, ' svg-d/svg-container ')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] #default: <xsl:value-of select="concat(name(..), '/', name(.))"/>: Handling SVG container...</xsl:message>
    </xsl:if>
    
    <xsl:apply-templates>
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="svg:svg">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] #default: svg:svg - Applying templates in mode svg:svg-copy...</xsl:message>
    </xsl:if>
    <xsl:apply-templates mode="svg:copy-svg" select=".">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    
  </xsl:template>
    
</xsl:stylesheet>
