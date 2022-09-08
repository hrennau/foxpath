<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" 
   xmlns:df="http://dita2indesign.org/dita/functions"
   exclude-result-prefixes="xs df">

   <!-- Unit tests for the dita_tidy.xsl function library 
  
       To run this either give it any XML document (such as this XSLT document)
       as input or specify the template "run-all-tests" as the initial
       template to run.
       
       The test results are written to the primary result document.
  
  -->
   <xsl:import href="../xsl/dita_tidy.xsl"/>
   <xsl:import href="../xsl/dita-support-lib.xsl"/>
   <xsl:import href="../xsl/relpath_util.xsl"/>
   <xsl:output method="xml" indent="yes"/>

   <xsl:template name="run-all-tests" match="/">
      <xsl:variable name="test-data" as="element()">
         <concept id="test-mixed-concept" class="- topic/topic concept/concept ">
            <title class="- topic/title ">Test topic</title>
            <shortdesc class="- topic/shortdesc ">This topic is mixed.</shortdesc>
            <conbody class="- topic/body concept/conbody ">
               <note product="product1" class="- topic/note ">Raw text.<p class="- topic/p ">Test paragraph for
                  testing.</p><i class="+ topic/ph hi-d/i ">Look!</i> More raw text. Here is more <b
                  class="+ topic/ph hi-d/b ">mixed</b> content.</note>
               <section product="product1" class="- topic/section">
                  <title class="- topic/title ">Section title</title>
                  <p class="- topic/p ">This is an authored paragraph.</p>
                  <b class="+ topic/ph hi-d/b ">Subtitle through tag abuse</b>
                  <p class="- topic/p ">This is an authored paragraph.</p>
               </section>
            </conbody>
         </concept>
      </xsl:variable>
      <test-results>
         <xsl:call-template name="testMixedContent">
            <xsl:with-param name="test-data" select="$test-data"/>
         </xsl:call-template>
      </test-results>
   </xsl:template>

   <xsl:template name="testMixedContent">
      <xsl:param name="test-data" required="yes"/>
      <!--<xsl:apply-templates select="$test-data"/>-->
      <xsl:variable name="processed-test-data">
         <xsl:apply-templates select="$test-data"/>
      </xsl:variable>

      <xsl:variable name="tests" as="node()">
         <testcase name="wrapMixed tests">
            <!-- test-data contains three authored <p> elements and three node-sets of contiguous
            text and inlines. When these text-inline node-sets have been wrapped there should
            be three new <p> elements for a total of six <p> elements. -->
            <test name="wrapMixed 1" pass="{count($processed-test-data//p) = 6}">6 paragraphs</test>
         </testcase>
      </xsl:variable>
      <xsl:if test="$tests/test[@pass = 'false']">
         <failures name="ts:isInline tests">
            <xsl:apply-templates select="$tests"/>
         </failures>
      </xsl:if>
      <xsl:sequence select="$tests"/>
   </xsl:template>

   <xsl:template match="testcase">
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="test[@pass = 'false']">
      <fail name="{@name}">
         <xsl:apply-templates/>
      </fail>
   </xsl:template>

   <xsl:template match="test[@pass = 'true']"/>


</xsl:stylesheet>
