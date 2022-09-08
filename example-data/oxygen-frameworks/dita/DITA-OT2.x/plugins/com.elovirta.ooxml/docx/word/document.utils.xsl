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

  <xsl:param name="template.dir" as="xs:string"/>

  <!--xsl:import href="plugin:org.dita.base:xsl/common/dita-utilities.xsl"/>
  <xsl:import href="plugin:org.dita.base:xsl/common/output-message.xsl"/-->
  
  <xsl:variable name="msgprefix" select="'DOTX'"/>

  <!-- Utilities -->
  
  <xsl:variable name="styles" select="document(concat($template.dir, 'word/styles.xml'))" as="document-node()?"/>
  
  <xsl:function name="x:get-style-indent" as="xs:integer?">
    <xsl:param name="style" as="xs:string"/>
    <xsl:variable name="left" select="$styles/w:styles/w:style[@w:styleId = $style]/w:pPr/w:ind/@w:left" as="attribute()?"/>
    <xsl:if test="exists($left)">
      <xsl:sequence select="xs:integer($left)"/>
    </xsl:if>
  </xsl:function>
    
  <xsl:variable name="default-dpi" select="96" as="xs:double"/>
  
  <xsl:function name="x:px-to-emu" as="xs:integer">
    <xsl:param name="px" as="xs:double"/>
    <xsl:param name="dpi" as="xs:double?"/>
    <xsl:variable name="d" select="if (exists($dpi)) then $dpi else $default-dpi" as="xs:double"/>
    <xsl:sequence select="if ($px > 0)
                          then xs:integer(round(($px div $d) * 914400))
                          else xs:integer(0)"/>
  </xsl:function>
  
  <!-- Units are English metric units: 1 EMU = 1 div 914400 in = 1 div 360000 cm -->
  <xsl:function name="x:to-emu" as="xs:integer">
    <xsl:param name="length" as="xs:string"/>
    <xsl:param name="dpi" as="xs:double?"/>
    <xsl:variable name="d" select="if (exists($dpi)) then $dpi else $default-dpi" as="xs:double"/>
    <xsl:variable name="value" select="number(translate($length, 'abcdefghijklmnopqrstuvwxyz', ''))"/>
    <xsl:variable name="unit" select="translate($length, '+-0123456789.', '')"/>
    <xsl:choose>
      <xsl:when test="$unit = 'px' or $unit = ''">
        <xsl:sequence select="xs:integer(round(($value div $d) * 914400))"/>
      </xsl:when>
      <xsl:when test="$unit = 'cm'">
        <xsl:sequence select="xs:integer(round($value * 360000))"/>
      </xsl:when>
      <xsl:when test="$unit = 'mm'">
        <xsl:sequence select="xs:integer(round($value * 36000))"/>
      </xsl:when>
      <xsl:when test="$unit = 'in'">
        <xsl:sequence select="xs:integer(round($value * 914400))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">ERROR: Unsupported unit "<xsl:value-of select="$unit"/>"</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
    
  <!-- Test if element can contain only block content -->
  <xsl:function name="x:block-content" as="xs:boolean">
    <xsl:param name="element" as="node()"/>
    <xsl:variable name="class" select="string($element/@class)"/>
    <xsl:sequence select="contains($class, ' topic/body ') or
                          contains($class, ' topic/abstract ') or
                          contains($class, ' topic/pre ') or
                          contains($class, ' topic/note ') or
                          contains($class, ' topic/fig ') or
                          contains($class, ' topic/li ') or
                          contains($class, ' topic/sli ') or
                          contains($class, ' topic/dt ') or
                          contains($class, ' topic/dd ') or
                          contains($class, ' topic/itemgroup ') or
                          contains($class, ' topic/draft-comment ') or
                          contains($class, ' topic/section ') or
                          contains($class, ' topic/entry ') or
                          contains($class, ' topic/stentry ') or
                          contains($class, ' topic/example ')"/>
    <!--
      contains($class, ' topic/p ') or
      contains($class, ' topic/table ') or
      contains($class, ' topic/simpletable ') or
      contains($class, ' topic/dl ') or
      contains($class, ' topic/sl ') or
      contains($class, ' topic/ol ') or
      contains($class, ' topic/ul ') or
    -->
  </xsl:function>
  
  <!-- Test is element is block -->
  <xsl:function name="x:is-block" as="xs:boolean">
    <xsl:param name="element" as="node()"/>
    <xsl:variable name="class" select="string($element/@class)"/>
    <xsl:sequence select="contains($class, ' topic/body ') or
                          contains($class, ' topic/shortdesc ') or
                          contains($class, ' topic/abstract ') or
                          contains($class, ' topic/title ') or
                          contains($class, ' topic/section ') or 
                          contains($class, ' task/info ') or
                          contains($class, ' topic/p ') or
                          (contains($class, ' topic/image ') and $element/@placement = 'break') or
                          contains($class, ' topic/pre ') or
                          contains($class, ' topic/note ') or
                          contains($class, ' topic/fig ') or
                          contains($class, ' topic/dl ') or
                          contains($class, ' topic/sl ') or
                          contains($class, ' topic/ol ') or
                          contains($class, ' topic/ul ') or
                          contains($class, ' topic/li ') or
                          contains($class, ' topic/sli ') or
                          contains($class, ' topic/itemgroup ') or
                          contains($class, ' topic/section ') or
                          contains($class, ' topic/table ') or
                          contains($class, ' topic/entry ') or
                          contains($class, ' topic/simpletable ') or
                          contains($class, ' topic/stentry ') or
                          contains($class, ' topic/example ')"/>
  </xsl:function>
  
  <!-- bookmark fix-up -->
  
  <xsl:template match="@* | node()" mode="fixup" priority="-1000">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="fixup"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@w:rsidR | @w:rsidRPr | @w:rsidSect"
                mode="fixup" priority="1000"/>
  
  <xsl:template match="w:tc/w:tbl[empty(following-sibling::w:p)]" mode="fixup">
    <xsl:next-match/>
    <!-- generate after table in table because Word requires it -->
    <w:p>
      <w:pPr>
        <w:spacing w:before="0" w:after="0"/>
      </w:pPr>
    </w:p>
  </xsl:template>
  
  <xsl:template match="w:tc[empty(w:p | w:tbl)]" mode="fixup">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="fixup"/>
      <w:p>
        <w:pPr>
          <w:spacing w:before="0" w:after="0"/>
        </w:pPr>
      </w:p>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="w:body/w:bookmarkStart |
    w:body/w:bookmarkEnd"
    mode="fixup" priority="1000"/>
  
  <xsl:template match="w:bookmarkStart |
    w:bookmarkEnd"
    mode="fixup"
    name="output-bookmark">
    <xsl:param name="bookmarks" as="xs:string*" tunnel="yes"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:if test="string(@w:id) = $bookmarks">
        <xsl:attribute name="w:id" select="index-of($bookmarks, string(@w:id))"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="w:p" mode="fixup" priority="1000">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="fixup"/>
      <xsl:apply-templates select="w:pPr" mode="fixup"/>
      <xsl:apply-templates select="preceding-sibling::*[1]" mode="fixup.before"/>
      <xsl:apply-templates select="* except w:pPr" mode="fixup"/>
      <xsl:apply-templates select="following-sibling::*[1]" mode="fixup.after"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="w:bookmarkStart" mode="fixup.before" priority="10">
    <xsl:call-template name="output-bookmark"/>
    <xsl:apply-templates select="preceding-sibling::*[1]" mode="fixup.before"/>
  </xsl:template>
  <xsl:template match="*" mode="fixup.before"/>
  
  <xsl:template match="w:bookmarkEnd" mode="fixup.after" priority="10">
    <xsl:call-template name="output-bookmark"/>
    <xsl:apply-templates select="following-sibling::*[1]" mode="fixup.after"/>
  </xsl:template>
  <xsl:template match="*" mode="fixup.after"/>
  
  <!-- Whitespace fix-up -->
  
  <xsl:template match="@* | node()" mode="whitespace" priority="-1000">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="whitespace"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Collapse whitespace to a single space character -->
  <xsl:template match="w:t" mode="whitespace">
    <xsl:param name="t" select="string(.)" as="xs:string"/>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="whitespace"/>
      <xsl:variable name="only-whitespace" select="matches($t, '^\s+$')" as="xs:boolean"/>
      <xsl:choose>
        <xsl:when test="$only-whitespace and exists(parent::w:r) and empty(parent::w:r/preceding-sibling::w:r)"/>
        <xsl:when test="$only-whitespace">
          <xsl:attribute name="xml:space">preserve</xsl:attribute>
          <xsl:text> </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="starts" select="matches($t, '^\s')" as="xs:boolean"/>
          <xsl:variable name="ends" select="matches($t, '\s$')" as="xs:boolean"/>
          <xsl:if test="$starts or $ends">
            <xsl:attribute name="xml:space">preserve</xsl:attribute>
          </xsl:if>
          <xsl:if test="$starts">
            <xsl:text> </xsl:text>
          </xsl:if>
          <xsl:value-of select="normalize-space($t)"/>
          <xsl:if test="$ends">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="w:t[@xml:space = 'preserve']" mode="whitespace" priority="10">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="whitespace"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
