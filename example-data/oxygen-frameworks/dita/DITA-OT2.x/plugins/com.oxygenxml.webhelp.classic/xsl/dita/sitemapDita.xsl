<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
            xmlns:oxygen="http://www.oxygenxml.com/functions"
            exclude-result-prefixes="oxygen"
            version="2.0">
    
    <xsl:import href="dita-utilities.xsl"/>
    
    <!-- Extension of DITA output files for example .html -->
    <xsl:param name="OUT_EXT" select="'.html'"/>
    
    <!-- Base URL that is the prefix of any relative path from href attribute. -->
    <xsl:param name="WEBHELP_BASE_URL" select="''"/>
    
    <!-- Date of last modification - the same for every Webhelp page. -->
    <xsl:param name="WEBHELP_LAST_MODIFIED" select="''"/>
    
    <!-- Change frequency of Webhelp pages, for example: "weekly", "monthly", etc. -->
    <xsl:param name="WEBHELP_CHANGE_FREQUENCY" select="''"/>
    
    <!-- WEBHELP_PRIORITY of page in the website - teh same for every Webhelp page. -->
    <xsl:param name="WEBHELP_PRIORITY" select="''"/>
  
    <xsl:output method="xml" indent="yes"/>

    <xsl:key name="kTopicHrefs" 
                match="*[contains(@class, ' map/topicref ')]
                        [@href]
                        [not(@scope) or @scope = 'local']
                        [not(@processing-role) or @processing-role = 'normal']
                        [not(@format) or @format = 'dita' or @format = 'DITA']" 
                use="@href"/>
    
    
    <xsl:template match="/">
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            <xsl:apply-templates/>
        </urlset>
    </xsl:template>
    

    <xsl:template match="*[contains(@class, ' map/topicref ')]">
      <xsl:if test="@href and (not(@scope) or @scope = 'local')
                    and (not(@processing-role) or @processing-role = 'normal')
                    and (not(@format) or @format = 'dita' or @format = 'DITA')">
          <xsl:if test="generate-id(key('kTopicHrefs', @href)[1]) = generate-id()">
              <xsl:variable name="relativePath">
                  <xsl:call-template name="replace-extension">
                      <xsl:with-param name="filename" select="@href"/>
                      <xsl:with-param name="extension" select="$OUT_EXT"/>
                  </xsl:call-template>
              </xsl:variable>
              <url xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
                  <loc><xsl:value-of select="concat($WEBHELP_BASE_URL, $relativePath)"/></loc>
                  <lastmod><xsl:value-of select="$WEBHELP_LAST_MODIFIED"/></lastmod>
                  <xsl:if test="string-length($WEBHELP_CHANGE_FREQUENCY) > 0">
                      <changefreq><xsl:value-of select="$WEBHELP_CHANGE_FREQUENCY"/></changefreq>
                  </xsl:if>
                  <xsl:if test="string-length($WEBHELP_PRIORITY) > 0">
                      <priority><xsl:value-of select="$WEBHELP_PRIORITY"/></priority>
                  </xsl:if>
              </url>
          </xsl:if>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:template>


  <xsl:template match="text()"/>
</xsl:stylesheet>