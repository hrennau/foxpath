<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen float image
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file LICENSE 
available in the base directory of this plugin.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
  >
  <xsl:template match="*[contains(@class, ' topic/image ')]
    [contains(@outputclass, 'float-left')
    or contains(@outputclass, 'float-right')
    ]">
    <div>
      <xsl:choose>
        <xsl:when test="contains(@outputclass, 'float-left')">
          <xsl:attribute name="style">float:left;margin:2 2 2 2</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="style">float:right;margin:2 2 2 2</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:next-match/>
    </div>
  </xsl:template>
</xsl:stylesheet>