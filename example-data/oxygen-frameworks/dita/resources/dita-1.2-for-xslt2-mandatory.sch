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
    queryBinding="xslt2" xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <title>Schematron schema for DITA 1.2</title>
    <p>Version 3.0.0 released 2010-10-17.</p>
    <ns uri="http://dita.oasis-open.org/architecture/2005/" prefix="ditaarch"/>
    
    <!-- EXM-31129 The DITA validation already does this -->
    <!--<!-\-EXM-21448 Report duplicate IDs start pattern-\->
    <xsl:key name="elementsByID" match="*[@id][not(contains(@class, ' topic/topic '))]"
        use="concat(@id, '#', ancestor::*[contains(@class, ' topic/topic ')][1]/@id)"/>
    
    <pattern id="checkIDs">
        <rule context="*[@class][@id]">
            <let name="k" value="concat(@id, '#', ancestor::*[contains(@class, ' topic/topic ')][1]/@id)"/>
            <let name="countKey" value="count(key('elementsByID', $k))"/>
            <report test="$countKey > 1" >
                The id attribute value "<value-of select="@id"/>" is not unique within the topic that contains it.
            </report>
        </rule>
    </pattern>
    <!-\-EXM-21448 Report duplicate IDs end pattern-\->-->
    
    <pattern abstract="true" id="self_nested_element">
    <rule context="$element">
        <report test="descendant::$element" role="warning">The <name/> contains a <name/>. The
            results in processing are undefined.</report>
    </rule>
    </pattern>
    <pattern abstract="true" id="nested_element">
        <rule context="$element">
            <report test="descendant::$descendant">The <name/> contains <value-of
                    select="name(descendant::$descendant)"/>. Using <value-of
                    select="name(descendant::$descendant)"/> in this context is
                ill-adviced.</report>
        </rule>
    </pattern>
    <pattern abstract="true" id="future_use_element">
        <rule context="$context">
            <report test="$element">The <value-of select="name($element)"/> element is reserved for
                future use. <value-of select="$reason"/></report>
        </rule>
    </pattern>
    <pattern abstract="true" id="future_use_attribute">
        <rule context="$context">
            <report test="$attribute">The <value-of select="name($attribute)"/> attribute on <name/>
                is reserved for future use. <value-of select="$reason"/></report>
        </rule>
    </pattern>
    <pattern abstract="true" id="deprecated_element">
        <rule context="$context">
            <report test="$element">The <value-of select="name($element)"/> element is deprecated.
                    <value-of select="$reason"/></report>
        </rule>
    </pattern>
    <pattern abstract="true" id="deprecated_attribute">
        <rule context="$context">
            <report test="$attribute">The <value-of select="name($attribute)"/> attribute is
                deprecated. <value-of select="$reason"/></report>
        </rule>
    </pattern>
    <pattern abstract="true" id="deprecated_attribute_value">
        <rule context="$context">
            <report test="$attribute[. = $value]">The value "<value-of select="$value"/>" for
                    <value-of select="name($attribute)"/> attribute is deprecated. <value-of
                    select="$reason"/></report>
        </rule>
    </pattern>
    <pattern id="otherrole"
        >
        <rule context="*[@role = 'other']">
            <assert test="@otherrole" role="error" sqf:fix="addOtherRole chanageRole"><name/> with role 'other' should have otherrole
                attribute set.</assert>
            <sqf:fix id="addOtherRole">
                <sqf:description>
                    <sqf:title>Add the @otherrole attribute on the current element</sqf:title>
                </sqf:description>
                <sqf:add node-type="attribute" target="otherrole"/>
            </sqf:fix>
            <sqf:fix id="chanageRole" role="replace">
                <sqf:description>
                    <sqf:title>Change the role for the <name/> element</sqf:title>
                </sqf:description>
                <sqf:delete match="@role"/>
                <sqf:add node-type="attribute" target="role"/>
            </sqf:fix>
        </rule>
    </pattern>
    <pattern id="othernote"
        >
        <rule context="*[contains(@class,' topic/note ')][@type = 'other']">
            <assert test="@othertype" role="error" sqf:fix="addOtherType"><name/> with type 'other' should have othertype
                attribute set.</assert>
            <sqf:fix id="addOtherType">
                <sqf:description>
                    <sqf:title>Add the @othertype attribute on the current element</sqf:title>
                </sqf:description>
                <sqf:add node-type="attribute" target="othertype"/>
            </sqf:fix>
        </rule>
    </pattern>
    <pattern id="indextermref"
        >
        <rule context="*">
            <report test="*[contains(@class, ' topic/indextermref ')]" role="error">The <value-of
                    select="name(*[contains(@class, ' topic/indextermref ')])"/> element is reserved
                for future use.</report>
        </rule>
    </pattern>
    <pattern id="collection-type_on_rel"
        >
        <rule
            context="*[contains(@class, ' map/reltable ')] | *[contains(@class, ' map/relcolspec ')]">
            <report test="@collection-type" role="error">The collection-type attribute on <name/> is
                reserved for future use.</report>
        </rule>
    </pattern>
    <pattern id="multiple_section_titles">
        <rule context="*[contains(@class, ' topic/section ')]">
            <report test="count(*[contains(@class, ' topic/title ')]) &gt; 1" role="warning" 
                sqf:fix="deletTitles convertTitles" >
                <name/>
                should only contain one title element.</report>
            
            <sqf:fix id="deletTitles" role="delete">
                <sqf:description>
                    <sqf:title>Delete other title elements</sqf:title>
                </sqf:description>
                <sqf:delete match="*[contains(@class, ' topic/title ')][position() > 1]"/>
            </sqf:fix>
            
            <sqf:fix id="convertTitles">
                <sqf:description>
                    <sqf:title>Convert other titles to text</sqf:title>
                </sqf:description>
                <sqf:replace match="*[contains(@class, ' topic/title ')][position() > 1]" select="child::node()"/>
            </sqf:fix>
        </rule>
    </pattern>
    <pattern id="multiple_example_titles">
        <rule context="*[contains(@class, ' topic/example ')]">
            <report test="count(*[contains(@class, ' topic/title ')]) &gt; 1" role="warning" 
                sqf:fix="deletTitles convertTitles" >
                <name/>
                should only contain one title element.</report>
            
            <sqf:fix id="deletTitles" role="delete">
                <sqf:description>
                    <sqf:title>Delete other title elements</sqf:title>
                </sqf:description>
                <sqf:delete match="*[contains(@class, ' topic/title ')][position() > 1]"/>
            </sqf:fix>
            
            <sqf:fix id="convertTitles">
                <sqf:description>
                    <sqf:title>Convert other titles to text</sqf:title>
                </sqf:description>
                <sqf:replace match="*[contains(@class, ' topic/title ')][position() > 1]" select="child::node()"/>
            </sqf:fix>
        </rule>
    </pattern>
    
    <!-- Fix format attribute for HTML and PDF references -->
    <!--<pattern id="check_format_attribute">
        <rule context="xref[ends-with(lower-case(@href), '.html')]">
            <assert test="@format = 'html'" role="warning" sqf:fix="addFormatHTMLScopeExternal"
                diagnostics="showFormatAndScope"> For HTML references the format attribute needs to
                be set to "html" and the scope attribute should not be "local"! </assert>
            <sqf:fix id="addFormatHTMLScopeExternal">
                <sqf:description>
                    <sqf:title>Fix reference by updating format and scope attributes</sqf:title>
                </sqf:description>
                <sqf:add node-type="attribute" target="format" select="'html'"/>
                <sqf:add use-when="not(@scope) or @scope='local'" node-type="attribute" target="scope" select="'external'"/>
            </sqf:fix>
            
        </rule>
        <rule context="xref[ends-with(lower-case(@href), '.pdf')]">
            <assert test="@format = 'pdf'" role="warning" sqf:fix="addFormatPDFScopeExternal"
                diagnostics="showFormatAndScope"> For PDF references the format attribute needs to
                be set to "pdf" and the scope attribute should not be "local"</assert>
            <sqf:fix id="addFormatPDFScopeExternal">
                <sqf:description>
                    <sqf:title>Fix reference by updating format and scope attributes</sqf:title>
                </sqf:description>
                <sqf:add node-type="attribute" target="format" select="'pdf'"/>
                <sqf:add use-when="not(@scope) or @scope='local'" node-type="attribute" target="scope" select="'external'"/>
            </sqf:fix>
        </rule>
    </pattern>-->
    
    <!-- Check that the number of coordinates matches the selected shape -->
    <pattern id="check_area_coordinates">
        <rule context="area[shape]">
            <let name="nCoordinates" value="count(tokenize(coords, ','))"/>
            <report test="shape = 'rect' and $nCoordinates != 4" sqf:fix="replaceWithCircle"> The
                number of coordinates for a rectangle should be 4. They specify the coordinates of
                two points that define the rectangle. </report>
            <report test="shape = 'circle' and $nCoordinates != 3" sqf:fix="replaceWithRect"> The
                number of coordinates for a circle should be 3. They specify the coordinates of one
                point that define the center and the circle radius. </report>
            <report test="shape = 'poly' and $nCoordinates mod 2 = 1"> The number of coordinates for
                a polygon should be even. They specify the coordinates of the points that define the
                polygon. </report>
            <report test="shape = 'poly' and $nCoordinates &lt; 6"
                sqf:fix="replaceWithRect replaceWithCircle" role="warn"> The number of coordinates
                for a polygon should be at least 6. They specify the coordinates of the points that
                define the polygon and we need to have at least 3 point. </report>
            <report test="shape = 'default' and $nCoordinates > 0" role="error"
                sqf:fix="removeCoordinates replaceWithRect replaceWithCircle">The default shape
                means the entire diagram, so we should have no coordinates.</report>
            <sqf:fix id="removeCoordinates">
                <sqf:description>
                    <sqf:title>Remove the specified coordinates</sqf:title>
                </sqf:description>
                <sqf:delete match="coords/node()"/>
            </sqf:fix>
            <sqf:fix id="replaceWithRect" use-when="$nCoordinates = 4">
                <sqf:description>
                    <sqf:title>Set shape to "rect"</sqf:title>
                    <sqf:p>You have 4 coordinates - if they represent the two points that define a
                        rectangle then the shape should be set to 'rect'!</sqf:p>
                </sqf:description>
                <sqf:delete match="shape/node()"/>
                <sqf:add match="shape" select="'rect'"/>
            </sqf:fix>
            <sqf:fix id="replaceWithCircle" use-when="$nCoordinates = 3">
                <sqf:description>
                    <sqf:title>Set shape to "circle"</sqf:title>
                    <sqf:p>You have 3 coordinates - if they represent the center point and the
                        radius of a circle then the shape should be circle!</sqf:p>
                </sqf:description>
                <sqf:delete match="shape/node()"/>
                <sqf:add match="shape" select="'circle'"/>
            </sqf:fix>

        </rule>
    </pattern>
    <!-- Show warnings when markup is used inside shape or coords -->
    <pattern id="checkMarkupInsideShapeAndCoordinates">
        <rule context="shape/*">
            <report test="true()" role="warn" sqf:fix="removeMarkup"> Shape should not contain
                additional elements, only one of the values: "default", "circle", "rect" or "poly". </report>
            <sqf:fix id="removeMarkup">
                <sqf:description>
                    <sqf:title>Remove markup keeping the text content</sqf:title>
                </sqf:description>
                <sqf:replace match="." select="node()"/>
            </sqf:fix>
        </rule>
        <rule context="coords/*">
            <report test="true()" role="warn" sqf:fix="removeMarkup"> Coordinates should not contain
                additional elements, only numbers separated by comma. </report>
            <sqf:fix id="removeMarkup">
                <sqf:description>
                    <sqf:title>Remove markup keeping the text content</sqf:title>
                </sqf:description>
                <sqf:replace match="." select="node()"/>
            </sqf:fix>
        </rule>
    </pattern>
    <!-- Show warning if other values than the supported ones are used for shape -->
    <pattern id="checkShapeValues">
        <rule context="shape">
            <let name="nCoordinates" value="count(tokenize(following-sibling::coords, ','))"/>
            <assert test=". = ('default', 'circle', 'rect', 'poly')" role="warn"
                sqf:fix="replaceWithDefault replaceWithCircle replaceWithRect replaceWithPoly"> The
                only supported values for shape are 'default', 'circle', 'rect' and 'poly'.
            </assert>
            <sqf:fix id="replaceWithDefault" use-when="$nCoordinates = 0">
                <sqf:description>
                    <sqf:title>Set shape to "default"</sqf:title>
                    <sqf:p>You have no coordinates - if your intention is to provide a default link
                        for the entire image then the shape should be set to 'default'!</sqf:p>                    
                </sqf:description>
                <sqf:delete match="./node()"/>
                <sqf:add match="." select="'default'"/>
            </sqf:fix>
            <sqf:fix id="replaceWithCircle" use-when="$nCoordinates = 3">
                <sqf:description>
                    <sqf:title>Set shape to "circle"</sqf:title>
                    <sqf:p>You have 3 coordinates - if they represent the center point and the
                        radius of a circle then the shape should be circle!</sqf:p>
                </sqf:description>
                <sqf:delete match="./node()"/>
                <sqf:add match="." select="'circle'"/>
            </sqf:fix>
            <sqf:fix id="replaceWithRect" use-when="$nCoordinates = 4">
                <sqf:description>
                    <sqf:title>Set shape to "rect"</sqf:title>
                    <sqf:p>You have 4 coordinates - if they represent the two points that define a
                        rectangle then the shape should be set to 'rect'!</sqf:p>
                </sqf:description>
                <sqf:delete match="./node()"/>
                <sqf:add match="." select="'rect'"/>
            </sqf:fix>
            <sqf:fix id="replaceWithPoly" use-when="$nCoordinates > 4">
                <sqf:description>
                    <sqf:title>Set shape to "poly"</sqf:title>
                    <sqf:p>You have more than 4 coordinates - if they defines a polygon then the
                        shape should be set to "poly"!</sqf:p>
                </sqf:description>
                <sqf:delete match="./node()"/>
                <sqf:add match="." select="'poly'"/>
            </sqf:fix>
        </rule>
    </pattern>
    
    <diagnostics>
        <diagnostic id="external_scope_attribute">Use the scope="external" attribute to indicate
            external links.</diagnostic>
        <diagnostic id="navtitle_element">Preferred way to specify navigation title is navtitle
            element.</diagnostic>
        <diagnostic id="state_element">The state element should be used instead with value attribute
            of "yes" or "no".</diagnostic>
        <diagnostic id="alt_element">The alt element should be used instead.</diagnostic>
        <diagnostic id="link_target">Elements with titles are candidate targets for elements level
            links.</diagnostic>
        <diagnostic id="title_links">Using <value-of
                select="name(descendant::*[contains(@class, ' topic/xref ')])"/> in this context is
            ill-adviced because titles in themselves are often used as links, e.g., in table of
            contents and cross-references.</diagnostic>
        <diagnostic id="showFormatAndScope">
            You have 
            <value-of
                select="
                if (@format) then
                concat('''', @format, '''', ' set for the format attribute')
                else
                'no format attribute'"
            /> and <value-of
                select="
                if (@scope) then
                concat('''', @scope, '''', ' set for the scope attribute')
                else
                'no scope attribute'"
            />.
        </diagnostic>
    </diagnostics>
</schema>
