<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                version="2.0">

  <xsl:template match="*[contains(@class, ' xml-d/xmlelement ')]">
    <w:r>
      <w:rPr>
        <w:rStyle w:val="HTMLCode"/>
      </w:rPr>
      <w:t>&lt;</w:t>
    </w:r>
    <xsl:apply-templates/>
    <w:r>
      <w:rPr>
        <w:rStyle w:val="HTMLCode"/>
      </w:rPr>
      <w:t>&gt;</w:t>
    </w:r>
  </xsl:template>
  <xsl:template match="*[contains(@class, ' xml-d/xmlelement ')]" mode="inline-style">
    <w:rStyle w:val="HTMLCode"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' xml-d/xmlatt ')]">
    <w:r>
      <w:rPr>
        <w:rStyle w:val="HTMLCode"/>
      </w:rPr>
      <w:t>@</w:t>
    </w:r>
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="*[contains(@class, ' xml-d/xmlatt ')]" mode="inline-style">
    <w:rStyle w:val="HTMLCode"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' xml-d/textentity ')]">
    <w:r>
      <w:rPr>
        <w:rStyle w:val="HTMLCode"/>
      </w:rPr>
      <w:t>&amp;</w:t>
    </w:r>
    <xsl:apply-templates/>
    <w:r>
      <w:rPr>
        <w:rStyle w:val="HTMLCode"/>
      </w:rPr>
      <w:t>;</w:t>
    </w:r>
  </xsl:template>
  <xsl:template match="*[contains(@class, ' xml-d/textentity ')]" mode="inline-style">
    <w:rStyle w:val="HTMLCode"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' xml-d/parameterentity ')]">
    <w:r>
      <w:rPr>
        <w:rStyle w:val="HTMLCode"/>
      </w:rPr>
      <w:t>%</w:t>
    </w:r>
    <xsl:apply-templates/>
    <w:r>
      <w:rPr>
        <w:rStyle w:val="HTMLCode"/>
      </w:rPr>
      <w:t>;</w:t>
    </w:r>
  </xsl:template>
  <xsl:template match="*[contains(@class, ' xml-d/parameterentity ')]" mode="inline-style">
    <w:rStyle w:val="HTMLCode"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' xml-d/numcharref ')]">
    <w:r>
      <w:rPr>
        <w:rStyle w:val="HTMLCode"/>
      </w:rPr>
      <w:t>&amp;#</w:t>
    </w:r>
    <xsl:apply-templates/>
    <w:r>
      <w:rPr>
        <w:rStyle w:val="HTMLCode"/>
      </w:rPr>
      <w:t>;</w:t>
    </w:r>
  </xsl:template>
  <xsl:template match="*[contains(@class, ' xml-d/numcharref ')]" mode="inline-style">
    <w:rStyle w:val="HTMLCode"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' xml-d/xmlnsname ')]">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="*[contains(@class, ' xml-d/xmlnsname ')]" mode="inline-style">
    <w:rStyle w:val="HTMLCode"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' xml-d/xmlpi ')]">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="*[contains(@class, ' xml-d/xmlpi ')]" mode="inline-style">
    <w:rStyle w:val="HTMLCode"/>
  </xsl:template>
    
</xsl:stylesheet>
