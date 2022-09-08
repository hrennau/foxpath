<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
                xmlns:mo="http://schemas.microsoft.com/office/mac/office/2008/main"
                xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
                xmlns:mv="urn:schemas-microsoft-com:mac:vml" xmlns:o="urn:schemas-microsoft-com:office:office"
                xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
                xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
                xmlns:v="urn:schemas-microsoft-com:vml"
                xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"
                xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
                xmlns:w10="urn:schemas-microsoft-com:office:word"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
                xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
                xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"
                xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
                xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
                xmlns:a14="http://schemas.microsoft.com/office/drawing/2010/main"
                xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006"
                xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
                xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
                xmlns:x="com.elovirta.ooxml"
                version="2.0"
                exclude-result-prefixes="x xs">

  <xsl:import href="document.xsl"/>
  <!--xsl:import href="document.utils.xsl"/>
  <xsl:import href="document.topic.xsl"/>
  <xsl:import href="document.table.xsl"/>
  <xsl:import href="document.link.xsl"/-->  

  <xsl:template match="/">
    <w:comments mc:Ignorable="w14 wp14">
      <xsl:apply-templates select="//*[contains(@class, ' topic/draft-comment ')]"/>
    </w:comments>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/draft-comment ')]">
    <w:comment w:id="{@x:draft-comment-number}">
      <xsl:if test="@author">
        <xsl:attribute name="w:author" select="@author"/>
        <xsl:attribute name="w:initials">
          <xsl:for-each select="tokenize(@author, '\s+')">
            <xsl:value-of select="upper-case(substring(., 1, 1))"/>
          </xsl:for-each>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@time">
        <xsl:attribute name="w:date" select="@time"/>
      </xsl:if>
      <w:p>
        <w:pPr>
          <w:pStyle w:val="CommentText"/>
        </w:pPr>
        <w:r>
          <w:rPr>
            <w:rStyle w:val="CommentReference"/>
          </w:rPr>
          <w:annotationRef/>
        </w:r>
      </w:p>
      <xsl:apply-templates/>      
    </w:comment>
  </xsl:template>

</xsl:stylesheet>
