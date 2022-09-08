<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
          xmlns:XSLTExtensionIOUtil="java:ro.sync.io.XSLTExtensionIOUtil"
          xmlns:opf="http://www.idpf.org/2007/opf"
          xmlns:xhtml="http://www.w3.org/1999/xhtml" 
          exclude-result-prefixes="XSLTExtensionIOUtil opf xhtml"
          version="2.0">
  
  <!-- Dir of input XML. -->
  <xsl:param name="inputDir"/>
  
  <!-- Dir of output HTML. -->
  <xsl:param name="outputDir"/>
  
  <!-- Dir of images. -->
  <xsl:param name="imagesDir"/>
  
  <xsl:output method="xhtml" 
              encoding="UTF-8"
              indent="no"
              doctype-public=""
              doctype-system="about:legacy-compat"
              omit-xml-declaration="yes"/>
    
    
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@src[parent::xhtml:img]">
      <xsl:choose>
          <xsl:when test="starts-with(., 'http') or starts-with(., 'ftp')">
              <xsl:attribute name="src"><xsl:value-of select="."/></xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
              <xsl:variable name="src" select="XSLTExtensionIOUtil:copyFile($inputDir, ., $outputDir, $imagesDir)"/>
              <xsl:attribute name="src"><xsl:value-of select="$src"/></xsl:attribute>
          </xsl:otherwise>
      </xsl:choose>
  </xsl:template>


    <xsl:template match="xhtml:video[@src][parent::xhtml:div[contains(@class, 'mediaobject')]]">
        <xsl:variable name="src">
            <xsl:choose>
                <xsl:when test="starts-with(@src, 'http') or starts-with(@src, 'ftp')">
                    <xsl:value-of select="@src"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="XSLTExtensionIOUtil:copyFile($inputDir, @src, $outputDir, 'video')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="insertVideo">
            <xsl:with-param name="src" select="$src"/>
        </xsl:call-template>
    </xsl:template>
    
  <xsl:template match="xhtml:embed[@src][parent::xhtml:div[contains(@class, 'mediaobject')]]">
      <xsl:variable name="src">
          <xsl:choose>
              <xsl:when test="starts-with(@src, 'http') or starts-with(@src, 'ftp')">
                  <xsl:value-of select="@src"/>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:value-of select="XSLTExtensionIOUtil:copyFile($inputDir, @src, $outputDir, 'video')"/>
              </xsl:otherwise>
          </xsl:choose>
      </xsl:variable>
      <xsl:call-template name="insertVideo">
          <xsl:with-param name="src" select="$src"/>
      </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="insertVideo">
      <xsl:param name="src"/>
      <video class="video" controls="controls" xmlns="http://www.w3.org/1999/xhtml">
          <source src="{$src}"/>
          <p>Your browser does not support the 'video' tag.</p>
      </video>
  </xsl:template>
  
  
  <xsl:template match="@data[parent::xhtml:object[@type='image/svg+xml']]">
      <xsl:choose>
          <xsl:when test="starts-with(., 'http') or starts-with(., 'ftp')">
              <xsl:attribute name="data"><xsl:value-of select="."/></xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
              <xsl:variable name="data" select="XSLTExtensionIOUtil:copyFile($inputDir, ., $outputDir, $imagesDir)"/>
              <xsl:attribute name="data"><xsl:value-of select="$data"/></xsl:attribute>
          </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
  
  <xsl:template match="@href[parent::xhtml:link[@rel='stylesheet'][@type='text/css']]">
    <xsl:choose>
      <xsl:when test="starts-with(., 'http') or starts-with(., 'ftp')">
          <xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
          <xsl:variable name="cssPath">
              <xsl:choose>
                  <xsl:when test="contains(., '?')">
                      <xsl:value-of select="substring-before(., '?')"/>
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:value-of select="."/>
                  </xsl:otherwise>
              </xsl:choose>
          </xsl:variable>
          <xsl:variable name="href" select="XSLTExtensionIOUtil:copyFile($inputDir, $cssPath, $outputDir, 'css')"/>
        <xsl:attribute name="href"><xsl:value-of select="$href"/></xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>