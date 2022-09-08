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
  exclude-result-prefixes="xs xd df relpath"
  version="2.0">
  
  <!-- =============================================================
    
       DITA Map to ePub Transformation
       
       Copyright (c) 2010, 2014 DITA For Publishers
       
       Licensed under Common Public License v1.0 or the Apache Software Foundation License v2.0.
       The intent of this license is for this material to be licensed in a way that is
       consistent with and compatible with the license of the DITA Open Toolkit.
       
       This transform requires XSLT 2.
       
       This transform is the root transform and manages the generation
       of the following distinct artifacts that make up a complete
       ePub publication:
       
       1. content.opf file, which defines the contents and publication metadata for the ePub
       2. toc.ncx, which defines the navigation table of contents for the ePub.
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
  <xsl:import href="../../net.sourceforge.dita4publishers.common.xslt/xsl/lib/dita-support-lib.xsl"/>
  <xsl:import href="../../net.sourceforge.dita4publishers.common.xslt/xsl/lib/relpath_util.xsl"/>
  -->
  <xsl:import href="../../net.sourceforge.dita4publishers.common.xslt/xsl/lib/html-generation-utils.xsl"/>
  
  <!-- Import the base HTML output generation transform. -->
  <xsl:import href="plugin:org.dita.xhtml:xsl/dita2xhtml.xsl"/>
  
  <xsl:import href="../../net.sourceforge.dita4publishers.common.xslt/xsl/graphicMap2AntCopyScript.xsl"/>
  <xsl:import href="../../net.sourceforge.dita4publishers.common.xslt/xsl/map2graphicMapImpl.xsl"/>
  <xsl:import href="../../net.sourceforge.dita4publishers.common.xslt/xsl/topicHrefFixup.xsl"/>
  <xsl:import href="../../net.sourceforge.dita4publishers.common.mapdriven/xsl/dataCollection.xsl"/>  
  
  <xsl:include href="../../net.sourceforge.dita4publishers.common.html/xsl/commonHtmlOverrides.xsl"/>
  <xsl:include href="../../net.sourceforge.dita4publishers.common.html/xsl/commonHtmlEnumeration.xsl"/>
  <xsl:include href="../../net.sourceforge.dita4publishers.common.html/xsl/commonHtmlBookmapEnumeration.xsl"/>
  <xsl:include href="map2epubCommon.xsl"/>
  <xsl:include href="map2epubOpfImpl.xsl"/>
  <xsl:include href="map2epubBookLists.xsl"/>
  <xsl:include href="map2epubContentImpl.xsl"/>
  <xsl:include href="map2epubSetCoverGraphic.xsl"/>
  <xsl:include href="map2epubHtmlTocImpl.xsl"/>
  <xsl:include href="map2epubListOfFigures.xsl"/>
  <xsl:include href="map2epubListOfTables.xsl"/>
  <xsl:include href="map2epubTocImpl.xsl"/>
