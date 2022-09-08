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
               xmlns:x="com.elovirta.ooxml"
               exclude-result-prefixes="x xs"
               version="2.0">

  <xsl:variable name="generate-task-labels" select="false()" as="xs:boolean"/>

  <xsl:template match="*[contains(@class, ' task/prereq ')]">
    <xsl:if test="$generate-task-labels">
      <xsl:call-template name="section.title">
        <xsl:with-param name="contents">
          <w:r>
            <w:t>Prerequisites</w:t>
          </w:r>
        </xsl:with-param>
        <xsl:with-param name="style">
          <xsl:call-template name="block-style-section.title"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' task/postreq ')]">
    <xsl:if test="$generate-task-labels">
      <xsl:call-template name="section.title">
        <xsl:with-param name="contents">
          <w:r>
            <w:t>Post-requisites</w:t>
          </w:r>
        </xsl:with-param>
        <xsl:with-param name="style">
          <xsl:call-template name="block-style-section.title"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' task/steps ')] |
                       *[contains(@class, ' task/steps-unordered ')]">
    <xsl:if test="$generate-task-labels">
      <xsl:call-template name="section.title">
        <xsl:with-param name="contents">
          <w:r>
            <w:t>Procedure</w:t>
          </w:r>
        </xsl:with-param>
        <xsl:with-param name="style">
          <xsl:call-template name="block-style-section.title"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="*"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' task/result ')]">
    <xsl:if test="$generate-task-labels">
      <xsl:call-template name="section.title">
        <xsl:with-param name="contents">
          <w:r>
            <w:t>Result</w:t>
          </w:r>
        </xsl:with-param>
        <xsl:with-param name="style">
          <xsl:call-template name="block-style-section.title"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="*"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' task/steps ')]/*[contains(@class, ' task/step ')]">
    <xsl:apply-templates select="*"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' task/substeps ')]/*[contains(@class, ' task/substep ')]">
    <xsl:apply-templates select="*"/>
  </xsl:template>
  
  <!--xsl:template match="*[contains(@class, ' task/choices ')]">
    <!- - FIXME - ->
  </xsl:template-->

  <xsl:template match="*[contains(@class, ' task/cmd ')]">
    <xsl:call-template name="p"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' task/info ')]">
    <xsl:apply-templates select="*"/>
  </xsl:template>

</xsl:stylesheet>
