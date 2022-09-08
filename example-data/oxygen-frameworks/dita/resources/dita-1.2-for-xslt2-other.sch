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
-->
<schema xmlns="http://purl.oclc.org/dsdl/schematron" 
    queryBinding="xslt2" xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    <title>Schematron schema for DITA 1.2</title>
    <p>Version 3.0.0 released 2010-10-17.</p>
    <ns uri="http://dita.oasis-open.org/architecture/2005/" prefix="ditaarch"/>
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
    <pattern id="boolean"
        >
        <rule context="*[contains(@class, ' topic/boolean ')]">
            <report test="true()" diagnostics="state_element"
                role="warning">The <value-of select="name(.)"/>
                element is deprecated.</report>
        </rule>
    </pattern>
    <pattern id="image_alt_attr"
        >
        <rule context="*[contains(@class, ' topic/image ')]">
            <report test="@alt" diagnostics="alt_element" role="warning" sqf:fix="addAltElem removeAlternate">The use of the alt attribute is deprecated.</report>
            <sqf:fix id="addAltElem">
                <sqf:description>
                    <sqf:title>Replace @alt attribute with alt element</sqf:title>
                    <sqf:p>Replace the @alt attribute with the alt element and set the value from the @alt attribute in the element.</sqf:p>
                </sqf:description>
                <sqf:add node-type="element" target="alt" select="@alt/string()"/>
                <sqf:delete match="@alt"/>
            </sqf:fix>
            <sqf:fix id="removeAlternate">
                <sqf:description>
                    <sqf:title>Remove the @alt attribute</sqf:title>
                    <sqf:p>Remove the @alt attribute from the element.</sqf:p>
                </sqf:description>
                <sqf:delete match="@alt"/>
            </sqf:fix>
        </rule>
    </pattern>
    <pattern id="query_attr"
        >
        <rule context="*[contains(@class, ' topic/link ')] | *[contains(@class, ' map/topicref ')]">
            <report test="@query" role="warning" sqf:fix="removeAttr">The query attribute is deprecated. It may be
                removed in the future.</report>
            
            <sqf:fix id="removeAttr">
                <sqf:description>
                    <sqf:title>Remove the @query attribute</sqf:title>
                    <sqf:p>Remove the deprecated @query attribute from the element.</sqf:p>
                </sqf:description>
                <sqf:delete match="@query"/>
            </sqf:fix>
        </rule>
    </pattern>
    <pattern id="role_attr_value"
        >
        <rule
            context="*[contains(@class, ' topic/related-links ')] | *[contains(@class, ' topic/link ')] | *[contains(@class, ' topic/linklist ')] | *[contains(@class, ' topic/linkpool ')]">
            <report test="@role[. = 'sample']" role="warning">The value "sample" for role attribute
                is deprecated.</report>
            <report test="@role[. = 'external']" diagnostics="external_scope_attribute"
                role="warning">The value "external" for role attribute is deprecated.</report>
        </rule>
    </pattern>
    <pattern id="single_paragraph"
        >
        <rule context="*[contains(@class, ' topic/topic ')]"
            subject="*[contains(@class, ' topic/body ')]/*[contains(@class, ' topic/p ')]">
            <!-- EXM-30485 Do not present warning when paragraph contains child elements -->
            <report
                test="not(*[contains(@class, ' topic/shortdesc ')] | *[contains(@class, ' topic/abstract ')]) 
                           and count(*[contains(@class, ' topic/body ')]/*) = 1 
                           and *[contains(@class, ' topic/body ')]/*[contains(@class, ' topic/p ')]
                           and count(*[contains(@class, ' topic/body ')]/*[contains(@class, ' topic/p ')]/*) = 0"
                role="warning" sqf:fix="createShortDesc">In cases where a topic contains only one paragraph, then it is
                preferable to include this text in the shortdesc element and leave the topic body
                empty.</report>
            <sqf:fix id="createShortDesc">
                <sqf:description>
                    <sqf:title>Move text in a shortdesc element</sqf:title>
                    <sqf:p>Create a shortdesc element with the current paragraph text. And remove the topic body.</sqf:p>
                </sqf:description>
                <sqf:add match="*[contains(@class, ' topic/body ')]" target="shortdesc" node-type="element" position="before" 
                    select="*[contains(@class, ' topic/p ')]/text()"/>
                <sqf:delete match="*[contains(@class, ' topic/body ')]"/>
            </sqf:fix>
        </rule>
    </pattern>
    <pattern id="shortdesc_length"
        >
        <rule context="*[contains(@class, ' topic/shortdesc ')]">
            <let name="text" value="normalize-space(.)"/>
            <let name="text2" value="translate($text, ' ', '')"/>
            <report test="string-length($text) - string-length(translate($text, ' ', '')) &gt;= 50"
                role="warning" sqf:fix="cutDescription">The short description should be a single, concise paragraph
                containing one or two sentences of no more than 50 words.</report>
            
            <sqf:fix id="cutDescription">
                <sqf:description>
                    <sqf:title>Cut the description after the 50th word</sqf:title>
                </sqf:description>
               <!-- <let name="sub" value="tokenize(text(), '\s+')"/>
                <let name="index" value="subse(1 + string-length(substring-before($text, ' ') + string-length($searchString))"/>
                <sqf:stringReplace regex="(.+)" match="text()" select="substring(.,1,$index)"/>-->
            </sqf:fix>
        </rule>
    </pattern>
<!-- EXM-19131 REMOVED   <pattern id="navtitle">
        <rule context="*[contains(@class, ' map/topicref ')]">
            <report test="@navtitle" diagnostics="navtitle_element" role="warning">The navtitle
                attribute is deprecated.</report>
        </rule>
    </pattern>-->
<!-- EXM-19131 REMOVED   <pattern id="map_title_attribute">
        <rule context="*[contains(@class, ' map/map ')]">
            <report test="@title" role="warning">Map can include a title element, which is preferred
                over the title attribute</report>
        </rule>
    </pattern>-->
    <pattern is-a="self_nested_element" id="self_nested_xref"
        >
        <param name="element" value="*[contains(@class, ' topic/xref ')]"/>
    </pattern>
    <pattern id="pre_content" 
        >
        <rule context="*[contains(@class, ' topic/pre ')]">
            <report test="descendant::*[contains(@class, ' topic/image ')]" role="warning">The
                <name/> contains <value-of
                    select="name(descendant::*[contains(@class, ' topic/image ')])"/>. Using
                    <value-of select="name(descendant::*[contains(@class, ' topic/image ')])"/> in
                this context is ill-adviced.</report>
            <report test="descendant::*[contains(@class, ' topic/object ')]" role="warning">The
                <name/> contains <value-of
                    select="name(descendant::*[contains(@class, ' topic/object ')])"/>. Using
                    <value-of select="name(descendant::*[contains(@class, ' topic/object ')])"/> in
                this context is ill-adviced.</report>
            <report test="descendant::*[contains(@class, ' hi-d/sup ')]" role="warning">The <name/>
                contains <value-of select="name(descendant::*[contains(@class, ' hi-d/sup ')])"/>.
                Using <value-of select="name(descendant::*[contains(@class, ' hi-d/sup ')])"/> in
                this context is ill-adviced.</report>
            <report test="descendant::*[contains(@class, ' hi-d/sub ')]" role="warning">The <name/>
                contains <value-of select="name(descendant::*[contains(@class, ' hi-d/sub ')])"/>.
                Using <value-of select="name(descendant::*[contains(@class, ' hi-d/sub ')])"/> in
                this context is ill-adviced.</report>
        </rule>
    </pattern>
    <pattern id="abstract_shortdesc">
        <!-- EXM-30485 Do not report this warning for a glossentry -->
        <rule context="*[contains(@class, ' topic/abstract ') and not(contains(@class, ' glossentry/glossdef '))]">
            <assert test="*[contains(@class, ' topic/shortdesc ')]" role="warning">Abstract should
                contain at least one shortdesc element.</assert>
        </rule>
    </pattern>
    <pattern id="xref_in_title">
        <rule context="*[contains(@class, ' topic/title ')]">
            <report test="descendant::*[contains(@class, ' topic/xref ')]" diagnostics="title_links"
                role="warning" sqf:fix="removeLink">The <name/> contains <name
                    path="(descendant::*[contains(@class, ' topic/xref ')])[1]"/>.</report>
            
            <sqf:fix id="removeLink">
                <sqf:description>
                    <sqf:title>Remove links from title</sqf:title>
                    <sqf:p>Remove the links from the title but keep the links content.</sqf:p>
                </sqf:description>
                <sqf:replace match="descendant::*[contains(@class, ' topic/xref ')]" select="child::node()"/>
            </sqf:fix>
        </rule>
    </pattern>
<!-- EXM-19131 REMOVED   <pattern id="idless_title">
        <rule context="*[not(@id)]">
            <report test="*[contains(@class, ' topic/title ')]" diagnostics="link_target"
                role="warning"><name/> with a title should have an id attribute.</report>
        </rule>
    </pattern>-->
    <pattern id="required-cleanup">
        <rule context="*">
            <report test="*[contains(@class, ' topic/required-cleanup ')]" role="warning" sqf:fix="removeElement">A
                required-cleanup element is used as a placeholder for migrated elements and should
                not be used in documents by authors.</report>
            <sqf:fix id="removeElement">
                <sqf:description>
                    <sqf:title>Delete the required-cleanup elements</sqf:title>
                </sqf:description>
                <sqf:delete match="*[contains(@class, ' topic/required-cleanup ')]"/>
            </sqf:fix>
        </rule>
    </pattern>
    <pattern id="no_topic_nesting">
        <rule context="no-topic-nesting">
            <report test="." role="warning"><name/> element is not intended for direct use by
                authors, and has no associated output processing.</report>
        </rule>
    </pattern>
    <pattern id="tm_character"
        >
        <rule context="text()">
            <report test="contains(., '™')" role="warning" sqf:fix="replaceTM">It's preferable to use tm element instead
                of ™ character.</report>
            <report test="contains(., '℠')" role="warning" sqf:fix="replaceSM">It's preferable to use tm element instead
                of ℠ character.</report>
            <report test="contains(., '®')" role="warning" sqf:fix="replaceR">It's preferable to use tm element instead
                of ® character.</report>
            
            <sqf:fix id="replaceTM">
                <sqf:description>
                    <sqf:title>Replace ™ character with tm element</sqf:title>
                    <sqf:p>Replace ™ character with tm element with the value of the @tmtype attribute set to "tm".</sqf:p>
                </sqf:description>
                <sqf:stringReplace regex="™"><tm xmlns="" tmtype="tm"/></sqf:stringReplace>
            </sqf:fix>
            
            <sqf:fix id="replaceSM">
                <sqf:description>
                    <sqf:title>Replace ℠ character with tm element</sqf:title>
                    <sqf:p>Replace ℠ character with tm element with the value of the @tmtype attribute set to "service".</sqf:p>
                </sqf:description>
                <sqf:stringReplace regex="℠"><tm xmlns="" tmtype="service"/></sqf:stringReplace>
            </sqf:fix>
            
            <sqf:fix id="replaceR">
                <sqf:description>
                    <sqf:title>Replace ® character with tm element</sqf:title>
                    <sqf:p>Replace ® character with tm element with the value of the @tmtype attribute set to "reg".</sqf:p>
                </sqf:description>
                <sqf:stringReplace regex="®"><tm xmlns="" tmtype="reg"/></sqf:stringReplace>
            </sqf:fix>
        </rule>
    </pattern>
    
    <!-- EXM-29876 Avoid reporting this at all -->
    <!--<pattern id="no_alt_desc"
        >
        <!-\- EXM-28035 Avoid reporting warnings when the image has a @conref or @conkeyref, the attribute might be on the target. -\->
        <rule context="*[contains(@class, ' topic/image ')][not(@conref)][not(@conkeyref)]">
            <assert test="@alt | alt" flag="non-WAI" role="warning">Alternative description should
                be provided for users using screen readers or text-only readers.</assert>
        </rule>
        <rule context="*[contains(@class, ' topic/object ')]">
            <assert test="desc" flag="non-WAI" role="warning">Alternative description should be
                provided for users using screen readers or text-only readers.</assert>
        </rule>
    </pattern>-->
    <diagnostics>
        <diagnostic id="external_scope_attribute">Use the scope="external" attribute to indicate
            external links.</diagnostic>
        <diagnostic id="navtitle_element">Preferred way to specify navigation title is navtitle
            element.</diagnostic>
        <diagnostic id="state_element">The state element should be used instead with value attribute
            of "yes" or "no".</diagnostic>
        <diagnostic id="alt_element">The alt element is the preferred way of indicating alternative text for an image.</diagnostic>
        <diagnostic id="link_target">Elements with titles are candidate targets for elements level
            links.</diagnostic>
        <diagnostic id="title_links">Using <value-of
                select="name((descendant::*[contains(@class, ' topic/xref ')])[1])"/> in this context is
            ill-advised because titles in themselves are often used as links, e.g., in table of
            contents and cross-references.</diagnostic>
    </diagnostics>
</schema>
