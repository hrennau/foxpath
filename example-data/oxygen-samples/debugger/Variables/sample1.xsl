<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:     Variables
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    This stylesheet demonstrates setting of xsl:variable -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:variable name="totalChapters">
        <xsl:value-of select="count(//chapter)"/>
    </xsl:variable>
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
