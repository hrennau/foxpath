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
    
  <xsl:param name="WEBHELP_PARAMETERS_URL"/>
  
  <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
    <xd:desc>
      <xd:p>Webhelp parameters with assigned values.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:variable 
    name="plugin.declared.parameters" 
    select="doc($WEBHELP_PARAMETERS_URL)/properties"/>
  
  <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
    <xd:desc>
      <xd:p>Webhelp parameters with default values..</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:variable 
    name="plugin.default.parameters" 
    select="doc('plugin:com.oxygenxml.webhelp.responsive:plugin.xml')//param[val[@default='true']]"/>
    
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
  
  <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
    <xd:desc>
      <xd:p>Retrieves the value for the given parameter.</xd:p>
    </xd:desc>
    <xd:param name="parameterName">The name of the parameter.</xd:param>
  </xd:doc>
  <xsl:function name="oxygen:getParameter">
    <xsl:param name="parameterName"/>
    <xsl:choose>
      <!-- Look for an assigne value. -->
      <xsl:when test="$plugin.declared.parameters/property[@name=$parameterName]">
        <xsl:value-of select="$plugin.declared.parameters/property[@name=$parameterName]/@value"/>
      </xsl:when>
      <!-- Otherwise look for a default value. -->
      <xsl:when test="$plugin.default.parameters[@name=$parameterName]">
        <xsl:value-of select="$plugin.default.parameters[@name=$parameterName]/val[@default='true']/node()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="''"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>