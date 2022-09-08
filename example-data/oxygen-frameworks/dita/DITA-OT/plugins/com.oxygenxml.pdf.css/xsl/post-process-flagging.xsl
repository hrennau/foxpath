<?xml version="1.0" encoding="UTF-8"?>

<!--
    Stylesheet used to convert DITA-OT flagging elements in a structure that is more easier to match from CSS.  
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!--
        Copy attributes from ditaval-startprop/prop and ditaval-startprop/revprop elements
    -->
    <xsl:template
        match="*[*[local-name() = 'ditaval-startprop' and position() = 1]][*[local-name() = 'ditaval-endprop' and position() = last()]]">
        <xsl:copy>
            <!-- Copy attributes -->
            <xsl:apply-templates select="@*"/>
            
            
            <!--<p class="- topic/p ">
                <ditaval-startprop
                class="+ topic/foreign ditaot-d/ditaval-startprop "
                outputclass="text-decoration:underline;">
                    <prop action="flag" att="audience"
                    style="double-underline" val="a-style-double-underline"
                />
                </ditaval-startprop>double-underline
                <ditaval-endprop
                    class="+ topic/foreign ditaot-d/ditaval-endprop ">
                    <prop action="flag"
                        att="audience" style="double-underline" val="a-style-double-underline"
                    />
                </ditaval-endprop>
            </p>-->
            <!-- Copy attributes from ditaval-startprop/prop element-->
            <xsl:variable name="ditaval-startprop" select="*[local-name() = 'ditaval-startprop' and position() = 1]"/>                        
            <xsl:for-each select="$ditaval-startprop/prop/@*">
                <xsl:attribute name="data-ditaval-{local-name()}" select="."/>
            </xsl:for-each>
            
            <!--
                <p class="- topic/p " rev="16">
                <ditaval-startprop
                class="+ topic/foreign ditaot-d/ditaval-startprop ">
                <revprop action="flag"
                    changebar="color:red;style:solid;width:1pt;offset:1.25mm;placement:start"
                    val="16"/></ditaval-startprop>This paragraph has the next changebar set:
                color:red;style:solid;width:1pt;offset:1.25mm;placement:start<ditaval-endprop
                    class="+ topic/foreign ditaot-d/ditaval-endprop "><revprop action="flag"
                        changebar="color:red;style:solid;width:1pt;offset:1.25mm;placement:start"
                        val="16"/></ditaval-endprop></p>
            -->
            <!--                
                <revprop action="flag"
                    changebar="color:red;style:solid;width:1pt;offset:1.25mm;placement:start"
                    val="16"/>
            -->
            <!-- Copy attributes from ditaval-startprop/revprop element-->
            <xsl:for-each select="$ditaval-startprop/revprop/@*">
                <xsl:choose>
                    <!--
                        Tokenize the changebar attribute to emit separate attributes like:
                        data-ditaval-change-bar-color, data-ditaval-change-bar-style.
                        
                        changebar="color:red;style:solid;width:1pt;offset:1.25mm;placement:start" 
                    -->
                    <xsl:when test="local-name(.) = 'changebar'">
                        <xsl:variable name="changebarToken" select="tokenize(., ';')"/>
                        <xsl:for-each select="$changebarToken">
                            <xsl:variable name="propTokens" select="tokenize(., ':')"/>
                            <xsl:if test="count($propTokens) = 2">
                                <xsl:attribute 
                                    name="data-ditaval-change-bar-{$propTokens[1]}" 
                                    select="$propTokens[2]"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="data-ditaval-{local-name()}" select="."/>        
                    </xsl:otherwise>
                </xsl:choose>                
            </xsl:for-each>
            
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>