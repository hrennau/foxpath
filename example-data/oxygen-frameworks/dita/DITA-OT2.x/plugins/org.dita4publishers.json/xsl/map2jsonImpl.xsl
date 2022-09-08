<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:index-terms="http://dita4publishers.org/index-terms"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:mapdriven="http://dita4publishers.org/mapdriven"
  exclude-result-prefixes="xs xd df relpath mapdriven index-terms java xsl mapdriven"
  xmlns:java="org.dita.dost.util.ImgUtils"
  version="2.0">

  <!-- =============================================================

       DITA Map to json Transformation

       Copyright (c) 2010, 2013 DITA For Publishers

       Licensed under Common Public License v1.0 or the Apache Software Foundation License v2.0.
       The intent of this license is for this material to be licensed in a way that is
       consistent with and compatible with the license of the DITA Open Toolkit.

    ============================================================== -->
  <!--xsl:import href="../../net.sourceforge.dita4publishers.html2/xsl/map2html2Impl.xsl"/-->
  <xsl:import href="plugin:org.dita-community.common.mapdriven:/xsl/dataCollection.xsl"/>

  <xsl:import href="plugin:org.dita4publishers.common.xslt:xsl/reportParametersBase.xsl"/>
  <xsl:import href="plugin:org.dita4publishers.common.html:xsl/html-generation-utils.xsl"/>

  <!-- Import the base HTML output generation transform. -->
  <xsl:import href="plugin:org.dita.xhtml:xsl/dita2xhtml.xsl"/>

  <xsl:import href="plugin:org.dita4publishers.common.mapdriven:xsl/mapdrivenEnumerationD4P.xsl"/>

  <xsl:import href="plugin:org.dita4publishers.common.xslt:xsl/graphicMap2AntCopyScript.xsl"/>
  <xsl:import href="plugin:org.dita4publishers.common.xslt:xsl/map2graphicMap.xsl"/>
  <xsl:import href="plugin:org.dita4publishers.common.xslt:xsl/topicHrefFixup.xsl"/>

  <!-- FIXME: This URL syntax is local to me: I hacked catalog-dita_template.xml
              to add this entry:

              <rewriteURI uriStartString="plugin:base-xsl:" rewritePrefix="xsl/"></rewriteURI>

        see https://github.com/dita-ot/dita-ot/issues/1405
    -->
  <xsl:import href="plugin:org.dita.base:xsl/common/dita-utilities.xsl"/>

  <xsl:include href="plugin:org.dita4publishers.common.html:xsl/commonHtmlOverrides.xsl"/>
  <xsl:include href="plugin:org.dita4publishers.common.html:xsl/commonHtmlEnumeration.xsl"/>
  <xsl:include href="plugin:org.dita4publishers.common.html:xsl/commonHtmlBookmapEnumeration.xsl"/>
 
  <xsl:include href="xml2json/xml-to-json.xsl"/>
  <xsl:include href="map2jsonContent.xsl"/>
  
  <xsl:param name="OUTEXT" select="'.json'" as="xs:string"/>
  <xsl:param name="CSSPATH" select="''" />
  <xsl:param name="outdir" select="''" />
  <xsl:param name="topicsOutputDir" select="''" />
  <xsl:param name="tempdir" select="''" />
  <xsl:param name="generateGlossaryBoolean" select="false()"/>
  <xsl:param name="generateIndexBoolean" select="false()"/>
  <xsl:param name="imagesOutputDir" select="'images'" as="xs:string"/>

  <xsl:param name="rawPlatformString" select="'unknown'" as="xs:string"/><!-- As provided by Ant -->

  <xsl:variable name="platform" as="xs:string"
    select="
    if (starts-with($rawPlatformString, 'Win') or
        starts-with($rawPlatformString, 'Win'))
       then 'windows'
       else 'nx'
    "
  />

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

  <xsl:output  name="json" indent="no" omit-xml-declaration="yes" method="text" encoding="utf-8"/>
  
  <xsl:template match="/">
    <xsl:message> + [INFO] Using DITA for Publishers json transformation type</xsl:message>
    <xsl:apply-templates>
      <xsl:with-param name="rootMapDocUrl" select="document-uri(.)" as="xs:string" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="/*[df:class(., 'map/map')]"> 
  
  <xsl:variable name="uniqueTopicRefs" as="element()*" select="df:getUniqueTopicrefs(.)"/>


    <xsl:message> + [INFO] Collecting data for index generation, enumeration, etc....</xsl:message>

	<!-- collected data -->
    <xsl:variable name="collected-data" as="element()">
      <xsl:call-template name="mapdriven:collect-data"/>
    </xsl:variable>
    
    <xsl:apply-templates select="." mode="generate-json-content">
    	<xsl:with-param name="baseUri" as="xs:string" select="@xtrf" tunnel="yes"/>
    	<xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
    	 <xsl:with-param name="uniqueTopicRefs" as="element()*" select="$uniqueTopicRefs" tunnel="yes"/>
    </xsl:apply-templates>
    
  </xsl:template>

</xsl:stylesheet>