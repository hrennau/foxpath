<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:index-terms="http://dita4publishers.org/index-terms"
  xmlns:enum="http://dita4publishers.org/enumerables"
  xmlns:glossdata="http://dita4publishers.org/glossdata"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:mapdriven="http://dita4publishers.org/mapdriven"
  xmlns:epubtrans="urn:d4p:epubtranstype"
  exclude-result-prefixes="xs xd df relpath epubtrans"
  version="2.0">

  <!-- =============================================================

       DITA Map to EPUB Transformation

       Copyright (c) 2010, 2016 DITA For Publishers

       Licensed under Common Public License v1.0 or the Apache Software Foundation License v2.0.
       The intent of this license is for this material to be licensed in a way that is
       consistent with and compatible with the license of the DITA Open Toolkit.

       This transform requires XSLT 2.

       This transform is the root transform and manages the generation
       of the following distinct artifacts that make up a complete
       ePub publication:

       1. content.opf file, which defines the contents and publication metadata for the ePub
       2. toc.ncx, which defines the navigation table of contents for the ePub (when producing
          an EPUB2 or dual EPUB2/3 EPUB).
       2. nav.xhtml, the EPUB3 navigation table of contents (when producing an EPUB3)
       3. The HTML content, generated from the map and topics referenced by the input map.
       4. An input-file-to-output-file map document that is used to copy referenced non-XML
          objects to the appropriate output location.

       This process flattens the resulting HTML such that file system organization of the
       input map does not matter as far as the ePub organization is concerned.

       The input to this transform is a fully-resolved map. All processing of maps
       and topics is driven by references from the map.

       All files produced by this transform use xsl:result document. The primary
       output should be named deleteme.txt. It should be empty but extensions
       may inadvertently output data outside the scope of a containing xsl:result-document
       instruction.
       ============================================================== -->

