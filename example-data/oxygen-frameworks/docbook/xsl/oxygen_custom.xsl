<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <!-- Template to add the namespace to non-namespaced documents -->
    <!-- oXygen Patch: Add the docbook namespace only to the elements from no namespace.-->
    <xsl:template match="*" mode="addNS">
        <xsl:choose>
            <xsl:when test="namespace-uri(.) = ''">
                <xsl:element name="{local-name()}" 
                    namespace="http://docbook.org/ns/docbook">
                    <!-- EXM-26444 Fix, replace entityrefs with filerefs -->
                    <xsl:if test="@entityref">
                        <xsl:attribute name="fileref"><xsl:value-of select="unparsed-entity-uri(@entityref)"/></xsl:attribute>
                    </xsl:if>
                    <!-- Copy any attribute except entityref -->
                    <xsl:copy-of select="@*[local-name()!='entityref']"/>
                    <!--EXM-21274 Add the xml:base to the root-->
                    <xsl:if test="not(../..)">
                        <xsl:call-template name="add-xml-base"/>
                    </xsl:if>
                    <xsl:apply-templates select="node()" mode="addNS"/>
                </xsl:element>                
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:template>
</xsl:stylesheet>
