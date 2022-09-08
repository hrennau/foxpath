<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" 
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:d="http://docbook.org/ns/docbook">
    <!-- EXM-22572 Must be the profiling Docbook stylesheet. -->
    <xsl:import href="../xsl/fo/profile-docbook.xsl"/>

    <xsl:param name="body.font.master">8</xsl:param>
    <xsl:param name="body.start.indent">0.1in</xsl:param>
    <xsl:param name="draft.mode">no</xsl:param>
    <xsl:param name="fop.extensions">0</xsl:param>
    <xsl:param name="fop1.extensions">1</xsl:param>
    <xsl:param name="paper.type">A4</xsl:param>
    <xsl:param name="toc.section.depth">3</xsl:param>
    <!-- The oXygen family product used to generate the documentation.
         Possible values:Editor (default value), Developer
    -->
    <xsl:param name="distribution">Editor</xsl:param>
    <!-- Larger page than the default.-->
    <xsl:param name="page.margin.outer">
        <xsl:choose>
            <xsl:when test="$double.sided != 0">0.5in</xsl:when>
            <xsl:otherwise>0.75in</xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <xsl:param name="page.margin.inner">
        <xsl:choose>
            <xsl:when test="$double.sided != 0">1in</xsl:when>
            <xsl:otherwise>0.75in</xsl:otherwise>
        </xsl:choose>
    </xsl:param>


    <xsl:attribute-set name="monospace.verbatim.properties"
        use-attribute-sets="verbatim.properties monospace.properties">
        <!-- Tyhe annotation and source section should wrap. -->
        <xsl:attribute name="text-align">start</xsl:attribute>
        <xsl:attribute name="wrap-option">wrap</xsl:attribute>
        <!-- Use a smaller font, since the monospaced fonts looks bigger -->
        <xsl:attribute name="font-size"><xsl:value-of select="$body.font.master - 1"/>pt</xsl:attribute>        
    </xsl:attribute-set>
            
    <!-- Smaller titles than default. -->
    <xsl:template match="d:title" mode="article.titlepage.recto.auto.mode">
        <fo:block 
            xmlns:fo="http://www.w3.org/1999/XSL/Format" 
            xsl:use-attribute-sets="article.titlepage.recto.style" 
            keep-with-next.within-column="always" 
            font-weight="bold">
            
            <xsl:attribute name="font-size">
                <xsl:value-of select="$body.font.master * 2.8"/>
                <xsl:text>pt</xsl:text>
            </xsl:attribute>                         
            <xsl:call-template name="component.title">
                <xsl:with-param name="node" select="ancestor-or-self::d:article[1]"/>
            </xsl:call-template>
        </fo:block>
    </xsl:template>
        
    <xsl:attribute-set name="section.title.level1.properties">
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 1.6"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>  
    </xsl:attribute-set> 
    
    <xsl:attribute-set name="section.title.level2.properties">
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 1.5"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>  
    </xsl:attribute-set> 
    
    <xsl:attribute-set name="section.title.level3.properties">
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 1.3"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>  
    </xsl:attribute-set> 
    
    <!-- XML syntax highlight -->
    <xsl:template match="d:tag[@class]">        
        <xsl:variable name="color">
            <xsl:choose>
                <xsl:when test="@class = 'element'">#000096</xsl:when>
                <xsl:when test="@class = 'attribute'">#F5844C</xsl:when>
                <xsl:when test="@class = 'attvalue'">#993300</xsl:when>
                <xsl:when test="@class = 'comment'">#006400</xsl:when>
                <xsl:when test="@class = 'xmlpi'">#8B26C9</xsl:when>
                <xsl:when test="@class = 'genentity'">#969600</xsl:when>  
                <xsl:otherwise>#000000</xsl:otherwise>
            </xsl:choose>                    
        </xsl:variable>
        <fo:inline color="{$color}">
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- The header content -->
    <xsl:param name="header.column.widths">1.2 1 1.2</xsl:param>
    <xsl:template name="header.content">
        <xsl:param name="pageclass" select="''"/>
        <xsl:param name="sequence" select="''"/>
        <xsl:param name="position" select="''"/>
        <xsl:param name="gentext-key" select="''"/>
        
        <!--
            <fo:block>
            <xsl:value-of select="$pageclass"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="$sequence"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="$position"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="$gentext-key"/>
            </fo:block>-->        
        
        <fo:block>
            
            <!-- sequence can be odd, even, first, blank -->
            <!-- position can be left, center, right -->
            <xsl:choose>
                <xsl:when test="$sequence = 'blank'">
                    <!-- nothing -->
                </xsl:when>
                                
                <xsl:when test="($sequence='odd' or $sequence='even') and $position='center'">
                    <xsl:choose>
                        <!-- Not on the title page put the file name. -->
                        <xsl:when test="$pageclass != 'titlepage'">
                            <xsl:choose>
                                <xsl:when test="ancestor::d:book and ($double.sided != 0)">
                                    <fo:retrieve-marker retrieve-class-name="section.head.marker"
                                        retrieve-position="first-including-carryover"
                                        retrieve-boundary="page-sequence"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="." mode="titleabbrev.markup"/>
                                </xsl:otherwise>
                            </xsl:choose>                            
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>

                <xsl:when test="$sequence='first' and $position='left'">
                    <fo:inline font-style="italic">Generated with <fo:basic-link
                        external-destination="url(http://www.oxygenxml.com/)">
                        <fo:inline xmlns:xlink="http://www.w3.org/1999/xlink" color="#000066">oXygen XML
                            <xsl:value-of select="$distribution"/></fo:inline>
                        </fo:basic-link>
                    </fo:inline>                    
                </xsl:when>

                <xsl:when test="$sequence='first' and $position='right'">
                    <fo:inline font-style="italic" overflow="visible">Take care of the environment, print only 
                        if necessary!</fo:inline>                    
                </xsl:when>
                                
            </xsl:choose>
        </fo:block>
        
    </xsl:template>
    <xsl:attribute-set name="header.content.properties">
        <xsl:attribute name="font-size">
            <xsl:value-of select="$body.font.master * 0.9"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>              
    </xsl:attribute-set>
    
    <xsl:template name="log.message">
        <xsl:param name="level"/>
        <xsl:param name="source"/>
        <xsl:param name="context-desc"/>
        <xsl:param name="context-desc-field-length">12</xsl:param>
        <xsl:param name="context-desc-padded">
            <xsl:if test="not($context-desc = '')">
                <xsl:call-template name="pad-string">
                    <xsl:with-param name="leftRight">right</xsl:with-param>
                    <xsl:with-param name="padVar"
                        select="substring($context-desc, 1, $context-desc-field-length)"/>
                    <xsl:with-param name="length" select="$context-desc-field-length"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:param>
        <xsl:param name="message"/>
        <xsl:param name="message-field-length" select="45"/>
        <xsl:param name="message-padded">
            <xsl:variable name="spaces-for-blank-level">
                <!-- * if the level field is blank, we'll need to pad out -->
                <!-- * the message field with spaces to compensate -->
                <xsl:choose>
                    <xsl:when test="$level = ''">
                        <xsl:value-of select="4 + 2"/>
                        <!-- * 4 = hard-coded length of comment text ("Note" or "Warn") -->
                        <!-- * + 2 = length of colon-plus-space separator ": " -->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="0"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="spaces-for-blank-context-desc">
                <!-- * if the context-description field is blank, we'll need -->
                <!-- * to pad out the message field with spaces to compensate -->
                <xsl:choose>
                    <xsl:when test="$context-desc = ''">
                        <xsl:value-of select="$context-desc-field-length + 2"/>
                        <!-- * + 2 = length of colon-plus-space separator ": " -->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="0"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="extra-spaces"
                select="$spaces-for-blank-level + $spaces-for-blank-context-desc"/>
            <xsl:call-template name="pad-string">
                <xsl:with-param name="leftRight">right</xsl:with-param>
                <xsl:with-param name="padVar"
                    select="substring($message, 1, ($message-field-length + $extra-spaces))"/>
                <xsl:with-param name="length"
                    select="$message-field-length + $extra-spaces"/>
            </xsl:call-template>
        </xsl:param>
        <!-- * emit the actual log message -->
        
        <xsl:if test="not($level='Note' or $level='Warn')">
            <xsl:message>
                <xsl:if test="not($level = '')">
                    <xsl:value-of select="$level"/>
                    <xsl:text>: </xsl:text>
                </xsl:if>
                <xsl:if test="not($context-desc = '')">
                    <xsl:value-of select="$context-desc-padded"/>
                    <xsl:text>: </xsl:text>
                </xsl:if>
                <xsl:value-of select="$message-padded"/>
                <xsl:text>  </xsl:text>
                <xsl:value-of select="$source"/>
            </xsl:message>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="root.messages"/>    
</xsl:stylesheet>