<!-- These two libraries end up getting imported via the dita2xhtml.xsl from the main toolkit
     because the base XSL support lib is integrated into that file. So these inclusions are redundant.
  <xsl:import href="../../org.dita-community.common.xslt/xsl/dita-support-lib.xsl"/>
  <xsl:import href="../../org.dita-community.common.xslt/xsl/relpath_util.xsl"/>
  -->
  <xsl:import href="plugin:org.dita-community.common.mapdriven:xsl/dataCollection.xsl"/>

  <xsl:import href="plugin:org.dita4publishers.common.xslt:xsl/reportParametersBase.xsl"/>
  <xsl:import href="plugin:org.dita4publishers.common.html:xsl/html-generation-utils.xsl"/>
  <!-- Import the base HTML output generation transform. -->
  <xsl:import href="plugin:org.dita.xhtml:xsl/dita2xhtml.xsl"/>

  <xsl:import href="plugin:org.dita4publishers.common.mapdriven:xsl/mapdrivenEnumerationD4P.xsl"/>
  <xsl:import href="plugin:org.dita4publishers.common.xslt:xsl/map2graphicMap.xsl"/>
  <xsl:import href="plugin:org.dita4publishers.common.xslt:xsl/graphicMap2AntCopyScript.xsl"/>
  <xsl:import href="plugin:org.dita4publishers.common.xslt:xsl/topicHrefFixup.xsl"/>

  <xsl:include href="plugin:org.dita4publishers.common.html:xsl/commonHtmlOverrides.xsl"/>
  <xsl:include href="plugin:org.dita4publishers.common.html:xsl/commonHtmlEnumeration.xsl"/>
  <xsl:include href="plugin:org.dita4publishers.common.html:xsl/commonHtmlBookmapEnumeration.xsl"/>
  <xsl:include href="plugin:org.dita4publishers.common.html:/xsl/map2htmlIndex.xsl"/>


  <xsl:include href="map2epubCommon.xsl"/>
  <xsl:include href="map2epubOpfImpl.xsl"/>
  <xsl:include href="map2epubBookLists.xsl"/>
  <xsl:include href="map2epubContentImpl.xsl"/>
  <xsl:include href="map2epubSetCoverGraphic.xsl"/>
  <xsl:include href="map2epubHtmlTocImpl.xsl"/>
  <xsl:include href="map2epubListOfFigures.xsl"/>
  <xsl:include href="map2epubListOfTables.xsl"/>
  <xsl:include href="map2epubNavImpl.xsl"/>
  <xsl:include href="map2epubTocImpl.xsl"/>
  <xsl:include href="map2epubEmbedFonts.xsl"/>
  <xsl:include href="map2epubIncludeJavaScript.xsl"/>
  <!--  <xsl:include href="map2epubIndexImpl.xsl"/>-->
  <xsl:include href="html2xhtmlImpl.xsl"/>
  <xsl:include href="epubHtmlOverrides.xsl"/>


  <xsl:include href="map2epubD4PImpl.xsl"/>
  <xsl:include href="map2epubBookmapImpl.xsl"/>

  <!-- Initial part of EPUB ID URI. Should reflect the book's
       owner.
    -->
  <xsl:param name="idURIStub" select="'http://example.org/dummy/URIstub/'" as="xs:string"/>

  <xsl:param name="tempFilesDir" select="'tempFilesDir value not passed'" as="xs:string"/>

  <!-- XSLT document function needs full URI for parameter, so this is
    used for that. -->
  <xsl:variable name="inputURLstub" as="xs:string"
    select="concat('file:///', translate($tempFilesDir,':\','|/'), '/')"/>

  <!--
       NOTE: As of OT 2.0, there is no Ant parameter that provides the input directory,
             so we use the @xtrf attribute to get the directory containing the input
             map.
    -->
  <xsl:param name="inputdir" select="relpath:getParent(relpath:getParent(/*/@xtrf))" as="xs:string"/>
  <!-- Directory into which the generated output is put.

       This should be the directory that will be zipped up to
       produce the final ePub package.
       -->
  <xsl:param name="outdir" select="./epub"/>
  <xsl:param name="outext" select="'.xhtml'"/>
  <xsl:param name="OUTEXT" select="$outext" as="xs:string"/>
  <xsl:param name="tempdir" select="./temp"/>

  <!-- Used by the copied map2htmtoc.xsl: -->
  <xsl:param name="FILEREF" select="'file://'"/>

 <!-- The path of the directory, relative the $outdir parameter,
    to hold the graphics in the EPub package. Should not have
    a leading "/".
  -->
  <xsl:param name="imagesOutputDir" select="'images'" as="xs:string"/>
  <!-- The path of the directory, relative the $outdir parameter,
    to hold the topics in the EPub package. Should not have
    a leading "/".
  -->
  <xsl:param name="topicsOutputDir" select="'topics'" as="xs:string"/>

  <!-- The path of the directory, relative to the $outdir parameter,
       to hold any fonts embedded in the EPUB.
    -->
  <xsl:param name="fontsOutputDir" select="'fonts'" as="xs:string"/>
  
  <xsl:param name="epubGenerateCSSFontRules" select="'false'" as="xs:string"/>
  <xsl:variable name="epubtrans:doGenerateCSSFontRules" 
    select="matches($epubGenerateCSSFontRules, '1|yes|true|on', 'i')" 
    as="xs:boolean"
  />
  
  <!-- The path of the directory, relative the $outdir parameter,
    to hold the CSS files in the EPub package. Should not have
    a leading "/".

    NOTE: cssOutputDir is obsolete as of D4P 1.0 as it's redundant
    with the CSSPATH parameter. CSSPATH is used in some common code
    to set the CSS output path.
  -->
  <xsl:param name="cssOutputDir" select="'css'" as="xs:string"/>
  <!-- As far as I can tell from the base Ant scripts, CSSPATH will always
       have a value, even if it's an empty string.
    -->
  <xsl:param name="CSSPATH" as="xs:string" select="$cssOutputDir"/>
  <!-- The relative path from $outdir to the CSS directory. This must be the same
       as CSSPATH because CSSPATH is used in some HTML output code.
    -->
  <xsl:variable name="cssOutDir" as="xs:string">
    <xsl:if test="$cssOutputDir != $CSSPATH">
      <xsl:message> + [WARN] The cssOutputDir parameter value ("<xsl:value-of select="$cssOutputDir"/>") != CSSPATH parameter value ("<xsl:value-of select="$CSSPATH"/>"). CSSPATH will be used.</xsl:message>
    </xsl:if>
    <xsl:sequence select="$CSSPATH"/>
  </xsl:variable>
  <!-- Trigger resolution of the cssOutDir variable so we get any messages: -->
  <xsl:variable name="_gargage">
    <xsl:message><xsl:value-of select="if ($cssOutDir != $cssOutputDir) then '' else ''"/></xsl:message>
  </xsl:variable>


  <xsl:param name="debug" select="'false'" as="xs:string"/>

  <xsl:param name="rawPlatformString" select="'unknown'" as="xs:string"/><!-- As provided by Ant -->

  <xsl:param name="titleOnlyTopicClassSpec" select="'- topic/topic '" as="xs:string"/>

  <xsl:param name="titleOnlyTopicTitleClassSpec" select="'- topic/title '" as="xs:string"/>

  <!-- Maxminum depth of the generated HTML ToC -->
  <xsl:param name="maxTocDepth" as="xs:string" select="'5'"/>

  <!-- Maxminum depth of the generated navigation ToC -->
  <xsl:param name="maxNavDepth" as="xs:string" select="$maxTocDepth"/>

  <!-- Include literal HTML ToC page as for normal HTML output.
  -->

  <xsl:param name="generateHtmlToc" as="xs:string" select="'no'"/>
  <xsl:variable name="generateHtmlTocBoolean"
    select="matches($generateHtmlToc, 'yes|true|on|1', 'i')"
  />

  <xsl:param name="html.toc.OUTPUTCLASS" as="xs:string" select="''"/>

  <!--
    The strategy to use when constructing output files. Default is "as-authored".
  -->
  <xsl:param name="fileOrganizationStrategy" as="xs:string" select="'as-authored'"/>

  <xsl:param name="generateIndex" as="xs:string" select="'no'"/>
  <xsl:variable name="generateIndexBoolean"
    select="matches($generateIndex, 'yes|true|on|1', 'i')"
  />

  <!-- Generate the glossary dynamically using all glossary entry
    topics included in the map.
  -->
  <xsl:param name="generateGlossary" as="xs:string" select="'no'"/>
  <xsl:variable name="generateGlossaryBoolean"
    select="matches($generateGlossary, 'yes|true|on|1', 'i')"
  />

  <!-- Absolute URI of the graphic to use for the cover. Specify
       when the source markup does not enable determination
       of the cover graphic.
    -->
  <xsl:param name="coverGraphicUri" as="xs:string" select="''" />
  
  <!-- The URI of the epub font manifest file used to manage embedding 
       of fonts in the EPUB file. The file must be an XML document
       valid to the urn:dita4publishers:doctypes:font-manifest:rng:font-manifest.rng
       grammar included in the DITA for Publisher doctypes plugin.
    -->
  <xsl:param name="epubFontManifestUri" as="xs:string?"/>

  <!-- NOTE: These parameters are used by the math-d2html XSLT code -->

  <xsl:param name="mathJaxInclude" select="'false'"/>
  <xsl:param name="mathJaxIncludeBoolean"
    select="matches($mathJaxInclude, 'yes|true|on|1', 'i')"
    as="xs:boolean"
  />

  <xsl:param name="mathJaxUseCDNLinkBoolean" select="false()" as="xs:boolean"/><!-- For EPUB, can't use remote version -->

  <xsl:param name="mathJaxUseLocalLinkBoolean"
    select="$mathJaxIncludeBoolean"
    as="xs:boolean"
  />

  <!-- FIXME: Parameterize the location of the JavaScript directory -->
  <xsl:param name="mathJaxLocalJavascriptUri" select="'js/mathjax/MathJax.js'"/>

  <xsl:variable name="coverImageId" select="'coverimage'" as="xs:string"/>

  <!-- Generate the OPF package bindings section. -->
  <xsl:param name="generateBindings" as="xs:string" select="'no'"/>
  <xsl:variable name="epubtrans:doGenerateBindings" as="xs:boolean"
    select="matches($generateBindings, 'yes|true|on|1', 'i')"
  />

  <!-- Generate the OPF package collections section. -->
  <xsl:param name="generateCollections" as="xs:string" select="'no'"/>
  <xsl:variable name="epubtrans:doGenerateCollections" as="xs:boolean"
    select="matches($generateCollections, 'yes|true|on|1', 'i')"
  />

  <!-- The URI of the epub font manifest file used to manage embedding 
       of fonts in the EPUB file. The file must be an XML document
       valid to the urn:dita4publishers:doctypes:font-manifest:rng:font-manifest.rng
       grammar included in the DITA for Publisher doctypes plugin.
    -->
  <xsl:param name="epubFontManifestURI" as="xs:string?"/>  
  
  <!-- Apply font obfuscation to any font in the font manifest that
       turns obfuscation on.
    -->
  <xsl:param name="obfuscateFonts" as="xs:string" select="'no'"/>
  <xsl:variable name="epubtrans:doObfuscateFonts" as="xs:boolean"
    select="matches($obfuscateFonts, 'yes|true|on|1', 'i')"
  />
  
  <!-- The type of EPUB to be generated: EPUB3 only ('epub3'),
       EPUB2 only ('epub2'), or dual EPUB3/EPUB2 ('dual').
       Dual is the default.
    -->
  <xsl:param name="epubType" as="xs:string" select="'dual'"/>
  <xsl:variable name="epubtrans:doIncludeEpub2" as="xs:boolean"
    select="matches($epubType, 'dual', 'i')"
  />
  <!-- Are we producing a dual EPUB3/EPUB2 EPUB? -->
  <xsl:variable name="epubtrans:isDualEpub" as="xs:boolean"
    select="matches($epubType, 'dual', 'i')"
  />
  <!-- Are we producing an EPUB3-only EPUB (not a dual EPUB) -->
  <xsl:variable name="epubtrans:isEpub3" as="xs:boolean"
    select="matches($epubType, 'epub3|dual', 'i')"
  />
  <!-- Are we producing an EPUB2-only EPUB (not a dual EPUB) -->
  <xsl:variable name="epubtrans:isEpub2" as="xs:boolean"
    select="matches($epubType, 'epub2', 'i')"
  />

  <!-- Specifies the set of EPUB3 navigation pages to generated
       as a list of blank-delimited tokens.

       E.g, "toc lot lof" (Toc, list of tables, list of figures).

       The keywords should be taken from the list defined in the EPUB
       spec: http://www.idpf.org/epub/vocab/structure/#h_navigation.
       This transform adds "lof" (list of figures). The EPUB spec allows
       use of values not defined in the EPUB spec.

       The default value is "toc", the normal navigation table of contents.
    -->
  <xsl:param name="epubNavTypes" as="xs:string" select="'toc'"/>
  <xsl:variable name="baseNavTypes" as="xs:string*"
    select="tokenize($epubNavTypes, ' ')"
  />
  <!-- EPUB3 requires a 'toc' navigation -->
  <xsl:variable name="navTypes" as="xs:string+"
    select="if (not('toc' = $baseNavTypes))
               then ('toc', $baseNavTypes)
               else $baseNavTypes"
  />
  <!-- used to resolved outer image -->
  <xsl:param name="uplevels" select="''" />

  <!-- Used to determine whether to include DITA-OT default CSS files -->
  <xsl:param name="copySystemCssNo" select="'false'" />
  
  <xsl:variable name="copySystemCssNoBoolean" as="xs:boolean" select="matches($copySystemCssNo,'yes|true|on|1','i')" />
  
  <!-- JavaScript file to include in all HTML files -->
  <xsl:param name="javaScriptSourceFile" as="xs:string?"/>
  <!-- Directory to store the JavaScript file in in the EPUB package. -->
  <xsl:param name="javaScriptOutputDir" as="xs:string" select="'js'"/>
  
  <!-- Used by some HTML output stuff. For EPUB, don't want links to
       go to a new window.
    -->
  <xsl:variable name="contenttarget" as="xs:string" select="''"/>

  <xsl:key name="elementsById" match="*[@id]" use="@id"/>
  <xsl:key name="elementsByXtrc" match="*[@xtrc]" use="@xtrc"/>

  <xsl:template name="report-parameters" match="*" mode="report-parameters">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="effectiveCoverGraphicUri" select="''" as="xs:string" tunnel="yes"/>
    <xsl:param name="epubBookID" as="xs:string"/>
    
    <xsl:message>
      ==========================================
      Plugin version: ^version^ - build ^buildnumber^ at ^timestamp^

      Parameters:

      + coverGraphicUri = "<xsl:sequence select="$coverGraphicUri"/>"
      + epubType        = "<xsl:sequence select="$epubType"/>"
      + generateBindings= "<xsl:sequence select="$epubtrans:doGenerateBindings"/>"
      + generateCollections= "<xsl:sequence select="$epubtrans:doGenerateCollections"/>"
      + generateGlossary= "<xsl:sequence select="$generateGlossary"/>"
      + generateHtmlToc = "<xsl:sequence select="$generateHtmlToc"/>"
      + maxTocDepth     = "<xsl:sequence select="$maxTocDepth"/>"
      + maxNavDepth     = "<xsl:sequence select="$maxNavDepth"/>"
      + generateIndex   = "<xsl:sequence select="$generateIndex"/>"
      + imagesOutputDir = "<xsl:sequence select="$imagesOutputDir"/>"
      + imagesOutputDir = "<xsl:sequence select="$imagesOutputDir"/>"
      + mathJaxInclude  = "<xsl:sequence select="$mathJaxInclude"/>"
      + mathJaxConfigParam = "<xsl:sequence select="$mathJaxConfigParam"/>"
      + mathJaxLocalJavascriptUri= "<xsl:sequence select="$mathJaxLocalJavascriptUri"/>"
      + outdir          = "<xsl:sequence select="$outdir"/>"
      + tempdir         = "<xsl:sequence select="$tempdir"/>"
      + titleOnlyTopicClassSpec = "<xsl:sequence select="$titleOnlyTopicClassSpec"/>"
      + titleOnlyTopicTitleClassSpec = "<xsl:sequence select="$titleOnlyTopicTitleClassSpec"/>"
      + topicsOutputDir = "<xsl:sequence select="$topicsOutputDir"/>"
      + fontsOutputDir  = "<xsl:sequence select="$fontsOutputDir"/>"
      + epubFontManifestUri = "<xsl:sequence select="$epubFontManifestUri"/>"
      + obfuscateFonts  = "<xsl:sequence select="$obfuscateFonts"/>"
      + copySystemCssNo = "<xsl:sequence select="$copySystemCssNo"/>"
      + epubGenerateCSSFontRules = "<xsl:sequence select="$epubGenerateCSSFontRules"/>"
      
      
      + WORKDIR         = "<xsl:sequence select="$WORKDIR"/>"
      + PATH2PROJ       = "<xsl:sequence select="$PATH2PROJ"/>"
      + KEYREF-FILE     = "<xsl:sequence select="$KEYREF-FILE"/>"
      + CSS             = "<xsl:sequence select="$CSS"/>"
      + CSSPATH         = "<xsl:sequence select="$CSSPATH"/>"
      + debug           = "<xsl:sequence select="$debug"/>"

      Global Variables:

      + cssOutDir        = "<xsl:sequence select="$cssOutDir"/>"
      + effectiveCoverGraphicUri = "<xsl:sequence select="$effectiveCoverGraphicUri"/>"
      + topicsOutputPath = "<xsl:sequence select="$topicsOutputPath"/>"
      + imagesOutputPath = "<xsl:sequence select="$imagesOutputPath"/>"
      + platform         = "<xsl:sequence select="$platform"/>"
      + debugBoolean     = "<xsl:sequence select="$debugBoolean"/>"
      + epubtrans:isEpub3     = "<xsl:sequence select="$epubtrans:isEpub3"/>"
      + epubtrans:isEpub2     = "<xsl:sequence select="$epubtrans:isEpub2"/>"
      + epubtrans:isDualEpub  = "<xsl:sequence select="$epubtrans:isDualEpub"/>"
      + epubtrans:doObfuscateFonts = "<xsl:sequence select="$epubtrans:doObfuscateFonts"/>"
      + epubtrans:doGenerateCSSFontRules = "<xsl:sequence select="$epubtrans:doGenerateCSSFontRules"/>"
      + epubBookID       = "<xsl:sequence select="$epubBookID"/>"

      ==========================================
    </xsl:message>
    <xsl:apply-templates select="." mode="extension-report-parameters"/>
  </xsl:template>


  <xsl:output method="xml" name="indented-xml"
    indent="yes"
  />
  <xsl:output name="html5" method="xhtml"
    indent="yes"
    encoding="utf-8"
    doctype-system="about:legacy-compat"
    omit-xml-declaration="yes"
    include-content-type="no"
  />

  <xsl:variable name="maxTocDepthInt" select="xs:integer($maxTocDepth)" as="xs:integer"/>
  <xsl:variable name="maxNavDepthInt" select="xs:integer($maxNavDepth)" as="xs:integer"/>


  <xsl:variable name="platform" as="xs:string"
    select="
    if (starts-with($rawPlatformString, 'Win') or
        starts-with($rawPlatformString, 'Win'))
       then 'windows'
       else 'nx'
    "
  />

  <xsl:variable name="debugBinary" select="$debug = 'true'" as="xs:boolean"/>

  <xsl:variable name="topicsOutputPath">
      <xsl:choose>
        <xsl:when test="$topicsOutputDir != ''">
          <xsl:sequence select="concat($outdir, $topicsOutputDir)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$outdir"/>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:variable>

  <xsl:variable name="imagesOutputPath">
      <xsl:choose>
        <xsl:when test="$imagesOutputDir != ''">
          <xsl:sequence select="concat($outdir,
            if (ends-with($outdir, '/')) then '' else '/',
            $imagesOutputDir)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$outdir"/>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:variable>

  <xsl:variable name="cssOutputPath">
    <xsl:choose>
      <xsl:when test="$cssOutDir != ''">
        <xsl:sequence select="relpath:newFile($outdir, $cssOutDir)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$outdir"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="fontsOutputPath">
    <xsl:choose>
      <xsl:when test="$fontsOutputDir != ''">
        <xsl:sequence select="relpath:newFile($outdir, $fontsOutputDir)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$outdir"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="javascriptOutputPath">
    <xsl:choose>
      <xsl:when test="$javaScriptOutputDir != ''">
        <xsl:sequence select="relpath:newFile($outdir, $javaScriptOutputDir)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$outdir"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  

  <xsl:template match="/">
    <xsl:if test="$debugBoolean">
        <xsl:message> + [DEBUG] Root template in default mode. Root element is "<xsl:sequence select="name(/*[1])"/>", class="<xsl:sequence select="string(/*[1]/@class)"/>:</xsl:message>
    </xsl:if>
    <xsl:apply-templates>
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
      <xsl:with-param name="rootMapDocUrl" select="document-uri(.)" as="xs:string" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="/*[df:class(., 'map/map')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>

    <xsl:variable name="effectiveCoverGraphicUri" as="xs:string">
      <xsl:apply-templates select="." mode="get-cover-graphic-uri"/>
    </xsl:variable>
    
    <!-- Get the EPUB book ID as used for font obfuscation, among
         other things.
         
      -->
    <xsl:variable name="epubBookID" as="xs:string">
      <xsl:choose>
        <xsl:when test="*[df:class(., 'map/topicmeta')]">
          <xsl:variable name="dcIdentifier" as="node()*">
            <xsl:apply-templates select="*[df:class(., 'map/topicmeta')]" mode="bookid">
              <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            </xsl:apply-templates>
          </xsl:variable>
          <xsl:variable name="candBookID" select="normalize-space($dcIdentifier)"/>
          <xsl:sequence select="if (matches($candBookID, '^\s*$')) 
                                   then 'no-bookid-value' 
                                   else $candBookID"
          />
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="'no-bookid-value'"/>
        </xsl:otherwise>
      </xsl:choose>      
    </xsl:variable>

    <!-- FIXME: Add mode to get effective front cover topic URI so we
         can generate <guide> entry for the cover page. Also provides
         extension point for synthesizing the cover if it's not
         explicit in the map.
    -->

    <!--<xsl:apply-templates select="." mode="report-parameters">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
      <xsl:with-param name="effectiveCoverGraphicUri" select="$effectiveCoverGraphicUri" as="xs:string" tunnel="yes"/>
      <xsl:with-param name="epubBookID" as="xs:string" select="$epubBookID"/>
    </xsl:apply-templates>-->

    <xsl:variable name="graphicMap" as="element()">
      <xsl:apply-templates select="." mode="generate-graphic-map">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
        <xsl:with-param name="effectiveCoverGraphicUri" select="$effectiveCoverGraphicUri" as="xs:string" tunnel="yes"/>
        <xsl:with-param name="uplevels" select="$uplevels" as="xs:string" tunnel="yes" />
        <xsl:with-param name="epubBookID" as="xs:string" tunnel="yes" select="$epubBookID"/>
      </xsl:apply-templates>
    </xsl:variable>
    
    <xsl:if test="$epubtrans:doGenerateCSSFontRules">
      <xsl:call-template name="epubtrans:generateCSSFontRules">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
      </xsl:call-template>
    </xsl:if>
    

    <xsl:message> + [INFO] Collecting data for index generation, enumeration, etc....</xsl:message>

    <xsl:variable name="collected-data" as="element()">
      <xsl:call-template name="mapdriven:collect-data">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] Writing file <xsl:sequence select="relpath:newFile($outdir, 'collected-data.xml')"/>...</xsl:message>
      <xsl:result-document href="{relpath:newFile($outdir, 'collected-data.xml')}"
        format="indented-xml"
        >
        <xsl:sequence select="$collected-data"/>
      </xsl:result-document>
    </xsl:if>

    <xsl:result-document href="{relpath:newFile($outdir, 'graphicMap.xml')}" format="graphic-map"
      >
      <xsl:sequence select="$graphicMap"/>
    </xsl:result-document>
    <xsl:call-template name="make-meta-inf">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
      <xsl:with-param name="epubBookID" as="xs:string" tunnel="yes" select="$epubBookID"/>
    </xsl:call-template>
    <xsl:call-template name="make-mimetype">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
      <xsl:with-param name="epubBookID" as="xs:string" tunnel="yes" select="$epubBookID"/>
    </xsl:call-template>

    <xsl:message> + [INFO] Generating EPUB content components...</xsl:message>

    <xsl:apply-templates select="." mode="generate-content">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
      <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
      <xsl:with-param name="epubBookID" as="xs:string" tunnel="yes" select="$epubBookID"/>
    </xsl:apply-templates>
    <xsl:if test="$epubtrans:isEpub3">
      <xsl:if test="$doDebug">
        <xsl:message> + [DEBUG] generating EPUB3 nav</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="." mode="epubtrans:generate-nav">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
        <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
        <xsl:with-param name="epubBookID" as="xs:string" tunnel="yes" select="$epubBookID"/>
      </xsl:apply-templates>
      <xsl:if test="$doDebug">
        <xsl:message> + [DEBUG] after generate-nav</xsl:message>
      </xsl:if>
    </xsl:if>
    <!-- NOTE: The generate-toc mode is for the EPUB2 toc.ncx, not the HTML toc -->
    <xsl:if test="$epubtrans:isEpub2 or $epubtrans:isDualEpub">
      <xsl:if test="$doDebug">
        <xsl:message> + [DEBUG] generating EPUB2 toc.ncx...</xsl:message>
      </xsl:if>
      <xsl:apply-templates select="." mode="generate-toc">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
        <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
        <xsl:with-param name="epubBookID" as="xs:string" tunnel="yes" select="$epubBookID"/>
      </xsl:apply-templates>
      <xsl:if test="$doDebug">
        <xsl:message> + [DEBUG] after generate-toc</xsl:message>
      </xsl:if>
    </xsl:if>
    <xsl:message> + [INFO] Generating back-of-book index (if requested)...</xsl:message>
    <xsl:apply-templates select="." mode="generate-index">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
      <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
      <xsl:with-param name="epubBookID" as="xs:string" tunnel="yes" select="$epubBookID"/>
    </xsl:apply-templates>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] after generate-index</xsl:message>
    </xsl:if>
    <xsl:message> + [INFO] Generating book lists (toc, figlist, etc.)...</xsl:message>
    <xsl:apply-templates select="." mode="generate-book-lists">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
      <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
      <xsl:with-param name="epubBookID" as="xs:string" tunnel="yes" select="$epubBookID"/>
    </xsl:apply-templates>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] after generate-book-lists</xsl:message>
    </xsl:if>
    <xsl:message> + [INFO] Generating OPF file...</xsl:message>
    <xsl:apply-templates select="." mode="generate-opf">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
      <xsl:with-param name="graphicMap" as="element()" tunnel="yes" select="$graphicMap"/>
      <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
      <xsl:with-param name="effectiveCoverGraphicUri" select="$effectiveCoverGraphicUri" as="xs:string" tunnel="yes"/>
      <xsl:with-param name="epubBookID" as="xs:string" tunnel="yes" select="$epubBookID"/>
    </xsl:apply-templates>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] after generate-opf</xsl:message>
    </xsl:if>
    <xsl:message> + [INFO] Generating graphic copy Ant script...</xsl:message>
    <xsl:apply-templates select="." mode="generate-graphic-copy-ant-script">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
      <xsl:with-param name="graphicMap" as="element()" tunnel="yes" select="$graphicMap"/>
      <xsl:with-param name="epubBookID" as="xs:string" tunnel="yes" select="$epubBookID"/>
    </xsl:apply-templates>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] after generate-graphic-copy-ant-script</xsl:message>
    </xsl:if>
  </xsl:template>

  <xsl:template name="make-meta-inf">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:result-document href="{relpath:newFile(relpath:newFile($outdir, 'META-INF'), 'container.xml')}"
      format="indented-xml" exclude-result-prefixes="enum index-terms glossdata mapdriven"
      >
      <container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
        <rootfiles>
          <rootfile full-path="content.opf" media-type="application/oebps-package+xml"/>
        </rootfiles>
      </container>
    </xsl:result-document>
  </xsl:template>

  <xsl:template name="make-mimetype">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:result-document href="{relpath:newFile($outdir, 'mimetype')}" method="text">
      <xsl:text>application/epub+zip</xsl:text>
    </xsl:result-document>
  </xsl:template>


</xsl:stylesheet>
