<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Copyright 2001-2015 Syncro Soft SRL. All rights reserved.
    This is licensed under Oxygen XML Editor EULA (http://www.oxygenxml.com/eula.html).
    Redistribution and use outside Oxygen XML Editor is forbidden without express 
    written permission (contact e-mail address support@oxygenxml.com).
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:oxyd="http://www.oxygenxml.com/ns/dita"
    version="2.0">
    
    <!-- Resolve map and topic references, adding in topics content. -->

    <!-- default recurssive copy -->
    <xsl:template match="node() | @*" mode="resolve resolve-base resolve-map">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <!-- resolve topic refs -->
    <xsl:template match="*[contains(@class, ' map/topicref ') and @href and (@format='dita' or not(@format))]" mode="resolve">
        <xsl:variable name="topic" select="document(@href, .)"/>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <oxyd:topicref>
                <xsl:attribute name="xml:base" select="document-uri($topic)"/>
                <xsl:apply-templates select="$topic" mode="#current"/>
            </oxyd:topicref>
            <!-- copy eventual content of the topic ref -->
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <!-- resolve topic refs in resolve-map mode -->
    <xsl:template match="*[contains(@class, ' map/topicref ') and @href and (@format='dita' or not(@format))]" mode="resolve-map">
        <xsl:variable name="topic" select="document(@href, .)"/>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <!-- copy eventual content of the topic ref -->
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- resolve topic keyrefs -->
    <xsl:template match="*[contains(@class, ' map/topicref ') and @keyref]" mode="resolve">
        <xsl:param name="keyspace" tunnel="yes"/>
        <xsl:variable name="key" select="@keyref"/>
        <xsl:variable name="keydef" select="$keyspace/oxyd:keyspace/oxyd:key[@value=$key]"/>
        <xsl:variable name="topic" select="$keydef/*[1]/document(@href, .)"/>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <oxyd:topicref>
                <xsl:attribute name="xml:base" select="document-uri($topic)"/>
                <xsl:apply-templates select="$topic" mode="#current"/>
            </oxyd:topicref>
            <!-- copy eventual content of the topic ref -->
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    

    <!-- resolve maprefs -->
    <xsl:template match="*[contains(@class, ' map/topicref ') and @format='ditamap']" priority="100" mode="resolve resolve-map">
        <xsl:variable name="map" select="document(@href, .)"/>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <oxyd:mapref>
                <xsl:attribute name="xml:base" select="document-uri($map)"/>
                <xsl:apply-templates select="$map" mode="#current"/>
            </oxyd:mapref>
            <!-- copy eventual content of the map ref -->
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- topicset reference -->
    <xsl:template match="*[contains(@class, ' mapgroup-d/topicsetref ')]" priority="150" mode="resolve resolve-map">
        <xsl:variable name="map" select="document(substring-before(@href, '#'), .)"/>
        <xsl:variable name="id" select="substring-after(@href, '#')"/>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <oxyd:mapref>
                <xsl:attribute name="xml:base" select="document-uri($map)"/>
                <xsl:apply-templates select="$map//*[@id=$id]" mode="#current"/>
            </oxyd:mapref>
            <!-- copy eventual content of the map ref -->
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- disable topic expasion inside reltables -->
    <xsl:template match="*[contains(@class, ' map/reltable ')]" mode="resolve resolve-map">
        <xsl:apply-templates select="." mode="resolve-base"/>
    </xsl:template>
    
    <!-- Do not try to open resourse-only topics -->
    <xsl:template match="*[contains(@class, ' map/topicref ') and @processing-role='resource-only']" priority="200" mode="resolve">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="resolve"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- CONREFs -->
    <xsl:template match="*[@conref]" mode="resolve-base resolve">
        <xsl:variable name="topicURI" select="substring-before(@conref, '#')"/>
        <xsl:variable name="idPart" select="substring-after(@conref, '#')"/>
        <xsl:variable name="topicID" select="if (contains($idPart, '/')) then substring-before($idPart, '/') else $idPart"/>
        <xsl:variable name="elementID" select="substring-after($idPart, '/')"/>
        <xsl:variable name="topicFile" select="document($topicURI, .)"/>
        <xsl:variable name="targetTopic" select="$topicFile//*[contains(@class, ' topic/topic ') and @id=$topicID]"/>
        <xsl:variable name="end" select="if (@conrefend) then substring-after(@conrefend, '/') else ''"/>
            
        <oxyd:conref element="{name()}">
            <xsl:if test="$end!=''"><xsl:attribute name="range" select="concat($elementID, '-', $end)"></xsl:attribute></xsl:if>
            <xsl:attribute name="xml:base" select="document-uri($topicFile)"/>
            <xsl:choose>
                <xsl:when test="$elementID = ''">
                    <xsl:apply-templates select="$targetTopic" mode="#current"/>
                </xsl:when>
                <xsl:when test="$end=''">
                    <xsl:apply-templates select="$targetTopic//*[@id=$elementID]" mode="#current"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="$targetTopic//*[@id=$elementID]/(self::*|following-sibling::*[@id=$end or following-sibling::*[@id=$end]])" mode="#current"/>
                </xsl:otherwise>
            </xsl:choose>
        </oxyd:conref>
    </xsl:template>
    
    <!-- CONKEYREFs -->
    <xsl:template match="*[@conkeyref]" mode="resolve-base resolve">
        <xsl:param name="keyspace" tunnel="yes"/>
        <xsl:variable name="key" select="if (contains(@conkeyref, '/')) then substring-before(@conkeyref, '/') else @conkeyref"/>
        <xsl:variable name="elementID" select="substring-after(@conkeyref, '/')"/>
        <xsl:variable name="keydef" select="$keyspace/oxyd:keyspace/oxyd:key[@value=$key]"/>
        <xsl:variable name="topicFile" select="$keydef/*[1]/document(@href, .)"/>
        <xsl:variable name="end" select="if (@conrefend) then substring-after(@conrefend, '/') else ''"/>
        <oxyd:conref element="{name()}" key="{$key}">
            <xsl:if test="$end!=''"><xsl:attribute name="range" select="concat($elementID, '-', $end)"></xsl:attribute></xsl:if>
            <xsl:attribute name="xml:base" select="document-uri($topicFile)"/>
            <xsl:choose>
                <xsl:when test="$elementID = ''">
                    <xsl:apply-templates select="$topicFile/*" mode="#current"/>
                </xsl:when>
                <xsl:when test="$end=''">
                    <xsl:apply-templates select="$topicFile//*[@id=$elementID]" mode="#current"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="$topicFile//*[@id=$elementID]/(self::*|following-sibling::*[@id=$end or following-sibling::*[@id=$end]])" mode="#current"/>
                </xsl:otherwise>
            </xsl:choose>
        </oxyd:conref>
    </xsl:template>    
</xsl:stylesheet>