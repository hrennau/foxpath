<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  exclude-result-prefixes="xs xd"
  version="2.0">
  
 <xsl:template match="*[contains(@class, ' hi-d/line-through ')]"
               name="topic.hi-d.line-through">
    <fo:inline text-decoration="line-through">
       <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>
  
 <xsl:template match="*[contains(@class, ' hi-d/overline ')]"
               name="topic.hi-d.overline">
    <fo:inline text-decoration="overline">
       <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>
  
</xsl:stylesheet>