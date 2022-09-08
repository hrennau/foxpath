<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
                xmlns:df="http://dita2indesign.org/dita/functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:relpath="http://dita2indesign/functions/relpath"
                xmlns:htmlutil="http://dita4publishers.org/functions/htmlutil"
                xmlns:index-terms="http://dita4publishers.org/index-terms"
                xmlns:glossdata="http://dita4publishers.org/glossdata"
                xmlns:mapdriven="http://dita4publishers.org/mapdriven"
                xmlns:enum="http://dita4publishers.org/enumerables"
                xmlns:local="urn:functions:local"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns:epubtrans="urn:d4p:epubtranstype"
                xmlns="http://www.w3.org/1999/xhtml" 
                exclude-result-prefixes="local xs df xsl relpath htmlutil index-terms epubtrans mapdriven enum glossdata"
  >
  <!-- ============================================================================= 
    
       Generate the <nav> structure for EPUB3
       
       Implements mode "epubtrans:generate-nav"
       
       NOTE: Mode generate-toc is for the EPUB2 toc.ncx file. 
       
       ============================================================================= -->
  
  <xsl:output indent="yes" name="ncx" method="xml"/>
  
  <xsl:template match="*[df:class(., 'map/map')]" mode="epubtrans:generate-nav">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="collected-data" as="element()" tunnel="yes"/>
        
    <xsl:variable name="map" as="element()" select="."/>
    
 <!-- ================= 
      
      See 
      
        http://www.idpf.org/epub/301/spec/epub-contentdocs.html#sec-xhtml-nav-def
       
      for the EPUB3 rules for navigation markup. These templates attempt to enforce
      those rules.
      
     ================= -->
    
    <xsl:variable name="pubTitle" as="xs:string*">
      <xsl:apply-templates select="*[df:class(., 'topic/title')] | @title" mode="pubtitle"/>
    </xsl:variable>           
    <xsl:message> + [INFO] Constructing nav structures...</xsl:message>
    <xsl:variable name="resultUri" 
      select="relpath:newFile($outdir, epubtrans:getNavFilename('toc'))" 
      as="xs:string"/>
    
    <xsl:message> + [INFO] Generating EPUB3 Nav document "<xsl:sequence select="$resultUri"/>"...</xsl:message>
    
    <xsl:result-document href="{$resultUri}" format="html5">
      <html 
        xmlns:epub="http://www.idpf.org/2007/ops" 
        >
      	<head>
      		<meta charset="utf-8" />
      		<!-- FIXME: May need to generate appropriate CSS references here -->
      	  <xsl:call-template name="epubtrans:constructJavaScriptReferences">
      	    <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      	    <xsl:with-param name="resultUri" as="xs:string" select="$resultUri"/>
      	  </xsl:call-template>      	  
      	</head>
      	<body>
      	  <xsl:for-each select="$navTypes">
      	    <xsl:variable name="navType" as="xs:string" select="."/>
      	    <xsl:message> + [INFO]   Generating nav structure for type "<xsl:value-of select="$navType"/>"...</xsl:message>
      	    <xsl:for-each select="$map">
        	    <xsl:call-template name="generate-nav-structure">
        	      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        	      <xsl:with-param name="navType" select="$navType" as="xs:string" tunnel="yes"/>
        	    </xsl:call-template>
      	    </xsl:for-each>
      	  </xsl:for-each>
      	</body>
      </html>
    </xsl:result-document>  

  </xsl:template>
  
  <xsl:template name="generate-nav-structure">
    <!-- Context node must be a map -->
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="navType" as="xs:string" tunnel="yes"/>
    <xsl:param name="collected-data" as="node()*" tunnel="yes"/>
    
    <!-- Note that per the EPUB3 spec, nav elements must contain exactly one
         ordered list.
      -->
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] generate-nav-structure: context: <xsl:value-of select="name(.)"/>, <xsl:value-of select="@class"/></xsl:message>
      <xsl:message> + [DEBUG] generate-nav-structure:   navType: "<xsl:value-of select="$navType"/>"</xsl:message>
    </xsl:if>
    
    <nav epub:type="{$navType}" id="{epubtrans:getNavId($navType)}">
      <h1 class="title"><xsl:sequence select="epubtrans:getNavTitle(., $navType)"/></h1>
      <ol>
        <xsl:choose>
          <xsl:when test="$navType = 'toc'">
            <xsl:apply-templates mode="epubtrans:generate-nav-toc" select=".">
      	      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="$navType = 'toc-brief'">
            <xsl:apply-templates mode="epubtrans:generate-nav-toc" select=".">
              <xsl:with-param name="tocDepth" as="xs:integer" tunnel="yes" select="1"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="$navType = 'landmarks'">
            <xsl:apply-templates mode="epubtrans:generate-nav-landmarks" select=".">
      	      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="$navType = 'loa'">
            <xsl:apply-templates mode="epubtrans:generate-nav-loa" select=".">
      	      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="$navType = 'loi'">
            <xsl:apply-templates mode="epubtrans:generate-nav-loi" select=".">
      	      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="$navType = 'lot'">
            <xsl:apply-templates mode="epubtrans:generate-nav-lot" select=".">
      	      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="$navType = 'lov'">
            <xsl:apply-templates mode="epubtrans:generate-nav-lov" select=".">
      	      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="$navType = 'lof'">
            <!-- Not a type defined in EPUB spec.-->
            <xsl:apply-templates mode="epubtrans:generate-nav-lof" select=".">
      	      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="epubtrans:generate-nav-custom" select=".">
      	      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </ol>
    </nav>
  </xsl:template>
  
  <xsl:template mode="epubtrans:generate-nav-toc" match="*[df:class(., 'map/map')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="collected-data" as="node()*" tunnel="yes"/>
    
    <!-- NOTE: This template generates the <li> elements that populate the root
               <ol> for the <nav> element.
      -->
    <xsl:apply-templates select="*[df:class(., 'map/topicref')]" mode="generate-html-toc">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      <xsl:with-param name="tocDepth" as="xs:integer" tunnel="yes" select="1"/>
      <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="epubtrans:generate-nav-loa 
                      epubtrans:generate-nav-loi 
                      epubtrans:generate-nav-lot 
                      epubtrans:generate-nav-lov 
                      epubtrans:generate-nav-custom 
                      epubtrans:generate-nav-landmarks
                      " 
                      match="*[df:class(., 'map/map')]"
                      priority="-1" 
    >
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="navType" as="xs:string" tunnel="yes"/>

    <li>Navigation type <xsl:value-of select="$navType"/> not implemented.</li>

  </xsl:template>
  
  <xsl:template mode="epubtrans:generate-pagelist-nav" match="*[df:class(., 'map/map')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] epubtrans:generate-pagelist-nav: handling element <xsl:value-of select="name(.)"/></xsl:message>
    </xsl:if>

    <!-- Default: No pagelist nav. 
      
      The pagelist nav section should be e.g., 
      
      <nav epub:type="page-list">
        <h2>Page List</h2>
        <ol>
        	<li><a href="testdoc-001.xhtml#p110">110</a></li>
        </ol>
			</nav>
      -->
  </xsl:template>
  
  <xsl:template mode="epubtrans:generate-custom-nav" match="*[df:class(., 'map/map')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] epubtrans:generate-custom-nav: handling element <xsl:value-of select="name(.)"/></xsl:message>
    </xsl:if>

    <!-- Mode for generating arbitrary navigation structures. See 
      http://www.idpf.org/epub/301/spec/epub-contentdocs.html#sec-xhtml-nav-def-types-pagelist
      
      Extensions can hook this mode to generate whatever additional navigation
      structures they want.
      -->
  </xsl:template>
  
  <xsl:template mode="epubtrans:generate-nav" match="*[df:class(., 'topic/title')][not(@toc = 'no')]"/>

  <!-- Convert each topicref to a ToC entry. -->
  <xsl:template match="*[df:isTopicRef(.)][not(@toc = 'no')]" mode="epubtrans:generate-nav">
    <xsl:param name="tocDepth" as="xs:integer" tunnel="yes" select="0"/>
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>

    <xsl:if test="$tocDepth le $maxTocDepthInt">
      <xsl:variable name="topic" select="df:resolveTopicRef(.)" as="element()*"/>
      <xsl:choose>
        <xsl:when test="not($topic)">
          <xsl:message> + [WARNING] epubtrans:generate-nav: Failed to resolve topic reference to href
              "<xsl:sequence select="string(@href)"/>"</xsl:message>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="targetUri"
            select="htmlutil:getTopicResultUrl2($outdir, root($topic), ., $rootMapDocUrl)"
            as="xs:string"/>
          <xsl:variable name="relativeUri" select="relpath:getRelativePath($outdir, $targetUri)"
            as="xs:string"/>
          <xsl:variable name="enumeration" as="xs:string?">
            <xsl:apply-templates select="." mode="enumeration"/>
          </xsl:variable>
          <xsl:variable name="self" select="generate-id(.)" as="xs:string"/>

          <!-- Use UL for navigation structure -->

          <li>
            <a href="{$relativeUri}">
              <!-- target="{$contenttarget}" -->
              <xsl:if test="$enumeration and $enumeration != ''">
                <span class="enumeration enumeration{$tocDepth}">
                  <xsl:sequence select="$enumeration"/>
                </span>
              </xsl:if>
              <xsl:apply-templates select="." mode="nav-point-title"/>
            </a>
            <xsl:if test="$topic/*[df:class(., 'topic/topic')], *[df:class(., 'map/topicref')]">
              <xsl:variable name="listItems" as="node()*">
                <!-- Any subordinate topics in the currently-referenced topic are
              reflected in the ToC before any subordinate topicrefs.
            -->
                <xsl:apply-templates mode="#current"
                  select="$topic/*[df:class(., 'topic/topic')], *[df:class(., 'map/topicref')]">
                  <xsl:with-param name="tocDepth" as="xs:integer" tunnel="yes"
                    select="$tocDepth + 1"/>
                </xsl:apply-templates>
              </xsl:variable>
              <xsl:if test="$listItems">
                <ul>
                  <xsl:sequence select="$listItems"/>
                </ul>
              </xsl:if>
            </xsl:if>
          </li>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[df:isTopicGroup(.)]" priority="20" mode="epubtrans:generate-nav">
    <xsl:apply-templates select="*[df:class(., 'map/topicref')]" mode="#current"/>
  </xsl:template>

  <xsl:template match="*[df:class(., 'topic/topic')]" mode="epubtrans:generate-nav">
    <!-- Non-root topics generate ToC entries if they are within the ToC depth -->
    <xsl:param name="tocDepth" as="xs:integer" tunnel="yes" select="0"/>
    <xsl:if test="$tocDepth le $maxTocDepthInt">
      <!-- FIXME: Handle nested topics here. -->
    </xsl:if>
  </xsl:template>

  <xsl:template mode="#all"
    match="*[df:class(., 'map/topicref') and (@processing-role = 'resource-only')]" priority="30"/>


  <!-- topichead elements get a navPoint, but don't actually point to
       anything.  Same with topicref that has no @href. -->
  <xsl:template match="*[df:isTopicHead(.)][not(@toc = 'no')]" mode="epubtrans:generate-nav">
    <xsl:param name="tocDepth" as="xs:integer" tunnel="yes" select="0"/>

    <xsl:if test="$tocDepth le $maxTocDepthInt">
      <xsl:variable name="navPointId" as="xs:string" select="generate-id(.)"/>
      <li id="{$navPointId}" class="topichead">
        <span>
          <xsl:sequence select="df:getNavtitleForTopicref(.)"/>
        </span>
        <xsl:variable name="listItems" as="node()*">
          <xsl:apply-templates select="*[df:class(., 'map/topicref')]" mode="#current">
            <xsl:with-param name="tocDepth" as="xs:integer" tunnel="yes" select="$tocDepth + 1"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:if test="$listItems">
          <ul>
            <xsl:sequence select="$listItems"/>
          </ul>
        </xsl:if>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[df:class(., 'topic/tm')]" mode="epubtrans:generate-nav">
    <xsl:apply-templates mode="#current"/>
    <xsl:choose>
      <xsl:when test="@type = 'reg'">
        <xsl:text>[reg]</xsl:text>
      </xsl:when>
      <xsl:when test="@type = 'sm'">
        <xsl:text>[sm]</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>[tm]</xsl:text>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template
    match="
    *[df:class(., 'topic/topicmeta')] |
    *[df:class(., 'map/navtitle')] |
    *[df:class(., 'topic/ph')] |
    *[df:class(., 'topic/cite')] |
    *[df:class(., 'topic/image')] |
    *[df:class(., 'topic/keyword')] |
    *[df:class(., 'topic/term')]
    "
    mode="epubtrans:generate-nav">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="*[df:class(., 'topic/title')]//text()" mode="epubtrans:generate-nav">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="text()" mode="epubtrans:generate-nav"/>

  <xsl:template match="@*|node()" mode="fix-navigation-href">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="fix-navigation-href"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="li" mode="fix-navigation-href">
    <xsl:param name="topicRelativeUri" as="xs:string" select="''" tunnel="yes"/>
    <xsl:variable name="isActiveTrail" select="descendant::*[contains(@href, $topicRelativeUri)]"/>
    <xsl:variable name="hasChild" select="descendant::li"/>

    <xsl:variable name="hasChildClass">
      <xsl:choose>
        <xsl:when test="$hasChild">
          <xsl:value-of select="' collapsible '"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="' no-child '"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <li>
      <xsl:attribute name="class" select="@class"/>
      <xsl:if test="text()[1]">
        <span class="navtitle">
          <xsl:value-of select="text()[1]" />
        </span>
      </xsl:if>
      <xsl:apply-templates select="*" mode="fix-navigation-href"/>
    </li>
  </xsl:template>


  <xsl:template match="a" mode="fix-navigation-href">
   <xsl:param name="topicRelativeUri" as="xs:string" select="''" tunnel="yes"/>
    <xsl:param name="relativePath" as="xs:string" select="''" tunnel="yes"/>

   <xsl:variable name="isSelected" select="@href=$topicRelativeUri"/>

    <xsl:variable name="prefix">
      <xsl:choose>
        <xsl:when test="substring(@href, 1, 1) = '#'">
          <xsl:value-of select="''"/>
        </xsl:when>
        <xsl:when test="substring(@href, 1, 1) = '/'">
          <xsl:value-of select="''"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$relativePath"/>
        </xsl:otherwise>

      </xsl:choose>
    </xsl:variable>
  <a>
    <xsl:if test="$isSelected">
      <xsl:attribute name="class" select="'selected'" />
    </xsl:if>
      <xsl:attribute name="href" select="concat($prefix, @href)"/>
      <xsl:sequence select="node()" />
    </a>
  </xsl:template>

  <xsl:template match="mapdriven:collected-data" mode="epubtrans:generate-nav">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="enum:enumerables" mode="epubtrans:generate-nav">
    <!-- Nothing to do with enumerables in this context -->
  </xsl:template>

  <xsl:template match="glossdata:glossary-entries" mode="epubtrans:generate-nav">
    <xsl:message> + [INFO] EPUB3 nav generation: glossary entry processing not yet
      implemented.</xsl:message>
  </xsl:template>
  
  <xsl:function name="epubtrans:getNavFilename" as="xs:string">
    <!-- Returns the filename to use for the navigation file -->
    <xsl:param name="navType" as="xs:string"/>
    <xsl:variable name="result">
      <xsl:call-template name="get-nav-filename">
        <xsl:with-param name="navType" as="xs:string" select="$navType"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:sequence select="normalize-space($result)"/>
  </xsl:function>
  
  <xsl:template name="get-nav-filename">
    <xsl:param name="navType" as="xs:string"/>
    <!-- Override this template to change the logic for nav filename construction -->
    <xsl:variable name="namePart" as="xs:string"
      select="if ($navType = 'toc') 
                 then 'nav' 
                 else concat('nav-', $navType)"
    />
    <xsl:variable name="filename" select="concat($namePart, '.xhtml')"/>
    <xsl:value-of select="$filename"/>
  </xsl:template>

  <xsl:function name="epubtrans:getNavId" as="xs:string">
    <!-- Returns the ID to use in the EPUB manifest for the navigation file of the specified type -->
    <xsl:param name="navType" as="xs:string"/>
    
    <xsl:variable name="result">
      <xsl:call-template name="get-nav-id">
        <xsl:with-param name="navType" as="xs:string" select="$navType"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:sequence select="normalize-space($result)"/>
  </xsl:function>
  
  <xsl:template name="get-nav-id">
    <xsl:param name="navType" as="xs:string"/>
    <!-- Override this template to change the logic for nav ID construction -->
    <xsl:variable name="id" as="xs:string"
      select="if ($navType = 'toc') 
                 then 'nav' 
                 else concat('nav-', $navType)"
    />
    <xsl:sequence select="$id"/>
  </xsl:template>
  
  <xsl:function name="epubtrans:getNavTitle" as="node()*">
    <xsl:param name="map" as="element()"/>
    <xsl:param name="navType" as="xs:string"/>
    <xsl:variable name="navTitle" as="node()*">
      <xsl:apply-templates select="$map" mode="epubtrans:getNavTitle">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
        <xsl:with-param name="navType" as="xs:string" tunnel="yes" select="$navType"/>
      </xsl:apply-templates>        
    </xsl:variable>
    <xsl:sequence select="$navTitle"/>
  </xsl:function>
  
  <xsl:template match="*[df:class(., 'map/map')]" mode="epubtrans:getNavTitle">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="true()"/>
    <xsl:param name="navType" as="xs:string" tunnel="yes"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] epubtrans:getNavTitle: Handling map, navType="<xsl:value-of select="$navType"/>"</xsl:message>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="$navType = 'toc'">
        <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'Contents'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$navType = 'landmarks'">
        <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'Landmarks'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$navType = 'loa'">
        <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'ListOfAudio'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$navType = 'loi'">
        <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'ListOfIllustrations'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$navType = 'lot'">
        <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'ListOfTables'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$navType = 'lov'">
        <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'ListOfVideos'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$navType = 'toc-brief'">
        <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'BriefToC'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$navType = 'lof'"><!-- Note a type defined in EPUB spec. EPUB spec allows other types. -->
        <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'ListOfFigures'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="upper-case($navType)"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  

</xsl:stylesheet>
