<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Copyright 2001-2011 Syncro Soft SRL. All rights reserved.
 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:i="http://www.oxygenxml.com/ns/doc/xsl-internal" xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs i" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p>Stylesheet that serializes any <xd:i>"unknown documentation"</xd:i> section. </xd:p>
            <xd:p>These sections will be left unchanged and they will copied to the output file(s).
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>The template that processes the documentation section of a component.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="i:docSection/*" mode="documentation">
        <pre>
            <xsl:call-template name="serializeElement"/>
        </pre>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>The template that processes any element from the <xd:i>unknown
                    documentation</xd:i> section. (see <xd:ref name="serializeElement"
                    type="template"><xd:i>"serializeElement" template</xd:i></xd:ref>).</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="*" mode="serialize">
        <xsl:call-template name="serializeElement"/>
    </xsl:template>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Copies an XML element and all of its children and attributes to the output
                file.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="serializeElement">
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:for-each select="@*">
            <xsl:text> </xsl:text>
            <xsl:value-of select="name()"/>
            <xsl:text>="</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>"</xsl:text>
        </xsl:for-each>
        <xsl:choose>
            <xsl:when test="*|text()">
                <xsl:text>&gt;</xsl:text>
                <xsl:apply-templates mode="serialize"/>
                <xsl:text>&lt;/</xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:text>&gt;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>/&gt;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
