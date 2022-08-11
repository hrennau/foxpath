<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:    Nodeset functions
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    The position function returns a number equal to the context position and 
        the last function returns a number equal to the context size from the expression evaluation context. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <TABLE border="1">
            <TR>
                <TH>Position</TH>
                <TH>Last</TH>
                <TH>Name</TH>
            </TR>
            <xsl:for-each select="//AAA[last()]//CCC">
                <TR>
                    <TD>
                        <xsl:value-of select="position()"/>
                    </TD>
                    <TD>
                        <xsl:value-of select="last()"/>
                    </TD>
                    <TD>
                        <xsl:value-of select="text()"/>
                    </TD>
                </TR>
            </xsl:for-each>
        </TABLE>
        <TABLE border="1">
            <TR>
                <TH>Position</TH>
                <TH>Last</TH>
                <TH>Name</TH>
            </TR>
            <xsl:for-each select="//AAA[last()]//CCC">
                <xsl:sort order="ascending" select="text()"/>
                <TR>
                    <TD>
                        <xsl:value-of select="position()"/>
                    </TD>
                    <TD>
                        <xsl:value-of select="last()"/>
                    </TD>
                    <TD>
                        <xsl:value-of select="text()"/>
                    </TD>
                </TR>
            </xsl:for-each>
        </TABLE>
    </xsl:template>
</xsl:stylesheet>
