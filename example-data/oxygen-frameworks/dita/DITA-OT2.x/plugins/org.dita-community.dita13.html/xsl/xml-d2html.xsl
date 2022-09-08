<?xml version="1.0" encoding="UTF-8" ?>
<!-- ===========================================================
     HTML generation templates for the xmlDomain DITA domain.
     
     Copyright (c) 2015 DITA Community
     
     =========================================================== -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="*[contains(@class, ' xml-d/xmlelement ')]" priority="10">
    <code class="xmlelement">
      <xsl:text>&lt;</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>&gt;</xsl:text>
    </code>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' xml-d/xmlatt ')]" priority="10">
    <code class="xmlatt">
      <xsl:text>@</xsl:text>
      <xsl:apply-templates/>
    </code>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' xml-d/textentity ')]" priority="10">
    <code class="textentity">
      <xsl:text>&amp;</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>;</xsl:text>
    </code>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' xml-d/parameterentity ')]" priority="10">
    <code class="parameterentity">
      <xsl:text>%</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>;</xsl:text>
    </code>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' xml-d/numcharref ')]" priority="10">
    <code class="numcharref">
      <xsl:text>&amp;#</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>;</xsl:text>
    </code>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' xml-d/xmlpi ')]" priority="10">
    <code class="xmlpi">
      <xsl:apply-templates/>
    </code>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' markup-d/markupname ')]" priority="9">
    <code class="xsdsimpletype">
      <xsl:apply-templates/>
    </code>
  </xsl:template>
</xsl:stylesheet>
