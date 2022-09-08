<?xml version="1.0" encoding="UTF-8"?>
<!--OXYGEN PATCH FOR EXM-18224-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xhtml="http://www.w3.org/1999/xhtml"  
  exclude-result-prefixes="xhtml" 
  version="2.0">
  
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  
  <!-- The path of the dir where the Table of Contents file is located (relative to the base dir of
    the Eclipse plugin). -->
  <xsl:param name="prefixHelpInstallPath" select="''"/>
  
  <xsl:template match="/">
    <xsl:element name="contexts">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
    
    <xsl:template match="topic[@href]
                        [ends-with(@href, '.html') or ends-with(@href, '.xhtml')]">
    <xsl:apply-templates select="document(@href)" mode="addContext">
      <xsl:with-param name="href" select="@href"/>
    </xsl:apply-templates>
    <xsl:apply-templates/>
  </xsl:template>
    
  <xsl:template match="text()"/>
  <xsl:template match="text()" mode="addContext"/>
    
  <xsl:template match="*[@id]" mode="addContext">
    <xsl:param name="href"/>
    <xsl:element name="context">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      <xsl:variable name="title" select="normalize-space(/xhtml:html/xhtml:head/xhtml:title)"/>
      <xsl:if test="string-length($title) > 0">
          <description><xsl:value-of select="$title"/></description>
          <topic label="{$title}" href="{concat($prefixHelpInstallPath, $href, '#', @id)}"/>
        </xsl:if>
    </xsl:element>
    <xsl:for-each select="descendant::*[@id]">
      <xsl:apply-templates select="." mode="addContext">
        <xsl:with-param name="href" select="@href"/>
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
