<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:    Miscellaneous Additional Functions
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    Function generate-id generates id conforming to XML spec. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <DIV>
            <B>
                <xsl:text>generate-id(//AAA) : </xsl:text>
            </B>
            <xsl:value-of select="generate-id(//AAA) "/>
        </DIV>
        <DIV>
            <B>
                <xsl:text>generate-id(//BBB) : </xsl:text>
            </B>
            <xsl:value-of select="generate-id(//BBB) "/>
        </DIV>
        <DIV>
            <B>
                <xsl:text>generate-id(//AAA[1]) : </xsl:text>
            </B>
            <xsl:value-of select="generate-id(//AAA[1]) "/>
        </DIV>
        <DIV>
            <B>
                <xsl:text>generate-id(//*[1]) : </xsl:text>
            </B>
            <xsl:value-of select="generate-id(//*[1]) "/>
        </DIV>
        <DIV>
            <B>
                <xsl:text>generate-id(//xslTutorial/*[1]) : </xsl:text>
            </B>
            <xsl:value-of select="generate-id(//xslTutorial/*[1]) "/>
        </DIV>
    </xsl:template>
</xsl:stylesheet>
