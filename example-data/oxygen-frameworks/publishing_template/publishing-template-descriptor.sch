<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns:xr="http://www.oxygenxml.com/ns/xmlRefactoring"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <!-- 
        Test all HTML page templates are specified. 
    -->
    <sch:pattern id="html-fragments">
        <!-- Change the attribute to point the element being the context of the assert expression. -->
        <sch:rule context="html-page-templates">
            <!-- Change the assert expression. -->
            <sch:assert test="page-template[@page='main']">The HTML template for the main page should be specified.</sch:assert>            
            <sch:assert test="page-template[@page='search']">The HTML template for the search page should be specified.</sch:assert>
            <sch:assert test="page-template[@page='topic']">The HTML template for the topic page should be specified.</sch:assert>
            <sch:assert test="page-template[@page='index-terms']">The HTML template for the index-terms page should be specified.</sch:assert>
        </sch:rule>        
    </sch:pattern>
    
    <!-- Customization folder URI -->
    <sch:let name="cfURI" value="concat(string-join(tokenize(base-uri(), '/')[position() &lt; last()], '/'), '/')"/>
    
    <!-- Test that the files associated with HTML page templates exist on disk -->
    <sch:pattern id="html-page-template">
        <sch:rule context="page-template[@file]">
            <sch:let name="pageTemplateURI" value="resolve-uri(@file, $cfURI)"/>
            
            <sch:assert test="doc-available($pageTemplateURI)">The HTML page template does not exist: <sch:value-of select="$pageTemplateURI"/>.</sch:assert>                        
        </sch:rule>
    </sch:pattern>
    
    <!-- Test that the files associated with template resources exist on disk -->
    <sch:pattern id="resources">         
        <sch:rule context="css[@file]">
            <sch:let name="cssURI" value="resolve-uri(@file, $cfURI)"/>          
            <sch:assert test="unparsed-text-available($cssURI)">The CSS template resource does not exist: <sch:value-of select="$cssURI"/>.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- 
        Test that the files associated with XSLT extension points exist on disk 
    -->
    <sch:pattern id="xslt-resources">         
        <sch:rule context="xslt/extension[@file]">
            <sch:let name="resourcesURI" value="resolve-uri(@file, $cfURI)"/>          
            <sch:assert test="doc-available($resourcesURI)">The referenced XSLT does not exist: <sch:value-of select="$resourcesURI"/>.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- 
        Test that the files associated with HTML-fragments extension points exist on disk 
    -->
    <sch:pattern id="html-fragment-resources">         
        <sch:rule context="html-fragments/fragment[@file]">
            <sch:let name="resourcesURI" value="resolve-uri(@file, $cfURI)"/>          
            <sch:assert test="doc-available($resourcesURI)">The resource associated with the HTML fragment does not exist: <sch:value-of select="$resourcesURI"/>.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
</sch:schema>