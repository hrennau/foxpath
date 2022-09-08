<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs"
                version="2.0">
  
  <xsl:template match="@xtrc
                     | @xtrf
                     | processing-instruction('workdir')
                     | processing-instruction('workdir-uri')
                     | processing-instruction('path2project')
                     | processing-instruction('path2project-uri')
                     | processing-instruction('ditaot')"/>
    
  <xsl:template match="node() | @*" priority="-1000">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>