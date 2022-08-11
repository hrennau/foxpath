<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:    Combining Stylesheets
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    Imports a stylesheet and changes its template. xsl-apply-imports works 
        only for templates imported with xsl:import, not for templates included with xsl:include. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="sample1.xsl"/>
    <xsl:template match="/*/*">
        <EM>
            <xsl:apply-imports/>
        </EM>
    </xsl:template>
</xsl:stylesheet>
