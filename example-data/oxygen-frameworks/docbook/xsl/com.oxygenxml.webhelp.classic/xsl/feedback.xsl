<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<!-- 
  Infrastructure for the feedback/comments. 
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            version="2.0">
  <xsl:template name="generateFeedbackDiv">
    
    <xsl:if test="string-length($WEBHELP_PRODUCT_ID) > 0">
      <xsl:variable name="formDivs" as="element()*">
        <div id="cmts"><xsl:comment/></div>
        <script type="text/javascript" src="{$PATH2PROJ}oxygen-webhelp/resources/js/parseuri.js?buildId={$WEBHELP_BUILD_NUMBER}"><!--  --></script>
        <script type="text/javascript" src="{$PATH2PROJ}oxygen-webhelp/feedback/config/config.js?buildId={$WEBHELP_BUILD_NUMBER}"><!--  --></script>
        <script type="text/javascript" src="{$PATH2PROJ}oxygen-webhelp/feedback/resources/js/init.js?buildId={$WEBHELP_BUILD_NUMBER}"><!--  --></script>
        <script type="text/javascript">
          function showCommentsFor(page) {
            init(page, $('#cmts'));
          
            return false;
          }
          
          var pageLocation = window.location.href;
          try {
            var p = parseUri(pageLocation);
            showCommentsFor(p.path);
          } catch (e) {
            debug(e);
          }
        </script>
      </xsl:variable>
      <!-- Sometimes the html root has a namespace and sometimes it does not. Output the divs accordingly. -->
      <xsl:apply-templates select="$formDivs" mode="fixXHTMLNS">
        <xsl:with-param name="ns" select="namespace-uri(/*)"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="node()|@*" mode="fixXHTMLNS">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="*" mode="fixXHTMLNS" priority="100">
    <xsl:param name="ns"/>
    <xsl:element name="{name()}" namespace="{$ns}">
      <xsl:apply-templates select="node()|@*" mode="fixXHTMLNS">
        <xsl:with-param name="ns" select="$ns"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>    
