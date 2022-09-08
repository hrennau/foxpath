<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:jatskit="https://github.com/wendellpiez/JATSKit/ns"
  xmlns:epub="http://www.idpf.org/2007/ops"
  exclude-result-prefixes="xs jatskit"
  version="2.0">

  <xsl:import href="jatskit-ebook-html.xsl"/>
  
  <xsl:template match="/">
    <xsl:apply-templates select="book"/>
  </xsl:template>
  
  <xsl:template match="book">
    <xsl:call-template name="make-html-page">
      <xsl:with-param name="attribute-proxies" as="element()?">
        <html class="apparatus">
          <xsl:call-template name="locate-page">
            <xsl:with-param name="page-label"  as="xs:string">titlepage</xsl:with-param>
            <xsl:with-param name="page-format" as="xs:string">xhtml</xsl:with-param>
          </xsl:call-template>
        </html>        
      </xsl:with-param>      
      <xsl:with-param name="html-contents">
        <div class="titlepage-body">
          <xsl:for-each select="book-meta">
            <xsl:apply-templates select="book-title-group"/>
            <xsl:apply-templates select="contrib-group"/>
            <div class="publication">
              <xsl:apply-templates select="publisher, pub-date, edition"/>
            </div>
          </xsl:for-each>
          <ul class="pagelinks">
            <xsl:call-template name="toc-component-links">
              <xsl:with-param name="pages" as="element()*">
                <jatskit:halftitle/>
                <jatskit:toc/>
                <jatskit:colophon/>
              </xsl:with-param>
            </xsl:call-template>
          </ul>
        </div>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="book-title">
    <h1 class="book-title">
      <xsl:apply-templates/>
    </h1>
  </xsl:template>
  
  <xsl:template match="subtitle">
    <h2 class="book-subtitle">
      <xsl:apply-templates/>
    </h2>
  </xsl:template>
  
  <xsl:template match="alt-title">
    <h3 class="book-alt-title">
      <xsl:apply-templates/>
    </h3>
  </xsl:template>
  
  <xsl:template match="trans-title">
    <h3 class="book-trans-title">
      <xsl:for-each select="@xml:lang">
        <xsl:text>[</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>] </xsl:text>
      </xsl:for-each>
      <xsl:apply-templates/>
    </h3>
  </xsl:template>

  <xsl:template match="contrib">
    <xsl:apply-templates select="(string-name | anonymous | collab | */collab | name | */name )"/>
  </xsl:template>
  
  <xsl:template match="contrib/* | collab | name" priority="100">
    <p class="contrib {local-name()}">
      <xsl:next-match/>
    </p>
  </xsl:template>
  
  
  <xsl:template match="publisher">
    <span class="publisher">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template match="pub-date">
    <xsl:if test="exists(../publisher)">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <span class="pub-date">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template match="pub-date/*">
    <xsl:if test="exists(preceding-sibling::*)">
      <xsl:text> </xsl:text>
    </xsl:if>
    <span class="{local-name(.)}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template match="edition">
    <xsl:if test="exists(../(publisher|pub-date))">
      <xsl:text>. </xsl:text>
    </xsl:if>
    <span class="edition">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  
</xsl:stylesheet>