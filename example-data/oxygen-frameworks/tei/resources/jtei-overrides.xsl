<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:e="http://www.oxygenxml.com/xsl/conversion-elements"
                xmlns:f="http://www.oxygenxml.com/xsl/functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:local="local"
                exclude-result-prefixes="#all">
    
  <!-- [jTEI] determine if an element is in monospace -->
  <xsl:variable name="monospace.regex">(monospace|courier)</xsl:variable>
  <xsl:function name="local:is.monospace" as="xs:boolean">
    <xsl:param name="node"/>
    <xsl:value-of select="$node/self::*:font[matches(@face, $monospace.regex, 'i')] or $node/self::*:span[matches(@style, $monospace.regex, 'i')]"/>
  </xsl:function>
  
  <!-- [jTEI] preserve monospace font (ODT) for further processing -->
  <xsl:template match="xhtml:font[local:is.monospace(.)]" mode="filterNodes">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="filterNodes"/>
    </xsl:copy>
  </xsl:template>

  <!-- [jTEI] preserve monospace span (DOCX) for further processing -->  
  <xsl:template match="xhtml:span[local:is.monospace(.)]" mode="removeSpans">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="removeSpans"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="xhtml:span[ancestor::xhtml:p | ancestor::xhtml:div][local:is.monospace(.)]" mode="setNamespace">
    <xsl:element name="{local-name()}" namespace="http://www.oxygenxml.com/xsl/conversion-elements">
      <xsl:if test="namespace-uri-for-prefix('o', .) = 'urn:schemas-microsoft-com:office:office'">
        <xsl:namespace name="o" select="'urn:schemas-microsoft-com:office:office'"/>
      </xsl:if>
      <xsl:apply-templates select="node() | @*" mode="setNamespace"/>
    </xsl:element>
  </xsl:template>
  
  <!-- [jTEI] preserve monospace snippets -->
  <xsl:template match="e:font[local:is.monospace(.)]|e:span[local:is.monospace(.)]">
    <xsl:choose>
      <xsl:when test="starts-with(., '@')">
        <att xmlns="http://www.tei-c.org/ns/1.0">
          <xsl:apply-templates/>
        </att>
      </xsl:when>
      <xsl:when test="matches(., '^&lt;[^/>\s]+&gt;$')">
        <gi xmlns="http://www.tei-c.org/ns/1.0">
          <xsl:apply-templates/>
        </gi>
      </xsl:when>
      <xsl:when test="matches(., '^&lt;[^>]+&gt;$')">
        <tag xmlns="http://www.tei-c.org/ns/1.0">
          <xsl:apply-templates/>
        </tag>
      </xsl:when>
      <xsl:otherwise>
        <ident xmlns="http://www.tei-c.org/ns/1.0">
          <xsl:apply-templates/>
        </ident>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- [jTEI] skip all other fonts -->
  <xsl:template match="e:font">
    <xsl:apply-templates/>
  </xsl:template>
  
  <!-- this is not applied, probably due to smart paste settings in the AuthorExternalObjectInsertionHandler class (presumably the textual content must be preserved literally) -->
  <xsl:template match="e:font[local:is.monospace(.)]/text()" priority="1">
    <xsl:value-of select="replace(., '^(@|&lt;)|&gt;$', '')"/>
  </xsl:template>
  
</xsl:stylesheet>