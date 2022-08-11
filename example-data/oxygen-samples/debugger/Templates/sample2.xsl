<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:       Templates
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    Quite often several templates match the same element in XML source. 
        It must be therefore decided which one should be used. This priority order can be 
        specified with the priority attributte. If this attribute is not specified, its priority is calculated
        according to several rules. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <xsl:apply-templates select="//CCC"/>
    </xsl:template>
    <xsl:template match="CCC" priority="4">
        <h3 style="color:blue">
            <xsl:value-of select="name()"/>
            <xsl:text> (id=</xsl:text>
            <xsl:value-of select="@id"/>
            <xsl:text>)</xsl:text>
        </h3>
    </xsl:template>
    <xsl:template match="CCC/CCC" priority="3">
        <h2 style="color:red">
            <xsl:value-of select="name()"/>
            <xsl:text> (id=</xsl:text>
            <xsl:value-of select="@id"/>
            <xsl:text>)</xsl:text>
        </h2>
    </xsl:template>
</xsl:stylesheet>
