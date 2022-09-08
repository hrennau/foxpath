<?xml version="1.0"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:fo="http://www.w3.org/1999/XSL/Format"
               version="1.0">

<!-- ====================================================================== -->
<!-- xmlspec.xsl: An XSL[1,2] Stylesheet for XML Spec V2.1[3] markup

     Version: $Id$

     URI:     http://dev.w3.org/cvsweb/spec-prod/fo/xmlspec.xsl

     Authors: Norman Walsh (norman.walsh@sun.com)

     Date:    Created 08 November 2000
              Last updated $Date$ by $Author$

     Copyright (C) 2000, 2001, 2002 Sun Microsystems, Inc. All Rights Reserved.
     This document is governed by the W3C Software License[3] as
     described in the FAQ[4].

       [1] http://www.w3.org/TR/xsl
       [2] http://www.w3.org/TR/xslt
       [3] http://www.w3.org/XML/1998/06/xmlspec-report-v21.htm
       [4] http://www.w3.org/Consortium/Legal/copyright-software-19980720
       [5] http://www.w3.org/Consortium/Legal/IPR-FAQ-20000620.html#DTD

     Notes:

     This stylesheet attempts to implement the XML Specification V2.1
     DTD.  Documents conforming to earlier DTDs may not be correctly
     transformed.

  -->
<!-- ====================================================================== -->

<xsl:include href="pagesetup.xsl"/>

<xsl:param name="last-call-fop" select="0"/>
<xsl:param name="fop" select="$last-call-fop"/>
<xsl:param name="fop-table-width-in-inches" select="6.25"/>

<xsl:key name="ids" match="*[@id]" use="@id"/>
<xsl:key name="specrefs" match="specref" use="@ref"/>

<xsl:output method="xml" indent="no"/>

<!-- ================================================================= -->

<xsl:template name="object.id">
  <xsl:param name="node" select="."/>
  <xsl:choose>
    <xsl:when test="$node/@id">
      <xsl:value-of select="$node/@id"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="generate-id($node)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="anchor">
  <xsl:param name="node" select="."/>
  <xsl:param name="conditional" select="1"/>
  <xsl:variable name="id">
    <xsl:call-template name="object.id">
      <xsl:with-param name="node" select="$node"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:if test="$conditional = 0 or $node/@id">
    <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
  </xsl:if>
