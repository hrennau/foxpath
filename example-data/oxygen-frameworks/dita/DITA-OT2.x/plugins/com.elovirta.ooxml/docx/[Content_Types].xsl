<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://schemas.openxmlformats.org/package/2006/content-types"
                xmlns:x="com.elovirta.ooxml"
                xmlns:c="http://schemas.openxmlformats.org/package/2006/content-types"
                exclude-result-prefixes="xs x c"
                version="2.0">

  <xsl:param name="input.uri"/>
  <xsl:variable name="input" select="document($input.uri)" as="document-node()"/>
  
  <xsl:variable name="prefix" select="'application/vnd.openxmlformats-officedocument.wordprocessingml.'" as="xs:string"/>
  <xsl:variable name="suffix" select="'+xml'" as="xs:string"/>
  <xsl:variable name="images" as="element()*">
    <Default Extension="jpeg" ContentType="image/jpeg"/>
    <Default Extension="jpg" ContentType="image/jpeg"/>
    <Default Extension="jfif" ContentType="image/jpeg"/>
    <Default Extension="jpe" ContentType="image/jpeg"/>
    <Default Extension="gif" ContentType="image/gif"/>
    <Default Extension="gfa" ContentType="image/gif"/>
    <Default Extension="png" ContentType="image/png"/>
    <Default Extension="tiff" ContentType="image/tiff"/>
    <Default Extension="tif" ContentType="image/tiff"/>
    <Default Extension="bmp" ContentType="image/bmp"/>
    <Default Extension="dib" ContentType="image/bmp"/>
    <Default Extension="rle" ContentType="image/bmp"/>
    <Default Extension="bmz" ContentType="image/bmp"/>
    <Default Extension="wmf" ContentType="windows/metafile"/>
    <Default Extension="emf" ContentType="image/x-emf"/>
    <Default Extension="eps" ContentType="application/postscript"/>
    <Default Extension="pct" ContentType="image/x-pict"/>
  </xsl:variable>

  <xsl:template match="c:Types">
    <xsl:copy>
      <xsl:apply-templates select="@* | *"/>
      <xsl:variable name="current" select="." as="element()"/>
      <xsl:for-each select="$images">
        <xsl:variable name="ext" select="@Extension" as="attribute()"/>
        <xsl:if test="empty($current/c:Default[@Extension = $ext])">
          <xsl:copy-of select="."/>
        </xsl:if>
      </xsl:for-each>
      <xsl:if test="empty(c:Override[@ContentType = concat($prefix, 'comments', $suffix)])">
        <Override PartName="/word/comments.xml" ContentType="{$prefix}comments{$suffix}"/>
      </xsl:if>
      <xsl:if test="empty(c:Override[@ContentType = concat($prefix, 'footnotes', $suffix)])">
        <Override PartName="/word/footnotes.xml" ContentType="{$prefix}footnotes{$suffix}"/>
      </xsl:if>
      <xsl:if test="empty(c:Override[@ContentType = concat($prefix, 'numbering', $suffix)])">
        <Override PartName="/word/numbering.xml" ContentType="{$prefix}numbering{$suffix}"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="c:Override/@ContentType[. = 'application/vnd.ms-word.template.macroEnabledTemplate.main+xml']">
    <xsl:attribute name="{name()}">
      <xsl:text>application/vnd.ms-word.document.macroEnabled.main+xml</xsl:text>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="c:Override/@ContentType[. = 'application/vnd.openxmlformats-officedocument.wordprocessingml.template.main+xml']">
    <xsl:attribute name="{name()}">
      <xsl:text>application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml</xsl:text>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="node() | @*" priority="-10">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>