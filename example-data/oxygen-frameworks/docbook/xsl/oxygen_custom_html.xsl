<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:import href="oxygen_custom.xsl"/>
    <!-- There can be SVG inside the imageobject. Let apply templates in this case. -->
    <xsl:template match="d:imageobject" xmlns:d="http://docbook.org/ns/docbook" xmlns:svg="http://www.w3.org/2000/svg">
        <xsl:choose>
            <xsl:when test="d:imagedata">
                <xsl:apply-templates select="d:imagedata"/>
            </xsl:when>
            <xsl:when test="svg:*">
                <xsl:copy-of select="svg:*"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
