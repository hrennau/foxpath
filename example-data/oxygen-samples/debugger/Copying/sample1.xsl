<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:    Copying
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    Copy and copy-of constructs are used for nodes copying. Copy element copies 
        only the current node without children and attributes, while copy-of copies everything.  -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="p">
        <DIV>
            <B>
                <xsl:text>copy-of : </xsl:text>
            </B>
            <xsl:copy-of select="."/>
        </DIV>
        <DIV>
            <B>
                <xsl:text>copy : </xsl:text>
            </B>
            <xsl:copy/>
        </DIV>
        <DIV>
            <B>
                <xsl:text>value-of : </xsl:text>
            </B>
            <xsl:value-of select="."/>
        </DIV>
    </xsl:template>
</xsl:stylesheet>
