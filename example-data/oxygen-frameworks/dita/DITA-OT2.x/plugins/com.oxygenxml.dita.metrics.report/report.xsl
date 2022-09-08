<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Copyright 2001-2017 Syncro Soft SRL. All rights reserved.
    This is licensed under MPL 2.0.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:oxyd="http://www.oxygenxml.com/ns/dita">
    
    <xsl:import href="modules/resolve.xsl"/>
    <xsl:import href="modules/text.xsl"/>
    
    <xsl:output indent="yes"/>

    <xsl:param name="topX" select="10"/>
    <xsl:param name="domains" select="document('data/domains.xml')/*"/>

    <xsl:template match="/">
        <xsl:variable name="resolvedMap">
            <oxyd:mapref>
                <xsl:attribute name="xml:base" select="document-uri(.)"/>
                <xsl:apply-templates select="/" mode="resolve-map"/>
            </oxyd:mapref>
        </xsl:variable>
        <xsl:variable name="keyspace">
            <oxyd:keyspace>
                <xsl:for-each select="distinct-values($resolvedMap//@keys/tokenize(., ' '))">
                    <xsl:variable name="currentKey" select="."/>
                    <oxyd:key value="{$currentKey}">
                        <xsl:for-each select="$resolvedMap//*[@keys][tokenize(@keys, ' ')=$currentKey]">
                            <xsl:sort select="count(ancestor::oxyd:mapref)"/>   
                            <xsl:if test="position()=1">
                                <xsl:copy-of select="ancestor-or-self::oxyd:*/@xml:base[1]"/>
                                <xsl:copy>
                                    <xsl:copy-of select="@*"/>
                                </xsl:copy>
                            </xsl:if>
                        </xsl:for-each>
                    </oxyd:key>
                </xsl:for-each>
            </oxyd:keyspace>
        </xsl:variable>
        
        <!-- Get the DITA map and all its content in a resolved document -->
        <xsl:variable name="resolved">
            <oxyd:mapref>
                <xsl:attribute name="xml:base" select="document-uri(.)"/>
                <xsl:apply-templates select="/" mode="resolve">
                    <xsl:with-param name="keyspace" select="$keyspace" tunnel="yes"/>
                </xsl:apply-templates>
            </oxyd:mapref>
        </xsl:variable>
        
        <!-- Get all the text content by topic -->
        <xsl:variable name="text">
            <xsl:apply-templates select="$resolved" mode="text"/>
        </xsl:variable>
        
        <!-- Get all the words used -->
        <xsl:variable name="index">
            <xsl:apply-templates select="$resolved" mode="index"/>
        </xsl:variable>
        
        <!-- DATA -->
        <xsl:variable name="elements" select="$resolved//*[namespace-uri()!='http://www.oxygenxml.com/ns/dita']"/>
        <xsl:variable name="maps" select="$resolved//oxyd:mapref/*[1]"/>
        <xsl:variable name="topics" select="$resolved//oxyd:topicref/*[1]"/>
        <xsl:variable name="nElements" select="count($elements)"/>
        <xsl:variable name="mapElements" select="$elements[local-name(ancestor::*[self::oxyd:mapref or self::oxyd:topicref][1])='mapref']"/>
        <xsl:variable name="topicElements" select="$elements[local-name(ancestor::*[self::oxyd:mapref or self::oxyd:topicref][1])='topicref']"/>
        <xsl:variable name="conrefs" select="$resolved//oxyd:conref"/>
        <xsl:variable name="conrefContent">
            <xsl:apply-templates select="$conrefs[not(ancestor::oxyd:conref)]" mode="index"/>
        </xsl:variable>
        <xsl:variable name="topicsSortedByWords">
            <xsl:for-each select="$text/oxyd:topicText">
                <xsl:sort select="oxyd:words" data-type="number"/>
                <xsl:copy-of select="."/>                                
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="pis" select="$resolved//processing-instruction()"/>
        <xsl:variable name="externalLinks" select="$resolved//*[@href][contains(@class, ' topic/xref ') or contains(@class, ' topic/link ') or (contains(@class, ' map/topicref '))][@format != 'dita' and @format != 'ditamap' and @format != ''][@scope='external']"/>
                
        <!-- Generate the report -->
        <oxyd:report rootMap="{document-uri(/)}">
            <oxyd:stats>
                <oxyd:overview>
                    <oxyd:maps><xsl:value-of select="count($resolved//oxyd:mapref)"/></oxyd:maps>
                    <oxyd:uniqueMaps><xsl:value-of select="count(distinct-values($resolved//oxyd:mapref/@xml:base))"/></oxyd:uniqueMaps>
                    <oxyd:topics><xsl:value-of select="count($resolved//oxyd:topicref)"/></oxyd:topics>
                    <oxyd:uniqueTopics><xsl:value-of select="count(distinct-values($resolved//oxyd:topicref/@xml:base))"/></oxyd:uniqueTopics>
                </oxyd:overview>
                <oxyd:infoTypes>
                    <oxyd:mapInfoTypes>
                        <xsl:for-each-group select="$maps" group-by="name()">
                            <xsl:sort select="count(current-group())" order="descending"/>
                            <oxyd:element name="{current-grouping-key()}" count="{count(current-group())}"/>
                        </xsl:for-each-group>
                    </oxyd:mapInfoTypes>
                    <oxyd:topicInfoTypes>
                        <xsl:for-each-group select="$topics" group-by="name()">
                            <xsl:sort select="count(current-group())" order="descending"/>
                            <oxyd:element name="{current-grouping-key()}" count="{count(current-group())}"/>
                        </xsl:for-each-group>
                    </oxyd:topicInfoTypes>
                </oxyd:infoTypes>                
                <oxyd:elements>
                    <oxyd:elementsData>
                        <oxyd:totalElements><xsl:value-of select="$nElements"/></oxyd:totalElements>
                        <oxyd:uniqueElements><xsl:value-of select="count(distinct-values($elements/name()))"/></oxyd:uniqueElements>
                        <oxyd:totalMapElements><xsl:value-of select="count($mapElements/name())"/></oxyd:totalMapElements>
                        <oxyd:uniqueMapElements><xsl:value-of select="count(distinct-values($mapElements/name()))"/></oxyd:uniqueMapElements>
                        <oxyd:totalTopicElements><xsl:value-of select="count($topicElements/name())"/></oxyd:totalTopicElements>
                        <oxyd:uniqueTopicElements><xsl:value-of select="count(distinct-values($topicElements/name()))"/></oxyd:uniqueTopicElements>    
                    </oxyd:elementsData>                    
                    <oxyd:mapElements>
                        <xsl:for-each-group select="$mapElements" group-by="name()">
                            <xsl:sort select="count(current-group())" order="descending"/>
                            <oxyd:mapElement count="{count(current-group())}"><xsl:value-of select="current-grouping-key()"/></oxyd:mapElement>
                        </xsl:for-each-group>
                    </oxyd:mapElements>
                    <oxyd:topicElements>
                        <xsl:for-each-group select="$topicElements" group-by="name()">
                            <xsl:sort select="count(current-group())" order="descending"/>
                            <oxyd:topicEelement count="{count(current-group())}"><xsl:value-of select="current-grouping-key()"/></oxyd:topicEelement>
                        </xsl:for-each-group>
                    </oxyd:topicElements>
                </oxyd:elements>
                <oxyd:domainAnalysis>
                    <xsl:for-each select="$domains/*">
                        <xsl:variable name="hits" select="count(element[@name = $elements/name()])"/>
                        <xsl:if test="$hits > 0">
                            <oxyd:domain>
                                <xsl:copy-of select="@*"/>
                                <xsl:attribute name="hits" select="count(element[@name = $elements/name()])"/>
                                <xsl:attribute name="elements" select="count(element)"/>
                                <xsl:for-each select="element">
                                    <oxyd:element count="{count($elements[name()=current()/@name])}">
                                        <xsl:copy-of select="@*"/>
                                        <xsl:value-of select="documentation"/>
                                    </oxyd:element>
                                </xsl:for-each>
                            </oxyd:domain>
                        </xsl:if>
                    </xsl:for-each>                    
                </oxyd:domainAnalysis>
                
                <!-- CONREFs -->
                <oxyd:conrefs>
                    <oxyd:conrefTotalWords><xsl:value-of select="count($conrefContent/*)"/></oxyd:conrefTotalWords>
                    <oxyd:conrefTotalElements><xsl:value-of select="count($conrefs[not(ancestor::oxyd:conref)]/descendant::*)"/></oxyd:conrefTotalElements>
                    <oxyd:totalConrefs><xsl:value-of select="count($conrefs)"/></oxyd:totalConrefs>
                    <oxyd:conrefElements>
                        <xsl:for-each-group select="$conrefs" group-by="@element">
                            <xsl:sort select="count(current-group())" order="descending"/>
                            <oxyd:conrefElement count="{count(current-group())}"><xsl:value-of select="current-grouping-key()"/></oxyd:conrefElement>
                        </xsl:for-each-group>
                    </oxyd:conrefElements>
                </oxyd:conrefs>
                
                <!-- ATTRIBUTES -->
                <oxyd:attributes>
                    <oxyd:attributesData>
                        <oxyd:totalAttributes><xsl:value-of select="count($elements/@*)"/></oxyd:totalAttributes>
                        <oxyd:uniqueAttributes><xsl:value-of select="count(distinct-values($elements/@*/name()))"/></oxyd:uniqueAttributes>
                        <oxyd:totalMapAttributes><xsl:value-of select="count($mapElements/@*)"/></oxyd:totalMapAttributes>
                        <oxyd:uniqueMapAttributes><xsl:value-of select="count(distinct-values($mapElements/@*/name()))"/></oxyd:uniqueMapAttributes>
                        <oxyd:totalTopicAttributes><xsl:value-of select="count($topicElements/@*)"/></oxyd:totalTopicAttributes>
                        <oxyd:uniqueTopicAttributes><xsl:value-of select="count(distinct-values($topicElements/@*/name()))"/></oxyd:uniqueTopicAttributes>    
                    </oxyd:attributesData>
                    <oxyd:mapAttributes>
                        <xsl:for-each-group select="$mapElements/@*" group-by="name()">
                            <xsl:sort select="count(current-group())" order="descending"/>
                            <oxyd:mapAttribute count="{count(current-group())}"><xsl:value-of select="current-grouping-key()"/></oxyd:mapAttribute>
                        </xsl:for-each-group>
                    </oxyd:mapAttributes>
                    <oxyd:topicAttributes>
                        <xsl:for-each-group select="$topicElements/@*" group-by="name()">
                            <xsl:sort select="count(current-group())" order="descending"/>
                            <oxyd:topicAttribute count="{count(current-group())}"><xsl:value-of select="current-grouping-key()"/></oxyd:topicAttribute>
                        </xsl:for-each-group>
                    </oxyd:topicAttributes>
                </oxyd:attributes>
                
                <!-- CONDITIONAL ATTRIBUTES -->
                <oxyd:conditionalAttributes>
                    <oxyd:audience>
                        <xsl:for-each select="distinct-values($elements/@audience/tokenize(normalize-space(.), ' '))">
                            <xsl:sort select="."/>
                            <oxyd:attValue><xsl:value-of select="."/></oxyd:attValue>
                        </xsl:for-each>
                    </oxyd:audience>
                    <oxyd:platform>
                        <xsl:for-each select="distinct-values($elements/@platform/tokenize(normalize-space(.), ' '))">
                            <xsl:sort select="."/>
                            <oxyd:attValue><xsl:value-of select="."/></oxyd:attValue>
                        </xsl:for-each>
                    </oxyd:platform>
                    <oxyd:product>
                        <xsl:for-each select="distinct-values($elements/@product/tokenize(normalize-space(.), ' '))">
                            <xsl:sort select="."/>
                            <oxyd:attValue><xsl:value-of select="."/></oxyd:attValue>
                        </xsl:for-each>
                    </oxyd:product>
                    <oxyd:otherprops>
                        <xsl:for-each select="distinct-values($elements/@otherprops/tokenize(normalize-space(.), ' '))">
                            <xsl:sort select="."/>
                            <oxyd:attValue><xsl:value-of select="."/></oxyd:attValue>
                        </xsl:for-each>
                    </oxyd:otherprops>
                    <oxyd:rev>
                        <xsl:for-each select="distinct-values($elements/@rev/tokenize(normalize-space(.), ' '))">
                            <xsl:sort select="."/>
                            <oxyd:attValue><xsl:value-of select="."/></oxyd:attValue>
                        </xsl:for-each>
                    </oxyd:rev>
                </oxyd:conditionalAttributes>
                <oxyd:text>
                    <oxyd:words>
                        <oxyd:uniqueWords><xsl:value-of select="oxyd:fix-number(count(distinct-values($index/oxyd:word)))"/></oxyd:uniqueWords>
                        <oxyd:totalWords><xsl:value-of select="oxyd:fix-number(sum($text//oxyd:words))"/></oxyd:totalWords>
                        <oxyd:minWords><xsl:value-of select="oxyd:fix-number(min($text//oxyd:words))"/></oxyd:minWords>
                        <oxyd:maxWords><xsl:value-of select="oxyd:fix-number(max($text//oxyd:words))"/></oxyd:maxWords>
                        <oxyd:avgWords><xsl:value-of select="oxyd:fix-number(format-number(avg($text//oxyd:words), '#'))"/></oxyd:avgWords>
                    </oxyd:words>
                    <oxyd:topMaxWords>
                        <xsl:copy-of select="reverse($topicsSortedByWords/*[last()-position() &lt;= $topX])"/>
                    </oxyd:topMaxWords>
                    <oxyd:topMinWords>
                        <xsl:copy-of select="$topicsSortedByWords/*[position() &lt;= $topX]"/>                        
                    </oxyd:topMinWords>
                    <oxyd:characters>
                        <oxyd:totalCharacters><xsl:value-of select="oxyd:fix-number(sum($text//oxyd:characters))"/></oxyd:totalCharacters>
                        <oxyd:minCharacters><xsl:value-of select="oxyd:fix-number(min($text//oxyd:characters))"/></oxyd:minCharacters>
                        <oxyd:maxCharacters><xsl:value-of select="oxyd:fix-number(max($text//oxyd:characters))"/></oxyd:maxCharacters>
                        <oxyd:avgCharacters><xsl:value-of select="oxyd:fix-number(format-number(avg($text//oxyd:characters), '#'))"/></oxyd:avgCharacters>
                    </oxyd:characters>
                </oxyd:text>
                <oxyd:processingInstructions>
                    <oxyd:piData>
                        <oxyd:totalPIs><xsl:value-of select="count($pis)"/></oxyd:totalPIs>
                        <oxyd:uniquePIs><xsl:value-of select="count(distinct-values($pis/name()))"/></oxyd:uniquePIs>
                    </oxyd:piData>
                    <oxyd:pis>
                        <xsl:for-each-group select="$pis" group-by="name()">
                            <xsl:sort select="count(current-group())" order="descending"/>
                            <oxyd:pi count="{count(current-group())}"><xsl:value-of select="current-grouping-key()"/></oxyd:pi>
                        </xsl:for-each-group>
                    </oxyd:pis>
                </oxyd:processingInstructions>
                <oxyd:externalLinks>
                    <oxyd:linksData>
                        <oxyd:totalLinks><xsl:value-of select="count($externalLinks)"/></oxyd:totalLinks>
                        <oxyd:uniqueLinks><xsl:value-of select="count(distinct-values($externalLinks/@href))"/></oxyd:uniqueLinks>
                    </oxyd:linksData>
                    <oxyd:links>
                        <xsl:for-each-group select="$externalLinks" group-by="@href" >
                            <xsl:sort select="@href" order="ascending"/>
                            <oxyd:link count="{count(current-group())}"><xsl:value-of select="current-grouping-key()"/></oxyd:link>
                        </xsl:for-each-group>
                    </oxyd:links>
                </oxyd:externalLinks>
            </oxyd:stats>
            <!--<oxyd:fullTextData>
                <xsl:copy-of select="$text"/>
            </oxyd:fullTextData>-->
            <!--<oxyd:index>
                <xsl:copy-of select="$index"/>
            </oxyd:index>-->
            <!--<oxyd:resolved map="{document-uri(/)}">
                <xsl:copy-of select="$resolved"/>
            </oxyd:resolved>-->
        </oxyd:report>
    </xsl:template>
    
    <xsl:function name="oxyd:fix-number">
        <xsl:param name="number"/>
        <xsl:value-of select="
            if (string($number)='' or string($number)='NaN') then 0 else $number"/>
    </xsl:function>
</xsl:stylesheet>
