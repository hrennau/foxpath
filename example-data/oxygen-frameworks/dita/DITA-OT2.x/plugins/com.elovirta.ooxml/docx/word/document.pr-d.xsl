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

  <!-- monospaced -->
  <xsl:template match="*[contains(@class, ' pr-d/codeblock ')]" mode="block-style">
    <w:pStyle w:val="HTMLPreformatted"/>
  </xsl:template>

  <!-- monospaced -->
  <xsl:template match="*[contains(@class, ' pr-d/apiname ')]" mode="inline-style">
    <w:rStyle w:val="HTMLTypewriter"/>
  </xsl:template>
  
  <!-- monospaced -->
  <xsl:template match="*[contains(@class, ' pr-d/codeph ')]" mode="inline-style">
    <w:rStyle w:val="HTMLTypewriter"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' pr-d/var ')]" mode="inline-style">
    <w:i/>
  </xsl:template>

  <!-- Syntax -->
    
  <xsl:template match="*[contains(@class,' pr-d/synblk ')]">
    <xsl:call-template name="p"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class,' pr-d/synnoteref ')]">
    <w:r>
      <w:t>[</w:t>
    </w:r>
    <w:r>
      <w:t>
        <xsl:value-of select="@refid"/>
      </w:t>
    </w:r>
    <w:r>
      <w:t>]</w:t>
    </w:r>
  </xsl:template>
  
  <xsl:template match="*[contains(@class,' pr-d/synnote ')]">
    <w:r>
      <w:t>
       <xsl:choose>
         <xsl:when test="not(@id = '')">       
           <xsl:value-of select="@id"/>
         </xsl:when>
         <xsl:when test="not(@callout = '')">
           <xsl:value-of select="@callout"/>
         </xsl:when>
         <xsl:otherwise>
           <xsl:text>*</xsl:text>
         </xsl:otherwise>
       </xsl:choose>
      </w:t>
    </w:r>
  </xsl:template>
  
  <xsl:template match="*[contains(@class,' pr-d/syntaxdiagram ')]">
    <xsl:apply-templates select="*"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class,' pr-d/fragment ')]">
    <xsl:apply-templates select="*[contains(@class,' topic/title ')]"/>
    <xsl:apply-templates select="node() except *[contains(@class,' topic/title ')]"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class,' pr-d/syntaxdiagram ')]/*[contains(@class,' topic/title ')]">
    <xsl:call-template name="p"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' pr-d/kwd ')]">
    <xsl:if test="parent::*[contains(@class, ' pr-d/groupchoice ')]">
      <xsl:if test="count(preceding-sibling::*)!=0">
        <w:r>
          <w:t>
            <xsl:attribute name="xml:space">preserve</xsl:attribute>
            <xsl:text> | </xsl:text>
          </w:t>
        </w:r>
      </xsl:if>
    </xsl:if>
    <xsl:if test="@importance = 'optional'">
      <w:r>
        <w:t>
          <xsl:attribute name="xml:space">preserve</xsl:attribute>
          <xsl:text> [</xsl:text>
        </w:t>
      </w:r>
     </xsl:if>
    <xsl:choose>
      <xsl:when test="@importance = 'default'">
        <!--fo:inline xsl:use-attribute-sets="kwd__default"-->
          <xsl:apply-templates/>
        <!--/fo:inline-->
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="@importance = 'optional'">
      <w:r>
        <w:t>
          <xsl:attribute name="xml:space">preserve</xsl:attribute>
          <xsl:text>] </xsl:text>
        </w:t>
      </w:r>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' pr-d/kwd ')]" mode="inline-style">
    <w:b w:val="true"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class,' pr-d/fragref ')]">
    <w:r>
      <w:t>&lt;</w:t>
    </w:r>
    <xsl:apply-templates/>
    <w:r>
      <w:t>&gt;</w:t>
    </w:r>
  </xsl:template>
  
  <xsl:template match="*[contains(@class,' pr-d/fragment ')]/*[contains(@class,' topic/title ')]">
    <xsl:call-template name="p"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class,' pr-d/fragment ')]/*[contains(@class,' pr-d/groupcomp ')] |
    *[contains(@class,' pr-d/fragment ')]/*[contains(@class,' pr-d/groupchoice ')] |
    *[contains(@class,' pr-d/fragment ')]/*[contains(@class,' pr-d/groupseq ')]">
    <xsl:apply-templates select="*"/>
  </xsl:template>
  
  <xsl:template match="
    *[contains(@class,' pr-d/syntaxdiagram ')]/*[contains(@class,' pr-d/groupcomp ')] |
    *[contains(@class,' pr-d/syntaxdiagram ')]/*[contains(@class,' pr-d/groupseq ')] |
    *[contains(@class,' pr-d/syntaxdiagram ')]/*[contains(@class,' pr-d/groupchoice ')]">
    <xsl:apply-templates select="*[contains(@class,' topic/title ')]"/>
    <xsl:apply-templates select="* except *[contains(@class,' topic/title ')]"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class,' pr-d/groupcomp ')]/*[contains(@class,' pr-d/groupcomp ')]">
    <xsl:call-template name="makeGroup"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class,' pr-d/groupchoice ')]/*[contains(@class,' pr-d/groupchoice ')]">
    <xsl:call-template name="makeGroup"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class,' pr-d/groupseq ')]/*[contains(@class,' pr-d/groupseq ')]">
    <xsl:call-template name="makeGroup"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class,' pr-d/groupchoice ')]/*[contains(@class,' pr-d/groupcomp ')]">
    <xsl:call-template name="makeGroup"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class,' pr-d/groupchoice ')]/*[contains(@class,' pr-d/groupseq ')]">
    <xsl:call-template name="makeGroup"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class,' pr-d/groupcomp ')]/*[contains(@class,' pr-d/groupchoice ')]">
    <xsl:call-template name="makeGroup"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class,' pr-d/groupcomp ')]/*[contains(@class,' pr-d/groupseq ')]">
    <xsl:call-template name="makeGroup"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class,' pr-d/groupseq ')]/*[contains(@class,' pr-d/groupchoice ')]">
    <xsl:call-template name="makeGroup"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class,' pr-d/groupseq ')]/*[contains(@class,' pr-d/groupcomp ')]">
    <xsl:call-template name="makeGroup"/>
  </xsl:template>
  
  <xsl:template name="makeGroup">
    <xsl:variable name="before" as="xs:string*">
      <xsl:if test="parent::*[contains(@class,' pr-d/groupchoice ')]">
        <xsl:if test="count(preceding-sibling::*)!=0"> | </xsl:if>
      </xsl:if>
      <xsl:if test="@importance = 'optional'">[</xsl:if>
      <xsl:if test="self::groupchoice">{</xsl:if>
    </xsl:variable>
    <xsl:if test="exists($before)">
      <w:r>
        <w:t>
          <xsl:attribute name="xml:space">preserve</xsl:attribute>
          <xsl:copy-of select="$before"/>
          <xsl:text> </xsl:text>
        </w:t>
      </w:r>
    </xsl:if>
    <xsl:apply-templates select="*"/>
    <xsl:variable name="after" as="xs:string*">
      <xsl:if test="self::groupchoice">}</xsl:if>
      <xsl:if test="@importance = 'optional'">]</xsl:if>
    </xsl:variable>
    <xsl:if test="exists($after)">
      <w:r>
        <w:t>
          <xsl:attribute name="xml:space">preserve</xsl:attribute>
          <xsl:text> </xsl:text>
          <xsl:copy-of select="$after"/>
        </w:t>
      </w:r>
    </xsl:if>
  </xsl:template>
  

</xsl:stylesheet>
