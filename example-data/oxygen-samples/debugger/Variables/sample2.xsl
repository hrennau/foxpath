<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:     Variables
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    This stylesheet demonstrate setting of xsl:param -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="totalChapters" select="count(//chapter)"/>
    <xsl:template match="/">
        <TABLE>
            <xsl:for-each select="//chapter">
                <TR>
                    <TD>
                        <xsl:value-of select="."/>
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="position()"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="$totalChapters"/>
                        <xsl:text>)</xsl:text>
                    </TD>
                </TR>
            </xsl:for-each>
        </TABLE>
    </xsl:template>
</xsl:stylesheet>
