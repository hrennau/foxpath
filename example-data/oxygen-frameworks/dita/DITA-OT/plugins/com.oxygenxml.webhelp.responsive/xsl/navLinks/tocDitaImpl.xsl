<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:relpath="http://dita2indesign/functions/relpath"
    xmlns:oxygen="http://www.oxygenxml.com/functions"
    xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc"
    xmlns="http://www.oxygenxml.com/ns/webhelp/toc" exclude-result-prefixes="relpath oxygen"
    xmlns:xhtml="http://www.w3.org/1999/xhtml" version="2.0">


    <!-- EXM-34368 Stylesheet to handle DITA elements -->
    <xsl:import href="plugin:org.dita.xhtml:xsl/dita2html-base.xsl"/>
    <xsl:import href="../util/dita-utilities.xsl"/>
    <xsl:import href="../util/functions.xsl"/>
    <!-- EXM-34663 - Importing the stylesheet that contains some functions for working with relative paths. -->
    <xsl:import href="../util/relpath_util.xsl"/>

    <xsl:import href="../util/fixupNS.xsl"/>

    <xsl:output method="xml" encoding="UTF-8"/>

    <!-- Extension of output files for example .html -->
    <xsl:param name="OUT_EXT" select="'.html'"/>
    <!-- the file name containing filter/flagging/revision information
        (file name and extension only - no path).  - testfile: revflag.dita -->
    <xsl:param name="FILTERFILE"/>

    <!-- WH-257: The temporary directory's URL needed to write the temporary files containing the TOC ID of each topic. -->
    <xsl:param name="TEMP_DIR_URL"/>

    <!-- The document tree of filterfile returned by document($FILTERFILE,/)-->
    <xsl:variable name="FILTERFILEURL">
        <xsl:choose>
            <xsl:when test="not($FILTERFILE)"/>
            <!-- If no filterfile leave empty -->
            <xsl:when test="starts-with($FILTERFILE, 'file:')">
                <xsl:value-of select="$FILTERFILE"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="starts-with($FILTERFILE, '/')">
                        <xsl:text>file://</xsl:text>
                        <xsl:value-of select="$FILTERFILE"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>file:/</xsl:text>
                        <xsl:value-of select="$FILTERFILE"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="FILTERDOC"
        select="
            if (string-length($FILTERFILEURL) > 0)
            then
                document($FILTERFILEURL, /)
            else
                ()"/>

    <xsl:variable name="passthrough-attrs" as="element()*"
        select="$FILTERDOC/val/prop[@action = 'passthrough']"/>

    <xsl:variable name="VOID_HREF" select="'javascript:void(0)'"/>

    <xsl:key name="tocHrefs"
        match="toc:topic[@href][not(@href = $VOID_HREF)][not(@format) or @format = 'dita' or @format = 'DITA']"
        use="tokenize(@href, '#')[1]"/>

    <xsl:template match="/">
        <xsl:variable name="toc">
            <toc>
                <!-- WH-257: Copy "chunk" info. -->
                <xsl:copy-of select="/*[contains(@class, ' map/map ')]/@chunk"/>
                <title>
                    <xsl:variable name="topicTitle"
                        select="/*[contains(@class, ' map/map ')]/*[contains(@class, ' topic/title ')][1]"/>
                    <xsl:choose>
                        <xsl:when test="exists($topicTitle)">
                            <xsl:element name="span" exclude-result-prefixes="#all"
                                namespace="http://www.w3.org/1999/xhtml">
                                <xsl:attribute name="class"
                                    select="oxygen:extractLastClassValue($topicTitle/@class)"/>
                                <xsl:apply-templates select="$topicTitle/node()"/>
                            </xsl:element>
                        </xsl:when>

                        <xsl:when test="/*[contains(@class, ' map/map ')]/@title">
                            <xsl:value-of select="/*[contains(@class, ' map/map ')]/@title"/>
                        </xsl:when>
                    </xsl:choose>
                </title>
                <!-- Copy meta information from DITA map -->
                <xsl:apply-templates select="/*[contains(@class, ' map/map ')]/*[contains(@class, ' map/topicmeta ')]" mode="copy-topic-meta"/>
                
                <xsl:apply-templates mode="toc-webhelp"/>
            </toc>
        </xsl:variable>

        <!-- Fixup the namespace to be HTML -->
        <xsl:apply-templates select="$toc" mode="fixup_XHTML_NS"/>

        <!-- Write the TOC IDs to temporary files, next to each topic -->
        <xsl:apply-templates select="$toc" mode="writeTocId"/>
    </xsl:template>

    <xsl:template match="text()" mode="toc-webhelp"/>

    <xsl:template
        match="
            *[contains(@class, ' map/topicref ')
            and not(@processing-role = 'resource-only')
            and not(@toc = 'no')
            and not(ancestor::*[contains(@class, ' map/reltable ')])]"
        mode="toc-webhelp">

        <xsl:variable name="title" as="node()*">
            <xsl:variable name="navTitleElem"
                select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]"/>
            <xsl:choose>
                <xsl:when test="$navTitleElem">
                    <!-- Fix the href attribute in the navtitle -->
                    <xsl:variable name="navTitle_hrefFixed">
                        <xsl:apply-templates select="$navTitleElem" mode="fixHRef">
                            <xsl:with-param name="base-uri" select="base-uri()"/>
                        </xsl:apply-templates>/ </xsl:variable>

                    <xsl:apply-templates select="$navTitle_hrefFixed/*/node()"/>
                    <!--<xsl:apply-templates select="$navTitleElem/node()"/>-->
                </xsl:when>
                <xsl:when test="@navtitle">
                    <xsl:value-of select="@navtitle"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="@href or @copy-to or not(empty($title))">
                <topic>
                    <xsl:attribute name="href">
                        <xsl:choose>
                            <xsl:when
                                test="@copy-to and not(ancestor-or-self::*[contains(@chunk, 'to-content')])">
                                <xsl:call-template name="replace-extension">
                                    <xsl:with-param name="filename" select="@copy-to"/>
                                    <xsl:with-param name="extension" select="$OUT_EXT"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:when test="@href">
                                <xsl:call-template name="replace-extension">
                                    <xsl:with-param name="filename" select="@href"/>
                                    <xsl:with-param name="extension" select="$OUT_EXT"/>
                                    <xsl:with-param name="forceReplace"
                                        select="not(@format) or @format = 'dita'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$VOID_HREF"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>

                    <xsl:if test="@collection-type">
                        <xsl:attribute name="collection-type" select="@collection-type"/>
                    </xsl:if>
                    <xsl:if test="@outputclass">
                        <xsl:attribute name="outputclass" select="@outputclass"/>
                    </xsl:if>
                    <xsl:if test="@scope and not(@scope = 'local')">
                        <xsl:attribute name="scope" select="@scope"/>
                    </xsl:if>
                    <!-- WH-257: Copy "chunk" info. -->
                    <xsl:copy-of select="@chunk"/>
                    <!-- WH-257: Copy "format" attribute. -->
                    <xsl:copy-of select="@format"/>

                    <xsl:if test="exists($passthrough-attrs)">
                        <xsl:for-each select="@*">
                            <xsl:if
                                test="
                                    $passthrough-attrs[@att = name(current()) and (empty(@val) or (some $v in tokenize(current(), '\s+')
                                        satisfies $v = @val))]">
                                <xsl:attribute name="data-{name()}" select="."/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:if>

                    <xsl:variable name="topicId">
                        <xsl:choose>
                            <!-- Pickup the ID from the topic file, that was set in the topicmeta by a previous processing (see "addResourceID.xsl").  -->
                            <xsl:when test="*[contains(@class, ' map/topicmeta ')]/@data-topic-id">
                                <xsl:value-of
                                    select="*[contains(@class, ' map/topicmeta ')]/@data-topic-id"/>
                            </xsl:when>
                            <!-- Fallback to the ID set on the topicref. For instance the topichead does not point to a topic 
                                file (that would have an ID inside), but can have an ID set on it directly in the map.-->
                            <xsl:when test="@id">
                                <xsl:value-of select="@id"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>

                    <xsl:if test="string-length($topicId) > 0">
                        <xsl:attribute name="data-id" select="$topicId"/>
                    </xsl:if>

                    <xsl:attribute name="wh-toc-id">
                        <xsl:variable name="tocIdPrefix">
                            <xsl:choose>
                                <xsl:when test="string-length($topicId) > 0">
                                    <xsl:value-of select="$topicId"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'tocId'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:value-of select="concat($tocIdPrefix, '-', generate-id(.))"/>
                    </xsl:attribute>

                    <title>
                        <xsl:choose>
                            <xsl:when test="not(empty($title))">
                                <xsl:copy-of select="$title"/>
                            </xsl:when>
                            <xsl:otherwise>***</xsl:otherwise>
                        </xsl:choose>
                    </title>

                    <xsl:variable name="shortDesc"
                        select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' map/shortdesc ')][1]"/>
                    <xsl:if test="$shortDesc">
                        <xsl:variable name="shortDesc_hrefFixed">
                            <xsl:apply-templates select="$shortDesc" mode="fixHRef">
                                <xsl:with-param name="base-uri" select="base-uri()"/>
                            </xsl:apply-templates>
                        </xsl:variable>

                        <shortdesc>
                            <xsl:apply-templates select="$shortDesc_hrefFixed/node()"/>
                        </shortdesc>
                    </xsl:if>
                    <xsl:apply-templates select="*[contains(@class, ' map/topicmeta ')]"
                        mode="copy-topic-meta"/>
                    <xsl:apply-templates mode="toc-webhelp"/>
                </topic>
            </xsl:when>
            <xsl:otherwise>
                <!-- Do not contribute a level in the TOC, but recurse in the child topicrefs -->
                <xsl:apply-templates mode="toc-webhelp"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/topicmeta ')]" mode="copy-topic-meta" priority="10">
        <topicmeta>
            <xsl:apply-templates mode="copy-topic-meta"/>
        </topicmeta>
    </xsl:template>

    <xsl:template match="*" mode="copy-topic-meta">
        <xsl:element name="{local-name()}" namespace="http://www.oxygenxml.com/ns/webhelp/toc">
            <xsl:apply-templates select="@* except (@xtrf, @xtrc)" mode="#current"/>
            <xsl:apply-templates select="node()" mode="#current"></xsl:apply-templates>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="copy-topic-meta" priority="-10">
        <xsl:copy>
            <xsl:apply-templates select="@* except (@xtrf, @xtrc)" mode="#current"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <!-- 
        Templates in 'fixHRef' mode used to fix the href location when the 'xtrf' attribute is present  
    -->
    <xsl:template match="node()" mode="fixHRef">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <!-- 
       EXM-36559 - Rename 'map/shortdesc' class to 'topic/shortdesc'.
    -->
    <xsl:template match="@class[contains(., ' map/shortdesc ')]" mode="fixHRef" priority="10">
        <xsl:attribute name="class" select="replace(., 'map/shortdesc', 'topic/shortdesc')"/>
    </xsl:template>

    <!-- Copy any attribute -->
    <xsl:template match="@*" mode="fixHRef">
        <xsl:copy/>
    </xsl:template>

    <xsl:template match="*" mode="fixHRef" priority="10">
        <xsl:param name="base-uri"/>
        <xsl:copy>
            <xsl:if test="string-length($base-uri) > 0">
                <xsl:attribute name="xml:base" select="$base-uri"/>
            </xsl:if>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <!-- Recompute the relative path for the @href in the context of the parent map -->
    <xsl:template match="@href" mode="fixHRef">
        <xsl:variable name="xtrf" select="parent::node()/@xtrf"/>
        <xsl:variable name="mapXtrf" select="ancestor::*[contains(@class, ' map/map ')][1]/@xtrf"/>
        <xsl:choose>
            <xsl:when
                test="
                    exists($xtrf) and exists($mapXtrf)
                    and not(doc-available(concat(relpath:getParent(base-uri(.)), '/', .)))">
                <xsl:variable name="pDoc" select="relpath:getParent(relpath:toUrl($xtrf))"/>

                <!-- Make path absolute -->
                <xsl:variable name="aPath" select="concat($pDoc, '/', .)"/>

                <!-- fix ../.. in the path -->
                <xsl:variable name="aPath" select="relpath:getAbsolutePath($aPath)"/>

                <!-- Get the map URL -->
                <xsl:variable name="mapURL" select="relpath:toUrl($mapXtrf)"/>

                <!-- Make the path relative in the context of the map -->
                <xsl:variable name="relPath"
                    select="
                        relpath:getRelativePath(
                        relpath:getParent($mapURL),
                        $aPath)"/>
                <xsl:attribute name="href" select="$relPath"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
        @mode = writeTocId
        
        WH-257: Templates used to transfer the TOC ID to their corresponding topics.
                A temporary file "{@href}.tocid" will be written next to each topic.     
    -->
    <xsl:template match="toc:toc" mode="writeTocId">
        <!-- WH-257: Do not generate temporary files containing the TOC ID for the chunked topics. -->
        <xsl:if test="not(@chunk) or @chunk != 'to-content'">
            <xsl:apply-templates mode="writeTocId"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="node() | @*" mode="writeTocId">
        <xsl:apply-templates select="node() | @*" mode="writeTocId"/>
    </xsl:template>

    <xsl:template
        match="
            toc:topic
            [@href]
            [not(@href = $VOID_HREF)]
            [not(@scope = 'external')]
            [not(@format) or @format = 'dita']"
        mode="writeTocId">

        <!-- WH-1469: Handle the case when there are topicrefs with duplicate hrefs without @copy-to. -->
        <xsl:variable name="nodes" select="key('tocHrefs', tokenize(@href, '#')[1])"/>
        <xsl:choose>
            <xsl:when test="count($nodes) lt 2 or deep-equal(., $nodes[1])">
                <xsl:call-template name="writeTocIdTempFile">
                    <xsl:with-param name="tocID" select="@wh-toc-id"/>
                    <xsl:with-param name="topicHref" select="@href"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <!-- The entire message should be output on a single line in order to be presented in the Results View. -->
                <xsl:message>[OXYWH002W][WARN] Duplicated topic references found for: '<xsl:value-of select="tokenize(@href, '#')[1]"/>'. The generated Table of Contents might be inconsistent. Please use the @copy-to attribute in the DITA map in order to create unique output files for each instance of the referenced resource.</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
        <!-- WH-257: Do not generate temporary files containing the TOC ID for the chunked topics. -->
        <xsl:if test="(not(@chunk) or @chunk != 'to-content')">
            <xsl:apply-templates mode="writeTocId"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="writeTocIdTempFile">
        <xsl:param name="topicHref"/>
        <xsl:param name="tocID"/>

        <xsl:variable name="tocIdTempFileHref">
            <xsl:call-template name="replace-extension">
                <xsl:with-param name="filename" select="$topicHref"/>
                <xsl:with-param name="extension" select="'.tocid'"/>
                <!-- Remove anchors -->
                <xsl:with-param name="ignore-fragment" select="true()"/>
                <xsl:with-param name="forceReplace" select="true()"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="tocIdTempFileUrl"
            select="resolve-uri($tocIdTempFileHref, $TEMP_DIR_URL)"/>
        <xsl:if test="not(unparsed-text-available($tocIdTempFileUrl))">
            <xsl:result-document method="text" href="{$tocIdTempFileUrl}">
                <xsl:value-of select="$tocID"/>
            </xsl:result-document>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
