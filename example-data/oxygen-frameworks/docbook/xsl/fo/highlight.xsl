<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:d="http://docbook.org/ns/docbook"
		xmlns:fo="http://www.w3.org/1999/XSL/Format"
		xmlns:xslthl="http://xslthl.sf.net"
                exclude-result-prefixes="xslthl d"
                version='1.0'>

<!-- ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://cdn.docbook.org/release/xsl/current/ for
     and other information.

     ******************************************************************** -->

<xsl:import href="../highlighting/common.xsl"/>

<!--<xsl:template match='xslthl:keyword' mode="xslthl">
  <fo:inline font-weight="bold"><xsl:apply-templates mode="xslthl"/></fo:inline>
</xsl:template>

<xsl:template match='xslthl:string' mode="xslthl">
  <fo:inline font-weight="bold" font-style="italic"><xsl:apply-templates mode="xslthl"/></fo:inline>
</xsl:template>

<xsl:template match='xslthl:comment' mode="xslthl">
  <fo:inline font-style="italic"><xsl:apply-templates mode="xslthl"/></fo:inline>
</xsl:template>

<xsl:template match='xslthl:tag' mode="xslthl">
  <fo:inline font-weight="bold"><xsl:apply-templates mode="xslthl"/></fo:inline>
</xsl:template>

<xsl:template match='xslthl:attribute' mode="xslthl">
  <fo:inline font-weight="bold"><xsl:apply-templates mode="xslthl"/></fo:inline>
</xsl:template>

<xsl:template match='xslthl:value' mode="xslthl">
  <fo:inline font-weight="bold"><xsl:apply-templates mode="xslthl"/></fo:inline>
</xsl:template>
-->
<!--
<xsl:template match='xslthl:html'>
  <span style='background:#AFF'><font color='blue'><xsl:apply-templates/></font></span>
</xsl:template>

<xsl:template match='xslthl:xslt'>
  <span style='background:#AAA'><font color='blue'><xsl:apply-templates/></font></span>
</xsl:template>

<xsl:template match='xslthl:section'>
  <span style='background:yellow'><xsl:apply-templates/></span>
</xsl:template>
-->

<!--<xsl:template match='xslthl:number' mode="xslthl">
  <xsl:apply-templates mode="xslthl"/>
</xsl:template>

<xsl:template match='xslthl:annotation' mode="xslthl">
  <fo:inline color="gray"><xsl:apply-templates mode="xslthl"/></fo:inline>
</xsl:template>

<xsl:template match='xslthl:directive' mode="xslthl">
  <xsl:apply-templates mode="xslthl"/>
</xsl:template>

<!-\- Not sure which element will be in final XSLTHL 2.0 -\->
<xsl:template match='xslthl:doccomment|xslthl:doctype' mode="xslthl">
  <fo:inline font-weight="bold"><xsl:apply-templates mode="xslthl"/></fo:inline>
</xsl:template>-->

  <!-- OXYGEN PATCH FOR EXM-39484 Added color syntax highlight-->  
  <xsl:template match='xslthl:keyword' mode="xslthl">
    <fo:inline font-weight="bold" color="#7f0055"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <xsl:template match='xslthl:string' mode="xslthl">
    <fo:inline font-weight="bold" font-style="italic" color="#2a00ff"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <xsl:template match='xslthl:comment' mode="xslthl">
    <fo:inline font-style="italic" color="#006400"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <xsl:template match='xslthl:tag' mode="xslthl">
    <fo:inline font-weight="bold" color="#000096"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  <xsl:template match='xslthl:xslt' mode="xslthl">
    <fo:inline font-weight="bold" color="#0092E6"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  <xsl:template match='xslthl:attribute' mode="xslthl">
    <fo:inline font-weight="bold" color="#ff7935"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <xsl:template match='xslthl:value' mode="xslthl">
    <fo:inline font-weight="bold" color="#993300" ><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <xsl:template match='xslthl:number' mode="xslthl">
    <xsl:apply-templates mode="xslthl"/>
  </xsl:template>
  
  <xsl:template match='xslthl:annotation' mode="xslthl">
    <fo:inline color="gray"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <xsl:template match='xslthl:directive' mode="xslthl">
    <fo:inline color="#8b26c9"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <!-- Not sure which element will be in final XSLTHL 2.0 -->
  <xsl:template match='xslthl:doccomment' mode="xslthl">
    <fo:inline font-weight="bold" color="#3f5fbf"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
  
  <xsl:template match='xslthl:doctype' mode="xslthl">
    <fo:inline font-weight="bold" color="#0000ff"><xsl:apply-templates mode="xslthl"/></fo:inline>
  </xsl:template>
</xsl:stylesheet>

