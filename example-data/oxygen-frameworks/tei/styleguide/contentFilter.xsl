<?xml version="1.0" encoding="UTF-8"?>
<!--Used to filter the HTML content to be better displayed in the tooltip window.-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml">
    <xsl:output method="html"/>
    <!-- Match document -->
    <xsl:template match="/">
        <xsl:apply-templates mode="copy" select="."/>
    </xsl:template>
    <!-- Deep copy template -->
    <xsl:template match="*|text()|@*" mode="copy">
        <xsl:copy>
            <xsl:apply-templates mode="copy" select="@*"/>
            <xsl:apply-templates mode="copy"/>
        </xsl:copy>
    </xsl:template>
    <!-- Handle default matching -->
    <xsl:template match="*"/>
    <!-- Remove some TEI header content. -->
    <xsl:template match="xhtml:div[@class='miniTOC miniTOC_right']" mode="copy"/>
    <xsl:template match="xhtml:div[@class='mainhead']" mode="copy"/>
    <xsl:template match="xhtml:div[@id='container']" mode="copy"/>
    <!--No scripts-->
    <xsl:template match="xhtml:script" mode="copy"/>
    <!--No meta-->
    <xsl:template match="xhtml:meta" mode="copy"/>
    <!--No CSS link-->
    <xsl:template match="xhtml:link" mode="copy"/>
</xsl:stylesheet>