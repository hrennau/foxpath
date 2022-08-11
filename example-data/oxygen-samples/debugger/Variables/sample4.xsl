<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:     Variables
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    Parameters for a template can be passed with xsl:with-param element. 
       If the template contains a xsl:param element with the same name as name attribute 
       of xsl:with-param, this value is used. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <TABLE>
            <xsl:for-each select="//number">
                <TR>
                    <TH>
                        <xsl:choose>
                            <xsl:when test="text() mod 2">
                                <xsl:apply-templates select=".">
                                    <xsl:with-param name="type">odd</xsl:with-param>
                                </xsl:apply-templates>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </TH>
                </TR>
            </xsl:for-each>
        </TABLE>
    </xsl:template>
    <xsl:template match="number">
        <xsl:param name="type">even</xsl:param>
        <xsl:value-of select="."/>
        <xsl:text> (</xsl:text>
        <xsl:value-of select="$type"/>
        <xsl:text>)</xsl:text>
    </xsl:template>
</xsl:stylesheet>
