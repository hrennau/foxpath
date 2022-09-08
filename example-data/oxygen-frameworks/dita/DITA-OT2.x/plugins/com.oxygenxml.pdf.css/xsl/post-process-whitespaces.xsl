<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- 
        
        Remove whitespaces from element-only inline elements that are formatted by oXygen.
        
    -->
    <xsl:template match="*[contains(@class, ' ui-d/menucascade ')]">
    	<xsl:copy>
    	<xsl:copy-of select="@*"/>
        	<xsl:apply-templates select="*"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>