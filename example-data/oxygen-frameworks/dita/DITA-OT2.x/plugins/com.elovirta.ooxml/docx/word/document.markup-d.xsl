<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                version="2.0">

  <xsl:template match="*[contains(@class, ' markup-d/markupname ')]">
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
  <xsl:template match="*[contains(@class, ' markup-d/markupname ')]" mode="inline-style">
    <w:rStyle w:val="HTMLCode"/>
  </xsl:template>
  
</xsl:stylesheet>
