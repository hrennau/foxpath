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
  xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:x="com.elovirta.ooxml"
  version="2.0" exclude-result-prefixes="x xs">

  <xsl:import href="document.xsl"/>

  <xsl:template match="/">
    <w:footnotes>
      <w:footnote w:type="separator" w:id="-1">
        <w:p>
          <w:pPr>
            <w:spacing w:after="0" w:line="240" w:lineRule="auto"/>
          </w:pPr>
          <w:r>
            <w:separator/>
          </w:r>
        </w:p>
      </w:footnote>
      <w:footnote w:type="continuationSeparator" w:id="0">
        <w:p>
          <w:pPr>
            <w:spacing w:after="0" w:line="240" w:lineRule="auto"/>
          </w:pPr>
          <w:r>
            <w:continuationSeparator/>
          </w:r>
        </w:p>
      </w:footnote>
      <xsl:apply-templates select="//*[contains(@class, ' topic/fn ')]"/>
    </w:footnotes>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/fn ')]">
    <w:footnote w:id="{@x:fn-number}">
      <xsl:variable name="contents" as="element()*" select="*"/>
      <w:p>
        <w:pPr>
          <w:pStyle w:val="FootnoteText"/>
        </w:pPr>
        <w:r>
          <w:rPr>
            <w:rStyle w:val="FootnoteReference"/>
          </w:rPr>
          <w:footnoteRef/>
        </w:r>
        <w:r>
          <w:t xml:space="preserve"> </w:t>
        </w:r>
        <xsl:apply-templates select="$contents[1]/node()"/>
      </w:p>
      <xsl:apply-templates select="$contents[position() ne 1]"/>
    </w:footnote>
  </xsl:template>

  <xsl:template match="node()" mode="block-style.default">
    <w:pStyle w:val="FootnoteText"/>
  </xsl:template>

</xsl:stylesheet>
