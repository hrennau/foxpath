<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" 
   xmlns:df="http://dita2indesign.org/dita/functions"
   exclude-result-prefixes="xs df">

   <!-- Unit tests for the dita_tidy_utils.xsl function library 
  
       To run this either give it any XML document (such as this XSLT document)
       as input or specify the template "run-all-tests" as the initial
       template to run.
       
       The test results are written to the primary result document.
  
  -->
   <xsl:include href="../xsl/dita-support-lib.xsl"/>
   <xsl:include href="../xsl/relpath_util.xsl"/>
   <xsl:output method="xml" indent="yes"/>


   <xsl:template match="/" name="run-all-tests">
      <xsl:variable name="test-data" as="element()">
         <test_data>
            <li class="- topic/li "/>
            <p class="- topic/p "/>
            <prereq class="- topic/section task/prereq "/>
            <section class="- topic/section "/>
            <tm tmtype="reg" class="- topic/tm "/>
            <uicontrol class="+ topic/ph ui-d/uicontrol "/>
         </test_data>
      </xsl:variable>
      <test-results>
         <xsl:call-template name="testIsInline">
            <xsl:with-param name="test-data" select="$test-data"/>
         </xsl:call-template>
         <xsl:call-template name="testIsWrapMixed">
            <xsl:with-param name="test-data" select="$test-data"/>
         </xsl:call-template>
      </test-results>
   </xsl:template>

   <xsl:template name="testIsInline">
      <xsl:param name="test-data" required="yes"/>
      <xsl:variable name="tests" as="node()">
         <testcase name="df:isInline tests">
            <test name="df:isInline 1" pass="{not(df:isInline($test-data/li))}">not li</test>
            <test name="df:isInline 2" pass="{not(df:isInline($test-data/p))}">not p</test>
            <test name="df:isInline 3" pass="{not(df:isInline($test-data/prereq))}">not prereq</test>
            <test name="df:isInline 4" pass="{not(df:isInline($test-data/section))}">not section</test>
            <test name="df:isInline 5" pass="{df:isInline($test-data/tm)}">tm</test>
            <test name="df:isInline 6" pass="{df:isInline($test-data/uicontrol)}">uicontrol</test>
         </testcase>
      </xsl:variable>
      <xsl:if test="$tests/test[@pass = 'false']">
         <failures name="df:isInline tests">
            <xsl:apply-templates select="$tests"/>
         </failures>
      </xsl:if>
      <xsl:sequence select="$tests"/>
   </xsl:template>
   
   <xsl:template name="testIsWrapMixed">
      <xsl:param name="test-data" required="yes"/>
      <xsl:variable name="tests" as="node()">
         <testcase name="df:isWrapMixed tests">
            <test name="df:isWrapMixed 1" pass="{df:isWrapMixed($test-data/li)}">li</test>
            <test name="df:isWrapMixed 2" pass="{not(df:isWrapMixed($test-data/p))}">not p</test>
            <test name="df:isWrapMixed 3" pass="{df:isWrapMixed($test-data/prereq)}">prereq</test>
            <test name="df:isWrapMixed 4" pass="{df:isWrapMixed($test-data/section)}">section</test>
            <test name="df:isWrapMixed 5" pass="{not(df:isWrapMixed($test-data/tm))}">not tm</test>
            <test name="df:isWrapMixed 6" pass="{not(df:isWrapMixed($test-data/uicontrol))}">not uicontrol</test>
         </testcase>
      </xsl:variable>
      <xsl:if test="$tests/test[@pass = 'false']">
         <failures name="df:isWrapMixed tests">
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
   
   
   <xsl:template match="test[@pass = 'true']">
   </xsl:template>


</xsl:stylesheet>
