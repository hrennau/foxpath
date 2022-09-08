<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:opentopic="http://www.idiominc.com/opentopic"
                xmlns:x="com.elovirta.ooxml"
                exclude-result-prefixes="x xs opentopic"
                version="2.0">
  
  <xsl:import href="document.utils.xsl"/>
  <xsl:import href="flatten.xsl"/>
  
  <xsl:variable name="content" as="document-node()">
    <xsl:document>
      <xsl:apply-templates select="node()" mode="flatten"/>
    </xsl:document>
  </xsl:variable>
  <xsl:variable name="lists" as="xs:string*">
    <xsl:for-each select="$content//*[contains(@class, ' topic/ol ') or contains(@class, ' topic/ul ') or contains(@class, ' topic/sl ')]">
      <xsl:value-of select="generate-id(.)"/>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="image-lists" as="xs:string*">
    <xsl:for-each select="$content//*[contains(@class, ' topic/image ')]">
      <xsl:value-of select="generate-id(.)"/>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="fn-lists" as="xs:string*">
    <xsl:for-each select="$content//*[contains(@class, ' topic/fn ')]">
      <xsl:value-of select="generate-id(.)"/>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="draft-comment-lists" as="xs:string*">
    <xsl:for-each select="$content//*[contains(@class, ' topic/draft-comment ')]">
      <xsl:value-of select="generate-id(.)"/>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="external-link-lists" as="xs:string*">
    <xsl:for-each select="$content//*[contains(@class, ' topic/xref ') or contains(@class, ' topic/link ')][@scope = 'external']">
      <xsl:value-of select="generate-id(.)"/>
    </xsl:for-each>
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:apply-templates select="$content" mode="number">
      <xsl:with-param name="lists" select="$lists" tunnel="yes"/>
      <xsl:with-param name="image-lists" select="$image-lists" tunnel="yes"/>
      <xsl:with-param name="fn-lists" select="$fn-lists" tunnel="yes"/>
      <xsl:with-param name="draft-comment-lists" select="$draft-comment-lists" tunnel="yes"/>
      <xsl:with-param name="external-link-lists" select="$external-link-lists" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="@xtrc | @xtrf | *[contains(@class, '- topic/required-cleanup ')]" mode="number" priority="1000"/>
  
  <!-- number -->
  
  <xsl:template match="*[contains(@class, ' topic/image ')]" mode="number">
    <xsl:param name="image-lists" as="xs:string*" tunnel="yes"/>
    <xsl:copy>
      <xsl:attribute name="x:image-number" select="index-of($image-lists, generate-id(.)) + 100"/>
      <xsl:apply-templates select="@* | node()" mode="number"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/fn ')]" mode="number">
    <xsl:param name="fn-lists" as="xs:string*" tunnel="yes"/>
    <xsl:copy>
      <xsl:attribute name="x:fn-number" select="index-of($fn-lists, generate-id(.)) + 100"/>
      <xsl:apply-templates select="@* | node()" mode="number"/>
    </xsl:copy>
  </xsl:template>  

  <xsl:template match="*[contains(@class, ' topic/ol ') or contains(@class, ' topic/ul ')  or contains(@class, ' topic/sl ')]" mode="number">
    <xsl:param name="lists" as="xs:string*" tunnel="yes"/>
    <xsl:copy>
      <xsl:attribute name="x:list-number" select="index-of($lists, generate-id(.)) + 100"/>
      <xsl:apply-templates select="@* | node()" mode="number"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/draft-comment ')]" mode="number">
    <xsl:param name="draft-comment-lists" as="xs:string*" tunnel="yes"/>
    <xsl:copy>
      <xsl:attribute name="x:draft-comment-number" select="index-of($draft-comment-lists, generate-id(.)) + 100"/>
      <xsl:apply-templates select="@* | node()" mode="number"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/xref ') or contains(@class, ' topic/link ')][@scope = 'external']" mode="number">
    <xsl:param name="external-link-lists" as="xs:string*" tunnel="yes"/>
    <xsl:copy>
      <xsl:attribute name="x:external-link-number" select="index-of($external-link-lists, generate-id(.)) + 100"/>
      <xsl:apply-templates select="@* | node()" mode="number"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@* | node()" mode="number" priority="-1000">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="number"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:key name="map-id" match="opentopic:map//*[@id]" use="@id"/>
  
  <xsl:template match="*[contains(@class, ' topic/topic ')]"
                mode="number">
    <xsl:copy>
      <xsl:for-each select="key('map-id', @id)[1]">
        <xsl:if test="empty(ancestor-or-self::*[self::*[contains(@class, ' bookmap/frontmatter ') or
                                                          contains(@class, ' bookmap/backmatter ')] or
                                                  @props = 'nonumbering'])">
          <xsl:attribute name="x:header-number">
            <xsl:variable name="appendix" select="ancestor-or-self::*[contains(@class, ' bookmap/appendix ')][1]" as="element()?"/>
            <xsl:choose>
              <xsl:when test="$appendix">
                <xsl:for-each select="$appendix">
                  <xsl:number count="*[contains(@class, ' bookmap/appendix ')]"
                              level="single" format="A."/>
                </xsl:for-each>
                <xsl:number count="*[contains(@class, ' map/topicref ')]
                                    [not(contains(@class, ' bookmap/frontmatter ') or
                                         contains(@class, ' bookmap/appendices ') or
                                         contains(@class, ' bookmap/appendix ') or
                                         @props = 'nonumbering')]"
                            level="multiple" format="1.1"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:number count="*[contains(@class, ' map/topicref ')]
                                    [not(contains(@class, ' bookmap/frontmatter ') or
                                         @props = 'nonumbering')]"
                            level="multiple" format="1.1"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:if>
      </xsl:for-each>
      <xsl:apply-templates select="@* | node()" mode="number"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>