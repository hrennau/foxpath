<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:     Numeric calculations
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    Functions ceilng(), floor() and round() transform floating point numbers into integers in the specified way. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <TABLE border="1">
            <TR>
                <TH>number</TH>
                <TH>floor</TH>
                <TH>ceiling</TH>
                <TH>round</TH>
            </TR>
            <xsl:for-each select="//number">
                <TR>
                    <TD>
                        <xsl:value-of select="."/>
                    </TD>
                    <TD>
                        <xsl:value-of select="floor(.)"/>
                    </TD>
                    <TD>
                        <xsl:value-of select="ceiling(.)"/>
                    </TD>
                    <TD>
                        <xsl:value-of select="round(.)"/>
                    </TD>
                </TR>
            </xsl:for-each>
        </TABLE>
    </xsl:template>
</xsl:stylesheet>
