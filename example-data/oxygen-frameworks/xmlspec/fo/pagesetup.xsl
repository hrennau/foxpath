<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="1.0">

<!-- ==================================================================== -->

<xsl:param name="region.after.extent" select="'0.5in'"/>
<xsl:param name="region.before.extent" select="'0.5in'"/>
<xsl:param name="body.margin.bottom">0.5in</xsl:param>
<xsl:param name="body.margin.top">1in</xsl:param>
<xsl:param name="page.margin.bottom">0.5in</xsl:param>
<xsl:param name="page.margin.inner">
  <xsl:choose>
    <xsl:when test="$double.sided != 0">1.25in</xsl:when>
    <xsl:otherwise>1in</xsl:otherwise>
  </xsl:choose>
</xsl:param>
<xsl:param name="page.margin.outer">
  <xsl:choose>
    <xsl:when test="$double.sided != 0">0.75in</xsl:when>
    <xsl:otherwise>1in</xsl:otherwise>
  </xsl:choose>
</xsl:param>
<xsl:param name="page.margin.top">0in</xsl:param>


<xsl:param name="column.count" select="1"/>
<xsl:param name="alignment" select="'justify'"/>
<xsl:param name="hyphenate">true</xsl:param>
<xsl:param name="body.font.family">Times Roman</xsl:param>
<xsl:param name="body.font.master">10</xsl:param>
<xsl:param name="body.font.size">
 <xsl:value-of select="$body.font.master"/><xsl:text>pt</xsl:text>
</xsl:param>



<xsl:param name="double.sided" select="'0'"/>
<xsl:param name="footnote.font.size">
 <xsl:value-of select="$body.font.master * 0.8"/><xsl:text>pt</xsl:text>
</xsl:param>
<xsl:param name="monospace.font.family">Courier</xsl:param>
<xsl:param name="page.height">
  <xsl:choose>
    <xsl:when test="$page.orientation = 'portrait'">
      <xsl:value-of select="$page.height.portrait"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$page.width.portrait"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:param>
<xsl:param name="page.height.portrait">
  <xsl:choose>
    <xsl:when test="$paper.type = 'A4landscape'">210mm</xsl:when>
    <xsl:when test="$paper.type = 'USletter'">11in</xsl:when>
    <xsl:when test="$paper.type = 'USlandscape'">8.5in</xsl:when>
    <xsl:when test="$paper.type = '4A0'">2378mm</xsl:when>
    <xsl:when test="$paper.type = '2A0'">1682mm</xsl:when>
    <xsl:when test="$paper.type = 'A0'">1189mm</xsl:when>
    <xsl:when test="$paper.type = 'A1'">841mm</xsl:when>
    <xsl:when test="$paper.type = 'A2'">594mm</xsl:when>
    <xsl:when test="$paper.type = 'A3'">420mm</xsl:when>
    <xsl:when test="$paper.type = 'A4'">297mm</xsl:when>
    <xsl:when test="$paper.type = 'A5'">210mm</xsl:when>
    <xsl:when test="$paper.type = 'A6'">148mm</xsl:when>
    <xsl:when test="$paper.type = 'A7'">105mm</xsl:when>
    <xsl:when test="$paper.type = 'A8'">74mm</xsl:when>
    <xsl:when test="$paper.type = 'A9'">52mm</xsl:when>
    <xsl:when test="$paper.type = 'A10'">37mm</xsl:when>
    <xsl:when test="$paper.type = 'B0'">1414mm</xsl:when>
    <xsl:when test="$paper.type = 'B1'">1000mm</xsl:when>
    <xsl:when test="$paper.type = 'B2'">707mm</xsl:when>
    <xsl:when test="$paper.type = 'B3'">500mm</xsl:when>
    <xsl:when test="$paper.type = 'B4'">353mm</xsl:when>
    <xsl:when test="$paper.type = 'B5'">250mm</xsl:when>
    <xsl:when test="$paper.type = 'B6'">176mm</xsl:when>
    <xsl:when test="$paper.type = 'B7'">125mm</xsl:when>
    <xsl:when test="$paper.type = 'B8'">88mm</xsl:when>
    <xsl:when test="$paper.type = 'B9'">62mm</xsl:when>
    <xsl:when test="$paper.type = 'B10'">44mm</xsl:when>
    <xsl:when test="$paper.type = 'C0'">1297mm</xsl:when>
    <xsl:when test="$paper.type = 'C1'">917mm</xsl:when>
    <xsl:when test="$paper.type = 'C2'">648mm</xsl:when>
    <xsl:when test="$paper.type = 'C3'">458mm</xsl:when>
    <xsl:when test="$paper.type = 'C4'">324mm</xsl:when>
    <xsl:when test="$paper.type = 'C5'">229mm</xsl:when>
    <xsl:when test="$paper.type = 'C6'">162mm</xsl:when>
    <xsl:when test="$paper.type = 'C7'">114mm</xsl:when>
    <xsl:when test="$paper.type = 'C8'">81mm</xsl:when>
    <xsl:when test="$paper.type = 'C9'">57mm</xsl:when>
    <xsl:when test="$paper.type = 'C10'">40mm</xsl:when>
    <xsl:otherwise>11in</xsl:otherwise>
  </xsl:choose>
