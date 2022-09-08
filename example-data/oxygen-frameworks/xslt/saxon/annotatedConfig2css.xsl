<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">
    <xsl:output method="text"/>
    
    <!-- Start with the root element -->    
    <xsl:template match="/">
@namespace oxy "http://www.oxygenxml.com/extensions/author";
oxy|comment {
    display:none !important;
}
        <xsl:apply-templates select="//xs:element[@name='configuration']" mode="options"/>
    </xsl:template>
    
    <!-- Elements with a simple type -->
    <xsl:template match="xs:element[@type]" expand-text="yes" mode="options" priority="10">
        <xsl:variable name="name" select="@name"/>
{$name}:before(6){{
    display:inline;
    content: 
        oxy_label(text, "{$name}:", width, 40%)
        
    ;    
        
}}  


{$name} {{
    -oxy-show-placeholder:always;
}}


{$name}:after(4) {{
    display:inline;
    content:
        " "
        oxy_button(
            action, oxy_action(
                name, '[+]', 
                description, 'See option description', 
                operation, 'ro.sync.ecss.extensions.commons.operations.TogglePseudoClassOperation', 
                arg-elementLocation, '.',
                icon, url('info12.png'), 
                arg-name, '-oxy-hints'
            ),
            transparent, true,
            showIcon, true)
        ;
}}
{$name}:after(4):-oxy-hints {{
    display:inline;
    content:
        " "
        oxy_button(
            action, oxy_action(
                name, '[-]', 
                description, 'Hide option description', 
                operation, 'ro.sync.ecss.extensions.commons.operations.TogglePseudoClassOperation', 
                arg-elementLocation, '.',
                icon, url('info12.png'),
                arg-name, '-oxy-hints'
            ),
        transparent, true,
        showIcon, true)
        ;
}}

/* delete action */
{@name}:after(5) {{
    display:inline;
    content:
    " "
    oxy_button(
        color, #CC5400,
        action, oxy_action(
            name, '[X]', 
            icon, '/images/Remove16.png',
            description, oxy_concat('Delete the current "', oxy_local-name(), '" element'), 
            operation, 'ro.sync.ecss.extensions.commons.operations.DeleteElementOperation'
        ), 
        transparent, true,
        showIcon, true);    
    ;
}}


{$name}:after(12):-oxy-hints {{
    border:1px solid gray;
    background-color:#FFFCCA;
    width:93%;
    display:block;
    content:
        oxy_htmlContent(
            href, 'saxonConfiguration.html',
            id, 'element-{$name}',
            width, 100%
        );
}}

{$name}:after(300) {{
    display:block;
    width:90%;
    margin-top:2px;
    margin-left:24px;
    border-top:1px solid #B08A5D;
    line-height:2px;
    content:" ";
}}






    </xsl:template>
    
    <xsl:template match="xs:element[@name]" expand-text="yes" mode="options">
        <xsl:variable name="name" select="@name"/>
        
/* main element styles */        
{@name} {{
    margin:1em;
    margin-top:2em;
    padding:0.2em;
    padding-left:1em;
    border:1px solid gray;

}}

<xsl:if test="@name!='configuration'">
/* delete action */
{@name}:before(500) {{
    text-align:right;
    display:block;
    content:
    " "
    oxy_button(
        color, #CC5400,
        action, oxy_action(
            name, '[X]', 
            icon, '/images/Remove16.png',
            description, oxy_concat('Delete the current "', oxy_local-name(), '" element'), 
            operation, 'ro.sync.ecss.extensions.commons.operations.DeleteElementOperation'
        ), 
        transparent, true,
        showIcon, true);    
    ;
}}
</xsl:if>
/* section title */
{@name}:before(499) {{
    display:block;
    font-size:1.5em;
    text-align:center;
    content:"{if (xs:annotation/xs:documentation) then normalize-space(translate(xs:annotation/xs:documentation, '.', '')) else concat('Specify ',@name, ' options for Saxon')}"; 
    padding:1em;
}}



{$name}:after(300) {{
    display:block;
    width:90%;
    margin-left:24px;
    margin-top:2px;
    border-top:1px solid #B08A5D;
    line-height:2px;
    content:" ";
}}



        <xsl:for-each select=".//xs:element[@ref]" expand-text="yes">
            <xsl:variable name="ref" select="substring-after(@ref, ':')"/>
