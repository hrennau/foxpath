<?xml version="1.0" encoding="UTF-8"?>
<!--
    Copyright 2011 Jarno Elovirta
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
    http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    
    Modified 05 Jul 2011 by Syncrosoft to add a pattern for checking unique element IDs.
-->
<schema xmlns="http://purl.oclc.org/dsdl/schematron" 
    queryBinding="xslt2"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <title>Schematron schema for DITA Map 1.2</title>
    <pattern id="topichead_navtitle">
        <rule context="*[contains(@class, ' mapgroup-d/topichead ')]">
            <assert test="@navtitle | *[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]" role="warning"                >
                The <name/> element should have a navtitle element.
            </assert>
        </rule>
    </pattern>    
</schema>
