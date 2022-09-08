<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:iso="http://purl.oclc.org/dsdl/schematron" exclude-result-prefixes="iso">
    <!-- Oxygen patch: EXM-33724 The default query binding used by the embedded schematron rules. -->
    <xsl:param name="defaultQueryBinding">xslt2</xsl:param>
    <xsl:include href="XSD2Schtrn.xsl"/>
    <xsl:include href="RNG2Schtrn.xsl"/>
    
    <xsl:template match="/">  
        <xsl:choose>
            <xsl:when test="namespace-uri(/*[1])='http://relaxng.org/ns/structure/1.0'">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="namespace-uri(/*[1])='http://www.w3.org/2001/XMLSchema'">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="namespace-uri(/*[1])='http://purl.oclc.org/dsdl/schematron'">
                <xsl:apply-templates mode="resolveIncludes" select="."/>
            </xsl:when>
            <xsl:when test="namespace-uri(/*[1])='http://www.ascc.net/xml/schematron'">
                <xsl:apply-templates mode="copyAndAddLocationAttributes" select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="/"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="resolveIncludes copyAndAddLocationAttributes">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:call-template name="addLocation"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
	
    <!-- This template may be overridden to add location attributes --> 
    <xsl:template name="addLocation"/>
        
    <xsl:template match="iso:include" mode="resolveIncludes">
        <xsl:choose>
            <xsl:when test="contains(@href, '#')">
                <xsl:variable name="document-uri" select="substring-before(@href, '#')"/>
                <xsl:variable name="fragment-id" select="substring-after(@href, '#')"/>
                <xsl:choose>
                    <xsl:when test="$fragment-id!=''">
                        <xsl:variable name="doc" select="document($document-uri,.)"/>
                        <xsl:choose>
                            <xsl:when test="not($doc)">
                                <xsl:message terminate="no">
                                    <xsl:text>Error:Unable to open referenced included file: </xsl:text>
                                    <xsl:value-of select="$document-uri"/>
                                </xsl:message>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="componentNode" select="$doc//iso:*[@id=$fragment-id]"/>
                                
                                <xsl:choose>
                                    <xsl:when test="not($componentNode)">
                                        <xsl:message terminate="no">
                                            <xsl:text>Error:Unable to find the component with ID '</xsl:text>
                                            <xsl:value-of select="$fragment-id"/> 
                                            <xsl:text>' in the included file '</xsl:text>
                                            <xsl:value-of select="$document-uri"/><xsl:text>'</xsl:text>
                                        </xsl:message>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates select="$componentNode" mode="resolveIncludes"/>
                                    </xsl:otherwise>                                
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message terminate="no">
                            <xsl:text>Error:Invalid href attribute value for include: </xsl:text>
                            <xsl:value-of select="@href"/>
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="doc" select="document(@href,.)"/>
                <xsl:if test="not($doc)">
                    <xsl:message terminate="no">
                        <xsl:text>Error:Unable to open referenced included file: </xsl:text>
                        <xsl:value-of select="@href"/>
                    </xsl:message>
                </xsl:if>
                <xsl:if test="$doc/iso:schema">
                    <xsl:message terminate="no">
                        <xsl:text>Error:The Schematron include should not point to a schema element,</xsl:text>
                        <xsl:text> it should point to an element that is valid when it replaces the include: </xsl:text>
                        <xsl:value-of select="@href"/>
                    </xsl:message>
                </xsl:if>
                <xsl:apply-templates select="$doc/*" mode="resolveIncludes"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="iso:include[normalize-space(@href)='']" mode="resolveIncludes">
        <xsl:message terminate="no">
            <xsl:text>Error:Invalid empty href attribute value for include.</xsl:text>
        </xsl:message>
    </xsl:template>
    
    
    <xsl:template match="iso:extends[@href]" mode="resolveIncludes">
        
        <xsl:variable name="document-uri"
            select="substring-before(concat(@href,'#'), '#')" />
        
        <xsl:variable name="fragment-id"
            select="substring-after(@href, '#')" />
        
        
        <!--<xsl:processing-instruction name="DSDL_INCLUDE_START">
			<xsl:value-of select="@href" />
		</xsl:processing-instruction>-->
        
        <xsl:choose>

            <xsl:when
                test="string-length( $document-uri ) = 0 and string-length( $fragment-id ) = 0">
                <xsl:message> Error: Impossible URL in Schematron extends </xsl:message>
            </xsl:when>

            <!-- this case is when there is in embedded schema in the same document elsewhere -->
            <xsl:when test="string-length( $document-uri ) = 0">
                <xsl:apply-templates
                    mode="resolveIncludes"
                    select="//iso:*[@xml:id= $fragment-id ]/* 
                            |id( $fragment-id)/*
                            | //iso:*[@id= $fragment-id ]/*"
                />
            </xsl:when>

            <!-- case where there is a fragment in another document (should be an iso: element) -->
            <!-- There are three cases for includes with fragment:
						0) No href file or no matching id - error!
						1) REMOVED
						
						2) REMOVED
						
						3) Otherwise, include the pointed-to element
					-->

            <xsl:when test="string-length( $fragment-id ) &gt; 0">
                <xsl:variable name="theDocument_1" select="document( $document-uri,/ )"/>
                <xsl:variable name="originalParent" select=".."/>

                <!-- case 0 -->
                <xsl:if test="not($theDocument_1)">
                    <xsl:message terminate="no">
                        <xsl:text>Unable to open referenced included file: </xsl:text>
                        <xsl:value-of select="@href"/>
                    </xsl:message>
                </xsl:if>
                <!-- use for-each to rebase id() to external document -->
                <xsl:for-each select="$theDocument_1">
                    <xsl:variable name="theFragment_1"
                        select=" $theDocument_1//iso:*[@xml:id= $fragment-id ] |
                                id($fragment-id) |
                                $theDocument_1//iso:*[@id= $fragment-id ]"/>


                    <xsl:choose>
                        <!-- case 0 -->
                        <xsl:when test="not($theFragment_1)">
                            <xsl:message terminate="no">
                                <xsl:text>Unable to locate id attribute: </xsl:text>
                                <xsl:value-of select="@href"/>
                            </xsl:message>
                        </xsl:when>


                        <!-- case 1 REMOVED -->

                        <!-- case 2 REMOVED -->


                        <!-- case 3 -->
                        <xsl:otherwise>

                            <xsl:apply-templates select=" $theFragment_1[1]/*" mode="resolveIncludes"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>

            <!-- Case where there is no ID so we include the whole document -->
            <!-- Experimental addition: include fragments of children -->
            <xsl:otherwise>
                <xsl:variable name="theDocument_2" select="document( $document-uri,/ )"/>
                <xsl:variable name="theFragment_2" select="$theDocument_2/iso:*"/>
                <xsl:variable name="theContainedFragments"
                    select="$theDocument_2/*/iso:* | $theDocument_2/*/xsl:* | $theDocument_2/*/xhtml:*"/>
                <xsl:if test="not($theDocument_2)">
                    <xsl:message terminate="no">
                        <xsl:text>Unable to open referenced included file: </xsl:text>
                        <xsl:value-of select="@href"/>
                    </xsl:message>
                </xsl:if>

                <!-- There are three cases for includes:
							0) No text specified- error!
							
							1) REMOVED
							
							2) REMOVED
							
							3) Otherwise, include the pointed-to element
						-->
                <xsl:choose>
                    <!-- case 0 -->
                    <xsl:when test="not($theFragment_2) and not ($theContainedFragments)">
                        <xsl:message terminate="no">
                            <xsl:text>Unable to locate id attribute: </xsl:text>
                            <xsl:value-of select="@href"/>
                        </xsl:message>
                    </xsl:when>

                    <!-- case 1 removed -->

                    <!-- case 2 removed -->

                    <!-- If this were XLST 2, we could use  
								if ($theFragment) then $theFragment else $theContainedFragments
								here (thanks to KN)
							-->
                    <!-- case 3 -->
                    <xsl:otherwise>
                        <xsl:apply-templates select="$theFragment_2/* " mode="resolveIncludes"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
            
        
        
        <!--<xsl:processing-instruction name="DSDL_INCLUDE_END">
			<xsl:value-of select="@href" />
		</xsl:processing-instruction>-->
    </xsl:template>
</xsl:stylesheet>
