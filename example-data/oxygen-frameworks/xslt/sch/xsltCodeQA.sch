<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns:fn="function.namespace"
    >
    
    <!-- Declare the used namespaces. -->
    <sch:ns uri="http://www.w3.org/1999/XSL/Transform" prefix="xsl"/>
    <sch:ns uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>
    <sch:ns uri="function.namespace" prefix="fn"/>
    
    <xsl:function name="fn:getCandidateName" as="xs:string*">
        <xsl:param name="text"/>
        <xsl:analyze-string select="$text" regex="(^|\s+)(\$[a-zA-Z0-9\-_\.]+)(\s+|$)">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(2)"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <!-- Compute only once the XSLT -->
    <sch:let name="isXSLT30" value="boolean(/node()[
        local-name()='stylesheet' and
        namespace-uri()='http://www.w3.org/1999/XSL/Transform'
        and (@version='3.0' or @version='3.1')])"/>
    
    <sch:pattern>
        <!-- Check the xsl:attribute not to contain variables or parameters in the text part... -->
        <!-- Ex: <xsl:attribute name="margin-right">$page-margin-inside</xsl:attribute> -->
        <sch:rule context="xsl:attribute/text()">
            <!-- Verify if there is text present in the element... -->
            <sch:let name="textContent" value="."/>
            <!-- Get the attribute's name. -->
            <sch:let name="attributeName" value="./parent::node()/@name"/>
            <sch:let name="isSelectPresent" value="boolean(./parent::node()/@select)"/>
            <sch:let name="candidateName" value="fn:getCandidateName(.)"/>
            
            <sch:report test="not($isXSLT30) and boolean($textContent) and not($isSelectPresent)
                and (string-length($candidateName[1]) > 1)"
                sqf:fix="addValueOf" role="warn">
                For attribute '<sch:value-of select="$attributeName"/>',
                the variable/parameter '<sch:value-of select="$candidateName[1]"/>' should be placed
                in an 'xsl:value-of' element. 
            </sch:report>
            
            <sch:report test="$isXSLT30 and boolean($textContent) and not($isSelectPresent)
                and (string-length($candidateName[1]) > 1)"
                sqf:fix="addTVT" role="warn">
                For attribute '<sch:value-of select="$attributeName"/>',
                the variable/parameter '<sch:value-of select="$candidateName[1]"/>' should be placed
                in a 'Text Value Template'. 
            </sch:report>
            
            <sqf:fix id="addValueOf">
                <sqf:description>
                    <sqf:title>Insert 'xsl:value-of' element</sqf:title>
                </sqf:description>
                <sqf:call-fix ref="addValueOfElement">
                    <sqf:with-param name="param" select="$candidateName[1]"/>
                </sqf:call-fix>
            </sqf:fix>
            
            <sqf:fix id="addTVT">
                <sqf:description>
                    <sqf:title>Insert 'Text Value Template'</sqf:title>
                </sqf:description>
                <sqf:call-fix ref="addTextValueTemplate">
                    <sqf:with-param name="param" select="$candidateName[1]"/>
                </sqf:call-fix>
            </sqf:fix>
        </sch:rule>
        
        <!-- Check the xsl:variable not to contain variables or parameters in the text part... -->
        <!-- Ex: <xsl:variable name="margin-right">$page-margin-inside</xsl:variable> -->
        <sch:rule context="xsl:variable/text()">
            <!-- Verify if there is text present in the element... -->
            <sch:let name="textContent" value="."/>
            <!-- Get the variable's name. -->
            <sch:let name="variableName" value="./parent::node()/@name"/>
            <sch:let name="isSelectPresent" value="boolean(./parent::node()/@select)"/>
            <sch:let name="candidateName" value="fn:getCandidateName(.)"/>
            
            <sch:report test="not($isXSLT30) and boolean($textContent) and not($isSelectPresent)
                and (string-length($candidateName[1]) > 1)"
                sqf:fix="addValueOf" role="warn">
                For variable '<sch:value-of select="$variableName"/>',
                the variable/parameter '<sch:value-of select="$candidateName[1]"/>' should be placed
                in an 'xsl:value-of' element. 
            </sch:report>
            
            <sch:report test="$isXSLT30 and boolean($textContent) and not($isSelectPresent)
                and (string-length($candidateName[1]) > 1)"
                sqf:fix="addTVT" role="warn">
                For variable '<sch:value-of select="$variableName"/>',
                the variable/parameter '<sch:value-of select="$candidateName[1]"/>' should be placed
                in a 'Text Value Template'. 
            </sch:report>
            
            <sqf:fix id="addValueOf">
                <sqf:description>
                    <sqf:title>Insert 'xsl:value-of' element</sqf:title>
                </sqf:description>
                <sqf:call-fix ref="addValueOfElement">
                    <sqf:with-param name="param" select="$candidateName[1]"/>
                </sqf:call-fix>
            </sqf:fix>
            
            <sqf:fix id="addTVT">
                <sqf:description>
                    <sqf:title>Insert 'Text Value Template'</sqf:title>
                </sqf:description>
                <sqf:call-fix ref="addTextValueTemplate">
                    <sqf:with-param name="param" select="$candidateName[1]"/>
                </sqf:call-fix>
            </sqf:fix>
        </sch:rule>
        
        <!-- Check the xsl:param not to contain variables or parameters in the text part... -->
        <!-- Ex: <xsl:param name="margin-right">$page-margin-inside</xsl:param> -->
        <sch:rule context="xsl:param/text()">
            <!-- Verify if there is text present in the element... -->
            <sch:let name="textContent" value="."/>
            <!-- Get the attribute's name. -->
            <sch:let name="paramName" value="./parent::node()/@name"/>
            <sch:let name="isSelectPresent" value="boolean(./parent::node()/@select)"/>
            <sch:let name="candidateName" value="fn:getCandidateName(.)"/>
            
            <sch:report test="not($isXSLT30) and boolean($textContent) and not($isSelectPresent)
                and (string-length($candidateName[1]) > 1)"
                sqf:fix="addValueOf" role="warn">
                For parameter '<sch:value-of select="$paramName"/>',
                the variable/parameter '<sch:value-of select="$candidateName[1]"/>' should be placed
                in an 'xsl:value-of' element. 
            </sch:report>
            
            <sch:report test="$isXSLT30 and boolean($textContent) and not($isSelectPresent)
                and (string-length($candidateName[1]) > 1)"
                sqf:fix="addTVT" role="warn">
                For parameter '<sch:value-of select="$paramName"/>',
                the variable/parameter '<sch:value-of select="$candidateName[1]"/>' should be placed
                in a 'Text Value Template'. 
            </sch:report>
            
            <sqf:fix id="addValueOf">
                <sqf:description>
                    <sqf:title>Insert 'xsl:value-of' element</sqf:title>
                </sqf:description>
                <sqf:call-fix ref="addValueOfElement">
                    <sqf:with-param name="param" select="$candidateName[1]"/>
                </sqf:call-fix>
            </sqf:fix>
            
            <sqf:fix id="addTVT">
                <sqf:description>
                    <sqf:title>Insert 'Text Value Template'</sqf:title>
                </sqf:description>
                <sqf:call-fix ref="addTextValueTemplate">
                    <sqf:with-param name="param" select="$candidateName[1]"/>
                </sqf:call-fix>
            </sqf:fix>
        </sch:rule>
    </sch:pattern>
    
    <!-- The QuickFix-es -->
    <sqf:fixes>
        <!-- Add the xsl:value-of element. For xslt 1.0 & 2.0 -->
        <sqf:fix id="addValueOfElement">
            <sqf:param name="param"/>
            <sqf:description>
                <sqf:title>Insert 'xsl:value-of' element</sqf:title>
            </sqf:description>
            
            <sqf:stringReplace regex="{concat('\', $param)}">
                <xsl:element name="xsl:value-of">
                    <xsl:attribute name="select" select="concat('\', $param)"/>
                </xsl:element>
            </sqf:stringReplace>
        </sqf:fix>
        
        <!-- Suround the variable with curly brackets. For xslt 3.0 & 3.1 -->
        <sqf:fix id="addTextValueTemplate">
            <sqf:param name="param"/>
            <sch:let name="expandText" value="ancestor-or-self::node()/@expand-text[1]"/>
            <sqf:description>
                <sqf:title>Insert "<sch:value-of select="$expandText"/>" 'Text Value Template'</sqf:title>
            </sqf:description>
            
            <xsl:variable name="lcb" select="'{'"/>
            <xsl:variable name="rcb" select="'}'"/>
            
            <sqf:stringReplace regex="{concat('\', $param)}" select="concat($lcb, '\', $param, $rcb)"/>
            <sqf:add node-type="attribute" match="parent::node()" target="expand-text" select="'true'"
                use-when="(not(boolean($expandText))) or ($expandText != 'true' and $expandText != 'yes' and $expandText != '1')"/>
        </sqf:fix>
    </sqf:fixes>
</sch:schema>