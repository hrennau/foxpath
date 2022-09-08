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
               xmlns:a14="http://schemas.microsoft.com/office/drawing/2010/main"
               xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
               xmlns:opentopic="http://www.idiominc.com/opentopic"
               xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
               xmlns:x="com.elovirta.ooxml"
               exclude-result-prefixes="x xs opentopic opentopic-index ot-placeholder"
               version="2.0">

  <xsl:import href="plugin:org.dita.base:xsl/common/dita-utilities.xsl"/>
  <xsl:import href="plugin:org.dita.base:xsl/common/output-message.xsl"/>

  <xsl:import href="document.utils.xsl"/>
  <xsl:import href="document.topic.xsl"/>
  <xsl:import href="document.abbrev-d.xsl"/>
  <xsl:import href="document.hi-d.xsl"/>
  <xsl:import href="document.markup-d.xsl"/>
  <xsl:import href="document.pr-d.xsl"/>
  <xsl:import href="document.sw-d.xsl"/>
  <xsl:import href="document.ui-d.xsl"/>
  <xsl:import href="document.xml-d.xsl"/>
  <xsl:import href="document.toc.xsl"/>
  <xsl:import href="document.table.xsl"/>
  <xsl:import href="document.task.xsl"/>
  <xsl:import href="document.link.xsl"/>

  <xsl:output indent="no"/>

  <xsl:param name="input.dir.url"/>
  
  <xsl:variable name="template" select="document(concat($template.dir, '/word/document.xml'))" as="document-node()?"/>
  <xsl:variable name="root" select="/" as="document-node()"/>
  <xsl:variable name="map" select="/*[contains(@class, ' map/map ')]/opentopic:map" as="element()"/>
  <xsl:variable name="language" select="string((//@xml:lang)[1])" as="xs:string"/>

  <xsl:variable name="sectPr" select="$template/w:document/w:body/w:sectPr[last()]" as="element()"/>
  <xsl:variable name="body-width" as="xs:integer">
    <xsl:sequence select="xs:integer($sectPr/w:pgSz/@w:w) - xs:integer($sectPr/w:pgMar/@w:left) - xs:integer($sectPr/w:pgMar/@w:right)"/>
  </xsl:variable>

  <xsl:key name="map-id" match="opentopic:map//*[@id]" use="@id"/>

  <xsl:function name="x:get-topicref">
    <xsl:param name="topic" as="element()"/>
    <xsl:variable name="id" select="$topic/ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id" as="attribute()"/>
    <xsl:sequence select="key('map-id', $id, $map)"/>
  </xsl:function>

  <xsl:template match="/">
    <xsl:variable name="content" as="node()*">
      <w:document>
        <w:body>
          <xsl:apply-templates select="*" mode="root"/>
        </w:body>
      </w:document>
    </xsl:variable>
    <xsl:variable name="fixup" as="node()*">
      <xsl:apply-templates select="$content" mode="fixup">
        <xsl:with-param name="bookmarks" as="xs:string*" tunnel="yes">
          <xsl:for-each-group select="$content//w:bookmarkStart" group-by="@w:id">
            <xsl:value-of select="current-grouping-key()"/>
          </xsl:for-each-group>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:apply-templates select="$fixup" mode="whitespace"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' map/map ')]" mode="root">
    <xsl:apply-templates select="/" mode="cover"/>
    <xsl:apply-templates select="/" mode="legal"/>
    <xsl:apply-templates select="/" mode="toc"/>
    <xsl:apply-templates select="." mode="body"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' bookmap/bookmap ')]" mode="root" priority="10">
    <xsl:apply-templates select="/" mode="cover"/>
    <xsl:apply-templates select="/" mode="legal"/>
    <xsl:apply-templates select="." mode="body"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' map/map ')]" mode="body">
    <xsl:apply-templates select="*[contains(@class, ' topic/topic ')]"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' bookmap/bookmap ')]" mode="body" priority="10">
    <xsl:apply-templates select="ot-placeholder:toc | *[contains(@class, ' topic/topic ')]"/>
  </xsl:template>

  <xsl:template match="/" mode="cover">
    <w:p>
      <w:pPr>
        <w:pStyle w:val="Title"/>
        <w:spacing w:before="720"/>
        <w:rPr>
          <w:lang w:val="{$language}"/>
        </w:rPr>
      </w:pPr>
      <w:r>
        <w:fldChar w:fldCharType="begin"/>
      </w:r>
      <w:r>
        <w:rPr>
          <w:lang w:val="{$language}"/>
        </w:rPr>
        <w:instrText xml:space="preserve">TITLE \* MERGEFORMAT</w:instrText>
      </w:r>
      <w:r>
        <w:fldChar w:fldCharType="separate"/>
      </w:r>
      <w:r>
        <w:rPr>
          <w:lang w:val="{$language}"/>
        </w:rPr>
        <w:t>
          <xsl:call-template name="get-title"/>
        </w:t>
      </w:r>
      <w:r>
        <w:fldChar w:fldCharType="end"/>
      </w:r>
    </w:p>
  </xsl:template>

  <xsl:template match="/" mode="legal"/>

  <xsl:template name="get-title">
    <xsl:for-each select="/*[contains(@class, ' map/map ')]">
      <xsl:choose>
        <xsl:when test="@title">
          <xsl:value-of select="@title"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="opentopic:map">
            <xsl:choose>
              <xsl:when test="*[contains(@class, ' bookmap/booktitle ')]/*[contains(@class, ' bookmap/mainbooktitle ')]">
                <xsl:apply-templates select="*[contains(@class, ' bookmap/booktitle ')]/*[contains(@class, ' bookmap/mainbooktitle ')]/node()"/>                
              </xsl:when>
              <xsl:when test="*[contains(@class, 'topic/title ')]">
                <xsl:apply-templates select="*[contains(@class, ' topic/title ')]/node()"/>                
              </xsl:when>
            </xsl:choose>            
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
