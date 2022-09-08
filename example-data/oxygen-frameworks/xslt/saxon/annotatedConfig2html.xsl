<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:xhtml="http://www.w3.org/1999/xhtml" version="2.0">

    <xsl:output method="xhtml" indent="yes"/>
    <xsl:template match="/">
        <xhtml:html>
            <xhtml:head>
                <xhtml:title>Saxon configuration annotations</xhtml:title>
            </xhtml:head>
            <xhtml:body>
                <xsl:apply-templates/>
            </xhtml:body>
        </xhtml:html>
    </xsl:template>

    <xsl:template match="text()"/>
    <xsl:template
        match="xs:documentation[parent::xs:annotation/(parent::xs:element or parent::xs:attribute)]">
        <xhtml:div id="{../../concat(local-name(), '-', @name)}">
            <xsl:apply-templates mode="copyToXHTML"/>
        </xhtml:div>
    </xsl:template>

    <xsl:template match="xhtml:*" mode="copyToXHTML">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="copyToXHTML"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="* | @*" mode="copyToXHTML">
        <xsl:element name="xhtml:{local-name()}" namespace="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates select="node() | @*" mode="copyToXHTML"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="text()" mode="copyToXHTML">
        <xsl:value-of select="."/>
    </xsl:template>

</xsl:stylesheet>
