<?xml version="1.0" encoding="UTF-8"?>

<!--
    
    Apply this stylesheet to ../src/translation_webhelp.xml file, received from translation company, 
    to generate the file used for WebHelp localization.
        
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:character-map name="simple.quote">
        <xsl:output-character character="&apos;" string="&amp;apos;"/>
    </xsl:character-map>
    
    <xsl:template match="/">
        <xsl:for-each select="/translation/languageList/language">
              <xsl:variable name="language">
                  <xsl:value-of select="@lang" />
              </xsl:variable>
            
              <!-- 
                Write every available languge to different file.
              -->
            
              <xsl:result-document href="strings-{$language}.xml" method="xml" indent="yes" 
                  use-character-maps="simple.quote" doctype-system="strings.dtd" encoding="UTF-8">

<xsl:comment>
Oxygen Webhelp plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

Translation strings for <xsl:value-of select="concat(upper-case(substring(@lang, 4)),' ', @description)"/> language.
</xsl:comment>
                  
                  <strings>
                      <xsl:message select="$language" />
                      <xsl:attribute name="xml:lang">
                          <xsl:value-of select="$language"/>
                      </xsl:attribute>
                      
                      <xsl:for-each select="/translation/key">
                          
                          <xsl:variable name="usedInJS" select="contains(@usages,'js')" />
                          <xsl:variable name="usedInPHP" select="contains(@usages,'php')" />    
                          
                          <str>
                              <xsl:attribute name="name">
                                  <xsl:copy-of select="@value" />
                              </xsl:attribute>
                              
                              <xsl:choose>
                                  <xsl:when test="$usedInJS"><xsl:attribute name="js">true</xsl:attribute></xsl:when>
                                  <xsl:otherwise><xsl:attribute name="js">false</xsl:attribute></xsl:otherwise>
                              </xsl:choose>
                              <xsl:choose>
                                  <xsl:when test="$usedInPHP"><xsl:attribute name="php">true</xsl:attribute></xsl:when>
                                  <xsl:otherwise><xsl:attribute name="php">false</xsl:attribute></xsl:otherwise>
                              </xsl:choose>
                          
                              <xsl:copy-of select="val[@lang=$language]/text()"/>
                          </str>
                      </xsl:for-each>
                  </strings>
              </xsl:result-document>
            
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>