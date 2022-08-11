<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:     Numbers generation and formatting
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    xsl:number inserts formated numbers into output. The format is given with format attribute. 
        The attribute starts with format identificator followed by separator characters. This stylesheet is example 
        of formatting of multilevel numbers. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <TABLE BORDER="1">
            <TR>
                <TH>Number</TH>
                <TH>text</TH>
            </TR>
            <xsl:for-each select="//chapter">
                <TR>
                    <TD>
                        <xsl:number level="multiple" format="1.A.a "/>
                    </TD>
                    <TD>
                        <xsl:value-of select="./text()"/>
                    </TD>
                </TR>
            </xsl:for-each>
        </TABLE>
    </xsl:template>
</xsl:stylesheet>
