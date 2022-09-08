<?xml version="1.0" encoding="utf-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  exclude-result-prefixes="relpath">
    
    <!--
        EXM-38366 - WebHelp localization support does not work with DITA-OT 1.8.5
    -->
    <!--<xsl:import href="plugin:org.dita.base:xsl/common/dita-utilities.xsl"/>-->
    <xsl:import href="../../../../xsl/common/dita-utilities.xsl"/>
    
    <xsl:import href="plugin:org.dita.base:xsl/common/output-message.xsl"/>
    <xsl:include href="common-utilities.xsl"/>

  <xsl:variable name="msgprefix">DOTX</xsl:variable>
  
  <!-- Uses the DITA localization architecture, but our strings. -->
  <xsl:template name="getWebhelpString">
    <xsl:param name="stringName" />
      <xsl:call-template name="getString" use-when="starts-with(system-property('DOT_VERSION'), '1.')">
          <xsl:with-param name="stringName" select="$stringName"/>
      </xsl:call-template>
      <xsl:call-template name="getVariable" use-when="string-length(system-property('DOT_VERSION')) > 0 and not(starts-with(system-property('DOT_VERSION'), '1.'))">
          <xsl:with-param name="id" select="$stringName"/>
      </xsl:call-template>
  </xsl:template>
  

  <!-- Replace file extension in a URI -->
  <xsl:template name="replace-extension">
    <xsl:param name="filename"/>
    <xsl:param name="extension"/>
    <xsl:param name="ignore-fragment" select="false()"/>
    <xsl:param name="forceReplace" select="false()"/>
    <xsl:variable name="file-path">
        <xsl:choose>
            <xsl:when test="contains($filename, '#')">
                <xsl:value-of select="substring-before($filename, '#')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$filename"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="f">
        <xsl:call-template name="substring-before-last">
            <xsl:with-param name="text" select="$file-path"/>
            <xsl:with-param name="delim" select="'.'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="original-extension">
        <xsl:call-template name="substring-after-last">
            <xsl:with-param name="text" select="$file-path"/>
            <xsl:with-param name="delim" select="'.'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:if test="string($f)">
        <xsl:choose>
            <xsl:when test="$forceReplace or $original-extension = 'xml' or $original-extension = 'dita'">
                <xsl:value-of select="concat($f, $extension)"/>  
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($f, '.', $original-extension)"/>  
            </xsl:otherwise>
        </xsl:choose>
    </xsl:if>
    <xsl:if test="not($ignore-fragment) and contains($filename, '#')">
        <xsl:value-of select="concat('#', substring-after($filename, '#'))"/>
    </xsl:if>
  </xsl:template>
    

  <xsl:template name="substring-after-last">
    <xsl:param name="text"/>
    <xsl:param name="delim"/>
    
    <xsl:if test="string($text) and string($delim)">
        <xsl:variable name="tail" select="substring-after($text, $delim)" />
        <xsl:choose>
            <xsl:when test="string-length($tail) > 0">
                <xsl:call-template name="substring-after-last">
                    <xsl:with-param name="text" select="$tail" />
                    <xsl:with-param name="delim" select="$delim" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>