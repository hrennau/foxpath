<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:    Combining Stylesheets
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    Import precedence is more important than priority precedence.  -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="sample3.xsl"/>
    <xsl:template match="/">
        <xsl:apply-templates select="//CCC"/>
    </xsl:template>
    <xsl:template match="CCC" priority="-100">
        <H3 style="color:red">
            <xsl:value-of select="name()"/>
            <xsl:text> (id=</xsl:text>
            <xsl:value-of select="@id"/>
            <xsl:text>)</xsl:text>
        </H3>
    </xsl:template>
</xsl:stylesheet>
