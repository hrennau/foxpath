<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen WeHhelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:relpath="http://dita2indesign/functions/relpath"
    exclude-result-prefixes="xs relpath"
    version="2.0">

  <xsl:import href="../original/relpath_util.xsl"/>
    <xsl:import href="plugin:org.dita.base:xsl/common/output-message.xsl"/>
    <xsl:import href="plugin:org.dita.base:xsl/common/dita-utilities.xsl"/>
    
    <xsl:variable name="msgprefix">DOTX</xsl:variable>
    
    <!-- The prefix of the input XML file path. -->
    <xsl:param name="TEMPFOLDER"/>
    
    <!-- Extension of output files for example .html -->
    <xsl:param name="OUT_EXT"/>
    
    <xsl:template match="/">
        <index xmlns="http://www.oxygenxml.com/ns/webhelp/index">
            <xsl:apply-templates/>
        </index>
    </xsl:template>

    <xsl:template match="text()|@*"/>
    
    <xsl:template match="*[contains(@class, ' topic/indexterm ')]">
        <term 
            xmlns="http://www.oxygenxml.com/ns/webhelp/index" 
            name="{normalize-space(string-join(text(), ' '))}" 
            sort-as="{normalize-space(string-join(text(), ' '))}">
            <xsl:if test="*[contains(@class, ' topic/keyword ')]">
                <xsl:attribute name="name">
                    <xsl:value-of select="*[contains(@class, ' topic/keyword ')]"/>
                </xsl:attribute>
                <xsl:attribute name="sort-as">
                    <xsl:value-of select="*[contains(@class, ' topic/keyword ')]"/>
                </xsl:attribute>
            </xsl:if>
            
            <xsl:if test="*[contains(@class, ' indexing-d/index-sort-as ')]">
                <xsl:attribute name="sort-as">
                    <xsl:value-of select="*[contains(@class, ' indexing-d/index-sort-as ')]"/>
                </xsl:attribute>
            </xsl:if>
            
            <xsl:if test="*[contains(@class, ' ut-d/sort-as ')]/@value">
                <xsl:attribute name="sort-as">
                    <xsl:value-of select="*[contains(@class, ' ut-d/sort-as ')]/@value"/>
                </xsl:attribute>
            </xsl:if>
            
            <xsl:choose>
                <xsl:when test="*[contains(@class, ' topic/indexterm ')]">
                    <xsl:apply-templates select="*[contains(@class, ' topic/indexterm ')]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="target">
                        <xsl:call-template name="replace-extension">
                            <xsl:with-param name="filename" 
                                select="substring-after(relpath:unencodeUri(document-uri(/)), 
                                relpath:unencodeUri($TEMPFOLDER))"/>
                            <xsl:with-param name="extension" select="$OUT_EXT"/>
                        </xsl:call-template>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </term>
    </xsl:template>
</xsl:stylesheet>