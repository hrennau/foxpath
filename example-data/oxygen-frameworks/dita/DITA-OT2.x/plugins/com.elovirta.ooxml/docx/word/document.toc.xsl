<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006"
               xmlns:o="urn:schemas-microsoft-com:office:office"
               xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
               xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
               xmlns:v="urn:schemas-microsoft-com:vml"
               xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
               xmlns:w10="urn:schemas-microsoft-com:office:word"
               xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
               xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
               xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
               xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
               xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
               xmlns:opentopic="http://www.idiominc.com/opentopic"
               xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
               xmlns:x="com.elovirta.ooxml"
               exclude-result-prefixes="x xs opentopic opentopic-index ot-placeholder"
               version="2.0">

  <xsl:variable name="tocMaximumLevel" select="9" as="xs:integer"/>

  <xsl:template match="ot-placeholder:toc">
    <xsl:apply-templates select="/" mode="toc"/>
  </xsl:template>

  <xsl:template match="/" mode="toc" name="toc">
    <xsl:comment>TOC</xsl:comment>
    <w:p>
      <w:pPr>
        <w:pStyle w:val="TOCHeading"/>
      </w:pPr>
      <w:r>
        <w:lastRenderedPageBreak/>
        <w:t>
          <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'Table of Contents'"/>
          </xsl:call-template>
        </w:t>
      </w:r>
      <xsl:apply-templates select="." mode="toc-field"/>
    </w:p>
    <xsl:apply-templates select="*[contains(@class, ' map/map ')]/*[contains(@class, ' topic/topic ')]" mode="x:toc"/>
    <!-- End TOC field -->
    <w:p>
      <w:r>
        <w:fldChar w:fldCharType="end"/>
      </w:r>
      <!--w:r>
        <w:br w:type="page"/>
      </w:r-->
    </w:p>
  </xsl:template>
  
  <xsl:template match="/" mode="toc-field">
    <w:r>
      <w:fldChar w:fldCharType="begin"/>
    </w:r>
    <w:r>
      <w:instrText>
        <xsl:attribute name="xml:space">preserve</xsl:attribute>
        <xsl:apply-templates select="." mode="toc-prefix"/> 
      </w:instrText>
    </w:r>
    <w:r>
      <w:fldChar w:fldCharType="separate"/>
    </w:r>
  </xsl:template>
  
  <xsl:template match="*" mode="toc-prefix">
    <xsl:value-of>TOC \o "1-<xsl:value-of select="$tocMaximumLevel"/>" \w \* MERGEFORMAT</xsl:value-of> 
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/topic ')]" mode="x:toc">
    <xsl:param name="depth" select="count(ancestor-or-self::*[contains(@class, ' topic/topic ')])" as="xs:integer"/>
    <xsl:param name="prefix" as="node()*"/>
    <xsl:variable name="target" select="concat($bookmark-prefix.toc, generate-id())" as="xs:string"/>
    <w:p>
      <w:pPr>
        <w:pStyle w:val="TOC{$depth}"/>
        <xsl:if test="*[contains(@class, ' topic/topic ')]">
          <w:keepNext/>
        </xsl:if>
        <w:tabs>
          <xsl:if test="@x:header-number">
            <!--xsl:variable name="tabs" as="xs:integer+" select="(373, 795, 1217, 1639, 1772, 2061, 2483, 2906, 3328)"/>
            <w:tab w:val="left" w:pos="{$tabs[$depth]}"/-->
            <w:tab w:val="left" w:pos="{422 * $depth}"/>
          </xsl:if>
          <w:tab w:val="right" w:leader="dot" w:pos="{$body-width}"/>
        </w:tabs>
        <w:rPr>
          <w:noProof/>
        </w:rPr>
      </w:pPr>
      <xsl:copy-of select="$prefix"/>
      <xsl:if test="@x:header-number">
        <w:r>
          <w:t>
            <xsl:value-of select="@x:header-number"/>
          </w:t>
        </w:r>
        <w:r>
          <w:tab/>
        </w:r>
      </xsl:if>
      <w:r>
        <w:t>
          <xsl:apply-templates select="*[contains(@class, ' topic/title ')]/node()"/>
        </w:t>
      </w:r>
      <w:r>
        <w:tab/>
      </w:r>
      <w:r>
        <w:fldChar w:fldCharType="begin" w:dirty="true"/>
      </w:r>
      <w:r>
        <w:instrText xml:space="preserve"> PAGEREF <xsl:value-of select="$target"/> \h </w:instrText>
      </w:r>
      <w:r>
        <w:fldChar w:fldCharType="separate"/>
      </w:r>
      <w:r>
        <w:t>0</w:t>
      </w:r>
      <w:r>
        <w:fldChar w:fldCharType="end"/>
      </w:r>
    </w:p>
    <xsl:if test="$depth lt $tocMaximumLevel">
      <xsl:apply-templates select="*[contains(@class, ' topic/topic ')]" mode="x:toc">
        <xsl:with-param name="depth" select="$depth + 1"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' glossentry/glossentry ')]" mode="x:toc" priority="1000"/>

</xsl:stylesheet>
