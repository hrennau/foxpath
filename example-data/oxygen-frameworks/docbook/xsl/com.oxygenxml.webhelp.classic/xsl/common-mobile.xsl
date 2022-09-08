<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen WebHelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    
    <!-- 
        The jQuery mobile guidelines recommend that the CSS and JS files should be 
        the same for all the files from a system. 
        
        That is because when the user navigates to a different page, the jQuery 
        framework uses ajax to load pages, and the js and css files from target pages
        are not executed/applied. A different modality to listen for a page load 
        is used than in a standard JQuery.     
        
    -->
  
  	<!-- Triggers the display of the comments and change tracking -->
    <xsl:param name="show.changes.and.comments" select="'no'"/>
    
    <!-- Custom CSS set in param args.css -->
    <xsl:param name="CSS" select="''"/>
    
    <!-- Custom JavaScript code set by param webhelp.head.script -->
    <xsl:param name="WEBHELP_HEAD_SCRIPT" select="''"/>
    
    <!-- Custom JavaScript code set by param webhelp.body.script -->
    <xsl:param name="WEBHELP_BODY_SCRIPT" select="''"/>
  
    <!-- Google Custom Search code set by param webhelp.search.script -->
    <xsl:param name="WEBHELP_SEARCH_SCRIPT" select="''"/>
     
    <!-- Google Custom Search code set by param webhelp.search.results -->
    <xsl:param name="WEBHELP_SEARCH_RESULT" select="''"/>
    
    <!-- Oxygen version that created the WebHelp pages. -->
    <xsl:param name="WEBHELP_VERSION"/>
        
    <!-- File path of image used as favicon -->
    <xsl:param name="WEBHELP_FAVICON"/>
  
    <xsl:template name="jsAndCSS">
      <xsl:param name="namespace" select="'http://www.w3.org/1999/xhtml'"/>
      
      <xsl:choose>
            <xsl:when test="contains($WEBHELP_VERSION, '$')">
                <xsl:comment>  Generated with Oxygen build number <xsl:value-of select="$WEBHELP_BUILD_NUMBER"/>.  </xsl:comment>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>  Generated with Oxygen version <xsl:value-of select="$WEBHELP_VERSION"/>, build number <xsl:value-of select="$WEBHELP_BUILD_NUMBER"/>.  </xsl:comment>
            </xsl:otherwise>
      </xsl:choose>
        
      <xsl:element name="meta" namespace="{$namespace}">
        <xsl:attribute name="http-equiv">Content-Type</xsl:attribute>
        <xsl:attribute name="content">text/html; charset=utf-8</xsl:attribute>
      </xsl:element>
      <xsl:element name="meta" namespace="{$namespace}">
        <xsl:attribute name="name">viewport</xsl:attribute>
        <xsl:attribute name="content">width=device-width, initial-scale=1</xsl:attribute>
      </xsl:element>
      
      <!-- Link the favicon -->
      <xsl:if test="string-length($WEBHELP_FAVICON) > 0">
        <link rel="shortcut icon">
          <xsl:attribute name="href">
            <xsl:value-of select="$WEBHELP_FAVICON"/>
          </xsl:attribute>
          <xsl:comment/>
        </link>
        <link rel="icon">
          <xsl:attribute name="href">
            <xsl:value-of select="$WEBHELP_FAVICON"/>
          </xsl:attribute>
          <xsl:comment/>
        </link>
      </xsl:if>
      
      <xsl:element name="link" namespace="{$namespace}"> 	 
        <xsl:attribute name="rel">stylesheet</xsl:attribute> 	 
        <xsl:attribute name="type">text/css</xsl:attribute> 	 
        <xsl:attribute name="href">
          <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/css/commonltr.css?buildId=', $WEBHELP_BUILD_NUMBER)"/> 	 
        </xsl:attribute> 	 
        <xsl:comment/> 	 
      </xsl:element>
      
      <xsl:element name="link" namespace="{$namespace}">
        <xsl:attribute name="rel">stylesheet</xsl:attribute>
        <xsl:attribute name="type">text/css</xsl:attribute>
        <xsl:attribute name="href">
          <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/skins/mobile/jquery.mobile-1.4.0/jquery.mobile-1.4.0.min.css')"/>
        </xsl:attribute>
        <xsl:comment/>
      </xsl:element>
      <xsl:element name="link" namespace="{$namespace}">
        <xsl:attribute name="rel">stylesheet</xsl:attribute>
        <xsl:attribute name="type">text/css</xsl:attribute>
        <xsl:attribute name="href">
          <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/skins/mobile/toc.css?buildId=', $WEBHELP_BUILD_NUMBER)"/>
        </xsl:attribute>
        <xsl:comment/>
      </xsl:element>
      <xsl:element name="link" namespace="{$namespace}">
        <xsl:attribute name="rel">stylesheet</xsl:attribute>
        <xsl:attribute name="type">text/css</xsl:attribute>
        <xsl:attribute name="href">
          <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/skins/mobile/topic.css?buildId=', $WEBHELP_BUILD_NUMBER)"/>
        </xsl:attribute>
        <xsl:comment/>
      </xsl:element>
      
      <xsl:if test="$show.changes.and.comments='yes'">
        <xsl:element name="link" namespace="{namespace-uri()}">
          <xsl:attribute name="rel">stylesheet</xsl:attribute>
          <xsl:attribute name="type">text/css</xsl:attribute>
          <xsl:attribute name="href">
            <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/css/p-side-notes.css?buildId=', $WEBHELP_BUILD_NUMBER)"/>
          </xsl:attribute>
          <xsl:comment/>
        </xsl:element>
      </xsl:if>
        
        <xsl:variable name="urltest">
            <xsl:call-template name="url-string-oxy-internal">
                <xsl:with-param name="urltext">
                    <xsl:value-of select="concat($CSSPATH,$CSS)"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:if test="string-length($CSS)>0">
            <xsl:choose>
                <xsl:when test="$urltest='url'">
                  <xsl:element name="link" namespace="{$namespace}">
                    <xsl:attribute name="rel">stylesheet</xsl:attribute>
                    <xsl:attribute name="type">text/css</xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="concat($CSSPATH, $CSS)"/>
                    </xsl:attribute>
                    <xsl:comment/>
                  </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:element name="link" namespace="{$namespace}">
                    <xsl:attribute name="rel">stylesheet</xsl:attribute>
                    <xsl:attribute name="type">text/css</xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="concat($PATH2PROJ, $CSSPATH, $CSS)"/>
                    </xsl:attribute>
                    <xsl:comment/>
                  </xsl:element>
                </xsl:otherwise>
            </xsl:choose>   
        </xsl:if>
      <xsl:element name="script" namespace="{$namespace}">
        <xsl:attribute name="type">text/javascript</xsl:attribute>
        var withFrames = false;
      </xsl:element>
       
      <xsl:element name="script" namespace="{$namespace}">
        <xsl:attribute name="type">text/javascript</xsl:attribute>
        <xsl:attribute name="src">
          <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/js/jquery-1.11.3.min.js')"/>
        </xsl:attribute>
        <xsl:comment/>
      </xsl:element>
      <xsl:element name="script" namespace="{$namespace}">
        <xsl:attribute name="type">text/javascript</xsl:attribute>
        <xsl:attribute name="src">
          <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/js/browserDetect.js?buildId=', $WEBHELP_BUILD_NUMBER)"/>
        </xsl:attribute>
        <xsl:comment/>
      </xsl:element>
      <xsl:element name="script" namespace="{$namespace}">
        <xsl:attribute name="type">text/javascript</xsl:attribute>
        <xsl:attribute name="src">
          <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/skins/mobile/topic.js?buildId=', $WEBHELP_BUILD_NUMBER)"/>
        </xsl:attribute>
        <xsl:comment/>
      </xsl:element>
      <xsl:element name="script" namespace="{$namespace}">
        <xsl:attribute name="type">text/javascript</xsl:attribute>
        <xsl:attribute name="src">
          <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/skins/mobile/toc.js?buildId=', $WEBHELP_BUILD_NUMBER)"/>
        </xsl:attribute>
        <xsl:comment/>
      </xsl:element>
      <xsl:element name="script" namespace="{$namespace}">
        <xsl:attribute name="type">text/javascript</xsl:attribute>
        <xsl:attribute name="src">
          <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/skins/mobile/jquery.mobile-1.4.0/jquery.mobile-1.4.0.min.js')"/>
        </xsl:attribute>
        <xsl:comment/>
      </xsl:element>
      <xsl:element name="script" namespace="{$namespace}">
        <xsl:attribute name="type">text/javascript</xsl:attribute>
        <xsl:attribute name="src">
          <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/skins/mobile/jquery.mobile-1.4.0/jquery.mobile.nestedlists.js')"/>
        </xsl:attribute>
        <xsl:comment/>
      </xsl:element>
      <xsl:if test="string-length($WEBHELP_SEARCH_SCRIPT) = 0">
      
      <xsl:element name="script" namespace="{$namespace}">
        <xsl:attribute name="type">text/javascript</xsl:attribute>
        <xsl:attribute name="charset">utf-8</xsl:attribute>
        <xsl:attribute name="src">
          <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/search/htmlFileInfoList.js')"/>
        </xsl:attribute>
        <xsl:comment/>
       </xsl:element>
         <xsl:element name="script" namespace="{$namespace}">
           <xsl:attribute name="type">text/javascript</xsl:attribute>
           <xsl:attribute name="charset">utf-8</xsl:attribute>
           <xsl:attribute name="src">
             <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/search/nwSearchFnt.js?uniqueId=', $WEBHELP_UNIQUE_ID)"/>             
           </xsl:attribute>
           <xsl:comment/>
        </xsl:element>
        
        <xsl:element name="script" namespace="{$namespace}">
          <xsl:attribute name="type">text/javascript</xsl:attribute>
          <xsl:attribute name="charset">utf-8</xsl:attribute>
          <xsl:attribute name="src">            
            <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/search/classic/search.js?buildId=', $WEBHELP_BUILD_NUMBER)"/>             
          </xsl:attribute>
          <xsl:comment/>
        </xsl:element>
        
        <xsl:element name="script" namespace="{$namespace}">
          <xsl:attribute name="type">text/javascript</xsl:attribute>
          <xsl:attribute name="charset">utf-8</xsl:attribute>
          <xsl:attribute name="src">
            <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/search/searchCommon.js?buildId=', $WEBHELP_BUILD_NUMBER)"/>
          </xsl:attribute>
          <xsl:comment/>
        </xsl:element>
        
      </xsl:if>
        
        <!-- For Docbook is used Saxon 6. -->
        <xsl:variable name="langPart" select="substring($DEFAULTLANG, 1, 2)" />
        <xsl:variable name="lang"> 
            <xsl:choose>            
                <xsl:when test="function-available('lower-case')">
                    <xsl:value-of select="translate($langPart, 
                                          'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 
                                          'abcdefghijklmnopqrstuvwxyz')"/>                            
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$langPart"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="normalizedLang" select="normalize-space($lang)"/>
        <xsl:if test="$normalizedLang = 'en' or $normalizedLang = 'fr' or $normalizedLang = 'de'">
          <xsl:element name="script" namespace="{$namespace}">
            <xsl:attribute name="type">text/javascript</xsl:attribute>
            <xsl:attribute name="charset">utf-8</xsl:attribute>
            <xsl:attribute name="src">
              <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/search/stemmers/', $normalizedLang, '_stemmer.js?uniqueId=', $WEBHELP_UNIQUE_ID)"/>
            </xsl:attribute>
            <xsl:comment/>
          </xsl:element>
        </xsl:if>
      <xsl:if test="string-length($WEBHELP_SEARCH_SCRIPT) = 0">
        <xsl:element name="script" namespace="{$namespace}">
          <xsl:attribute name="type">text/javascript</xsl:attribute>
          <xsl:attribute name="charset">utf-8</xsl:attribute>
          <xsl:attribute name="src">
            <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/search/index-1.js?uniqueId=', $WEBHELP_UNIQUE_ID)"/>
          </xsl:attribute>
          <xsl:comment/>
        </xsl:element>
        <xsl:element name="script" namespace="{$namespace}">
          <xsl:attribute name="type">text/javascript</xsl:attribute>
          <xsl:attribute name="charset">utf-8</xsl:attribute>
          <xsl:attribute name="src">
            <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/search/index-2.js?uniqueId=', $WEBHELP_UNIQUE_ID)"/>
          </xsl:attribute>
          <xsl:comment/>
        </xsl:element>
        <xsl:element name="script" namespace="{$namespace}">
          <xsl:attribute name="type">text/javascript</xsl:attribute>
          <xsl:attribute name="charset">utf-8</xsl:attribute>
          <xsl:attribute name="src">
            <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/search/index-3.js?uniqueId=', $WEBHELP_UNIQUE_ID)"/>
          </xsl:attribute>
          <xsl:comment/>
        </xsl:element>
      </xsl:if>
      <xsl:element name="script" namespace="{$namespace}">
        <xsl:attribute name="type">text/javascript</xsl:attribute>
        <xsl:attribute name="charset">utf-8</xsl:attribute>
        <xsl:attribute name="src">
          <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/localization/strings.js?uniqueId=', $WEBHELP_UNIQUE_ID)"/>
        </xsl:attribute>
        <xsl:comment/>
      </xsl:element>
      <xsl:element name="script" namespace="{$namespace}">
        <xsl:attribute name="type">text/javascript</xsl:attribute>
        <xsl:attribute name="charset">utf-8</xsl:attribute>
        <xsl:attribute name="src">
          <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/js/localization.js?buildId=', $WEBHELP_BUILD_NUMBER)"/>
        </xsl:attribute>
        <xsl:comment/>
      </xsl:element>
      <xsl:element name="script" namespace="{$namespace}">
        <xsl:attribute name="type">text/javascript</xsl:attribute>
        <xsl:attribute name="charset">utf-8</xsl:attribute>
        <xsl:attribute name="src">
          <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/js/parseuri.js?buildId=', $WEBHELP_BUILD_NUMBER)"/>
        </xsl:attribute>
        <xsl:comment/>
      </xsl:element>
      <xsl:element name="script" namespace="{$namespace}">
        <xsl:attribute name="type">text/javascript</xsl:attribute>
        <xsl:attribute name="charset">utf-8</xsl:attribute>
        <xsl:attribute name="src">
          <xsl:value-of select="concat($PATH2PROJ, 'oxygen-webhelp/resources/js/log.js?buildId=', $WEBHELP_BUILD_NUMBER)"/>
        </xsl:attribute>
        <xsl:comment/>
      </xsl:element>
      <xsl:call-template name="customHeadScript"/>
    </xsl:template>
  
  <xsl:template name="customHeadScript">
    <xsl:call-template name="customHeadScriptMobile"/>
  </xsl:template>
    
    
    <xsl:template name="jsInBodyStart">
      <xsl:call-template name="customBodyScriptMobile"/>
    </xsl:template>
    
    
  <xsl:template name="url-string-oxy-internal">
        <xsl:param name="urltext"/>
        <xsl:choose>
            <xsl:when test="contains($urltext,'http://')">url</xsl:when>
            <xsl:when test="contains($urltext,'https://')">url</xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>