<xsl:if test="not(@maxOccurs='unbounded') and not(../@maxOccurs='unbounded')">
{$name}:after({300 + 2*position()})! > {$ref} {{
    display:none;
}}
</xsl:if>
            <xsl:variable name="fragment">
                <xsl:apply-templates select="//xs:element[@name=$ref]" mode="fragment"/>
            </xsl:variable>
            
            
{$name}:after({300 + 2*position()}) {{
    content:
        oxy_button(  
            color, #B08A5D,
            action,
            oxy_action(
                name, '[{$ref}]', 
                description, 'Insert {$ref} options', 
                operation, 'ro.sync.ecss.extensions.commons.operations.InsertFragmentOperation', 
                arg-fragment, '{$fragment}',
                arg-insertLocation, '.',
                arg-insertPosition, 'Inside as last child',
                arg-schemaAware, false
            ), 
            transparent, true,
            actionContext, element,
            showIcon, true
            )
            ;
}}
            
            
            <xsl:apply-templates select="//xs:element[@name=$ref]" mode="options"/>
        </xsl:for-each>





        <xsl:for-each select=".//xs:attribute">
            <xsl:variable name="index" select="400 - 4 * position()"/>



{$name}:before({$index+2}) {{
    display:inline;
    content: 
        oxy_label(text, "{@name}:", width, 40%)
        oxy_combobox(
            width, 50%
            edit, "@{@name}",
            editable, true)
    ;    
    
}}

{$name}:before({$index + 3}) {{
    display:inline;
    content:
        " "
        oxy_button(
            action, oxy_action(
                name, '[+]', 
                description, 'See option description', 
                operation, 'ro.sync.ecss.extensions.commons.operations.TogglePseudoClassOperation', 
                arg-elementLocation, '.',
                icon, url('info12.png'),
                arg-name, '-oxy-hints{$index}'
            ),
            transparent, true,
            showIcon, true)
            
        ;
}}
{$name}:before({$index + 3}):-oxy-hints{$index} {{
    display:inline;
    content:
        " "
        oxy_button(
            action, oxy_action(
                name, '[-]', 
                description, 'Hide option description', 
                operation, 'ro.sync.ecss.extensions.commons.operations.TogglePseudoClassOperation', 
                arg-elementLocation, '.',
                icon, url('info12.png'),
                arg-name, '-oxy-hints{$index}'
            ),
        transparent, true,
        showIcon, true)
        ;
}}


{$name}:before({$index+1}):-oxy-hints{$index} {{
    border:1px solid gray;
    background-color:#FFFCCA;
    width:93%;
    display:block;
    content:
        oxy_htmlContent(
            href, 'saxonConfiguration.html',
            id, 'attribute-{@name}',
            width, 100%
        );
}}
            <xsl:if test="position()!=last()">
{$name}:before({$index}) {{
    display:block;
    width:90%;
    margin-left:24px;
    margin-top:2px;
    border-top:1px solid #B08A5D;
    line-height:2px;
    content:" ";
}}
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template mode="options" match="text()"/>
    
    <xsl:template match="xs:element[@name]" mode="fragment">
        <xsl:text expand-text="yes">&lt;{@name} xmlns="http://saxon.sf.net/ns/configuration"</xsl:text>
        <xsl:for-each select=".//xs:attribute[@use='required']">
            <xsl:text expand-text="yes"> {@name}=""</xsl:text>
        </xsl:for-each>
        <xsl:text>></xsl:text>
        <xsl:apply-templates select=".//xs:element" mode="fragment"/>
        <xsl:text expand-text="yes">&lt;/{@name}></xsl:text>
    </xsl:template>
    <xsl:template match="xs:element[@ref][(not(@minOccurs) or @minOccurs>0) and (not(../@minOccurs) or ../@minOccurs>0)]" mode="fragment" expand-text="yes">
        <xsl:variable name="ref" select="substring-after(@ref, ':')"/>
        <xsl:apply-templates select="//xs:element[@name=$ref]" mode="fragment"/>
    </xsl:template>
    <xsl:template match="text()" mode="fragment"/>
    
    <xsl:template match="text()"/>
</xsl:stylesheet>