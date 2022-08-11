<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:    Combining Stylesheets
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    Imported in other stylesheet. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <xsl:apply-templates select="//CCC"/>
    </xsl:template>
    <xsl:template match="CCC" priority="10">
        <H3 style="color:blue">
            <xsl:value-of select="name()"/>
            <xsl:text> (id=</xsl:text>
            <xsl:value-of select="@id"/>
            <xsl:text>)</xsl:text>
        </H3>
    </xsl:template>
</xsl:stylesheet>
