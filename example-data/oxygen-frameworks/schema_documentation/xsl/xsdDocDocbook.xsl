<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Copyright 2001-2011 Syncro Soft SRL. All rights reserved.
 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:func="http://www.oxygenxml.com/xsdDoc/functions" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    
    xmlns="http://docbook.org/ns/docbook"    
    xpath-default-namespace="http://www.oxygenxml.com/ns/doc/schema-internal" 
    exclude-result-prefixes="#all">
    
    <xsl:param name="mainFile" required="yes"/>
    
    <xd:doc>
        <xd:desc>The oXygen family product used to generate the documentation.
            <xd:p> Possible values:
                <xd:ul>
                    <xd:li>Editor (default value)</xd:li>
                    <xd:li>Developer</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="distribution">Editor</xsl:param>
    
    <xsl:output method="xml" encoding="UTF-8" version="1.0"
        exclude-result-prefixes="#all"/>
    <xsl:variable name="extension">
        <xsl:variable name="ext" select="func:substring-after-last($mainFile, '.')"/>
        <xsl:choose>
            <xsl:when test="string-length($ext) = 0">
                <xsl:text></xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('.', $ext)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="chunkValueLocation">location</xsl:variable>
    <xsl:variable name="chunkValueNamespace">namespace</xsl:variable>
    <xsl:variable name="chunkValueNone">none</xsl:variable>
    
    <xsl:variable name="splitInfo" select="/schemaDoc/splitInfo"></xsl:variable>

    <xd:doc>
        <xd:desc>When all the  components are in the same file (no split after some criteria) we will use FRAMES. So the index will be redirected in a $indexFile
            and the components in a $mainFile. The output file will only contain the FRAMESET</xd:desc>
    </xd:doc>
    <xsl:variable name="isChunkMode" as="xs:boolean" xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xsl:choose>
            <xsl:when test="compare(/schemaDoc/splitInfo/@criteria, 'none') = 0"> false </xsl:when>
            <xsl:otherwise> true </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xd:doc>
        <xd:desc>When  NO CHUNKS we will generate a frame html. The index in one file and the content in other</xd:desc>
    </xd:doc>
    <xsl:variable name="indexFile" select="concat(func:substring-before-last($splitInfo/@indexLocation, '.xml'), $extension)"/>

    <xsl:variable name="mainFrame">mainFrame</xsl:variable>
    <xsl:variable name="indexFrame">indexFrame</xsl:variable>

    <xd:doc>
        <xd:desc>Target for all the links. If we are using a FRAME representation of the html we need to specify which frame the reference will be opened in </xd:desc>
    </xd:doc>
    <xsl:variable name="target">
        <xsl:choose>
            <xsl:when test="boolean($isChunkMode)">
                <xsl:value-of select="$mainFrame"/>
            </xsl:when>
            <xsl:otherwise>_self</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xd:doc>
        <xd:desc>Used to construct an id for identifying a property of  a component. This prefix will be added to the unique component id</xd:desc>
    </xd:doc>
    <xsl:variable name="idsPrefixMap">
        <entry key="properties">properties_</entry>
        <entry key="usedBy">usedBy_</entry>
        <entry key="attributes">attributes_</entry>
        <entry key="asserts">asserts_</entry>
        <entry key="typeAlternatives">typeAlternatives_</entry>
        <entry key="children">children_</entry>
        <entry key="source">source_</entry>
        <entry key="instance">instance_</entry>
        <entry key="facets">facets_</entry>
        <entry key="diagram">diagram_</entry>
        <entry key="annotations">annotations_</entry>
        <entry key="constraints">identityConstraints_</entry>
        <entry key="defaultOpenContent">defaultOpenContent_</entry>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>Mapping between directive types and icons. Is used in 
            the schemas hierarchy tree.</xd:desc>
    </xd:doc>
    <xsl:variable name="scHierarchyIcons">
        <entry key="import">img/Import12.gif</entry>
        <entry key="include">img/Include12.gif</entry>
        <entry key="redefine">img/Redefine12.gif</entry>
        <entry key="override">img/Override12.gif</entry>
    </xsl:variable>

    <xsl:variable name="buttonPrefix">button_</xsl:variable>

    <xsl:function name="func:getDivId" as="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xsl:param name="node"/>
        <xsl:value-of
            select="concat($idsPrefixMap/*[@key=local-name($node)]/text(), $node/parent::node()/@id)"
        />
    </xsl:function>

    <xsl:function name="func:getButtonId" as="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xsl:param name="node"/>
        <xsl:value-of select="concat($buttonPrefix/text() , func:getDivId($node))"/>
    </xsl:function>


    <xsl:variable name="schemaTypeLabels">
        <entry key="main">Main schema</entry>
        <entry key="include">Included schema</entry>
        <entry key="import">Imported schema</entry>
        <entry key="redefine">Redefined schema</entry>
        <entry key="override">Overridden schema</entry>
    </xsl:variable>

    <xsl:variable name="componentTypeLabels">
        <entry key="Element"            xsd_name="element">Element</entry>
        <entry key="Attribute"          xsd_name="attribute">Attribute</entry>
        <entry key="Complex_Type"       xsd_name="complexType">Complex Type</entry>
        <entry key="Element_Group"      xsd_name="elementGroup">Element Group</entry>
        <entry key="Attribute_Group"    xsd_name="attributeGroup">Attribute Group</entry>
        <entry key="Simple_Type"        xsd_name="simpleType">Simple Type</entry>
        <entry key="Schema"             xsd_name="schema">Schema</entry>
        <entry key="Notation"           xsd_name="notation">Notation</entry>
    </xsl:variable>

    <xd:doc>
        <xd:desc>Build a title message 
            <xd:ul>
                <xd:li>If the documentation was splited by namespace we present something like: "Documentation for namespace 'ns'"</xd:li>
                <xd:li>If the documentation was splited by location we present somehing like: "Documentation for 'Schema.xsd'"</xd:li>
                <xd:li>If no split we always present: "Documentation for 'MainSchema.xsd'" and this function will not be used</xd:li>
            </xd:ul>
        </xd:desc>
    </xd:doc>
    <xsl:function name="func:getTitle" as="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xsl:param name="ref"/>
        <xsl:param name="criteria"/>
        <xsl:variable name="message">
            <xsl:text>updatePageTitle('</xsl:text>
            <xsl:choose>
                <xsl:when test="compare($criteria, $chunkValueLocation) = 0">
                    <!-- The split is done after the location-->
                    <xsl:value-of select="func:getLocationChunkTitle($ref/@schemaLocation)"/>
                </xsl:when>
                <xsl:when test="compare($criteria, $chunkValueNamespace) = 0">
                    <!-- The split is done after the namespace -->
                    <xsl:value-of select="func:getNamespaceChunkTitle($ref/@ns)"/>
                </xsl:when>
            </xsl:choose>
            <xsl:text>')</xsl:text>
        </xsl:variable>
        <xsl:value-of select="$message"/>
    </xsl:function>

    <xsl:function name="func:getNamespaceChunkTitle" as="xs:string"
        xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xsl:param name="ns"/>
        <xsl:variable name="toReturn">
            <xsl:text>Schema documentation for namespace </xsl:text>
            <xsl:value-of select="$ns"/>
        </xsl:variable>
        <xsl:value-of select="$toReturn"/>
    </xsl:function>

    <xsl:function name="func:getLocationChunkTitle" as="xs:string"
        xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xsl:param name="location"/>
        <xsl:variable name="toReturn">
            <xsl:text>Schema documentation for </xsl:text>
            <xsl:value-of select="$location"/>            
        </xsl:variable>
        <xsl:value-of select="$toReturn"/>
    </xsl:function>

    <xd:doc>
        <xd:desc>Get the title of the html page by analyzing the splitInfo element </xd:desc>
    </xd:doc>
    <xsl:function name="func:getTitleFromSplitInfo" as="xs:string"
        xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xsl:param name="splitInfo"/>
        <xsl:choose>
            <xsl:when test="compare($splitInfo/@criteria, $chunkValueNamespace) = 0">
                <xsl:value-of select="func:getNamespaceChunkTitle($splitInfo/@value)"/>
            </xsl:when>
            <xsl:when test="compare($splitInfo/@criteria, $chunkValueLocation) = 0">
                <xsl:value-of select="func:getLocationChunkTitle($splitInfo/parent::node()/schema[compare(./schemaLocation/text(), $splitInfo/@value) = 0]/qname)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="func:getLocationChunkTitle($splitInfo/parent::node()/schema[compare(@type, 'main') = 0]/qname)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xd:doc>
        <xd:desc>Get the substring before the last occurence of the given substring </xd:desc>
    </xd:doc>
    <xsl:function name="func:substring-before-last" as="xs:string">
        <xsl:param name="string"/>
        <xsl:param name="searched"/>
        <xsl:variable name="toReturn">
            <xsl:choose>
                <xsl:when test="contains($string, $searched)">
                    <xsl:variable name="before"
                        select="substring-before($string, $searched)"/>
                    
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
                <xsl:otherwise></xsl:otherwise>
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
                    <xsl:variable name="after"
                        select="substring-after($string, $searched)"/>
                    
                    <xsl:variable name="rec" 
                        select="func:substring-after-last($after, $searched)"/>
                    <xsl:choose>
                        <xsl:when test="string-length($rec) = 0">
                            <xsl:value-of select="$after"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$rec"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$toReturn"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>The entry point </xd:desc>
    </xd:doc>
    <xsl:template match="schemaDoc">
        <xsl:text xml:space="preserve">
</xsl:text>
        <xsl:processing-instruction name="oxygen">RNGSchema="http://www.oasis-open.org/docbook/xml/5.0/rng/docbook.rng" type="xml"</xsl:processing-instruction>
        <xsl:text xml:space="preserve">
</xsl:text>
        <xsl:comment>XML Schema documentation generated by &lt;oXygen/&gt; XML <xsl:value-of select="$distribution"/>.</xsl:comment>
        <article
            xmlns:xlink="http://www.w3.org/1999/xlink" version="5.0">
            <title>
                <xsl:value-of select="func:getTitleFromSplitInfo(./splitInfo)"/>
            </title>
            <info>
                <pubdate><xsl:value-of select="format-date(current-date(),'[Mn] [D], [Y]', 'en', (), ())"/></pubdate>
            </info>
            
            <!-- Generate a schemas hierarchy. -->
            <xsl:apply-templates select="schemaHierarchy"/>
                
            <xsl:call-template name="main"/>            
        </article>
    </xsl:template>

    <xd:doc>
        <xd:desc>Create the a link element to a component</xd:desc>
    </xd:doc>
    <xsl:template name="reference">
        <xsl:param name="ref" select="."/>
        <xsl:choose>
            <xsl:when test="exists($ref/@refId)">
                    <link linkend="{$ref/@refId}">
                        <xsl:value-of select="$ref/text()"/>
                    </link>
                    <!-- 
                    <a href="{concat(substring-before($ref/@base,'.xml'), $extension, '#', $ref/@refId)}"
                        target="{$target}">
                        <xsl:attribute name="title">
                            <xsl:choose>
                                <xsl:when test="compare('', $ref/@ns) = 0">No namespace</xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$ref/@ns"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:variable name="criteria" select="$splitInfo/@criteria"/>
                        <xsl:if test="compare($criteria, $chunkValueNone) != 0">
                            <xsl:attribute name="onclick" select="func:getTitle($ref, $criteria)"/>
                        </xsl:if>
                        <xsl:value-of select="$ref/text()"/>
                    </a>
                    -->
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
                <xsl:value-of select="$schemaTypeLabels/*[@key=$currentSchema/@type]"/>
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
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <row>
            <entry>
                 Facets
            </entry>
            <entry>
                <informaltable frame="none" colsep="0" >      
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
                                <literal>
                                    <xsl:value-of select="@value"/>
                                </literal>
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
                </informaltable>
            </entry>
        </row>
    </xsl:template>

    <xsl:template match="properties">
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <row>
            <entry> Properties </entry>
            <entry>
                <informaltable frame="none" colsep="0">
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
                                                <literal><xsl:value-of select="value"/></literal>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </entry>
                                </row>
                            </xsl:for-each>
                        </tbody>
                    </tgroup>
                </informaltable>
            </entry>
        </row>
    </xsl:template>
    
    <xsl:template match="defaultOpenContent">
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <row>
            <entry>
                    Default Open Content
            </entry>
            <entry>
                <informaltable frame="none" colsep="0">
                    <tgroup cols="2">
                        <colspec colwidth="2*" align="left"/>
                        <colspec colwidth="8*" align="left"/>
                        <tbody>
                            <!-- Add open content documentation -->
                            <xsl:if test="exists(@mode)">
                                <row>
                                    <entry>Mode</entry>
                                    <entry>
                                        <literal><xsl:value-of select="@mode"/></literal>
                                    </entry>
                                </row>
                            </xsl:if>
                            <xsl:if test="exists(text())">
                                <row>
                                    <entry>Wildcard</entry>
                                    <entry>
                                        <literal><xsl:value-of select="text()"/></literal>
                                    </entry>
                                </row>
                            </xsl:if>
                            <xsl:if test="exists(@processContents)">
                                <row>
                                    <entry>Process contents</entry>
                                    <entry>
                                        <literal><xsl:value-of select="@processContents"/></literal>
                                    </entry>
                                </row>
                            </xsl:if>
                            <xsl:if test="exists(@appliesToEmpty)">
                                <row>
                                    <entry>Applies to empty</entry>
                                    <entry>
                                        <literal><xsl:value-of select="@appliesToEmpty"/></literal>
                                    </entry>
                                </row>
                            </xsl:if>
                        </tbody>
                    </tgroup>
                </informaltable>
            </entry>
        </row>
    </xsl:template>

    <xsl:template match="namespace">
        <row>
            <entry>
                Namespace
            </entry>
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
            <entry>
                Schema location
            </entry>
            <entry>
                <xsl:value-of select="text()"/>
            </entry>
        </row>
    </xsl:template>
    
    <xsl:template match="diagram">
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <xsl:variable name="width" select="@width div 2.0"/>
        <xsl:variable name="widthLimited">
            <xsl:choose>
                <xsl:when test="$width > 350">350</xsl:when>
                <xsl:otherwise><xsl:value-of select="$width"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>        
        <xsl:variable name="width" select="concat($widthLimited,'pt')"></xsl:variable>
        <row>
            <entry>
                Diagram
            </entry>
            <entry>
                <xsl:variable name="hasMap" as="xs:boolean" select="count(map) != 0"/>                
                <para>
                    <xsl:choose>
                        <xsl:when test="map/area" xml:space="preserve">
                            
                            <mediaobject>  
                                <imageobjectco>  
                                    <xsl:variable name="mapName" select="map/@name"/>
                                    <areaspec xml:id="{$mapName}">  
                                        <xsl:for-each select="map/area">  
                                            <area 
                                                linkends="{substring-after(@href,'.tmp#')}"  
                                                units="other"
                                                otherunits="imagemap"  
                                                coords="{@coords}"                                    
                                                xml:id="{concat($mapName,'-',position())}"/>
                                        </xsl:for-each>
                                        
                                    </areaspec>
                                    <imageobject>                                        
                                                <imagedata fileref="{location/text()}" width="{$width}"/>
                                        <xsl:comment>If you want to use this Docbook document to generate
                                            HTML output you will have to delete the "width" attributes in order for the imagemaps to function.
                                        </xsl:comment>
                                    </imageobject>                                    
                                </imageobjectco>
                            </mediaobject>
                            
                        </xsl:when>
                        <xsl:otherwise>
                            <mediaobject>
                                <imageobject>
                                    <imagedata fileref="{location/text()}" width="{$width}"/>
                                </imageobject>                                
                            </mediaobject>
                        </xsl:otherwise>
                    </xsl:choose>
                </para>
            </entry>
        </row>
    </xsl:template>
    
    <xsl:template match="usedBy">
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <row>
            <entry>
                    Used by
            </entry>
            <entry>
                
                    <informaltable frame="none" colsep="0">
                        <tgroup cols="2">
                        <colspec colwidth="2*" align="left"/>
                        <colspec colwidth="8*" align="left"/>
                        <tbody>
                        <xsl:for-each-group select="./ref" group-by="@refType">
                            <row>
                                <entry>
                                    <xsl:variable name="currentRef" select="."/>
                                    <xsl:value-of
                                        select="$componentTypeLabels/*[@key=$currentRef/@refType]"/>
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
                    </informaltable>
            </entry>
        </row>
    </xsl:template>

    <xsl:template match="attributes">
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <row>
            <entry>
                    Attributes
            </entry>
            <entry>
                <xsl:if test="count(attr) > 0 or count(defaultAttr) > 0">
                    <xsl:variable name="showFixed" select="exists(attr/fixed/text()) or exists(defaultAttr/fixed/text())" as="xs:boolean"/>
                    <xsl:variable name="showDefault" select="exists(attr/default/text()) or exists(defaultAttr/default/text())" as="xs:boolean"/>
                    <xsl:variable name="showUse" select="exists(attr/use/text()) or exists(defaultAttr/use/text())" as="xs:boolean"/>
                    <xsl:variable name="showInheritable" select="exists(attr/inheritable/text()) or exists(defaultAttr/inheritable/text())" as="xs:boolean"/>
                    <xsl:variable name="showAnn" select="exists(attr/annotations) or exists(defaultAttr/annotations)" as="xs:boolean"/>
                    <informaltable frame="none" colsep="1">            
                        <tgroup cols='6'>
                            <colspec colnum="1" colname="col1" align="left" colwidth="3*"/>
                            <colspec colnum="2" colname="col2" align="left" colwidth="3*"/>
                            <colspec colnum="3" colname="col3" align="left" colwidth="2*"/>
                            <colspec colnum="4" colname="col4" align="left" colwidth="2*"/>
                            <colspec colnum="5" colname="col5" align="left" colwidth="1*"/>
                            <colspec colnum="6" colname="col6" align="left" colwidth="1*"/>
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
                                            <emphasis role="bold">
                                                <xsl:call-template name="reference">
                                                  <xsl:with-param name="ref" select="ref"/>
                                                </xsl:call-template>
                                            </emphasis>
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
                                <xsl:for-each select="defaultAttr">
                                    <xsl:sort select="ref/text()"/>
                                    <row>
                                        <entry>
                                            <emphasis role="bold">
                                                <xsl:call-template name="reference">
                                                  <xsl:with-param name="ref" select="ref"/>
                                                </xsl:call-template>
                                            </emphasis>
                                            <emphasis role="bold">[Default]</emphasis>
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
                    </informaltable>
                </xsl:if>
                <xsl:if test="count(anyAttr) > 0">
                    <informaltable frame="none" colsep="0">
                        <tgroup cols="2">
                            <colspec colwidth="1*" align="left"/>
                            <colspec colwidth="9*" align="left"/>
                            <tbody>
                                <xsl:for-each select="anyAttr">
                                    <row>
                                        <entry>
                                            <emphasis role="bold">Wildcard:</emphasis>
                                        </entry>
                                        <entry>
                                            <xsl:value-of select="text()"/>
                                        </entry>
                                    </row>
                                </xsl:for-each>
                            </tbody>
                        </tgroup>
                    </informaltable>
                </xsl:if>
            </entry>
        </row>
    </xsl:template>
    
    <xsl:template match="asserts">
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <row>
            <entry>
                Asserts
            </entry>
            <entry>
                
                <informaltable frame="none" colsep="1">            
                    <tgroup cols='2'>
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
                                        <entry  namest="col1" nameend="col2">
                                            <xsl:for-each select="annotations/annotation">
                                                <xsl:call-template name="buildAnnotation"/>                                       
                                            </xsl:for-each>                                        
                                        </entry>
                                    </row>
                                </xsl:if>
                            </xsl:for-each>                           
                        </tbody>
                    </tgroup>
                </informaltable>
                
            </entry>
        </row>
    </xsl:template>
    
    <xsl:template match="typeAlternatives">
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <row>
            <entry>
                Type Alternatives
            </entry>
            <entry>
                
                <informaltable frame="none" colsep="1">            
                    <tgroup cols='3'>
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
                                        <xsl:if test="(position() = last()) and not(exists(test/text()))">
                                            <emphasis>
                                                <xsl:text> [Default Type]</xsl:text>
                                            </emphasis>
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
                                        <entry  namest="col1" nameend="col3">
                                            <xsl:for-each select="annotations/annotation">
                                                <xsl:call-template name="buildAnnotation"/>                                       
                                            </xsl:for-each>                                        
                                        </entry>
                                    </row>
                                </xsl:if>
                            </xsl:for-each>                           
                        </tbody>
                    </tgroup>
                </informaltable>
                
            </entry>
        </row>
    </xsl:template>

    <xsl:template name="component">
        <xsl:param name="type"/>
           <section>
               <xsl:attribute name="xml:id" select="@id"/>
               <title>                   
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
                           <literal>
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
                           </literal>
                       </xsl:otherwise>
                   </xsl:choose>                      
               </title>
               <xsl:if test="count(namespace | annotations | diagram | type | typeAlternatives | typeHierarchy | properties | defaultOpenContent | facets | substitutionGroup |
                   substitutionGroupAffiliation | usedBy | model | children | attributes | asserts | contraints | instance | source | publicid | systemid | schemaLocation) > 0">
                   <informaltable frame="all" colsep="1">
                       <tgroup cols="2">
                           <colspec colwidth="3*" align="left"/>
                           <colspec colwidth="25*" align="left"/>
                           <tbody>
                               <xsl:apply-templates select="namespace | annotations"></xsl:apply-templates>
                               <xsl:apply-templates select="diagram | type | typeHierarchy | properties | defaultOpenContent"></xsl:apply-templates>
                               <xsl:apply-templates select="facets"/>
                               <xsl:apply-templates select="substitutionGroup | substitutionGroupAffiliation"/>
                               <xsl:apply-templates select="usedBy | model | children | attributes | typeAlternatives | asserts | contraints | instance | source"></xsl:apply-templates>
                               <xsl:apply-templates select="publicid | systemid"/>
                               <xsl:apply-templates select="schemaLocation"/>
                           </tbody>         
                       </tgroup>
                   </informaltable>
               </xsl:if>
           </section>              
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
            <entry>
                Type
            </entry>
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
        <itemizedlist>
            <listitem>
                <para>
                    <xsl:call-template name="reference">
                        <xsl:with-param name="ref" select="$refs[$index]"/>
                    </xsl:call-template>
                </para>
                <xsl:if test="$index &lt; count($refs)">
                    <xsl:call-template name="hierarchyOutput">
                        <xsl:with-param name="refs" select="$refs"/>
                        <xsl:with-param name="index" select="$index + 1"/>
                    </xsl:call-template>
                </xsl:if>
            </listitem>
        </itemizedlist>
    </xsl:template>

    <xsl:template match="typeHierarchy">
        <row>
            <entry>
                Type hierarchy
            </entry>
            <entry>
                <xsl:call-template name="hierarchyOutput">
                    <xsl:with-param name="refs" select="ref"/>
                </xsl:call-template>
            </entry>
        </row>
    </xsl:template>

    <xsl:template match="model">
        <row>
            <entry>
                Model
            </entry>
            <entry>
                <xsl:choose>
                    <xsl:when test="exists(openContent)">
                        <informaltable frame="none" colsep="0">
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
                                                  <xsl:with-param name="ref" select="openContent/ref"/>
                                                  </xsl:call-template>
                                                </entry>
                                            </row>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <row>
                                                <entry namest="col1" nameend="col2">
                                                  <emphasis role="bold">Open Content:</emphasis>
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
                                                  <entry><xsl:value-of select="openContent/@processContents"/></entry>
                                                </row>
                                            </xsl:if>
                                            <xsl:if test="exists(openContent/@appliesToEmpty)">
                                                <row>
                                                  <entry>Applies to empty</entry>
                                                  <entry><xsl:value-of select="openContent/@appliesToEmpty"/></entry>
                                                </row>
                                            </xsl:if>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </tbody>
                            </tgroup>
                        </informaltable>
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
            <entry>
                Children
            </entry>
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
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
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
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <row>
            <entry>
                    Identity constraints
            </entry>
            <entry>                
                    <informaltable frame="none" colsep="1">   
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
                        <xsl:when test="compare(local-name(.), 'publicid') = 0"
                            >Public ID</xsl:when>
                        <xsl:otherwise>System ID</xsl:otherwise>
                    </xsl:choose>
            </entry>
            <entry><xsl:value-of select="text()"/></entry>
        </row>
    </xsl:template>

    <xsl:template match="substitutionGroup | substitutionGroupAffiliation">
        <row>
            <entry>
                    <xsl:choose>
                        <xsl:when test="compare(local-name(.), 'substitutionGroup') = 0"
                            >Substitution Group</xsl:when>
                        <xsl:otherwise>Substitution Group Affiliation</xsl:otherwise>
                    </xsl:choose>
            </entry>
            <entry>
                
                <itemizedlist>
                    <xsl:for-each select="ref">
                        <listitem>
                            <para>
                                <xsl:call-template name="reference"/>
                            </para>
                        </listitem>
                    </xsl:for-each>
                </itemizedlist>
            </entry>
        </row>
    </xsl:template>

    <xsl:template match="annotations">
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <row>
            <entry>
                Annotations
            </entry>
            <entry>            
              <xsl:for-each select="annotation">
                <para>
                  <xsl:call-template name="buildAnnotation"/>                            
                </para>
              </xsl:for-each>
            </entry>
        </row>
    </xsl:template>

    <xd:doc>
        <xd:desc>Builds an annotation representation from the context annotation </xd:desc>
    </xd:doc>
    <xsl:template name="buildAnnotation">
            <xsl:if test="exists(@source)">
                <link xlink:href="{@source}"><xsl:value-of select="@source"/></link>
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
        
        <programlisting>
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
                <xsl:element name="tag">
                    <xsl:if test="string-length($class) > 0">
                        <xsl:attribute name="class" select="normalize-space($class)"/>
                    </xsl:if>
                    <xsl:value-of select="text()"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>            
        </xsl:for-each>
        </programlisting>
    </xsl:template>
    
    <xsl:template name="main">
        <xsl:variable name="first" select="(element | complexType | attribute | simpleType | elementGroup | schema | attributeGroup | notation)[1]"/>
        <xsl:choose>
            <xsl:when test="exists($first/namespace)">
                <xsl:for-each-group select="element | complexType | attribute | simpleType | elementGroup | schema | attributeGroup | notation" group-by="namespace">
                    <section>
                        <title> Namespace: "<xsl:value-of select="namespace"/>" </title>                
                        <xsl:for-each-group select="current-group()"  group-by="node-name(.)">
                            <section>
                                <xsl:variable name="name" select="node-name(.)"/>
                                <title><xsl:value-of select="$componentTypeLabels/*[@xsd_name=string($name)]"/>(s)</title>
                                <xsl:for-each select="current-group()">                            
                                    <xsl:apply-templates select="."/>
                                </xsl:for-each>
                            </section>
                        </xsl:for-each-group>
                    </section>
                </xsl:for-each-group>
            </xsl:when>
            <xsl:when test="exists($first/schemaLocation)">
                <xsl:for-each-group 
                    select="element | complexType | attribute | simpleType | elementGroup | schema | attributeGroup | notation" 
                    group-by="schemaLocation">
                    <section>
                        <title> Schema system ID: "<xsl:value-of select="schemaLocation"/>" </title>                
                        <xsl:for-each-group select="current-group()"  group-by="node-name(.)">
                            <section>
                                <xsl:variable name="name" select="node-name(.)"/>
                                <title><xsl:value-of select="$componentTypeLabels/*[@xsd_name=string($name)]"/>(s)</title>
                                <xsl:for-each select="current-group()">                            
                                    <xsl:apply-templates select="."/>
                                </xsl:for-each>
                            </section>
                        </xsl:for-each-group>
                    </section>
                </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each-group 
                    select="element | complexType | attribute | simpleType | elementGroup | schema | attributeGroup | notation" 
                    group-by="node-name(.)">
                    <section>
                        <xsl:variable name="name" select="node-name(.)"/>
                        <title><xsl:value-of select="$componentTypeLabels/*[@xsd_name=string($name)]"/>(s)</title>
                        <xsl:for-each select="current-group()">                            
                            <xsl:apply-templates select="."/>
                        </xsl:for-each>
                    </section>
                </xsl:for-each-group>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc>Builds a hierarchy of the documented schemas based on the detected directives.</xd:desc>
        <xd:param name="mainSchema">Main schema. The hierarchy is found inside it.</xd:param>
    </xd:doc>
    <xsl:template match="schemaHierarchy">
        <xsl:variable name="schemaHierarchy" select="."/>
        <section>
            <title>Resource hierarchy:</title>
            <para>
                <emphasis role="bold">Legend:  </emphasis>
                <inlinemediaobject>
                    <imageobject>
                        <imagedata fileref="{$scHierarchyIcons/*[@key = 'import']}"/>
                    </imageobject>
                </inlinemediaobject>
                <emphasis role="italic"> Import,  </emphasis>
                <inlinemediaobject>
                    <imageobject>
                        <imagedata fileref="{$scHierarchyIcons/*[@key = 'include']}"/>
                    </imageobject>
                </inlinemediaobject>
                <emphasis role="italic"> Include,  </emphasis>
                <inlinemediaobject>
                    <imageobject>
                        <imagedata fileref="{$scHierarchyIcons/*[@key = 'redefine']}"/>
                    </imageobject>
                </inlinemediaobject>
                <emphasis role="italic"> Redefine, </emphasis>
                <inlinemediaobject>
                    <imageobject>
                        <imagedata fileref="{$scHierarchyIcons/*[@key = 'override']}"/>
                    </imageobject>
                </inlinemediaobject>
                <emphasis role="italic"> Override, </emphasis>
                <inlinemediaobject>
                    <imageobject>
                        <imagedata fileref="img/Cycle12.png"/>
                    </imageobject>
                </inlinemediaobject>
                <emphasis role="italic"> Cycle detected</emphasis>
            </para>
            <para>
                <itemizedlist mark="none">
                    <listitem>
                        <para>
                            <link linkend="{$schemaHierarchy/@refId}">
                                <xsl:value-of select="$schemaHierarchy/@schemaLocation"/>
                            </link> 
                        </para>
                        
                        <itemizedlist mark="none">
                            <xsl:for-each select="$schemaHierarchy">
                                <xsl:apply-templates>
                                    <xsl:with-param name="parentSchema" select="$schemaHierarchy/@schemaLocation"/>
                                </xsl:apply-templates>
                            </xsl:for-each>
                        </itemizedlist>
                    </listitem>
                </itemizedlist>
            </para>
        </section>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Process a directive and output a list item. Recursion is used so that a 
            tree like representation is build using lists.</xd:desc>
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
        
        <listitem>
            <para>
                <xsl:choose>
                    <xsl:when test="exists($directive/@refId)">
                        <inlinemediaobject>
                            <imageobject>
                                <imagedata fileref="{$image}"/>
                            </imageobject>
                        </inlinemediaobject>
                        <inlinemediaobject>
                            <imageobject>
                                <imagedata fileref="{$scHierarchyIcons/*[@key = $directive/@directiveType]/text()}"/>
                            </imageobject>
                        </inlinemediaobject>
                        <xsl:text> </xsl:text>
                        <link linkend="{$directive/@refId}">
                            <xsl:value-of select="$directive/@schemaLocation"/>
                        </link>     
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$directive/@schemaLocation"/>
                    </xsl:otherwise>
                </xsl:choose>
            </para>
            <xsl:if test="exists(child::node())">
                <itemizedlist mark="none">
                    <xsl:apply-templates>
                        <xsl:with-param name="parentSchema" select="$directive/@schemaLocation"/>
                    </xsl:apply-templates>
                </itemizedlist>
            </xsl:if>
        </listitem>
        
    </xsl:template>
    
    <xsl:template match="text()"/>
</xsl:stylesheet>
