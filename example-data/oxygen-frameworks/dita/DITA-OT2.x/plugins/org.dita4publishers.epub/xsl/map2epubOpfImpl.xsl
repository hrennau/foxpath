<xsl:stylesheet version="2.0"
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:htmlutil="http://dita4publishers.org/functions/htmlutil"
  xmlns:gmap="http://dita4publishers/namespaces/graphic-input-to-output-map"  
  xmlns="http://www.idpf.org/2007/opf"
  xmlns:local="urn:functions:local"
  xmlns:epubtrans="urn:d4p:epubtranstype"
  xmlns:enc="http://www.w3.org/2001/04/xmlenc#"
  exclude-result-prefixes="df xs relpath htmlutil gmap local epubtrans"
  >

  <xsl:output name="xml-no-doctype" method="xml" indent="yes"/>
  
  <!-- Convert a DITA map to an EPUB content.opf file. 
    
    Notes:
    
    If map/topicmeta element has author, publisher, and copyright elements,
    they will be added to the epub file as Dublin Core metadata.
    
  -->
  
  <!-- Map of topicref elements with keys to the first key. 
  
       This is not quite the same as the key space, because it's 
       only looking at the first key in @keys.
  -->
  <xsl:key name="topicrefsByFirstKey" match="*[df:class(., 'map/topicref')][@keys != '']"
    use="tokenize(@keys, ' ')[1]"
  />
  
  <!-- Output format for the content.opf file -->
  <xsl:output name="opf"
    indent="yes"
    method="xml"
  />

  <xsl:template match="*[df:class(., 'map/map')]" mode="generate-opf">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="graphicMap" as="element()" tunnel="yes"/>
    <xsl:param name="effectiveCoverGraphicUri" select="''" as="xs:string" tunnel="yes"/>
    <xsl:message> + [INFO] Generating OPF manifest file...</xsl:message>
    
    <xsl:if test="not(@xml:lang)">
      <xsl:message> - [WARNING] dc:language required in epub file; please add xml:lang attribute to map element. Using en-US.
      </xsl:message>
    </xsl:if>

    <xsl:variable name="lang" select="if (@xml:lang) then string(@xml:lang) else 'en-US'" as="xs:string"/>
    
    <xsl:variable name="resultUri" 
      select="relpath:newFile($outdir, 'content.opf')" 
      as="xs:string"/>
    
    <xsl:message> + [INFO] Generating OPF file "<xsl:sequence select="$resultUri"/>"...</xsl:message>
    
    <xsl:variable name="uniqueTopicRefs" as="element()*" 
      select="df:getUniqueTopicrefs(.)[not(@format = 'ditamap')]"
    />
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] uniqueTopicRefs=<xsl:sequence select="$uniqueTopicRefs"/></xsl:message>
    </xsl:if>
    
    <xsl:variable name="epubVersion" as="xs:string"
      select="if ($epubtrans:isEpub2) then '2.0' else '3.0'"
    />
        
    <xsl:result-document format="opf" href="{$resultUri}">
      <package
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        version="{$epubVersion}"
        unique-identifier="bookid"
        >
        <xsl:choose>
          <xsl:when test="$epubtrans:isEpub3">
            <xsl:attribute name="xml:lang"><xsl:sequence select="$lang"/></xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <!-- @xml:lang is not allowed on opf:package in ePub2 --> 
          </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="." mode="epubtrans:set-prefix-attribute">
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        </xsl:apply-templates>
        
        <metadata>
          <xsl:call-template name="epubtrans:generate-opf-metadata">
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            <xsl:with-param name="lang" as="xs:string" select="$lang"/>
          </xsl:call-template>
        </metadata>
        
        <manifest>
          <xsl:call-template name="epubtrans:generate-opf-manifest">
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            <xsl:with-param name="uniqueTopicRefs" as="element()*" 
              select="$uniqueTopicRefs" tunnel="yes"/>
          </xsl:call-template>
        </manifest>
        
        <spine>
          <xsl:call-template name="epubtrans:generate-opf-spine">
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            <xsl:with-param name="uniqueTopicRefs" as="element()*" 
              select="$uniqueTopicRefs" tunnel="yes"/>            
          </xsl:call-template>
          
        </spine>
        
        <!-- NOTE: guide is deprecated for EPUB3. Allowed for EPUB2 
                   compatiblity.
          -->
        <xsl:variable name="guideContents" as="node()*">
          <xsl:apply-templates mode="guide"  select=".">
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            <xsl:with-param name="uniqueTopicRefs" as="element()*"  tunnel="yes" 
            select="$uniqueTopicRefs"
            />
          </xsl:apply-templates>            
        </xsl:variable>
        <!-- $guideContents is either the empty sequence or a sequence of nodes without an outer element -->
        <xsl:if test="count($guideContents) gt 0">
          <guide>
            <xsl:sequence select="$guideContents"/>
          </guide>
        </xsl:if>

        <xsl:if test="$epubtrans:doGenerateBindings">          
          <bindings>
            <xsl:apply-templates mode="epubtrans:bindings" select=".">
              <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
              <xsl:with-param name="uniqueTopicRefs" as="element()*" 
                select="$uniqueTopicRefs" tunnel="yes"/>
            </xsl:apply-templates>
          </bindings>
        </xsl:if>
        <xsl:if test="$epubtrans:doGenerateCollections">          
          <xsl:apply-templates mode="epubtrans:collections" select=".">
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            <xsl:with-param name="uniqueTopicRefs" as="element()*" 
              select="$uniqueTopicRefs" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:if>
        <!-- First see if encryption is required then, if it is, generate the encryption.xml file. -->
        <xsl:variable name="isEncryptionRequired" as="xs:boolean*">
          <xsl:apply-templates select="." mode="epubtrans:isEncryptionRequired">
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
            <xsl:with-param name="graphicMap" as="element()" tunnel="yes" select="$graphicMap"/>
            <xsl:with-param name="effectiveCoverGraphicUri" select="$effectiveCoverGraphicUri" as="xs:string" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:message> + [DEBUG] $isEncryptionRequired="<xsl:value-of select="$isEncryptionRequired"/>"</xsl:message>
        <xsl:if test="$isEncryptionRequired">
          <xsl:message> + [INFO] Generating encryption.xml file...</xsl:message>
          <xsl:call-template name="epubtrans:makeEncryptionXml">
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="true()"/>
            <xsl:with-param name="graphicMap" as="element()" tunnel="yes" select="$graphicMap"/>
            <xsl:with-param name="effectiveCoverGraphicUri" select="$effectiveCoverGraphicUri" as="xs:string" tunnel="yes"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:message> + [INFO] Encryption.xml generation done.</xsl:message>
        
      </package>
    </xsl:result-document>  
    <xsl:message> + [INFO] OPF file generation done.</xsl:message>
  </xsl:template>
  
  <xsl:template name="epubtrans:generate-opf-manifest">
    <!-- Context is the map -->
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="graphicMap" as="element()" tunnel="yes"/>
    <xsl:param name="effectiveCoverGraphicUri" select="''" as="xs:string" tunnel="yes"/>
    <xsl:param name="uniqueTopicRefs" as="element()*" tunnel="yes"/>
    
    <xsl:if test="$epubtrans:isDualEpub or $epubtrans:isEpub2">
      <!-- Add the NCX file to the manifest: -->
      <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
    </xsl:if>
    <xsl:if test="$epubtrans:isEpub3">
      <!-- FIXME: Need to do this for each separate nav file to be generated -->
      <xsl:if test="$epubtrans:isEpub3">
        <xsl:variable name="properties" as="xs:string*" 
          select="('nav', if (epubtrans:isScripted(.)) then 'scripted' else ())"
        />
        <item href="{epubtrans:getNavFilename('toc')}" 
          id="{epubtrans:getNavId('toc')}" 
          media-type="application/xhtml+xml" 
          properties="{string-join($properties, ' ')}" 
        />        
      </xsl:if>
    </xsl:if>
    <!-- List the XHTML files -->
    <!-- FIXME: Have to account for all navigation topicrefs. -->
    <xsl:apply-templates mode="epubtrans:manifest " select="$uniqueTopicRefs">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    <xsl:apply-templates select=".//*[df:isTopicHead(.)]" mode="epubtrans:manifest ">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    <xsl:apply-templates select=".//*[local:includeTopicrefInManifest(.)]" mode="epubtrans:manifest ">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    <!-- Hook for extension points: -->
    <xsl:apply-templates select="." mode="generate-opf-manifest-extensions">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    <!-- List the images -->
    <xsl:apply-templates mode="epubtrans:manifest " select="$graphicMap">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    
    <!-- CSS items: 
    
         First two are the OT-provided base CSS. $CSS is for a user-specified CSS file.
         
         NOTE: $cssOutDir should have the same value as CSSPATH.
    -->
    
    <xsl:choose>
      <xsl:when test="$copySystemCssNoBoolean">
        <!-- Do not include DITA-OT Default CSS files -->    
      </xsl:when>
      <xsl:otherwise>
        <item id="commonltr.css" href="{relpath:newFile($cssOutDir, 'commonltr.css')}" media-type="text/css"/>
        <item id="commonrtl.css" href="{relpath:newFile($cssOutDir, 'commonrtl.css')}" media-type="text/css"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$CSS != ''">
      <item id="{$CSS}" href="{relpath:newFile($cssOutDir, $CSS)}" media-type="text/css"/>
    </xsl:if>
    
    <xsl:if test="$generateIndexBoolean">
      <item id="generated-index" 
            href="{concat('generated-index', $outext)}"
            media-type="application/xhtml+xml">
        <xsl:if test="epubtrans:isScripted(.)">
          <xsl:attribute name="properties" select="'scripted'"/>          
        </xsl:if>
      </item>
    </xsl:if>

  </xsl:template>

  <xsl:template name="epubtrans:generate-opf-metadata">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="lang" as="xs:string" select="'en-US'"/>
    <xsl:param name="effectiveCoverGraphicUri" select="''" as="xs:string" tunnel="yes"/>
    
    <!-- Context node is the map -->
    <xsl:variable name="utcTime" as="xs:dateTime"
      select="adjust-dateTime-to-timezone(current-dateTime(), xs:dayTimeDuration('-PT0H'))"
    />
    <xsl:variable name="formatted-time" as="xs:string"
      select="format-dateTime($utcTime, '[Y]-[M,2]-[D,2]T[h,2]:[m,2]:[s,2]Z')"
    />
    <!-- NOTE: For EPUB3, the <meta> element has different attributes from
         EPUB2. Instead of @name and @value, it uses @property to specify
         the property name and the element content to specify the value.
      -->
    <xsl:choose>
      <xsl:when test="$epubtrans:isEpub3">
        <meta property="dcterms:modified"><xsl:value-of 
          select="$formatted-time"/></meta>
      </xsl:when>
      <xsl:otherwise>
        <dc:date opf:event="modification"><xsl:sequence select="$formatted-time"/></dc:date>
      </xsl:otherwise>
    </xsl:choose>
    
    <!-- dc:title, dc:language, and dc:identifier are required, so
      if the ditamap doesn't have values, they go in as empty
      elements. -->
    
    <dc:title>
      <xsl:apply-templates select="*[df:class(., 'topic/title')] | @title" mode="pubtitle">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </dc:title>
    
    <dc:language id="language"><xsl:sequence select="$lang"/></dc:language>
    
    <xsl:choose>
      <xsl:when test="*[df:class(., 'map/topicmeta')]">
        <xsl:apply-templates select="*[df:class(., 'map/topicmeta')]" mode="bookid">
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <dc:identifier id="bookid">no-bookid-value</dc:identifier>
      </xsl:otherwise>
    </xsl:choose>
    
    <!-- Remaining metadata fields optional, so 
      their tags only get output if values exist. -->
    
    <xsl:apply-templates select="*[df:class(., 'map/topicmeta')]/*[df:class(., 'topic/author')]" 
        mode="generate-opf">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    
    <xsl:apply-templates select="*[df:class(., 'map/topicmeta')]/*[df:class(., 'topic/publisher')]" 
      mode="generate-opf">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    
    <xsl:apply-templates 
      select="*[df:class(., 'map/topicmeta')]/*[df:class(., 'topic/copyright')] |
      *[df:class(., 'map/topicmeta')]/*[df:class(., 'pubmeta-d/pubrights')]
      " 
      mode="generate-opf">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    
    <!-- NOTE: keywords can be directly in topicmeta or in metadata under topicmeta -->
    <xsl:apply-templates mode="generate-opf"
      select="*[df:class(., 'map/topicmeta')]//*[df:class(., 'topic/keywords')]"
    >
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    
    <xsl:if test="$effectiveCoverGraphicUri != ''">
      <!-- EPUB2 cover meta element -->
      <xsl:if test="$epubtrans:isEpub2 or $epubtrans:isDualEpub">
        <meta name="cover" content="{$coverImageId}"/>
      </xsl:if>
    </xsl:if>
    <xsl:apply-templates mode="generate-opf"
      select="*[df:class(., 'map/topicmeta')]/*[df:class(., 'topic/data') and @name = 'opf-metadata']">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
      
    <xsl:apply-templates mode="epubtrans:additional-opf-metadata" select=".">      
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>  
  </xsl:template>
  
  <xsl:template mode="epubtrans:additional-opf-metadata" match="text()">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- Make sure we don't get unwanted text in the output if there are
         no extensions that implement this mode.
      -->
  </xsl:template>
  
  <xsl:template mode="epubtrans:additional-opf-metadata" match="*">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:apply-templates mode="#current" select="*"/><!-- We only care about elements -->
  </xsl:template>
  
  <!-- =============================
       Mode epubtrans:collections
       ============================= -->
  
  <xsl:template name="epubtrans:generate-opf-spine">
    <!-- Context is a map -->
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="uniqueTopicRefs" as="element()*" tunnel="yes"/>

    <xsl:if test="$epubtrans:isEpub2 or $epubtrans:isDualEpub">
      <xsl:attribute name="toc" select="'ncx'"/>
    </xsl:if>
    
    <!--
      
      Note that this applies templates to the map as well ('.')
      so that we can generate spine entries for the nav 
      documents.
    
    -->
    <xsl:apply-templates mode="spine" 
      select="($uniqueTopicRefs | 
      .//*[df:isTopicHead(.)]) | 
      .//*[local:includeTopicrefInSpine(.)] |
      ."
    >
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    <xsl:if test="$generateIndexBoolean">
      <itemref idref="generated-index"/>
    </xsl:if>
    
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'map/map')]" mode="spine">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
     <!-- Generate entries for each of the navigation files to be generated. -->
    <xsl:if test="$epubtrans:isEpub3">
      <itemref idref="{epubtrans:getNavId('toc')}"/>
    </xsl:if>
  </xsl:template>
  
  <!-- =============================
       Mode epubtrans:bindings
       ============================= -->
  
  <xsl:template mode="epubtrans:bindings" match="*" priority="-1">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- Do nothing. There are no default bindings.
      -->
  </xsl:template>
  
  <!-- =============================
       Mode epubtrans:collections
       ============================= -->

  <xsl:template mode="epubtrans:collections" match="*[df:class(., 'map/map')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <collection>
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </collection>
  </xsl:template>
  
  <xsl:template mode="epubtrans:collections" match="*" priority="-1">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- Nothing to do. No default collections. -->
  </xsl:template>
  
  <xsl:template mode="epubtrans:set-prefix-attribute" match="*" priority="-1">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- Do nothing. Override this mode if you need to set the 
         @prefix attribute on the <package> element.
      -->
  </xsl:template>

  <!-- =============================
       Mode epubtrans:isEncryptionRequired
            epubtrans:makeEncryptionXml
       ============================= -->
  
  <!-- Default check for encryption. If obfuscation is turned on and
       any embedded fonts are obfuscated then encryption is required.
       
    -->
  <xsl:template mode="epubtrans:isEncryptionRequired" match="*[df:class(., 'map/map')]">   
    <xsl:choose>
      <xsl:when test="$epubtrans:doObfuscateFonts">
        <xsl:variable name="fontManifest" as="document-node()?" 
          select="epubtrans:getFontManifestDoc($epubFontManifestUri, root(.))"/>
        <xsl:sequence select="boolean($fontManifest//*[@obfuscate = ('obfuscate')])"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="false()"/>
      </xsl:otherwise>      
    </xsl:choose>
  </xsl:template>
  
  <!-- Generate the encryption.xml file.
    
       The encryption.xml file must reflect any
       resource that is encrypted or obfuscated,
       such as obfuscated fonts.
       
       Context is the root map.
    -->
  <xsl:template name="epubtrans:makeEncryptionXml">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] epubtrans:makeEncryptionXml: Generating encryption.xml...</xsl:message>
    </xsl:if>
    
    <xsl:variable name="fontManifest" as="document-node()?" 
      select="epubtrans:getFontManifestDoc($epubFontManifestURI, root(.))"
    />
    <xsl:variable name="resultURI" as="xs:string"
      select="relpath:newFile(relpath:newFile($outdir, 'META-INF'), 'encryption.xml')"
    />
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] epubtrans:makeEncryptionXml: resultURI="<xsl:value-of select="$resultURI"/>"</xsl:message>
    </xsl:if>
    
    <xsl:result-document indent="yes" method="xml" format="xml-no-doctype"
      href="{$resultURI}"
      >      
      <encryption 
        xmlns="urn:oasis:names:tc:opendocument:xmlns:container" 
        xmlns:enc="http://www.w3.org/2001/04/xmlenc#">
        <!-- Handle any embedded fonts. -->
        <xsl:apply-templates mode="epubtrans:makeEncryptionXml"
          select="$fontManifest/*"
          >
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="." mode="epubtrans:makeEncryptionXml">
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        </xsl:apply-templates>
      </encryption>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template mode="epubtrans:makeEncryptionXml" match="*[df:class(., 'map/map')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <!-- No default encryption processing for maps. Override this template in
         an extension plugin to add additional encryption entries.
      -->
  </xsl:template>
  
  <xsl:template mode="epubtrans:makeEncryptionXml" match="text()">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- Suppress all text by default -->
  </xsl:template>
  
  <!-- =====================
       Mode guide
       ===================== -->
  
  <xsl:template mode="guide" match="*[df:class(., 'map/map')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="uniqueTopicRefs" as="element()*" tunnel="yes"/>
    <!-- FIXME: Generate a guide entry for the cover page -->            
    <!--<reference type="cover" title="Cover Page" href="${frontCoverUri}"/>-->
    <xsl:apply-templates mode="#current" 
      select="*[df:class(., 'map/topicref')][not(@processing-role = 'resource-only')]"
    >
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    
  </xsl:template>
  
  <xsl:template mode="guide" match="text()">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>    
  </xsl:template>
  
  <xsl:template mode="guide" match="*[df:class(., 'map/topicref')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:apply-templates mode="#current" select="*[df:class(., 'map/topicref')][not(@processing-role = 'resource-only')]">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <!-- ======================================
       Mode generate-opf-manifest-extensions
       ====================================== -->
  
  <xsl:template mode="generate-opf-manifest-extensions" match="*[df:class(., 'map/map')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- Default implementation. Override to add files to the OPF manifest. -->
  </xsl:template>

  <!-- ======================================
       Mode generate-opf-spine-extensions
       ====================================== -->
  <xsl:template mode="spine-extensions" match="*[df:class(., 'map/map')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- Default implementation. Override to add files to the OPF spine. -->
  </xsl:template>

  <xsl:template match="*[df:class(., 'map/map')]/*[df:class(., 'map/topicmeta')]/*[df:class(., 'topic/author')]" 
    mode="generate-opf">  
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:variable name="role" as="xs:string"
      select="if (@type) then string(@type) else 'aut'"
    />
    <xsl:choose>
      <xsl:when test="$epubtrans:isEpub2">
        <dc:creator id="{$role}"
          ><xsl:apply-templates select=".//*[df:class(., 'topic/data')]" mode="data-to-atts">
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
          </xsl:apply-templates><xsl:apply-templates>
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
          </xsl:apply-templates></dc:creator>
      </xsl:when>
      <xsl:otherwise>
        <dc:creator id="{$role}"><xsl:apply-templates>
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        </xsl:apply-templates></dc:creator>
        <xsl:apply-templates select=".//*[df:class(., 'topic/data')]" mode="data-to-refines"
          >
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
          <xsl:with-param name="refinesId" as="xs:string" select="$role"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- ======================================
       Mode data-to-refines
       ====================================== -->
  
  <xsl:template match="*[df:class(., 'topic/data')]" mode="data-to-refines">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="refinesId" as="xs:string"/>
    <meta refines="#{$refinesId}" property="{@name}">
      <xsl:value-of select="if (@value != '') then @value else ."/>
    </meta>
  </xsl:template>
  
  <!-- ======================================
       Mode data-to-atts
       ====================================== -->

  <xsl:template mode="data-to-atts" match="text()">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
  </xsl:template><!-- Suppress all text by default -->
  
  <xsl:template match="*[df:class(., 'topic/data')]" mode="data-to-atts" priority="-1">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:message> + [INFO] mode data-to-atss: Unhandled data element <xsl:sequence select="name(.)"/>, @name="<xsl:sequence select="string(@name)"/>"</xsl:message>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/author')]//*[df:class(., 'topic/data') and @name = 'file-as']" mode="data-to-atts">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:attribute name="opf:file-as" select="normalize-space(.)"/>
  </xsl:template>

  <xsl:template 
    match="
    *[df:class(., 'map/map')]/*[df:class(., 'map/topicmeta')]/*[df:class(., 'topic/publisher')]
    " 
    mode="generate-opf"> 
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:variable name="publisherText" as="node()*">
      <xsl:apply-templates mode="#current">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:if test="not(matches($publisherText, '^\s*$'))">
      <dc:publisher><xsl:value-of select="$publisherText"/></dc:publisher>  
    </xsl:if>
    
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/data')]/text()" mode="generate-opf">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:apply-templates select="."/><!-- Process text in default mode. -->
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/data')]" mode="generate-opf" priority="-1">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:apply-templates mode="#current">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'bookmap/published')]" mode="generate-opf" priority="10">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- Suppress -->
  </xsl:template>


  <xsl:template match="*[df:class(., 'map/map')]/*[df:class(., 'map/topicmeta')]/*[df:class(., 'topic/copyright')]" 
    mode="generate-opf"> 
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- copyryear and copyrholder are required children of copyright element -->
    <dc:rights>Copyright <xsl:value-of select="*[df:class(., 'topic/copyryear')]/@year"/><xsl:text> </xsl:text><xsl:value-of select="*[df:class(., 'topic/copyrholder')]"/></dc:rights>
  </xsl:template>

  <xsl:template match="*[df:class(., 'pubmeta-d/pubrights')]"
    mode="generate-opf"> 
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:variable name="content">
      <xsl:apply-templates mode="#current" select="*[df:class(., 'pubmeta-d/copyrfirst')]">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
      <xsl:text> </xsl:text>
      <xsl:apply-templates mode="generate-opf" select="* except *[df:class(., 'pubmeta-d/copyrfirst')]">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:if test="normalize-space($content) != ''">
      <dc:rights>
        <xsl:sequence select="$content"/>
      </dc:rights>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="generate-opf" match="*[df:class(., 'pubmeta-d/copyrfirst')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:text>Copyright </xsl:text><xsl:value-of select="normalize-space(.)"/>
    <xsl:if test="../*[df:class(., 'pubmeta-d/copyrlast')]">
      <xsl:text>, </xsl:text>
      <xsl:sequence select="normalize-space(../*[df:class(., 'pubmeta-d/copyrlast')])"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="generate-opf" match="*[df:class(., 'pubmeta-d/copyrlast')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- Handled in processing of copyrfirst -->
  </xsl:template>
  
  <xsl:template mode="generate-opf" match="*[df:class(., 'pubmeta-d/pubowner')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:variable name="pubOwners" as="element()*">
      <xsl:sequence select="*"/>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="count($pubOwners) le 1">
        <xsl:apply-templates select="$pubOwners" mode="pubOwner">
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="count($pubOwners) = 2">
        <xsl:apply-templates select="$pubOwners[1]" mode="pubOwner"/>
        <xsl:text> and </xsl:text>
        <xsl:apply-templates select="$pubOwners[2]" mode="pubOwner"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$pubOwners[1]" mode="pubOwner"/>
        <xsl:for-each select="$pubOwners[2, last() - 1]">
          <xsl:text>, </xsl:text>
          <xsl:apply-templates select="." mode="pubOwner"/>
        </xsl:for-each>
        <xsl:text> and </xsl:text>
        <xsl:apply-templates select="$pubOwners[last()]" mode="pubOwner"/>        
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="pubOwner" match="*">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="*[df:isTopicRef(.)]" mode="epubtrans:manifest manifest">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
    
    <xsl:variable name="topic" select="df:resolveTopicRef(.)" as="element()*"/>
    <xsl:choose>
      <xsl:when test="not($topic)">
        <xsl:message> + [WARNING] manifest: Failed to resolve topic reference to href "<xsl:sequence select="string(@href)"/>"</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="epubtrans:manifest" select="$topic">
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
          <xsl:with-param name="rootMapDocUrl" as="xs:string" tunnel="yes" select="$rootMapDocUrl"/>
          <xsl:with-param name="topicref" as="element()" tunnel="yes" select="."/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>
  
  <!-- ======================================
       Mode epubtrans:manifest
       ====================================== -->

  <xsl:template mode="epubtrans:manifest" match="*[df:class(., 'topic/topic')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
    <xsl:param name="topicref" as="element()" tunnel="yes"/>
    
    <xsl:variable name="targetUri" 
      select="htmlutil:getTopicResultUrl2($outdir, root(.), ., $rootMapDocUrl, $doDebug)"
      as="xs:string"
    />
    <xsl:variable name="relativeUri" select="relpath:getRelativePath($outdir, $targetUri)" as="xs:string"/>
    <xsl:if test="$doDebug">          
      <xsl:message> + [DEBUG] map2epubOpfImpl: outdir="<xsl:sequence select="$outdir"/>"</xsl:message>
      <xsl:message> + [DEBUG] map2epubOpfImpl: targetUri="<xsl:sequence select="$targetUri"/>"</xsl:message>
      <xsl:message> + [DEBUG] map2epubOpfImpl: relativeUri="<xsl:sequence select="$relativeUri"/>"</xsl:message>
    </xsl:if>
    <xsl:variable name="itemID" as="xs:string">
      <xsl:apply-templates select="$topicref" mode="epubtrans:getManifestItemID">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </xsl:variable>
    <item id="{$itemID}" href="{$relativeUri}"
      media-type="application/xhtml+xml"
    >
      <xsl:if test="epubtrans:isScripted(.)">
        <xsl:attribute name="properties" select="'scripted'"/>          
      </xsl:if>
    </item>
  </xsl:template>
  
  <xsl:template mode="epubtrans:getManifestItemID" match="*[df:class(., 'map/topicref')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>

    <xsl:variable name="key" as="xs:string?"
      select="if (@keys) then tokenize(@keys, ' ')[1] else ()"
      />
    <xsl:variable name="itemKey" as="xs:string">
      <xsl:choose>
        <xsl:when test="$key and (key('topicrefsByFirstKey', $key, root(.))[1] = .)">
          <!-- This topicref is the first with the key, so it should be the active
               topicref with this key.
            -->
          <xsl:sequence select="$key"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="generate-id(.)"></xsl:sequence>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:sequence select="normalize-space($itemKey)"/>
  </xsl:template>

  <xsl:template match="*[df:isTopicHead(.)]" mode="epubtrans:manifest manifest">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="false()">
      <xsl:message> + [DEBUG] in mode manifest, handling topichead <xsl:sequence select="df:getNavtitleForTopicref(.)"/></xsl:message>
    </xsl:if>
    <xsl:variable name="titleOnlyTopicFilename" as="xs:string"
      select="htmlutil:getTopicheadHtmlResultTopicFilename(.)" />
    <xsl:variable name="targetUri" as="xs:string"
          select="        
       if ($topicsOutputDir != '') 
          then concat($topicsOutputDir, '/', $titleOnlyTopicFilename) 
          else $titleOnlyTopicFilename
          " />
    <item id="{generate-id()}" href="{$targetUri}"
      media-type="application/xhtml+xml">
      <xsl:if test="epubtrans:isScripted(.)">
        <xsl:attribute name="properties" select="'scripted'"/>          
      </xsl:if>
    </item>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'map/topicref')]" mode="spine">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:variable name="itemID" as="xs:string">
      <xsl:apply-templates select="." mode="epubtrans:getManifestItemID">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </xsl:variable>
    <itemref idref="{$itemID}"/>
  </xsl:template>
  
  <xsl:template mode="bookid" match="*[df:class(., 'map/topicmeta')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- OPF requires one dc:identifier, which must have an ID. There may
         be other book identifiers.
         
         DITA provides a number of ways, none mandatory, to specify book
         identifiers. So there's a bit of a challenge here.
         
         Bookmap and pubmap-d both provide elements for ISBNs, book numbers,
         etc.
         
         The approach here is to get a sequence of book-identifying elements
         and then process them, using the first one in the sequence as
         the "bookid" as referenced from the OPF manifest.
         
    -->
    
    <xsl:variable name="bookids" as="element()*">
      <xsl:apply-templates mode="list-bookids"/>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="count($bookids) = 0">
        <dc:identifier id="bookid">no-bookid-value</dc:identifier>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="constructDcIdentifiers">
          <xsl:with-param name="bookids" select="$bookids" as="element()+"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>

  <xsl:template name="constructDcIdentifiers">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="bookids" as="element()+"/>
      
      <!-- $bookids is a list of elements that are specializations of 
           <data> and that represent some form of book ID.
      -->
      
      <xsl:apply-templates select="$bookids[1]" mode="bookid">
        <xsl:with-param name="id" select="'bookid'"/>
      </xsl:apply-templates>
    
  </xsl:template>
  
  <!-- ======================================
       Mode list-bookids, bookid
       ====================================== -->
  
  <xsl:template match="*[df:class(., 'bookmap/bookid')] | *[df:class(., 'pubmeta-d/pubid ')]" 
    mode="list-bookids">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- Assume that all topic/data children of bookid or pubid are identifiers. -->
    <xsl:sequence select="*[df:class(., 'topic/data')]"/>
  </xsl:template>
  
  <xsl:template match="text()" mode="list-bookids">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
  </xsl:template> 
  
  <xsl:template match="*[df:class(., 'bookmap/bookid')] | *[df:class(., 'pubmeta-d/pubid ')]" 
    mode="bookid">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/data')]" 
    mode="bookid">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="id" as="xs:string?" required="no"/>
    
    <xsl:variable name="schemeBase" as="xs:string"
      select="if (@name) then string(@name) else name(.)"
    />
    
    <xsl:variable name="scheme" as="xs:string"
      select="if (starts-with(lower-case($schemeBase), 'isbn')) then 'isbn' else $schemeBase"
    />
    <dc:identifier>
      <xsl:if test="$id">
        <xsl:attribute name="id" select="$id"/>
      </xsl:if>
      <xsl:sequence select="string(@value)"/>
      <xsl:apply-templates mode="#current"/>
    </dc:identifier>
  </xsl:template>
  
  <xsl:template mode="bookid" match="text()">
    <xsl:sequence select="."/>
  </xsl:template>
  
  <xsl:template match="*" mode="bookid" priority="-1">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- Do nothing by default -->
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'pubmap/pubid')]" mode="bookid">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:choose>
      <xsl:when test=".//*[df:class(., 'topic/data') and @name = 'epub-bookid']">
        <xsl:sequence select="normalize-space(.//*[df:class(., 'topic/data') and @name = 'epub-bookid'][1])"></xsl:sequence>
      </xsl:when>
      <xsl:when test="not(normalize-space(*[df:class(., 'pubmap/isbn-13')]) = '')">
        <xsl:sequence select="normalize-space(*[df:class(., 'pubmap/isbn-13')])"/>
      </xsl:when>
      <xsl:when test="not(normalize-space(*[df:class(., 'pubmap/isbn-10')]) = '')">
        <xsl:sequence select="normalize-space(*[df:class(., 'pubmap/isbn-10')])"/>
      </xsl:when>
      <xsl:when test="not(normalize-space(*[df:class(., 'pubmap/isbn')]) = '')">
        <xsl:sequence select="normalize-space(*[df:class(., 'pubmap/isbn')])"/>
      </xsl:when>
      <xsl:when test="not(normalize-space(*[df:class(., 'pubmap/issn-13')]) = '')">
        <xsl:sequence select="normalize-space(*[df:class(., 'pubmap/issn-13')])"/>
      </xsl:when>
      <xsl:when test="not(normalize-space(*[df:class(., 'pubmap/issn-10')]) = '')">
        <xsl:sequence select="normalize-space(*[df:class(., 'pubmap/issn-10')])"/>
      </xsl:when>
      <xsl:when test="not(normalize-space(*[df:class(., 'pubmap/issn')]) = '')">
        <xsl:sequence select="normalize-space(*[df:class(., 'pubmap/issn')])"/>
      </xsl:when>
      <xsl:when test="not(normalize-space(*[df:class(., 'pubmap/pubpartno')]) = '')">
        <xsl:sequence select="normalize-space(*[df:class(., 'pubmap/pubpartno')])"/>
      </xsl:when>
      <xsl:when test="not(normalize-space(*[df:class(., 'pubmap/pubnumber')]) = '')">
        <xsl:sequence select="normalize-space(*[df:class(., 'pubmap/pubnumber')])"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>{No publication ID}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/keywords')]" mode="generate-opf">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] generate-opf: handling topic/keywords</xsl:message>
    </xsl:if>
    <xsl:apply-templates select="*[df:class(., 'topic/keyword')]" mode="#current"/>
  </xsl:template>

  <xsl:template match="*[df:class(., 'topic/keyword')]" mode="generate-opf">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] generate-opf: handling topic/keyword</xsl:message>
    </xsl:if>
    <dc:subject><xsl:apply-templates/></dc:subject>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/data') and @name = 'opf-metadata']" mode="generate-opf">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:apply-templates select="*[df:class(., 'topic/data')]" mode="generate-opf-metadata"/>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/data')]" mode="generate-opf-metadata">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:variable name="value" as="xs:string"
      select="if (@value)
        then string(@value)
        else string(.)"
    />
    <!-- NOTE: This is the EPUB2 syntax for <meta> elements. Not sure how 
         to produce EPUB3 meta elements, where the @name attribute is replaced
         by a prefix-qualified property name.
      -->
    <meta name="{@name}" content="{$value}"/>
  </xsl:template>

  <xsl:template match="gmap:graphic-map" mode="epubtrans:manifest manifest">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="gmap:graphic-map-item" mode="epubtrans:manifest manifest">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:variable name="imageFilename" select="relpath:getName(@output-url)" as="xs:string"/>
    <xsl:variable name="imageExtension" select="lower-case(relpath:getExtension($imageFilename))" as="xs:string"/>
    <xsl:variable name="hrefPath" as="xs:string" 
      select="relpath:getParent(@output-url)"/>
    <xsl:variable name="imageHref" 
      select="relpath:newFile(relpath:getRelativePath($outdir, $hrefPath), $imageFilename)" as="xs:string"/>
    <xsl:if test="false()">
      <xsl:message> + [DEBUG]
        outdir      =<xsl:sequence select="$outdir"/>
        output-url  =<xsl:sequence select="string(@output-url)"/>
        hrefPath    =<xsl:sequence select="$hrefPath"/>
        imageHref   =<xsl:sequence select="$imageHref"/>
      </xsl:message>
    </xsl:if>
    <xsl:variable name="filenameHolder" as="element()">
      <gmap:filename extension="{$imageExtension}"
          name="{$imageFilename}"
      />
    </xsl:variable>
    <item id="{@id}" href="{$imageHref}">
      <xsl:attribute name="media-type">
        <xsl:apply-templates select="$filenameHolder" mode="getMimeType"/>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="$epubtrans:isEpub3">
          <!-- epub3 takes @properties: -->
          <xsl:sequence select="@properties"/>    
        </xsl:when>
        <xsl:otherwise>
          <!-- epub2 does not allow @properties -->
        </xsl:otherwise>
      </xsl:choose>
    </item>
  </xsl:template>
  
  <!-- ======================================
       Mode getMimeType
       ====================================== -->
  
  <xsl:template mode="getMimeType" match="gmap:filename" priority="10">
    <xsl:variable name="imageExtension" as="xs:string" select="@extension"/>
    <xsl:choose>
      <xsl:when test="$imageExtension = 'jpg'"><xsl:sequence select="'image/jpeg'"/></xsl:when>
      <xsl:when test="$imageExtension = 'jpeg'"><xsl:sequence select="'image/jpeg'"/></xsl:when>
      <xsl:when test="$imageExtension = 'gif'"><xsl:sequence select="'image/gif'"/></xsl:when>
      <xsl:when test="$imageExtension = 'png'"><xsl:sequence select="'image/png'"/></xsl:when>
      <xsl:when test="$imageExtension = 'svg'"><xsl:sequence select="'image/svg+xml'"/></xsl:when>
      <xsl:when test="$imageExtension = 'aac'"><xsl:sequence select="'audio/aac'"/></xsl:when>
      <xsl:when test="$imageExtension = ('mp1', 'mp2', 'mp3', 'mpg', 'mpeg')"><xsl:sequence select="'audio/mpeg'"/></xsl:when>
      <xsl:when test="$imageExtension = ('oga', 'ogg')"><xsl:sequence select="'audio/ogg'"/></xsl:when>
      <xsl:when test="$imageExtension = 'wav'"><xsl:sequence select="'audio/wav'"/></xsl:when>
      <xsl:when test="$imageExtension = 'm4a'"><xsl:sequence select="'audio/mp4'"/></xsl:when>
      <xsl:when test="$imageExtension = 'mp4'"><xsl:sequence select="'video/mp4'"/></xsl:when>
      <xsl:when test="$imageExtension = 'mov'"><xsl:sequence select="'video/mov'"/></xsl:when>
      <xsl:when test="$imageExtension = 'webm'"><xsl:sequence select="'video/webm'"/></xsl:when>
      <xsl:otherwise>
        <!-- Enable custom extensions to this logic -->
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  <xsl:template mode="getMimeType" match="gmap:filename" priority="0">
    <!-- Fallback handling. -->
    <xsl:variable name="imageExtension" as="xs:string" select="@extension"/>
    <xsl:message> - [WARN] Image extension "<xsl:sequence select="$imageExtension"/>" not recognized, may not work with ePub viewers.</xsl:message>
    <xsl:sequence select="concat('application/', lower-case($imageExtension))"/>    
  </xsl:template>
  
  <xsl:function name="local:includeTopicrefInSpine" as="xs:boolean">
    <xsl:param name="context" as="element()"/>
    <xsl:variable name="test">
      <xsl:apply-templates select="$context" mode="include-topicref-in-spine"/>
    </xsl:variable>
    <xsl:variable name="result" as="xs:boolean" select="$test = 'true'"/>
    <xsl:if test="$result and true()">
      <xsl:message> + [DEBUG] local:includeTopicrefInSpine: Including element "<xsl:sequence select="name($context)"/>" in spine.</xsl:message>
    </xsl:if>
    <xsl:sequence select="$result"/>
  </xsl:function>  
  
  <xsl:function name="local:includeTopicrefInManifest" as="xs:boolean">
    <xsl:param name="context" as="element()"/>
    <xsl:variable name="test">
      <xsl:apply-templates select="$context" mode="include-topicref-in-manifest"/>
    </xsl:variable>
    <xsl:variable name="result" as="xs:boolean" select="$test = 'true'"/>
    <xsl:if test="$result and false()">
      <xsl:message> + [DEBUG] local:includeTopicrefInSpine: Including element "<xsl:sequence select="name($context)"/>" in manifest.</xsl:message>
    </xsl:if>
    <xsl:sequence select="$result"/>
  </xsl:function>  
  
  <!-- ======================================
       Mode include-topicref-in-spine
       ====================================== -->
  
  <xsl:template mode="include-topicref-in-spine" match="*">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- Do nothing, don't explicitly include by default. -->
  </xsl:template>
  
  <xsl:template mode="include-topicref-in-manifest" match="*">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- Do nothing, don't explicitly include by default. -->
  </xsl:template>
  
  <xsl:template match="text()" 
    mode="generate-opf 
          manifest guide 
          include-topicref-in-manifest 
          include-topicref-in-spine">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
  </xsl:template>
</xsl:stylesheet>
