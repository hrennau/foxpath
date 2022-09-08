<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="xs xd"
  version="2.0">
  <xsl:template match="*[contains(@class, ' topic/div ')]" priority="-1"
    >
<!--    <xsl:message> + [DEBUG] base template for topic/div: <xsl:value-of select="concat(name(..), '/', name(.))"/></xsl:message>-->
    <div>
      <xsl:call-template name="commonattributes"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
</xsl:stylesheet>