<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:    Combining Stylesheets
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    Imported in other stylesheet. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/*/*">
        <DIV style="color:red">
            <xsl:value-of select="name()"/>
        </DIV>
    </xsl:template>
</xsl:stylesheet>
