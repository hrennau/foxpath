<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Copyright 2001-2011 Syncro Soft SRL. All rights reserved.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:func="http://www.oxygenxml.com/xsdDoc/functions"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xpath-default-namespace="http://www.oxygenxml.com/ns/doc/schema-internal"
    exclude-result-prefixes="#all" version="3.0">
    <xsl:output indent="yes"/>
    <xsl:param name="mainFile" required="yes"/>

    <xd:doc>
        <xd:desc>The oXygen family product used to generate the documentation. <xd:p> Possible
                values: <xd:ul>
                    <xd:li>Editor (default value)</xd:li>
                    <xd:li>Developer</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:param name="distribution">Editor</xsl:param>
    <xsl:variable name="topicExtension">.dita</xsl:variable>
    <xsl:variable name="tempFileExtension">.tmp</xsl:variable>
    <xsl:variable name="splitInfo" select="/schemaDoc/splitInfo"/>

    <xd:doc>
        <xd:desc>Mapping between directive types and icons. Is used in the schemas hierarchy
            tree.</xd:desc>
    </xd:doc>
    <xsl:variable name="scHierarchyIcons" as="map(xs:string, xs:string)"
        select="map { 
        'import'    : 'img/Import12.gif', 
        'include'   : 'img/Include12.gif',
        'redefine'  : 'img/Redefine12.gif',
        'override'  : 'img/Override12.gif'}"/>      
    
    <xsl:variable name="schemaTypeLabels" as="map(xs:string, xs:string)"
    select="map {
    'main'      : 'Main schema',
    'include'   : 'Included schema',
    'import'    : 'Imported schema',
    'redefine'  : 'Redefined schema',
    'override'  : 'Overridden schema'}"/>
    
    <xsl:variable name="componentTypeLabels" as="map(xs:string, xs:string)"
        select="map{
        'Element'           : 'Element',
        'Attribute'         : 'Attribute',
        'Complex_Type'      : 'Complex Type',
        'Element_Group'     : 'Element Group',
        'Attribute_Group'   : 'Attribute Group',
        'Simple_Type'       : 'Simple Type',
        'Schema'            : 'Schema',
        'Notation'          : 'Notation',
        'Main_schema'       : 'Main Schema',
        'Included_schema'   : 'Included Schema',
        'Imported_schema'   : 'Imported Schema',
        'Redefined_schema'  : 'Redefined Schema',
        'Overridden_schema' : 'Overridden Schema'
        }"/>
    

    <xd:doc>
        <xd:desc>Get the substring before the last occurence of the given substring </xd:desc>
    </xd:doc>
    <xsl:function name="func:substring-before-last" as="xs:string">
        <xsl:param name="string"/>
        <xsl:param name="searched"/>
        <xsl:variable name="toReturn">
            <xsl:choose>
                <xsl:when test="contains($string, $searched)">
                    <xsl:variable name="before" select="substring-before($string, $searched)"/>

                    <xsl:variable name="rec"
                        select="func:substring-before-last(substring-after($string, $searched), $searched)"/>
                    <xsl:choose>
                        <xsl:when test="string-length($rec) = 0">
                            <xsl:value-of select="$before"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat($before, $searched, $rec)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$toReturn"/>
    </xsl:function>

    <xd:doc>
        <xd:desc>Get the substring after the last occurence of the given substring </xd:desc>
    </xd:doc>
    <xsl:function name="func:substring-after-last" as="xs:string">
        <xsl:param name="string"/>
        <xsl:param name="searched"/>
        <xsl:variable name="toReturn">
            <xsl:choose>
                <xsl:when test="contains($string, $searched)">
                    <xsl:variable name="after" select="substring-after($string, $searched)"/>

                    <xsl:variable name="rec" select="func:substring-after-last($after, $searched)"/>
                    <xsl:choose>
                        <xsl:when test="string-length($rec) = 0">
                            <xsl:value-of select="$after"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$rec"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$toReturn"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Create separate topics for "Elements", "Attributes", "Simple Types", "Complex Types"</xd:desc>
    </xd:doc>
    <xsl:template name="generateTopicForType">
        <xsl:result-document href="{concat(@refType, $topicExtension)}">
            <topic>
                <xsl:attribute name="id" select="concat(@refType, '_', @schemaLocation)"/>
                <title>
                    <xsl:value-of select="$componentTypeLabels(@refType)"/>
                </title>
                <shortdesc>
                    <xsl:choose>
                        <xsl:when test="compare(xs:string(@refType), 'Main_schema') = 0">
                            <xsl:value-of select="concat('Here is the Global ',$componentTypeLabels(@refType))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('Here are the Global ',$componentTypeLabels(@refType),'s')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </shortdesc>
            </topic>
        </xsl:result-document>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Write main output file. This template is used when we have a split
            criteria.</xd:desc>
    </xd:doc>
    <xsl:template name="generateMapFromIndex">
        <xsl:result-document href="{resolve-uri($mainFile, base-uri())}" indent="yes"
            exclude-result-prefixes="#all" doctype-public="-//OASIS//DTD DITA Map//EN"
            doctype-system="map.dtd">
                <xsl:comment>XML Schema documentation generated by &lt;oXygen/&gt; XML <xsl:value-of select="$distribution"/>.</xsl:comment>
            <map>
                <title>
                    <xsl:value-of select="concat('Schema documentation for ', index/ref[@refType='Main_schema']/text())"/>
                </title>
                
                <xsl:for-each-group select="index/ref" group-by="@refType">
                    
                    <!-- generate a Topic with a short desc for each schema type -->
                    <xsl:call-template name="generateTopicForType"></xsl:call-template>
                    
                    <!-- Encode URIs to avoid validation errors. -->
                    <topicref href="{concat(@refType, $topicExtension)}">
                            <xsl:for-each select="current-group()">
                                <topicref>
                                    <xsl:variable name="fileName" select="@base"/>
                                    <xsl:variable name="fileRefId" select="@refId"/>
                                    <xsl:choose>
                                        <xsl:when test="(compare(xs:string(@refType), 'Element') = 0) or 
                                            (compare(xs:string(@refType), 'Attribute') = 0)">
                                            <xsl:attribute name="href"
                                                select="concat(substring-before($fileName, $tempFileExtension), $topicExtension,'#', $fileRefId)"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:attribute name="href"
                                                select="concat(substring-before($fileName, $tempFileExtension), $topicExtension)"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </topicref>
                            </xsl:for-each>
                        </topicref>
                </xsl:for-each-group>
                
                <xsl:if test="schemaHierarchy">
                    <topicref href="{concat(substring-before(splitInfo/@indexLocation, $tempFileExtension), $topicExtension)}"/>
                </xsl:if>
            </map>

        </xsl:result-document>
    </xsl:template>


    <xsl:output 
        method="xml" encoding="UTF-8" version="1.0" 
        exclude-result-prefixes="#all"
        doctype-public="-//OASIS//DTD DITA Topic//EN" 
        doctype-system="topic.dtd"/>
    
    <xd:doc>
        <xd:desc>The entry point </xd:desc>
    </xd:doc>
    <xsl:template match="schemaDoc">
        <xsl:choose>
            <xsl:when test="index">
                <xsl:call-template name="generateMapFromIndex"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="*[@id][empty(declarationPath)]"/>
            </xsl:otherwise>
        </xsl:choose>

        <!-- Generate a resource schemas hierarchy. -->
        <xsl:apply-templates select="schemaHierarchy"/>

    </xsl:template>

    <xd:doc>
        <xd:desc>Create the a link element to a component</xd:desc>
    </xd:doc>
    <xsl:template name="reference">
        <xsl:param name="ref" select="."/>
        <xsl:choose>
            <xsl:when test="exists($ref/@refId)">
                <xsl:variable name="refTargetURI" select="resolve-uri(xs:string($ref/@base), base-uri())" as="xs:anyURI"/>
                <xref>
                    <xsl:attribute name="href">
                        <xsl:choose>
                            <xsl:when test="base-uri() = $refTargetURI">
                                <!-- A local reference. -->
                                <xsl:value-of select="concat('#', $ref/@refId)"/>
                            </xsl:when> 
                            <xsl:otherwise>
                        <xsl:variable name="refBase" select="substring-before(xs:string($ref/@base), $tempFileExtension)"/>
                        <xsl:value-of select="concat($refBase, $topicExtension,'#', $ref/@refId)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </xref>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$ref/text()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="schema">
        <xsl:call-template name="component">
            <xsl:with-param name="type">
                <xsl:variable name="currentSchema" select="."/>
                <xsl:value-of select="$schemaTypeLabels($currentSchema/@type)"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="element">
        <xsl:call-template name="component">
            <xsl:with-param name="type">Element</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="complexType">
        <xsl:call-template name="component">
            <xsl:with-param name="type">Complex Type</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="simpleType">
        <xsl:call-template name="component">
            <xsl:with-param name="type">Simple Type</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="attribute">
        <xsl:call-template name="component">
            <xsl:with-param name="type">Attribute</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="attributeGroup">
        <xsl:call-template name="component">
            <xsl:with-param name="type">Attribute Group</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="elementGroup">
        <xsl:call-template name="component">
            <xsl:with-param name="type">Element Group</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="notation">
        <xsl:call-template name="component">
            <xsl:with-param name="type">Notation</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="facets">

        <row>
            <entry>Facets</entry>
            <entry>
                <p>
                    <table frame="all" rowsep="1" colsep="1">
                        <tgroup cols="3">
                            <colspec colwidth="2*" align="left"/>
                            <colspec colwidth="3*" align="left"/>
                            <colspec colwidth="5*" align="left"/>
                            <tbody>
                                <xsl:for-each select="./facet">
                                    <row>
                                        <entry>
                                            <xsl:value-of select="@name"/>
                                        </entry>
                                        <entry>

                                            <xsl:value-of select="@value"/>

                                        </entry>
                                        <entry>
                                            <xsl:for-each select="annotation">
                                                <xsl:call-template name="buildAnnotation"/>
                                            </xsl:for-each>
                                        </entry>
                                    </row>
                                </xsl:for-each>
                            </tbody>
                        </tgroup>
                    </table>
                </p>
            </entry>
        </row>
    </xsl:template>

    <xsl:template match="properties">
        <row>
            <entry>Properties</entry>
            <entry>
                <p>
                    <table frame="all" rowsep="1" colsep="1">
                        <tgroup cols="2">
                            <colspec colwidth="2*" align="left"/>
                            <colspec colwidth="8*" align="left"/>
                            <tbody>
                                <xsl:for-each select="./property">
                                    <row>
                                        <entry>
                                            <xsl:value-of select="name"/>: </entry>
                                        <entry>
                                            <xsl:choose>
                                                <xsl:when test="exists(ref)">
                                                  <xsl:call-template name="reference">
                                                  <xsl:with-param name="ref" select="ref"/>
                                                  </xsl:call-template>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <b>
                                                  <xsl:value-of select="value"/>
                                                  </b>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </entry>
                                    </row>
                                </xsl:for-each>
                            </tbody>
                        </tgroup>
                    </table>
                </p>
            </entry>
        </row>
    </xsl:template>

    <xsl:template match="defaultOpenContent">
        <row>
            <entry>Default Open Content</entry>
            <entry>
                <table frame="all" rowsep="1" colsep="1">
                    <tgroup cols="2">
                        <colspec colwidth="2*" align="left"/>
                        <colspec colwidth="8*" align="left"/>
                        <tbody>
                            <!-- Add open content documentation -->
                            <xsl:if test="exists(@mode)">
                                <row>
                                    <entry>Mode</entry>
                                    <entry>
                                        <xsl:value-of select="@mode"/>
                                    </entry>
                                </row>
                            </xsl:if>
                            <xsl:if test="exists(text())">
                                <row>
                                    <entry>Wildcard</entry>
                                    <entry>
                                        <xsl:value-of select="text()"/>
                                    </entry>
                                </row>
                            </xsl:if>
                            <xsl:if test="exists(@processContents)">
                                <row>
                                    <entry>Process contents</entry>
                                    <entry>
                                        <xsl:value-of select="@processContents"/>
                                    </entry>
                                </row>
                            </xsl:if>
                            <xsl:if test="exists(@appliesToEmpty)">
                                <row>
                                    <entry>Applies to empty</entry>
                                    <entry>
                                        <xsl:value-of select="@appliesToEmpty"/>
                                    </entry>
                                </row>
                            </xsl:if>
                        </tbody>
                    </tgroup>
                </table>
            </entry>
        </row>
    </xsl:template>

    <xsl:template match="namespace">
        <row>
            <entry>Namespace</entry>
            <entry>
                <xsl:choose>
                    <xsl:when test="compare('', text()) != 0">
                        <xsl:value-of select="text()"/>
                    </xsl:when>
                    <xsl:otherwise>No namespace</xsl:otherwise>
                </xsl:choose>
            </entry>
        </row>
    </xsl:template>

    <xsl:template match="schemaLocation">
        <row>
            <entry>Schema location</entry>
            <entry>
                <xsl:value-of select="text()"/>
            </entry>
        </row>
    </xsl:template>

    <xsl:template match="diagram">
        <xsl:variable name="width" select="@width div 2.0"/>
        <xsl:variable name="widthLimited">
            <xsl:choose>
                <xsl:when test="$width > 350">350</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$width"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="width" select="concat($widthLimited, 'pt')"/>
        <row>
            <entry>Diagram</entry>
            <entry>
                <xsl:variable name="hasMap" as="xs:boolean" select="count(map) != 0"/>
                <xsl:variable name="imgExtension" select="func:substring-after-last(location/text(),'.')"/>
                <p>
                    <xsl:choose>
                        <xsl:when test="map/area" xml:space="preserve">
                            
                                    <xsl:variable name="mapName" select="map/@name"/>
                                    <imagemap id="{$mapName}">
                                        
                                        <image href="{concat('img/',$mapName,'.',$imgExtension)}"/>
                                        
                                        <xsl:for-each select="map/area">  
                                            <area>
                                                <shape><xsl:value-of select="@shape"/></shape>
                                                <coords><xsl:value-of select="@coords"/></coords>
                                                <xsl:variable name="imageRef" select="@href"/>
                                                <xsl:variable name="refTargetURI" select="resolve-uri($imageRef, base-uri())" as="xs:anyURI"/>
                                                <xsl:choose>
                                                    <!-- Local image ref -->
                                                    <xsl:when test="substring-before($refTargetURI, '#') = base-uri()">
                                                        <xref href="{concat('#',substring-after($imageRef,'#'))}"></xref>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:variable name="topicTargetID" select="substring-after(@href, concat($tempFileExtension,'#'))"/>
                                                        <xref href="{concat(substring-before(@href, $tempFileExtension), $topicExtension,'#',$topicTargetID)}"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </area>
                                        </xsl:for-each>
                                    </imagemap>
                        </xsl:when>
                        <xsl:otherwise> </xsl:otherwise>
                    </xsl:choose>
                </p>
            </entry>
        </row>
    </xsl:template>

    <xsl:template match="usedBy">
        <row>
            <entry>Used by</entry>
            <entry>
                <p>
                    <table frame="all" rowsep="1" colsep="1">
                        <tgroup cols="2">
                            <colspec colwidth="2*" align="left"/>
                            <colspec colwidth="8*" align="left"/>
                            <tbody>
                                <xsl:for-each-group select="./ref" group-by="@refType">
                                    <row>
                                        <entry>
                                            <xsl:variable name="currentRef" select="."/>
                                            <xsl:value-of select="$componentTypeLabels($currentRef/@refType)"/>
                                            <xsl:if test="count(current-group()) > 1">
                                                <xsl:text>s</xsl:text>
                                            </xsl:if>
                                            <xsl:text> </xsl:text>
                                        </entry>
                                        <entry>
                                            <xsl:for-each select="current-group()">
                                                <xsl:sort select="text()"/>
                                                <xsl:call-template name="reference"/>
                                                <xsl:if test="position() != last()">
                                                  <xsl:text>, </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </entry>
                                    </row>
                                </xsl:for-each-group>
                            </tbody>
                        </tgroup>
                    </table>
                </p>
            </entry>
        </row>
    </xsl:template>


    <xsl:template match="attributes">
        <row>
            <entry>Attributes</entry>
            <entry>
                <xsl:if test="count(attr) > 0 or count(defaultAttr) > 0">
                    <xsl:variable name="showFixed"
                        select="exists(attr/fixed/text()) or exists(defaultAttr/fixed/text())"
                        as="xs:boolean"/>
                    <xsl:variable name="showDefault"
                        select="exists(attr/default/text()) or exists(defaultAttr/default/text())"
                        as="xs:boolean"/>
                    <xsl:variable name="showUse"
                        select="exists(attr/use/text()) or exists(defaultAttr/use/text())"
                        as="xs:boolean"/>
                    <xsl:variable name="showInheritable"
                        select="exists(attr/inheritable/text()) or exists(defaultAttr/inheritable/text())"
                        as="xs:boolean"/>
                    <xsl:variable name="showAnn"
                        select="exists(attr/annotations) or exists(defaultAttr/annotations)"
                        as="xs:boolean"/>
                    <p>
                        <xsl:variable name="optionalOn"
                            select="count(($showFixed, $showDefault, $showInheritable, $showUse)[. = true()])"/>

                        <table frame="all" rowsep="1" colsep="1">
                            <tgroup cols="{2 + $optionalOn}">
                                <colspec colnum="1" colname="col1" align="left" colwidth="3*"/>
                                <colspec colnum="2" colname="col2" align="left" colwidth="3*"/>

                                <xsl:for-each select="1 to $optionalOn">
                                    <colspec colnum="{2 + position()}" colname="col{2 + position()}"
                                        align="left">
                                        <xsl:attribute name="colwidth">
                                            <xsl:choose>
                                                <xsl:when
                                                  test="(position() = 1 and ($showFixed or $showDefault)) or (position() = 2 and $showFixed and $showDefault)"
                                                  >2*</xsl:when>
                                                <xsl:otherwise>1*</xsl:otherwise>
                                            </xsl:choose>

                                        </xsl:attribute>
                                    </colspec>
                                </xsl:for-each>

                                <thead>
                                    <row>
                                        <entry>QName</entry>
                                        <entry>Type</entry>
                                        <xsl:if test="$showFixed">
                                            <entry>Fixed</entry>
                                        </xsl:if>
                                        <xsl:if test="$showDefault">
                                            <entry>Default</entry>
                                        </xsl:if>
                                        <xsl:if test="$showUse">
                                            <entry>Use</entry>
                                        </xsl:if>
                                        <xsl:if test="$showInheritable">
                                            <entry>Inheritable</entry>
                                        </xsl:if>
                                    </row>
                                </thead>
                                <tbody>
                                    <xsl:for-each select="attr">
                                        <xsl:sort select="ref/text()"/>
                                        <row>
                                            <entry>
                                                <xsl:call-template name="reference">
                                                  <xsl:with-param name="ref" select="ref"/>
                                                </xsl:call-template>
                                            </entry>
                                            <entry>
                                                <xsl:call-template name="typeEmitter">
                                                  <xsl:with-param name="type" select="type"/>
                                                </xsl:call-template>
                                            </entry>
                                            <xsl:if test="$showFixed">
                                                <entry>
                                                  <xsl:value-of select="fixed"/>
                                                </entry>
                                            </xsl:if>
                                            <xsl:if test="$showDefault">
                                                <entry>
                                                  <xsl:value-of select="default"/>
                                                </entry>
                                            </xsl:if>
                                            <xsl:if test="$showUse">
                                                <entry>
                                                  <xsl:value-of select="use"/>
                                                </entry>
                                            </xsl:if>
                                            <xsl:if test="$showInheritable">
                                                <entry>
                                                  <xsl:value-of select="inheritable"/>
                                                </entry>
                                            </xsl:if>
                                        </row>
                                        <xsl:if test="annotations/annotation">
                                            <row>
                                                <entry namest="col1" nameend="col{2 + $optionalOn}">
                                                  <xsl:for-each select="annotations/annotation">
                                                  <xsl:call-template name="buildAnnotation"/>
                                                  </xsl:for-each>
                                                </entry>
                                            </row>
                                        </xsl:if>
                                    </xsl:for-each>
                                    <xsl:for-each select="defaultAttr">
                                        <xsl:sort select="ref/text()"/>
                                        <row>
                                            <entry>
                                                <b>
                                                  <xsl:call-template name="reference">
                                                  <xsl:with-param name="ref" select="ref"/>
                                                  </xsl:call-template>
                                                </b>
                                                <b>[Default]</b>
                                            </entry>
                                            <entry>
                                                <xsl:call-template name="typeEmitter">
                                                  <xsl:with-param name="type" select="type"/>
                                                </xsl:call-template>
                                            </entry>
                                            <xsl:if test="$showFixed">
                                                <entry>
                                                  <xsl:value-of select="fixed"/>
                                                </entry>
                                            </xsl:if>
                                            <xsl:if test="$showDefault">
                                                <entry>
                                                  <xsl:value-of select="default"/>
                                                </entry>
                                            </xsl:if>
                                            <xsl:if test="$showUse">
                                                <entry>
                                                  <xsl:value-of select="use"/>
                                                </entry>
                                            </xsl:if>
                                            <xsl:if test="$showInheritable">
                                                <entry>
                                                  <xsl:value-of select="inheritable"/>
                                                </entry>
                                            </xsl:if>
                                        </row>
                                        <xsl:if test="annotations/annotation">
                                            <row>
                                                <entry namest="col2" nameend="col6">
                                                  <xsl:for-each select="annotations/annotation">
                                                  <xsl:call-template name="buildAnnotation"/>
                                                  </xsl:for-each>
                                                </entry>
                                            </row>
                                        </xsl:if>
                                    </xsl:for-each>
                                </tbody>
                            </tgroup>
                        </table>
                    </p>
                </xsl:if>
                <xsl:if test="count(anyAttr) > 0">
                    <table frame="all" rowsep="1" colsep="1">
                        <tgroup cols="2">
                            <colspec colwidth="1*" align="left"/>
                            <colspec colwidth="9*" align="left"/>
                            <tbody>
                                <xsl:for-each select="anyAttr">
                                    <row>
                                        <entry>
                                            <b>Wildcard:</b>
                                        </entry>
                                        <entry>
                                            <xsl:value-of select="text()"/>
                                        </entry>
                                    </row>
                                </xsl:for-each>
                            </tbody>
                        </tgroup>
                    </table>
                </xsl:if>
            </entry>
        </row>
    </xsl:template>

    <xsl:template match="asserts">
        <row>
            <entry>Asserts</entry>
            <entry>

                <table frame="all" rowsep="1" colsep="1">
                    <tgroup cols="2">
                        <colspec colnum="1" colname="col1" align="left" colwidth="4*"/>
                        <colspec colnum="2" colname="col2" align="left" colwidth="4*"/>
                        <thead>
                            <row>
                                <entry>Test</entry>
                                <entry>XPath default namespace</entry>
                            </row>
                        </thead>
                        <tbody>
                            <xsl:for-each select="assert">
                                <row>
                                    <entry>
                                        <xsl:value-of select="test"/>
                                    </entry>
                                    <entry>
                                        <xsl:value-of select="xpathDefaultNs"/>
                                    </entry>
                                </row>
                                <xsl:if test="annotations/annotation">
                                    <row>
                                        <entry namest="col1" nameend="col2">
                                            <xsl:for-each select="annotations/annotation">
                                                <xsl:call-template name="buildAnnotation"/>
                                            </xsl:for-each>
                                        </entry>
                                    </row>
                                </xsl:if>
                            </xsl:for-each>
                        </tbody>
                    </tgroup>
                </table>

            </entry>
        </row>
    </xsl:template>

    <xsl:template match="typeAlternatives">
        <row>
            <entry>Type Alternatives</entry>
            <entry>

                <table frame="all" rowsep="1" colsep="1">
                    <tgroup cols="3">
                        <colspec colnum="1" colname="col1" align="left" colwidth="4*"/>
                        <colspec colnum="2" colname="col2" align="left" colwidth="4*"/>
                        <colspec colnum="3" colname="col3" align="left" colwidth="4*"/>
                        <thead>
                            <row>
                                <entry>Type</entry>
                                <entry>Test</entry>
                                <entry>XPath default namespace</entry>
                            </row>
                        </thead>
                        <tbody>
                            <xsl:for-each select="typeAlternative">
                                <row>
                                    <entry>
                                        <xsl:call-template name="typeEmitter">
                                            <xsl:with-param name="type" select="type"/>
                                        </xsl:call-template>
                                        <!-- Last type is the default type alternative, if the test XPath expression is missing-->
                                        <xsl:if
                                            test="(position() = last()) and not(exists(test/text()))">
                                            <xsl:text> [Default Type]</xsl:text>
                                        </xsl:if>
                                    </entry>
                                    <entry>
                                        <xsl:value-of select="test"/>
                                    </entry>
                                    <entry>
                                        <xsl:value-of select="xPathDefaultNs"/>
                                    </entry>
                                </row>
                                <xsl:if test="annotations/annotation">
                                    <row>
                                        <entry namest="col1" nameend="col3">
                                            <xsl:for-each select="annotations/annotation">
                                                <xsl:call-template name="buildAnnotation"/>
                                            </xsl:for-each>
                                        </entry>
                                    </row>
                                </xsl:if>
                            </xsl:for-each>
                        </tbody>
                    </tgroup>
                </table>

            </entry>
        </row>
    </xsl:template>

    <xsl:template name="component">
        <xsl:param name="type"/>
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="exists(redefinedComponent)">
                    <xsl:text>Redefines </xsl:text>
                    <xsl:value-of select="$type"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="reference">
                        <xsl:with-param name="ref" select="redefinedComponent"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="exists(overriddenComponent)">
                    <xsl:text>Overrides </xsl:text>
                    <xsl:value-of select="$type"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="reference">
                        <xsl:with-param name="ref" select="overriddenComponent"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="exists(overridingComponent)">
                    <xsl:text>Overridden by </xsl:text>
                    <xsl:value-of select="$type"/>
                    <xsl:text> </xsl:text>
                    <xsl:call-template name="reference">
                        <xsl:with-param name="ref" select="overridingComponent"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$type"/>
                    <xsl:text> </xsl:text>

                    <xsl:for-each select="declarationPath/ref">
                        <xsl:value-of select="."/>
                        <!-- Placed in the title, the links generated by the reference 
                            template are breaking the TOC, adding the text 
                            "the section called" before each link target. -->

                        <!--                                   <xsl:call-template name="reference"/> -->
                        <xsl:text> / </xsl:text>
                    </xsl:for-each>
                    <xsl:if test="compare(local-name(.), 'attribute') = 0">
                        <xsl:text>@</xsl:text>
                    </xsl:if>
                    <xsl:value-of select="qname/text()"/>

                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <topic>
            <!-- Take the ID of the global component -->
            <xsl:attribute name="id" select="@id"/>
            <title>
                <xsl:value-of select="$title"/>
            </title>

            <body>


                <xsl:if
                    test="
                        count(namespace | annotations | diagram | type | typeAlternatives | typeHierarchy | properties | defaultOpenContent | facets | substitutionGroup |
                        substitutionGroupAffiliation | usedBy | model | children | attributes | asserts | contraints | instance | source | publicid | systemid | schemaLocation) > 0">
                    <table frame="all" rowsep="1" colsep="1">
                        <tgroup cols="2">
                            <colspec colwidth="3*" align="left"/>
                            <colspec colwidth="25*" align="left"/>
                            <tbody>
                                <xsl:apply-templates select="namespace | annotations"/>
                                <xsl:apply-templates
                                    select="diagram | type | typeHierarchy | properties | defaultOpenContent"/>
                                <xsl:apply-templates select="facets"/>
                                <xsl:apply-templates
                                    select="substitutionGroup | substitutionGroupAffiliation"/>
                                <xsl:apply-templates
                                    select="usedBy | model | children | attributes | typeAlternatives | asserts | contraints | instance | source"/>
                                <xsl:apply-templates select="publicid | systemid"/>
                                <xsl:apply-templates select="schemaLocation"/>
                            </tbody>
                        </tgroup>
                    </table>
                </xsl:if>

            </body>

            <xsl:if test="empty(declarationPath)">
                <xsl:apply-templates select="following-sibling::*[declarationPath]"/>
                <xsl:apply-templates select="preceding-sibling::*[declarationPath]"/>
            </xsl:if>

        </topic>


    </xsl:template>

    <xsl:template name="typeEmitter">
        <xsl:param name="type"/>
        <xsl:for-each select="$type/node()">
            <xsl:choose>
                <xsl:when test="compare('ref', local-name()) = 0">
                    <xsl:call-template name="reference">
                        <xsl:with-param name="ref" select="."/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="element/type | complexType/type | attribute/type | simpleType/type">
        <row>
            <entry>Type</entry>
            <entry>
                <xsl:call-template name="typeEmitter">
                    <xsl:with-param name="type" select="."/>
                </xsl:call-template>
            </entry>
        </row>
    </xsl:template>

    <!-- Show the hierarchy type  -->
    <xsl:template name="hierarchyOutput">
        <xsl:param name="refs"/>
        <xsl:param name="index" as="xs:integer" select="1"
            xmlns:xs="http://www.w3.org/2001/XMLSchema"/>
        <ul>
            <li>
                <p>
                    <xsl:call-template name="reference">
                        <xsl:with-param name="ref" select="$refs[$index]"/>
                    </xsl:call-template>
                </p>
                <xsl:if test="$index &lt; count($refs)">
                    <xsl:call-template name="hierarchyOutput">
                        <xsl:with-param name="refs" select="$refs"/>
                        <xsl:with-param name="index" select="$index + 1"/>
                    </xsl:call-template>
                </xsl:if>
            </li>
        </ul>
    </xsl:template>

    <xsl:template match="typeHierarchy">
        <row>
            <entry>Type hierarchy</entry>
            <entry>
                <xsl:call-template name="hierarchyOutput">
                    <xsl:with-param name="refs" select="ref"/>
                </xsl:call-template>
            </entry>
        </row>
    </xsl:template>

    <xsl:template match="model">
        <row>
            <entry>Model</entry>
            <entry>
                <xsl:choose>
                    <xsl:when test="exists(openContent)">
                        <table frame="all" rowsep="1" colsep="1">
                            <tgroup cols="2">
                                <colspec colnum="1" colname="col1" colwidth="2*" align="left"/>
                                <colspec colnum="2" colname="col2" colwidth="8*" align="left"/>
                                <tbody>
                                    <xsl:if test="count(group) > 0">
                                        <row>
                                            <entry namest="col1" nameend="col2">
                                                <xsl:call-template name="groupTemplate">
                                                  <xsl:with-param name="group" select="group[1]"/>
                                                </xsl:call-template>
                                            </entry>
                                        </row>
                                    </xsl:if>
                                    <xsl:choose>
                                        <xsl:when test="exists(openContent/ref)">
                                            <!-- Add rederence to default open content -->
                                            <row>
                                                <entry namest="col1" nameend="col2">
                                                  <xsl:call-template name="reference">
                                                  <xsl:with-param name="ref"
                                                  select="openContent/ref"/>
                                                  </xsl:call-template>
                                                </entry>
                                            </row>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <row>
                                                <entry namest="col1" nameend="col2">
                                                  <b>Open Content:</b>
                                                </entry>
                                            </row>
                                            <xsl:if test="exists(openContent/@mode)">
                                                <row>
                                                  <entry>Mode</entry>
                                                  <entry>
                                                  <xsl:value-of select="openContent/@mode"/>
                                                  </entry>
                                                </row>
                                            </xsl:if>
                                            <xsl:if test="exists(openContent/text())">
                                                <row>
                                                  <entry>Wildcard</entry>
                                                  <entry>
                                                  <xsl:value-of select="openContent/text()"/>
                                                  </entry>
                                                </row>
                                            </xsl:if>
                                            <xsl:if test="exists(openContent/@processContents)">
                                                <row>
                                                  <entry>Process contents</entry>
                                                  <entry>
                                                  <xsl:value-of
                                                  select="openContent/@processContents"/>
                                                  </entry>
                                                </row>
                                            </xsl:if>
                                            <xsl:if test="exists(openContent/@appliesToEmpty)">
                                                <row>
                                                  <entry>Applies to empty</entry>
                                                  <entry>
                                                  <xsl:value-of select="openContent/@appliesToEmpty"
                                                  />
                                                  </entry>
                                                </row>
                                            </xsl:if>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </tbody>
                            </tgroup>
                        </table>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="groupTemplate">
                            <xsl:with-param name="group" select="group[1]"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </entry>
        </row>
    </xsl:template>

    <xsl:template name="groupTemplate">
        <xsl:param name="group" select="."/>
        <xsl:variable name="compositor">
            <xsl:value-of select="$group/@compositor"/>
        </xsl:variable>
        <xsl:variable name="separator">
            <xsl:if test="compare($compositor, 'sequence') = 0">
                <xsl:text> , </xsl:text>
            </xsl:if>
            <xsl:if test="compare($compositor, 'choice') = 0">
                <xsl:text> | </xsl:text>
            </xsl:if>
            <xsl:if test="compare($compositor, 'all') = 0">
                <xsl:text> </xsl:text>
            </xsl:if>
        </xsl:variable>

        <xsl:if test="compare($compositor, 'all') = 0">
            <xsl:text>ALL(</xsl:text>
        </xsl:if>
        <xsl:for-each
            select="$group/*[compare(local-name(.), 'group') = 0 or compare(local-name(.), 'ref') = 0]">
            <xsl:if test="position() != 1">
                <xsl:value-of select="$separator"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="compare(local-name(.), 'ref') = 0">
                    <xsl:call-template name="reference"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="nextCompositor">
                        <xsl:value-of select="@compositor"/>
                    </xsl:variable>

                    <xsl:if test="compare($compositor, $nextCompositor) != 0">
                        <xsl:text>(</xsl:text>
                    </xsl:if>

                    <xsl:call-template name="groupTemplate"/>

                    <xsl:if test="compare($compositor, $nextCompositor) != 0">
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

        <xsl:if test="compare($compositor, 'all') = 0">
            <xsl:text>)</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="children">
        <row>
            <entry>Children</entry>
            <entry>
                <xsl:for-each select="child">
                    <xsl:sort select="ref/text()"/>
                    <xsl:call-template name="reference">
                        <xsl:with-param name="ref" select="ref"/>
                    </xsl:call-template>
                    <xsl:if test="position() != last()">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </entry>
        </row>
    </xsl:template>

    <xsl:template match="source | instance">
        <row>
            <entry>
                <xsl:choose>
                    <xsl:when test="compare(local-name(.), 'source') = 0">Source</xsl:when>
                    <xsl:otherwise>Instance</xsl:otherwise>
                </xsl:choose>
            </entry>
            <entry>
                <!-- Formats an XML source section-->
                <xsl:variable name="tokens" select="token"/>
                <xsl:call-template name="formatXmlSource">
                    <xsl:with-param name="tokens" select="$tokens"/>
                </xsl:call-template>
            </entry>
        </row>
    </xsl:template>


    <xsl:template match="constraints">
        <row>
            <entry>Identity constraints</entry>
            <entry>
                <informaltable frame="all" colsep="1">
                    <tgroup cols="5">
                        <colspec colwidth="2*" align="left"/>
                        <colspec colwidth="2*" align="left"/>
                        <colspec colwidth="2*" align="left"/>
                        <colspec colwidth="2*" align="left"/>
                        <colspec colwidth="2*" align="left"/>
                        <thead>
                            <row>
                                <entry>QName</entry>
                                <entry>Type</entry>
                                <entry>Refer</entry>
                                <entry>Selector</entry>
                                <entry>Field(s)</entry>
                            </row>
                        </thead>
                        <tbody>
                            <xsl:for-each select="constraint">
                                <row>
                                    <entry>
                                        <emphasis role="bold">
                                            <xsl:value-of select="name"/>
                                        </emphasis>
                                    </entry>
                                    <entry>
                                        <xsl:value-of select="type"/>
                                    </entry>
                                    <entry>
                                        <xsl:value-of select="refer"/>
                                    </entry>
                                    <entry>
                                        <xsl:value-of select="selector"/>
                                    </entry>
                                    <entry>
                                        <xsl:value-of select="fields"/>
                                    </entry>
                                </row>
                            </xsl:for-each>
                        </tbody>
                    </tgroup>
                </informaltable>

            </entry>
        </row>
    </xsl:template>

    <xsl:template match="publicid | systemid">
        <row>
            <entry>
                <xsl:choose>
                    <xsl:when test="compare(local-name(.), 'publicid') = 0">Public ID</xsl:when>
                    <xsl:otherwise>System ID</xsl:otherwise>
                </xsl:choose>
            </entry>
            <entry>
                <xsl:value-of select="text()"/>
            </entry>
        </row>
    </xsl:template>

    <xsl:template match="substitutionGroup | substitutionGroupAffiliation">
        <row>
            <entry>
                <xsl:choose>
                    <xsl:when test="compare(local-name(.), 'substitutionGroup') = 0">Substitution
                        Group</xsl:when>
                    <xsl:otherwise>Substitution Group Affiliation</xsl:otherwise>
                </xsl:choose>
            </entry>
            <entry>
                <ul>
                    <xsl:for-each select="ref">
                        <li>
                            <p>
                                <xsl:call-template name="reference"/>
                            </p>
                        </li>
                    </xsl:for-each>
                </ul>
            </entry>
        </row>
    </xsl:template>

    <xsl:template match="annotations">
        <row>
            <entry>Annotations</entry>
            <entry>
                <xsl:for-each select="annotation">
                    <xsl:call-template name="buildAnnotation"/>
                </xsl:for-each>
            </entry>
        </row>
    </xsl:template>

    <xd:doc>
        <xd:desc>Builds an annotation representation from the context annotation </xd:desc>
    </xd:doc>
    <xsl:template name="buildAnnotation">
        <xsl:if test="exists(@source)">
            <xsl:variable name="fileExt" select="func:substring-after-last(@source, '.')"/>
            <xsl:choose>
                <xsl:when test="starts-with(@source, 'http')">
                    <xsl:choose>
                        <xsl:when test="contains($fileExt, '#')">
                            <xref href="{@source}" format="{substring-before($fileExt, '#')}"
                                scope="external">
                                <xsl:value-of select="@source"/>
                            </xref>
                        </xsl:when>
                        <xsl:otherwise>
                            <xref href="{@source}" format="{$fileExt}" scope="external">
                                <xsl:value-of select="@source"/>
                            </xref>

                        </xsl:otherwise>
                    </xsl:choose>

                </xsl:when>
                <xsl:otherwise>
                    <xref href="{@source}" format="{$fileExt}">
                        <xsl:value-of select="@source"/>
                    </xref>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:variable name="tokens" select="token"/>
        <xsl:choose>
            <xsl:when test="empty($tokens)">
                <xsl:for-each select="child::node()">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <!-- Formats an XML source section-->
                <xsl:call-template name="formatXmlSource">
                    <xsl:with-param name="tokens" select="$tokens"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="formatXmlSource">
        <xsl:param name="tokens"/>

        <codeblock outputclass="language-xml">
            <xsl:for-each select="$tokens">
                <xsl:choose>
                    <!-- Simple text. -->
                    <xsl:when test="@type = 'tT' or @type = 'tCD'">
                        <xsl:choose>
                            <xsl:when test="text() = ' '">
                                <!-- Just a whitespace should preserve it, 
                                    may be it dellimits something.  -->
                                <xsl:text xml:space="preserve"> </xsl:text>
                            </xsl:when>
                            <xsl:when test="@xml:space = 'preserve'">
                                <xsl:value-of select="text()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(text())"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <!-- The indent -->
                    <xsl:when test="@type = 'tI'">
                        <xsl:value-of select="text()"/>
                    </xsl:when>
                    <!-- Other tokens -->
                    <xsl:otherwise>
                        <xsl:variable name="class">
                            <xsl:choose>
                                <xsl:when test="@type = 'tEl'">element</xsl:when>
                                <xsl:when test="@type = 'tAN'">attribute</xsl:when>
                                <xsl:when test="@type = 'tAV'">attvalue</xsl:when>
                                <xsl:when test="@type = 'tC'">comment</xsl:when>
                                <xsl:when test="@type = 'tCD'">comment</xsl:when>
                                <xsl:when test="@type = 'tPI'">xmlpi</xsl:when>
                                <xsl:when test="@type = 'tEn'">genentity</xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:value-of select="text()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </codeblock>
    </xsl:template>

    <xd:doc>
        <xd:desc>Builds a hierarchy of the documented schemas based on the detected
            directives.</xd:desc>
        <xd:param name="mainSchema">Main schema. The hierarchy is found inside it.</xd:param>
    </xd:doc>
    <xsl:template match="schemaHierarchy">
        <xsl:variable name="schemaHierarchy" select="."/>
        <topic id="{$splitInfo/@indexLocation}">
            <title>Resource hierarchy</title>
            <body>
                <p>
                    <b>Legend: </b>
                    <image href="{$scHierarchyIcons('import')}"/>
                    <i> Import, </i>
                    <image href="{$scHierarchyIcons('include')}"/>
                    <i> Include, </i>
                    <image href="{$scHierarchyIcons('redefine')}"/>
                    <i> Redefine, </i>
                    <image href="{$scHierarchyIcons('override')}"/>
                    <i> Override, </i>
                    <image href="img/Cycle12.png"/>
                    <i> Cycle detected</i>
                </p>
                <ul>
                    <li>
                        <xsl:variable name="referredResource"
                            select="concat(substring-before($schemaHierarchy/@base, $tempFileExtension), $topicExtension)"/>
                        <xref href="{$referredResource}">
                            <xsl:value-of select="$referredResource"/>
                        </xref>
                    </li>
                    <xsl:for-each select="$schemaHierarchy">
                        <xsl:apply-templates>
                            <xsl:with-param name="parentSchema"
                                select="$schemaHierarchy/@schemaLocation"/>
                        </xsl:apply-templates>
                    </xsl:for-each>
                </ul>
            </body>
        </topic>
    </xsl:template>

    <xd:doc>
        <xd:desc>Process a directive and output a list item. Recursion is used so that a tree like
            representation is build using lists.</xd:desc>
        <xd:param name="parentSchema">Parent schema for this directive.</xd:param>
    </xd:doc>
    <xsl:template match="directive">
        <xsl:param name="parentSchema"/>

        <xsl:variable name="directive" select="."/>
        <xsl:variable name="image">
            <xsl:choose>
                <xsl:when test="not($directive/@cycle)">
                    <xsl:text>img/HierarchyArrow12.jpg</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>img/Cycle12.png</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <li>
            <xsl:variable name="referredResource"
                select="concat(substring-before($directive/@base, $tempFileExtension), $topicExtension)"/>
            <xsl:choose>
                <xsl:when test="exists($directive/@refId)">
                    <p>
                        <image href="{$image}"/>
                        <image href="{$scHierarchyIcons($directive/@directiveType)}"/>
                        <xref href="{$referredResource}">
                            <xsl:value-of select="$referredResource"/>
                        </xref>
                    </p>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$referredResource"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="exists(child::node())">
                <ul>
                    <xsl:apply-templates>
                        <xsl:with-param name="parentSchema" select="$directive/@schemaLocation"/>
                    </xsl:apply-templates>
                </ul>
            </xsl:if>
        </li>
    </xsl:template>

    <xsl:template match="text()"/>
</xsl:stylesheet>
