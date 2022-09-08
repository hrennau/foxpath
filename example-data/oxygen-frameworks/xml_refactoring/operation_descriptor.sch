<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2" xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns:xr="http://www.oxygenxml.com/ns/xmlRefactoring">
    <ns uri="http://www.oxygenxml.com/ns/xmlRefactoring" prefix="xr"/>
    
    <pattern>
        <p>An parameter with TEXT_CHOICE type should have a list with possible values.</p>
        <rule context="xr:parameter[@type='TEXT_CHOICE']">
            <assert test="exists(xr:possibleValues)" sqf:fix="add_possible_values">                
                For parameters with TEXT_CHOICE type a list with possible values is required.</assert>
        </rule>
    </pattern>
    
    <pattern>
        <p>A parameter with possible values should have only one default value.</p>
        <rule context="xr:possibleValues">
            <assert test="count(xr:value[@default = 'true']) &lt;= 1" subject="xr:value[@default = 'true']">
                Only one of the possible values can be the default one.</assert>
        </rule>
    </pattern>
      
    <sqf:fixes>
        <sqf:fix id="add_possible_values">
            <sqf:description>
                <sqf:title>Add possible values</sqf:title>
            </sqf:description>
            
            <sqf:add match="." position="last-child">
                <xr:possibleValues onlyPossibleValuesAllowed="true">
                    <xr:value name="value_id">Value label</xr:value>
                </xr:possibleValues>
            </sqf:add>
        </sqf:fix>
    </sqf:fixes>
    
</schema>