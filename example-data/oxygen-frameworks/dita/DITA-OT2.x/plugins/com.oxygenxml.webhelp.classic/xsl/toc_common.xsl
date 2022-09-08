<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc"
    xmlns:oxygen="http://www.oxygenxml.com/functions"
    version="2.0">
    <xsl:param name="namespace" select="''"/>
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Function to compute the title displayed in the TOC for a topic.</xd:p>
        </xd:desc>
        <xd:param name="topic">The topic for extracting the title for.</xd:param>
    </xd:doc>
    <xsl:function name="oxygen:getTopicTitle">
        <xsl:param name="topic"/>
        <xsl:choose>
            <xsl:when test="$topic/toc:title">
                <xsl:apply-templates select="$topic/toc:title/node()" mode="copy-xhtml-without-links"/>
            </xsl:when>
            <xsl:when test="$topic/@title">
                <xsl:value-of select="$topic/@title"/>
            </xsl:when>
            <xsl:when test="$topic/@navtitle">
                <xsl:value-of select="$topic/@navtitle"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
        <xd:desc>
            <xd:p>Create the content of a TOC entry.</xd:p>
        </xd:desc>
        <xd:param name="title">The title of the topic associated with the this TOC entry.</xd:param>
    </xd:doc>
    <xsl:template name="createTOCContent">
        <xsl:param name="cTopic" select="."/>
        <xsl:param name="title"/>
        
        <xsl:element name="span" namespace="{$namespace}">
            <xsl:attribute name="class">topicref</xsl:attribute>
            <xsl:if test="$cTopic/@outputclass">
                <xsl:attribute name="class">
                    <xsl:value-of select="@outputclass"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:variable name="hrefLink">
                <xsl:choose>
                    <xsl:when test="(string-length($cTopic/@href) eq 0) or ($cTopic/@href eq 'javascript:void(0)') ">
                        <!-- EXM-38925 Select the href of the first descendant topic ref -->
                        <xsl:value-of select="$cTopic/descendant::toc:topic[(string-length(@href) ne 0) and (@href ne 'javascript:void(0)')][1]/@href"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$cTopic/@href"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:choose>                
                <xsl:when test="$hrefLink">
                    <xsl:element name="a" namespace="{$namespace}">
                        <xsl:attribute name="href"><xsl:value-of select="concat($PATH2PROJ, $hrefLink)"/></xsl:attribute>
                        <xsl:if test="$cTopic/@scope = 'external' or $cTopic/@scope = 'peer'">
                            <xsl:attribute name="target">_blank</xsl:attribute>
                        </xsl:if>
                        <xsl:for-each select="$cTopic/@*[starts-with(name(), 'data-')]">
                            <xsl:copy/>
                        </xsl:for-each>
                        <xsl:copy-of select="$title"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$title"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="*" mode="copy-xhtml copy-xhtml-without-links">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="@* | node()" mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="@*" mode="copy-xhtml copy-xhtml-without-links">
        <xsl:attribute name="{local-name()}" select="."/>
    </xsl:template>
    
    <!-- Skip HTML 'a' elements from output -->
    <xsl:template match="*:a" mode="copy-xhtml-without-links">
        <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:template>
    
</xsl:stylesheet>