</xsl:template>

  <!-- ================================================================= -->

  <xsl:attribute-set name="div1.style">
    <xsl:attribute name="space-before">1em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="h1.style">
    <xsl:attribute name="font-family">Helvetica</xsl:attribute>
    <xsl:attribute name="font-size">18pt</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="space-after">0.5em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="div2.style">
    <xsl:attribute name="space-before">1em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="h2.style">
    <xsl:attribute name="font-family">Helvetica</xsl:attribute>
    <xsl:attribute name="font-size">16pt</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="space-after">0.5em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="div3.style">
    <xsl:attribute name="space-before">1em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="h3.style">
    <xsl:attribute name="font-family">Helvetica</xsl:attribute>
    <xsl:attribute name="font-size">14pt</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="space-after">0.5em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="div4.style">
    <xsl:attribute name="space-before">1em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="h4.style">
    <xsl:attribute name="font-family">Helvetica</xsl:attribute>
    <xsl:attribute name="font-size">12pt</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="space-after">0.5em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="div5.style">
    <xsl:attribute name="space-before">1em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="h5.style">
    <xsl:attribute name="font-family">Helvetica</xsl:attribute>
    <xsl:attribute name="font-size">10pt</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="space-after">0.5em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="div6.style">
    <xsl:attribute name="space-before">1em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="h6.style">
    <xsl:attribute name="font-family">Helvetica</xsl:attribute>
    <xsl:attribute name="font-size">10pt</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="space-after">0.5em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="inform-div1.style">
    <xsl:attribute name="space-before">1em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="thead.style">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="tfoot.style">
  </xsl:attribute-set>

  <xsl:attribute-set name="note.style">
  </xsl:attribute-set>

  <xsl:attribute-set name="notice.style">
  </xsl:attribute-set>

  <xsl:attribute-set name="constraint.style">
  </xsl:attribute-set>

  <xsl:attribute-set name="prefix.style">
  </xsl:attribute-set>

  <xsl:attribute-set name="para.style">
    <xsl:attribute name="space-before">0.5em</xsl:attribute>
    <xsl:attribute name="space-after">0.5em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="blockquote.style">
    <xsl:attribute name="margin-left">2em</xsl:attribute>
    <xsl:attribute name="margin-right">2em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="var.style">
    <xsl:attribute name="font-family">Courier</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="code.style">
    <xsl:attribute name="font-family">Courier</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="pre.style">
    <xsl:attribute name="font-family">Courier</xsl:attribute>
    <xsl:attribute name="wrap-option">no-wrap</xsl:attribute>
    <xsl:attribute name="text-align">start</xsl:attribute>
    <xsl:attribute name="white-space-collapse">false</xsl:attribute>
    <xsl:attribute name="linefeed-treatment">preserve</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="i.style">
    <xsl:attribute name="font-style">italic</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="cite.style">
    <xsl:attribute name="font-style">italic</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="b.style">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="em.style">
    <xsl:attribute name="font-style">italic</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="th.style">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>

  <!-- ================================================================= -->

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- ================================================================= -->

  <xsl:template match="abstract">
    <fo:block id="abstract">
      <fo:block xsl:use-attribute-sets="h2.style">
        <xsl:text>Abstract</xsl:text>
      </fo:block>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="affiliation">
    <xsl:text>, </xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="arg">
    <xsl:if test="position() > 1">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <fo:inline xsl:use-attribute-sets="var.style">
      <xsl:value-of select="@type"/>
    </fo:inline>
    <xsl:if test="@occur = 'opt'">
      <xsl:text>?</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="att">
    <fo:inline xsl:use-attribute-sets="code.style">
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <xsl:template match="attval">
    <xsl:text>"</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="authlist">
    <fo:block font-weight="bold">
      <xsl:text>Editor</xsl:text>
      <xsl:if test="count(author) > 1">
        <xsl:text>s</xsl:text>
      </xsl:if>
      <xsl:text>:</xsl:text>
    </fo:block>
    <fo:block start-indent="0.3in">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="author">
    <fo:block>
      <xsl:apply-templates/>
      <xsl:if test="@role = '2e'">
        <xsl:text> - Second Edition</xsl:text>
      </xsl:if>
    </fo:block>
  </xsl:template>

  <xsl:template match="back">
    <fo:block>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="blist">
    <fo:block>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="bibl">
    <fo:block font-weight="bold">
      <xsl:call-template name="anchor"/>
      <xsl:choose>
	<xsl:when test="@key">
	  <xsl:value-of select="@key"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="@id"/>
	</xsl:otherwise>
      </xsl:choose>
    </fo:block>
    <fo:block start-indent="0.3in">
      <xsl:apply-templates/>
      <xsl:if test="@href">
        <xsl:text>  (See </xsl:text>
        <fo:basic-link external-destination="url({@href})">
          <xsl:value-of select="@href"/>
        </fo:basic-link>
        <xsl:text>.)</xsl:text>
      </xsl:if>
    </fo:block>
  </xsl:template>

  <xsl:template match="bibref">
    <fo:basic-link internal-destination="{@ref}">
      <xsl:text>[</xsl:text>
      <xsl:choose>
        <xsl:when test="key('ids',@ref)/@key">
          <xsl:value-of select="key('ids',@ref)/@key"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@ref"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>]</xsl:text>
    </fo:basic-link>
  </xsl:template>

  <xsl:template match="bnf">
    <fo:table-row>
      <fo:table-cell>
        <fo:block xsl:use-attribute-sets="pre.style">
          <xsl:apply-templates/>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>

  <xsl:template match="body">
    <fo:block break-before="page">
      <fo:block xsl:use-attribute-sets="h2.style">
        <xsl:text>Table of Contents</xsl:text>
      </fo:block>
      <fo:block>
        <xsl:apply-templates select="div1" mode="toc"/>
      </fo:block>
      <xsl:if test="../back">
        <fo:block xsl:use-attribute-sets="h3.style" space-before="0.5em">
          <xsl:text>Appendi</xsl:text>
          <xsl:choose>
            <xsl:when test="count(../back/div1 | ../back/inform-div1) > 1">
              <xsl:text>ces</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>x</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </fo:block>
        <fo:block>
          <xsl:apply-templates mode="toc"
            select="../back/div1 | ../back/inform-div1"/>
        </fo:block>
      </xsl:if>
    </fo:block>
    <fo:block break-before='page'>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="code">
    <fo:inline xsl:use-attribute-sets="code.style">
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <xsl:template match="constraintnote">
    <fo:block>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="div1">
    <fo:block xsl:use-attribute-sets="div1.style">
      <xsl:call-template name="anchor">
        <xsl:with-param name="conditional" select="0"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="div2">
    <fo:block xsl:use-attribute-sets="div2.style">
      <xsl:call-template name="anchor">
        <xsl:with-param name="conditional" select="0"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="div3">
    <fo:block xsl:use-attribute-sets="div3.style">
      <xsl:call-template name="anchor">
        <xsl:with-param name="conditional" select="0"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="div4">
    <fo:block xsl:use-attribute-sets="div4.style">
      <xsl:call-template name="anchor">
        <xsl:with-param name="conditional" select="0"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="div5">
    <fo:block xsl:use-attribute-sets="div5.style">
      <xsl:call-template name="anchor">
        <xsl:with-param name="conditional" select="0"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="ednote"/>

  <xsl:template match="eg">
    <fo:block xsl:use-attribute-sets="pre.style">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="el">
    <fo:inline xsl:use-attribute-sets="code.style">
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <xsl:template match="email">
    <xsl:text> </xsl:text>
    <fo:basic-link external-destination="url({@href})">
      <xsl:text>&lt;</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>&gt;</xsl:text>
    </fo:basic-link>
  </xsl:template>

  <xsl:template match="emph">
    <fo:inline xsl:use-attribute-sets="em.style">
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <xsl:template match="rfc2119">
    <fo:inline font-weight="bold">
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <xsl:template match="example">
    <fo:block>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="footnote">
    <fo:footnote>
      <fo:inline>
        <xsl:apply-templates select="." mode="label.markup"/>
      </fo:inline>
      <fo:footnote-body font-size="9pt" font-family="{$body.font.family}">
        <xsl:apply-templates/>
      </fo:footnote-body>
    </fo:footnote>
  </xsl:template>

  <xsl:template match="footnote/p[1]">
    <fo:block>
      <xsl:apply-templates select=".." mode="label.markup"/>
      <xsl:text> </xsl:text>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="footnote" mode="label.markup">
    <fo:inline baseline-shift="super">
      <xsl:number level="any" format="1"/>
    </fo:inline>
  </xsl:template>

  <xsl:template match="front">
    <fo:block>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="function">
    <fo:inline xsl:use-attribute-sets="code.style">
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <xsl:template match="glist">
    <fo:block>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="gitem">
    <fo:block>
      <xsl:call-template name="anchor"/>
      <fo:block font-weight="bold">
        <xsl:apply-templates select="label"/>
      </fo:block>
      <fo:block start-indent="{count(ancestor::glist)*0.3}in">
        <xsl:apply-templates select="def"/>
      </fo:block>
    </fo:block>
  </xsl:template>

  <xsl:template match="label">
    <fo:inline>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <xsl:template match="def">
    <fo:block>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="graphic">
    <fo:external-graphic src="url({@source})"/>
  </xsl:template>

  <xsl:template match="constraintnote/head">
    <fo:block>
      <fo:inline xsl:use-attribute-sets="b.style">
        <xsl:text>Constraint: </xsl:text>
        <xsl:apply-templates/>
      </fo:inline>
    </fo:block>
  </xsl:template>

  <xsl:template match="div1/head">
    <fo:block xsl:use-attribute-sets="h2.style"
              keep-with-next="always">
      <xsl:apply-templates select=".." mode="divnum"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="div2/head">
    <fo:block xsl:use-attribute-sets="h3.style"
              keep-with-next="always">
      <xsl:apply-templates select=".." mode="divnum"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="div3/head">
    <fo:block xsl:use-attribute-sets="h4.style"
              keep-with-next="always">
      <xsl:apply-templates select=".." mode="divnum"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="div4/head">
    <fo:block xsl:use-attribute-sets="h5.style"
              keep-with-next="always">
      <xsl:apply-templates select=".." mode="divnum"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="div5/head">
    <fo:block xsl:use-attribute-sets="h6.style"
              keep-with-next="always">
      <xsl:apply-templates select=".." mode="divnum"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="example/head">
    <fo:block xsl:use-attribute-sets="h5.style"
              keep-with-next="always">
      <xsl:text>Example: </xsl:text>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="inform-div1/head">
    <fo:block xsl:use-attribute-sets="h2.style"
              keep-with-next="always">
      <xsl:apply-templates select=".." mode="divnum"/>
      <xsl:apply-templates/>
      <xsl:text> (Non-Normative)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="issue/head">
    <fo:inline xsl:use-attribute-sets="b.style">
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <xsl:template match="vcnote/head">
    <fo:block>
      <fo:inline xsl:use-attribute-sets="b.style">
        <xsl:text>Validity constraint: </xsl:text>
        <xsl:apply-templates/>
      </fo:inline>
    </fo:block>
  </xsl:template>

  <xsl:template match="wfcnote/head">
    <fo:block>
      <fo:inline xsl:use-attribute-sets="b.style">
        <xsl:text>Well-formedness constraint: </xsl:text>
        <xsl:apply-templates/>
      </fo:inline>
    </fo:block>
  </xsl:template>

  <xsl:template match="header">
    <fo:block>
      <fo:block>
        <fo:basic-link external-destination="url(http://www.w3.org/)">
          <fo:external-graphic src="url(http://www.w3.org/Icons/w3c_home.png)"
                               height="48px" width="72px"/>
        </fo:basic-link>
      </fo:block>
      <fo:block xsl:use-attribute-sets="h1.style">
        <xsl:apply-templates select="title"/>
        <xsl:if test="version">
          <xsl:text> </xsl:text>
          <xsl:apply-templates select="version"/>
        </xsl:if>
      </fo:block>
      <xsl:if test="subtitle">
        <fo:block xsl:use-attribute-sets="h2.style">
          <xsl:apply-templates select="subtitle"/>
        </fo:block>
      </xsl:if>
      <fo:block xsl:use-attribute-sets="h2.style">
        <xsl:apply-templates select="w3c-doctype"/>
        <xsl:text> </xsl:text>
        <xsl:if test="pubdate/day">
          <xsl:apply-templates select="pubdate/day"/>
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:apply-templates select="pubdate/month"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="pubdate/year"/>
      </fo:block>
      <xsl:apply-templates select="publoc"/>
      <xsl:apply-templates select="latestloc"/>
      <xsl:apply-templates select="prevlocs"/>
      <xsl:apply-templates select="authlist"/>

      <xsl:apply-templates select="errataloc"/>
      <xsl:apply-templates select="preverrataloc"/>
      <xsl:apply-templates select="translationloc"/>

      <!-- output the altlocs -->
      <xsl:apply-templates select="altlocs"/>

      <xsl:choose>
        <xsl:when test="copyright">
          <xsl:apply-templates select="copyright"/>
        </xsl:when>
        <xsl:otherwise>
          <fo:block space-before="0.5em" space-after="0.5em">
            <fo:basic-link external-destination="url(http://www.w3.org/Consortium/Legal/ipr-notice#Copyright)">
              <xsl:text>Copyright</xsl:text>
            </fo:basic-link>
            <xsl:text>&#xa0;&#xa9;&#xa0;</xsl:text>
            <xsl:apply-templates select="pubdate/year"/>
            <xsl:text>&#xa0;</xsl:text>
            <fo:basic-link external-destination="url(http://www.w3.org/)">
              <xsl:text>W3C</xsl:text>
            </fo:basic-link>
            <fo:inline baseline-shift="super">&#xae;</fo:inline>
            <xsl:text> (</xsl:text>
            <fo:basic-link external-destination="url(http://www.lcs.mit.edu/)">
              <xsl:text>MIT</xsl:text>
            </fo:basic-link>
            <xsl:text>, </xsl:text>
            <fo:basic-link external-destination="url(http://www.ercim.org/)">
              <xsl:text>ERCIM</xsl:text>
            </fo:basic-link>
            <xsl:text>, </xsl:text>
            <fo:basic-link external-destination="url(http://www.keio.ac.jp/)">
              <xsl:text>Keio</xsl:text>
            </fo:basic-link>
            <xsl:text>), All Rights Reserved. W3C </xsl:text>
            <fo:basic-link external-destination="url(http://www.w3.org/Consortium/Legal/ipr-notice#Legal_Disclaimer)">
              <xsl:text>liability</xsl:text>
            </fo:basic-link>
            <xsl:text>, </xsl:text>
            <fo:basic-link external-destination="url(http://www.w3.org/Consortium/Legal/ipr-notice#W3C_Trademarks)">
              <xsl:text>trademark</xsl:text>
            </fo:basic-link>
            <xsl:text>, </xsl:text>
            <fo:basic-link external-destination="url(http://www.w3.org/Consortium/Legal/copyright-documents-19990405)">
              <xsl:text>document use</xsl:text>
            </fo:basic-link>
            <xsl:text> and </xsl:text>
            <fo:basic-link external-destination="url(http://www.w3.org/Consortium/Legal/copyright-software-19980720)">
              <xsl:text>software licensing</xsl:text>
            </fo:basic-link>
            <xsl:text> rules apply.</xsl:text>
          </fo:block>
        </xsl:otherwise>
      </xsl:choose>
    </fo:block>
    <!-- FIXME: hr -->
    <xsl:apply-templates select="notice"/>
    <xsl:apply-templates select="abstract"/>
    <xsl:apply-templates select="status"/>
  </xsl:template>

  <xsl:template match="inform-div1">
    <fo:block xsl:use-attribute-sets="inform-div1.style">
      <xsl:call-template name="anchor">
        <xsl:with-param name="conditional" select="0"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="issue">
    <fo:block>
      <xsl:call-template name="anchor"/>
      <fo:block>
	<fo:inline xsl:use-attribute-sets="b.style">
          <xsl:text>Issue (</xsl:text>
          <xsl:value-of select="@id"/>
          <xsl:text>):</xsl:text>
        </fo:inline>
      </fo:block>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="issue" mode="number">
    <xsl:number level="any" format="1"/>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- OrderedList Numeration -->

  <xsl:template name="next.numeration">
    <xsl:param name="numeration" select="'default'"/>
    <xsl:choose>
      <!-- Change this list if you want to change the order of numerations -->
      <xsl:when test="$numeration = 'arabic'">loweralpha</xsl:when>
      <xsl:when test="$numeration = 'loweralpha'">lowerroman</xsl:when>
      <xsl:when test="$numeration = 'lowerroman'">upperalpha</xsl:when>
      <xsl:when test="$numeration = 'upperalpha'">upperroman</xsl:when>
      <xsl:when test="$numeration = 'upperroman'">arabic</xsl:when>
      <xsl:otherwise>arabic</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="list.numeration">
    <xsl:param name="node" select="."/>

    <xsl:choose>
      <xsl:when test="$node/ancestor::olist">
        <xsl:call-template name="next.numeration">
          <xsl:with-param name="numeration">
            <xsl:call-template name="list.numeration">
              <xsl:with-param name="node" select="$node/ancestor::olist[1]"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="next.numeration"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="item">
    <fo:list-item space-before="0.5em">
      <fo:list-item-label end-indent="label-end()">
        <fo:block>
          <xsl:choose>
            <xsl:when test="local-name(..) = 'olist'">

              <xsl:variable name="numeration">
                <xsl:call-template name="list.numeration">
                  <xsl:with-param name="node" select="ancestor::olist[1]"/>
                </xsl:call-template>
              </xsl:variable>

              <xsl:variable name="type">
                <xsl:choose>
                  <xsl:when test="$numeration='arabic'">1</xsl:when>
                  <xsl:when test="$numeration='loweralpha'">a</xsl:when>
                  <xsl:when test="$numeration='lowerroman'">i</xsl:when>
                  <xsl:when test="$numeration='upperalpha'">A</xsl:when>
                  <xsl:when test="$numeration='upperroman'">I</xsl:when>
                  <!-- What!? This should never happen -->
                  <xsl:otherwise>
                    <xsl:message>
                      <xsl:text>Unexpected numeration: </xsl:text>
                      <xsl:value-of select="$numeration"/>
                    </xsl:message>
                    <xsl:value-of select="1"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>

              <xsl:number count="item" format="{$type}."/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>&#x2022;</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </fo:block>
      </fo:list-item-label>
      <fo:list-item-body start-indent="body-start()">
        <xsl:apply-templates/>
      </fo:list-item-body>
    </fo:list-item>
  </xsl:template>

  <xsl:template match="item/p[1]">
    <fo:block>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="kw">
    <fo:inline xsl:use-attribute-sets="b.style">
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- New pubrules will allow more than one, support multiple loc elements -->
  <!-- DTD actually allows p.pcd.mix (!?) so be careful here... -->

  <xsl:template match="latestloc">
    <xsl:choose>
      <xsl:when test="count(loc) &gt; 1">
	<xsl:for-each select="loc">
	  <fo:block font-weight="bold">
	    <xsl:apply-templates select="node()"/>
	  </fo:block>
	  <fo:block start-indent="0.3in">
	    <fo:basic-link external-destination="url({@href})">
	      <xsl:value-of select="@href"/>
	    </fo:basic-link>
	  </fo:block>
	</xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
	<fo:block font-weight="bold">
	  <xsl:text>Latest version:</xsl:text>
	</fo:block>
	<fo:block start-indent="0.3in">
	  <xsl:apply-templates/>
	</fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="loc">
    <fo:basic-link external-destination="url({@href})">
      <xsl:apply-templates/>
    </fo:basic-link>
  </xsl:template>

  <xsl:template match="member">
    <fo:list-item>
      <fo:list-item-label>
        <fo:block>
          <xsl:text>?</xsl:text>
        </fo:block>
      </fo:list-item-label>
      <fo:list-item-body>
        <fo:block>
          <xsl:apply-templates/>
        </fo:block>
      </fo:list-item-body>
    </fo:list-item>
  </xsl:template>

  <xsl:template match="name">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="note">
    <fo:block xsl:use-attribute-sets="note.style">
      <fo:block xsl:use-attribute-sets="prefix.style">
        <fo:inline xsl:use-attribute-sets="b.style">Note:</fo:inline>
      </fo:block>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="notice">
    <fo:block xsl:use-attribute-sets="notice.style">
      <fo:block xsl:use-attribute-sets="prefix.style">
        <fo:inline xsl:use-attribute-sets="b.style">NOTICE:</fo:inline>
      </fo:block>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="nt">
    <fo:inline id="{@def}">
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <xsl:template match="orglist">
    <!-- FIXME: ul -->
    <fo:list-block>
      <xsl:apply-templates/>
    </fo:list-block>
  </xsl:template>

  <xsl:template match="p">
    <fo:block xsl:use-attribute-sets="para.style">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="phrase">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="prevlocs">
    <fo:block font-weight="bold">
      <xsl:text>Previous version</xsl:text>
      <xsl:if test="count(locs) &gt; 1">s</xsl:if>
      <xsl:text>:</xsl:text>
    </fo:block>
    <fo:block start-indent="0.3in">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="proto">
    <fo:block>
      <fo:inline xsl:use-attribute-sets="em.style">
        <xsl:value-of select="@return-type"/>
      </fo:inline>
      <xsl:text> </xsl:text>
      <fo:inline xsl:use-attribute-sets="b.style">
        <xsl:value-of select="@name"/>
      </fo:inline>
      <xsl:text>(</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>)</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="publoc">
    <fo:block font-weight="bold">
      <xsl:text>This version:</xsl:text>
    </fo:block>
    <fo:block start-indent="0.3in">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="errataloc">
    <fo:block xsl:use-attribute-sets="para.style">
      <xsl:text>Please refer to the </xsl:text>
      <xsl:text>errata</xsl:text>
      <xsl:text> for this document, which may
      include normative corrections.</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="preverrataloc">
    <fo:block xsl:use-attribute-sets="para.style">
      <xsl:text>The </xsl:text>
      <xsl:text>previous errata</xsl:text>
      <xsl:text> for this document, are also available.</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="translationloc">
    <fo:block xsl:use-attribute-sets="para.style">
      <xsl:text>See also </xsl:text>
      <fo:inline font-weight="bold">translations</fo:inline>
      <xsl:text>.</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="altlocs">
    <fo:block space-before="1em">
      <xsl:text>This document is also available </xsl:text>
      <xsl:text>in these non-normative formats: </xsl:text>
      <xsl:for-each select="loc">
        <xsl:if test="position() &gt; 1">
          <xsl:if test="last() &gt; 2">
            <xsl:text>, </xsl:text>
          </xsl:if>
          <xsl:if test="last() = 2">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:if>
        <xsl:if test="position() = last() and position() &gt; 1">and&#160;</xsl:if>
        <fo:basic-link external-destination="url({@href})">
          <xsl:apply-templates/>
        </fo:basic-link>
      </xsl:for-each>
      <xsl:text>.</xsl:text>
    </fo:block>
  </xsl:template>

  <xsl:template match="quote">
    <xsl:text>"</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template match="resolution">
    <fo:block xsl:use-attribute-sets="prefix.style">
      <fo:inline xsl:use-attribute-sets="b.style">Resolution:</fo:inline>
    </fo:block>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="role">
    <xsl:text> (</xsl:text>
    <fo:inline xsl:use-attribute-sets="i.style">
      <xsl:apply-templates/>
    </fo:inline>
    <xsl:text>) </xsl:text>
  </xsl:template>

  <!-- ================================================================= -->
  <!-- ELEMENT scrap (head, (prodgroup | prod | bnf | prodrecap)+) -->
  <!-- ELEMENT prodgroup (prod+) -->
  <!-- ELEMENT prod (lhs, (rhs, (com|wfc|vc|constraint)*)+) -->
  <!-- ELEMENT prodrecap EMPTY -->
  <!-- ELEMENT bnf (%eg.pcd.mix;)* -->

  <xsl:template match="scrap">
    <xsl:apply-templates select="head"/>
    <fo:table>
      <fo:table-column column-number='1' column-width='0.3in'/>
      <fo:table-column column-number='2' column-width='2in'/>
      <fo:table-column column-number='3' column-width='0.3in'/>
      <fo:table-column column-number='4' column-width='2in'/>
      <fo:table-column column-number='5' column-width='1.4in'/>
      <fo:table-body>
        <xsl:apply-templates select="bnf | prod | prodgroup"/>
      </fo:table-body>
    </fo:table>
  </xsl:template>

  <xsl:template match="scrap/head">
    <fo:block xsl:use-attribute-sets="h5.style">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="prod">
    <xsl:apply-templates
         select="lhs |
                 rhs[preceding-sibling::*[1][name()!='lhs']] |
                 com[preceding-sibling::*[1][name()!='rhs']] |
                 constraint[preceding-sibling::*[1][name()!='rhs']] |
                 vc[preceding-sibling::*[1][name()!='rhs']] |
                 wfc[preceding-sibling::*[1][name()!='rhs']]"/>
  </xsl:template>

  <xsl:template match="prodgroup/prod">
    <xsl:apply-templates
      select="lhs |
              rhs[preceding-sibling::*[1][name()!='lhs']] |
              com[preceding-sibling::*[1][name()!='rhs']] |
              constraint[preceding-sibling::*[1][name()!='rhs']] |
              vc[preceding-sibling::*[1][name()!='rhs']] |
              wfc[preceding-sibling::*[1][name()!='rhs']]"/>
  </xsl:template>

  <xsl:template match="prodgroup">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="prodrecap">
    <fo:table-body>
      <xsl:apply-templates select="key('ids',@ref)" mode="ref"/>
    </fo:table-body>
  </xsl:template>

  <xsl:template match="lhs">
    <fo:table-row>
      <fo:table-cell>
        <fo:block>
          <xsl:apply-templates select="ancestor::prod" mode="number"/>
          <xsl:text>&#xa0;&#xa0;&#xa0;</xsl:text>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell>
        <fo:block>
          <fo:inline xsl:use-attribute-sets="code.style">
            <xsl:apply-templates/>
          </fo:inline>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell>
        <fo:block>
          <xsl:text>&#xa0;&#xa0;&#xa0;::=&#xa0;&#xa0;&#xa0;</xsl:text>
        </fo:block>
      </fo:table-cell>
      <xsl:apply-templates select="following-sibling::*[1][name()='rhs']"/>
    </fo:table-row>
  </xsl:template>

  <!-- mode: ref -->
  <xsl:template match="lhs" mode="ref">
    <fo:table-row>
      <fo:table-cell><fo:block/></fo:table-cell>
      <fo:table-cell>
        <fo:block>
          <fo:inline xsl:use-attribute-sets="code.style">
            <xsl:apply-templates/>
          </fo:inline>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell>
        <fo:block>
          <xsl:text>&#xa0;&#xa0;&#xa0;::=&#xa0;&#xa0;&#xa0;</xsl:text>
        </fo:block>
      </fo:table-cell>
      <xsl:apply-templates select="following-sibling::*[1][name()='rhs']"/>
    </fo:table-row>
  </xsl:template>

  <xsl:template match="rhs">
    <xsl:choose>
      <xsl:when test="preceding-sibling::*[1][name()='lhs']">
        <fo:table-cell>
          <fo:block>
            <fo:inline xsl:use-attribute-sets="code.style">
              <xsl:apply-templates/>
            </fo:inline>
          </fo:block>
        </fo:table-cell>
        <xsl:apply-templates
          select="following-sibling::*[1][name()='com' or
                                          name()='constraint' or
                                          name()='vc' or
                                          name()='wfc']"/>
      </xsl:when>
      <xsl:otherwise>
        <fo:table-row>
          <fo:table-cell><fo:block/></fo:table-cell>
          <fo:table-cell><fo:block/></fo:table-cell>
          <fo:table-cell><fo:block/></fo:table-cell>
          <fo:table-cell>
            <fo:block>
              <fo:inline xsl:use-attribute-sets="code.style">
                <xsl:apply-templates/>
              </fo:inline>
            </fo:block>
          </fo:table-cell>
          <xsl:apply-templates
            select="following-sibling::*[1][name()='com' or
                                            name()='constraint' or
                                            name()='vc' or
                                            name()='wfc']"/>
        </fo:table-row>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="com">
    <xsl:choose>
      <xsl:when test="preceding-sibling::*[1][name()='rhs']">
        <fo:table-cell>
          <fo:block>
            <fo:inline xsl:use-attribute-sets="i.style">
              <xsl:text>/* </xsl:text>
              <xsl:apply-templates/>
              <xsl:text> */</xsl:text>
            </fo:inline>
          </fo:block>
        </fo:table-cell>
      </xsl:when>
      <xsl:otherwise>
        <fo:table-row>
          <fo:table-cell><fo:block/></fo:table-cell>
          <fo:table-cell><fo:block/></fo:table-cell>
          <fo:table-cell>
            <fo:block>
              <fo:inline xsl:use-attribute-sets="i.style">
                <xsl:text>/* </xsl:text>
                <xsl:apply-templates/>
                <xsl:text> */</xsl:text>
              </fo:inline>
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="rhs/com">
    <fo:inline xsl:use-attribute-sets="i.style">
      <xsl:text>/* </xsl:text>
      <xsl:apply-templates/>
      <xsl:text> */</xsl:text>
    </fo:inline>
  </xsl:template>

  <xsl:template match="constraint">
    <xsl:choose>
      <xsl:when test="preceding-sibling::*[1][name()='rhs']">
        <fo:table-cell>
          <fo:block>
            <fo:basic-link internal-destination="{@def}">
              <xsl:text>[Constraint: </xsl:text>
              <xsl:apply-templates select="key('ids',@def)/head" mode="text"/>
              <xsl:text>]</xsl:text>
            </fo:basic-link>
          </fo:block>
        </fo:table-cell>
      </xsl:when>
      <xsl:otherwise>
        <fo:table-row>
          <fo:table-cell><fo:block/></fo:table-cell>
          <fo:table-cell><fo:block/></fo:table-cell>
          <fo:table-cell>
            <fo:block>
              <fo:basic-link internal-destination="{@def}">
                <xsl:text>[Constraint: </xsl:text>
                <xsl:apply-templates select="key('ids',@def)/head" mode="text"/>
                <xsl:text>]</xsl:text>
              </fo:basic-link>
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="ref" match="prod">
    <xsl:apply-templates select="lhs" mode="ref"/>
    <xsl:apply-templates
      select="rhs[preceding-sibling::*[1][name()!='lhs']] |
              com[preceding-sibling::*[1][name()!='rhs']] |
              constraint[preceding-sibling::*[1][name()!='rhs']] |
              vc[preceding-sibling::*[1][name()!='rhs']] |
              wfc[preceding-sibling::*[1][name()!='rhs']]"/>
  </xsl:template>

  <!-- ================================================================= -->

  <xsl:template match="sitem">
    <fo:block>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="slist">
    <fo:block margin-left="2em" margin-right="2em">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="source">
    <fo:block>
      <fo:inline xsl:use-attribute-sets="b.style">Source</fo:inline>
      <xsl:text>: </xsl:text>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="spec">
    <xsl:variable name="master-name">
      <xsl:call-template name="select.pagemaster"/>
    </xsl:variable>

    <fo:root font-family="{$body.font.family}"
             font-size="{$body.font.size}"
             text-align="{$alignment}">
      <xsl:call-template name="setup.pagemasters"/>
      <fo:page-sequence format="1.">
        <xsl:if test="@xml:lang">
          <xsl:attribute name="language">
            <xsl:value-of select="@xml:lang"/>
          </xsl:attribute>
          <xsl:attribute name="hyphenate">
            <xsl:value-of select="$hyphenate"/>
          </xsl:attribute>
        </xsl:if>

        <xsl:choose>
          <xsl:when test="$last-call-fop != 0">
            <xsl:attribute name="master-name">
              <xsl:value-of select="$master-name"/>
            </xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="master-reference">
              <xsl:value-of select="$master-name"/>
            </xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:apply-templates select="." mode="running.head.mode">
          <xsl:with-param name="master-name" select="$master-name"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="." mode="running.foot.mode">
          <xsl:with-param name="master-name" select="$master-name"/>
        </xsl:apply-templates>

        <fo:flow flow-name="xsl-region-body">
          <xsl:apply-templates/>
        </fo:flow>
      </fo:page-sequence>
    </fo:root>
  </xsl:template>

  <xsl:template match="specref">
    <xsl:variable name="target" select="key('ids',@ref)[1]"/>

    <xsl:choose>
      <xsl:when test="not($target)">
	<xsl:message>
          <xsl:text>Missing specref target </xsl:text>
          <xsl:value-of select="@ref"/>
        </xsl:message>
        <fo:inline font-weight="bold">
          <xsl:text>[specref failure, no ID '</xsl:text>
          <xsl:value-of select="@ref"/>
          <xsl:text>']</xsl:text>
        </fo:inline>
      </xsl:when>

      <xsl:when test="local-name($target)='issue'
                      or starts-with(local-name($target), 'div')
                      or starts-with(local-name($target), 'inform-div')
                      or local-name($target) = 'vcnote'
                      or local-name($target) = 'prod'
                      or local-name($target) = 'example'
                      or local-name($target) = 'label'
		      or $target/self::item[parent::olist]">
        <xsl:apply-templates select="$target" mode="specref"/>
      </xsl:when>

      <xsl:otherwise>
	<xsl:message>
	  <xsl:text>Unsupported specref to </xsl:text>
	  <xsl:value-of select="local-name($target)"/>
	  <xsl:text> [</xsl:text>
	  <xsl:value-of select="@ref"/>
	  <xsl:text>] </xsl:text>
	  <xsl:text> (Contact stylesheet maintainer).</xsl:text>
	</xsl:message>
	<fo:inline font-weight="bold">
	  <xsl:text>???</xsl:text>
	</fo:inline>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<xsl:template match="item" mode="specref">
  <xsl:variable name="items" select="ancestor-or-self::item[parent::olist]"/>

  <fo:basic-link external-destination="url(#@{@id})">
    <xsl:for-each select="$items">
      <xsl:variable name="number" select="count(preceding-sibling::item)+1"/>
      <xsl:variable name="numeration">
	<!-- this is related to, but not the same as, list.numeration -->
	<xsl:choose>
	  <xsl:when test="count(ancestor::olist) mod 5 = 1">ar</xsl:when>
	  <xsl:when test="count(ancestor::olist) mod 5 = 2">la</xsl:when>
	  <xsl:when test="count(ancestor::olist) mod 5 = 3">lr</xsl:when>
	  <xsl:when test="count(ancestor::olist) mod 5 = 4">ua</xsl:when>
	  <xsl:when test="count(ancestor::olist) mod 5 = 0">ur</xsl:when>
	</xsl:choose>
      </xsl:variable>

      <xsl:choose>
	<xsl:when test="$numeration = 'la'">
	  <xsl:number value="$number" format="a"/>
	</xsl:when>
	<xsl:when test="$numeration = 'lr'">
	  <xsl:number value="$number" format="i"/>
	</xsl:when>
	<xsl:when test="$numeration = 'ua'">
	  <xsl:number value="$number" format="A"/>
	</xsl:when>
	<xsl:when test="$numeration = 'ur'">
	  <xsl:number value="$number" format="I"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$number"/>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:text>.</xsl:text>
    </xsl:for-each>
  </fo:basic-link>
</xsl:template>

<xsl:template match="issue" mode="specref">
  <xsl:text>[</xsl:text>
  <fo:inline font-weight="bold">
    <xsl:text>Issue </xsl:text>
    <xsl:apply-templates select="key('ids',@ref)" mode="number"/>
    <xsl:text>: </xsl:text>
    <xsl:for-each select="key('ids',@ref)/head">
      <xsl:apply-templates/>
    </xsl:for-each>
  </fo:inline>
  <xsl:text>]</xsl:text>
</xsl:template>

<xsl:template match="div1|div2|div3|div4|div5" mode="specref">
  <fo:inline font-weight="bold">
    <xsl:apply-templates select="key('ids',@ref)" mode="divnum"/>
    <xsl:apply-templates select="key('ids',@ref)/head" mode="text"/>
  </fo:inline>
</xsl:template>

<xsl:template match="inform-div1" mode="specref">
  <fo:inline font-weight="bold">
    <xsl:apply-templates select="key('ids',@ref)" mode="divnum"/>
    <xsl:apply-templates select="key('ids',@ref)/head" mode="text"/>
  </fo:inline>
</xsl:template>

<xsl:template match="vcnote" mode="specref">
  <fo:inline font-weight="bold">
    <xsl:text>[VC: </xsl:text>
    <xsl:apply-templates select="key('ids',@ref)/head" mode="text"/>
    <xsl:text>]</xsl:text>
  </fo:inline>
</xsl:template>

<xsl:template match="prod" mode="specref">
  <fo:inline font-weight="bold">
    <xsl:text>[PROD: </xsl:text>
    <xsl:apply-templates select="." mode="number-simple"/>
    <xsl:text>]</xsl:text>
  </fo:inline>
</xsl:template>

<xsl:template match="example" mode="specref">
  <xsl:apply-templates select="head" mode="specref"/>
</xsl:template>

<xsl:template match="example/head" mode="specref">
  <xsl:variable name="id">
    <xsl:call-template name="object.id">
	<xsl:with-param name="node" select=".."/>
    </xsl:call-template>
  </xsl:variable>

  <fo:basic-link external-destination="url(#{$id})">
    <xsl:text>Example</xsl:text>
  </fo:basic-link>
</xsl:template>

<xsl:template match="label" mode="specref">
  <fo:inline font-weight="bold">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>]</xsl:text>
  </fo:inline>
