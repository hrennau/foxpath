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
               xmlns:x="com.elovirta.ooxml"
               exclude-result-prefixes="x xs"
               version="2.0">

  <xsl:template match="*[contains(@class, ' hi-d/u ')]" mode="inline-style">
    <w:u w:val="single"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' hi-d/b ')]" mode="inline-style">
    <w:b w:val="true"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' hi-d/i ')]" mode="inline-style">
    <w:i/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' hi-d/sup ')]" mode="inline-style">
    <w:vertAlign w:val="superscript"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' hi-d/sub ')]" mode="inline-style">
    <w:vertAlign w:val="subscript"/>
  </xsl:template>
    
</xsl:stylesheet>
