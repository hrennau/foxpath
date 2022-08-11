<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:     Boolean functions
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    This stylesheet uses node-sets as arguments for boolean() function. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <TABLE border="1">
            <TR>
                <TH>node-set</TH>
                <TH>boolean</TH>
            </TR>
            <TR>
                <TD>
                    <xsl:text>/</xsl:text>
                </TD>
                <TD>
                    <xsl:value-of select="boolean(/)"/>
                </TD>
            </TR>
            <TR>
                <TD>
                    <xsl:text>//text</xsl:text>
                </TD>
                <TD>
                    <xsl:value-of select="boolean(//text)"/>
                </TD>
            </TR>
            <TR>
                <TD>
                    <xsl:text>//number</xsl:text>
                </TD>
                <TD>
                    <xsl:value-of select="boolean(//number)"/>
                </TD>
            </TR>
            <TR>
                <TD>
                    <xsl:text>//text[23]</xsl:text>
                </TD>
                <TD>
                    <xsl:value-of select="boolean(//text[23])"/>
                </TD>
            </TR>
        </TABLE>
    </xsl:template>
</xsl:stylesheet>
