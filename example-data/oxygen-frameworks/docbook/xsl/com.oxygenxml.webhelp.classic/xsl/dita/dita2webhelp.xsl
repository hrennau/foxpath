<?xml version="1.0" encoding="UTF-8" ?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:File="java:java.io.File" 
  xmlns:oxygen="http://www.oxygenxml.com/functions"
  exclude-result-prefixes="File oxygen">

  <xsl:import href="plugin:org.dita.xhtml:xsl/dita2xhtml.xsl"/>
  <xsl:import href="rel-links.xsl"/>
  <xsl:import href="../functions.xsl"/>
  <xsl:import href="../localization.xsl"/>
  <xsl:import href="dita-utilities.xsl"/>
  <xsl:import href="dita_common.xsl"/>
  
  <xsl:param name="CUSTOM_RATE_PAGE_URL" select="''"/>
  <xsl:param name="WEBHELP_FOOTER_INCLUDE" select="'yes'"/>
  <xsl:param name="WEBHELP_FOOTER_FILE" select="''"/>
  <xsl:param name="WEBHELP_TRIAL_LICENSE" select="'no'"/>
  <xsl:param name="WEBHELP_SKIN_CSS" select="''"/>
  <xsl:param name="WEBHELP_PRODUCT_ID" select="''"/>
  <xsl:param name="WEBHELP_PRODUCT_VERSION" select="''"/>
  
  <xsl:param name="BASEDIR"/>
  <xsl:param name="OUTPUTDIR"/>
  <xsl:param name="LANGUAGE" select="'en-us'"/>
  
  <xsl:output 
            method="xhtml" 
            encoding="UTF-8"
            indent="no"
            doctype-public=""
            doctype-system="about:legacy-compat"
            omit-xml-declaration="yes"/>


  <!-- Transforms oXygen change tracking and review elements to html elements. -->
  <xsl:include href="../review/review-elements-to-html.xsl"/>
  
  <!--  Header navigation.  -->
  <xsl:template match="/|node()|@*" mode="gen-user-header">
    <table class="nav">
      <tbody>
        <tr>
          <td colspan="2">
            <!-- Print link. --> 	 
            <xsl:variable name="printLinkText"> 	 
              <xsl:call-template name="getWebhelpString">
                <xsl:with-param name="stringName" select="'printThisPage'"/> 	 
              </xsl:call-template> 	 
            </xsl:variable> 	 
            <div id="printlink"> 	 
              <a href="javascript:window.print();" title="{$printLinkText}"></a> 	 
            </div>
            <!-- Permanent link. -->            
            <xsl:variable name="permaLinkText">
              <xsl:call-template name="getWebhelpString">
                <xsl:with-param name="stringName" select="'linkToThis'"/>
              </xsl:call-template>
            </xsl:variable>
            <div id="permalink"><a href="#" title="{$permaLinkText}"></a>              
            </div>
          </td>
        </tr>
        <tr>
          <td style="width:75%;">
            <span class="topic_breadcrumb_links">
              <xsl:if test="count(distinct-values(descendant::*[contains(@class, ' topic/link ')][@role='parent']/@href)) = 1">
                <!-- Bread-crumb -->
                <xsl:variable name="parentRelativePath" 
                  select="descendant::*[contains(@class, ' topic/link ')][@role='parent'][1]/@href"/>
                <xsl:variable name="parentTopic" 
                  select="document($parentRelativePath)"/>
                <xsl:if test="count(distinct-values($parentTopic//*[contains(@class, ' topic/link ')][@role='parent']/@href)) = 1">            
                  <!-- Link to parent of parent. -->
                  <xsl:variable name="parentOfParentTopic" select="($parentTopic//*[contains(@class, ' topic/link ')][@role='parent'])[1]"/>
                  <xsl:for-each select="$parentOfParentTopic">
                    <span class="topic_breadcrumb_link">
                      <xsl:call-template name="makelink">
                        <xsl:with-param name="final-path"
                          tunnel="yes"
                          select="oxygen:combineRelativePaths($parentRelativePath, @href)"
                        />
                      </xsl:call-template>
                    </span>
                  </xsl:for-each>
                </xsl:if>
                <!-- Link to parent. -->
                <xsl:for-each select="(descendant::*[contains(@class, ' topic/link ')][@role='parent'])[1]">
                  <span class="topic_breadcrumb_link">
                    <xsl:call-template name="makelink"/>
                  </span>
                </xsl:for-each>
              </xsl:if>
            </span>
          </td>
          <td>
            <!-- Navigation to the next, previous siblings and to the parent. -->
            <span id="topic_navigation_links" class="navheader">              
              <xsl:call-template name="oxygenCustomHeaderAndFooter"/>
            </span>
          </td>        
        </tr>
      </tbody>
    </table>
  </xsl:template>
  
  
  <!--  Adds topic rating and navigation to the footer.  -->  
  <xsl:template match="/|node()|@*" mode="gen-user-footer">
    <div class="navfooter">
      <xsl:comment/>
      <xsl:call-template name="oxygenCustomHeaderAndFooter"/>
    </div>
    <xsl:if test="string-length($CUSTOM_RATE_PAGE_URL) > 0">
      <noscript>.rate_page{display:none}</noscript>
      <div class="rate_page">
        <div id="rate_stars">
          <span><b>Rate this page</b>:</span> 
          <ul class="stars">
            <li><a href="#rate_stars" id="star1" onclick='setRate(this.id, this.title);' title="Not helpful"><xsl:comment/></a></li>
            <li><a href="#rate_stars" id="star2" onclick='setRate(this.id, this.title);' title="Somewhat helpful" class=""><xsl:comment/></a></li>
            <li><a href="#rate_stars" id="star3" onclick='setRate(this.id, this.title);' title="Helpful" class=""><xsl:comment/></a></li>
            <li><a href="#rate_stars" id="star4" onclick='setRate(this.id, this.title);' title="Very helpful" class=""><xsl:comment/></a></li>
            <li><a href="#rate_stars" id="star5" onclick='setRate(this.id, this.title);' title="Solved my problem" class=""><xsl:comment/></a></li>
          </ul>
        </div>
        <div id="rate_comment" class="hide">
          <span class="small">Optional Comment:</span><br/>
          <form name="contact" method="post" action="" enctype="multipart/form-data">
            <textarea rows='2' cols='20' name="feedback" id="feedback" class="text-input"><xsl:text> </xsl:text></textarea><br/>
            <input type="submit" name="submit" class="button" id="submit_btn" value="Send feedback" />
          </form>
        </div>
      </div>
    </xsl:if>
      
    <xsl:call-template name="generateWebhelpFooter"/>
  </xsl:template>
  
  <!--  Template for header and footer common navigation.  -->
  <xsl:template name="oxygenCustomHeaderAndFooter">
    <xsl:if test="$NOPARENTLINK = 'no'">
      <xsl:for-each
        select="descendant::*[contains(@class, ' topic/link ')]
        [@role='parent' or @role='previous' or @role='next']">
        <xsl:text>&#10;</xsl:text>
        <xsl:variable name="cls">
          <xsl:choose>
            <xsl:when test="@role = 'parent'">
              <xsl:text>navparent</xsl:text>
            </xsl:when>
            <xsl:when test="@role = 'previous'">
              <xsl:text>navprev</xsl:text>
            </xsl:when>
            <xsl:when test="@role = 'next'">
              <xsl:text>navnext</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>nonav</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <span>
          <xsl:attribute name="class">
            <xsl:value-of select="$cls"/>
          </xsl:attribute>
          <xsl:variable name="textLinkBefore">
            <span class="navheader_label">
              <xsl:choose>
                <xsl:when test="@role = 'parent'">
                  <xsl:call-template name="getWebhelpString">
                    <xsl:with-param name="stringName" select="'Parent topic'"/>
                  </xsl:call-template>
                </xsl:when>
                <xsl:when test="@role = 'previous'">
                  <xsl:call-template name="getWebhelpString">
                    <xsl:with-param name="stringName" select="'Previous topic'"/>
                  </xsl:call-template>
                </xsl:when>
                <xsl:when test="@role = 'next'">
                  <xsl:call-template name="getWebhelpString">
                    <xsl:with-param name="stringName" select="'Next topic'"/>
                  </xsl:call-template>
                </xsl:when>
              </xsl:choose>
            </span>
            <span class="navheader_separator">
              <xsl:text>: </xsl:text>
            </span>
          </xsl:variable>
          <xsl:call-template name="makelink">
            <xsl:with-param name="label" select="$textLinkBefore"/>
          </xsl:call-template>
        </span>
        <xsl:text>  </xsl:text>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>
  
  
  <!--  Finds all index terms and adds them to the meta element 'indexterms'. (EXM-20576)  -->
    <xsl:template match="*" mode="gen-keywords-metadata">
      <xsl:variable name="indexterms-content">
          <xsl:for-each select="descendant::*[contains(@class,' topic/keywords ')]//*[contains(@class,' topic/indexterm ')]">
              <xsl:value-of select="normalize-space(text()[1])"/>
              <xsl:if test="position() &lt; last()"><xsl:text>, </xsl:text></xsl:if>
          </xsl:for-each>
      </xsl:variable>
      <xsl:if test="string-length($indexterms-content)>0">
          <meta name="indexterms" content="{$indexterms-content}"/>
          <xsl:value-of select="$newline"/>
      </xsl:if>
      <xsl:apply-imports/>
  </xsl:template>
  
  
  <xsl:function name="oxygen:combineRelativePaths" as="item()">
    <xsl:param name="relativePath1" as="item()"/>
    <xsl:param name="relativePath2" as="item()"/>
      <xsl:variable name="baseFolder" select="string-join(tokenize($relativePath1, '/')[position() &lt; last()], '/')"/>
    <xsl:variable name="result" 
        select="if (string-length($baseFolder) > 0) then concat($baseFolder, '/', $relativePath2) else $relativePath2"/>
    <xsl:value-of select="$result"/>
  </xsl:function>
  
  
  <!-- EXM-31518 Generate something for learning and training lcTime -->
  <xsl:template match="*[contains(@class, ' learningBase/lcTime ')]">
    <span>
      <xsl:call-template name="commonattributes"/>
      <b>Time: </b>
      <xsl:choose>
        <xsl:when test="empty(node())">
          <xsl:value-of select="@value"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>
  
  <!--EXM-32868 Allow data- attributes to pass through -->
  <xsl:template match="@*[starts-with(name(), 'data-')]" mode="add-xhtml-ns" priority="20">
    <xsl:copy/>
  </xsl:template>
  
  
  <!-- EXM-31128 - Filter the related links in this mode. They will be copied at the end. -->
  <xsl:template match="*[contains(@class, ' topic/related-links ')]" mode="move-related-links"/>
  
  <!-- EXM-31128 - Move the related links at the topic end -->  
  <xsl:template match="*[contains(@class, ' topic/topic ')]" mode="move-related-links">
    <xsl:param name="base"/>
    <xsl:copy>
      <xsl:if test="not($base = '')">
        <xsl:attribute name="xml:base" select="$base"/>
      </xsl:if>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
      <xsl:copy-of select="*[contains(@class, ' topic/related-links ')]"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- EXM-31128 - Copy template for 'move-related-links' mode -->
  <xsl:template match="node() | @*" mode="move-related-links">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:variable name="moveRelatedLinks" select="false()"/>
  
  <xsl:template match="/">
    <!-- 
      Move related links improvement is enabled only in the Webhelp Classic. 
      For Responsive variant we have another mechanism that applies over HTML content 
    -->
      <xsl:variable 
        name="topicWithRelatedLinks" 
        select="*[contains(@class, ' topic/topic ')][*[contains(@class, ' topic/related-links ')]]"/>
      
      <xsl:choose>
        <!-- EXM-31128 - Move the related links at the topic end when it does not have nested topics with related links. -->
        <xsl:when test="
        $moveRelatedLinks and
        $topicWithRelatedLinks and 
        empty($topicWithRelatedLinks/child::*[contains(@class, ' topic/topic ')]/*[contains(@class, ' topic/related-links ')])">
          
          <xsl:variable name="filterTopic">
            <xsl:apply-templates mode="move-related-links" select="$topicWithRelatedLinks">
              <xsl:with-param name="base" select="base-uri()"/>
            </xsl:apply-templates>
          </xsl:variable>
          
          <xsl:apply-templates select="$filterTopic/*"/>        
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>    
        </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
  
  
  <!-- the path back to the project. Used for c.gif, delta.gif, css to allow user's to have
     these files in 1 location. -->
  <xsl:param name="PATH2PROJ">
    <!-- OXYGEN PATCH START  EXM-30937 -->
    <xsl:choose>
      <xsl:when test="/processing-instruction('path2project-uri')">        
        <xsl:apply-templates select="/processing-instruction('path2project-uri')[1]" mode="get-path2project"/>
      </xsl:when>
      <xsl:when test="/processing-instruction('path2project')">
        <xsl:apply-templates select="/processing-instruction('path2project')[1]" mode="get-path2project"/>
      </xsl:when>
    </xsl:choose>
    <!-- OXYGEN PATCH END  EXM-30937 -->
  </xsl:param>
  
</xsl:stylesheet>
