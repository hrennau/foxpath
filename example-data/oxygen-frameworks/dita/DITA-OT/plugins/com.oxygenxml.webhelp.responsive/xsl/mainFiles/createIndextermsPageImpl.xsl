<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc"
  xmlns:index="http://www.oxygenxml.com/ns/webhelp/index" 
  xmlns:File="java:java.io.File"
  xmlns:oxygen="http://www.oxygenxml.com/functions" xmlns:d="http://docbook.org/ns/docbook"
  xmlns:whc="http://www.oxygenxml.com/webhelp/components" xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
  
  <!-- Used to expand common WebHelp components like menu -->
  <xsl:import href="../template/commonComponentsExpander.xsl"/>
  <xsl:import href="../util/macroExpander.xsl"/>
  
  <!-- Localization of text strings displayed in Webhelp output. -->
  <xsl:import href="../util/dita-utilities.xsl"/> 
  <xsl:import href="../util/functions.xsl"/>
  
  <!-- XSLT library to work with paths -->
  <xsl:import href="../util/relpath_util.xsl"/>  
  <xsl:import href="../util/fixupNS.xsl"/>
  
  <!-- Declares all available parameters -->
  <xsl:include href="params.xsl"/>
  
  <xsl:output 
    method="xhtml" 
    encoding="UTF-8"
    indent="no"
    doctype-public=""
    doctype-system="about:legacy-compat"
    omit-xml-declaration="yes"/>
  
  <!-- EXM-36947 Used to translate katakana chars to hiragana when grouping index terms. -->
  <!-- アカサタナハマヤラワイキシチニヒミリヰウクスツヌフムユルエケセテネヘメレヱオコソトノホモヨロヲ -->
  <xsl:variable 
    name="katakana_chars"
    select="'&#12450;&#12459;&#12469;&#12479;&#12490;&#12495;&#12510;&#12516;&#12521;&#12527;&#12452;&#12461;&#12471;&#12481;&#12491;&#12498;&#12511;&#12522;&#12528;&#12454;&#12463;&#12473;&#12484;&#12492;&#12501;&#12512;&#12518;&#12523;&#12456;&#12465;&#12475;&#12486;&#12493;&#12504;&#12513;&#12524;&#12529;&#12458;&#12467;&#12477;&#12488;&#12494;&#12507;&#12514;&#12520;&#12525;&#12530;'"/>
  
  <!-- あかさたなはまやらわいきしちにひみりゐうくすつぬふむゆるえけせてねへめれゑおこそとのほもよろを -->
  <xsl:variable 
    name="hiragana_chars"
    select="'&#12354;&#12363;&#12373;&#12383;&#12394;&#12399;&#12414;&#12420;&#12425;&#12431;&#12356;&#12365;&#12375;&#12385;&#12395;&#12402;&#12415;&#12426;&#12432;&#12358;&#12367;&#12377;&#12388;&#12396;&#12405;&#12416;&#12422;&#12427;&#12360;&#12369;&#12379;&#12390;&#12397;&#12408;&#12417;&#12428;&#12433;&#12362;&#12371;&#12381;&#12392;&#12398;&#12411;&#12418;&#12424;&#12429;&#12434;'"/>  
  
  <!-- Loads the additional XML documents. -->
  <xsl:variable name="index" select="document(oxygen:makeURL($INDEX_XML_FILEPATH))/index:index"/>    
  <xsl:variable name="toc" select="document(oxygen:makeURL($TOC_XML_FILEPATH))/toc:toc"/>
  
  <!--
    A temporary node used to keep @lang and @dir attributes.
  -->
  
  <xsl:variable name="webhelp_language" select="oxygen:getParameter('webhelp.language')"/>
  
  <xsl:variable name="i18n_context">
    <i18n_context>
      <xsl:attribute name="xml:lang" select="$webhelp_language"/>
      <xsl:attribute name="lang" select="$webhelp_language"/>
      <xsl:attribute name="dir" select="oxygen:getParameter('webhelp.page.direction')"/>
    </i18n_context>
  </xsl:variable>
  
  <!-- 
    Creates the index terms file using the given template.
  -->
  <xsl:template match="/">
    <!-- Expand the components index terms template -->    
    <xsl:apply-templates mode="copy_template">
      <!-- EXM-36737 - Context node used for messages localization -->
      <xsl:with-param name="i18n_context" select="$i18n_context/*" tunnel="yes" as="element()"/>                
    </xsl:apply-templates>
    
  </xsl:template>

  <!-- 
    Generate the index terms grouped by the first letter.
  -->
  <xsl:template match="index:index" mode="create-index">
    
    <!-- EXM-36947 - Use a collation to support multi language sort -->
    <xsl:variable 
      name="collation" 
      select="
      concat(
      'http://saxon.sf.net/collation?alphanumeric=yes;normalization=yes;ignore-case=yes;lang=', 
      $webhelp_language)"/>
    
    <!-- 
      Generates the list of the letters from terms list 
      EXM-37491
    -->
    <ul class="wh-letters">      
      <xsl:for-each-group select="index:term" group-by="
        upper-case(
        translate(
        substring(
        normalize-unicode(@sort-as, 'NFD'), 1, 1), $katakana_chars, $hiragana_chars))" 
        collation="{$collation}">
        <xsl:sort select="current-grouping-key()" collation="{$collation}"/>
      <!-- Output the first letter -->
        <li>
          <a href="#whletter_{escape-html-uri(lower-case(current-grouping-key()))}">
            <xsl:value-of select="current-grouping-key()"/>
          </a>
        </li>
      </xsl:for-each-group>
    </ul>
    
    <ul id="indexList">
      <xsl:for-each-group select="index:term" group-by="
        upper-case(
        translate(
        substring(
        normalize-unicode(@sort-as, 'NFD'), 1, 1), $katakana_chars, $hiragana_chars))" 
        collation="{$collation}">
        <xsl:sort select="current-grouping-key()" collation="{$collation}"/>
        <!-- Output the first letter -->
        <li class="wh_term_group" id="whletter_{escape-html-uri(lower-case(current-grouping-key()))}">
        <span class="wh_first_letter"><xsl:value-of 
          select="current-grouping-key()"/></span>
        <ul>
          <!-- Iterates over the current group and output its items -->
          <xsl:apply-templates select="current-group()" mode="#current">
            <xsl:sort select="@sort-as" collation="{$collation}"/>
            <xsl:with-param name="collation" select="$collation"/>
          </xsl:apply-templates>
        </ul>
      </li>
    </xsl:for-each-group>
    </ul>
  </xsl:template>
  <!--
    Template used to generate indexterms
  -->
  <xsl:template match="whc:webhelp_index_terms" mode="copy_template">
    <div>
      <xsl:call-template name="generateComponentClassAttribute">
        <xsl:with-param name="compClass">wh_index_terms</xsl:with-param>
      </xsl:call-template>
      <xsl:copy-of select="@* except @class"/>
      <xsl:if test="count($index/*) > 0">
        <xsl:variable name="compContent">
          <div id="iList">
            <xsl:variable name="indexterms">
              <xsl:apply-templates select="$index" mode="create-index"/>
            </xsl:variable>
            <!--<xsl:copy-of select="$indexterms"/>-->
            <xsl:apply-templates select="$indexterms" mode="fixup_XHTML_NS"/>
          </div>
        </xsl:variable>
        
        <xsl:call-template name="outputComponentContent">
          <xsl:with-param name="compContent" select="$compContent"/>
          <xsl:with-param name="compName" select="local-name()"/>
        </xsl:call-template>
      </xsl:if>
    </div>
  </xsl:template>
  
  <!-- 
    Generates a list item for each index term.
  -->  
  <xsl:template match="index:term" mode="create-index">
    <!-- EXM-36947 - Use a collation to support multi language sort -->
    <xsl:param name="collation"/>
    <li class="wh_term">
      <span><xsl:value-of select="@name"/></span>
      <!-- Generate links for each target -->
      <xsl:for-each select="index:target">
        <a class="wh_term_target" href="{.}">[<xsl:value-of select="position()"/>]</a>
      </xsl:for-each>
      
      <!-- Handle nested index terms -->
      <xsl:if test="count(index:term) > 0">      
        <ul>
          <xsl:apply-templates mode="#current" select="index:term">
            <xsl:sort select="@sort-as" collation="{$collation}"/>
            <xsl:with-param name="collation" select="$collation"/>
          </xsl:apply-templates>
        </ul>
      </xsl:if>
    </li>
  </xsl:template>
</xsl:stylesheet>