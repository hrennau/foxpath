<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0" xmlns="http://www.w3.org/1999/xhtml" 
  xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xhtml">

  <xsl:import href="../../common-mobile.xsl"/>
  <xsl:include href="fixup_href.xsl"/>
  
  <xsl:include href="../../macroExpander.xsl"/>


    <xsl:template name="customBodyScriptMobile">
        <!-- Custom JavaScript code set by param webhelp.body.script -->
        <xsl:if test="string-length($WEBHELP_BODY_SCRIPT) > 0">
          <xsl:call-template name="includeCustomHTMLContent">
            <xsl:with-param name="hrefURL" select="$WEBHELP_BODY_SCRIPT"/>
          </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    
    <xsl:template name="customHeadScriptMobile">
        <!-- Custom JavaScript code set by param webhelp.head.script -->
        <xsl:if test="string-length($WEBHELP_HEAD_SCRIPT) > 0" >
          <xsl:call-template name="includeCustomHTMLContent">
            <xsl:with-param name="hrefURL" select="$WEBHELP_HEAD_SCRIPT"/>
          </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    
  <!--
        Transforms the single H1 into a header, or:
        Puts a header before the first H1, if there is a sequence of H1s in the document.
    -->
  <xsl:template match="*:h1[contains(@class,'topictitle1')][count(//*:h1) = 1]" mode="fixup_mobile">
    <div data-role="header" data-position="fixed" data-theme="c">
      <xsl:copy>
        <xsl:attribute name="class">pageHeader</xsl:attribute>
        <xsl:apply-templates mode="fixup_mobile"/>
      </xsl:copy>
      <xsl:call-template name="generateNavigationLinks"/>
    </div>
  </xsl:template>
  
  <xsl:template
      match="*:h1[contains(@class,'topictitle1')][count(preceding::*:h1) = 0][count(following::*:h1) > 0]"
    mode="fixup_mobile">
    <div data-role="header" data-position="fixed" data-theme="c">
      <h1>
        <xsl:attribute name="class">pageHeader</xsl:attribute><xsl:comment/></h1>
      <xsl:call-template name="generateNavigationLinks"/>
    </div>
    <xsl:copy-of select="."/>
  </xsl:template>
  
   <xsl:template name="generateHeadContent">
    <xsl:apply-templates 
      select="*[not(local-name() = 'link' 
      and @rel='stylesheet' 
      and not(contains(@href, 'commonltr.css'))
      and not(contains(@href, 'commonrtl.css')))]" 
      mode="fixup_mobile"/>
    <xsl:call-template name="jsAndCSS">
      <xsl:with-param name="namespace" select="namespace-uri(/*)"/>
    </xsl:call-template>
  </xsl:template>
  
  <!-- 
    Divert the commonltr.css from the standard DITA-OT location to our resources folder.  
  -->
  <xsl:template match="*:link[ends-with(@href, 'commonltr.css')]" mode="fixup_mobile">
    <xsl:element name="link" namespace="{namespace-uri()}">
      <xsl:attribute name="rel">stylesheet</xsl:attribute>
      <xsl:attribute name="type">text/css</xsl:attribute>
      <xsl:attribute name="href"><xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/css/commonltr.css?buildId=', $WEBHELP_BUILD_NUMBER)"/></xsl:attribute>
      <xsl:comment/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="*:link[ends-with(@href, 'commonrtl.css')]" mode="fixup_mobile">
    <xsl:element name="link" namespace="{namespace-uri()}">
      <xsl:attribute name="rel">stylesheet</xsl:attribute>
      <xsl:attribute name="type">text/css</xsl:attribute>
      <xsl:attribute name="href"><xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/css/commonrtl.css?buildId=', $WEBHELP_BUILD_NUMBER)"/></xsl:attribute>
      <xsl:comment/>
    </xsl:element>
  </xsl:template>
  
    <xsl:template name="generateNavigationLinks" 
        xmlns:xhtml="http://www.w3.org/1999/xhtml">
        <xsl:variable name="up" select="(//*[@class='navparent']/*:a/@href)[1]"/>
        <xsl:variable name="prev" select="(//*[@class='navprev']/*:a/@href)[1]"/>
        <xsl:variable name="next" select="(//*[@class='navnext']/*:a/@href)[1]"/>
      <div class="ui-btn-left">
          <a href="{$PATH2PROJ}index.html" data-role="button" title="Home" data-icon="home"
            rel="external" data-iconpos="notext"><xsl:comment/></a>
        </div>
        <xsl:if test="$prev or $next or $up">
          <div class="ui-btn-right" data-role="controlgroup" data-iconpos="notext"
              data-type="horizontal">
            <xsl:if test="$prev">
              <a href="{$prev}" data-icon="arrow-l" data-role="button" data-iconpos="notext"
                class="prevPage" title="Previous" data-direction="reverse"><xsl:comment/></a>
            </xsl:if>
            <xsl:if test="$up">
              <a href="{$up}" data-icon="arrow-u" data-role="button" title="Up" 
                data-transition="slidedown" data-iconpos="notext" data-inline="true" class="upPage ui-btn-corner-all"
                ><xsl:comment/></a>
            </xsl:if>
            <xsl:if test="$next">
              <a href="{$next}" data-icon="arrow-r" data-role="button" data-iconpos="notext"
                title="Next" class="nextPage"><xsl:comment/></a>
            </xsl:if>
          </div>
        </xsl:if>
  </xsl:template>

  <!-- 
        Eliminates the upper navigation section.
    -->
    <xsl:template match="*:table[@class='nav']" mode="fixup_mobile"/>
  
    <xsl:template match="*:div[@class='related-links']" mode="fixup_mobile">
    <xsl:variable name="content" select="."/>
    <xsl:if test="$content">
      <div class="related-links"><xsl:comment/><xsl:apply-templates mode="fixup_mobile"/>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- 
        Converts the related links into mobile style buttons.
  -->
  <xsl:template match="//*[contains(@class,'relinfo')]|//*[contains(@class,'linklist')]" mode="fixup_mobile">
    <xsl:variable name="content" select="."/>
    <xsl:if test="$content">
      <div class="relinfo"><xsl:comment/>
          <xsl:if test="*:strong">
            <h4><xsl:apply-templates select="*:strong" mode="fixup_mobile"/></h4>
        </xsl:if>
        <xsl:if test="*:div">
          <ul class="ullinks" data-role="listview">
            <xsl:for-each select="*:div">
              <li>
                <xsl:apply-templates select="@*" mode="fixup_mobile"/>
                <xsl:choose>
                  <xsl:when test="@class">
                    <xsl:attribute name="class"><xsl:value-of select="concat(@class, ' related_link')"/></xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="class">related_link</xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates mode="fixup_mobile"/>
              </li>
            </xsl:for-each>
          </ul>
        </xsl:if>
      </div>
    </xsl:if>
  </xsl:template>
  

  <xsl:template match="*:table" mode="fixup_mobile">
    <div class="tablemob">
      <xsl:copy>
        <xsl:apply-templates select="@*" mode="fixup_mobile"/>
        <xsl:apply-templates mode="fixup_mobile"/>
      </xsl:copy>
    </div>
  </xsl:template>

  <!-- 
        Cleans-up the footer. The oXygen logo is converted to text.        
    -->
    <xsl:template match="*:div[@class='footer']" mode="fixup_mobile"/>
    <xsl:template match="*:div[@class='navfooter']" mode="fixup_mobile">
    <xsl:variable name="content">
        <xsl:apply-templates select="//*:div[@class='footer']/(*|text())" mode="fixup_mobile"/>
    </xsl:variable>
    <xsl:if test="count($content/node()) > 0">
      <div data-role="footer" data-theme="c">
        <div class="footer">
          <xsl:copy-of select="$content"/>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <!--
        Transforms the UL containing links in a list view.
        Eliminate the strong element from the list items. This 
        way the buttons created by JQuery mobile will be more platform-like. 
    -->
    <xsl:template match="*:ul[@class='ullinks']" mode="fixup_mobile">
        <ul class="ullinks" data-role="listview">
          <xsl:apply-templates mode="fixup_mobile"/>
        </ul>
    </xsl:template>

    <!-- Hide the link descriptions. -->
    <xsl:template match="*:li[@class='link olchildlink'] | *:li[@class='link ulchildlink']" mode="fixup_mobile">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select=".//*:a[1]" mode="fixup_mobile"/>
        </xsl:copy>
    </xsl:template>
    
  <!--
        Transforms the OL containing related links in a list view.
    -->
    <xsl:template match="*:ol[@class='olchildlinks']" mode="fixup_mobile">
    <ul class="olchildlinks" data-role="listview">
      <xsl:apply-templates mode="fixup_mobile"/>
    </ul>
  </xsl:template>


  <!--
        Rewrites the head section.
     -->
    <xsl:template match="*:head" mode="fixup_mobile">
      <xsl:copy>
        <xsl:apply-templates mode="fixup_mobile" select="@*"/>
        <xsl:text xml:space="preserve">        
      </xsl:text>
        <xsl:call-template name="generateHeadContent"/>
      </xsl:copy>
      
  </xsl:template>


  <!--
    Adds page attributes on the body. Imposes a theme and a page structure.
  -->  
    <xsl:template match="*:body" mode="fixup_mobile">
    <body>
      <!-- Custom JavaScript code set by param webhelp.body.script -->
      <xsl:call-template name="jsInBodyStart"/>
      <div data-content-theme="c" data-role="page">
          <xsl:for-each select="ancestor-or-self::*/@*">
              <xsl:if test="local-name(.) != 'id'">
                  <xsl:attribute name="{local-name(.)}">
                      <xsl:value-of select="."/>
                  </xsl:attribute>
              </xsl:if>
          </xsl:for-each>
          <xsl:variable name="content">
            <xsl:apply-templates mode="fixup_mobile"/>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$content/*[@data-role='header'] and $content/*[@data-role='footer']">
              <!-- Now re-creates the sections JQuery mobile needs. Header, Content, Footer -->
              <xsl:copy-of select="$content/*[@data-role='header']"/>
              <div data-role="content" class="content">
                  <xsl:copy-of select="*:h1[contains(@class,'topictitle1')]"></xsl:copy-of>
                <xsl:copy-of
                  select="$content/node()[preceding-sibling::*[@data-role='header'] and following-sibling::*[@data-role='footer']]"
                />
              </div>
              <xsl:copy-of select="$content/*[@data-role='footer']"/>
            </xsl:when>
            <xsl:when test="$content/*[@data-role='header']">
              <!-- Now re-creates the sections JQuery mobile needs. Header, Content, Footer -->
              <xsl:copy-of select="$content/*[@data-role='header']"/>
              <div data-role="content" class="content">
                <xsl:copy-of select="$content/node()[preceding-sibling::*[@data-role='header']]"/>
              </div>
            </xsl:when>
            <xsl:otherwise>
              <!-- No header or no footer. Dump all. -->
              <div data-role="content" class="content">
                <xsl:copy-of select="$content"/>
              </div>
            </xsl:otherwise>
          </xsl:choose>
      </div>
    </body>
  </xsl:template>

  <!-- 
        Remove only the css and scripts from the oXygen webhelp system. Other scripts are left in place. 
    -->
    <xsl:template match="*:script[contains(@src, 'oxygen-webhelp/resources/')]" mode="fixup_mobile"/>
    <xsl:template match="*:link[contains(@href, 'oxygen-webhelp/resources/')]" mode="fixup_mobile"/>

  <!-- 
        Navigating from TOC to a page and hitting Home on that page lead to the 
        impossibility to change the tab to "Search" or "Index", from "Content".
        
        This looks like it fixes the problem.
    -->
  <xsl:template match="*:a[not(@onclick)]" mode="fixup_mobile">
    <xsl:param name="a"/>
    <xsl:copy>
      <xsl:variable name="href">
        <xsl:call-template name="removeFragmentIfRedundant">
          <xsl:with-param name="href" select="@href"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="contains($href, '#')">
          <!-- The href still contains a fragment. This means the fragment 
              is not redundant, it is important. Because we have to keep it,
              put ajax="false" on the link, in order to preserve its functionality.
            -->
          <xsl:attribute name="href" select="@href"/>
          <xsl:attribute name="data-ajax" select="'false'"/>
          <xsl:attribute name="data-transition" select="'slide'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="href" select="normalize-space($href)"/>
        </xsl:otherwise>
      </xsl:choose>

      <!-- Copy all other attributes. -->
      <xsl:copy-of select="@*[name() != 'href']"/>
      <xsl:attribute name="onclick">return true;</xsl:attribute>
      <xsl:apply-templates mode="fixup_mobile"/>
    </xsl:copy>
  </xsl:template>
    
    
  <!-- 
        Generic copy. 
    -->
  <xsl:template match="node() | @*" mode="fixup_mobile">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="fixup_mobile"/>
    </xsl:copy>
  </xsl:template>

  <!--Fix up all empty namespaces to the XHTML namespace -->
  <xsl:template match="*[namespace-uri() eq '']" mode="fixup_XHTML_NS">
    <xsl:element name="{name()}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@* | node()" mode="fixup_XHTML_NS"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@* | node()" mode="fixup_XHTML_NS">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="fixup_XHTML_NS"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="nav | section | figure | article" mode="fixup_XHTML_NS" priority="20">
    <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@* except @role | node()" mode="fixup_XHTML_NS"/>
    </xsl:element>
  </xsl:template>
  
  <!-- Group for root document node does not need extra XHTML div -->
  <xsl:template match="main/article" mode="fixup_XHTML_NS" priority="30">
    <xsl:apply-templates select="node()" mode="fixup_XHTML_NS"/>
  </xsl:template>
  
  <xsl:template match="header | footer | main" mode="fixup_XHTML_NS" priority="20">
    <xsl:apply-templates select="node()" mode="fixup_XHTML_NS"/>
  </xsl:template>
  
  <xsl:template match="div/@role" mode="fixup_XHTML_NS" priority="10"/>
  
  <xsl:template match="@*[starts-with(name(), 'data-')]" mode="fixup_XHTML_NS" priority="10"/>

</xsl:stylesheet>