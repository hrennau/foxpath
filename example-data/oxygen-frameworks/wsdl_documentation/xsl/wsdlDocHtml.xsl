<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Copyright 2001-2011 Syncro Soft SRL. All rights reserved.
 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:func="http://www.oxygenxml.com/xsdDoc/functions" 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xpath-default-namespace="http://www.oxygenxml.com/ns/doc/wsdl-internal" 
    exclude-result-prefixes="#all"
    xmlns:sDoc="http://www.oxygenxml.com/ns/doc/schema-internal">
  
    <xsl:import href="../schema_documentation/xsdDocHtml.xsl"/>
  
    <xd:doc>
      <xd:desc>The root element of the documentation.</xd:desc>
    </xd:doc>
    <xsl:variable name="documentationRoot" select="/wsdlDoc"/>  

    <xsl:variable name="definitionTypeLabels">
        <entry key="main">Main WSDL</entry>
        <entry key="wsdlImport">Imported WSDL</entry>
    </xsl:variable>
   
    <xd:doc>
        <xd:desc>Defines labels for all WSDL component types.</xd:desc>
    </xd:doc>
    <xsl:variable name="wsdlComponentTypes">
        <entry key="Service">Service</entry>
        <entry key="Binding">Binding</entry>
        <entry key="PortType">PortType</entry>
        <entry key="Message">Message</entry>        
        <entry key="PortType_operation">Operation</entry>
    </xsl:variable>

    <xd:doc>
        <xd:desc>Redefines the variable from 'xsdDocHtml.xsl' stylesheet. Adds the WSDL components.</xd:desc>
    </xd:doc>
    <xsl:variable name="componentTypeLabels">
        <xsl:copy-of select="$schemaComponentTypes"/>
        <xsl:copy-of select="$wsdlComponentTypes"/>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>Prefix used to generate the title of a documentation HTML page.</xd:desc>
    </xd:doc>
    <xsl:variable name="documentationPageTitle">Documentation for</xsl:variable>
    
    <xd:doc>
        <xd:desc>Get the name of the main documentation resource.</xd:desc>
    </xd:doc>
    <xsl:function name="func:getMainResourceName" as="xs:string">
        <xsl:value-of select="$documentationRoot/definition[compare(@type, 'main') = 0]/qname"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Points to the node that contains schema hierarchy. Is empty if hierarchy was not generated.</xd:desc>
    </xd:doc>
    <xsl:variable name="resourceHierarchyNode" select="$documentationRoot/resourceHierarchy"/>
    
    <xd:doc>
        <xd:desc>Returns the main definition, the definition with type 'main'.</xd:desc>
    </xd:doc>
    <xsl:function name="func:getMainResource" as="item()">
        <xsl:value-of select="$documentationRoot/definition[@type='main']"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Mapping between directive types and icons. Is used in 
            the hierarchy tree.</xd:desc>
    </xd:doc>
    <xsl:variable name="scHierarchyIcons">
        <xsl:copy-of select="$schemaHierarchyIcons"/>
        <xsl:copy-of select="$wsdlHierarchyIcons"/>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>Part of the tooltip presented on a from the hierarchy view.</xd:desc>
    </xd:doc>
    <xsl:variable name="scHierarchyTooltip">
        <xsl:copy-of select="$schemaHierarchyTooltip"/>
        <xsl:copy-of select="$wsdlHierarchyTooltip"/>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>Overrides 'schemaTypeLabels' variable form the 'xsdDocHtml' and changes the render 
            labels for the schema types.</xd:desc>
    </xd:doc>
    <xsl:variable name="schemaTypeLabels">
        <entry key="main">Inner Schema</entry>
        <entry key="include">Included schema</entry>
        <entry key="import">Imported schema</entry>
        <entry key="redefine">Redefined schema</entry>
        <entry key="override">Overridden schema</entry>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>Mapping between schema directive types and icons. Is used in 
            the schemas hierarchy tree.</xd:desc>
    </xd:doc>
    <xsl:variable name="wsdlHierarchyIcons">
        <entry key="wsdlImport">img/ImportWsdl12.png</entry>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>Part of the tooltip presented on a schema from the hierarchy view.</xd:desc>
    </xd:doc>
    <xsl:variable name="wsdlHierarchyTooltip">
        <entry key="wsdlImport">Imported by </entry>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>Used to construct an id for identifying a property of  a component. This prefix will be added to the unique component id</xd:desc>
    </xd:doc>
    <xsl:variable name="idsPrefixMap">
        <xsl:copy-of select="$wsdlIdsPrefixMap"/>
        <xsl:copy-of select="$schemaIdsPrefixMap"/>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>Used to construct an id for identifying a property of a WSDL component. This prefix will be added to the unique component id</xd:desc>
    </xd:doc>
    <xsl:variable name="wsdlIdsPrefixMap">
        <entry key="ports">ports_</entry>
        <entry key="operations">operations_</entry>
        <entry key="parts">parts_</entry>
        <entry key="extensibilityElements">extensibility_</entry>
        <entry key="bindingType">bindingType_</entry>
        <entry key="documentation">documentation_</entry>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>The list with the java script variables used for the WSDL displayed component details.</xd:desc>
    </xd:doc>
    <xsl:variable name="jsWSDLDisplayOptionsVariables">
        <xsl:value-of select="$portsBoxes"/>
        <xsl:value-of select="$operationsBoxes"/>
        <xsl:value-of select="$messagesPartsBoxes"/>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>The list with the java script variables used for the displayed component details.</xd:desc>
    </xd:doc>
    <xsl:variable name="jsDisplayOptionsVariables">
        <xsl:value-of select="$jsWSDLDisplayOptionsVariables"/>
        <xsl:value-of select="$jsSchemaDisplayOptionsVariables"/>
    </xsl:variable>
    
    <xsl:variable name="portsBoxes">        
        <xsl:call-template name="createJsIdsArray">
            <xsl:with-param name="arrayName">portsBoxes</xsl:with-param>
            <xsl:with-param name="nodes" select="$documentationRoot/*[@id]/ports"/>
        </xsl:call-template> 
    </xsl:variable>
    
    <xsl:variable name="operationsBoxes">        
        <xsl:call-template name="createJsIdsArray">
            <xsl:with-param name="arrayName">operationsBoxes</xsl:with-param>
            <xsl:with-param name="nodes" select="$documentationRoot/*[@id]/operations"/>
        </xsl:call-template> 
    </xsl:variable>
    
    <xsl:variable name="messagesPartsBoxes">        
        <xsl:call-template name="createJsIdsArray">
            <xsl:with-param name="arrayName">messagesPartsBoxes</xsl:with-param>
            <xsl:with-param name="nodes" select="$documentationRoot/*[@id]/parts"/>
        </xsl:call-template> 
    </xsl:variable>
    
    <xsl:variable name="annotationBoxes">        
        <xsl:call-template name="createJsIdsArray">
            <xsl:with-param name="arrayName">annotationBoxes</xsl:with-param>
            <xsl:with-param name="nodes" select="$documentationRoot/*[@id]/node()[local-name() = 'documentation' or local-name() = 'annotations']"/>
        </xsl:call-template>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>The name of the option used to show/hide the documentation from the documentation</xd:desc>
    </xd:doc>
    <xsl:variable name="docOptionName">Documentation</xsl:variable>
    
    <xd:doc>
        <xd:desc>Returns the checkbox buttons that controls the displayed details for the WSDL documentation.</xd:desc>
    </xd:doc>
    <xsl:function name="func:getWSDLDisplayedOptions">
        <xsl:if test="string-length($portsBoxes) > 0">
            <tr>
                <td>
                    <span><input type="checkbox" value="-" checked="checked" onclick="switchStateForAll(this, portsBoxes);" class="control"/></span>                                
                    <span class="globalControlName">Ports </span></td>
            </tr>
        </xsl:if>
        <xsl:if test="string-length($operationsBoxes) > 0">
            <tr>
                <td>
                    <span><input type="checkbox" value="-" checked="checked" onclick="switchStateForAll(this, operationsBoxes);" class="control"/></span>                                
                    <span class="globalControlName">Operations </span></td>
            </tr>
        </xsl:if>
        <xsl:if test="string-length($messagesPartsBoxes) > 0">
            <tr>
                <td>
                    <span><input type="checkbox" value="-" checked="checked" onclick="switchStateForAll(this, messagesPartsBoxes);" class="control"/></span> 
                    <span class="globalControlName">Parts </span></td>
            </tr>
        </xsl:if>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Returns the checkbox buttons that controls the displayed details for the documentation.</xd:desc>
    </xd:doc>
    <xsl:function name="func:getDisplayedOptions">
        <xsl:copy-of select="func:getWSDLDisplayedOptions()"/>
        <xsl:copy-of select="func:getSchemaDisplayedOptions()"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Check if there is any checkbox button that should be displayed for the current documentation.</xd:desc>
    </xd:doc>
    <xsl:variable name="areComponentsDetailsVisible" as="xs:boolean" select="
        $areSchemaComponentsDetailsVisible or $areWSDLComponentsDetailsVisible"/>
    
    <xd:doc>
        <xd:desc>Check if there is any WSDL component detail visible for the current documentation.</xd:desc>
    </xd:doc>
    <xsl:variable name="areWSDLComponentsDetailsVisible" as="xs:boolean" 
        select="boolean(string-length($portsBoxes) > 0
        or string-length($messagesPartsBoxes) > 0
        or string-length($operationsBoxes) > 0)">
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>Copy CSS file.</xd:desc>
    </xd:doc>
    <xsl:template name="copyCSSFile">
        <xsl:result-document href="{$cssCopyLocation}" method="text">
            <xsl:value-of disable-output-escaping="yes"
                select="unparsed-text($cssRelativeLocationToXSL,'UTF-8')"/>
        </xsl:result-document>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>The entry point </xd:desc>
    </xd:doc>
    <xsl:template match="wsdlDoc">
        <xsl:if test="exists(definition[@type='main'])">
            <!-- This way we make sure the CSS will only be copied once-->
            <xsl:call-template name="copyCSSFile"/>
        </xsl:if>
        
        <xsl:choose>
            <xsl:when test="boolean($isChunkMode) and exists(definition[@type='main'])">
                <xsl:call-template name="writeMainFileInChunckMode"/>
            </xsl:when>
        </xsl:choose>

        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <title>
                    <xsl:value-of select="func:getTitleFromSplitInfo(splitInfo)"/>
                </title>
                <link rel="stylesheet" href="{$cssRelativeLocationToXML}" type="text/css"/>
                <script type="text/javascript">
                    <xsl:comment>
                        <xsl:value-of select="$javascript" disable-output-escaping="yes"/>
                    //</xsl:comment>
                </script>
            </head>
            <xsl:call-template name="main"/>
        </html>
    </xsl:template>

    <xd:doc>
        <xd:desc>Test if the given reference points to a WSDL component.</xd:desc>
    </xd:doc>
    <xsl:function name="func:isWSLDComponentReference" as="xs:boolean">
        <xsl:param name="ref"/>
        <xsl:value-of select="exists($wsdlComponentTypes/*:entry[@key=$ref/@refType])"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Test if the given reference points to a XML Schema component.</xd:desc>
    </xd:doc>
    <xsl:function name="func:isSchemaComponentReference" as="xs:boolean">
        <xsl:param name="ref"/>
        <xsl:value-of select="exists($schemaComponentTypes/*:entry[@key=$ref/@refType])"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Get the node component class.</xd:desc>
    </xd:doc>
    <xsl:function name="func:getComponentClass" as="xs:string">
        <xsl:param name="node"/>
        <xsl:choose>
            <xsl:when test="namespace-uri($node)='http://www.oxygenxml.com/ns/doc/wsdl-internal'">
                <xsl:value-of>wsdlComponent</xsl:value-of>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of>component</xsl:value-of>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>Filter the given components sequence by keeping only the WSDL or XML Schema components.</xd:desc>
        <xd:param name="components">The components sequence to filter.</xd:param>
        <xd:param name="keepWSDLComponents">
            If true then keep only the WSDL components, otherwise the XML Schema components will be kept.
        </xd:param>
    </xd:doc>
    <xsl:function name="func:filterComponents" as="item()*">
        <xsl:param name="components" as="item()*"/>
        <xsl:param name="keepWSDLComponents" as="xs:boolean"/>
        
        <xsl:for-each select="$components">
            <xsl:if test="if ($keepWSDLComponents) 
                then func:isWSLDComponentReference(.)
                else func:isSchemaComponentReference(.)">
                <xsl:copy-of select="."/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            Overrides the template from 'xsdDocHtml.xsl' to generate two indexes sections. 
            The first index is for the WSDL components and second is for XML Schema components. 
        </xd:desc>
    </xd:doc>
    <xsl:template name="indexGroupByComponent">
        <xsl:param name="refSeq" required="yes"/>
        <xsl:param name="prefix"/>
        
        <xsl:variable name="wsdlComponents" select="func:filterComponents($refSeq, true())"/>
        <xsl:variable name="schemaComponents" select="func:filterComponents($refSeq, false())"/>
        
        <!-- Generate index for WSDL components. -->
        <xsl:call-template name="generateComponentsIndex">
            <xsl:with-param name="refSeq" select="$wsdlComponents"/>
            <xsl:with-param name="prefix" select="$prefix"/>
        </xsl:call-template>    
        
        <!-- Generate index for XML Schema components. -->
        <xsl:call-template name="generateComponentsIndex">
            <xsl:with-param name="refSeq" select="$schemaComponents"/>
            <xsl:with-param name="prefix" select="$prefix"/>
        </xsl:call-template>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Apply templates to generate documentation for XML Schema and WSDL components</xd:desc>
    </xd:doc>
    <xsl:template name="processDocumentationElements">
        <!-- Process the WSDL definitions -->
        <xsl:apply-templates select="definition"/>
        
        <!-- Process the schemas definitions -->
        <xsl:apply-templates select="sDoc:schema"/>
        
        <!-- Process the WSDL components -->
        <xsl:apply-templates select="service"/>
        <xsl:apply-templates select="binding"/>
        <xsl:apply-templates select="portType"/>
        <xsl:apply-templates select="message"/>
        
        <!-- Process the XML Schema components -->
        <xsl:apply-templates select="
            sDoc:element | sDoc:complexType | sDoc:attribute | sDoc:simpleType |
            sDoc:elementGroup | sDoc:attributeGroup | sDoc:notation"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Generate documentation for a WSDL message.</xd:desc>
    </xd:doc>
    <xsl:template match="message">
        <xsl:call-template name="component">
            <xsl:with-param name="type">Message</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Generate documentation for a WSDL message.</xd:desc>
    </xd:doc>
    <xsl:template match="definition">
        <xsl:call-template name="component">
            <xsl:with-param name="type">
                <xsl:variable name="currentSchema" select="."/>
                <xsl:value-of select="$definitionTypeLabels/*[@key=$currentSchema/@type]"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            Overrides the template from 'xsdDocHtml.xsl' to match also the WSDL related elements. 
        </xd:desc>
    </xd:doc>
    <xsl:template name="generateComponentDocumentation">
        <xsl:call-template name="makeRoundedTable">
            <xsl:with-param name="content">
                <table class="{func:getComponentClass(.)}">
                    <tbody>
                        <xsl:apply-templates select="name"/>
                        <xsl:apply-templates select="*:namespace | sDoc:annotations"/>
                        
                        <!-- WSDL elements -->
                        <xsl:apply-templates select="documentation"/>
                        <xsl:apply-templates select="ports"/>
                        <xsl:apply-templates select="bindingType"/>
                        <xsl:apply-templates select="extensibilityElements"/>
                        <xsl:apply-templates select="parts"/>
                        <xsl:apply-templates select="operations"/>
                        
                        <!-- XML Schema components information -->
                        <xsl:apply-templates select="sDoc:diagram | sDoc:type | sDoc:typeHierarchy | sDoc:typeAlternatives | sDoc:properties | sDoc:defaultOpenContent"/>
                        <xsl:apply-templates select="sDoc:facets"/>
                        <xsl:apply-templates select="sDoc:substitutionGroup | sDoc:substitutionGroupAffiliation"/>
                        <xsl:apply-templates select="sDoc:usedBy | sDoc:model | sDoc:children | sDoc:attributes | sDoc:asserts | sDoc:contraints | sDoc:instance | sDoc:source"/>
                        <xsl:apply-templates select="sDoc:publicid | sDoc:systemid"/>
                        <xsl:apply-templates select="sDoc:schemaLocation"/>
                        
                        <!-- WSDL elements -->
                        <xsl:apply-templates select="resourceLocation"/>
                    </tbody>
                </table>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="name">
        <tr>
            <td class="firstColumn">
                <b>Name</b>
            </td>
            <td>
                <xsl:value-of select="text()"/>
            </td>
        </tr>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Generate documentation for a WSDL portType.</xd:desc>
    </xd:doc>
    <xsl:template match="portType">
        <xsl:call-template name="component">
            <xsl:with-param name="type">PortType</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Generate documentation for a WSDL binding.</xd:desc>
    </xd:doc>
    <xsl:template match="binding">
        <xsl:call-template name="component">
            <xsl:with-param name="type">Binding</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Generate documentation for a WSDL service.</xd:desc>
    </xd:doc>
    <xsl:template match="service">
        <xsl:call-template name="component">
            <xsl:with-param name="type">Service</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            Match the services/ports to generate a table describing all the service ports. 
        </xd:desc>
    </xd:doc>
    <xsl:template match="ports">
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <tr>
            <td class="firstColumn">
                <div class="floatLeft">
                    <b>Ports</b>
                </div>
                <div class="floatRight">
                    <xsl:copy-of select="func:createControl($boxID, func:getButtonId(.))"/>                    
                </div>
            </td>
            <td>
                <div id="{$boxID}" style="display:block">
                    <xsl:for-each select="port">
                        <!-- Add the port name. For the first port do not add margin top. -->
                        <xsl:choose>
                            <xsl:when test="position() = 1">
                                <div class="componentGroupTitle">
                                    <xsl:value-of select="name"/>
                                </div>
                            </xsl:when>
                            <xsl:otherwise>
                                <div class="componentGroupTitle" style="margin-top:20px;">
                                    <xsl:value-of select="name"/>
                                </div>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                        <!-- Add the opration documenattion.  -->
                        <xsl:for-each select="documentation">
                            <div class="annotation"> 
                                <xsl:call-template name="buildAnnotation"/>
                            </div>
                        </xsl:for-each>
                        
                        
                        <table class="propertiesTable" style="margin-left:10px;">
                            <xsl:if test="exists(sDoc:ref)">
                                <tr>
                                    <td class="firstColumn" style="white-space: nowrap;">
                                        <xsl:text>Binding</xsl:text> 
                                    </td>
                                    <td class="floatLeft">
                                        <xsl:call-template name="reference">
                                            <xsl:with-param name="ref" select="sDoc:ref"/>
                                        </xsl:call-template>
                                    </td>
                                </tr>
                            </xsl:if>
                            <!-- Add the port extensibility elements. -->
                            <xsl:if test="exists(extensibilityElements)">
                                <tr>
                                    <td class="firstColumn" style="white-space: nowrap;">
                                        <xsl:text>Extensibility</xsl:text> 
                                    </td>
                                    <td class="floatLeft">
                                        <xsl:for-each select="extensibilityElements/sDoc:source">
                                            <!-- Formats an XML source section-->
                                            <xsl:call-template name="formatXmlSource">
                                                <xsl:with-param name="tokens" select="sDoc:token"/>
                                            </xsl:call-template>
                                        </xsl:for-each>
                                    </td>
                                </tr>
                            </xsl:if>
                        </table>
                    </xsl:for-each>
                </div>
            </td>
        </tr>
    </xsl:template>
    
    
    <xd:doc>
        <xd:desc>Generate documentation for WSDL portType operations.</xd:desc>
    </xd:doc>
    <xsl:template match="operations">
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <tr>
            <td class="firstColumn">
                <div class="floatLeft">
                    <b>Operations</b>
                </div>
                <div class="floatRight">
                    <xsl:copy-of select="func:createControl($boxID, func:getButtonId(.))"/>                    
                </div>
            </td>
            <td>
                <div id="{$boxID}" style="display:block">
                    <xsl:for-each select="operation">
                        <xsl:element name="a">
                            <xsl:attribute name="id" select="@id"/>
                        </xsl:element>
                        
                        <!-- Add the operation name. For the first operation do not add margin top. -->
                        <xsl:choose>
                            <xsl:when test="position() = 1">
                                <div class="componentGroupTitle">
                                    <xsl:value-of select="name"/>
                                </div>
                            </xsl:when>
                            <xsl:otherwise>
                                <div class="componentGroupTitle" style="margin-top:20px;">
                                    <xsl:value-of select="name"/>
                                </div>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                        <!-- Add the opration documenattion.  -->
                        <xsl:for-each select="documentation">
                            <div class="annotation"> 
                                <xsl:call-template name="buildAnnotation"/>
                            </div>
                        </xsl:for-each>
                        
                        
                        <!-- Add the opration input/output/fault. -->
                        <table class="propertiesTable" style="margin-left:10px;">
                            <!-- Add the opration extensibility elements. -->
                            <xsl:if test="exists(extensibilityElements)">
                                <tr>
                                    <td class="firstColumn" style="white-space: nowrap;">
                                        <xsl:text>Extensibility</xsl:text> 
                                    </td>
                                    <td class="floatLeft">
                                        <xsl:for-each select="extensibilityElements/sDoc:source">
                                            <!-- Formats an XML source section-->
                                            <xsl:call-template name="formatXmlSource">
                                                <xsl:with-param name="tokens" select="sDoc:token"/>
                                            </xsl:call-template>
                                        </xsl:for-each>
                                    </td>
                                </tr>
                            </xsl:if>
                            <xsl:if test="exists(input)">
                                <xsl:call-template name="oprationIO">
                                    <xsl:with-param name="ioNode" select="input"/>
                                    <xsl:with-param name="name">Input</xsl:with-param>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if test="exists(output)">
                                <xsl:call-template name="oprationIO">
                                    <xsl:with-param name="ioNode" select="output"/>
                                    <xsl:with-param name="name">Output</xsl:with-param>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:for-each select="fault">
                                <xsl:call-template name="oprationIO">
                                    <xsl:with-param name="ioNode" select="current()"/>
                                    <xsl:with-param name="name">Fault</xsl:with-param>
                                </xsl:call-template>
                            </xsl:for-each>
                        </table>
                    </xsl:for-each>
                </div>
            </td>
        </tr>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Write the extensibility elememts.</xd:desc>
    </xd:doc>
    <xsl:template match="extensibilityElements">
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <tr>
            <td class="firstColumn">
                <div class="floatLeft">
                    <b>Extensibility</b>
                </div>
                <div class="floatRight">
                    <xsl:copy-of select="func:createControl($boxID, func:getButtonId(.))"/>
                </div>
            </td>
            <td>
                <div id="{$boxID}" style="display:block">
                    <xsl:for-each select="sDoc:source">
                        <!-- Formats an XML source section-->
                        <xsl:call-template name="formatXmlSource">
                            <xsl:with-param name="tokens" select="sDoc:token"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </div>
            </td>
        </tr>
    </xsl:template>
    
    <xsl:template match="bindingType">
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <tr>
            <td class="firstColumn">
                <div class="floatLeft">
                    <b>Type</b>
                </div>
                <div class="floatRight">
                    <xsl:copy-of select="func:createControl($boxID, func:getButtonId(.))"/>
                </div>
            </td>
            <td>
                <div id="{$boxID}" style="display:block">
                    <xsl:call-template name="typeEmitter">
                        <xsl:with-param name="type" select="current()"/>
                    </xsl:call-template>
                </div>
            </td>
        </tr>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            Match the operation input/output/fault to generate a row table with its information. 
        </xd:desc>
    </xd:doc>
    <xsl:template name="oprationIO">
        <xsl:param name="ioNode"/>
        <xsl:param name="name"/>
        <tr>
            <td class="firstColumn" style="white-space: nowrap;">
                <xsl:value-of select="$name"/> 
                <xsl:if test="exists($ioNode/name)">
                    <xsl:text>: </xsl:text>
                    <xsl:value-of select="$ioNode/name"/>
                </xsl:if>
            </td>
            <td class="floatLeft">
                <!-- Add the reference or the extensibility elements. -->
                <xsl:choose>
                    <xsl:when test="exists($ioNode/sDoc:ref)">
                        <xsl:call-template name="reference">
                            <xsl:with-param name="ref" select="$ioNode/sDoc:ref"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="exists($ioNode/extensibilityElements)">
                        <xsl:for-each select="$ioNode/extensibilityElements/sDoc:source">
                            <!-- Formats an XML source section-->
                            <xsl:call-template name="formatXmlSource">
                                <xsl:with-param name="tokens" select="sDoc:token"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            Match the message/parts to generate a table describing all the message parts. 
        </xd:desc>
    </xd:doc>
    <xsl:template match="parts">
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <tr>
            <td class="firstColumn">
                <div class="floatLeft">
                    <b>Parts</b>
                </div>
                <div class="floatRight">
                    <xsl:copy-of select="func:createControl($boxID, func:getButtonId(.))"/>                    
                </div>
            </td>
            <td>
                <div id="{$boxID}" style="display:block">
                    <table class="propertiesTable">
                        <xsl:variable name="hasDocumentation" select="exists(part/documentation)"/>
                        <xsl:for-each select="part">
                            <tr>
                                <td class="firstColumn" style="white-space: nowrap;">
                                    <xsl:value-of select="name"/>
                                </td>
                                <td class="floatLeft" style="white-space: nowrap;">
                                    <xsl:choose>
                                        <xsl:when test="exists(sDoc:ref)">
                                            <xsl:choose>
                                                <xsl:when test="sDoc:ref/@refType">
                                                    <xsl:value-of select="func:getComponentTypeLabel(sDoc:ref/@refType)"/>
                                                    <xsl:text> </xsl:text>
                                                </xsl:when>
                                                <xsl:otherwise>Type </xsl:otherwise>
                                            </xsl:choose>
                                            
                                            <xsl:call-template name="reference">
                                                <xsl:with-param name="ref" select="sDoc:ref"/>
                                            </xsl:call-template>
                                        </xsl:when>
                                        <!-- Display the value for a message without type or element -->
                                        <xsl:otherwise>
                                            <b><xsl:value-of select="value"/></b>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                                <xsl:if test="$hasDocumentation">
                                    <!-- Add a cell with part documentation -->
                                    <td style="width:100%;">
                                        <i>
                                            <xsl:for-each select="documentation">
                                                <xsl:call-template name="buildAnnotation"/>
                                            </xsl:for-each>
                                        </i>
                                    </td>
                                </xsl:if>
                            </tr>
                        </xsl:for-each>
                    </table>
                </div>
            </td>
        </tr>
    </xsl:template>
	
	<xd:doc>
        <xd:desc>Adds component documentation.</xd:desc>
    </xd:doc>
    <xsl:template match="documentation">
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <tr>
            <td class="firstColumn">
                <div class="floatLeft"><b>Documentation</b></div>
                <div class="floatRight">
                    <xsl:copy-of select="func:createControl($boxID, func:getButtonId(.))"/>
                </div>
            </td>
            <td>
                <div id="{$boxID}" style="display:block" class="annotation">
                    <xsl:call-template name="buildAnnotation"/>
                </div>
            </td>
        </tr>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Matches the location of a component. Adds the location of the component in the properties table.</xd:desc>
    </xd:doc>
    <xsl:template match="resourceLocation | sDoc:schemaLocation">
        <tr>
            <td class="firstColumn">
                <b>Location</b>
            </td>
            <td>
                <xsl:value-of select="text()"/>
            </td>
        </tr>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>The name of the documentation</xd:desc>
    </xd:doc>
    <xsl:variable name="documentationName">WSDL documentation</xsl:variable>
</xsl:stylesheet>
