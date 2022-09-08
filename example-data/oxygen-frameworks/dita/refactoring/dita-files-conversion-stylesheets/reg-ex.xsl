<?xml version="1.0" encoding="UTF-8"?>
<!--
  Copyright 2001-2017 Syncro Soft SRL. All rights reserved.
 --> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="3.0"
    xmlns:xrf="http://www.oxygenxml.com/ns/xmlRefactoring/functions/regex">

    <!-- One or more spaces. -->
    <xsl:variable name="S">
        <xsl:text>([ \t\r\n]+)</xsl:text>
    </xsl:variable>

    <!-- 
       Returns a regex expression that match the DOCTYPE declaration. 
   -->
    <xsl:function name="xrf:doctype-regex" as="xs:string">
        <!-- DOCTYPE regex -->
        <xsl:variable name="doctype-regex">
            <xsl:variable name="DOCTYPE" select="'!DOCTYPE'"/>

            <!-- '<!DOCTYPE' S Name (S ExternalID)? S? ('[' intSubset ']' S?)? '>' -->
            <!--<xsl:value-of select="concat('(', $S, xrf:external-id-regex(), ')')"/>-->
            <xsl:value-of
                select="concat('&lt;', $DOCTYPE, $S, xrf:name(), '(', $S, xrf:external-id(), ')?', $S, '?', '(\[[^\]]*\]', $S, '?)?', '&gt;')"
            />
            <!--<xsl:value-of select="'\[[^\]]*\]'"/>-->
            
        </xsl:variable>

        <xsl:value-of select="$doctype-regex"/>
    </xsl:function>

    <!-- 
       Returns a regex expression that match a Name declaration within DOCTYPE.
    -->
    <xsl:function name="xrf:name">
        <xsl:variable name="NameStartChar">
            <xsl:text>(:|[A-Za-z]|_|[&#x00C0;-&#x00D6;]|[&#x00D8;-&#x00F6;]|[&#x00F8;-&#x02FF;]|[&#x0370;-&#x037D;]|[&#x037F;-&#x1FFF;]|[&#x200C;-&#x200D;]|[&#x2070;-&#x218F;]|[&#x2C00;-&#x2FEF;]|[&#x3001;-&#xD7FF;]|[&#xF900;-&#xFDCF;]|[&#xFDF0;-&#xFFFD;])</xsl:text>
        </xsl:variable>

        <xsl:variable name="NameChar">
            <xsl:value-of
                select="concat($NameStartChar, '|-|\.|[0-9]|&#x00B7;|[&#x0300;-&#x036F;]|[&#x203F;-&#x2040;]')"
            />
        </xsl:variable>

        <xsl:value-of select="concat($NameStartChar, '(', $NameChar, ')*')"/>
    </xsl:function>

    <!-- 
       Returns a regex expression that match the external id within DOCTYPE.
    -->
    <xsl:function name="xrf:external-id">
        <xsl:variable name="SystemLiteral">
            <xsl:text>(("[^"]*")|('[^']*'))</xsl:text>
        </xsl:variable>

        <xsl:variable name="PubidLiteral">
            <xsl:variable name="PubIdCharSQ">
                <xsl:text>[&#x0020;\r\n]|[a-zA-Z0-9]|[\-\(\)+,\./:=\?;!\*#@$_%]</xsl:text>
            </xsl:variable>

            <xsl:variable name="sq">'</xsl:variable>
            <xsl:variable name="PubIdCharDQ">
                <xsl:value-of select="concat($PubIdCharSQ, '|', $sq)"/>
            </xsl:variable>
            <xsl:value-of
                select="concat('((&quot;(', $PubIdCharDQ, ')*&quot;)|(', $sq, '(', $PubIdCharSQ, ')*', $sq, '))')"
            />
        </xsl:variable>
        <xsl:value-of
            select="concat('((SYSTEM', $S, $SystemLiteral, ')|(', 'PUBLIC', $S, $PubidLiteral, $S, $SystemLiteral, '))')"
        />
    </xsl:function>

    <!-- 
       Returns a regex expression that match any pi.
    -->
    <xsl:function name="xrf:pi-regex" as="xs:string">
        <xsl:value-of
            select="concat('(&lt;\?', xrf:name(), '(', $S, '([^\?]|(\?[^>]))+', ')?\?&gt;)')"/>
    </xsl:function>

    <!-- 
       Returns a regex expression that match the xml-model pi.
    -->
    <xsl:function name="xrf:xml-model-pi-regex" as="xs:string">
        <xsl:value-of select="concat('(&lt;\?xml-model', '(', $S, '([^\?]|(\?[^>]))+', ')?\?&gt;)')"
        />
    </xsl:function>
</xsl:stylesheet>
