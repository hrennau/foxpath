<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Copyright 2001-2011 Syncro Soft SRL. All rights reserved.
    This is licensed under Oxygen XML Editor EULA (http://www.oxygenxml.com/eula.html).
    Redistribution and use outside Oxygen XML Editor is forbidden without express 
    written permission (contact e-mail address support@oxygenxml.com).
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:oxyd="http://www.oxygenxml.com/ns/dita"
    version="2.0">
    
    <!-- Characters that are not part of a word -->
    <xsl:param name="exclude">&quot;&amp;&apos;&gt;&lt;()[]{}.,:!?;-0123456789</xsl:param>
    
    <!-- Process only elements -->
    <xsl:template match="*" mode="index text">
        <xsl:apply-templates select="*" mode="#current"/>
    </xsl:template>
    
    
    <!-- Get the words and characters count for each topic -->
    <xsl:template match="oxyd:topicref" mode="text">
        <xsl:variable name="this" select="generate-id(.)"/>
        <oxyd:topicText topic="{@xml:base}">
            <xsl:variable name="topicText">
                <xsl:for-each select=".//text()[generate-id(ancestor::oxyd:topicref[1]) = $this]">
                    <xsl:value-of select="."/>
                    <xsl:text> </xsl:text>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="normalizedText" select="translate(normalize-space($topicText), $exclude, '')"/>
            <xsl:variable name="characters" select="translate($normalizedText, ' ', '')"/>
            <oxyd:words>
                <xsl:value-of select="string-length($normalizedText) - string-length($characters) + 1"/>
            </oxyd:words>
            <oxyd:characters>
                <xsl:value-of select="string-length(normalize-space($topicText))"/>
            </oxyd:characters>
        </oxyd:topicText>    
        <!-- Process inner topics -->
        <xsl:apply-templates select="*" mode="text"/>
    </xsl:template>    
    
    <!-- Get all the actual words -->
        
    <xsl:template match="oxyd:topicref" mode="index">  
        <xsl:variable name="this" select="generate-id(.)"/>
        <xsl:variable name="topicText">
            <xsl:for-each select=".//text()[generate-id(ancestor::oxyd:topicref[1]) = $this]">
                <xsl:value-of select="."/>
                <xsl:text> </xsl:text>
            </xsl:for-each>
        </xsl:variable>
        <xsl:analyze-string select="translate(normalize-space($topicText), $exclude, '')" regex="\s">
            <xsl:non-matching-substring>
                <oxyd:word><xsl:value-of select="."/></oxyd:word>
            </xsl:non-matching-substring>
        </xsl:analyze-string>        
    </xsl:template>
    
    <xsl:template match="oxyd:conref" mode="index">  
        <xsl:variable name="this" select="generate-id(.)"/>
        <xsl:variable name="conrefText">
            <xsl:for-each select=".//text()">
                <xsl:value-of select="."/>
                <xsl:text> </xsl:text>
            </xsl:for-each>
        </xsl:variable>
        <xsl:analyze-string select="translate(normalize-space($conrefText), $exclude, '')" regex="\s">
            <xsl:non-matching-substring>
                <oxyd:word><xsl:value-of select="."/></oxyd:word>
            </xsl:non-matching-substring>
        </xsl:analyze-string>        
    </xsl:template>
    
</xsl:stylesheet>