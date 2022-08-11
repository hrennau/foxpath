<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:       Creation of elements and attributes
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    Copy and copy-of constructs are used for nodes copying. Copy element copies only the current node 
        without children and attributes, while copy-of copies everything.The xsl:copy element may have a use-attribute-sets
        attribute. In this way attributes for copied element can be specified. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <xsl:apply-templates select="/source/*"/>
    </xsl:template>
    <xsl:template match="h1">
        <xsl:copy use-attribute-sets="H1">
            <xsl:value-of select="."/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="p">
        <xsl:copy use-attribute-sets="P ">
            <xsl:value-of select="."/>
        </xsl:copy>
    </xsl:template>
    <xsl:attribute-set name="H1">
        <xsl:attribute name="align">center</xsl:attribute>
        <xsl:attribute name="style">color:red</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="P">
        <xsl:attribute name="align">left</xsl:attribute>
        <xsl:attribute name="style">color:blue</xsl:attribute>
    </xsl:attribute-set>
</xsl:stylesheet>
