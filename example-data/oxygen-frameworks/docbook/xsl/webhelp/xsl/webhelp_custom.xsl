<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    The customizations addedin Oxygen for the DocBook Webhelp transformation. 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:d="http://docbook.org/ns/docbook"
    xmlns:exsl="http://exslt.org/common"
    xmlns:saxon="http://icl.com/saxon"
    xmlns:ng="http://docbook.org/docbook-ng" 
    xmlns:db="http://docbook.org/ns/docbook"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xsl d exsl saxon ng db"
    version="1.0">

    <!-- The stylesheet from Docbook XSL. -->
    <xsl:import href="webhelp.xsl"/>
    
    <xsl:template name="webhelptoc">
        <xsl:param name="currentid"/>
        <xsl:choose>
            <xsl:when test="$rootid != ''">
                <xsl:variable name="title">
                    <xsl:if test="$webhelp.autolabel=1">
                        <xsl:variable name="label.markup">
                            <xsl:apply-templates select="key('id',$rootid)" mode="label.markup"/>
                        </xsl:variable>
                        <xsl:if test="normalize-space($label.markup)">
                            <xsl:value-of select="concat($label.markup,$autotoc.label.separator)"/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:apply-templates select="key('id',$rootid)" mode="title.markup"/>
                </xsl:variable>
                <xsl:variable name="href">
                    <xsl:choose>
                        <xsl:when test="$manifest.in.base.dir != 0">
                            <xsl:call-template name="href.target">
                                <xsl:with-param name="object" select="key('id',$rootid)"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="href.target.with.base.dir">
                                <xsl:with-param name="object" select="key('id',$rootid)"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:variable name="title">
                    <xsl:if test="$webhelp.autolabel=1">
                        <xsl:variable name="label.markup">
                            <xsl:apply-templates select="/*" mode="label.markup"/>
                        </xsl:variable>
                        <xsl:if test="normalize-space($label.markup)">
                            <xsl:value-of select="concat($label.markup,$autotoc.label.separator)"/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:apply-templates select="/*" mode="title.markup"/>
                </xsl:variable>
                <xsl:variable name="href">
                    <xsl:choose>
                        <xsl:when test="$manifest.in.base.dir != 0">
                            <xsl:call-template name="href.target">
                                <xsl:with-param name="object" select="/"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="href.target.with.base.dir">
                                <xsl:with-param name="object" select="/"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <div>
                    <div id="leftnavigation" style="padding-top:3px; background-color:white;">
                        <div id="tabs">
                            <ul>
                                <li>
                                    <a href="#treeDiv">
                                        <em>
                                            <xsl:call-template name="gentext">
                                                <xsl:with-param name="key" select="'TableofContents'"/>
                                            </xsl:call-template>
                                        </em>
                                    </a>
                                </li>
                                <xsl:if test="$webhelp.include.search.tab != 'false'">
                                    <li>
                                        <a href="#searchDiv">
                                            <em>
                                                <xsl:call-template name="gentext">
                                                    <xsl:with-param name="key" select="'Search'"/>
                                                </xsl:call-template>
                                            </em>
                                        </a>
                                    </li>
                                </xsl:if>
                            </ul>
                            <div id="treeDiv">
                                <img src="../common/images/loading.gif" alt="loading table of contents..."
                                    id="tocLoading" style="display:block;"/>
                                <div id="ulTreeDiv" style="display:none">
                                    <ul id="tree" class="filetree">
                                        <!-- OXYGEN PATCH START -->
                                        <xsl:variable name="tocList">
                                            <xsl:apply-templates select="/*/*" mode="webhelptoc">
                                                <xsl:with-param name="currentid" select="$currentid"/>
                                            </xsl:apply-templates>
                                        </xsl:variable>
                                        
                                        <xsl:variable name="tocTitle">
                                            <xsl:apply-templates select="/" mode="object.title.markup"/>
                                        </xsl:variable>
                                        <xsl:call-template name="write.chunk">
                                            <xsl:with-param name="filename" select="concat($webhelp.base.dir, '/toc.xml')"/>
                                            <xsl:with-param name="content">
                                                <toc title="{$tocTitle}" xmlns="http://www.oxygenxml.com/ns/webhelp/toc" 
                                                    xsl:exclude-result-prefixes="xhtml">
                                                    <xsl:apply-templates select="saxon:node-set($tocList)/*" mode="toc-webhelp"/>
                                                </toc>
                                            </xsl:with-param>
                                            <xsl:with-param name="quiet" select="$chunk.quietly"/>
                                        </xsl:call-template>
                                        <xsl:copy-of select="$tocList"/>
                                        <!-- OXYGEN PATCH END -->
                                    </ul>
                                </div>
                            </div>
                            <xsl:if test="$webhelp.include.search.tab != 'false'">
                                <div id="searchDiv">
                                    <div id="search">
                                        <form onsubmit="Verifie(ditaSearch_Form);return false"
                                            name="ditaSearch_Form"
                                            class="searchForm">
                                            <fieldset class="searchFieldSet">
                                                <legend>
                                                    <xsl:call-template name="gentext">
                                                        <xsl:with-param name="key" select="'Search'"/>
                                                    </xsl:call-template>
                                                </legend>
                                                <center>
                                                    <input id="textToSearch" name="textToSearch" type="text"
                                                        class="searchText"/>
                                                    <xsl:text disable-output-escaping="yes"> <![CDATA[&nbsp;]]> </xsl:text>
                                                    <input onclick="Verifie(ditaSearch_Form)" type="button"
                                                        class="searchButton"
                                                        value="Go" id="doSearch"/>
                                                </center>
                                            </fieldset>
                                        </form>
                                    </div>
                                    <div id="searchResults">
                                        <center> </center>
                                    </div>
                                </div>
                            </xsl:if>
                            
                        </div>
                    </div>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    

    <xsl:template match="li" mode="toc-webhelp">
        <topic title="{normalize-space(span/a)}" href="{span/a/@href}"
            xmlns="http://www.oxygenxml.com/ns/webhelp/toc"
            xsl:exclude-result-prefixes="xhtml">
            <xsl:apply-templates select="ul" mode="toc-webhelp"/>
        </topic>
    </xsl:template>
    
    <xsl:template match="d:indexterm">
        <oxygen:indexterm xmlns:oxygen="http://www.oxygenxml.com/ns/webhelp/index">
            <xsl:if test="d:primary">
                <xsl:attribute name="primary"><xsl:value-of select="d:primary"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="d:secondary">
                <xsl:attribute name="secondary"><xsl:value-of select="d:secondary"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="d:tertiary">
                <xsl:attribute name="tertiary"><xsl:value-of select="d:tertiary"/></xsl:attribute>
            </xsl:if>
        </oxygen:indexterm>
    </xsl:template>
    
    
</xsl:stylesheet>