<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:       Creation of elements and attributes
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    xsl:element generates elements in time of processing. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <xsl:for-each select="//text">
            <xsl:element name="{@size}">
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
