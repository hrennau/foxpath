<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
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
  xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:x="com.elovirta.ooxml" version="2.0"
  exclude-result-prefixes="x xs">

  <xsl:import href="document.xsl"/>

  <xsl:variable name="doc" select="document(concat($template.dir, 'word/numbering.xml'))" as="document-node()?"/>

  <xsl:template match="/">
    <w:numbering>
      <xsl:for-each select="//@x:list-number">
        <xsl:choose>
          <xsl:when test="contains(../@class, ' topic/ol')">
            <xsl:call-template name="ol">
              <xsl:with-param name="number" select="."/>
              <xsl:with-param name="indent-start" select="xs:integer($indent-base)"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="ul">
              <xsl:with-param name="number" select="."/>
              <xsl:with-param name="indent-start" select="xs:integer($indent-base)"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <!-- original numberings -->
      <xsl:copy-of select="$doc/w:numbering/w:abstractNum"/>
      <!-- list numbering -->
      <xsl:for-each select="//@x:list-number">
        <w:num w:numId="{.}">
          <w:abstractNumId w:val="{.}"/>
        </w:num>
      </xsl:for-each>
      <!-- original numberings -->
      <xsl:copy-of select="$doc/w:numbering/w:num"/>
      
    </w:numbering>
  </xsl:template>
  
  <xsl:template name="ol">
    <xsl:param name="number" as="xs:string"/>
    <xsl:param name="indent-start" as="xs:integer"/>
    <xsl:apply-templates select="." mode="ol">
      <xsl:with-param name="number" select="$number"/>
      <xsl:with-param name="indent-start" select="$indent-start"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="@* | node()" mode="ol">
    <xsl:param name="number"/>
    <xsl:param name="indent-start" as="xs:integer"/>
    <!-- Ordered list -->
    <w:abstractNum w:abstractNumId="{$number}">
      <!--w:nsid w:val="54120D7E"/-->
      <w:multiLevelType w:val="hybridMultilevel"/>
      <w:tmpl w:val="7690F386"/>
      <w:lvl w:ilvl="0" w:tplc="0809000F">
        <w:start w:val="1"/>
        <w:numFmt w:val="decimal"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="%1."/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 1 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
      </w:lvl>
      <w:lvl w:ilvl="1" w:tplc="08090019">
        <w:start w:val="1"/>
        <w:numFmt w:val="lowerLetter"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="%2."/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 2 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
      </w:lvl>
      <w:lvl w:ilvl="2" w:tplc="0809001B" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="lowerRoman"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="%3."/>
        <w:lvlJc w:val="right"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 3 * xs:integer($increment-base)}" w:hanging="180"/>
        </w:pPr>
      </w:lvl>
      <w:lvl w:ilvl="3" w:tplc="0809000F" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="decimal"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="%4."/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 4 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
      </w:lvl>
      <w:lvl w:ilvl="4" w:tplc="08090019" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="lowerLetter"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="%5."/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 5 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
      </w:lvl>
      <w:lvl w:ilvl="5" w:tplc="0809001B" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="lowerRoman"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="%6."/>
        <w:lvlJc w:val="right"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 6 * xs:integer($increment-base)}" w:hanging="180"/>
        </w:pPr>
      </w:lvl>
      <w:lvl w:ilvl="6" w:tplc="0809000F" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="decimal"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="%7."/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 7 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
      </w:lvl>
      <w:lvl w:ilvl="7" w:tplc="08090019" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="lowerLetter"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="%8."/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 8 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
      </w:lvl>
      <w:lvl w:ilvl="8" w:tplc="0809001B" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="lowerRoman"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="%9."/>
        <w:lvlJc w:val="right"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 9 * xs:integer($increment-base)}" w:hanging="180"/>
        </w:pPr>
      </w:lvl>
    </w:abstractNum>
  </xsl:template>
  
  <xsl:template name="ul">
    <xsl:param name="number" as="xs:string"/>
    <xsl:param name="indent-start" as="xs:integer"/>
    <xsl:apply-templates select="." mode="ul">
      <xsl:with-param name="number" select="$number"/>
      <xsl:with-param name="indent-start" select="$indent-start"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="@* | node()" mode="ul">
    <xsl:param name="number"/>
    <xsl:param name="indent-start" as="xs:integer"/>
    <w:abstractNum w:abstractNumId="{$number}">
      <!--w:nsid w:val="5910710B"/-->
      <w:multiLevelType w:val="hybridMultilevel"/>
      <w:tmpl w:val="0316CE72"/>
      <w:lvl w:ilvl="0" w:tplc="08090001">
        <w:start w:val="1"/>
        <w:numFmt w:val="bullet"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val=""/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 1 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
        <w:rPr>
          <w:rFonts w:ascii="Symbol" w:hAnsi="Symbol" w:hint="default"/>
        </w:rPr>
      </w:lvl>
      <w:lvl w:ilvl="1" w:tplc="08090003" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="bullet"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="o"/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 2 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
        <w:rPr>
          <w:rFonts w:ascii="Courier New" w:hAnsi="Courier New" w:cs="Courier New"
            w:hint="default"/>
        </w:rPr>
      </w:lvl>
      <w:lvl w:ilvl="2" w:tplc="08090005" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="bullet"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val=""/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 3 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
        <w:rPr>
          <w:rFonts w:ascii="Wingdings" w:hAnsi="Wingdings" w:hint="default"/>
        </w:rPr>
      </w:lvl>
      <w:lvl w:ilvl="3" w:tplc="08090001" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="bullet"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val=""/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 4 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
        <w:rPr>
          <w:rFonts w:ascii="Symbol" w:hAnsi="Symbol" w:hint="default"/>
        </w:rPr>
      </w:lvl>
      <w:lvl w:ilvl="4" w:tplc="08090003" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="bullet"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="o"/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 5 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
        <w:rPr>
          <w:rFonts w:ascii="Courier New" w:hAnsi="Courier New" w:cs="Courier New"
            w:hint="default"/>
        </w:rPr>
      </w:lvl>
      <w:lvl w:ilvl="5" w:tplc="08090005" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="bullet"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val=""/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 6 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
        <w:rPr>
          <w:rFonts w:ascii="Wingdings" w:hAnsi="Wingdings" w:hint="default"/>
        </w:rPr>
      </w:lvl>
      <w:lvl w:ilvl="6" w:tplc="08090001" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="bullet"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val=""/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 7 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
        <w:rPr>
          <w:rFonts w:ascii="Symbol" w:hAnsi="Symbol" w:hint="default"/>
        </w:rPr>
      </w:lvl>
      <w:lvl w:ilvl="7" w:tplc="08090003" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="bullet"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val="o"/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 8 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
        <w:rPr>
          <w:rFonts w:ascii="Courier New" w:hAnsi="Courier New" w:cs="Courier New"
            w:hint="default"/>
        </w:rPr>
      </w:lvl>
      <w:lvl w:ilvl="8" w:tplc="08090005" w:tentative="1">
        <w:start w:val="1"/>
        <w:numFmt w:val="bullet"/>
        <xsl:apply-templates select="parent::*" mode="block-style"/>
        <w:lvlText w:val=""/>
        <w:lvlJc w:val="left"/>
        <w:pPr>
          <w:ind w:left="{$indent-start + 9 * xs:integer($increment-base)}" w:hanging="360"/>
        </w:pPr>
        <w:rPr>
          <w:rFonts w:ascii="Wingdings" w:hAnsi="Wingdings" w:hint="default"/>
        </w:rPr>
      </w:lvl>
    </w:abstractNum>
  </xsl:template>

</xsl:stylesheet>
