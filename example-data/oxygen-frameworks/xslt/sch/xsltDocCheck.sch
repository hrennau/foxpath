<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsldoc="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:fn="function.namespace"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    >
    
    <!-- Declare the used namespaces. -->
    <sch:ns uri="http://www.w3.org/1999/XSL/Transform" prefix="xsl"/>
    <sch:ns uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>
    <sch:ns uri="http://www.oxygenxml.com/ns/doc/xsl" prefix="xsldoc"/>
    <sch:ns uri="function.namespace" prefix="fn"/>
    
    <!-- Get some strings depending on the specified parameters. -->
    <xsl:function name="fn:getParams" as="xs:string">
        <xsl:param name="paramsList"/>
        <xsl:choose>
            <xsl:when test="count($paramsList) = 1">
                <!-- Single parameter case. -->
                parameter is
            </xsl:when>
            <xsl:otherwise>
                <!-- Multiple parameters. -->
                parameters are
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Get the current template string representation -->
    <xsl:function name="fn:getCurrentTemplate" as="xs:string*">
        <xsl:param name="templateName"/>
        <xsl:param name="templateMatch"/>
        <xsl:param name="templateMode"/>
        
        <xsl:if test="boolean($templateName)">
            <xsl:value-of select="concat('name &quot;',$templateName, '&quot;')"/>
        </xsl:if>
        <xsl:if test="boolean($templateMatch)">
            <xsl:if test="boolean($templateName)">,<xsl:text> </xsl:text></xsl:if>
            <xsl:value-of select="concat('match &quot;',$templateMatch, '&quot;')"/>
        </xsl:if>
        <xsl:if test="boolean($templateMode)">
            <xsl:if test="boolean($templateName) or boolean($templateMatch)">,<xsl:text> </xsl:text></xsl:if>
            <xsl:value-of select="concat('mode &quot;',$templateMode, '&quot;')"/>
        </xsl:if>
    </xsl:function>
    
    <!-- The main condition for presenting warnings on the templates or functions -->
    <xsl:function name="fn:paramsAreDeclared" as="xs:boolean">
        <xsl:param name="params2Check"/>
        <xsl:param name="docElement"/>
        <xsl:param name="docParams"/>
        <xsl:param name="equalParams"/>
        <xsl:value-of select="
            if (boolean($params2Check) and boolean($docElement))
            then
                if ($docParams)
                then
                    if (count($params2Check) = count($docParams))
                    then
                        if (count($params2Check) = count($equalParams))
                        then
                            true()
                        else
                            false()
                    else
                        false()
                else
                    false()
            else
                true()
            "/>
    </xsl:function>
    <!-- Check if the documentation is present inthe document. -->
    <sch:let name="isDocPresent" value="boolean(//xsldoc:doc)"/>
    <!-- Check the templates and functions for proper documented parameters. -->
    <sch:pattern>
        <sch:rule context="xsl:template[boolean($isDocPresent)]">
            <!-- Verify if the documentation is present in the entire document. -->
            <!-- Find the documentation element. -->
            <sch:let name="docElement" value="preceding-sibling::*[1][self::xsldoc:doc]"/>
            <!-- Find the comment... -->
            <sch:let
                name="docComment"
                value="preceding-sibling::node()[not(self::text())][1][self::comment()]"/>
            <!-- Identify the template through name, match, mode... -->
            <sch:let name="templateName" value="@name"/>
            <sch:let name="templateMatch" value="@match"/>
            <sch:let name="templateMode" value="@mode"/>
            
            <!-- Get the template parameters. -->
            <sch:let name="templateParams" value="xsl:param/@name"/>
            <!-- Get the documented parameters. -->
            <sch:let name="docParams" value="$docElement/xsldoc:param/@name"/>
            <!-- Keep a list with the parametars that are in both lists. -->
            <sch:let name="equalParams" value="$templateParams[.=$docParams]"/>
            <!-- Keep a list with the missing parameters from the template declaration. -->
            <sch:let name="missingTemplateParams" value="$templateParams[not(.=$docParams)]"/>
            <!-- Keep a list with the missing parameters from the documentation. -->
            <sch:let name="missingDocParams" value="$docParams[not(.=$templateParams)]"/>
            <!-- The main condition that activates the reporting. -->
            <sch:let name="allOK" value="fn:paramsAreDeclared($templateParams, $docElement, $docParams, $equalParams)"/>
            
            <!-- Report the not documented template parameters -->
            <sch:report test="not($docComment) and not($allOK) and boolean($missingTemplateParams)" role="warn" sqf:fix="addParamsDocumentation addParamsDocumentation2AllTemplates">
                The following <sch:value-of select="fn:getParams($missingTemplateParams)"/> not documented for
                the template with 
                <sch:value-of select="fn:getCurrentTemplate($templateName, $templateMatch, $templateMode)"/>:
                [<sch:value-of select="$missingTemplateParams"/>].
            </sch:report>
            
            <!-- Add missing documentation for the parameters list passed as argument.-->
            <sqf:fix id="addParamsDocumentation">
                <sqf:description>
                    <sqf:title>Add documentation for parameter(s)</sqf:title>
                </sqf:description>
                <sqf:call-fix ref="addParameterDocumentation">
                    <sqf:with-param name="params" select="$missingTemplateParams"/>
                    <sqf:with-param name="docElement" select="$docElement"/>
                </sqf:call-fix>
            </sqf:fix>
            
            <sqf:fix id="addParamsDocumentation2AllTemplates">
                <sqf:description>
                    <sqf:title>Add documentation for parameter(s) in the whole document</sqf:title>
                </sqf:description>
                
                <!-- The current docs -->
                <sch:let name="theDocs" value="//xsldoc:doc[following-sibling::*[1][self::xsl:template]]"/>
                <!-- Add doc where required. -->
                <sqf:add match="$theDocs" position="last-child">
                    <!-- Find the documentation element. -->
                    <sch:let name="docElement" value="current()"/>
                    <sch:let name="template" value="$docElement/following-sibling::*[1][self::xsl:template]"/>
                    
                    <!-- Get the template parameters. -->
                    <sch:let name="templateParams" value="$template/xsl:param/@name"/>
                    <!-- Get the documented parameters. -->
                    <sch:let name="docParams" value="$docElement/xsldoc:param/@name"/>
                    <!-- Keep a list with the missing parameters from the documentation. -->
                    <sch:let name="missingParams" value="$templateParams[not(.=$docParams)]"/>
                    
                    <xsl:if test="boolean($missingParams)">
                        <xsl:for-each select="$missingParams">
                            <xsldoc:param name="{current()}"></xsldoc:param>
                            <xsl:text>
                            </xsl:text>
                        </xsl:for-each>
                    </xsl:if>
                    
                </sqf:add>
            </sqf:fix>
            
            <!-- Report the parameters that are documented but not present in the template. -->
            <sch:report test="not($docComment) and not($allOK) and boolean($missingDocParams)" role="warn" sqf:fix="addParams deleteParameterDoc">
                The template with 
                <sch:value-of select="fn:getCurrentTemplate($templateName, $templateMatch, $templateMode)"/>
                is missing the following parameter(s): [<sch:value-of select="$missingDocParams"/>].
            </sch:report>
            
            <sqf:fix id="addParams">
                <sqf:description>
                    <sqf:title>Add missing parameter(s)</sqf:title>
                </sqf:description>
                <sqf:call-fix ref="addParameterDeclaration">
                    <sqf:with-param name="params" select="$missingDocParams"/>
                    <sqf:with-param name="element" select="."/>
                </sqf:call-fix>
            </sqf:fix>
            
            <sqf:fix id="deleteParameterDoc">
                <sqf:description>
                    <sqf:title>Delete unbound documentation parameter(s)</sqf:title>
                </sqf:description>
                <sqf:call-fix ref="deleteParameterDocumentation">
                    <sqf:with-param name="params" select="$missingDocParams"/>
                    <sqf:with-param name="docElement" select="$docElement"/>
                </sqf:call-fix>
            </sqf:fix>
            
            <!-- If the template does not have a "doc" issue an warning. -->
            <sch:report test="not($docComment) and not($docElement)" role="warn" sqf:fix="addTemplateDocElement addDoc2AllTemplates">
                <!--There is no documentation for the current template.-->
                There is no documentation for the template with 
                <sch:value-of select="fn:getCurrentTemplate($templateName, $templateMatch, $templateMode)"/>.
            </sch:report>
            
            <!-- If the template does not have a "doc" but have a comment issue an warning.
                 And use the comment's body as description for the inserted "doc" element.-->
            <sch:report test="$docComment and not($docElement)" role="warn" sqf:fix="addTemplateDocElement addDoc2AllTemplates">
                <!--There is no documentation for the current template... But there is a comment...-->
                There is no documentation for the template with 
                <sch:value-of select="fn:getCurrentTemplate($templateName, $templateMatch, $templateMode)"/>.
                The preceeding comment might be used.
            </sch:report>

            <!-- Add the documentation for the curent template -->
            <sqf:fix id="addTemplateDocElement">
                <sqf:description>
                    <sqf:title>Add documentation to current template</sqf:title>
                </sqf:description>
                
                <sqf:add position="before">
                    <xsldoc:doc><xsl:text>
                    </xsl:text>
                        <xsldoc:desc><xsl:if test="$docComment">
                            <xsl:value-of select="$docComment"/>
                        </xsl:if></xsldoc:desc><xsl:text>
                        </xsl:text>
                        <xsl:if test="$templateParams">
                            <xsl:for-each select="$templateParams">
                                <xsldoc:param name="{current()}"></xsldoc:param>
                                <xsl:text>
                                </xsl:text>
                            </xsl:for-each>
                        </xsl:if>
                    </xsldoc:doc><xsl:text>
                    </xsl:text>
                </sqf:add>
                <sqf:delete match="$docComment" use-when="$docComment"/>
            </sqf:fix>
            
            <!-- Add missing documentation for all the templates. -->
            <sqf:fix id="addDoc2AllTemplates">
                <sqf:description>
                    <sqf:title>Add documentation to all templates</sqf:title>
                </sqf:description>
                
                <!-- The current templates -->
                <sch:let name="theTemplates" value="//xsl:template[not(preceding-sibling::*[1][self::xsldoc:doc])]"/>
                <!-- Add doc where required. -->
                <sqf:add match="$theTemplates" position="before">
                    <!-- The template's doc comment. -->
                    <sch:let name="templateDocComment" value="preceding-sibling::node()[not(self::text())][1][self::comment()]"/>
                
                    <!-- Get the template parameters. -->
                    <sch:let name="templatesParams" value="xsl:param/@name"/>
                    <xsldoc:doc><xsl:text>
                    </xsl:text>
                        <xsldoc:desc><xsl:if test="$templateDocComment">
                            <xsl:value-of select="$templateDocComment"/>
                        </xsl:if></xsldoc:desc><xsl:text>
                        </xsl:text>
                        <xsl:if test="$templatesParams">
                            <xsl:for-each select="$templatesParams">
                                <xsldoc:param name="{current()}"></xsldoc:param>
                                <xsl:text>
                                </xsl:text>
                            </xsl:for-each>
                        </xsl:if>
                    </xsldoc:doc><xsl:text>
                    </xsl:text>
                </sqf:add>
                <!-- Delete comments after doc generation -->
                <sqf:delete match="$theTemplates/preceding-sibling::node()[not(self::text())][1][self::comment()]"/>
            </sqf:fix>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern>
        <!-- Check the function for documentation. -->
        <sch:rule context="xsl:function[boolean($isDocPresent)]">
            <!-- Verify if the documentation is present in the entire document. -->
            <!-- Get the function's name. -->
            <sch:let name="functionName" value="@name"/>
            <!-- Get the function element. -->
            <sch:let name="function" value="."/>
            
            
            <!-- Find the documentation element. -->
            <sch:let name="docElement" value="preceding-sibling::*[1][self::xsldoc:doc]"/>
            <!-- Find the comment... -->
            <sch:let
                name="docComment"
                value="preceding-sibling::node()[not(self::text())][1][self::comment()]"/>
            <!-- Get the function parameters. -->
            <sch:let name="functionParams" value="xsl:param/@name"/>
            <!-- Get the documented parameters. -->
            <sch:let name="docParams" value="$docElement/xsldoc:param/@name"/>
            <!-- Keep a list with the parametars that are in both lists. -->
            <sch:let name="equalParams" value="$functionParams[.=$docParams]"/>
            <!-- Keep a list with the missing parameters from the template declaration. -->
            <sch:let name="missingFunctionParams" value="$functionParams[not(.=$docParams)]"/>
            <!-- Keep a list with the missing parameters from the documentation. -->
            <sch:let name="missingDocParams" value="$docParams[not(.=$functionParams)]"/>
            <!-- The main condition that activates the reporting. -->
            <sch:let name="allOK" value="fn:paramsAreDeclared($functionParams, $docElement, $docParams, $equalParams)"/>
            <!-- Report the not documented template parameters -->
            <sch:report test="not($allOK) and boolean($missingFunctionParams)" role="warn" sqf:fix="addParamsDocumentation addParamsDocumentation2AllFunctions">
                The following <sch:value-of select="fn:getParams($missingFunctionParams)"/> not documented for
                the function with name "<sch:value-of select="$functionName"/>": [<sch:value-of select="$missingFunctionParams"/>].
            </sch:report>
            
            <!-- Add missing documentation for the parameters list passed as argument.-->
            <sqf:fix id="addParamsDocumentation">
                <sqf:description>
                    <sqf:title>Add documentation for parameter(s)</sqf:title>
                </sqf:description>
                <sqf:call-fix ref="addParameterDocumentation">
                    <sqf:with-param name="params" select="$missingFunctionParams"/>
                    <sqf:with-param name="docElement" select="$docElement"/>
                </sqf:call-fix>
            </sqf:fix>
            
            <sqf:fix id="addParamsDocumentation2AllFunctions">
                <sqf:description>
                    <sqf:title>Add documentation for parameter(s) in the whole document</sqf:title>
                </sqf:description>
                
                <!-- The current docs -->
                <sch:let name="theDocs" value="//xsldoc:doc[following-sibling::*[1][self::xsl:function]]"/>
                <!-- Add doc where required. -->
                <sqf:add match="$theDocs" position="last-child">
                    <!-- Find the documentation element. -->
                    <sch:let name="docElement" value="current()"/>
                    <sch:let name="function" value="$docElement/following-sibling::*[1][self::xsl:function]"/>
                    
                    <!-- Get the function parameters. -->
                    <sch:let name="functionParams" value="$function/xsl:param/@name"/>
                    <!-- Get the documented parameters. -->
                    <sch:let name="docParams" value="$docElement/xsldoc:param/@name"/>
                    <!-- Keep a list with the missing parameters from the documentation. -->
                    <sch:let name="missingParams" value="$functionParams[not(.=$docParams)]"/>
                    
                    <xsl:if test="boolean($missingParams)">
                        <xsl:for-each select="$missingParams">
                            <xsldoc:param name="{current()}"></xsldoc:param>
                            <xsl:text>
                            </xsl:text>
                        </xsl:for-each>
                    </xsl:if>
                    
                </sqf:add>
            </sqf:fix>
             
            <!-- Report the parameters that are documented but not present in the template. -->
            <sch:report test="not($allOK) and boolean($missingDocParams)" role="warn" sqf:fix="addParams deleteParameterDoc">
                The function with name "<sch:value-of select="$functionName"/>" is missing the following parameter(s): [<sch:value-of select="$missingDocParams"/>].
            </sch:report>
            
            <sqf:fix id="addParams">
                <sqf:description>
                    <sqf:title>Add missing parameter(s)</sqf:title>
                </sqf:description>
                <sqf:call-fix ref="addParameterDeclaration">
                    <sqf:with-param name="params" select="$missingDocParams"/>
                    <sqf:with-param name="element" select="."/>
                </sqf:call-fix>
            </sqf:fix>
            
            <sqf:fix id="deleteParameterDoc">
                <sqf:description>
                    <sqf:title>Delete unbound documentation parameter(s)</sqf:title>
                </sqf:description>
                <sqf:call-fix ref="deleteParameterDocumentation">
                    <sqf:with-param name="params" select="$missingDocParams"/>
                    <sqf:with-param name="docElement" select="$docElement"/>
                </sqf:call-fix>
            </sqf:fix>
            
            <!-- If the template does not have a "doc" issue an warning. -->
            <sch:report test="not($docComment) and not($docElement)" role="warn" sqf:fix="addFunctionDocElement addDoc2AllFunctions">
                There is no documentation for the function with name "<sch:value-of select="$functionName"/>".
            </sch:report>
            
            <!-- If the template does not have a "doc" but have a comment issue an warning.
                 And use the comment's body as description for the inserted "doc" element.-->
            <sch:report test="$docComment and not($docElement)" role="warn" sqf:fix="addFunctionDocElement addDoc2AllFunctions">
                <!--There is no documentation for the current template... But there is a comment...-->
                There is no documentation for the function with name "<sch:value-of select="$functionName"/>".
                The preceeding comment might be used.
            </sch:report>
            
            <!-- Add the documentation element to a function. -->
            <sqf:fix id="addFunctionDocElement">
                <sqf:description>
                    <sqf:title>Add documentation to current function</sqf:title>
                </sqf:description>
                
                <sqf:add position="before">
                    <xsldoc:doc><xsl:text>
                </xsl:text>
                        <xsldoc:desc><xsl:if test="$docComment">
                            <xsl:value-of select="$docComment"/>
                        </xsl:if></xsldoc:desc><xsl:text>
                    </xsl:text>
                        <xsl:if test="$functionParams">
                            <xsl:for-each select="$functionParams">
                                <xsldoc:param name="{current()}"></xsldoc:param>
                                <xsl:text>
                            </xsl:text>
                            </xsl:for-each>
                        </xsl:if>
                    </xsldoc:doc><xsl:text>
                </xsl:text>
                </sqf:add>
                <sqf:delete match="$docComment" use-when="$docComment"/>
            </sqf:fix>
            
            <!-- Add missing documentation for all the functions. -->
            <sqf:fix id="addDoc2AllFunctions">
                <sqf:description>
                    <sqf:title>Add documentation to all functions</sqf:title>
                </sqf:description>
                
                <!-- The current functions -->
                <sch:let name="theFunctions" value="//xsl:function[not(preceding-sibling::*[1][self::xsldoc:doc])]"/>
                <!-- Add doc where required. -->
                <sqf:add match="$theFunctions" position="before">
                    <!-- The function's doc comment. -->
                    <sch:let name="functionDocComment" value="preceding-sibling::node()[not(self::text())][1][self::comment()]"/>
                    
                    <!-- Get the template parameters. -->
                    <sch:let name="functionParams" value="xsl:param/@name"/>
                    <xsldoc:doc><xsl:text>
                    </xsl:text>
                        <xsldoc:desc><xsl:if test="$functionDocComment">
                            <xsl:value-of select="$functionDocComment"/>
                        </xsl:if></xsldoc:desc><xsl:text>
                        </xsl:text>
                        <xsl:if test="$functionParams">
                            <xsl:for-each select="$functionParams">
                                <xsldoc:param name="{current()}"></xsldoc:param>
                                <xsl:text>
                                </xsl:text>
                            </xsl:for-each>
                        </xsl:if>
                    </xsldoc:doc><xsl:text>
                    </xsl:text>
                </sqf:add>
                <!-- Delete comments after doc generation. -->
                <sqf:delete match="$theFunctions/preceding-sibling::node()[not(self::text())][1][self::comment()]"/>
            </sqf:fix>
        </sch:rule>
    </sch:pattern>
    
    <!-- The QuickFix-es -->
    <sqf:fixes>
        <!-- Add a new parameter in the template/function -->
        <sqf:fix id="addParameterDeclaration">
            <sqf:param name="params"/>
            <sqf:param name="element"/>
            <sqf:description>
                <sqf:title>Add the missing parameter(s)</sqf:title>
            </sqf:description>
            <sqf:add match="$element" position="first-child">
                <xsl:for-each select="$params">
                    <xsl:text>
                    </xsl:text>
                    <xsl:element name="xsl:param">
                        <xsl:attribute name="name"><xsl:value-of select="current()"/></xsl:attribute>
                    </xsl:element>
                </xsl:for-each>
            </sqf:add>
        </sqf:fix>
        
        <!-- Add parameter in the documentation -->
        <sqf:fix id="addParameterDocumentation">
            <sqf:param name="params"/>
            <sqf:param name="docElement"/>
            <sqf:description>
                <sqf:title>Add the missing parameter(s)</sqf:title>
            </sqf:description>
            <sqf:add match="$docElement" position="last-child">
                <xsl:for-each select="$params">
                    <xsldoc:param name="{current()}"/>
                    <xsl:text>
                    </xsl:text>
                </xsl:for-each>
            </sqf:add>
        </sqf:fix>
        
        <!-- Delete parameter in the documentation -->
        <sqf:fix id="deleteParameterDocumentation">
            <sqf:param name="params"/>
            <sqf:param name="docElement"/>
            <sqf:description>
                <sqf:title>Delete unbound documentation parameter(s)</sqf:title>
            </sqf:description>
            <sqf:delete match="$docElement/xsldoc:param[some $i in $params satisfies $i = @name]"/>
        </sqf:fix>
        
        <!-- Add missing documentation element -->
        <sqf:fix id="addDocumentationElement">
            <sqf:param name="existingParams"/>
            <sqf:param name="description"/>
            <sqf:description>
                <sqf:title>Add the documentation element.</sqf:title>
            </sqf:description>
            <sqf:add position="before">
                <xsldoc:doc><xsl:text>
                </xsl:text>
                    <xsldoc:desc><xsl:if test="$description">
                        <xsl:value-of select="$description"/>
                    </xsl:if></xsldoc:desc><xsl:text>
                    </xsl:text>
                    <xsl:if test="$existingParams">
                        <xsl:for-each select="$existingParams">
                            <xsldoc:param name="{current()}"></xsldoc:param>
                            <xsl:text>
                            </xsl:text>
                        </xsl:for-each>
                    </xsl:if>
                </xsldoc:doc><xsl:text>
                </xsl:text>
            </sqf:add>
        </sqf:fix>
    </sqf:fixes>
</sch:schema>