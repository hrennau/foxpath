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
  xmlns:a14="http://schemas.microsoft.com/office/drawing/2010/main" xmlns:x="com.elovirta.ooxml"
  xmlns:java="org.dita.dost.util.ImgUtils"
  exclude-result-prefixes="x java xs opentopic opentopic-index ot-placeholder" version="2.0">

  <xsl:template match="*[contains(@class, ' topic/related-links ')]">
    <xsl:variable name="all-links" as="element()*"
      select="
        *[contains(@class, ' topic/link ')] |
        *[contains(@class, ' topic/linkpool ')]/*[contains(@class, ' topic/link ')]"/>
    <xsl:variable name="links" as="element()*"
      select="$all-links[not(@role = ('parent', 'child')) or empty(@role)]"/>
    <xsl:if test="exists($links)">
      <w:p>
        <w:pPr>
          <w:pStyle w:val="Subtitle"/>
        </w:pPr>
        <w:r>
          <w:t>
            <xsl:call-template name="getVariable">
              <xsl:with-param name="id" select="'Related information'"/>
            </xsl:call-template>
          </w:t>
        </w:r>
      </w:p>
      <xsl:apply-templates select="$links"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/link ')]">
    <xsl:variable name="target" select="x:get-target(.)" as="element()?"/>
    <xsl:if test="exists($target)">
      <w:p>
        <w:pPr>
          <xsl:apply-templates select="." mode="block-style"/>
        </w:pPr>
        <w:r>
          <w:fldChar w:fldCharType="begin"/>
        </w:r>
        <w:r>
          <w:instrText>
            <xsl:attribute name="xml:space">preserve</xsl:attribute>
            <xsl:text> REF </xsl:text>
            <xsl:value-of select="concat($bookmark-prefix.ref, generate-id($target))"/>
            <xsl:text> </xsl:text>
            <xsl:text>\h </xsl:text>
          </w:instrText>
        </w:r>
        <w:r>
          <w:fldChar w:fldCharType="separate"/>
        </w:r>
        <xsl:apply-templates select="*[contains(@class, ' topic/linktext ')]/node()"/>
        <w:r>
          <w:fldChar w:fldCharType="end"/>
        </w:r>
      </w:p>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/link ')][@scope = 'external']" priority="10">
    <xsl:param name="contents" as="node()*">
      <xsl:apply-templates/>
    </xsl:param>

    <w:p>
      <w:pPr>
        <xsl:apply-templates select="." mode="block-style"/>
      </w:pPr>
      <w:hyperlink r:id="rIdHyperlink{@x:external-link-number}">
        <xsl:choose>
          <xsl:when test="exists($contents)">
            <xsl:copy-of select="$contents"/>
          </xsl:when>
          <xsl:otherwise>
            <w:r>
              <w:rPr>
                <xsl:apply-templates select="." mode="inline-style"/>
              </w:rPr>
              <w:t>
                <xsl:value-of select="@href"/>
              </w:t>
            </w:r>
          </xsl:otherwise>
        </xsl:choose>
      </w:hyperlink>
    </w:p>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/link ')]" mode="block-style">
    <xsl:if test="empty(following-sibling::*[contains(@class, ' topic/link ')])">
      <w:spacing w:after="0"/>
    </xsl:if>
    <w:tabs>
      <w:tab w:val="left" w:pos="373"/>
      <w:tab w:val="right" w:leader="dot" w:pos="{$body-width}"/>
    </w:tabs>
  </xsl:template>

  <xsl:function name="x:get-target" as="element()?">
    <xsl:param name="link" as="element()?"/>
    <xsl:variable name="scope"
      select="
        if ($link/@scope) then
          $link/@scope
        else
          'local'"
      as="xs:string"/>
    <xsl:variable name="format"
      select="
        if ($link/@format) then
          $link/@format
        else
          'dita'"
      as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$scope != 'local' or $format != 'dita'"/>
      <xsl:otherwise>
        <xsl:variable name="h" select="substring-after($link/@href, '#')"/>
        <xsl:variable name="topic"
          select="
            if (contains($h, '/')) then
              substring-before($h, '/')
            else
              $h"
          as="xs:string"/>
        <xsl:variable name="element"
          select="
            if (contains($h, '/')) then
              substring-after($h, '/')
            else
              ()"
          as="xs:string?"/>
        <xsl:choose>
          <xsl:when test="empty($element)">
            <xsl:sequence
              select="key('id', $topic, $root)[not(contains(@class, ' map/topicref '))][1]"/>
          </xsl:when>
          <xsl:when
            test="count(key('id', $element, $root)[not(contains(@class, ' map/topicref '))]) eq 1">
            <xsl:sequence
              select="key('id', $element, $root)[not(contains(@class, ' map/topicref '))]"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence
              select="(key('id', $topic, $root)[not(contains(@class, ' map/topicref '))]/descendant::*[@id and @id = $element])[1]"
            />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template match="*[contains(@class, ' topic/xref ')]" name="topic.xref">
    <xsl:param name="contents" as="node()*">
      <xsl:apply-templates/>
    </xsl:param>
    <xsl:variable name="target" as="element()?" select="x:get-target(.)"/>

    <!-- Attempt to determine whether the reference is at the beginning of a sentence. -->
    <xsl:variable name="context"
      select="normalize-space(string-join(preceding-sibling::text(), ' '))" as="xs:string"/>
    <!-- pick the containing element, disregarding p -->
    <xsl:variable name="container" select="ancestor::*[not(contains(@class, ' topic/p '))][1]"
      as="element()?"/>
    <xsl:variable name="capitalize" as="xs:boolean">
      <xsl:choose>
        <!-- capitalize when at the start of a sentence -->
        <xsl:when
          test="ends-with(translate($context, '!?', '.'), '.') or string-length($context) eq 0">
          <xsl:sequence select="true()"/>
        </xsl:when>
        <!-- capitalize when this is the first element in an enumeration, note, or table -->
        <xsl:when
          test="
            $container[contains(@class, ' topic/note ') or
            contains(@class, ' topic/li ') or
            contains(@class, ' topic/entry ')] and empty(preceding-sibling::node())">
          <xsl:sequence select="true()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="false()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="empty($target)">
        <xsl:copy-of select="$contents"/>
      </xsl:when>
      <xsl:when
        test="contains($target/@class, ' topic/topic ') and not(contains($target/@class, ' glossentry/glossentry '))">
        <xsl:apply-templates select="$target" mode="xref-prefix">
          <xsl:with-param name="capitalize" select="$capitalize"/>
        </xsl:apply-templates>
        <w:r>
          <w:fldChar w:fldCharType="begin"/>
        </w:r>
        <w:r>
          <w:instrText>
            <xsl:attribute name="xml:space">preserve</xsl:attribute>
            <xsl:text> </xsl:text>
            <xsl:choose>
              <xsl:when test="false()">PAGEREF </xsl:when>
              <xsl:otherwise>REF </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="concat($bookmark-prefix.num, generate-id($target))"/>
            <xsl:text> \h </xsl:text>
          </w:instrText>
        </w:r>
        <w:r>
          <w:fldChar w:fldCharType="separate"/>
        </w:r>
        <xsl:copy-of select="$contents"/>
        <w:r>
          <w:fldChar w:fldCharType="end"/>
        </w:r>
      </xsl:when>
      <xsl:when test="@type = 'fn'">
        <!--xsl:apply-templates select="$target"/-->
        <w:r>
          <w:rPr>
            <w:rStyle w:val="FootnoteReference"/>
          </w:rPr>
          <w:fldChar w:fldCharType="begin"/>
        </w:r>
        <w:r>
          <w:rPr>
            <w:rStyle w:val="FootnoteReference"/>
          </w:rPr>
          <w:instrText xml:space="preserve">
            <xsl:text> NOTEREF </xsl:text>
            <xsl:value-of select="concat($bookmark-prefix.note, generate-id($target))"/>
            <xsl:text> \h </xsl:text>
          </w:instrText>
        </w:r>
        <w:r>
          <w:rPr>
            <w:rStyle w:val="FootnoteReference"/>
          </w:rPr>
        </w:r>
        <w:r>
          <w:rPr>
            <w:rStyle w:val="FootnoteReference"/>
          </w:rPr>
          <w:fldChar w:fldCharType="separate"/>
        </w:r>
        <w:r>
          <w:rPr>
            <w:rStyle w:val="FootnoteReference"/>
          </w:rPr>
          <w:t>0</w:t>
        </w:r>
        <w:r>
          <w:rPr>
            <w:rStyle w:val="FootnoteReference"/>
          </w:rPr>
          <w:fldChar w:fldCharType="end"/>
        </w:r>
      </xsl:when>
      <xsl:when test="@type = 'fig'">
        <xsl:apply-templates select="$target" mode="xref-prefix">
          <xsl:with-param name="capitalize" select="$capitalize"/>
        </xsl:apply-templates>
        <w:r>
          <w:fldChar w:fldCharType="begin"/>
        </w:r>
        <w:r>
          <w:instrText>
            <xsl:attribute name="xml:space">preserve</xsl:attribute>
            <xsl:text> REF </xsl:text>
            <xsl:value-of select="concat($bookmark-prefix.num, generate-id($target))"/>
            <xsl:text> \h </xsl:text>
          </w:instrText>
        </w:r>
        <w:r>
          <w:fldChar w:fldCharType="separate"/>
        </w:r>
        <xsl:choose>
          <xsl:when test="$target/*[contains(@class, ' topic/title ')]">
            <w:r>
              <w:t>
                <xsl:call-template name="getVariable">
                  <xsl:with-param name="id" select="'Figure'"/>
                </xsl:call-template>
              </w:t>
            </w:r>
            <w:r>
              <w:t>
                <xsl:attribute name="xml:space">preserve</xsl:attribute>
                <xsl:call-template name="getVariable">
                  <xsl:with-param name="id" select="'figure-number-separator'"/>
                </xsl:call-template>
              </w:t>
            </w:r>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$contents"/>
          </xsl:otherwise>
        </xsl:choose>
        <w:r>
          <w:fldChar w:fldCharType="end"/>
        </w:r>
      </xsl:when>
      <xsl:when test="@type = 'table'">
        <xsl:apply-templates select="$target" mode="xref-prefix">
          <xsl:with-param name="capitalize" select="$capitalize"/>
        </xsl:apply-templates>
        <w:r>
          <w:fldChar w:fldCharType="begin"/>
        </w:r>
        <w:r>
          <w:instrText>
            <xsl:attribute name="xml:space">preserve</xsl:attribute>
            <xsl:text> REF </xsl:text>
            <xsl:value-of select="concat($bookmark-prefix.num, generate-id($target))"/>
            <xsl:text> \h </xsl:text>
          </w:instrText>
        </w:r>
        <w:r>
          <w:fldChar w:fldCharType="separate"/>
        </w:r>
        <xsl:choose>
          <xsl:when test="$target/*[contains(@class, ' topic/title ')]">
            <w:r>
              <w:t>
                <xsl:call-template name="getVariable">
                  <xsl:with-param name="id" select="'Table'"/>
                </xsl:call-template>
              </w:t>
            </w:r>
            <w:r>
              <w:t>
                <xsl:attribute name="xml:space">preserve</xsl:attribute>
                <xsl:call-template name="getVariable">
                  <xsl:with-param name="id" select="'figure-number-separator'"/>
                </xsl:call-template>
              </w:t>
            </w:r>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$contents"/>
          </xsl:otherwise>
        </xsl:choose>
        <w:r>
          <w:fldChar w:fldCharType="end"/>
        </w:r>
      </xsl:when>
      <xsl:when test="@type = 'callout'">
        <w:r>
          <w:t>(</w:t>
        </w:r>
        <w:r>
          <w:fldChar w:fldCharType="begin"/>
        </w:r>
        <w:r>
          <w:instrText>
            <xsl:attribute name="xml:space">preserve</xsl:attribute>
            <xsl:text> REF </xsl:text>
            <xsl:value-of select="concat($bookmark-prefix.ref, generate-id($target))"/>
            <xsl:text> \n \h </xsl:text>
          </w:instrText>
        </w:r>
        <w:r>
          <w:fldChar w:fldCharType="separate"/>
        </w:r>
        <xsl:copy-of select="$contents"/>
        <w:r>
          <w:fldChar w:fldCharType="end"/>
        </w:r>
        <w:r>
          <w:t>)</w:t>
        </w:r>
      </xsl:when>
      <xsl:otherwise>
        <w:r>
          <w:fldChar w:fldCharType="begin"/>
        </w:r>
        <w:r>
          <w:instrText>
            <xsl:attribute name="xml:space">preserve</xsl:attribute>
            <xsl:text> </xsl:text>
            <xsl:choose>
              <xsl:when test="false()">PAGEREF </xsl:when>
              <xsl:otherwise>REF </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="concat($bookmark-prefix.ref, generate-id($target))"/>
            <xsl:text> \h </xsl:text>
          </w:instrText>
        </w:r>
        <w:r>
          <w:fldChar w:fldCharType="separate"/>
        </w:r>
        <xsl:copy-of select="$contents"/>
        <w:r>
          <w:fldChar w:fldCharType="end"/>
        </w:r>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/xref ')][@scope = 'external']" priority="10">
    <xsl:param name="contents" as="node()*">
      <xsl:apply-templates/>
    </xsl:param>

    <w:hyperlink r:id="rIdHyperlink{@x:external-link-number}">
      <xsl:choose>
        <xsl:when test="exists($contents)">
          <xsl:copy-of select="$contents"/>
        </xsl:when>
        <xsl:otherwise>
          <w:r>
            <w:rPr>
              <xsl:apply-templates select="." mode="inline-style"/>
            </w:rPr>
            <w:t>
              <xsl:value-of select="@href"/>
            </w:t>
          </w:r>
        </xsl:otherwise>
      </xsl:choose>
    </w:hyperlink>
  </xsl:template>

  <xsl:template match="node()" mode="xref-prefix"/>

  <xsl:template match="*[contains(@class, ' topic/table ')]" mode="xref-prefix">
    <xsl:param name="capitalize" select="true()" as="xs:boolean"/>
    <w:r>
      <!-- FIXME: Maybe this should be done with a text-transform -->
      <xsl:choose>
        <xsl:when test="$capitalize">
          <w:t>Table&#xA0;</w:t>
        </xsl:when>
        <xsl:otherwise>
          <w:t>table&#xA0;</w:t>
        </xsl:otherwise>
      </xsl:choose>
    </w:r>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/fig ')]" mode="xref-prefix">
    <xsl:param name="capitalize" select="true()" as="xs:boolean"/>
    <w:r>
      <xsl:choose>
        <xsl:when test="$capitalize">
          <w:t>Figure&#xA0;</w:t>
        </xsl:when>
        <xsl:otherwise>
          <w:t>figure&#xA0;</w:t>
        </xsl:otherwise>
      </xsl:choose>
    </w:r>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/xref ')]" mode="inline-style">
    <w:u w:val="single"/>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/xref ')][@scope = 'external']" mode="inline-style"
    priority="10">
    <!--w:color w:val="0000FF" w:themeColor="hyperlink"/>
    <w:u w:val="single"/-->
    <w:rStyle w:val="Hyperlink"/>
  </xsl:template>

</xsl:stylesheet>
