<!-- 
  Copyright 2001-2012 Syncro Soft SRL. All rights reserved.
 -->
<xsl:stylesheet version="3.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="http://www.oxygenxml.com/xsl/functions"
    exclude-result-prefixes="f">

    <xsl:template match="node() | @*" mode="filterNodes">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="filterNodes"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- CSS properties of fonts in MSOffice -->
    <xsl:variable name="stylesPropMap" as="map(xs:string, xs:string)" 
        select="map{
        'bold' : 'font-weight',
        'italic' : 'font-style',
        'underlined' : 'text-decoration',
        'monospaced' : 'font-family'
        }"/>
    
    <!-- CSS properties values in MSOffice -->
    <xsl:variable name="stylesValMap" as="map(xs:string, xs:string)"
        select="map{
        'bold' : 'bold',
        'bold700' : '700',
        'italic' : 'italic',
        'underlined' : 'underline',
        'monospaced' : 'Courier New'
        }"/>
    
    <!-- EXM-36613 Convert word-style links to XHTML style links. -->
    <xsl:template match="text()" mode="filterNodes">
        <xsl:variable name="linkComment" select="preceding-sibling::node()[1][self::comment()][contains(., 'mso- element:field- begin') and contains(., 'REF ')]"/>
        <xsl:variable name="refTarget" select="substring-before(substring-after($linkComment, 'REF '), ' \h')"/>
        <xsl:choose>
            <xsl:when test="$linkComment and $refTarget">
                <a href="#{$refTarget}" xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:copy-of select="."/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Transform MS Word titles to XHTML titles. -->
    <xsl:template match="xhtml:div[xhtml:p[@class = 'MsoTitle']]" mode="filterNodes">
        <h1 xmlns="http://www.w3.org/1999/xhtml">
            <xsl:value-of select="xhtml:p[@class = 'MsoTitle']"/>
        </h1>
    </xsl:template>
    
    <!-- 
        Check if the font style has a property
    -->
    <xsl:function name="f:hasFontStyle" as="xs:boolean">
        <xsl:param name="styleValue"/>
        <xsl:param name="propParam"/>
        <xsl:param name="valParam"/>
            
        <xsl:variable name="toReturn" as="xs:boolean*">
            <xsl:for-each select="tokenize($styleValue,';')">
                <xsl:variable name="propAndValue" select="tokenize(., ':')"/>
                <xsl:variable name="property" select="normalize-space($propAndValue[1])"/>
                <xsl:variable name="value" select="normalize-space($propAndValue[2])"/>
                <xsl:choose>
                    <xsl:when test="$property = $stylesPropMap('monospaced')">
                        <xsl:if test="contains($value, $valParam)">
                            <xsl:value-of select="true()"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="$property = $propParam">
                            <xsl:if test="$value = $valParam">
                                <xsl:value-of select="true()"/>
                            </xsl:if>
                        </xsl:if>    
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:value-of select="$toReturn = true()"/>
    </xsl:function>
    
    <!-- 
        ===============================
        Manage  styling
        Preserve font style at paste.
        ===============================
    -->
    
    <xsl:template match="xhtml:span[
        f:hasFontStyle(@style, $stylesPropMap('bold'), $stylesValMap('bold')) or
        f:hasFontStyle(@style, $stylesPropMap('bold'), $stylesValMap('bold700')) or
        f:hasFontStyle(@style, $stylesPropMap('italic'), $stylesValMap('italic')) or
        f:hasFontStyle(@style, $stylesPropMap('underlined'), $stylesValMap('underlined'))
        ]" mode="filterNodes">
        
        <xsl:call-template name="styling">
            <!-- The three props: bold, italic and underline are passed automatically. 
                They are used to create an order when parsing the fragment styles. 
            -->
            <xsl:with-param name="toConsume" select="('bold', 'italic', 'underline')" tunnel="yes"/>
            <!-- position in the so-called array = "toConsume" ('bold', 'italic', 'underline');  -->
            <xsl:with-param name="index" select="xs:integer(1)"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- 
        Preserve font style at paste from google doc.
    -->
    <xsl:template name="styling">
        <xsl:param name="toConsume" as="xs:string*" tunnel="yes"/>
        <xsl:param name="index" as="xs:integer"/>
        
        <xsl:if test="$index &lt;= count($toConsume)">
            <xsl:choose>
                <!-- 1. check if the current prop is bold.
                    If the bold prop is not detected, increment the index and advance to next prop.
                    See the <xsl:otherwise> condition.
                -->
                <xsl:when test="$toConsume[$index]='bold' and
                    (xs:boolean(f:hasFontStyle(@style, $stylesPropMap('bold'), $stylesValMap('bold'))) or 
                     xs:boolean(f:hasFontStyle(@style, $stylesPropMap('bold'), $stylesValMap('bold700'))))">
                    <!-- 2. emit the first(bold) tag -->
                    <b xmlns="http://www.w3.org/1999/xhtml">
                        <!-- 3. now apply the styling template, with the next porp: index -->
                        <xsl:call-template name="styling">
                            <xsl:with-param name="index" select="$index + 1"/>
                        </xsl:call-template>
                        <!-- if the next prop is not found, close the current element.-->
                    </b>        
                </xsl:when>
                <!-- the bold prop was consumed; look for italic now -->
                <xsl:when test="$toConsume[$index]='italic' and 
                    xs:boolean(f:hasFontStyle(@style, $stylesPropMap('italic'), $stylesValMap('italic')))">
                    <!-- 4. emit the italic tag -->
                    <i xmlns="http://www.w3.org/1999/xhtml">
                        <xsl:call-template name="styling">
                            <!-- advance to next prop to consume-->
                            <xsl:with-param name="index" select="$index + 1"/>
                        </xsl:call-template>
                        <!-- close it -->
                    </i>        
                </xsl:when>
                <!-- underline style -->
                <xsl:when test="$toConsume[$index]='underline' and 
                    xs:boolean(f:hasFontStyle(@style, $stylesPropMap('underlined'), $stylesValMap('underlined')))">
                    <u xmlns="http://www.w3.org/1999/xhtml">
                        <xsl:call-template name="styling">
                            <xsl:with-param name="index" select="$index + 1"/>
                        </xsl:call-template>
                    </u>        
                </xsl:when>
                <xsl:otherwise>
                    <!-- 
                        1. if the bold property is not found, advance to next element
                    to consume by incrementing the index.
                    -->
                    <xsl:call-template name="styling">
                        <xsl:with-param name="index" select="$index + 1"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        
        <!-- copy the text -->
        <xsl:if test="$index > count($toConsume)">
            <xsl:copy-of select="."/>
        </xsl:if>
    </xsl:template>
    
    <!-- Unwrap xhtml:div nodes and keep only the child nodes. -->
    <xsl:template match="xhtml:div | xhtml:center | xhtml:font" mode="filterNodes">
        <xsl:apply-templates select="node()" mode="filterNodes"/>
    </xsl:template>
    
    <!-- Filter xhtml:head and empty nodes. -->
    <xsl:template match="xhtml:head" mode="filterNodes" priority="3"/>
    
    <xsl:template match="*[not(node())]
            [not(local-name() = 'img' 
               or local-name() = 'ph' 
               or local-name() = 'br' 
               or local-name() = 'col' 
               or local-name() = 'td'
               or local-name() = 'colgroup')]" 
            mode="filterNodes"
            priority="2"/>
    
    <xsl:template match="text()[string-length(normalize-space()) = 0]
                                             [empty(../preceding-sibling::*)]" 
                  mode="filterNodes"/>    
</xsl:stylesheet>