</xsl:param>
<xsl:param name="page.orientation" select="'portrait'"/>
<xsl:param name="page.width">
  <xsl:choose>
    <xsl:when test="$page.orientation = 'portrait'">
      <xsl:value-of select="$page.width.portrait"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$page.height.portrait"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:param>
<xsl:param name="page.width.portrait">
  <xsl:choose>
    <xsl:when test="$paper.type = 'USletter'">8.5in</xsl:when>
    <xsl:when test="$paper.type = '4A0'">1682mm</xsl:when>
    <xsl:when test="$paper.type = '2A0'">1189mm</xsl:when>
    <xsl:when test="$paper.type = 'A0'">841mm</xsl:when>
    <xsl:when test="$paper.type = 'A1'">594mm</xsl:when>
    <xsl:when test="$paper.type = 'A2'">420mm</xsl:when>
    <xsl:when test="$paper.type = 'A3'">297mm</xsl:when>
    <xsl:when test="$paper.type = 'A4'">210mm</xsl:when>
    <xsl:when test="$paper.type = 'A5'">148mm</xsl:when>
    <xsl:when test="$paper.type = 'A6'">105mm</xsl:when>
    <xsl:when test="$paper.type = 'A7'">74mm</xsl:when>
    <xsl:when test="$paper.type = 'A8'">52mm</xsl:when>
    <xsl:when test="$paper.type = 'A9'">37mm</xsl:when>
    <xsl:when test="$paper.type = 'A10'">26mm</xsl:when>
    <xsl:when test="$paper.type = 'B0'">1000mm</xsl:when>
    <xsl:when test="$paper.type = 'B1'">707mm</xsl:when>
    <xsl:when test="$paper.type = 'B2'">500mm</xsl:when>
    <xsl:when test="$paper.type = 'B3'">353mm</xsl:when>
    <xsl:when test="$paper.type = 'B4'">250mm</xsl:when>
    <xsl:when test="$paper.type = 'B5'">176mm</xsl:when>
    <xsl:when test="$paper.type = 'B6'">125mm</xsl:when>
    <xsl:when test="$paper.type = 'B7'">88mm</xsl:when>
    <xsl:when test="$paper.type = 'B8'">62mm</xsl:when>
    <xsl:when test="$paper.type = 'B9'">44mm</xsl:when>
    <xsl:when test="$paper.type = 'B10'">31mm</xsl:when>
    <xsl:when test="$paper.type = 'C0'">917mm</xsl:when>
    <xsl:when test="$paper.type = 'C1'">648mm</xsl:when>
    <xsl:when test="$paper.type = 'C2'">458mm</xsl:when>
    <xsl:when test="$paper.type = 'C3'">324mm</xsl:when>
    <xsl:when test="$paper.type = 'C4'">229mm</xsl:when>
    <xsl:when test="$paper.type = 'C5'">162mm</xsl:when>
    <xsl:when test="$paper.type = 'C6'">114mm</xsl:when>
    <xsl:when test="$paper.type = 'C7'">81mm</xsl:when>
    <xsl:when test="$paper.type = 'C8'">57mm</xsl:when>
    <xsl:when test="$paper.type = 'C9'">40mm</xsl:when>
    <xsl:when test="$paper.type = 'C10'">28mm</xsl:when>
    <xsl:otherwise>8.5in</xsl:otherwise>
  </xsl:choose>
