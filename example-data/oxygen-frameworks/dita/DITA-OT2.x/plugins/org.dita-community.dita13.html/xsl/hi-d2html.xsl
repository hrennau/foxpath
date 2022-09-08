<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="xs xd"
  version="2.0">
  
 <xsl:template match="*[contains(@class, ' hi-d/line-through ')]"
               name="topic.hi-d.line-through">
    <span style="text-decoration: line-through;">
       <xsl:call-template name="commonattributes"/>
       <xsl:call-template name="setidaname"/>
       <xsl:apply-templates/>
    </span>
  </xsl:template>
  
 <xsl:template match="*[contains(@class, ' hi-d/overline ')]"
               name="topic.hi-d.overline">
    <span style="text-decoration: overline;">
       <xsl:call-template name="commonattributes"/>
       <xsl:call-template name="setidaname"/>
       <xsl:apply-templates/>
    </span>
  </xsl:template>
  
</xsl:stylesheet>