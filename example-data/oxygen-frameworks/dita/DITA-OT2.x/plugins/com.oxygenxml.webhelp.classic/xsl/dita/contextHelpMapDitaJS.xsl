<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:oxygen="http://www.oxygenxml.com/functions"
    exclude-result-prefixes="oxygen"
    version="2.0">
    
    <xsl:output method="text" />
   
    <xsl:template match="map">
        <xsl:text>var helpContexts = [</xsl:text>
        <xsl:apply-templates select="appContext"/> 
        <xsl:text>]</xsl:text>
    </xsl:template>
    
    <xsl:template match="appContext">
        <xsl:text>{</xsl:text>
        <xsl:text>"appname":"</xsl:text>
        <xsl:value-of select="@appname"/>
        <xsl:text>", "appid":"</xsl:text>
        <xsl:value-of select="@helpID"/>
        <xsl:text>", "path":"</xsl:text>
        <xsl:value-of select="@path"/>
        <xsl:text>"}</xsl:text>
        <xsl:variable name="pos" select="position()"/>
        <xsl:variable name="last" select="last()"/>
        <xsl:if test="position() != last()">
            <xsl:text>,</xsl:text>
        </xsl:if>
    </xsl:template>
    <xsl:template match="text()"/>
</xsl:stylesheet>