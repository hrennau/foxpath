<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:File="java:java.io.File"
    xmlns:URI="java:java.net.URI"
    exclude-result-prefixes="xs File URI"
    version="2.0">

    <xsl:template name="generateLocalizationFiles">
        <xsl:param name="jsURL"/>
        <xsl:param name="phpURL"/>
        <xsl:result-document href="{$jsURL}" method="text">
            <xsl:text>var localization = new Array();

</xsl:text>
            <xsl:call-template name="generateArrayElements">
                <xsl:with-param name="arrayName" select="'localization'"/>
                <xsl:with-param name="outputLang" select="'js'"/>
            </xsl:call-template>
        </xsl:result-document>
        
        <xsl:result-document href="{$phpURL}" method="text">
            <xsl:text>&lt;?php
$translate = array();

</xsl:text>
            <xsl:call-template name="generateArrayElements">
                <xsl:with-param name="arrayName" select="'$translate'"/>
                <xsl:with-param name="outputLang" select="'php'"/>
            </xsl:call-template>
            <xsl:text>
global $translate;
?&gt;</xsl:text>
        </xsl:result-document>
    </xsl:template>
    
    
    <xsl:template name="generateArrayElements">
        <xsl:param name="arrayName"/>
        <xsl:param name="outputLang"/>
                
        <xsl:variable name="language">
            <xsl:call-template name="getLowerCaseLang"/>
        </xsl:variable>
        <xsl:variable name="languageFileList" select="concat($BASEDIR, '/oxygen-webhelp/resources/localization/strings.xml')"/>
        <xsl:variable name="languageFileUrl" select="File:toURI(File:new(string($languageFileList)))"/>
        <xsl:variable name="stringFileName"
            select="document($languageFileUrl)/*/lang[@xml:lang=$language]/@filename"/>
            <xsl:variable name="stringFile" 
                select="concat($BASEDIR, '/oxygen-webhelp/resources/localization/', 
                               if (string-length($stringFileName) > 0) then $stringFileName 
                                   else 'strings-en-us.xml')"/>
            <xsl:variable name="stringFileUrl" 
                select="URI:toASCIIString(File:toURI(File:new(string($stringFile))))"/>
            <xsl:variable name="strings">
                <xsl:choose>
                    <xsl:when test="$outputLang = 'js'">
                        <xsl:copy-of select="document($stringFileUrl)/strings/str[@js = 'true']"/>
                    </xsl:when>
                    <xsl:when test="$outputLang = 'php'">
                        <xsl:copy-of select="document($stringFileUrl)/strings/str[@php = 'true']"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="count($strings) > 0">
                <xsl:for-each select="$strings/str">
                    <xsl:value-of select="$arrayName"/>
                    <xsl:text>["</xsl:text><xsl:value-of select="@name"/><xsl:text>"]="</xsl:text>
                    <xsl:value-of select="normalize-space()"/>
                    <xsl:text>";
    </xsl:text>
                </xsl:for-each>
            </xsl:if>
    </xsl:template>
</xsl:stylesheet>