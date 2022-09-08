<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:e="http://www.oxygenxml.com/xsl/conversion-elements"
    xmlns:f="http://www.oxygenxml.com/xsl/functions"
    exclude-result-prefixes="xsl e f"
    version="2.0">

  <xsl:template match="e:table[$dita.reference.properties.table != 0]
                             [$context.path.names.sequence[1] = 'reference'
                              or ($context.path.names.sequence[1] = 'dita'
                                 and $context.path.names.sequence[2] = 'reference')]"
            priority="1">
        <properties>
            <xsl:apply-templates mode="reference"/>
        </properties>
    </xsl:template>
    
    
    <xsl:template match="e:tr" mode="reference">
        <property>
            <xsl:apply-templates mode="reference"/>
        </property>
    </xsl:template>
    
    
    <xsl:template match="e:th | e:td" mode="reference">
        <xsl:variable 
            name="numberOfPrecedingColumns" 
            select="count(preceding-sibling::e:th | preceding-sibling::e:td)"/>
        <xsl:variable 
            name="numberOfFollowingColumns" 
            select="count(following-sibling::e:th | following-sibling::e:td)"/>
        <xsl:choose>
            <xsl:when test="$numberOfPrecedingColumns = 0">
                <xsl:choose>
                    <xsl:when test="$numberOfFollowingColumns = 0">
                        <propvalue>
                            <xsl:apply-templates/>
                        </propvalue>
                    </xsl:when>
                    <xsl:otherwise>
                        <proptype>
                            <xsl:apply-templates/>
                        </proptype>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$numberOfPrecedingColumns = 1">
                <propvalue>
                    <xsl:apply-templates/>
                </propvalue>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="position() = last()">
                        <propdesc>
                            <xsl:apply-templates/>
                        </propdesc>
                    </xsl:when>
                    <xsl:otherwise>
                        <propvalue>
                            <xsl:apply-templates/>
                        </propvalue>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template match="e:li" mode="reference">
        <property>
            <propvalue>
                <xsl:apply-templates/>
            </propvalue>
        </property>
    </xsl:template>
    
    
    <xsl:template 
        match="e:ul[not(ancestor::e:li)]
                          [$context.path.names.sequence[1] = 'reference'
                          or ($context.path.names.sequence[1] = 'dita'
                                and $context.path.names.sequence[2] = 'reference')]">
        <properties>
            <xsl:apply-templates mode="reference"/>
        </properties>
    </xsl:template>
    
    
    <xsl:template 
        match="e:ol[not(ancestor::e:li)]
                          [$context.path.names.sequence[1] = 'reference'
                          or ($context.path.names.sequence[1] = 'dita'
                                and $context.path.names.sequence[2] = 'reference')]">
        <properties>
            <xsl:apply-templates mode="reference"/>
        </properties>
    </xsl:template>
</xsl:stylesheet>