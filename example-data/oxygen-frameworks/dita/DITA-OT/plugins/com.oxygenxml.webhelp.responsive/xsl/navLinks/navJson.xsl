<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0"
    xmlns:t="http://www.oxygenxml.com/ns/webhelp/toc">
    
    <xsl:variable name="EXT" select="'js'" as="xs:string"/>

    <xsl:character-map name="json">
        <xsl:output-character character="&quot;" string="\&quot;"/>   
        <xsl:output-character character="\" string="\\"/>
        <xsl:output-character character="/" string='\/'/>
        <xsl:output-character character="&#9;" string='\t'/>
        <xsl:output-character character="&#10;" string='\n'/>
        <xsl:output-character character="&#13;" string='\r'/>
        <!-- WH-1580: Escape XML special chars -->
        <xsl:output-character character="&amp;" string='&amp;amp;'/>
        <xsl:output-character character="&lt;" string='&amp;lt;'/>
        <xsl:output-character character="&gt;" string='&amp;gt;'/>
        <xsl:output-character character="&apos;" string='&amp;apos;'/>
    </xsl:character-map>
    
    <xsl:output name="json" method="text" use-character-maps="json" omit-xml-declaration="yes" />
    
    <xsl:template match="t:toc">
        <xsl:apply-templates mode="nav-json" select="."/>
    </xsl:template>
    
    <xsl:template match="t:toc" mode="nav-json">
        <xsl:result-document href="{$JSON_OUTPUT_DIR_URI}/nav-links.{$EXT}" format="json">
            <xsl:text disable-output-escaping="yes">define({</xsl:text>
            <xsl:apply-templates select="t:title" mode="nav-json"/>
            <xsl:text disable-output-escaping="yes">"topics" : [</xsl:text>
            <xsl:apply-templates select="t:topic" mode="nav-json"/>
            <xsl:text disable-output-escaping="yes">]});</xsl:text>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="t:title" mode="nav-json">
        <xsl:call-template name="string-property">
            <xsl:with-param name="name">title</xsl:with-param>
            <xsl:with-param name="value" select="node()"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="t:shortdesc" mode="nav-json">
        <xsl:call-template name="string-property">
            <xsl:with-param name="name">shortdesc</xsl:with-param>
            <xsl:with-param name="value" select="node()"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="t:topic" mode="nav-json">
        <xsl:text disable-output-escaping="yes">{</xsl:text>
        
        <xsl:apply-templates select="t:title" mode="nav-json"/>
        <xsl:apply-templates select="t:shortdesc" mode="nav-json"/>
        
        <xsl:call-template name="string-property">
            <xsl:with-param name="name">id</xsl:with-param>
            <xsl:with-param name="value" select="@data-id"/>
        </xsl:call-template>
        
        <xsl:call-template name="string-property">
            <xsl:with-param name="name">href</xsl:with-param>
            <xsl:with-param name="value" select="@href"/>
        </xsl:call-template>
        
        <xsl:if test="@outputclass">
            <xsl:call-template name="string-property">
                <xsl:with-param name="name">outputclass</xsl:with-param>
                <xsl:with-param name="value" select="@outputclass"/>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="@scope">
            <xsl:call-template name="string-property">
                <xsl:with-param name="name">scope</xsl:with-param>
                <xsl:with-param name="value" select="@scope"/>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:call-template name="object-property">
            <xsl:with-param name="name">menu</xsl:with-param>
            <xsl:with-param name="value">
                <xsl:variable name="menuChildCount" 
                    select="count(t:topic[not(t:topicmeta/t:data[@name='wh-menu']/t:data[@name='hide'][@value='yes'])])"/>
                                    
                <xsl:variable name="currentDepth" select="count(ancestor-or-self::t:topic)"/>
                <xsl:variable name="maxDepth" select="number($WEBHELP_TOP_MENU_DEPTH)"/>
                
                <!-- Decide if this topic has children for the menu component. -->
                <xsl:variable name="hasChildren" select="$menuChildCount > 0 and ($maxDepth le 0 or $maxDepth > $currentDepth)"/>
                
                <xsl:call-template name="boolean-property">
                    <xsl:with-param name="name">hasChildren</xsl:with-param>
                    <xsl:with-param name="value" select="$hasChildren"/>
                </xsl:call-template>
                <xsl:apply-templates select="t:topicmeta/t:data[@name='wh-menu']" mode="nav-json"/>
            </xsl:with-param>
        </xsl:call-template>
        
        <xsl:variable name="tocID" select="@wh-toc-id"/>
        
        <xsl:call-template name="string-property">
            <xsl:with-param name="name">tocID</xsl:with-param>
            <xsl:with-param name="value" select="$tocID"/>
        </xsl:call-template>
        
        <xsl:choose>
            <xsl:when test="count(t:topic) = 0">
                <xsl:text disable-output-escaping="yes">"topics":[]</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="string-property">
                    <xsl:with-param name="name">next</xsl:with-param>
                    <xsl:with-param name="value" select="$tocID"/>
                </xsl:call-template>
                
                <xsl:result-document href="{$JSON_OUTPUT_DIR_URI}/{$tocID}.{$EXT}" format="json">
                    <xsl:text disable-output-escaping="yes">define({"topics" : [</xsl:text>
                    <xsl:apply-templates select="t:topic" mode="nav-json"/>
                    <xsl:text disable-output-escaping="yes">]});</xsl:text>
                </xsl:result-document>
            </xsl:otherwise>
        </xsl:choose>
        
        <xsl:text disable-output-escaping="yes">}</xsl:text>
        <xsl:if test="position() != last()">
            <xsl:text disable-output-escaping="yes">,</xsl:text>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="t:topicmeta/t:data[@name='wh-menu']" mode="nav-json">
        <xsl:if test="t:data[@name='image'][@href]">
            <xsl:call-template name="object-property">
                <xsl:with-param name="name">image</xsl:with-param>
                <xsl:with-param name="value">
                    <xsl:apply-templates select="t:data[@name='image'][@href]" mode="nav-json"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="t:data[@name='hide'][@value='yes']">
            <xsl:call-template name="boolean-property">
                <xsl:with-param name="name">isHidden</xsl:with-param>
                <xsl:with-param name="value" select="true()"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="t:data[@name='image'][@href]" mode="nav-json">
        <xsl:call-template name="string-property">
            <xsl:with-param name="name">href</xsl:with-param>
            <xsl:with-param name="value" select="@href"/>
        </xsl:call-template> 
        
        <xsl:if test="@scope">
            <xsl:call-template name="string-property">
                <xsl:with-param name="name">scope</xsl:with-param>
                <xsl:with-param name="value" select="@scope"/>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:variable name="attrWidth" select="t:data[@name = 'attr-width'][@value]"/>
        <xsl:if test="$attrWidth">
            <xsl:call-template name="string-property">
                <xsl:with-param name="name">width</xsl:with-param>
                <xsl:with-param name="value" select="$attrWidth/@value"/>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:variable name="attrHeight" select="t:data[@name = 'attr-height'][@value]"/>
        <xsl:if test="$attrHeight">
            <xsl:call-template name="string-property">
                <xsl:with-param name="name">height</xsl:with-param>
                <xsl:with-param name="value" select="$attrHeight/@value"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="string-property">
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        
        <xsl:text disable-output-escaping="yes">"</xsl:text>
        <xsl:value-of select="$name"/>
        <xsl:text disable-output-escaping="yes">":"</xsl:text>
        
        <xsl:call-template name="value">
            <xsl:with-param name="value" select="$value"/>
        </xsl:call-template>
        
        <xsl:text disable-output-escaping="yes">",</xsl:text>
    </xsl:template>
    
    <xsl:template name="boolean-property">
        <xsl:param name="name"/>
        <xsl:param name="value" as="xs:boolean"/>
        
        <xsl:text disable-output-escaping="yes">"</xsl:text>
        <xsl:value-of select="$name"/>
        <xsl:text disable-output-escaping="yes">":</xsl:text>
        <xsl:value-of select="$value"/>
        <xsl:text disable-output-escaping="yes">,</xsl:text>
    </xsl:template>
    
    <xsl:template name="object-property">
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        
        <xsl:text disable-output-escaping="yes">"</xsl:text>
        <xsl:value-of select="$name"/>
        <xsl:text disable-output-escaping="yes">": {</xsl:text>
        <!-- Already escaped -->
        <xsl:value-of select="$value" disable-output-escaping="yes"/>
        <xsl:text disable-output-escaping="yes">},</xsl:text>
    </xsl:template>
    
    <xsl:template name="value">
        <xsl:param name="value"/>
        <xsl:choose>
            <xsl:when test="$value instance of attribute() or $value instance of xs:string">
                <xsl:value-of select="$value"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$value" mode="copy-value"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*" mode="copy-value">
        <xsl:text disable-output-escaping="yes">&lt;</xsl:text>
        <xsl:value-of select="local-name()"/>
        <xsl:apply-templates select="@*" mode="copy-value"/>
        <xsl:text disable-output-escaping="yes">&gt;</xsl:text>
        <xsl:apply-templates select="node()" mode="copy-value"/>
        <xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="local-name()"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
    </xsl:template>
    
    <xsl:template match="@*" priority="10" mode="copy-value">
        <xsl:text> </xsl:text>
        <xsl:value-of select="local-name(.)"/>
        <xsl:text>="</xsl:text>
        <!-- WH-1580: Quotes from attribute values should be XML-escaped. -->
        <xsl:value-of select="replace(., '&quot;', '&amp;quot;')"/>
        <xsl:text>"</xsl:text>
    </xsl:template>
    
    <xsl:template match="processing-instruction()" mode="copy-value">
        <xsl:text disable-output-escaping="yes">&lt;?</xsl:text><xsl:value-of select="node-name(.)"/><xsl:text> </xsl:text><xsl:value-of select="."/><xsl:text disable-output-escaping="yes">?&gt;</xsl:text>
    </xsl:template>
    
    <xsl:template match="comment()" mode="copy-value">
        <xsl:text disable-output-escaping="yes">&lt;!--</xsl:text><xsl:value-of select="."/><xsl:text disable-output-escaping="yes">--&gt;</xsl:text>
    </xsl:template>
    
    <xsl:template match="text()" mode="copy-value">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <xsl:template match="text()"  mode="nav-json"/>
</xsl:stylesheet>