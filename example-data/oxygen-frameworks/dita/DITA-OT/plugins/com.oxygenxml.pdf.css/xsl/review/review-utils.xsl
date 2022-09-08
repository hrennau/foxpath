<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs saxon oxy"
    version="2.0"
    xmlns:oxy="http://www.oxygenxml.com/extensions/author"
    xmlns:saxon="http://saxon.sf.net/"
    extension-element-prefixes="saxon">
    
    <xsl:variable name="pi-stack" saxon:assignable="yes" />
    
    <!-- 
        This variable holds the mapping between the text nodes ids 
        and their highlight state and covering review processing 
        instruction. 
    -->
    <xsl:variable name="review-coverage">

		<xsl:if test="$show.changes.and.comments = 'yes'">
		    
		    <!-- 
		      Create a border for the highlights, make sure the unclosed highlights are:
		      1. reported to the user
		      2. do not bleed outside their topic, in case of DITA.
		    -->

		    <xsl:variable name="ranges" select="if (/*[contains(@class, ' map/map ')]) then //*[contains(@class, ' topic/topic ')] else /*"/>
                
		    <xsl:for-each select="$ranges">		        
    		    <xsl:variable name="range" select="."/>

		        <saxon:assign name="pi-stack" select="()"/>		      
		        <xsl:variable name="generated">
		          <xsl:for-each select="
		            $range//processing-instruction('oxy_insert_start')| 
		            $range//processing-instruction('oxy_insert_end')|
		            $range//text()">
		            <xsl:call-template name="generate-review-text-coverage-ids"/>
		          </xsl:for-each>		          
		        </xsl:variable>
		        <xsl:if test="$generated">
			        <xsl:choose>
			          <xsl:when test="$pi-stack[1]">
			            <xsl:call-template name="report-review-text-coverage-bleeding">
			              <xsl:with-param name="range" select="$range"/>
			            </xsl:call-template>
			          </xsl:when>
			          <xsl:otherwise>
			            <inserted>
			                <xsl:copy-of select="$generated"/>
			            </inserted>
			          </xsl:otherwise>
			        </xsl:choose>
				</xsl:if>
				
				
		        <saxon:assign name="pi-stack" select="()"/>
		        <xsl:variable name="generated">
    		        <xsl:for-each select="
    		            $range//processing-instruction('oxy_comment_start')| 
    		            $range//processing-instruction('oxy_comment_end')|
    		            $range//text()">
    		        	<xsl:call-template name="generate-review-text-coverage-ids"/>		            
    		        </xsl:for-each>
		      </xsl:variable>
		      <xsl:if test="$generated">
			      <xsl:choose>
			        <xsl:when test="$pi-stack[1]">
			          <xsl:call-template name="report-review-text-coverage-bleeding">
			            <xsl:with-param name="range" select="$range"/>
			          </xsl:call-template>
			        </xsl:when>
			        <xsl:otherwise>
			          <commented>
			            <xsl:copy-of select="$generated"/>
			          </commented>
			        </xsl:otherwise>
			      </xsl:choose>
			  </xsl:if>
			  
		      <saxon:assign name="pi-stack" select="()"/>
		      <xsl:variable name="generated">
    		        <xsl:for-each select="
    		            $range//processing-instruction('oxy_custom_start')[contains(., 'type=&quot;oxy_content_highlight&quot;')]|
    		            $range//processing-instruction('oxy_custom_end')|
    		            $range//text()">
    		        	<xsl:call-template name="generate-review-text-coverage-ids"/>
    		        </xsl:for-each>	    
		      </xsl:variable>
		      <xsl:if test="$generated">
			      <xsl:choose>
			        <xsl:when test="$pi-stack[1]">
			          <xsl:call-template name="report-review-text-coverage-bleeding">
			            <xsl:with-param name="range" select="$range"/>
			          </xsl:call-template>
			        </xsl:when>
			        <xsl:otherwise>
			          <highlighted>
			            <xsl:copy-of select="$generated"/>
			          </highlighted>
			        </xsl:otherwise>
			      </xsl:choose>
		      </xsl:if>

		    </xsl:for-each>
		  </xsl:if>
    </xsl:variable>

    <xsl:template name="report-review-text-coverage-bleeding">
        <xsl:param name="range" as="node()"/>
        <xsl:variable name="title-path">
          <xsl:for-each select="$pi-stack[1]/ancestor::*[title]/title">
            <xsl:value-of select="."/>
            <xsl:if test="position() != last()">
              <xsl:text> / </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:message terminate="no">[OXYRV01W][WARNING] Cannot process <xsl:value-of select="$pi-stack[1]/name()"/> highlights. Highlights without an end: <xsl:copy-of select="$pi-stack"/>. Section in which they appear: "<xsl:value-of select="$title-path"/>" </xsl:message>       
    </xsl:template>
    
    <!--
        Generates a series of markers for text nodes, like the entries in a map.
        Uses a stack to determine which PI is covering the text node.
        
        Context: A text node.
    -->    
    <xsl:template name="generate-review-text-coverage-ids">
        
        <xsl:choose>
            
            <xsl:when test="self::text()">
                <xsl:choose>
                    <xsl:when test="$pi-stack[1]">
                        <text text-id="{generate-id(.)}">
                            <xsl:copy-of select="$pi-stack[1]"/>
                        </text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>

            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="ends-with(./name(), '_start')">
                        <saxon:assign name="pi-stack" select="insert-before($pi-stack, 1, .)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <saxon:assign name="pi-stack" select="remove($pi-stack, 1)"/>                        
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>            
            
        </xsl:choose>
               
    </xsl:template>
    
    <xsl:key name="key-inserted" match="inserted/text" use="@text-id"/>
    <xsl:key name="key-commented" match="commented/text" use="@text-id"/>
    <xsl:key name="key-highlighted" match="highlighted/text" use="@text-id"/>
    
    <!-- Converts a timestamp to a date using the YYYY/MM/DD format -->
    <xsl:template name="get-date">
        <xsl:param name="ts"/>
        <xsl:value-of select="substring($ts, 1, 4)"/>/<xsl:value-of select="substring($ts, 5, 2)"
        />/<xsl:value-of select="substring($ts, 7, 2)"/>
    </xsl:template>
    
    <!-- Converts a timestamp to a string containing hours, minutes, seconds. -->
    <xsl:template name="get-hour">
        <xsl:param name="ts"/>
        <xsl:variable name="part" select="substring-after($ts, 'T')"/>
        <xsl:value-of select="substring($part, 1,2)"/>:<xsl:value-of select="substring($part, 3,2)"/>:<xsl:value-of select="substring($part,5,2)"/>
    </xsl:template>
    
    <!-- Converts a timestamp to a timezone. -->
    <xsl:template name="get-tz">
        <xsl:param name="ts"/>        
        <xsl:variable name="part" select="substring-after($ts, 'T')"/>
        <xsl:choose>
            <xsl:when test="contains($part,'+')">                
                <xsl:variable name="t" select="substring-after($part, '+')"/>
                <xsl:variable name="t1" select="concat(substring($t, 1, 2), ':', substring($t, 3, 2))"/>                
                <xsl:value-of select="concat('+', $t1)"/>                
            </xsl:when>
            <xsl:when test="contains($part,'-')">
                <xsl:variable name="t" select="substring-after($part, '-')"/>
                <xsl:variable name="t1" select="concat(substring($t, 1, 2), ':', substring($t, 3, 2))"/>
                <xsl:value-of select="concat('-', $t1)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'+00:00'"/>                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- Gets a part from the comment PI. -->
    <xsl:template name="get-pi-part">
        <xsl:param name="part"/>
        <xsl:param name="data" select="."/>
        <xsl:variable name="after" select="substring-after($data, concat($part, '=&quot;'))"/>
        <xsl:variable name="before" select="substring-before($after, '&quot;')"/>
        <xsl:value-of select="$before"/>
    </xsl:template>
    
    <xsl:function name="oxy:unescape" as="xs:string">
        <xsl:param name="in" as="xs:string"/>
        <xsl:variable name="s2" select="replace($in, '&amp;amp;', '&amp;')"/>
        <xsl:variable name="s3" select="replace($s2, '&amp;lt;', '&lt;')"/>
        <xsl:variable name="s4" select="replace($s3, '&amp;gt;', '&gt;')"/>
        <xsl:variable name="s5" select="replace($s4, '&amp;quot;', '&quot;')"/>
        <xsl:variable name="s6" select="replace($s5,'&amp;apos;', &quot;&apos;&quot;)"/>
        <xsl:value-of select="$s6"/>
    </xsl:function>
    
    <xsl:template match="attribute" mode="attributes-changes">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="change" mode="attributes-changes">
        <xsl:param name="ctx" tunnel="yes"/>
        <xsl:variable name="aName" select="../@name"/>
        <oxy:oxy-attribute-change type="{@type}" name="{$aName}">
            <oxy:oxy-author>
                <xsl:value-of select="@author"/>
            </oxy:oxy-author>
            <xsl:if test="@comment">
                <oxy:oxy-comment-text>
                    <xsl:value-of select="@comment"/>
                </oxy:oxy-comment-text>
            </xsl:if>
            <xsl:if test="@oldValue">
                <oxy:oxy-old-value>
                    <xsl:value-of select="@oldValue"/>
                </oxy:oxy-old-value>
            </xsl:if>
            <xsl:variable name="currentValue" select="$ctx/@*[local-name() = $aName]"/>
            <xsl:if test="$currentValue">
                <oxy:oxy-current-value>
                    <xsl:value-of select="$currentValue"/>                        
                </oxy:oxy-current-value>
            </xsl:if>
            
            <!-- MID -->
            <xsl:variable name="mid">
                <xsl:call-template name="get-pi-part">
                    <xsl:with-param name="part" select="'mid'"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:if test="string-length($mid) > 0">
                <oxy:oxy-mid>
                    <xsl:value-of select="$mid"/>
                </oxy:oxy-mid>
            </xsl:if>
            
            <oxy:oxy-date>
                <xsl:call-template name="get-date">
                    <xsl:with-param name="ts" select="@timestamp"/>
                </xsl:call-template>
            </oxy:oxy-date>
            <oxy:oxy-hour>
                <xsl:call-template name="get-hour">
                    <xsl:with-param name="ts" select="@timestamp"/>
                </xsl:call-template>
            </oxy:oxy-hour>
            <oxy:oxy-tz>
                <xsl:call-template name="get-tz">
                    <xsl:with-param name="ts" select="@timestamp"/>
                </xsl:call-template>
            </oxy:oxy-tz>
        </oxy:oxy-attribute-change>
    </xsl:template>
    
    <xsl:function name="oxy:getHighlightState" as="item()*">
        <xsl:param name="context" as="node()"/>

        <xsl:variable name="cid" select="generate-id($context)"/>
        
        <xsl:variable name="n" select="$review-coverage/key('key-inserted', $cid)"/>
        <xsl:choose>
            <xsl:when test="$n">
                <xsl:sequence select="'insert', $n/processing-instruction()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="n" select="$review-coverage/key('key-commented', $cid)"/>
                <xsl:choose>
                    <xsl:when test="$n">
                        <xsl:sequence select="'comment', $n/processing-instruction()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="n" select="$review-coverage/key('key-highlighted', $cid)"/>
                        <xsl:choose>
                            <xsl:when test="$n">
                                <xsl:sequence select="'highlight', $n/processing-instruction()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="'other'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Convert an attributes PI to a node set. -->
    <xsl:function name="oxy:attributesChangeAsNodeset" as="item()*">
        <xsl:param name="attributesPI" as="node()"/>
        <!-- Take each of the attribute changes (are separated with spaces.) -->
        <xsl:variable name="s1"
            select="replace($attributesPI, '\s*(.*?)=&quot;(.*?)&quot;', '&amp;lt;attribute name=&quot;$1&quot;&amp;gt;$2&amp;lt;/attribute&amp;gt;')"/>
        <xsl:apply-templates
            select="saxon:parse(concat('&lt;root>', oxy:unescape($s1), '&lt;/root>'))"
            mode="attributes-changes">
            <!-- In order to access the current attributes values -->
            <xsl:with-param name="ctx" select="$attributesPI/following-sibling::*[1]" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:function>
    
    <!-- Convert an attributes PI to a node set. -->
    <xsl:function name="oxy:findHighlightInfoElement" as="item()*">
        <xsl:param name="rangeEndElem" as="node()"/>
        <!-- Find oxy:comment, oxy:insert, oxy:delete elements connected 
            to the range end element. The hr_id is not an unique key, so 
            we select the closest element. -->
        
        <xsl:choose>
            <!-- For delete and attribute PIs usually the PI information element is right after the range end element. -->
            <xsl:when test="$rangeEndElem/following-sibling::node()[1][local-name() = 'oxy-delete' or local-name() = 'oxy-attributes']
                [@hr_id=$rangeEndElem/@hr_id]">
                <xsl:copy-of select="$rangeEndElem/following-sibling::node()[1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="prevMatch" select="($rangeEndElem/preceding::oxy:*[
                    not(local-name() = 'oxy-range-start') and 
                    not(local-name() = 'oxy-range-end')]
                    [@hr_id=$rangeEndElem/@hr_id])
                    [position() = last()]"/>
                <xsl:choose>
                    <xsl:when test="$prevMatch">
                        <xsl:copy-of select="$prevMatch"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- For deletions and attribute changes the information PI element might be after the range end.-->
                        <xsl:copy-of select="($rangeEndElem/following::oxy:*[
                            not(local-name() = 'oxy-range-start') and 
                            not(local-name() = 'oxy-range-end')]
                            [@hr_id=$rangeEndElem/@hr_id])
                            [position() = 1]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>