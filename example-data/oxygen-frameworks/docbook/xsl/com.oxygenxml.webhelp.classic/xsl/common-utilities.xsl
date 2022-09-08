<?xml version="1.0" encoding="utf-8"?>
<!--
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  exclude-result-prefixes="relpath">
    
    <!-- 
        Output the 'dir' attribute to indicate the content direction (ltr pr rtl).
    -->
    <xsl:template name="setTopicLanguage">
        <xsl:param name="withFrames"/>
        <xsl:variable name="childlang">
            <xsl:apply-templates select="/*" mode="get-first-topic-lang"/>
        </xsl:variable>
        <xsl:variable name="direction">
        	<xsl:apply-templates select="." mode="get-render-direction">
        		<xsl:with-param name="lang" select="$childlang"/>
        	</xsl:apply-templates>
        </xsl:variable>
        <xsl:call-template name="generate-lang">
            <xsl:with-param name="lang" select="$childlang"/>
        </xsl:call-template>
        <xsl:if test="string($direction) = 'rtl'">
            <xsl:attribute name="dir">rtl</xsl:attribute>
        </xsl:if>
    </xsl:template>

    <!-- Add both lang and xml:lang attributes -->
    <xsl:template match="@xml:lang" name="generate-lang">
        <xsl:param name="lang" select="."/>
        <xsl:attribute name="xml:lang">
            <xsl:value-of select="$lang"/>
        </xsl:attribute>
        <xsl:attribute name="lang">
            <xsl:value-of select="$lang"/>
        </xsl:attribute>
    </xsl:template>
    
</xsl:stylesheet>