<!--  <xsl:include href="map2epubIndexImpl.xsl"/>-->
  <xsl:include href="html2xhtmlImpl.xsl"/>
  <xsl:include href="epubHtmlOverrides.xsl"/>
  
  <xsl:include href="../../net.sourceforge.dita4publishers.html2/xsl/map2html2Index.xsl"/>
  

  <xsl:include href="map2epubD4PImpl.xsl"/>
  <xsl:include href="map2epubBookmapImpl.xsl"/>
  
  <!-- Initial part of ePUB ID URI. Should reflect the book's
       owner.
    -->
  <xsl:param name="idURIStub" select="'http://example.org/dummy/URIstub/'" as="xs:string"/>
  
  <xsl:param name="tempFilesDir" select="'tempFilesDir value not passed'" as="xs:string"/>
  
  <!-- XSLT document function needs full URI for parameter, so this is
    used for that. -->
  <xsl:variable name="inputURLstub" as="xs:string" 
    select="concat('file:///', translate($tempFilesDir,':\','|/'), '/')"/>
  
  
  <!-- Directory into which the generated output is put.

       This should be the directory that will be zipped up to
       produce the final ePub package.
       -->
  <xsl:param name="outdir" select="./epub"/>
  <xsl:param name="outext" select="'.html'"/>
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

  <!-- The path of the directory, relative the $outdir parameter,
    to hold the CSS files in the EPub package. Should not have
    a leading "/". 
  -->  
  <xsl:param name="cssOutputDir" select="'topics'" as="xs:string"/>
  
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
    The strategy to use when constructing output files. Default is "single-dir", meaning
    put all result topics in the same output directory (as specified by $topicsOutputDir)
  -->         
  <xsl:param name="fileOrganizationStrategy" as="xs:string" select="'single-dir'"/>
  
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
  
  <!-- Used by some HTML output stuff. For EPUB, don't want links to
       go to a new window.
    -->
  <xsl:variable name="contenttarget" as="xs:string" select="''"/>
  
  <xsl:key name="elementsById" match="*[@id]" use="@id"/>
  <xsl:key name="elementsByXtrc" match="*[@xtrc]" use="@xtrc"/>
  
  <xsl:template name="report-parameters" match="*" mode="report-parameters">
    <xsl:param name="effectiveCoverGraphicUri" select="''" as="xs:string" tunnel="yes"/>
    <xsl:message> 
      ==========================================
      Plugin version: 0.9.19RC12 - build 1968 at 2014-07-02
      
      Parameters:
      
      + coverGraphicUri = "<xsl:sequence select="$coverGraphicUri"/>"
      + cssOutputDir    = "<xsl:sequence select="$cssOutputDir"/>"
      + generateGlossary= "<xsl:sequence select="$generateGlossary"/>"
      + generateHtmlToc = "<xsl:sequence select="$generateHtmlToc"/>"
      + maxTocDepth     = "<xsl:sequence select="$maxTocDepth"/>"
      + maxNavDepth     = "<xsl:sequence select="$maxNavDepth"/>"
      + generateIndex   = "<xsl:sequence select="$generateIndex"/>"
      + imagesOutputDir = "<xsl:sequence select="$imagesOutputDir"/>"
      + mathJaxInclude  = "<xsl:sequence select="$mathJaxInclude"/>"
      + mathJaxConfigParam = "<xsl:sequence select="$mathJaxConfigParam"/>"
      + mathJaxLocalJavascriptUri= "<xsl:sequence select="$mathJaxLocalJavascriptUri"/>"
      + outdir          = "<xsl:sequence select="$outdir"/>"
      + tempdir         = "<xsl:sequence select="$tempdir"/>"
      + titleOnlyTopicClassSpec = "<xsl:sequence select="$titleOnlyTopicClassSpec"/>"
      + titleOnlyTopicTitleClassSpec = "<xsl:sequence select="$titleOnlyTopicTitleClassSpec"/>"
      + topicsOutputDir = "<xsl:sequence select="$topicsOutputDir"/>"

      + DITAEXT         = "<xsl:sequence select="$DITAEXT"/>"
      + WORKDIR         = "<xsl:sequence select="$WORKDIR"/>"
      + PATH2PROJ       = "<xsl:sequence select="$PATH2PROJ"/>"
      + KEYREF-FILE     = "<xsl:sequence select="$KEYREF-FILE"/>"
      + CSS             = "<xsl:sequence select="$CSS"/>"
      + CSSPATH         = "<xsl:sequence select="$CSSPATH"/>"
      + debug           = "<xsl:sequence select="$debug"/>"
      
      Global Variables:
      
      + cssOutputPath    = "<xsl:sequence select="$cssOutputPath"/>"
      + effectiveCoverGraphicUri = "<xsl:sequence select="$effectiveCoverGraphicUri"/>"
      + topicsOutputPath = "<xsl:sequence select="$topicsOutputPath"/>"
      + imagesOutputPath = "<xsl:sequence select="$imagesOutputPath"/>"
      + platform         = "<xsl:sequence select="$platform"/>"
      + debugBoolean     = "<xsl:sequence select="$debugBoolean"/>"
      
      ==========================================
    </xsl:message>
    <xsl:apply-templates select="." mode="extension-report-parameters"/>
  </xsl:template>
  
  
  <xsl:output method="xml" name="indented-xml"
    indent="yes"
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
        <xsl:message> + [DEBUG] Root template in default mode. Root element is "<xsl:sequence select="name(/*[1])"/>", class="<xsl:sequence select="string(/*[1]/@class)"/>:</xsl:message>
    </xsl:if>    
    <xsl:apply-templates>
      <xsl:with-param name="rootMapDocUrl" select="document-uri(.)" as="xs:string" tunnel="yes"/>      
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="/*[df:class(., 'map/map')]">
    
    <xsl:variable name="effectiveCoverGraphicUri" as="xs:string">
      <xsl:apply-templates select="." mode="get-cover-graphic-uri"/>
    </xsl:variable>
    
    <!-- FIXME: Add mode to get effective front cover topic URI so we
         can generate <guide> entry for the cover page. Also provides
         extension point for synthesizing the cover if it's not 
         explicit in the map.
    -->

    <xsl:apply-templates select="." mode="report-parameters">
      <xsl:with-param name="effectiveCoverGraphicUri" select="$effectiveCoverGraphicUri" as="xs:string" tunnel="yes"/>
    </xsl:apply-templates>
    
    <xsl:variable name="graphicMap" as="element()">
      <xsl:apply-templates select="." mode="generate-graphic-map">
        <xsl:with-param name="effectiveCoverGraphicUri" select="$effectiveCoverGraphicUri" as="xs:string" tunnel="yes"/>        
      </xsl:apply-templates>
    </xsl:variable>
    
    <xsl:message> + [INFO] Collecting data for index generation, enumeration, etc....</xsl:message>
    
    <xsl:variable name="collected-data" as="element()">
      <xsl:call-template name="mapdriven:collect-data"/>      
    </xsl:variable>
    
    <xsl:if test="true() or $debugBoolean">
      <xsl:message> + [DEBUG] Writing file <xsl:sequence select="relpath:newFile($outdir, 'collected-data.xml')"/>...</xsl:message>
      <xsl:result-document href="{relpath:newFile($outdir, 'collected-data.xml')}"
        format="indented-xml"
        >
        <xsl:sequence select="$collected-data"/>
      </xsl:result-document>
    </xsl:if>
        
    <xsl:result-document href="{relpath:newFile($outdir, 'graphicMap.xml')}" format="graphic-map">
      <xsl:sequence select="$graphicMap"/>
    </xsl:result-document>    
    <xsl:call-template name="make-meta-inf"/>
    <xsl:call-template name="make-mimetype"/>
    
    <xsl:message> + [INFO] Gathering index terms...</xsl:message>
    
    <xsl:apply-templates select="." mode="generate-content">
      <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>     
    </xsl:apply-templates>
    <!-- NOTE: The generate-toc mode is for the EPUB toc, not the HTML toc -->
    <xsl:apply-templates select="." mode="generate-toc">
      <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
    </xsl:apply-templates>
    <xsl:message> + [DEBUG] after generate-toc</xsl:message>
    <xsl:apply-templates select="." mode="generate-index">
      <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
    </xsl:apply-templates>
    <xsl:message> + [DEBUG] after generate-index</xsl:message>
    <xsl:apply-templates select="." mode="generate-book-lists">
      <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
    </xsl:apply-templates>
    <xsl:message> + [DEBUG] after generate-book-lists</xsl:message>
    <xsl:apply-templates select="." mode="generate-opf">
      <xsl:with-param name="graphicMap" as="element()" tunnel="yes" select="$graphicMap"/>
      <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
      <xsl:with-param name="effectiveCoverGraphicUri" select="$effectiveCoverGraphicUri" as="xs:string" tunnel="yes"/>        
    </xsl:apply-templates>
    <xsl:message> + [DEBUG] after generate-opf</xsl:message>
    <xsl:apply-templates select="." mode="generate-graphic-copy-ant-script">
      <xsl:with-param name="graphicMap" as="element()" tunnel="yes" select="$graphicMap"/>
    </xsl:apply-templates>
    <xsl:message> + [DEBUG] after generate-graphic-copy-ant-script</xsl:message>
  </xsl:template>
  
  <xsl:template name="make-meta-inf">
    <xsl:result-document href="{relpath:newFile(relpath:newFile($outdir, 'META-INF'), 'container.xml')}">
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
  
  
</xsl:stylesheet>
