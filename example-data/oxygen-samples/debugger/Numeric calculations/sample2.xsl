<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:     Numeric calculations
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    Addition, subtraction and multiplication uses common syntax. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <P>
            <xsl:value-of select="//number[1]"/>
            <xsl:text> + </xsl:text>
            <xsl:value-of select="//number[2]"/>
            <xsl:text> = </xsl:text>
            <xsl:value-of select="//number[1] + //number[2]"/>
        </P>
        <P>
            <xsl:value-of select="//number[3]"/>
            <xsl:text> - </xsl:text>
            <xsl:value-of select="//number[4]"/>
            <xsl:text> = </xsl:text>
            <xsl:value-of select="//number[3] - //number[4]"/>
        </P>
        <P>
            <xsl:value-of select="//number[5]"/>
            <xsl:text> * </xsl:text>
            <xsl:value-of select="//number[6]"/>
            <xsl:text> = </xsl:text>
            <xsl:value-of select="//number[5] * //number[6]"/>
        </P>
    </xsl:template>
</xsl:stylesheet>
