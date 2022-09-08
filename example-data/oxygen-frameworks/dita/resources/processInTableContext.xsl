<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:o="urn:schemas-microsoft-com:office:office"
    xmlns:e="http://www.oxygenxml.com/xsl/conversion-elements">
    
    <xsl:template match="/" mode="processInTableContext">
        <xsl:choose>
            <xsl:when test="$inTableContext and count(*) = 1 and local-name(*[1]) = 'table'">
                <xsl:copy-of select="//*:row | //*/*:row"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>