</xsl:template>

  <xsl:template match="status">
    <fo:block id="status">
      <fo:block xsl:use-attribute-sets="h2.style">
        <xsl:text>Status of this Document</xsl:text>
      </fo:block>
      <xsl:if test="/spec/@role='editors-copy'">
        <fo:block font-weight="bold" space-before="0.5em" space-after="0.5em">
          <xsl:text>This document is an editors' copy that has </xsl:text>
          <xsl:text>no official standing.</xsl:text>
        </fo:block>
      </xsl:if>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="sub">
    <fo:inline baseline-shift="sub">
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <xsl:template match="sup">
    <fo:inline baseline-shift="super">
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <xsl:template match="caption">
  </xsl:template>

  <xsl:template match="col">
  </xsl:template>

  <xsl:template match="colgroup">
  </xsl:template>

  <xsl:template match="table">
    <xsl:variable name="numcols">
      <xsl:call-template name="widest-row">
        <xsl:with-param name="rows" select=".//tr"/>
      </xsl:call-template>
    </xsl:variable>
    <fo:table table-layout="fixed">
      <xsl:attribute name="width">
        <xsl:choose>
          <xsl:when test="@width">
            <xsl:value-of select="@width"/>
          </xsl:when>
          <xsl:otherwise>100%</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:call-template name="make-table-columns">
        <xsl:with-param name="count" select="$numcols"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </fo:table>
  </xsl:template>

  <xsl:template name="widest-row">
    <xsl:param name="rows" select="''"/>
    <xsl:param name="count" select="0"/>
    <xsl:choose>
      <xsl:when test="count($rows) = 0">
        <xsl:value-of select="$count"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$count &gt; count($rows[1]/*)">
            <xsl:call-template name="widest-row">
              <xsl:with-param name="rows" select="$rows[position() &gt; 1]"/>
              <xsl:with-param name="count" select="$count"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="widest-row">
              <xsl:with-param name="rows" select="$rows[position() &gt; 1]"/>
              <xsl:with-param name="count" select="count($rows[1]/*)"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="make-table-columns">
    <xsl:param name="count" select="0"/>
    <xsl:param name="number" select="1"/>

    <xsl:choose>
      <xsl:when test="col|colgroup/col">
        <xsl:for-each select="col|colgroup/col">
          <fo:table-column>
            <xsl:attribute name="column-number">
              <xsl:number from="table" level="any" format="1"/>
            </xsl:attribute>
            <xsl:if test="@width">
              <xsl:attribute name="column-width">
                <xsl:value-of select="@width"/>
              </xsl:attribute>
            </xsl:if>
          </fo:table-column>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$fop != 0">
        <xsl:if test="$number &lt;= $count">
          <fo:table-column column-number="{$number}"
                           column-width="{$fop-table-width-in-inches div $count}in"/>
          <xsl:call-template name="make-table-columns">
            <xsl:with-param name="count" select="$count"/>
            <xsl:with-param name="number" select="$number + 1"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tbody">
    <fo:table-body border-bottom-width="0.25pt"
                   border-bottom-style="solid"
                   border-bottom-color="black">
      <xsl:apply-templates/>
    </fo:table-body>
  </xsl:template>

  <xsl:template match="td">
    <fo:table-cell>
      <fo:block>
        <xsl:apply-templates/>
      </fo:block>
    </fo:table-cell>
  </xsl:template>

  <xsl:template match="tfoot">
    <fo:table-footer>
      <xsl:apply-templates/>
    </fo:table-footer>
  </xsl:template>

  <xsl:template match="th">
    <fo:table-cell xsl:use-attribute-sets="th.style">
      <fo:block>
        <xsl:apply-templates/>
      </fo:block>
    </fo:table-cell>
  </xsl:template>

  <xsl:template match="thead">
    <fo:table-header border-bottom-width="0.25pt"
                     border-bottom-style="solid"
                     border-bottom-color="black"
                     font-weight="bold">
      <xsl:apply-templates/>
    </fo:table-header>
  </xsl:template>

  <xsl:template match="tr">
    <fo:table-row>
      <xsl:apply-templates/>
    </fo:table-row>
  </xsl:template>

  <xsl:template match="term">
    <fo:inline xsl:use-attribute-sets="b.style">
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <xsl:template match="termdef">
    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>

    <fo:inline id="{$id}">
      <xsl:text>[</xsl:text>
      <xsl:text>Definition</xsl:text>
      <xsl:text>: </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>]</xsl:text>
    </fo:inline>
  </xsl:template>

  <xsl:template match="termref">
    <fo:basic-link internal-destination="{@def}">
      <xsl:apply-templates/>
    </fo:basic-link>
  </xsl:template>

  <xsl:template match="titleref">
    <xsl:choose>
      <xsl:when test="@href">
        <fo:basic-link external-destination="url({@href})">
          <fo:inline xsl:use-attribute-sets="cite.style">
            <xsl:apply-templates/>
          </fo:inline>
        </fo:basic-link>
      </xsl:when>
      <xsl:otherwise>
        <fo:inline xsl:use-attribute-sets="cite.style">
          <xsl:apply-templates/>
        </fo:inline>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="ulist">
    <fo:list-block provisional-distance-between-starts="1.2em"
                   provisional-label-separation="0.2em">
      <xsl:apply-templates/>
    </fo:list-block>
  </xsl:template>

  <xsl:template match="olist">
    <fo:list-block provisional-distance-between-starts="1.2em"
                   provisional-label-separation="0.2em">
      <xsl:apply-templates/>
    </fo:list-block>
  </xsl:template>

  <xsl:template match="var">
    <fo:inline xsl:use-attribute-sets="var.style">
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <xsl:template match="vc">
    <xsl:choose>
      <xsl:when test="preceding-sibling::*[1][name()='rhs']">
        <fo:table-cell>
          <fo:block>
            <fo:basic-link internal-destination="{@def}">
              <xsl:text>[VC: </xsl:text>
              <xsl:apply-templates select="key('ids',@def)/head" mode="text"/>
              <xsl:text>]</xsl:text>
            </fo:basic-link>
          </fo:block>
        </fo:table-cell>
      </xsl:when>
      <xsl:otherwise>
        <fo:table-row>
          <fo:table-cell><fo:block/></fo:table-cell>
          <fo:table-cell><fo:block/></fo:table-cell>
          <fo:table-cell><fo:block/></fo:table-cell>
          <fo:table-cell>
            <fo:block>
              <fo:basic-link internal-destination="{@def}">
                <xsl:text>[VC: </xsl:text>
                <xsl:apply-templates select="key('ids',@def)/head" mode="text"/>
                <xsl:text>]</xsl:text>
              </fo:basic-link>
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="vcnote">
    <fo:block xsl:use-attribute-sets="constraint.style">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="wfc">
    <xsl:choose>
      <xsl:when test="preceding-sibling::*[1][name()='rhs']">
        <fo:table-cell>
          <fo:block>
            <fo:basic-link internal-destination="{@def}">
              <xsl:text>[WFC: </xsl:text>
              <xsl:apply-templates select="key('ids',@def)/head" mode="text"/>
              <xsl:text>]</xsl:text>
            </fo:basic-link>
          </fo:block>
        </fo:table-cell>
      </xsl:when>
      <xsl:otherwise>
        <fo:table-row>
          <fo:table-cell><fo:block/></fo:table-cell>
          <fo:table-cell><fo:block/></fo:table-cell>
          <fo:table-cell>
            <fo:block>
              <fo:basic-link internal-destination="{@def}">
                <xsl:text>[WFC: </xsl:text>
                <xsl:apply-templates select="key('ids',@def)/head" mode="text"/>
                <xsl:text>]</xsl:text>
              </fo:basic-link>
            </fo:block>
          </fo:table-cell>
        </fo:table-row>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="wfcnote">
    <fo:block xsl:use-attribute-sets="constraint.style">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <xsl:template match="xnt | xspecref | xtermref">
    <fo:basic-link external-destination="url({@href})">
      <xsl:apply-templates/>
    </fo:basic-link>
  </xsl:template>

  <!-- mode: divnum -->
  <xsl:template mode="divnum" match="div1">
    <xsl:number format="1 "/>
  </xsl:template>

  <xsl:template mode="divnum" match="back/div1 | inform-div1">
    <xsl:number count="div1 | inform-div1" format="A "/>
  </xsl:template>

  <xsl:template mode="divnum"
    match="front/div1 | front//div2 | front//div3 | front//div4 | front//div5"/>

  <xsl:template mode="divnum" match="div2">
    <xsl:number level="multiple" count="div1 | div2" format="1.1 "/>
  </xsl:template>

  <xsl:template mode="divnum" match="back//div2">
    <xsl:number level="multiple" count="div1 | div2 | inform-div1"
      format="A.1 "/>
  </xsl:template>

  <xsl:template mode="divnum" match="div3">
    <xsl:number level="multiple" count="div1 | div2 | div3"
      format="1.1.1 "/>
  </xsl:template>

  <xsl:template mode="divnum" match="back//div3">
    <xsl:number level="multiple"
      count="div1 | div2 | div3 | inform-div1" format="A.1.1 "/>
  </xsl:template>

  <xsl:template mode="divnum" match="div4">
    <xsl:number level="multiple" count="div1 | div2 | div3 | div4"
      format="1.1.1.1 "/>
  </xsl:template>

  <xsl:template mode="divnum" match="back//div4">
    <xsl:number level="multiple"
      count="div1 | div2 | div3 | div4 | inform-div1"
      format="A.1.1.1 "/>
  </xsl:template>

  <xsl:template mode="divnum" match="div5">
    <xsl:number level="multiple"
      count="div1 | div2 | div3 | div4 | div5" format="1.1.1.1.1 "/>
  </xsl:template>

  <xsl:template mode="divnum" match="back//div5">
    <xsl:number level="multiple"
      count="div1 | div2 | div3 | div4 | div5 | inform-div1"
      format="A.1.1.1.1 "/>
  </xsl:template>

  <!-- mode: number -->
  <xsl:template mode="number" match="prod">
    <xsl:text>[</xsl:text>
    <xsl:apply-templates select="." mode="number-simple"/>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <!-- mode: number-simple -->
  <xsl:template mode="number-simple" match="prod">
    <xsl:number level="any" count="prod[not(@diff='add')]"/>
  </xsl:template>

  <xsl:template mode="text" match="ednote | footnote"/>

  <!-- mode: toc -->
  <xsl:template name="toc.line">
    <xsl:param name="notation" select="''"/>
    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$fop = 0">
        <!-- do it "right" -->
        <fo:block text-align-last="justify"
                  end-indent="2pc"
                  last-line-end-indent="-2pc">
          <fo:inline keep-with-next.within-line="always">
            <xsl:apply-templates select="." mode="divnum"/>
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="head" mode="text"/>
            <xsl:if test="$notation != ''">
              <xsl:text> </xsl:text>
              <xsl:value-of select="$notation"/>
            </xsl:if>
          </fo:inline>
          <fo:inline keep-together.within-line="always">
            <xsl:text> </xsl:text>
            <fo:leader leader-pattern="dots"
                       keep-with-next.within-line="always"/>
            <xsl:text> </xsl:text>
            <fo:basic-link internal-destination="{$id}">
              <fo:page-number-citation ref-id="{$id}"/>
            </fo:basic-link>
          </fo:inline>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <!-- do it so FOP doesn't choke -->
        <fo:block>
          <fo:inline keep-with-next.within-line="always">
            <xsl:apply-templates select="." mode="divnum"/>
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="head" mode="text"/>
            <xsl:if test="$notation != ''">
              <xsl:text> </xsl:text>
              <xsl:value-of select="$notation"/>
            </xsl:if>
          </fo:inline>
          <fo:inline keep-together.within-line="always">
            <xsl:text>--</xsl:text>
            <fo:basic-link internal-destination="{$id}">
              <fo:page-number-citation ref-id="{$id}"/>
            </fo:basic-link>
          </fo:inline>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="toc" match="div1|div2|div3|div4|div5">
    <xsl:call-template name="toc.line"/>
    <xsl:if test="div2|div3|div4|div5">
      <fo:block start-indent="{(count(ancestor::*)-1)*2}pc">
        <xsl:apply-templates select="div2|div3|div4|div5" mode="toc"/>
      </fo:block>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="toc" match="inform-div1">
    <xsl:call-template name="toc.line">
      <xsl:with-param name="notation" select="'(Non-Normative)'"/>
    </xsl:call-template>
    <xsl:if test="div2">
      <fo:block start-indent="{count(ancestor::*)*2}pc">
        <xsl:apply-templates select="div2" mode="toc"/>
      </fo:block>
    </xsl:if>
  </xsl:template>

</xsl:transform>
