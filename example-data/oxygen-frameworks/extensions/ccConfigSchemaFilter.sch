<?xml version="1.0" encoding="UTF-8"?>
<!-- A few rules that should guide the user writing a configuration file for CC. -->
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    <ns prefix="cc" uri="http://www.oxygenxml.com/ns/ccfilter/config"/>
    <pattern>
        <rule context="cc:match[@elementName]">
            <assert test="not(contains(@elementName, ':'))">The element name must be a local name. If you want to enforce a namespace restriction you can use @elementNs</assert>
        </rule>
        
        <rule context="cc:match[@attributeName]">
            <assert test="not(contains(@elementName, ':'))">The attribute name must be a local name. If you want to enforce a namespace restriction you can use @attributeNs</assert>
        </rule>
    </pattern>
    <pattern>
        <!-- An attribute namespace exists is not useful without the attribute local name. -->
        <rule context="cc:match[@attributeNS]">
            <assert test="@attributeName">If you intend this rule to match on an attribute you should add an @attributeName</assert>
        </rule>
        
        <!-- The rule requires an attribute local name or an element local name for matching. -->
        <rule context="cc:match">
            <assert test="@elementName or @attributeName">The rule must match on an @attributeName or an @elementName</assert>
        </rule>
    </pattern>
</schema>