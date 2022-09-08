<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:index-terms="http://dita4publishers.org/index-terms"
  xmlns:relpath="http://dita2indesign/functions/relpath" exclude-result-prefixes="xs xd df relpath"
  version="2.0">

  <!-- =============================================================
    
       DITA Map to Kindle Transformation
       
       Copyright (c) 2010 DITA For Publishers
       
       Licensed under Common Public License v1.0 or the Apache Software Foundation License v2.0.
       The intent of this license is for this material to be licensed in a way that is
       consistent with and compatible with the license of the DITA Open Toolkit.
       
       This transform requires XSLT 2.
       
       This transform is the root transform and manages the generation
       of the following distinct artifacts that make up a complete
       Kindle publication:
       
       1. content.opf file, which defines the contents and publication metadata for the publicatio.
       2. toc.ncx, which defines the navigation table of contents for the pub.
       3. The HTML content, generated from the map and topics referenced by the input map.
       4. An input-file-to-output-file map document that is used to copy referenced non-XML
          objects to the appropriate output location.
       
       This process flattens the resulting HTML such that file system organization of the 
       input map does not matter as far as the Kindle organization is concerned.
       
       The input to this transform is a fully-resolved map. All processing of maps
       and topics is driven by references from the map.
       
       All files produced by this transform use xsl:result document. The primary
       output should be named deleteme.txt. It should be empty but extensions 
       may inadvertently output data outside the scope of a containing xsl:result-document
       instruction.
       ============================================================== -->
  
  <!-- These two libraries end up getting imported via the dita2xhtml.xsl from the main toolkit
     because the base XSL support lib is integrated into that file. So these inclusions are redundant.
  <xsl:import href="../../net.sourceforge.dita4publishers.common.xslt/xsl/lib/dita-support-lib.xsl"/>
  <xsl:import href="../../net.sourceforge.dita4publishers.common.xslt/xsl/lib/relpath_util.xsl"/>
  -->
  
  <xsl:import href="../../net.sourceforge.dita4publishers.common.xslt/xsl/lib/html-generation-utils.xsl"/>
  
  <xsl:import
    href="../../net.sourceforge.dita4publishers.common.xslt/xsl/graphicMap2AntCopyScript.xsl"/>
  <xsl:import href="../../net.sourceforge.dita4publishers.common.xslt/xsl/map2graphicMapImpl.xsl"/>
  <xsl:import href="../../net.sourceforge.dita4publishers.common.xslt/xsl/topicHrefFixup.xsl"/>
  
  <xsl:import href="../../net.sourceforge.dita4publishers.epub/xsl/html2xhtmlImpl.xsl"/>

  <!-- Import the base HTML output generation transform. -->
  <xsl:import href="plugin:org.dita.xhtml:xsl/dita2xhtml.xsl"/>
  <xsl:import href="kindle-generation-utils.xsl"/>
  
  <xsl:include href="../../net.sourceforge.dita4publishers.common.html/xsl/commonHtmlOverrides.xsl"/>
  <xsl:include href="../../net.sourceforge.dita4publishers.common.html/xsl/commonHtmlEnumeration.xsl"/>
  <xsl:include href="../../net.sourceforge.dita4publishers.common.html/xsl/commonHtmlBookmapEnumeration.xsl"/>
  
  <xsl:include href="map2kindleCommon.xsl"/>
  <xsl:include href="map2kindleOpfImpl.xsl"/>
  <xsl:include href="map2kindleContentImpl.xsl"/>
  <xsl:include href="map2kindleSetCoverGraphic.xsl"/>
  <xsl:include href="map2kindleTocImpl.xsl"/>
  <!-- ======================================== -->
  <!-- ============= the html toc ============= -->
  <xsl:include href="map2kindleHtmlTocImpl.xsl"/>
  <!-- ======================================== -->
  <xsl:include href="map2kindleIndexImpl.xsl"/>
  <xsl:include href="kindleHtmlOverrides.xsl"/>

  <xsl:include href="map2kindleD4PImpl.xsl"/>
  <xsl:include href="map2kindleBookmapImpl.xsl"/>

  <!-- Initial part of ePUB ID URI. Should reflect the book's
       owner.
    -->
  <xsl:param name="idURIStub">http://example.org/dummy/URIstub/</xsl:param>

  <!-- Directory into which the generated output is put.

       This should be the directory that will be zipped up to
       produce the final ePub package.
       -->
  <xsl:param name="outdir" select="./kindle"/>
  <xsl:param name="outext" select="'.html'"/>
  <xsl:param name="tempdir" select="./temp"/>

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

  <!-- The path of the directory, relative the $outdir parameter,
    to hold the CSS files in the EPub package. Should not have
    a leading "/". 
  -->
  <xsl:param name="cssOutputDir" select="'topics'" as="xs:string"/>

  <xsl:param name="debug" select="'false'" as="xs:string"/>

  <xsl:param name="rawPlatformString" select="'unknown'" as="xs:string"/>
  <!-- As provided by Ant -->

  <xsl:param name="titleOnlyTopicClassSpec" select="'- topic/topic '" as="xs:string"/>

  <xsl:param name="titleOnlyTopicTitleClassSpec" select="'- topic/title '" as="xs:string"/>

  <!-- Maxminum depth of the generated ToC -->
  <xsl:param name="maxTocDepth" as="xs:string" select="'5'"/>

  <!-- 
    The strategy to use when constructing output files. Default is "single-dir", meaning
    put all result topics in the same output directory (as specified by $topicsOutputDir)
  -->         
  <xsl:param name="fileOrganizationStrategy" as="xs:string" select="'single-dir'"/>

  <!-- Include back-of-the-book-index if any index entries in source 
  
       For now default to no since index generation is still under development.
  -->
  <xsl:param name="generateIndex" as="xs:string" select="'no'"/>
  
  <!-- URI of the graphic to use in the case where there is no cover
    graphic defined in the incoming DITA map or as a parameter
    to this transform.
  --> 
  <xsl:param name="placeholderCoverGraphicUri" as="xs:string" 
    select="'resources/placeholder-cover-graphic.jpg'"/>
  
  <xsl:variable name="generateIndexBoolean"
    select="
    lower-case($generateIndex) = 'yes' or 
    lower-case($generateIndex) = 'true' or
    lower-case($generateIndex) = 'on'
    "/>

  <!-- Absolute URI of the graphic to use for the cover. Specify
       when the source markup does not enable determination
       of the cover graphic.
  -->

  <!-- 
        TBD: kindlegen expects a cover in the form of a cover image, 
        but allows the use of a cover page in the form of an HTML page
        in addition to the cover image
        
        so, we need to define a cover image and possibly a cover html page
        
        one possibility is to add a placeholder for cases where there
        is no cover image defined in the publication being processed
        
  -->
  <xsl:param name="coverGraphicUri" as="xs:string" select="''"/>

  <xsl:variable name="coverImageId" select="'coverimage'" as="xs:string"/>

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
  
  
  <xsl:template name="report-parameters" match="*" mode="report-parameters">
    <xsl:param name="effectiveCoverGraphicUri" select="''" as="xs:string" tunnel="yes"/>
    <xsl:message> ========================================== 
      Plugin version: 0.9.19RC12 - build 1968 at 2014-07-02 
      
      Parameters: 
      
      + coverGraphicUri = "<xsl:sequence select="$coverGraphicUri"/>" 
      + cssOutputDir = "<xsl:sequence select="$cssOutputDir"/>" 
      + generateIndex = "<xsl:sequence select="$generateIndex"/> 
      + imagesOutputDir = "<xsl:sequence select="$imagesOutputDir"/>" 
      + outdir = "<xsl:sequence select="$outdir"/>" 
      + tempdir = "<xsl:sequence select="$tempdir"/>" 
      + titleOnlyTopicClassSpec = "<xsl:sequence select="$titleOnlyTopicClassSpec"/>" 
      + titleOnlyTopicTitleClassSpec = "<xsl:sequence select="$titleOnlyTopicTitleClassSpec"/>" 
      + topicsOutputDir = "<xsl:sequence select="$topicsOutputDir"/>" 
      + DITAEXT = "<xsl:sequence select="$DITAEXT"/>" 
      + WORKDIR = "<xsl:sequence select="$WORKDIR"/>" 
      + PATH2PROJ = "<xsl:sequence select="$PATH2PROJ"/>" 
      + KEYREF-FILE = "<xsl:sequence select="$KEYREF-FILE"/>" 
      + CSS = "<xsl:sequence select="$CSS"/>"
      + CSSPATH = "<xsl:sequence select="$CSSPATH"/>" 
      + debug = "<xsl:sequence select="$debug"/>"
      
      Global Variables: 
      
      + cssOutputPath = "<xsl:sequence select="$cssOutputPath"/>" 
      + effectiveCoverGraphicUri = "<xsl:sequence select="$effectiveCoverGraphicUri"/>" 
      + topicsOutputPath = "<xsl:sequence select="$topicsOutputPath"/>" 
      + imagesOutputPath = "<xsl:sequence select="$imagesOutputPath"/>" 
      + platform = "<xsl:sequence select="$platform"/>" 
      + debugBoolean = "<xsl:sequence select="$debugBoolean"/>"      
    </xsl:message>
    <xsl:apply-templates select="." mode="extension-report-parameters"/>
    <xsl:message>
      ========================================== 
    </xsl:message>
    
  </xsl:template>


  <xsl:output method="xml" name="indented-xml" indent="yes"/>

  <xsl:variable name="maxTocDepthInt" select="xs:integer($maxTocDepth)" as="xs:integer"/>


  <xsl:variable name="platform" as="xs:string"
    select="
    if (starts-with($rawPlatformString, 'Win') or 
        starts-with($rawPlatformString, 'Win'))
       then 'windows'
       else 'nx'
    "/>

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
        <xsl:sequence
          select="concat($outdir, 
            if (ends-with($outdir, '/')) then '' else '/', 
            $imagesOutputDir)"
        />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$outdir"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="cssOutputPath">
    <xsl:choose>
      <xsl:when test="$cssOutputDir != ''">
        <xsl:sequence select="concat($outdir, $cssOutputDir)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$outdir"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:if test="$debugBoolean">
      <xsl:message> + [DEBUG] Root template in default mode. Root element is "<xsl:sequence
            select="name(/*[1])"/>", class="<xsl:sequence select="string(/*[1]/@class)"/>:</xsl:message>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="/*[df:class(., 'map/map')]">

    <xsl:variable name="effectiveCoverGraphicUri" as="xs:string">
      <xsl:apply-templates select="." mode="get-cover-graphic-uri"/>
    </xsl:variable>

    <xsl:apply-templates select="." mode="report-parameters">
      <xsl:with-param name="effectiveCoverGraphicUri" select="$effectiveCoverGraphicUri"
        as="xs:string" tunnel="yes"/>
    </xsl:apply-templates>

    <xsl:variable name="graphicMap" as="element()">
      <xsl:apply-templates select="." mode="generate-graphic-map">
        <xsl:with-param name="effectiveCoverGraphicUri" select="$effectiveCoverGraphicUri"
          as="xs:string" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:result-document href="{relpath:newFile($outdir, 'graphicMap.xml')}" format="graphic-map">
      <xsl:sequence select="$graphicMap"/>
    </xsl:result-document>
    <xsl:call-template name="make-meta-inf"/>
    <xsl:call-template name="make-mimetype"/>

    <xsl:message> + [INFO] Gathering index terms...</xsl:message>

    <!-- Gather all the index entries from the map and topic. 
    -->
    <xsl:variable name="index-terms" as="element()">
      <index-terms xmlns="http://dita4publishers.org/index-terms">
        <xsl:if test="$generateIndexBoolean">
          <xsl:apply-templates mode="gather-index-terms"/>
        </xsl:if>
      </index-terms>
    </xsl:variable>

    <xsl:if test="true()">
      <xsl:result-document href="{relpath:newFile($outdir, 'index-terms.xml')}"
        format="indented-xml">
        <xsl:sequence select="$index-terms"/>
      </xsl:result-document>
    </xsl:if>

    <xsl:apply-templates select="." mode="generate-content"/>
    <xsl:apply-templates select="." mode="generate-toc">
      <xsl:with-param name="index-terms" as="element()" select="$index-terms"/>
    </xsl:apply-templates>
    <xsl:message>[INFO] "generate-toc" is complete....</xsl:message>
    <!-- ======================================================= -->
    <!-- ===================== adding html toc ================= -->
    <xsl:apply-templates select="." mode="generate-html-toc">
      <xsl:with-param name="index-terms" as="element()" select="$index-terms"/>
    </xsl:apply-templates>
    <xsl:message>[INFO] "generate-html-toc" is complete....</xsl:message>
    <!-- ======================================================= -->    
    <xsl:apply-templates select="." mode="generate-index">
      <xsl:with-param name="index-terms" as="element()" select="$index-terms"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="." mode="generate-opf">
      <xsl:with-param name="graphicMap" as="element()" tunnel="yes" select="$graphicMap"/>
      <xsl:with-param name="index-terms" as="element()" select="$index-terms"/>
      <xsl:with-param name="effectiveCoverGraphicUri" select="$effectiveCoverGraphicUri"
        as="xs:string" tunnel="yes"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="." mode="generate-graphic-copy-ant-script">
      <xsl:with-param name="graphicMap" as="element()" tunnel="yes" select="$graphicMap"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template name="make-meta-inf">
    <xsl:result-document
      href="{relpath:newFile(relpath:newFile($outdir, 'META-INF'), 'container.xml')}">
      <container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
        <rootfiles>
          <rootfile full-path="content.opf" media-type="application/oebps-package+xml"/>
        </rootfiles>
      </container>
    </xsl:result-document>
  </xsl:template>

  <xsl:template name="make-mimetype">
    <xsl:result-document href="{relpath:newFile($outdir, 'mimetype')}" method="text">
      <xsl:text>application/epub+zip</xsl:text>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="/*[df:class(., 'map/map')]" mode="get-cover-graphic-uri">
    <!-- NOTE: override this template in order to implement different business logic
         for determining the cover graphic.
    -->
    <xsl:variable name="baseGraphicUri" as="xs:string">
      <xsl:choose>
        <xsl:when test="//*[df:class(., 'pubmap-d/epub-cover-graphic')]">
          <xsl:variable name="targetUri" as="xs:string"
            select="df:getEffectiveTopicUri((//*[df:class(., 'pubmap-d/epub-cover-graphic')])[1])"/>
          <xsl:sequence select="$targetUri"/>
        </xsl:when>
        <xsl:when
          test="*[df:class(., 'map/topicmeta')]//*[df:class(., 'topic/data') and @name = 'covergraphic']">
          <xsl:variable name="elem"
            select="(*[df:class(., 'map/topicmeta')]//*[df:class(., 'topic/data') and @name = 'covergraphic'])[1]"
            as="element()"/>
          <xsl:choose>
            <xsl:when test="$elem/@value">
              <xsl:sequence select="string($elem/@value)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="string($elem)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$coverGraphicUri"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="docUri" select="relpath:toUrl(@xtrf)" as="xs:string"/>
    <xsl:variable name="finalUri" as="xs:string"
      select="
      if ($baseGraphicUri = '')
         then ''
         else relpath:newFile(relpath:getParent($docUri), $baseGraphicUri)
      "/>
    <xsl:sequence select="$finalUri"/>
  </xsl:template>

</xsl:stylesheet>
