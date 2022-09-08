<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Copyright 2001-2017 Syncro Soft SRL. All rights reserved.
    This is licensed under MPL 2.0.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:oxyd="http://www.oxygenxml.com/ns/dita">
    
    <xsl:import href="modules/resolve.xsl"/>
    <xsl:output indent="yes"/>
    
    <xsl:template match="/">
        <xsl:variable name="resolvedMap">
            <oxyd:mapref>
                <xsl:attribute name="xml:base" select="document-uri(.)"/>
                <xsl:apply-templates select="/" mode="resolve-map"/>
            </oxyd:mapref>
        </xsl:variable>
        <xsl:variable name="keyspace">
            <oxyd:keyspace>
                <xsl:for-each select="distinct-values($resolvedMap//@keys/tokenize(., ' '))">
                    <xsl:variable name="currentKey" select="."/>
                    <oxyd:key value="{$currentKey}">
                        <xsl:for-each select="$resolvedMap//*[@keys][tokenize(@keys, ' ')=$currentKey]">
                            <xsl:sort select="count(ancestor::oxyd:mapref)"/>   
                            <xsl:if test="position()=1">
                                <xsl:copy-of select="ancestor-or-self::oxyd:*/@xml:base[1]"/>
                                <xsl:copy>
                                    <xsl:copy-of select="@*"/>
                                </xsl:copy>
                            </xsl:if>
                        </xsl:for-each>
                    </oxyd:key>
                </xsl:for-each>
            </oxyd:keyspace>
        </xsl:variable>
        
        <!-- Get the DITA map and all its content in a resolved document -->
        <oxyd:mapref>
            <xsl:attribute name="xml:base" select="document-uri(.)"/>
            <xsl:apply-templates select="/" mode="resolve">
                <xsl:with-param name="keyspace" select="$keyspace" tunnel="yes"/>
            </xsl:apply-templates>
        </oxyd:mapref>
    </xsl:template>
</xsl:stylesheet>