</xsl:param>
<xsl:param name="paper.type" select="'USletter'"/>
<xsl:param name="title.font.family">Helvetica</xsl:param>

<!-- ==================================================================== -->

<xsl:template name="setup.pagemasters">
  <fo:layout-master-set>
    <!-- one sided, single column -->
    <fo:simple-page-master master-name="blank"
                           page-width="{$page.width}"
                           page-height="{$page.height}"
                           margin-top="{$page.margin.top}"
                           margin-bottom="{$page.margin.bottom}"
                           margin-left="{$page.margin.outer}"
                           margin-right="{$page.margin.inner}">
      <fo:region-body
                      margin-bottom="{$body.margin.bottom}"
                      margin-top="{$body.margin.top}"/>
      <fo:region-before region-name="xsl-region-before-blank"
                        extent="{$region.before.extent}"
                        display-align="after"/>
      <fo:region-after region-name="xsl-region-after-blank"
                       extent="{$region.after.extent}"
                        display-align="after"/>
    </fo:simple-page-master>

    <!-- one sided, single column -->
    <fo:simple-page-master master-name="simple1"
                           page-width="{$page.width}"
                           page-height="{$page.height}"
                           margin-top="{$page.margin.top}"
                           margin-bottom="{$page.margin.bottom}"
                           margin-left="{$page.margin.outer}"
                           margin-right="{$page.margin.inner}">
      <fo:region-body
                      margin-bottom="{$body.margin.bottom}"
                      margin-top="{$body.margin.top}"/>
      <fo:region-before extent="{$region.before.extent}"
                        display-align="after"/>
      <fo:region-after extent="{$region.after.extent}"
                        display-align="after"/>
    </fo:simple-page-master>

    <!-- for left-hand/even pages in twosided mode, single column -->
    <fo:simple-page-master master-name="left1"
                           page-width="{$page.width}"
                           page-height="{$page.height}"
                           margin-top="{$page.margin.top}"
                           margin-bottom="{$page.margin.bottom}"
                           margin-left="{$page.margin.outer}"
                           margin-right="{$page.margin.inner}">
      <fo:region-body
                      margin-bottom="{$body.margin.bottom}"
                      margin-top="{$body.margin.top}"/>
      <fo:region-before region-name="xsl-region-before-left"
                        extent="{$region.before.extent}"
                        display-align="after"/>
      <fo:region-after region-name="xsl-region-after-left"
                       extent="{$region.after.extent}"
                        display-align="after"/>
    </fo:simple-page-master>

    <!-- for right-hand/odd pages in twosided mode, single column -->
    <fo:simple-page-master master-name="right1"
                           page-width="{$page.width}"
                           page-height="{$page.height}"
                           margin-top="{$page.margin.top}"
                           margin-bottom="{$page.margin.bottom}"
                           margin-left="{$page.margin.inner}"
                           margin-right="{$page.margin.outer}">
      <fo:region-body
                      margin-bottom="{$body.margin.bottom}"
                      margin-top="{$body.margin.top}"/>
      <fo:region-before region-name="xsl-region-before-right"
                        extent="{$region.before.extent}"
                        display-align="after"/>
      <fo:region-after region-name="xsl-region-after-right"
                       extent="{$region.after.extent}"
                        display-align="after"/>
    </fo:simple-page-master>

    <!-- special case of first page in either mode, single column -->
    <fo:simple-page-master master-name="first1"
                           page-width="{$page.width}"
                           page-height="{$page.height}"
                           margin-top="{$page.margin.top}"
                           margin-bottom="{$page.margin.bottom}"
                           margin-left="{$page.margin.inner}"
                           margin-right="{$page.margin.inner}">
      <fo:region-body
                      margin-bottom="{$body.margin.bottom}"
                      margin-top="{$body.margin.top}"/>
      <fo:region-before region-name="xsl-region-before-first"
                        extent="{$region.before.extent}"
                        display-align="after"/>
      <fo:region-after region-name="xsl-region-after-first"
                       extent="{$region.after.extent}"
                        display-align="after"/>
    </fo:simple-page-master>

    <!-- for pages in one-side mode, 2 column -->
    <fo:simple-page-master master-name="simple2"
                           page-width="{$page.width}"
                           page-height="{$page.height}"
                           margin-top="{$page.margin.top}"
                           margin-bottom="{$page.margin.bottom}"
                           margin-left="{$page.margin.outer}"
                           margin-right="{$page.margin.inner}">
      <fo:region-body
                      column-count="{$column.count}"
                      margin-bottom="{$body.margin.bottom}"
                      margin-top="{$body.margin.top}"/>
      <fo:region-before extent="{$region.before.extent}"
                        display-align="after"/>
      <fo:region-after extent="{$region.after.extent}"
                        display-align="after"/>
    </fo:simple-page-master>

    <!-- for left-hand/even pages in twosided mode, 2 column -->
    <fo:simple-page-master master-name="left2"
                           page-width="{$page.width}"
                           page-height="{$page.height}"
                           margin-top="{$page.margin.top}"
                           margin-bottom="{$page.margin.bottom}"
                           margin-left="{$page.margin.outer}"
                           margin-right="{$page.margin.inner}">
      <fo:region-body
                      column-count="{$column.count}"
                      margin-bottom="{$body.margin.bottom}"
                      margin-top="{$body.margin.top}"/>
      <fo:region-before region-name="xsl-region-before-left"
                        extent="{$region.before.extent}"
                        display-align="after"/>
      <fo:region-after region-name="xsl-region-after-left"
                       extent="{$region.after.extent}"
                        display-align="after"/>
    </fo:simple-page-master>

    <!-- for right-hand/odd pages in twosided mode, 2 column -->
    <fo:simple-page-master master-name="right2"
                           page-width="{$page.width}"
                           page-height="{$page.height}"
                           margin-top="{$page.margin.top}"
                           margin-bottom="{$page.margin.bottom}"
                           margin-left="{$page.margin.inner}"
                           margin-right="{$page.margin.outer}">
      <fo:region-body
                      column-count="{$column.count}"
                      margin-bottom="{$body.margin.bottom}"
                      margin-top="{$body.margin.top}"/>
      <fo:region-before region-name="xsl-region-before-right"
                        extent="{$region.before.extent}"
                        display-align="after"/>
      <fo:region-after region-name="xsl-region-after-right"
                       extent="{$region.after.extent}"
                        display-align="after"/>
    </fo:simple-page-master>

    <!-- special case of first page in either mode -->
    <fo:simple-page-master master-name="first2"
                           page-width="{$page.width}"
                           page-height="{$page.height}"
                           margin-top="{$page.margin.top}"
                           margin-bottom="{$page.margin.bottom}"
                           margin-left="{$page.margin.inner}"
                           margin-right="{$page.margin.inner}">
      <fo:region-body
                      column-count="1"
                      margin-bottom="{$body.margin.bottom}"
                      margin-top="{$body.margin.top}"/>
      <fo:region-before region-name="xsl-region-before-first"
                        extent="{$region.before.extent}"
                        display-align="after"/>
      <fo:region-after region-name="xsl-region-after-first"
                       extent="{$region.after.extent}"
                        display-align="after"/>
    </fo:simple-page-master>

    <!-- setup for title-page, 1 column -->
    <fo:page-sequence-master master-name="titlepage1">
      <fo:repeatable-page-master-alternatives>
        <fo:conditional-page-master-reference>
          <xsl:choose>
            <xsl:when test="$last-call-fop != 0">
              <xsl:attribute name="master-name">first1</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="master-reference">first1</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </fo:conditional-page-master-reference>
      </fo:repeatable-page-master-alternatives>
    </fo:page-sequence-master>

    <!-- setup for single-sided, 1 column -->
    <fo:page-sequence-master master-name="oneside1">
      <fo:repeatable-page-master-alternatives>
        <fo:conditional-page-master-reference>
          <xsl:choose>
            <xsl:when test="$last-call-fop != 0">
              <xsl:attribute name="master-name">simple1</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="master-reference">simple1</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </fo:conditional-page-master-reference>
      </fo:repeatable-page-master-alternatives>
    </fo:page-sequence-master>

    <!-- setup for double-sided, 1 column -->
    <fo:page-sequence-master master-name="twoside1">
      <fo:repeatable-page-master-alternatives>
        <fo:conditional-page-master-reference blank-or-not-blank="blank">
          <xsl:choose>
            <xsl:when test="$last-call-fop != 0">
              <xsl:attribute name="master-name">blank</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="master-reference">blank</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </fo:conditional-page-master-reference>
        <fo:conditional-page-master-reference odd-or-even="odd">
          <xsl:choose>
            <xsl:when test="$last-call-fop != 0">
              <xsl:attribute name="master-name">right1</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="master-reference">right1</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </fo:conditional-page-master-reference>
        <fo:conditional-page-master-reference odd-or-even="even">
          <xsl:choose>
            <xsl:when test="$last-call-fop != 0">
              <xsl:attribute name="master-name">left1</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="master-reference">left1</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </fo:conditional-page-master-reference>
      </fo:repeatable-page-master-alternatives>
    </fo:page-sequence-master>

    <!-- setup for title-page, 2 column -->
    <fo:page-sequence-master master-name="titlepage2">
      <fo:repeatable-page-master-alternatives>
        <fo:conditional-page-master-reference>
          <xsl:choose>
            <xsl:when test="$last-call-fop != 0">
              <xsl:attribute name="master-name">first2</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="master-reference">first2</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </fo:conditional-page-master-reference>
      </fo:repeatable-page-master-alternatives>
    </fo:page-sequence-master>

    <!-- setup for single-sided, 2 column -->
    <fo:page-sequence-master master-name="oneside2">
      <fo:repeatable-page-master-alternatives>
        <fo:conditional-page-master-reference>
          <xsl:choose>
            <xsl:when test="$last-call-fop != 0">
              <xsl:attribute name="master-name">simple2</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="master-reference">simple2</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </fo:conditional-page-master-reference>
      </fo:repeatable-page-master-alternatives>
    </fo:page-sequence-master>

    <!-- setup for double-sided, 2 column -->
    <fo:page-sequence-master master-name="twoside2">
      <fo:repeatable-page-master-alternatives>
        <fo:conditional-page-master-reference blank-or-not-blank="blank">
          <xsl:choose>
            <xsl:when test="$last-call-fop != 0">
              <xsl:attribute name="master-name">blank</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="master-reference">blank</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </fo:conditional-page-master-reference>
        <fo:conditional-page-master-reference odd-or-even="odd">
          <xsl:choose>
            <xsl:when test="$last-call-fop != 0">
              <xsl:attribute name="master-name">right2</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="master-reference">right2</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </fo:conditional-page-master-reference>
        <fo:conditional-page-master-reference odd-or-even="even">
          <xsl:choose>
            <xsl:when test="$last-call-fop != 0">
              <xsl:attribute name="master-name">left2</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="master-reference">left2</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </fo:conditional-page-master-reference>
      </fo:repeatable-page-master-alternatives>
    </fo:page-sequence-master>

    <xsl:call-template name="user.pagemasters"/>

    </fo:layout-master-set>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template name="user.pagemasters"/> <!-- intentionally empty -->

