<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:     Variables
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    A stylesheet can contain several variables of the same name. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:variable name="text">Chapter</xsl:variable>
    <xsl:template match="/">
        <TABLE>
            <xsl:for-each select="//chapter">
                <TR>
                    <TD>
                        <xsl:variable name="text">
                            <xsl:choose>
                                <xsl:when test="position() = 1">First chapter</xsl:when>
                                <xsl:when test="position()=last()">Last chapter</xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$text"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:value-of select="$text"/>
                        <xsl:text> : </xsl:text>
                        <xsl:value-of select="."/>
                    </TD>
                </TR>
            </xsl:for-each>
        </TABLE>
    </xsl:template>
</xsl:stylesheet>
