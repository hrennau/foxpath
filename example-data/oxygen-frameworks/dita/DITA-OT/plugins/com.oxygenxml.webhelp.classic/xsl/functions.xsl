<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:oxygen="http://www.oxygenxml.com/functions"
     xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="oxygen xs"
    version="2.0"
    xmlns:d="http://docbook.org/ns/docbook"
    xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc"
    xmlns:index="http://www.oxygenxml.com/ns/webhelp/index"
    xmlns:File="java:java.io.File">
    
    <xsl:function name="oxygen:makeURL" as="item()">
        <xsl:param name="filepath"/>
        <xsl:variable name="correctedPath" select="replace($filepath, '\\', '/')"/>
        <xsl:variable name="url">
            <xsl:choose>
                <!-- Mac / Linux paths start with / -->
                <xsl:when test="starts-with($correctedPath, '/')">
                    <xsl:value-of select="concat('file://', $correctedPath)"/>
                </xsl:when>
                <!-- Windows paths not start with / -->
                <xsl:otherwise>
                    <xsl:value-of select="concat('file:///', $correctedPath)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="iri-to-uri($url)"/>
    </xsl:function>
  
  
    <xsl:function name="oxygen:extractLastClassValue" as="item()">
      <xsl:param name="classValue" as="item()"/>
      <xsl:variable name="afterSlash" select="substring-after($classValue, '/')"/>
      <xsl:choose>
        <xsl:when test="string-length($afterSlash) = 0">
          <xsl:value-of select="translate($classValue, ' ', '')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="oxygen:extractLastClassValue($afterSlash)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:function>
    
    <!-- 
      Escape single quote in the given string 
    -->
  <xsl:function name="oxygen:escapeQuote" as="xs:string">
    <xsl:param name="toEscape" as="xs:string"/>
    <xsl:value-of select="replace($toEscape,'''','\\''')"/>
  </xsl:function>
</xsl:stylesheet>