<!-- ==================================================================== -->

<!-- $double.sided, $column.count, and context -->

<xsl:template name="select.pagemaster">
  <xsl:param name="element" select="local-name(.)"/>
  <xsl:choose>
    <xsl:when test="$double.sided != 0">
      <xsl:choose>
        <xsl:when test="$column.count &gt; 1">
          <xsl:call-template name="select.doublesided.multicolumn.pagemaster">
            <xsl:with-param name="element" select="$element"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="select.doublesided.pagemaster">
            <xsl:with-param name="element" select="$element"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="$column.count &gt; 1">
          <xsl:call-template name="select.singlesided.multicolumn.pagemaster">
            <xsl:with-param name="element" select="$element"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="select.singlesided.pagemaster">
            <xsl:with-param name="element" select="$element"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="select.doublesided.multicolumn.pagemaster">
  <xsl:param name="element" select="local-name(.)"/>
  <xsl:choose>
    <xsl:when test="$element='set' or $element='book' or $element='part'">
      <xsl:text>titlepage2</xsl:text>
    </xsl:when>
    <xsl:otherwise>twoside2</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="select.doublesided.pagemaster">
  <xsl:param name="element" select="local-name(.)"/>
  <xsl:choose>
    <xsl:when test="$element='set' or $element='book' or $element='part'">
      <xsl:text>titlepage1</xsl:text>
    </xsl:when>
    <xsl:otherwise>twoside1</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="select.singlesided.multicolumn.pagemaster">
  <xsl:param name="element" select="local-name(.)"/>
  <xsl:choose>
    <xsl:when test="$element='set' or $element='book' or $element='part'">
      <xsl:text>titlepage2</xsl:text>
    </xsl:when>
    <xsl:otherwise>oneside2</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="select.singlesided.pagemaster">
  <xsl:param name="element" select="local-name(.)"/>
  <xsl:choose>
    <xsl:when test="$element='set' or $element='book' or $element='part'">
      <xsl:text>titlepage1</xsl:text>
    </xsl:when>
    <xsl:otherwise>oneside1</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="*" mode="running.head.mode">
  <xsl:param name="master-name" select="'unknown'"/>
  <!-- by default, nothing -->
  <xsl:choose>
    <xsl:when test="$master-name='titlepage1'">
    </xsl:when>
    <xsl:when test="$master-name='oneside1'">
    </xsl:when>
    <xsl:when test="$master-name='twoside1'">
    </xsl:when>
    <xsl:when test="$master-name='titlepage2'">
    </xsl:when>
    <xsl:when test="$master-name='oneside2'">
    </xsl:when>
    <xsl:when test="$master-name='twoside2'">
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="*" mode="running.foot.mode">
  <xsl:param name="master-name" select="'unknown'"/>
  <xsl:variable name="foot">
    <fo:page-number/>
  </xsl:variable>
  <!-- by default, the page number -->
  <xsl:choose>
    <xsl:when test="$master-name='titlepage1'"></xsl:when>
    <xsl:when test="$master-name='oneside1'">
      <fo:static-content flow-name="xsl-region-after">
        <fo:block text-align="center" font-size="{$body.font.size}">
          <xsl:copy-of select="$foot"/>
        </fo:block>
      </fo:static-content>
    </xsl:when>
    <xsl:when test="$master-name='twoside1'">
      <fo:static-content flow-name="xsl-region-after-left">
        <fo:block text-align="left" font-size="{$body.font.size}">
          <xsl:copy-of select="$foot"/>
        </fo:block>
      </fo:static-content>
      <fo:static-content flow-name="xsl-region-after-right">
        <fo:block text-align="right" font-size="{$body.font.size}">
          <xsl:copy-of select="$foot"/>
        </fo:block>
      </fo:static-content>
    </xsl:when>
    <xsl:when test="$master-name='titlepage2'"></xsl:when>
    <xsl:when test="$master-name='oneside2'">
      <fo:static-content flow-name="xsl-after-before">
        <fo:block text-align="center" font-size="{$body.font.size}">
          <xsl:copy-of select="$foot"/>
        </fo:block>
      </fo:static-content>
    </xsl:when>
    <xsl:when test="$master-name='twoside2'">
      <fo:static-content flow-name="xsl-region-after-left">
        <fo:block text-align="left" font-size="{$body.font.size}">
          <xsl:copy-of select="$foot"/>
        </fo:block>
      </fo:static-content>
      <fo:static-content flow-name="xsl-region-after-right">
        <fo:block text-align="right" font-size="{$body.font.size}">
          <xsl:copy-of select="$foot"/>
        </fo:block>
      </fo:static-content>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<!-- ==================================================================== -->

</xsl:stylesheet>
