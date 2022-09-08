<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Copyright 2001-2017 Syncro Soft SRL. All rights reserved.
    This is licensed under MPL 2.0.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:oxyd="http://www.oxygenxml.com/ns/dita"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs oxyd"
    version="2.0">
    
    <xsl:output method="xhtml"/>

    <xsl:template match="/">
        <xsl:variable name="mapMame" select="tokenize(/*/@rootMap, '/')[last()]"></xsl:variable>
        <html>
            <head>
                <title>oXygen metrics for <xsl:value-of select="$mapMame"/></title>
                <xsl:call-template name="style"/>
            </head>
            <body>
                <h1>oXygen metrics for <xsl:value-of select="$mapMame"/></h1>
                <div class="toc" id="toc">
                    <xsl:apply-templates select="*" mode="toc"/>
                </div>
                <xsl:apply-templates/>
                <p/><p/><p/><p/><p/><p/><p/>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template name="style">
        <style type="text/css">
body {
    font: 1em Arial,"Lucida Grande", "Lucida Sans Unicode", Verdana, sans-serif; 
    margin:20px;
    padding-bottom:300px;
}
h1{font-size:2em;}
h2{margin-top:30px; font-size:1.5em;}
h3{margin-top:20px;color:#333; margin-left:1em}
p{margin-left:1em}
a{text-decoration:none; color:#235EB6}

.tentry {
    display : block;
}

.htable {
    align : center;
    margin-left : 1em;
    max-width:750px;
    width : 75%;
    border:1px solid #E1E1FF;
     font-size:1em;
}
tr:nth-child(even) {
    background: #F0F0FF
}

td{padding:5px 10px 5px 10px;}
td:first-child{width:70%}
.header {
    background:#8099B3;
    color:white;
}

th{padding:4px}

.stable {
    border:1px solid #E1E1FF;
    align : center;
    margin-left : 1em;
    width : 75%;
    max-width:750px;
    font-size:1em;
}
    
    
        </style>
    </xsl:template>
    
    <xsl:template name="showInfo">
        <xsl:param name="label"/>
        <xsl:param name="number" select="."/>
        <xsl:param name="doc"/>
        <tr>
            <td title="{$doc}"><xsl:value-of select="$label"/></td>
            <td align="right"><xsl:value-of select="format-number($number, '###,###,###')"/></td>
        </tr>
    </xsl:template>
    
    <xsl:template match="text()" mode="toc"/>
    
    <xsl:template match="oxyd:stats|oxyd:report">
        <xsl:apply-templates select="*"/>
    </xsl:template>   
    
    <xsl:template match="oxyd:overview" mode="toc">
        <span class="tentry"><a href="#maininformation">Main information</a></span>
    </xsl:template>
    
    <xsl:template match="oxyd:overview">
        <h2 id="maininformation">Main information</h2>
        <table class="stable">
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    <xsl:template match="oxyd:maps">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Total maps processed</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="oxyd:uniqueMaps">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Unique maps</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="oxyd:topics">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Total topics processed</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="oxyd:uniqueTopics">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Unique topics</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <!-- INFO TYPES -->
    
    <xsl:template match="oxyd:infoTypes" mode="toc">
        <span class="tentry"><a href="#infotypes">Information types</a></span>
    </xsl:template>
    <xsl:template match="oxyd:infoTypes">
        <h2 id="infotypes">Information types</h2>
        <xsl:apply-templates/>    
    </xsl:template>
    <xsl:template match="oxyd:mapInfoTypes">
        <h3>Maps</h3>
        <table class="htable">
            <tr class="header">
                <th>Element</th>
                <th>Count</th></tr>
            <xsl:apply-templates select="*">
                <xsl:sort select="@count" data-type="number" order="descending"/>
            </xsl:apply-templates>
        </table>
    </xsl:template>
    <xsl:template match="oxyd:topicInfoTypes">
        <h3>Topics</h3>
        <table class="htable">
            <tr class="header">
                <th>Element</th>
                <th>Count</th></tr>
            <xsl:apply-templates select="*">
                <xsl:sort select="@count" data-type="number" order="descending"/>
            </xsl:apply-templates>
        </table>
    </xsl:template>
    
    
    <!-- CONREFS -->
    
    <xsl:template match="oxyd:conrefs" mode="toc">
        <span class="tentry"><a href="#contentreuse">Content reuse</a></span>
    </xsl:template>
    <xsl:template match="oxyd:conrefs">
        <h2 id="contentreuse">Content reuse</h2>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="oxyd:conrefTotalWords">
        <p>
            <xsl:choose>
                <xsl:when test=". = 0">
                    <xsl:text>No content reuse.</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Total reused words (words in conref content) </xsl:text>
                    <xsl:value-of select="format-number(., '###,###,###')"/>
                    <xsl:text>. Content reuse percentage (words) is </xsl:text>
                    <xsl:variable name="p" select="(100 * number(.)) div number(//oxyd:totalWords[1])"/>
                    <xsl:value-of select="format-number($p, '##.##')"/>
                    <xsl:text>%.</xsl:text>        
                </xsl:otherwise>
            </xsl:choose>
        </p>
    </xsl:template>
    <xsl:template match="oxyd:conrefTotalElements">
        <p>
            <xsl:if test=". != 0">
                <xsl:text>Total reused elements (elements in conref content) </xsl:text>
                <xsl:value-of select="format-number(., '###,###,###')"/>
                <xsl:text>. Elements reuse percentage is </xsl:text>
                <xsl:variable name="p" select="(100 * number(.)) div number(//oxyd:totalTopicElements[1])"/>
                <xsl:value-of select="format-number($p, '##.##')"/>
                <xsl:text>%.</xsl:text>        
            </xsl:if>
        </p>
    </xsl:template>
    <xsl:template match="oxyd:totalConrefs">
        <xsl:if test=". != 0">
            <p>
                <xsl:text>Total content reference elements </xsl:text> 
                <xsl:value-of select="format-number(., '###,###,###')"/>
                <xsl:text>.</xsl:text>
            </p>
        </xsl:if>
    </xsl:template>
    <xsl:template match="oxyd:conrefElements">
        <xsl:if test="*[1]">
            <h3>Reused elements</h3>
            <table class="htable">
                <tr class="header">
                    <th>Element</th>
                    <th>Count</th></tr>
                <xsl:apply-templates/>
            </table>
        </xsl:if>
    </xsl:template>
    <xsl:template match="oxyd:conrefElement">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label" select="."/>
            <xsl:with-param name="number" select="@count"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- ELEMENTS -->
    <xsl:template match="oxyd:elements" mode="toc">
        <span class="tentry"><a href="#elements">Elements</a></span>
    </xsl:template>
    
    <xsl:template match="oxyd:elements">
        <h2 id="elements">Elements</h2>
        <p>
            <xsl:text>Markup percentage from topic content (words + markup) in topics is </xsl:text>
            <xsl:variable name="p" select="(100 * number(oxyd:elementsData/oxyd:totalTopicElements)) div 
                (number(oxyd:elementsData/oxyd:totalTopicElements) + number(//oxyd:totalWords[1]))"/>
            <xsl:value-of select="format-number($p, '##.##')"/>
            <xsl:text>%.</xsl:text>
        </p>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="oxyd:elementsData">
        <table class="stable">
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    <xsl:template match="oxyd:totalElements">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Total elements</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="oxyd:uniqueElements">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Unique elements</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="oxyd:totalMapElements">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Total map elements</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="oxyd:uniqueMapElements">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Unique map elements</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="oxyd:totalTopicElements">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Total topic elements</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="oxyd:uniqueTopicElements">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Unique topic elements</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="oxyd:mapElements">
        <h3>Map elements</h3>
        <table class="htable">
            <tr class="header">
                <th>Element</th>
                <th>Count</th></tr>
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    <xsl:template match="oxyd:topicElements">
        <h3>Topic elements</h3>
        <table class="htable">
            <tr class="header">
                <th>Element</th>
                <th>Count</th></tr>
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    <xsl:template match="oxyd:topicEelement | oxyd:mapElement">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label" select="."/>
            <xsl:with-param name="number" select="@count"/>
        </xsl:call-template>
    </xsl:template>
    
    
    <!-- ATTRIBUTES -->
    <xsl:template match="oxyd:attributes" mode="toc">
        <span class="tentry"><a href="#attributes">Attributes</a></span>
    </xsl:template>
    <xsl:template match="oxyd:attributes">
        <h2 id="attributes">Attributes</h2>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="oxyd:attributesData">
        <table class="stable">
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    <xsl:template match="oxyd:totalAttributes">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Total attributes</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="oxyd:uniqueAttributes">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Unique attributes</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="oxyd:totalMapAttributes">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Total map attributes</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="oxyd:uniqueMapAttributes">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Unique map attributes</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="oxyd:totalTopicAttributes">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Topic attributes</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="oxyd:uniqueTopicAttributes">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Unique topic attributes</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="oxyd:mapAttributes">
        <h3>Map attributes</h3>
        <table class="htable">
            <tr class="header">
                <th>Attribute</th>
                <th>Count</th>
            </tr>
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    
    <xsl:template match="oxyd:topicAttributes">
        <h3>Topic attributes</h3>
        <table class="htable">
            <tr class="header">
                <th>Element</th>
                <th>Count</th>
            </tr>
            <xsl:apply-templates/>
        </table>
    </xsl:template>

    <xsl:template match="oxyd:topicAttribute| oxyd:mapAttribute">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label" select="."/>
            <xsl:with-param name="number" select="@count"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- CONDITIONAL ATTRIBUTES -->
    <xsl:template match="oxyd:conditionalAttributes" mode="toc">
        <span class="tentry"><a href="#conditionalAttributes">Conditional Attributes</a></span>
    </xsl:template>
    <xsl:template match="oxyd:conditionalAttributes">
        <h2 id="conditionalAttributes">Conditional Attributes</h2>
        <xsl:if test="not(*/*)">
            <p>Conditional attributes are not used.</p>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="oxyd:audience[*]">
        <h3>audience</h3>
        <xsl:call-template name="showValues"/>
    </xsl:template>
    <xsl:template match="oxyd:platform[*]">
        <h3>platform</h3>
        <xsl:call-template name="showValues"/>
    </xsl:template>
    <xsl:template match="oxyd:product[*]">
        <h3>product</h3>
        <xsl:call-template name="showValues"/>
    </xsl:template>
    <xsl:template match="oxyd:otherprops[*]">
        <h3>otherprops</h3>
        <xsl:call-template name="showValues"/>
    </xsl:template>
    <xsl:template match="oxyd:rev[*]">
        <h3>rev</h3>
        <xsl:call-template name="showValues"/>
    </xsl:template>

    <xsl:template match="oxyd:attValue">
        <li><xsl:value-of select="."/></li>
    </xsl:template>
    
    <xsl:template name="showValues">
        <p>Values:</p>
        <ul>
            <xsl:apply-templates/>
        </ul>        
    </xsl:template>
    
    <!-- TEXT -->
    <xsl:template match="oxyd:text" mode="toc">
        <span class="tentry"><a href="#textinformation">Text information</a></span>
    </xsl:template>
    <xsl:template match="oxyd:text">
        <h2 id="textinformation">Text information</h2>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="oxyd:words">
        <h3>Words</h3>
        <table class="stable">
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    
    <xsl:template match="oxyd:uniqueWords">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Unique words</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="oxyd:totalWords">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Total words</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="oxyd:minWords">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Minimum words per topic</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="oxyd:maxWords">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Maximum words per topic</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="oxyd:avgWords">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Average words per topic</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="oxyd:topMaxWords">
        <h3>Top max words topics</h3>
        <table class="htable">
            <tr class="header">
                <th>Topic</th>
                <th>Words</th>
            </tr>
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    <xsl:template match="oxyd:topMinWords">
        <h3>Top min words topics</h3>
        <table class="htable">
            <tr class="header">
                <th>Topic</th>
                <th>Words</th>
            </tr>
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    <xsl:template match="oxyd:topicText">
        <tr>
            <td>
                <a href="{@topic}" title="Open the {@topic} topic">
                    <xsl:value-of select="tokenize(@topic, '/')[last()]"/>
                </a>
            </td> 
            <td align="right">
                <xsl:value-of select="format-number(oxyd:words, '###,###,###')"/>      
            </td>
        </tr>
    </xsl:template>
    
    <xsl:template match="oxyd:characters">
        <h3>Characters</h3>
        <table class="stable">
            <xsl:apply-templates/>
        </table>        
    </xsl:template>
    
    <xsl:template match="oxyd:totalCharacters">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Total characters</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="oxyd:minCharacters">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Minimum content characters per topic</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="oxyd:maxCharacters">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Maximum content characters per topic</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="oxyd:avgCharacters">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Average content characters per topic</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <!-- PIs -->
    <xsl:template match="oxyd:processingInstructions" mode="toc">
        <span class="tentry"><a href="#processinginstructions">Processing Instructions</a></span>
    </xsl:template>
    <xsl:template match="oxyd:processingInstructions">
        <h2 id="processinginstructions">Processing instructions</h2>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="oxyd:piData">
        <table class="stable">
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    <xsl:template match="oxyd:totalPIs">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Total processing instructions</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="oxyd:uniquePIs">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Unique processing instructions</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="oxyd:pis">
        <xsl:if test="*[1]">
            <h3>PIs distribution</h3>
            <table class="htable">
                <tr class="header">
                    <th>PI</th>
                    <th>Count</th></tr>
                <xsl:apply-templates/>
            </table>
        </xsl:if>
    </xsl:template>
    <xsl:template match="oxyd:pi">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label" select="."/>
            <xsl:with-param name="number" select="@count"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- External links -->
    <xsl:template match="oxyd:externalLinks" mode="toc">
        <span class="tentry"><a href="#externallinks">External links</a></span>
    </xsl:template>
    <xsl:template match="oxyd:externalLinks">
        <h2 id="externallinks">External links</h2>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="oxyd:linkData">
        <table class="stable">
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    <xsl:template match="oxyd:totalLinks">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Total links</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="oxyd:uniqueLinks">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label">Unique links</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="oxyd:links">
        <xsl:if test="*[1]">
            <h3>Links distribution</h3>
            <table class="htable">
                <tr class="header">
                    <th>Link</th>
                    <th>Count</th></tr>
                <xsl:apply-templates/>
            </table>
        </xsl:if>
    </xsl:template>
    <xsl:template match="oxyd:link">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label" select="."/>
            <xsl:with-param name="number" select="@count"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- Domains analysis -->
    
    <xsl:template match="oxyd:domainAnalysis" mode="toc">
        <span class="tentry"><a href="#domainanalysis">Domain analysis</a></span>
    </xsl:template>
    <xsl:template match="oxyd:domainAnalysis">
        <h2 id="domainanalysis">Domain analysis</h2>
        <p>
            <xsl:text>The following domains are actually used: </xsl:text>
            <xsl:value-of select="oxyd:domain/@name" separator=", "/>
            <xsl:text>.</xsl:text>
        </p>
        
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="oxyd:domain">
        <h3><xsl:value-of select="@name"/></h3>
        <p>
            <xsl:text>This domain defines </xsl:text>
            <xsl:value-of select="@elements"/>
            <xsl:text> elements, this document used </xsl:text>
            <xsl:value-of select="@hits"/>
            <xsl:text> of them. (</xsl:text>
            <xsl:value-of select="format-number(@hits * 100 div @elements, '##.##')"/>
            <xsl:text>%)</xsl:text>

        </p>
        <table class="htable">
            <tr class="header">
                <th>Element</th>
                <th>Count</th></tr>
            <xsl:apply-templates select="*">
                <xsl:sort select="@count" data-type="number" order="descending"/>
            </xsl:apply-templates>
        </table>
    </xsl:template>
    <xsl:template match="oxyd:element">
        <xsl:call-template name="showInfo">
            <xsl:with-param name="label" select="@name"/>
            <xsl:with-param name="number" select="@count"/>
            <xsl:with-param name="doc" select="."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="*"/>
</xsl:stylesheet>
