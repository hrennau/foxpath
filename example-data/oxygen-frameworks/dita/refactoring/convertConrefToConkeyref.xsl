<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="http://oxygenxml.com/ns/local"
    exclude-result-prefixes="xs xd"
    version="2.0">
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>Converts all @conrefs to @conkeyrefs. </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>The default, copy template</xd:desc>
    </xd:doc>
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
        Rename conref to conkeyref if the conref does not start with #.
        The key is now the name of the file. The # will be replaced with /.
    -->
    <xsl:template match="@conref[not(starts-with(., '#'))]">
        <!-- Get the ID part from the @conref and strip an eventual ending slash. -->
        <xsl:variable name="idWithoutEndingSlash" select="local:stripLastSlash(substring-after(xs:string(.),'#'))"/>
        <!-- Compute the ID needed for the key-based reference. -->
        <xsl:variable name="id" select="local:getElementId(xs:string($idWithoutEndingSlash))"/>  
        <!-- Compute a key name. -->
        <xsl:variable name="key" select="local:computeKeyName(substring-before(xs:string(.), '#'))"/>
        <!-- Set the @conkeyref -->
        <xsl:attribute name="conkeyref" select="concat($key, '/', $id)"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc><xd:b>Provides the key name of the future conkeyref. It's the name 
            of the content referred document.</xd:b></xd:desc>
        <xd:param>Path of the conref document.</xd:param>
        <xd:return>The key name. Identical with the referred document.</xd:return>
    </xd:doc>
    <xsl:function name="local:computeKeyName" as="xs:string">
        <xsl:param name="path" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="contains($path, '/')">
                <xsl:value-of select="local:computeKeyName(substring-after($path, '/'))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring-before($path, '.')"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xd:doc>
        <xd:desc><xd:b>Strip the last slash of the ID, if it ends with one.</xd:b></xd:desc>
        <xd:param>The element id that might end with /.</xd:param>
        <xd:return>The element ID, without the ending slash.</xd:return>
    </xd:doc>
    <xsl:function name="local:stripLastSlash" as="xs:string">
        <xsl:param name="initialId" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="ends-with($initialId, '/')">
                <xsl:value-of select="substring($initialId, 1, string-length($initialId) - 1)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$initialId"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Provides the element id.</xd:desc>
        <xd:param><xd:b>conrefStyleId</xd:b> topicId/elementID or just topicID if it refers the actual topic.</xd:param>
        <xd:return>The id of the element referred.</xd:return>
    </xd:doc>
    <xsl:function name="local:getElementId" as="xs:string">
        <xsl:param name="conrefStyleId" as="xs:string"></xsl:param>
        <!-- 
            If it contains a slash then it has the form topicId/elementID and we just need the elementID.
        -->
        <xsl:choose>
            <xsl:when test="contains($conrefStyleId, '/')">
                <xsl:value-of select="substring-after($conrefStyleId, '/')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$conrefStyleId"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>