<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:     Conditional processing
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    xsl:choose element is used for selection between several possibilities.  -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="//SECTION">
        <xsl:choose>
            <xsl:when test="SUMMARY">
                <P>
                    <xsl:text>SUMMARY: </xsl:text>
                    <xsl:value-of select="SUMMARY"/>
                </P>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="DATA">
                    <P>
                        <xsl:text>DATA: </xsl:text>
                        <xsl:value-of select="."/>
                    </P>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
