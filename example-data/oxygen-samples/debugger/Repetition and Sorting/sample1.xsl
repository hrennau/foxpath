<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:       Repetition and sorting
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    The xsl:for-each instruction contains a template, which is applied to each node 
        selected with select attribute. Nodes selected with xsl:for-each or xsl:apply-templates can be sorted.
        This stylesheet sorts in text mode.-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <TABLE>
            <xsl:for-each select="//car">
                <xsl:sort data-type="text" select="@id"/>
                <TR>
                    <TH>
                        <xsl:text>Car-</xsl:text>
                        <xsl:value-of select="@id"/>
                    </TH>
                </TR>
            </xsl:for-each>
        </TABLE>
    </xsl:template>
</xsl:stylesheet>
