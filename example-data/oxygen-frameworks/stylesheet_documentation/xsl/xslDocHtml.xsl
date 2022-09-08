<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Copyright 2001-2011 Syncro Soft SRL. All rights reserved.
 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:func="http://www.oxygenxml.com/doc/xsl/functions" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.oxygenxml.com/ns/doc/xsl-internal"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="#all">
    <xsl:import href="unknownDocToHtml.xsl"/>
    <xsl:import href="docbookDocToHtml.xsl"/>
    <xsl:import href="docLanguageToHtml.xsl"/>
    <xsl:import href="htmlDocToHtml.xsl"/>
    <xsl:import href="xslStyleDocToHtml.xsl"/>
    <xsl:import href="doxslDocToHtml.xsl"/>
    <xsl:import href="ditaDocToHtml.xsl"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>Transform Oxygen intermediate XML format into XHTML.</xd:p>
            <xd:p>XSLT stylesheet documentation can be generated in chunks. If the user chooses a
                split criterion, all the splitting is done before applying this stylesheet. So this
                stylesheet will be apply on each chunk file plus on a generated <xd:b>Table of
                    contents</xd:b> file. This stylesheet will transform each chunk file in a XHTML
                output file with the same name but with the <xd:b>html</xd:b> extension. Plus it
                will create a main file that will present the table of contents and chunk files. The
                name of the main file is given by the variable <xd:ref name="mainFile"
                    type="parameter">mainFile</xd:ref></xd:p>
        </xd:desc>
    </xd:doc>
    <xd:doc>
        <xd:desc>
            <xd:p>Name of the main output file. For a chunked documentation (with the split
                criterion being the location, namespace or XSLT element type) each chunk file will
                be transformed in its corresponding output file. Also the <xd:b>main</xd:b> file
                will be created and it will use FRAMES to present the index and output files.</xd:p>
            <xd:p>The name of the main file should also contain the extension.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="mainFile" required="yes" as="xs:string"/>
    <xd:doc>
        <xd:desc>
            <xd:p>Extension of the intermediate xml files. Default is "tmp".</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="intermediateXmlExtension" required="yes" as="xs:string"/>
     <xd:doc>
        <xd:desc>The oXygen family product used to generate the documentation.
        <xd:p> Possible values:
          <xd:ul>
              <xd:li>Editor (default value)</xd:li>
              <xd:li>Developer</xd:li>
          </xd:ul>
        </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="distribution">Editor</xsl:param>
    <xd:doc>
        <xd:desc>
            <xd:p>Output properties for this module.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xhtml" encoding="UTF-8" version="1.0" omit-xml-declaration="yes"
        doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" indent="yes"
        exclude-result-prefixes="#all"/>
    <xd:doc>
        <xd:desc>
            <xd:p>Extension of the output files. It is extracted from variable <xd:ref
                    name="mainFile" type="variable">mainFile</xd:ref>. It will be something like
                    <xd:i>.html</xd:i></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="extension" as="xs:string">
        <xsl:variable name="ext" select="func:substring-after-last($mainFile, '.')" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="string-length($ext) = 0">
                <xsl:text/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('.', $ext)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>The location of the CSS file. It is relative to the stylesheet location.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="cssRelativeLocationToXSL">docHtml.css</xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>The name of the CSS file. It is used to create references.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="css">docHtml.css</xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>Absolute location where to copy the CSS file. The CSS file will be copied next to
                the XML source file because that is where the output XHTML file will be
                created.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="cssCopyLocation" select="resolve-uri($css, base-uri())" as="xs:string"/>
    <xd:doc>
        <xd:desc>
            <xd:p>This is the value that indicates we have a split by location.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="chunkValueLocation" as="xs:string">location</xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>This is the value that indicates that we have a split by component type.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="chunkValueComponent" as="xs:string">component</xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>This is the value that indicates that we have a split by namespace.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="chunkValueNamespace" as="xs:string">namespace</xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>This is the value that indicates that we have no split. All output will be
                generated inside the same file.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="chunkValueNone" as="xs:string">none</xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>Information element from the source. It contains information about the chunk
                criterion and about the location of the <xd:b>Table of contents</xd:b> file.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="splitInfo" select="/xslDocumentation/splitInfo"/>
    <xd:doc>
        <xd:desc>
            <xd:p><b xmlns="http://www.oxygenxml.com/ns/doc/xsl">true</b> if the source file is from
                a chunked documentation.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="isChunkMode" as="xs:boolean" select="not($splitInfo/@criteria = 'none')"/>
    <xd:doc>
        <xd:desc>
            <xd:p><xd:b>true</xd:b> if the floating menu used to expand/collapse XSLT element
                details must be shown. </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="showFloatMenu" as="xs:boolean"
        select="(not(/xslDocumentation/splitInfo/@criteria = 'component') and not(/xslDocumentation/index))
                or /xslDocumentation/splitInfo/@criteria = 'none'"/>
    <xd:doc>
        <xd:desc>
            <xd:p>The location of the XHTML file that contains the <xd:b>Table of contents</xd:b>.
                It is relative to the source file.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="indexFile"
        select="concat(func:substring-before-last($splitInfo/@indexLocation, $intermediateXmlExtension), $extension)"
        as="xs:string"/>
    <xd:doc>
        <xd:desc>
            <xd:p>Name of the XHTML frame that will present documentation of the XSLT elements. Used
                when generating chunked documentation.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="mainFrame" as="xs:string">mainFrame</xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>Name of the XHTML frame where the <xd:b>Table of contents</xd:b> will be
                presented.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="indexFrame" as="xs:string">indexFrame</xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>Target for all links. When using a FRAME representation of the xhtml we need to
                specify which frame the reference will be opened in.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="target" as="xs:string">
        <xsl:choose>
            <xsl:when test="boolean($isChunkMode)">
                <xsl:choose>
                    <xsl:when test="not(/xslDocumentation/index)">_self</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$mainFrame"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>_self</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>These prefixes will be merged with the unique ID of an XSLT element in order to
                uniquely identify each detail of the element. It will be used in Javascript to
                hide/display details about elements.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="idsPrefixMap">
        <entry key="usedBy">uB_</entry>
        <entry key="docSection">dS_</entry>
        <entry key="attributes">atts_</entry>
        <entry key="parameters">prs_</entry>
        <entry key="source">src_</entry>
        <entry key="instance">inst_</entry>
        <entry key="output">o_</entry>
        <entry key="decimalFormat">dF_</entry>
        <entry key="characters">chs_</entry>
        <entry key="supersedes">sps_</entry>
        <entry key="overriding">ovr_</entry>
        <entry key="references">refs_</entry>
        <entry key="imports">ip_</entry>
        <entry key="includes">ic_</entry>
        <entry key="importedFrom">ipF_</entry>
        <entry key="includedFrom">icF_</entry>
    </xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>These prefixes will be merged with the unique ID of an XSLT element in order to
                uniquely identify each button that can expand/collapse a detail of an XSLT
                element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="buttonPrefix" as="xs:string">bt_</xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>Create a Javascript array that contains all the IDs to be expanded/collapsed when
                a specific detail must be shown/hiden for all XSLT elements from
                documentation.</xd:p>
        </xd:desc>
        <xd:param name="arrayName">
            <xd:p>The name of the array.</xd:p>
        </xd:param>
        <xd:param name="nodes">
            <xd:p>The nodes for which to generate the IDs. Each node represents a XSLT element
                detail (like <xd:i>References</xd:i>, <xd:i>Documentation</xd:i>,
                    <xd:i>Source</xd:i>).</xd:p>
        </xd:param>
    </xd:doc>
    <xsl:template name="createJsIdsArray">
        <xsl:param name="arrayName" as="xs:string" required="yes"/>
        <xsl:param name="nodes" required="yes"/>
        <xsl:choose>
            <xsl:when test="count($nodes) > 0">
                <xsl:text>var </xsl:text>
                <xsl:value-of select="$arrayName"/>
                <xsl:text>= new Array(</xsl:text>
                <xsl:for-each select="$nodes">
                    <xsl:if test="position()!=1">
                        <xsl:text>, &#10;&#9;&#9;&#9;&#9;</xsl:text>
                    </xsl:if>
                    <xsl:text>'</xsl:text>
                    <xsl:value-of select="func:getDivId(.)"/>
                    <xsl:text>'</xsl:text>
                </xsl:for-each>
                <xsl:text>);&#10;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>The Javascript array that contains IDs that identify all the
                    <xd:i>Documentation</xd:i> detail of the XSLT elements contained in the source
                file.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="docBoxes">
        <xsl:call-template name="createJsIdsArray">
            <xsl:with-param name="arrayName">docBoxes</xsl:with-param>
            <xsl:with-param name="nodes" select="/xslDocumentation/*[@id]/docSection"/>
        </xsl:call-template>
    </xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>The Javascript array that contains IDs that identify all the <xd:i>Used by</xd:i>
                detail of the XSLT elements contained in the source file.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="usedByBoxes">
        <xsl:call-template name="createJsIdsArray">
            <xsl:with-param name="arrayName">usedByBoxes</xsl:with-param>
            <xsl:with-param name="nodes" select="/xslDocumentation/*[@id]/usedBy"/>
        </xsl:call-template>
    </xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>The Javascript array that contains IDs that identify all the <xd:i>Source</xd:i>
                detail of the XSLT elements contained in the source file.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="sourceBoxes">
        <xsl:call-template name="createJsIdsArray">
            <xsl:with-param name="arrayName">sourceBoxes</xsl:with-param>
            <xsl:with-param name="nodes" select="/xslDocumentation/*[@id]/source"/>
        </xsl:call-template>
    </xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>The Javascript array that contains IDs that identify all the
                    <xd:i>References</xd:i> detail of the XSLT elements contained in the source
                file.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="referencesBoxes">
        <xsl:call-template name="createJsIdsArray">
            <xsl:with-param name="arrayName">referencesBoxes</xsl:with-param>
            <xsl:with-param name="nodes" select="/xslDocumentation/*[@id]/references"/>
        </xsl:call-template>
    </xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>
                <xd:p>The Javascript array that contains IDs that identify all the
                        <xd:i>Supersede</xd:i> detail of the XSLT elements contained in the source
                    file.</xd:p>
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="supersedesBoxes">
        <xsl:call-template name="createJsIdsArray">
            <xsl:with-param name="arrayName">supersedesBoxes</xsl:with-param>
            <xsl:with-param name="nodes" select="/xslDocumentation/*[@id]/supersedes"/>
        </xsl:call-template>
    </xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>
                <xd:p>The Javascript array that contains IDs that identify all the
                        <xd:i>Overriding</xd:i> detail of the XSLT elements contained in the source
                    file.</xd:p>
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="overridingBoxes">
        <xsl:call-template name="createJsIdsArray">
            <xsl:with-param name="arrayName">overridingBoxes</xsl:with-param>
            <xsl:with-param name="nodes" select="/xslDocumentation/*[@id]/overriding"/>
        </xsl:call-template>
    </xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>
                <xd:p>The Javascript array that contains IDs that identify all the
                        <xd:i>Attributes</xd:i> detail of the <xd:b>attribute-set</xd:b> elements
                    contained in the source file.</xd:p>
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="attributesBoxes">
        <xsl:call-template name="createJsIdsArray">
            <xsl:with-param name="arrayName">attributesBoxes</xsl:with-param>
            <xsl:with-param name="nodes" select="/xslDocumentation/*[@id]/attributes"/>
        </xsl:call-template>
    </xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>
                <xd:p>The Javascript array that contains IDs that identify all the
                        <xd:i>Parameters</xd:i> detail of the XSLT <xd:b>templates</xd:b> and
                        <xd:b>functions</xd:b> contained in the source file.</xd:p>
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="parametersBoxes">
        <xsl:call-template name="createJsIdsArray">
            <xsl:with-param name="arrayName">parametersBoxes</xsl:with-param>
            <xsl:with-param name="nodes" select="/xslDocumentation/*[@id]/parameters"/>
        </xsl:call-template>
    </xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>
                <xd:p>The Javascript array that contains IDs that identify all the
                        <xd:i>Character</xd:i> detail of the <xd:b>character-map</xd:b> elements
                    contained in the source file.</xd:p>
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="charactersBoxes">
        <xsl:call-template name="createJsIdsArray">
            <xsl:with-param name="arrayName">charactersBoxes</xsl:with-param>
            <xsl:with-param name="nodes" select="/xslDocumentation/*[@id]/characters"/>
        </xsl:call-template>
    </xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>
                <xd:p>The Javascript array that contains IDs that identify all the
                        <xd:i>Imports</xd:i> detail (all the XSLT modules that are imported in a
                    specific module) of the XSLT modules contained in the source file.</xd:p>
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="importsBoxes">
        <xsl:call-template name="createJsIdsArray">
            <xsl:with-param name="arrayName">importsBoxes</xsl:with-param>
            <xsl:with-param name="nodes" select="/xslDocumentation/*[@id]/imports"/>
        </xsl:call-template>
    </xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>The Javascript array that contains IDs that identify all the <xd:i>Includes</xd:i>
                detail (all the XSLT modules that are included in a specific module) of the XSLT
                modules contained in the source file.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="includesBoxes">
        <xsl:call-template name="createJsIdsArray">
            <xsl:with-param name="arrayName">includesBoxes</xsl:with-param>
            <xsl:with-param name="nodes" select="/xslDocumentation/*[@id]/includes"/>
        </xsl:call-template>
    </xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>The Javascript array that contains IDs that identify all the <xd:i>Imported
                    from</xd:i> detail(XSLT stylesheets that are imported in a specific
                module).</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="importedFromBoxes">
        <xsl:call-template name="createJsIdsArray">
            <xsl:with-param name="arrayName">importedFromBoxes</xsl:with-param>
            <xsl:with-param name="nodes" select="/xslDocumentation/*[@id]/importedFrom"/>
        </xsl:call-template>
    </xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>
                <xd:p>The Javascript array that contains IDs that identify all the <xd:i>Included
                        from</xd:i> detail(XSLT stylesheets that are included in a specific
                    stylesheet).</xd:p>
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="includedFromBoxes">
        <xsl:call-template name="createJsIdsArray">
            <xsl:with-param name="arrayName">includedFromBoxes</xsl:with-param>
            <xsl:with-param name="nodes" select="/xslDocumentation/*[@id]/includedFrom"/>
        </xsl:call-template>
    </xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>Javascript behind XHTML output.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="javascript" xml:space="preserve">
        <xsl:value-of select="$attributesBoxes"/>
        <xsl:value-of select="$parametersBoxes"/>
        <xsl:value-of select="$charactersBoxes"/>
        <xsl:value-of select="$usedByBoxes"/>
        <xsl:value-of select="$docBoxes"/>
        <xsl:value-of select="$sourceBoxes"/>
        <xsl:value-of select="$supersedesBoxes"/>
        <xsl:value-of select="$overridingBoxes"/>
        <xsl:value-of select="$referencesBoxes"/>
        <xsl:value-of select="$importsBoxes"/>
        <xsl:value-of select="$includesBoxes"/>
        <xsl:value-of select="$importedFromBoxes"/>
        <xsl:value-of select="$includedFromBoxes"/>
        var button_prefix = '<xsl:value-of select="$buttonPrefix"/>';
        <xsl:text>
        /**
        * Get all DIV elements with a specified class name.
        *
        * @param className The class name. 
        */
        function getElementsByClassName(className) {
            var results = [];
    
             if (document.getElementsByClassName == undefined) {
                var allElements = document.getElementsByTagName("div");
                var element;
                for (var i = 0; i &lt; allElements.length; i++) {
                    var element = allElements[i];
                	var elementClass = element.className;
                	if (elementClass == className) { 
                		results.push(element);
                	}
                }
             } else {
                results = document.getElementsByClassName(className);
             }
    
            return results;
        }
            
        /**
        * Returns an element in the current HTML document.
        *
        * @param elementID Identifier of HTML element
        * @return               HTML element object
        */
        function getElementObject(elementID) {
            var elemObj = null;
            if (document.getElementById) {
                elemObj = document.getElementById(elementID);
            }
            return elemObj;
        }
        
        /**
        * Switches the state of a collapseable box, e.g.
        * if it's opened, it'll be closed, and vice versa.
        *
        * @param boxID Identifier of box
        */
        function switchState(boxID) {
            var boxObj = getElementObject(boxID);
            var buttonObj = getElementObject(button_prefix + boxID);
            if (boxObj == null || buttonObj == null) {
                // Box or button not found
            } else if (boxObj.style.display == "none") {
                // Box is closed, so open it
                openBox(boxObj, buttonObj);
            } else if (boxObj.style.display == "block") {
                // Box is opened, so close it
                closeBox(boxObj, buttonObj);
            }
        }
        
        /**
        * Opens a collapseable box.
        *
        * @param boxObj       Collapseable box
        * @param buttonObj Button controlling box
        */
        function openBox(boxObj, buttonObj) {
            if (boxObj == null || buttonObj == null) {
                // Box or button not found
            } else {
                // Change 'display' CSS property of box
                boxObj.style.display = "block";
                
                // Change text of button
                if (boxObj.style.display == "block") {
                    buttonObj.src = "img/btM.gif";
                }
            }
        }
        
        /**
        * Closes a collapseable box.
        *
        * @param boxObj       Collapseable box
        * @param buttonObj Button controlling box
        */
        function closeBox(boxObj, buttonObj) {
            if (boxObj == null || buttonObj == null) {
                // Box or button not found
            } else {
                // Change 'display' CSS property of box
                boxObj.style.display = "none";
                
                // Change text of button
                if (boxObj.style.display == "none") {
                    buttonObj.src = "img/btP.gif";
                }
            }
        }

       /**
        * Switch between the compact list representation and the clasic list representation.
        */
       function switchMode(checkBox) {
            if (checkBox == null) {
                // Checkbox not found
            } else if (checkBox.checked == 1) {
                // Compact mode
                var divs = getElementsByClassName('refItemBlock');
                for (var i = 0; i &lt; divs.length; i ++) {
                    divs[i].style.display = "inline";
                    var children = divs[i].children;
                    var refItemSep = children[children.length - 1];
                    if (refItemSep.className == "refItemSep") {
                        children[children.length - 1].style.display = "inline";
                    }
                }
            } else {
                // Expanded mode
                var divs = getElementsByClassName('refItemBlock');
                for (var i = 0; i &lt; divs.length; i ++) {
                    divs[i].style.display = "block";
                    var children = divs[i].children;
                    var refItemSep = children[children.length - 1];
                    if (refItemSep.className == "refItemSep") {
                        children[children.length - 1].style.display = "none";
                    }
                }
            }
        }

       function switchStateForAll(buttonObj, boxList) {
            if (buttonObj == null) {
                // button not found
            } else if (buttonObj.value == "+") {
                // Expand all
                expandAll(boxList);
                buttonObj.value = "-";
            } else if (buttonObj.value == "-") {
                // Collapse all
                collapseAll(boxList);
                buttonObj.value = "+";
            }
        }
        
        /**
        * Closes all boxes in a given list.
        *
        * @param boxList Array of box IDs
        */
        function collapseAll(boxList) {
            var idx;
            for (idx = 0; idx &lt; boxList.length; idx++) {
                var boxObj = getElementObject(boxList[idx]);
                var buttonObj = getElementObject(button_prefix + boxList[idx]);
                closeBox(boxObj, buttonObj);
            }
        }
            
        /**
        * Open all boxes in a given list.
        *
        * @param boxList Array of box IDs
        */
        function expandAll(boxList) {
            var idx;
            for (idx = 0; idx &lt; boxList.length; idx++) {
                var boxObj = getElementObject(boxList[idx]);
                var buttonObj = getElementObject(button_prefix + boxList[idx]);
                openBox(boxObj, buttonObj);
            }
        }
        
        /**
         * Update the message presented in the title of the html page.
         * - If the documentation was splited by namespace we present something like: "Documentation for namespace 'ns'"
         * - If the documentation was splited by location we present somehing like: "Documentation for 'Schema.xsd'"
         * - If no split we always present: "Documentation for 'MainSchema.xsd'"
         */
        function updPT(message) {
            top.document.title = "Stylesheet documentation for: " + message;
        }
        
          
                    
         /**
          * Finds an HTML element by its ID and makes it floatable over the normal content.
          *
          * @param x_displacement The difference in pixels to the right side of the window from 
          *           the left side of the element.
          * @param y_displacement The difference in pixels to the right side of the window from 
          *           the top of the element.          
          */
         function findAndFloat(id, x_displacement, y_displacement){

            var element = getElementObject(id);            
            
            window[id + "_obj"] = element;
            
            if(document.layers) {
               element.style = element;
            }
            
            element.current_y = y_displacement;      
            element.first_time = true;
         
            element.floatElement = function(){
               // It may be closed by an user action.
                
               // Target X and Y coordinates.
               var x, y;
               
               var myWidth = 0, myHeight = 0;
               if( typeof( window.innerWidth ) == 'number' ) {
                  //Non-IE
                  myWidth = window.innerWidth;
                  myHeight = window.innerHeight;
               } else if( document.documentElement &amp;&amp; ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
                  //IE 6+ in 'standards compliant mode'
                  myWidth = document.documentElement.clientWidth;
                  myHeight = document.documentElement.clientHeight;
               } else if( document.body &amp;&amp; ( document.body.clientWidth || document.body.clientHeight ) ) {
                  //IE 4 compatible
                  myWidth = document.body.clientWidth;
                  myHeight = document.body.clientHeight;
               }
               
               
               x = myWidth - x_displacement;
               
               var ns = (navigator.appName.indexOf("Netscape") != -1);               
               y = ns ? pageYOffset : document.documentElement &amp;&amp; document.documentElement.scrollTop ? 
                  document.documentElement.scrollTop : document.body.scrollTop;               
               y = y + y_displacement;               
               
               // The current y is the current coordinate of the floating element.
               // This should be at the limit the y target coordinate.
               this.current_y += (y - this.current_y)/1.25;
               
               // Add the pixels constant after the values
               // and move the element.
               var px = document.layers ? "" : "px";
               this.style.left =  x + px;
               this.style.top =  this.current_y + px;
                              
               setTimeout(this.id + "_obj.floatElement()", 100);
            }
            
            element.floatElement();
            return element;
          }

         /**
          * Finds an HTML element by its ID and makes it floatable over the normal content.
          *
          * @param x_displacement The difference in pixels to the right side of the window from 
          *           the left side of the element.
          * @param y_displacement The difference in pixels to the right side of the window from 
          *           the top of the element.          
          */
         function selectTOCGroupBy(id){
         var selectIds = new Array('toc_group_by_location', 'toc_group_by_component_type', 'toc_group_by_namespace', 'toc_group_by_mode');
            // Make all the tabs invisible.
            for (i = 0; i &lt; 4; i++){
               var tab = getElementObject(selectIds[i]);
               tab.style.display = 'none';
            }
            var selTab = getElementObject(id);
            selTab.style.display = 'block';            
         }
          
</xsl:text>
    </xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>Constructs an unique ID for the given detail node. A prefix will be used for each
                detail type in conjunction with the ID of the XSLT element it belongs to. The
                constructed ID will identify a DIV element in the XHTML that will contain the
                detail. This block will be able to be expanded/colapsed through Javascript.</xd:p>
        </xd:desc>
        <xd:param name="node">
            <xd:p>The node from the source that represents a specific detail.</xd:p>
        </xd:param>
    </xd:doc>
    <xsl:function name="func:getDivId" as="xs:string">
        <xsl:param name="node"/>
        <xsl:value-of
            select="concat($idsPrefixMap/*[@key=local-name($node)]/text(), $node/parent::node()/@id)"
        />
    </xsl:function>
    <xd:doc>
        <xd:desc>
            <xd:p>Constructs an unique ID for the button used to expand/collapse a given detail
                node. A prefix will be used in conjunction with the ID generated for the actual
                XHTML block that the button will expand/collapse (see <xd:ref name="getDivId"
                    type="function">getDivId</xd:ref>).</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="func:getButtonId" as="xs:string" xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xsl:param name="node"/>
        <xsl:value-of select="concat($buttonPrefix , func:getDivId($node))"/>
    </xsl:function>
    <xd:doc>
        <xd:desc>
            <xd:p>A type label that will be presented for an XSLT stylesheet depending on its type :
                    <xd:b>main</xd:b>, <xd:b>included</xd:b> or <xd:b>imported</xd:b>.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="stylesheetTypeLabels">
        <entry key="main">Main stylesheet</entry>
        <entry key="included">Stylesheet</entry>
        <entry key="imported">Stylesheet</entry>
    </xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>Maps a XSLT element type to a string to be rendered.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="componentTypeLabels">
        <entry key="template">Template</entry>
        <entry key="function">Function</entry>
        <entry key="variable">Variable</entry>
        <entry key="parameter">Parameter</entry>
        <entry key="attributeSet">Attribute Set</entry>
        <entry key="stylesheet">Stylesheet</entry>
        <entry key="output">Output</entry>
        <entry key="decimalFormat">Decimal Format</entry>
        <entry key="characterMap">Character Map</entry>
        <entry key="key">Key</entry>
        <entry key="imported">Stylesheet</entry>
        <entry key="included">Stylesheet</entry>
        <entry key="main">Stylesheet</entry>
    </xsl:variable>
    <xd:doc>
        <xd:desc>
            <xd:p>Build a title message from a reference node when the documentation was generated
                using chunks. This title will be set in browser when the reference is clicked on.<xd:ul>
                    <xd:li>If the documentation was split by <xd:b>namespace</xd:b> we present
                        something like: "Documentation for namespace 'ns'"</xd:li>
                    <xd:li>If the documentation was split by <xd:b>location</xd:b> we present the
                        name of the XSLT stylesheet from which the component was collected.
                        Something like: "Documentation for 'stylesheet.xsl'"</xd:li>
                    <xd:li>If the documentation was split by <xd:b>component type</xd:b> we present
                        the component name. Something like: "Documentation for
                        myVariableName"</xd:li>
                    <xd:li>If no split we always present: "Documentation for 'MainStylesheet.xsl'"
                        and this function will not be used.</xd:li>
                </xd:ul></xd:p>
        </xd:desc>
        <xd:param name="ref">
            <xd:p>Reference node.</xd:p>
        </xd:param>
        <xd:param name="criteria">
            <xd:p>Split criterion. One of <xd:ref name="chunkValueLocation" type="variable"
                    >chunkValueLocation</xd:ref>, <xd:ref name="chunkValueNamespace" type="variable"
                    >chunkValueNamespace</xd:ref>, <xd:ref name="chunkValueComponent"
                    type="variable">chunkValueComponent</xd:ref>, <xd:ref name="chunkValueNone"
                    type="variable">chunkValueNone</xd:ref>.</xd:p>
        </xd:param>
    </xd:doc>
    <xsl:function name="func:getTitle" as="xs:string">
        <xsl:param name="ref"/>
        <xsl:param name="criteria" as="xs:string"/>
        <xsl:value-of>
            <xsl:text>updPT('</xsl:text>
            <xsl:choose>
                <xsl:when test="$criteria = $chunkValueLocation">
                    <!-- The split criterion is the location -->
                    <xsl:value-of select="$ref/@location"/>
                </xsl:when>
                <xsl:when test="$criteria = $chunkValueNamespace">
                    <!-- The split criterion is the namespace -->
                    <xsl:choose>
                        <xsl:when test="not($ref/@ns = '')">
                            <xsl:value-of select="$ref/@ns"/>
                        </xsl:when>
                        <xsl:otherwise>No namespace</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$criteria = $chunkValueComponent">
                    <!-- The split criterion is the component type -->
                    <xsl:choose>
                        <xsl:when test="$ref/@name">
                            <xsl:value-of select="$ref/@name"/>
                        </xsl:when>
                        <xsl:when test="$ref/@match">
                            <xsl:choose>
                                <xsl:when test="not($ref/@mode = '#default')">
                                    <xsl:value-of
                                        select="concat($ref/@match, ' [', $ref/@mode, ']')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$ref/@match"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$ref/text()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
            <xsl:text>')</xsl:text>
        </xsl:value-of>
    </xsl:function>
    <xd:doc>
        <xd:desc>
            <xd:p>Get the title of the html page by analyzing the <xd:ref name="splitInfo"
                    type="variable">splitInfo</xd:ref> element.</xd:p>
        </xd:desc>
        <xd:param name="splitInfo">the split criterion</xd:param>
        <xd:return>The title of the html page.</xd:return>
    </xd:doc>
    <xsl:function name="func:getTitleFromSplitInfo" as="xs:string"
        xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xsl:param name="splitInfo"/>
        <xsl:choose>
            <xsl:when test="$splitInfo/@criteria = $chunkValueLocation">
                <xsl:value-of select="concat('Stylesheet documentation for: ', $splitInfo/@value)"/>
            </xsl:when>
            <xsl:when test="$splitInfo/@criteria = $chunkValueComponent">
                <xsl:value-of select="concat('Stylesheet documentation for: ', $splitInfo/@value)"/>
            </xsl:when>
            <xsl:when test="$splitInfo/@criteria = $chunkValueNamespace">
                <xsl:choose>
                    <xsl:when
                        test="not($splitInfo/@value = '' or $splitInfo/@value = 'NO_NAMESPACE')">
                        <xsl:value-of
                            select="concat('Stylesheet documentation for: ', $splitInfo/@value)"/>
                    </xsl:when>
                    <xsl:otherwise>Stylesheet documentation for: No namespace</xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="concat('Stylesheet documentation for: ', $splitInfo/parent::node()/stylesheet[@type = 'main']/qname)"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xd:doc>
        <xd:desc>
            <xd:p>Search inside parameter <xd:i>string</xd:i> for the last occurrence of parameter
                    <xd:i>searched</xd:i>. The substring starting from the 0 position to the
                identified last occurrence will be returned. See also <xd:ref
                    name="f:substring-after-last" type="function"
                    xmlns:f="http://www.oxygenxml.com/doc/xsl/functions"
                    >f:substring-after-last</xd:ref>.</xd:p>
        </xd:desc>
        <xd:param name="string">
            <xd:p>String to be analyzed</xd:p>
        </xd:param>
        <xd:param name="searched">
            <xd:p>Marker string. Its last occurrence will be identified</xd:p>
        </xd:param>
        <xd:return>
            <xd:p>A substring starting from the beginning of <xd:i>string</xd:i> to the last
                occurrence of <xd:i>searched</xd:i>. If no occurrence is found an empty string will
                be returned.</xd:p>
        </xd:return>
    </xd:doc>
    <xsl:function name="func:substring-before-last" as="xs:string">
        <xsl:param name="string"/>
        <xsl:param name="searched"/>
        <xsl:variable name="toReturn">
            <xsl:choose>
                <xsl:when test="contains($string, $searched)">
                    <xsl:variable name="before" select="substring-before($string, $searched)"/>
                    <xsl:variable name="rec"
                        select="func:substring-before-last(substring-after($string, $searched), $searched)"/>
                    <xsl:choose>
                        <xsl:when test="string-length($rec) = 0">
                            <xsl:value-of select="$before"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat($before, $searched, $rec)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$toReturn"/>
    </xsl:function>
    <xd:doc>
        <xd:desc>
            <xd:p>Get the substring after the last occurrence of the given substring.</xd:p>
        </xd:desc>
        <xd:param name="string">
            <xd:p>The string to be analyzed.</xd:p>
        </xd:param>
        <xd:param name="searched">
            <xd:p>Marker string. Its last occurrence will be identified.</xd:p>
        </xd:param>
        <xd:return>
            <xd:p>A substring starting from the beginning of <xd:i>string</xd:i> to the last
                occurrence of <xd:i>searched</xd:i>. If no occurrence is found an empty string will
                be returned.</xd:p>
        </xd:return>
    </xd:doc>
    <xsl:function name="func:substring-after-last" as="xs:string">
        <xsl:param name="string"/>
        <xsl:param name="searched"/>
        <xsl:variable name="toReturn">
            <xsl:choose>
                <xsl:when test="contains($string, $searched)">
                    <xsl:variable name="after" select="substring-after($string, $searched)"/>
                    <xsl:variable name="rec" select="func:substring-after-last($after, $searched)"/>
                    <xsl:choose>
                        <xsl:when test="string-length($rec) = 0">
                            <xsl:value-of select="$after"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$rec"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$toReturn"/>
    </xsl:function>
    <xd:doc>
        <xd:desc>
            <xd:p>The entry point template. </xd:p>
            <xd:p>It creates the output files depending on the split criterion and copies the CSS
                file to the main file location.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="xslDocumentation">
        <xsl:if test="stylesheet[@type='main']">
            <!-- This way we make sure the CSS will only be copied once-->
            <xsl:result-document href="{$cssCopyLocation}" method="text">
                <xsl:value-of disable-output-escaping="yes"
                    select="unparsed-text($cssRelativeLocationToXSL,'UTF-8')"/>
            </xsl:result-document>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="boolean($isChunkMode) and stylesheet[@type='main']">
                <xsl:result-document href="{resolve-uri($mainFile, base-uri())}" method="xhtml"
                    indent="no" exclude-result-prefixes="#all"
                    doctype-public="-//W3C//DTD XHTML 1.0 Frameset//EN"
                    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">
                    <html xmlns="http://www.w3.org/1999/xhtml">
                        <head>
                            <title>
                                <xsl:value-of select="func:getTitleFromSplitInfo(splitInfo)"/>
                            </title>
                            <link rel="stylesheet" href="{$css}" type="text/css"/>
                        </head>
                        <xsl:if test="boolean($isChunkMode)">
                            <!-- When all the documentation is in one file we will generate a html with frames -->
                            <xsl:choose>
                                <xsl:when test="string-length($splitInfo/@indexLocation) = 0">
                                    <!-- The index was not included -->
                                    <frameset cols="100%">
                                        <xsl:element name="frame">
                                            <xsl:attribute name="name" select="$mainFrame"/>
                                            <xsl:attribute name="src"
                                                select="concat(func:substring-before-last(func:substring-after-last(base-uri(), '/'), $intermediateXmlExtension), $extension)"
                                            />
                                        </xsl:element>
                                    </frameset>
                                </xsl:when>
                                <xsl:otherwise>
                                    <frameset cols="20%, 80%">
                                        <xsl:element name="frame">
                                            <xsl:attribute name="name" select="$indexFrame"/>
                                            <xsl:attribute name="src" select="$indexFile"/>
                                        </xsl:element>
                                        <xsl:element name="frame">
                                            <xsl:attribute name="name" select="$mainFrame"/>
                                            <xsl:attribute name="src"
                                                select="concat(func:substring-before-last(func:substring-after-last(base-uri(), '/'), $intermediateXmlExtension), $extension)"
                                            />
                                        </xsl:element>
                                    </frameset>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </html>
                </xsl:result-document>
            </xsl:when>
        </xsl:choose>
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <title>
                    <xsl:value-of select="func:getTitleFromSplitInfo(./splitInfo)"/>
                </title>
                <link rel="stylesheet" href="{$css}" type="text/css"/>
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
        <xd:desc>
            <xd:p> This template is used to create the a link element to a component.</xd:p>
        </xd:desc>
        <xd:param name="ref">
            <xd:p>The node representing the component that will be referred.</xd:p>
        </xd:param>
    </xd:doc>
    <xsl:template name="reference">
        <xsl:param name="ref" select="."/>
        <xsl:choose>
            <xsl:when test="$ref/@refId">
                <a
                    href="{concat(substring-before($ref/@base, $intermediateXmlExtension), $extension, '#', $ref/@refId)}"
                    target="{$target}">
                    <xsl:if test="ancestor::index and not($ref/parent::stylesheetReferences)">
                        <xsl:attribute name="class">iRf</xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="title">
                        <xsl:choose>
                            <xsl:when test="'' = $ref/@ns">No namespace</xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$ref/@ns"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:variable name="criteria" select="$splitInfo/@criteria"/>
                    <xsl:if test="not($criteria = $chunkValueNone)">
                        <xsl:attribute name="onclick" select="func:getTitle($ref, $criteria)"/>
                    </xsl:if>
                    <xsl:call-template name="createRefSpan">
                        <xsl:with-param name="ref" select="$ref"/>
                    </xsl:call-template>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <b>
                    <xsl:call-template name="createRefSpan">
                        <xsl:with-param name="ref" select="$ref"/>
                    </xsl:call-template>
                </b>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>This template is used to create a span for a component reference.</xd:p>
        </xd:desc>
        <xd:param name="ref">
            <xd:p>The node representing the component that will be referred.</xd:p>
        </xd:param>
    </xd:doc>
    <xsl:template name="createRefSpan">
        <xsl:param name="ref"/>
        <xsl:choose>
            <xsl:when test="$ref/@name or $ref/@match">
                <xsl:if test="$ref/@match">
                    <xsl:choose>
                        <xsl:when test="ancestor::index">
                            <span class="mRfI">
                                <xsl:value-of select="$ref/@match"/>
                            </span>
                        </xsl:when>
                        <xsl:otherwise>
                            <span class="mRf">
                                <xsl:value-of select="$ref/@match"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
                <xsl:if test="$ref/@name">
                    <span class="nRf">
                        <xsl:value-of select="$ref/@name"/>
                    </span>
                </xsl:if>
                <xsl:if test="$ref/@mode and not($ref/@mode = '#default')">
                    <span class="mdRf">
                        <xsl:value-of select="$ref/@mode"/>
                    </span>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="ancestor::index and not($ref/parent::stylesheetReferences)">
                        <xsl:variable name="textToRender">
                            <xsl:choose>
                                <xsl:when
                                    test="$ref/@refType = 'output' and string-length($ref/text()) = 0">
                                    <xsl:text>(default)</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$ref/text()"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <span class="cRfI">
                            <xsl:call-template name="renderReferenceText">
                                <xsl:with-param name="refText" select="$textToRender"/>
                                <xsl:with-param name="refType" select="$ref/@refType"/>
                            </xsl:call-template>
                        </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="renderReferenceText">
                            <xsl:with-param name="refText" select="$ref/text()"/>
                            <xsl:with-param name="refType" select="$ref/@refType"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Emit the reference text. Depending on the reference the render can be
                different.</xd:p>
        </xd:desc>
        <xd:param name="refText">The reference text that must be rendered.</xd:param>
        <xd:param name="refType">The reference type. It indicates if it is a reference towards a
            function, template etc.</xd:param>
    </xd:doc>
    <xsl:template name="renderReferenceText">
        <xsl:param name="refText" as="xs:string"/>
        <xsl:param name="refType" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$refType = 'function'">
                <xsl:variable name="qname" select="substring-before($refText, '(')"/>
                <span>
                    <!-- The qname followed by ( -->
                    <xsl:value-of select="concat($qname, ' (')"/>
                </span>
                <span class="fParams">
                    <!-- The parameters are rendered different -->
                    <xsl:value-of
                        select="substring(
                         $refText, 
                         string-length($qname) + 2, 
                         string-length($refText) - string-length($qname) - 2)"
                    />
                </span>
                <span>
                    <!-- The trailing ) -->
                    <xsl:text>)</xsl:text>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$refText"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Template used to generate the table of contents.</xd:p>
            <xd:p>The components will be grouped by several criteria: <xd:b>location</xd:b>,
                    <xd:b>component type</xd:b>, <xd:b>namespace</xd:b> or <xd:b>mode</xd:b>.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="index">
        <h2>
            <a id="INDEX">Table of Contents</a>
        </h2>
        <div class="toc">
            <form action="none">
                <div>
                    <span> Group by: <select id="selectTOC"
                            onchange="selectTOCGroupBy(this.options[this.selectedIndex].value);">
                            <xsl:element name="option">
                                <xsl:attribute name="value">toc_group_by_location</xsl:attribute>
                                <xsl:if
                                    test="not($isChunkMode) or $splitInfo/@criteria = $chunkValueLocation">
                                    <xsl:attribute name="selected">selected</xsl:attribute>
                                </xsl:if>
                                <xsl:text>Location</xsl:text>
                            </xsl:element>
                            <xsl:element name="option">
                                <xsl:attribute name="value"
                                    >toc_group_by_component_type</xsl:attribute>
                                <xsl:if
                                    test="$isChunkMode and $splitInfo/@criteria = $chunkValueComponent">
                                    <xsl:attribute name="selected">selected</xsl:attribute>
                                </xsl:if>
                                <xsl:text>Component Type</xsl:text>
                            </xsl:element>
                            <xsl:element name="option">
                                <xsl:attribute name="value">toc_group_by_namespace</xsl:attribute>
                                <xsl:if
                                    test="$isChunkMode and $splitInfo/@criteria = $chunkValueNamespace">
                                    <xsl:attribute name="selected">selected</xsl:attribute>
                                </xsl:if>
                                <xsl:text>Namespace</xsl:text>
                            </xsl:element>
                            <xsl:element name="option">
                                <xsl:attribute name="value">toc_group_by_mode</xsl:attribute>
                                <xsl:text>Mode</xsl:text>
                            </xsl:element>
                        </select></span>
                </div>
            </form>
            <!-- Generate links grouped by the namespace of the component-->
            <xsl:variable name="boxId">groupByNs</xsl:variable>
            <div class="level1" id="toc_group_by_namespace">
                <!-- This is the displayed div by default if there is no chunking or it is chunked by namespace -->
                <xsl:choose>
                    <xsl:when test="$isChunkMode and $splitInfo/@criteria = $chunkValueNamespace">
                        <xsl:attribute name="style" select="'display:block'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="style" select="'display:none'"/>
                    </xsl:otherwise>
                </xsl:choose>
                <div>
                    <xsl:for-each-group select="ref" group-by="@ns">
                        <xsl:variable name="ns">
                            <xsl:choose>
                                <xsl:when test="'' = @ns">No namespace</xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@ns"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="nsBoxId">boxIdNamespace<xsl:value-of select="position()"
                            /></xsl:variable>
                        <div class="level2">
                            <p>
                                <input id="bt_{$nsBoxId}" type="image" value="-" src="img/btM.gif"
                                    onclick="switchState('{$nsBoxId}');" class="control"/>
                                <span class="indexGroupTitle">
                                    <xsl:value-of select="$ns"/>
                                </span>
                            </p>
                            <div id="{$nsBoxId}" style="display:block">
                                <xsl:call-template name="indexGroupByComponent">
                                    <xsl:with-param name="refSeq" select="current-group()"/>
                                    <xsl:with-param name="prefix" select="$nsBoxId"/>
                                </xsl:call-template>
                            </div>
                        </div>
                    </xsl:for-each-group>
                </div>
            </div>
            <!-- Generate links grouped by the mode of the component-->
            <xsl:variable name="boxId">groupByMode</xsl:variable>
            <div class="level1" id="toc_group_by_mode">
                <xsl:attribute name="style" select="'display:none'"/>
                <xsl:for-each-group select="ref" group-by="@mode">
                    <xsl:variable name="mode">
                        <xsl:if test="@mode">
                            <xsl:value-of select="@mode"/>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:variable name="nsBoxId">boxIdMode<xsl:value-of select="position()"
                        /></xsl:variable>
                    <div class="level2">
                        <p>
                            <input id="bt_{$nsBoxId}" type="image" value="-" src="img/btM.gif"
                                onclick="switchState('{$nsBoxId}');" class="control"/>
                            <span class="indexGroupTitle">
                                <xsl:value-of select="$mode"/>
                            </span>
                        </p>
                        <div id="{$nsBoxId}" style="display:block">
                            <xsl:call-template name="indexGroupByComponent">
                                <xsl:with-param name="refSeq" select="current-group()"/>
                                <xsl:with-param name="prefix" select="$nsBoxId"/>
                            </xsl:call-template>
                        </div>
                    </div>
                </xsl:for-each-group>
                <div class="level2">
                    <xsl:variable name="nsBoxId">boxIdNoMode</xsl:variable>
                    <p>
                        <input id="bt_{$nsBoxId}" type="image" value="-" src="img/btM.gif"
                            onclick="switchState('{$nsBoxId}');" class="control"/>
                        <span class="indexGroupTitle"> Components without mode </span>
                    </p>
                    <div id="{$nsBoxId}" style="display:block">
                        <xsl:call-template name="indexGroupByComponent">
                            <xsl:with-param name="refSeq" select="ref[not(@mode)]"/>
                            <xsl:with-param name="prefix" select="$nsBoxId"/>
                        </xsl:call-template>
                    </div>
                </div>
            </div>
            <!-- Generate links grouped by the type of the component-->
            <!-- This is hidden by default. -->
            <xsl:variable name="boxId">groupByCType</xsl:variable>
            <div class="level1" id="toc_group_by_component_type" style="display:none">
                <!-- This is the displayed div by default if there is chunking by component -->
                <xsl:choose>
                    <xsl:when test="$isChunkMode and $splitInfo/@criteria = $chunkValueComponent">
                        <xsl:attribute name="style" select="'display:block'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="style" select="'display:none'"/>
                    </xsl:otherwise>
                </xsl:choose>
                <div>
                    <xsl:call-template name="indexGroupByComponent">
                        <xsl:with-param name="refSeq" select="ref"/>
                    </xsl:call-template>
                </div>
            </div>
            <!-- Generate links grouped by the location of the component-->
            <!-- This is showing by default. -->
            <xsl:variable name="boxId">groupByLocation</xsl:variable>
            <div class="level1" id="toc_group_by_location" style="display:block">
                <!-- This is the displayed div by default -->
                <xsl:choose>
                    <xsl:when test="not($isChunkMode) or $splitInfo/@criteria = $chunkValueLocation">
                        <xsl:attribute name="style" select="'display:block'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="style" select="'display:none'"/>
                    </xsl:otherwise>
                </xsl:choose>
                <div>
                    <xsl:variable name="stylesheetsRefs" select="stylesheetReferences/ref"/>
                    <xsl:for-each-group select="ref" group-by="@location">
                        <xsl:variable name="stylesheetLocation">
                            <xsl:choose>
                                <xsl:when test="'' = @location"/>
                                <xsl:otherwise>
                                    <xsl:value-of select="@location"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <div class="level2">
                            <p>
                                <input id="bt_{$stylesheetLocation}" type="image" value="-"
                                    src="img/btM.gif"
                                    onclick="switchState('{$stylesheetLocation}');" class="control"/>
                                <span class="indexGroupTitle">
                                    <xsl:variable name="stRef"
                                        select="$stylesheetsRefs[@location=$stylesheetLocation]"/>
                                    <xsl:call-template name="reference">
                                        <xsl:with-param name="ref" select="$stRef[1]"/>
                                    </xsl:call-template>
                                    <xsl:if
                                        test="func:substring-before-last($mainFile, '.') = func:substring-before-last($stylesheetLocation, '.')">
                                        <em> - main file</em>
                                    </xsl:if>
                                </span>
                            </p>
                            <div id="{$stylesheetLocation}" style="display:block">
                                <xsl:call-template name="indexGroupByComponent">
                                    <xsl:with-param name="refSeq" select="current-group()"/>
                                    <xsl:with-param name="prefix" select="$stylesheetLocation"/>
                                </xsl:call-template>
                            </div>
                        </div>
                    </xsl:for-each-group>
                </div>
            </div>
        </div>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Template used to generate the table of contents having the components grouped by
                type.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="indexGroupByComponent">
        <xsl:param name="refSeq" required="yes"/>
        <xsl:param name="prefix"/>
        <!-- Use the horizontal layout. -->
        <xsl:for-each-group select="$refSeq" group-by="@refType">
            <xsl:variable name="refType" select="@refType"/>
            <!-- Can put this function of the isChunk -->
            <div class="horizontalLayout">
                <xsl:call-template name="makeRoundedTable">
                    <xsl:with-param name="countTableRows" select="false()"/>
                    <xsl:with-param name="content">
                        <div class="componentGroupTitle">
                            <input id="bt_{$prefix}{$refType}" type="image" value="-"
                                src="img/btM.gif" onclick="switchState('{$prefix}{$refType}');"
                                class="control"/>
                            <xsl:variable name="currentComponent" select="."/>
                            <xsl:value-of
                                select="$componentTypeLabels/*[@key=$currentComponent/@refType]"/>
                            <xsl:if test="count(current-group()) > 1">
                                <xsl:text>s</xsl:text>
                            </xsl:if>
                        </div>
                        <div id="{$prefix}{$refType}" style="display:block">
                            <xsl:for-each select="current-group()">
                                <xsl:sort select="@mode"/>
                                <xsl:sort select="@match"/>
                                <xsl:sort select="@name"/>
                                <xsl:sort select="text()"/>
                                <div class="indentWrapDiv">
                                    <xsl:call-template name="reference"/>
                                </div>
                            </xsl:for-each>
                        </div>
                    </xsl:with-param>
                </xsl:call-template>
            </div>
        </xsl:for-each-group>
        <!-- Back to the vertical layout for the divs. -->
        <div style="clear:left"/>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Template that generates the documentation details for a <xd:b>stylesheet</xd:b>
                module.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="stylesheet">
        <xsl:variable name="stylesheet" select="."/>
        <xsl:call-template name="component">
            <xsl:with-param name="type">
                <xsl:value-of select="$stylesheetTypeLabels/*[@key=$stylesheet/@type]"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Template that generates the documentation details for a <xd:b>template</xd:b>
                component.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="template">
        <xsl:call-template name="component">
            <xsl:with-param name="type">Template</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Template that generates the documentation details for a <xd:b>function</xd:b>
                component.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="function">
        <xsl:call-template name="component">
            <xsl:with-param name="type">Function</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Template that generates the documentation details for a <xd:b>global
                    variable</xd:b>.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="variable">
        <xsl:call-template name="component">
            <xsl:with-param name="type">Variable</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Template that generates the documentation details for an <xd:b>attribute
                    set</xd:b> component.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="attributeSet">
        <xsl:call-template name="component">
            <xsl:with-param name="type">Attribute set</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Template that generates the documentation details for a <xd:b>global
                    parameter</xd:b>.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="parameter">
        <xsl:call-template name="component">
            <xsl:with-param name="type">Parameter</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Template that generates the documentation details for an <xd:b>output</xd:b>
                component.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="output">
        <xsl:call-template name="component">
            <xsl:with-param name="type">Output</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Template that generates the documentation details for a <xd:b>decimal
                    format</xd:b> component.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="decimalFormat">
        <xsl:call-template name="component">
            <xsl:with-param name="type">Decimal format</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Template that generates the documentation details for a <xd:b>character map</xd:b>
                component.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="characterMap">
        <xsl:call-template name="component">
            <xsl:with-param name="type">Character map</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Template that generates the documentation details for a <xd:b>key</xd:b>
                component.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="key">
        <xsl:call-template name="component">
            <xsl:with-param name="type">Key</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Creates the button that allows the user to expand or collapse the section that
                displays a component detail.</xd:p>
        </xd:desc>
        <xd:param name="boxID">The ID of the given section. </xd:param>
        <xd:param name="buttonID">The ID of the button that will be created.</xd:param>
    </xd:doc>
    <xsl:function name="func:createControl" as="item()">
        <xsl:param name="boxID"/>
        <xsl:param name="buttonID"/>
        <input id="{$buttonID}" type="image" src="img/btM.gif" value="-"
            onclick="switchState('{$boxID}');" class="control"/>
    </xsl:function>
    <xd:doc>
        <xd:desc>
            <xd:p>Displays information about the <xd:b>namespace</xd:b> of a component.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="namespace">
        <tr>
            <td class="fCol">Namespace</td>
            <td>
                <xsl:choose>
                    <xsl:when test="text()">
                        <xsl:value-of select="text()"/>
                    </xsl:when>
                    <xsl:otherwise>No namespace</xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Displays information about the <xd:b>match</xd:b> property of a template or a key,
                if it exists.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="match">
        <tr>
            <td class="fCol">Match</td>
            <td>
                <xsl:value-of select="text()"/>
            </td>
        </tr>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Displays information about the <xd:b>mode</xd:b> of a template, if it
                exists.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mode">
        <tr>
            <td class="fCol">Mode</td>
            <td>
                <xsl:value-of select="text()"/>
            </td>
        </tr>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Displays information about the <xd:b>select</xd:b> property of a component, if it
                exists.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="select">
        <tr>
            <td class="fCol">Select</td>
            <td>
                <xsl:value-of select="text()"/>
            </td>
        </tr>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Displays information about the <xd:b>location</xd:b> of the component. </xd:p>
            <xd:p>The location is specified using the URL of the stylesheet where the component was
                declared, relative to the main stylesheet URL.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="stylesheetURL">
        <tr>
            <td class="fCol">Stylesheet location</td>
            <td>
                <xsl:call-template name="reference">
                    <xsl:with-param name="ref" select="ref"/>
                </xsl:call-template>
            </td>
        </tr>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Stylesheet version : 1.0 or 2.0</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="version">
        <tr>
            <td class="fCol">Stylesheet version</td>
            <td>
                <xsl:value-of select="text()"/>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="extensionFunctions">
        <tr>
            <td class="fCol">
                <div class="flL">Extension functions reliance</div>
            </td>
            <td>
                <div>
                    <table class="attsT">
                        <th class="fCol">
                            <div class="flL">Namespace</div>
                        </th>
                        <th class="fCol">
                            <div class="flL">Functions</div>
                        </th>
                        <xsl:for-each-group select="extensionFunction" group-by="@ns">
                            <tr>
                                <td class="fCol">
                                    <xsl:value-of select="current-grouping-key()"/>
                                </td>
                                <td>
                                    <xsl:for-each-group select="current-group()" group-by="@name">
                                        <xsl:sort select="@name"/>
                                        <xsl:if test="position() > 1">
                                            <xsl:text>, </xsl:text>
                                        </xsl:if>
                                        <xsl:element name="span">
                                            <xsl:attribute name="title">
                                                <xsl:variable name="arities"
                                                  select="distinct-values(current-group()/@arity)"/>

                                                <xsl:for-each select="$arities">
                                                  <xsl:text>Arity: </xsl:text>
                                                  <xsl:if test="position() > 1">
                                                  <xsl:text>, </xsl:text>
                                                  </xsl:if>
                                                  <xsl:value-of select="current()"/>

                                                  <xsl:text> Used in: </xsl:text>

                                                  <xsl:variable name="distictLocation"
                                                  select="distinct-values(current-group()[@arity = current()]/location)"/>
                                                  <xsl:for-each select="$distictLocation">
                                                  <xsl:if test="position() > 1">
                                                  <xsl:text>, </xsl:text>
                                                  </xsl:if>
                                                  <xsl:value-of select="current()"/>
                                                  </xsl:for-each>
                                                  <xsl:text>
</xsl:text>
                                                </xsl:for-each>
                                            </xsl:attribute>
                                            <xsl:value-of select="current-grouping-key()"/>
                                        </xsl:element>
                                    </xsl:for-each-group>
                                </td>
                            </tr>
                        </xsl:for-each-group>
                    </table>
                </div>
            </td>
        </tr>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Displays information about the <xd:b>use</xd:b> property of a key.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="use">
        <tr>
            <td class="fCol">Use</td>
            <td>
                <xsl:value-of select="text()"/>
            </td>
        </tr>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Displays information about the <xd:b>collation</xd:b> property of a key.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="collation">
        <tr>
            <td class="fCol">Collation</td>
            <td>
                <xsl:value-of select="text()"/>
            </td>
        </tr>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Template used to generate the tables with used by, references, imported/included
                modules, imported/included from, overriding, supersedes component references</xd:p>
        </xd:desc>
        <xd:param name="title">The title of the table with references</xd:param>
        <xd:param name="addTypesColumn">
            <xd:p><xd:b>true</xd:b> there is to be added an extra column that specifies the
                references type.</xd:p>
        </xd:param>
    </xd:doc>
    <xsl:template name="referencesTable">
        <xsl:param name="title" required="yes"/>
        <xsl:param name="addTypesColumn" as="xs:boolean" select="true()"/>
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <tr>
            <td class="fCol">
                <div class="flL">
                    <xsl:value-of select="$title"/>
                </div>
                <div class="flR">
                    <xsl:copy-of select="func:createControl($boxID, func:getButtonId(.))"/>
                </div>
            </td>
            <td>
                <div id="{$boxID}" style="display:block">
                    <table class="uBT">
                        <xsl:for-each-group select="ref" group-by="@refType">
                            <tr>
                                <xsl:if test="boolean($addTypesColumn)">
                                    <td class="fCol">
                                        <xsl:variable name="currentRef" select="."/>
                                        <xsl:value-of
                                            select="$componentTypeLabels/*[@key=$currentRef/@refType]"/>
                                        <xsl:if test="count(current-group()) > 1">
                                            <xsl:text>s</xsl:text>
                                        </xsl:if>
                                    </td>
                                </xsl:if>
                                <td>
                                    <div class="listGrouping">
                                        <xsl:variable name="count" select="count(current-group())"/>
                                        <xsl:for-each select="current-group()">
                                            <xsl:sort select="@mode"/>
                                            <xsl:sort select="@match"/>
                                            <xsl:sort select="@name"/>
                                            <xsl:sort select="text()"/>
                                            <div class="refItemBlock">
                                                <xsl:call-template name="reference"/>
                                                <xsl:if test="position() &lt; $count">
                                                  <span class="refItemSep">;</span>
                                                </xsl:if>
                                            </div>
                                        </xsl:for-each>
                                    </div>
                                </td>
                            </tr>
                        </xsl:for-each-group>
                    </table>
                </div>
            </td>
        </tr>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Creates a table with the references of the components that are overridden by the
                current component.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="supersedes">
        <xsl:call-template name="referencesTable">
            <xsl:with-param name="title">Supersedes</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Creates a table with the references of the components that override the current
                component.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="overriding">
        <xsl:call-template name="referencesTable">
            <xsl:with-param name="title">Overriding</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Creates a table with the components that are being referred by the current
                component.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="references">
        <xsl:call-template name="referencesTable">
            <xsl:with-param name="title">References</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Creates a table with the components that are referring the current
                component.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="usedBy">
        <xsl:call-template name="referencesTable">
            <xsl:with-param name="title">Used by</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Creates a table with the references of the modules imported by the current
                stylesheet.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="imports">
        <xsl:call-template name="referencesTable">
            <xsl:with-param name="title">Imported modules</xsl:with-param>
            <xsl:with-param name="addTypesColumn" select="false()"/>
        </xsl:call-template>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Creates a table with the references of the modules included by the current
                stylesheet.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="includes">
        <xsl:call-template name="referencesTable">
            <xsl:with-param name="title">Included modules</xsl:with-param>
            <xsl:with-param name="addTypesColumn" select="false()"/>
        </xsl:call-template>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Creates a table with the references of the modules where the current stylesheet is
                being imported from.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="importedFrom">
        <xsl:call-template name="referencesTable">
            <xsl:with-param name="title">Imported from</xsl:with-param>
            <xsl:with-param name="addTypesColumn" select="false()"/>
        </xsl:call-template>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Creates a table with the references of the modules where the current stylesheet is
                being included from.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="includedFrom">
        <xsl:call-template name="referencesTable">
            <xsl:with-param name="title">Included from</xsl:with-param>
            <xsl:with-param name="addTypesColumn" select="false()"/>
        </xsl:call-template>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Displays the <xd:b>XML source</xd:b> of the current component.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="source">
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <tr>
            <td class="fCol">
                <div class="flL">
                    <xsl:choose>
                        <xsl:when test="local-name() = 'source'">Source</xsl:when>
                        <xsl:otherwise>Instance</xsl:otherwise>
                    </xsl:choose>
                </div>
                <div class="flR">
                    <xsl:copy-of select="func:createControl($boxID, func:getButtonId(.))"/>
                </div>
            </td>
            <td>
                <div id="{$boxID}" style="display:block">
                    <!-- Formats an XML source section-->
                    <xsl:variable name="tokens" select="token"/>
                    <xsl:call-template name="formatXmlSource">
                        <xsl:with-param name="tokens" select="$tokens"/>
                    </xsl:call-template>
                </div>
            </td>
        </tr>
    </xsl:template>
    <xd:doc>
        <xd:desc>Formats an XML source section.</xd:desc>
    </xd:doc>
    <xsl:template name="formatXmlSource">
        <xsl:param name="tokens"/>
        <!-- I have to put the PRE in a TABLE to convince the Internet Explorer
            to wrap the PRE. In addition to putting it into a table, the css
            must contain the bloc: 
            
            pre {
            white-space: pre-wrap;       /* css-3 */
            white-space: -moz-pre-wrap;  /* Mozilla, since 1999 */
            white-space: -pre-wrap;      /* Opera 4-6 */
            white-space: -o-pre-wrap;    /* Opera 7 */
            word-wrap: break-word;       /* Internet Explorer 5.5+ */
            _white-space: pre;   /* IE only hack to re-specify in addition to            word-wrap  */
            }
        -->
        <table class="pWCont">
            <tr>
                <td width="100%">
                    <pre>
                        <xsl:for-each select="$tokens">
                            <!-- The content of the token is space preserve -->
                            <xsl:element name="span">
                                <xsl:attribute name="class" select="@type"/>
                                <!-- On IE the pre-wrap does not normalize the text. Doing it here. -->
                                <xsl:choose>
                                    <xsl:when test="@type = 'tT'">
                                        <xsl:choose>
                                            <xsl:when test="text() = ' '">
                                                <!-- Just a whitespace should preserve it, 
                                                    may be it dellimits something.  -->
                                                <xsl:text xml:space="preserve"> </xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:choose>
                                                  <xsl:when test="@xml:space = 'preserve'">
                                                  <xsl:value-of select="text()"/>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <!-- Because we normalize there is no need to keep the whitespace preserve -->
                                                  <xsl:attribute name="style">white-space:normal</xsl:attribute>
                                                  <xsl:value-of select="normalize-space(text())"/>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="text()"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:for-each>
                    </pre>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Creates a table that contains information about the <xd:b>attributes</xd:b> of an
                attribute-set component. </xd:p>
            <xd:p>The details presented in the table are: <xd:i>QName, namespace, type,
                    select</xd:i> and <xd:i>validation</xd:i>.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="attributes">
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <tr>
            <td class="fCol">
                <div class="flL">Attributes</div>
                <div class="flR">
                    <xsl:copy-of select="func:createControl($boxID, func:getButtonId(.))"/>
                </div>
            </td>
            <td>
                <div id="{$boxID}" style="display:block">
                    <table class="attsT">
                        <thead>
                            <tr>
                                <th>QName</th>
                                <xsl:if test="attribute/namespace">
                                    <th>Namespace</th>
                                </xsl:if>
                                <xsl:if test="attribute/type">
                                    <th>Type</th>
                                </xsl:if>
                                <xsl:if test="attribute/select">
                                    <th>Select</th>
                                </xsl:if>
                                <xsl:if test="attribute/validation">
                                    <th>Validation</th>
                                </xsl:if>
                            </tr>
                        </thead>
                        <xsl:for-each select="attribute">
                            <xsl:sort select="qname/text()"/>
                            <tr>
                                <td class="fCol">
                                    <xsl:value-of select="qname"/>
                                </td>
                                <xsl:if test="../attribute/namespace">
                                    <td>
                                        <xsl:value-of select="namespace"/>
                                    </td>
                                </xsl:if>
                                <xsl:if test="../attribute/type">
                                    <td>
                                        <xsl:value-of select="type"/>
                                    </td>
                                </xsl:if>
                                <xsl:if test="../attribute/select">
                                    <td>
                                        <xsl:value-of select="select"/>
                                    </td>
                                </xsl:if>
                                <xsl:if test="../attribute/validation">
                                    <td>
                                        <xsl:value-of select="validation"/>
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
        <xd:desc>
            <xd:p>Creates a table that contains information about the <xd:b>parameters</xd:b> of a
                template or a function.</xd:p>
            <xd:p>The details presented in the table are: <xd:i>QName, namespace, type, select,
                    required</xd:i> and <xd:i>tunnel</xd:i></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="parameters">
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <tr>
            <td class="fCol">
                <div class="flL">Parameters</div>
                <div class="flR">
                    <xsl:copy-of select="func:createControl($boxID, func:getButtonId(.))"/>
                </div>
            </td>
            <td>
                <div id="{$boxID}" style="display:block">
                    <table class="attsT">
                        <xsl:variable name="nsExists" select="parameter/namespace"/>
                        <xsl:variable name="selectExists" select="parameter/select"/>
                        <xsl:variable name="typeExists" select="parameter/type"/>
                        <xsl:variable name="requiredExists" select="parameter/required"/>
                        <xsl:variable name="tunnelExists" select="parameter/tunnel"/>
                        <thead>
                            <tr>
                                <th>QName</th>
                                <xsl:if test="$nsExists">
                                    <th>Namespace</th>
                                </xsl:if>
                                <xsl:if test="$selectExists">
                                    <th>Select</th>
                                </xsl:if>
                                <xsl:if test="$typeExists">
                                    <th>Type</th>
                                </xsl:if>
                                <xsl:if test="$requiredExists">
                                    <th>Required</th>
                                </xsl:if>
                                <xsl:if test="$tunnelExists">
                                    <th>Tunnel</th>
                                </xsl:if>
                            </tr>
                        </thead>
                        <xsl:for-each select="parameter">
                            <xsl:sort select="qname/text()"/>
                            <tr>
                                <td class="fCol">
                                    <xsl:value-of select="qname"/>
                                </td>
                                <xsl:if test="$nsExists">
                                    <td>
                                        <xsl:choose>
                                            <xsl:when test="namespace/text()">
                                                <xsl:value-of select="namespace"/>
                                            </xsl:when>
                                            <xsl:otherwise>No namespace</xsl:otherwise>
                                        </xsl:choose>
                                    </td>
                                </xsl:if>
                                <xsl:if test="$selectExists">
                                    <td>
                                        <xsl:value-of select="select"/>
                                    </td>
                                </xsl:if>
                                <xsl:if test="$typeExists">
                                    <td>
                                        <xsl:value-of select="type"/>
                                    </td>
                                </xsl:if>
                                <xsl:if test="$requiredExists">
                                    <td>
                                        <xsl:value-of select="required"/>
                                    </td>
                                </xsl:if>
                                <xsl:if test="$tunnelExists">
                                    <td>
                                        <xsl:value-of select="tunnel"/>
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
        <xd:desc>
            <xd:p>Creates a table that contains information about the <xd:b>ouput</xd:b> component
                properties. </xd:p>
            <xd:p>The details presented in the table are: </xd:p>
            <xd:ul>
                <xd:li>
                    <xd:p><xd:i>byte-order-mark</xd:i>;</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:i>cdata-section-elements</xd:i>;</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:i>doctype-public</xd:i>;</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:i>doctype-system</xd:i>;</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:i>encoding</xd:i>;</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:i>escape-uri-attributes</xd:i>;</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:i>include-content-type</xd:i>;</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:i>indent</xd:i>;</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:i>media-type</xd:i>;</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:i>method</xd:i>;</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:i>normalization-form</xd:i>;</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:i>omit-xml-declaration</xd:i>;</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:i>standalone</xd:i>;</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:i>undeclare-prefixes</xd:i>;</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:i>use-character-maps</xd:i>;</xd:p>
                </xd:li>
            </xd:ul>
        </xd:desc>
    </xd:doc>
    <xsl:template name="outputProperties">
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <xsl:variable name="outputProperties">
            <entry>byte-order-mark</entry>
            <entry>cdata-section-elements</entry>
            <entry>doctype-public</entry>
            <entry>doctype-system</entry>
            <entry>encoding</entry>
            <entry>escape-uri-attributes</entry>
            <entry>include-content-type</entry>
            <entry>indent</entry>
            <entry>media-type</entry>
            <entry>method</entry>
            <entry>normalization-form</entry>
            <entry>omit-xml-declaration</entry>
            <entry>standalone</entry>
            <entry>undeclare-prefixes</entry>
            <entry>use-character-maps</entry>
        </xsl:variable>
        <tr>
            <td class="fCol">
                <div class="flL">Output properties</div>
                <div class="flR">
                    <xsl:copy-of select="func:createControl($boxID, func:getButtonId(.))"/>
                </div>
            </td>
            <td>
                <div id="{$boxID}" style="display:block">
                    <table class="attsT">
                        <thead>
                            <tr>
                                <xsl:for-each select="node()">
                                    <xsl:variable name="localName" select="local-name()"/>
                                    <xsl:if test="$outputProperties/*[text() = $localName]">
                                        <th>
                                            <xsl:value-of select="$localName"/>
                                        </th>
                                    </xsl:if>
                                </xsl:for-each>
                            </tr>
                        </thead>
                        <tr>
                            <xsl:for-each select="node()">
                                <xsl:variable name="localName" select="local-name()"/>
                                <xsl:if test="$outputProperties/*[text() = $localName]">
                                    <td>
                                        <xsl:value-of select="text()"/>
                                    </td>
                                </xsl:if>
                            </xsl:for-each>
                        </tr>
                    </table>
                </div>
            </td>
        </tr>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Creates a table that contains information about the <xd:b>decimal-format</xd:b>
                component properties. </xd:p>
            <xd:p>The details presented in the table are: </xd:p>
            <xd:ul>
                <xd:li>
                    <xd:p><xd:i>decimal-separator</xd:i>;</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:i>digit</xd:i>;</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:i>grouping-separator</xd:i>;</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:i>infinity</xd:i>;</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:i>minus-sign</xd:i>;</xd:p>
                    <xd:p><xd:i>NaN</xd:i>;</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:i>pattern-separator</xd:i>;</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:i>per-mille</xd:i>;</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:i>percent</xd:i>;</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:i>zero-digit</xd:i>;</xd:p>
                </xd:li>
            </xd:ul>
        </xd:desc>
    </xd:doc>
    <xsl:template name="decimalFormatProperties">
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <xsl:variable name="dfProperties">
            <entry>decimal-separator</entry>
            <entry>digit</entry>
            <entry>grouping-separator</entry>
            <entry>infinity</entry>
            <entry>minus-sign</entry>
            <entry>NaN</entry>
            <entry>pattern-separator</entry>
            <entry>per-mille</entry>
            <entry>percent</entry>
            <entry>zero-digit</entry>
        </xsl:variable>
        <tr>
            <td class="fCol">
                <div class="flL">Decimal format properties</div>
                <div class="flR">
                    <xsl:copy-of select="func:createControl($boxID, func:getButtonId(.))"/>
                </div>
            </td>
            <td>
                <div id="{$boxID}" style="display:block">
                    <table class="attsT">
                        <thead>
                            <tr>
                                <xsl:for-each select="node()">
                                    <xsl:variable name="localName" select="local-name()"/>
                                    <xsl:if test="$dfProperties/*[text() = $localName]">
                                        <th>
                                            <xsl:value-of select="$localName"/>
                                        </th>
                                    </xsl:if>
                                </xsl:for-each>
                            </tr>
                        </thead>
                        <tr>
                            <xsl:for-each select="node()">
                                <xsl:variable name="localName" select="local-name()"/>
                                <xsl:if test="$dfProperties/*[text() = $localName]">
                                    <td>
                                        <xsl:value-of select="text()"/>
                                    </td>
                                </xsl:if>
                            </xsl:for-each>
                        </tr>
                    </table>
                </div>
            </td>
        </tr>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Generates the subsection of the <xd:b>character-map</xd:b> component that contains
                character mappings.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="characters">
        <xsl:variable name="boxID" select="func:getDivId(.)"/>
        <tr>
            <td class="fCol">
                <div class="flL">Characters</div>
                <div class="flR">
                    <xsl:copy-of select="func:createControl($boxID, func:getButtonId(.))"/>
                </div>
            </td>
            <td>
                <div id="{$boxID}" style="display:block">
                    <table>
                        <tr>
                            <xsl:message>
                                <xsl:value-of select="xs:integer(count(outputCharacter) div 7)"/>
                            </xsl:message>
                            <xsl:call-template name="outputCharacter">
                                <xsl:with-param name="currentCharacter" select="outputCharacter[1]"/>
                                <xsl:with-param name="index" select="1"/>
                                <xsl:with-param name="chunkSize"
                                    select="xs:integer(ceiling(count(outputCharacter) div 7))"/>
                            </xsl:call-template>
                        </tr>
                    </table>
                </div>
            </td>
        </tr>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Generates the small character chunks tables. To avoid having a very long table, it
                will be split into several tables. The number of rows of a table is given by the
                value of the <xd:i>$chunkSize</xd:i> parameter.</xd:p>
        </xd:desc>
        <xd:param name="currentCharacter">
            <xd:p>The current character.</xd:p>
        </xd:param>
        <xd:param name="index">
            <xd:p>The index of the current character.</xd:p>
        </xd:param>
        <xd:param name="chunkSize">
            <xd:p>The maximum number of rows that a table will have.</xd:p>
        </xd:param>
    </xd:doc>
    <xsl:template name="outputCharacter">
        <xsl:param name="currentCharacter"/>
        <xsl:param name="index"/>
        <xsl:param name="chunkSize" as="xs:integer"/>
        <xsl:if test="$index mod $chunkSize = 1">
            <td>
                <table class="attsT">
                    <thead>
                        <tr>
                            <th>Character</th>
                            <th>String</th>
                        </tr>
                    </thead>
                    <xsl:call-template name="outputCharRow">
                        <xsl:with-param name="currentCharacter" select="$currentCharacter"/>
                        <xsl:with-param name="index" select="$index"/>
                        <xsl:with-param name="counter" select="0"/>
                        <xsl:with-param name="chunkSize" select="$chunkSize"/>
                    </xsl:call-template>
                </table>
                <xsl:if test="$currentCharacter/following-sibling::outputCharacter[$chunkSize]">
                    <xsl:call-template name="outputCharacter">
                        <xsl:with-param name="currentCharacter"
                            select="$currentCharacter/following-sibling::outputCharacter[$chunkSize]"/>
                        <xsl:with-param name="index" select="$index + $chunkSize"/>
                        <xsl:with-param name="chunkSize" select="$chunkSize"/>
                    </xsl:call-template>
                </xsl:if>
            </td>
        </xsl:if>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Generate a row inside a character table.</xd:p>
        </xd:desc>
        <xd:param name="currentCharacter">
            <xd:p>The current character.</xd:p>
        </xd:param>
        <xd:param name="index">
            <xd:p>The index of the current character.</xd:p>
        </xd:param>
        <xd:param name="chunkSize">
            <xd:p>The maximum number of rows that a table will have.</xd:p>
        </xd:param>
    </xd:doc>
    <xsl:template name="outputCharRow">
        <xsl:param name="currentCharacter"/>
        <xsl:param name="index"/>
        <xsl:param name="counter"/>
        <xsl:param name="chunkSize" as="xs:integer"/>
        <xsl:if test="$counter &lt; $chunkSize">
            <tr>
                <td class="fCol">
                    <xsl:value-of select="$currentCharacter/character"/>
                </td>
                <td>
                    <xsl:value-of select="$currentCharacter/string"/>
                </td>
            </tr>
            <xsl:if test="$currentCharacter/following-sibling::outputCharacter[1]">
                <xsl:call-template name="outputCharRow">
                    <xsl:with-param name="currentCharacter"
                        select="$currentCharacter/following-sibling::outputCharacter[1]"/>
                    <xsl:with-param name="index" select="$index + 1"/>
                    <xsl:with-param name="counter" select="$counter + 1"/>
                    <xsl:with-param name="chunkSize" select="$chunkSize"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>The template that generates the properties table for a component.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="component">
        <xsl:param name="type"/>
        <xsl:element name="a">
            <xsl:attribute name="id" select="@id"/>
        </xsl:element>
        <div class="cmpT">
            <xsl:value-of select="$type"/>
            <xsl:text>
            </xsl:text>
            <xsl:choose>
                <xsl:when test="$type = 'Template' and match/text()">
                    <xsl:if test="match/text()">
                        <span class="titleTemplateMatch">
                            <xsl:value-of select="match/text()"/>
                        </span>
                    </xsl:if>
                    <xsl:if test="qname/text()">
                        <span class="titleTemplateName">
                            <xsl:value-of select="qname/text()"/>
                        </span>
                    </xsl:if>
                    <xsl:if test="mode/text() and not(mode/text() = '#default')">
                        <span class="titleTemplateMode">
                            <xsl:value-of select="mode/text()"/>
                        </span>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="name() = 'template'">
                            <span class="titleTemplateName">
                                <xsl:value-of select="qname/text()"/>
                            </span>
                        </xsl:when>
                        <xsl:otherwise>
                            <span class="qname">
                                <xsl:choose>
                                    <xsl:when test="$type = 'Output' and not(qname)">
                                        <xsl:text>(default)</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:choose>
                                            <xsl:when test="$type = 'Function'">
                                                <xsl:value-of select="qname/text()"/>
                                                <xsl:text> (</xsl:text>
                                                <span class="fParams">
                                                    <xsl:for-each select="parameters/parameter">
                                                        <xsl:if test="position() > 1">
                                                            <xsl:text>, </xsl:text>
                                                        </xsl:if>
                                                        <xsl:value-of select="qname"/>
                                                    </xsl:for-each>
                                                </span>
                                                <xsl:text>)</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="qname/text()"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </div>
        <xsl:call-template name="makeRoundedTable">
            <xsl:with-param name="countTableRows" select="true()"/>
            <xsl:with-param name="content">
                <table class="component">
                    <tbody>
                        <!-- There can be multiple documentation blocks -->
                        <xsl:if test="docSection">
                            <xsl:variable name="boxID" select="func:getDivId(docSection)"/>
                            <tr>
                                <td class="fCol">
                                    <div class="flL">Documentation</div>
                                    <div class="flR">
                                        <xsl:copy-of
                                            select="func:createControl($boxID, func:getButtonId(docSection))"
                                        />
                                    </div>
                                </td>
                                <td>
                                    <div id="{$boxID}" style="display:block">
                                        <xsl:for-each select="docSection/*">
                                            <xsl:if test="position() > 1">
                                                <hr/>
                                            </xsl:if>
                                            <xsl:apply-templates select="." mode="documentation"/>
                                        </xsl:for-each>
                                    </div>
                                </td>
                            </tr>
                        </xsl:if>
                        <xsl:apply-templates select="namespace"/>
                        <xsl:apply-templates select="type | match | mode | select | use | collation"/>
                        <xsl:apply-templates
                            select="supersedes | overriding | usedBy | references | attributes | parameters | characters | importPrecedence | priority"/>
                        <xsl:apply-templates
                            select="imports | includes | importedFrom | includedFrom"/>
                        <xsl:apply-templates select="version"/>
                        <xsl:apply-templates select="extensionFunctions"/>
                        <xsl:if test="local-name() = 'output'">
                            <!-- Output properties template -->
                            <xsl:call-template name="outputProperties"/>
                        </xsl:if>
                        <xsl:if test="local-name() = 'decimalFormat'">
                            <!-- Decimal format properties template -->
                            <xsl:call-template name="decimalFormatProperties"/>
                        </xsl:if>
                        <xsl:apply-templates select="source"/>
                        <xsl:if test="not(local-name() = 'stylesheet')">
                            <xsl:apply-templates select="stylesheetURL"/>
                        </xsl:if>
                    </tbody>
                </table>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:if test="not(boolean($isChunkMode))">
            <div class="toTop">
                <a href="#INDEX"> [ top ] </a>
            </div>
        </xsl:if>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Displays the <xd:b>type</xd:b> property for a function (return type), a parameter
                or a variable.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="parameter/type | function/type | variable/type">
        <tr>
            <td class="fCol">Type</td>
            <td>
                <xsl:value-of select="text()"/>
            </td>
        </tr>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Draws a table with rounded corners that will contain all the properties of a
                component.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="makeRoundedTable">
        <xsl:param name="content" required="yes"/>
        <xsl:param name="countTableRows" required="yes" as="xs:boolean"/>
        <xsl:variable name="counter" select="count($content//html:tr)"
            xmlns:html="http://www.w3.org/1999/xhtml"/>
        <xsl:if test="not($countTableRows) or $counter > 0">
            <table class="rt">
                <tr>
                    <td class="rt_cTL"/>
                    <td class="rt_lT"/>
                    <td class="rt_cTR"/>
                </tr>
                <tr>
                    <td class="rt_lL"/>
                    <td class="rt_cnt">
                        <xsl:copy-of select="$content"/>
                    </td>
                    <td class="rt_lR"/>
                </tr>
                <tr>
                    <td class="rt_cBL"/>
                    <td class="rt_lB"/>
                    <td class="rt_cBR"/>
                </tr>
            </table>
        </xsl:if>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>The main template which generates the XSLT Documentation.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="main">
        <body>
            <xsl:if test="$showFloatMenu">
                <!-- The position must be absolute for the floating mechanism to work. -->
                <xsl:if
                    test="string-length($attributesBoxes) > 0 
                    or string-length($usedByBoxes) > 0
                    or string-length($docBoxes) > 0
                    or string-length($sourceBoxes) > 0
                    or string-length($supersedesBoxes) > 0 
                    or string-length($overridingBoxes) > 0 
                    or string-length($parametersBoxes) > 0 
                    or string-length($charactersBoxes) > 0
                    or string-length($referencesBoxes) > 0
                    or string-length($importsBoxes) > 0
                    or string-length($includesBoxes) > 0
                    or string-length($importedFromBoxes) > 0
                    or string-length($includedFromBoxes) > 0">
                    <div id="global_controls" class="globalControls"
                        style="position:absolute;right:0;">
                        <xsl:call-template name="makeRoundedTable">
                            <xsl:with-param name="countTableRows" select="false()"/>
                            <xsl:with-param name="content">
                                <h3>Mode:</h3>
                                <table>
                                    <tr>
                                        <td>
                                            <span>
                                                <input type="checkbox" value="-" checked="checked"
                                                  onclick="switchMode(this);" class="control"/>
                                            </span>
                                            <span class="globalControlName">Compact lists</span>
                                        </td>
                                    </tr>
                                </table>
                                <h3>Showing:</h3>
                                <table>
                                    <xsl:if test="string-length($docBoxes) > 0">
                                        <tr>
                                            <td>
                                                <span>
                                                  <input type="checkbox" value="-" checked="checked"
                                                  onclick="switchStateForAll(this, docBoxes);"
                                                  class="control"/>
                                                </span>
                                                <span class="globalControlName">Documentation
                                                </span>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="string-length($attributesBoxes) > 0">
                                        <tr>
                                            <td>
                                                <span>
                                                  <input type="checkbox" value="-" checked="checked"
                                                  onclick="switchStateForAll(this, attributesBoxes);"
                                                  class="control"/>
                                                </span>
                                                <span class="globalControlName">Attributes </span>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="string-length($parametersBoxes) > 0">
                                        <tr>
                                            <td>
                                                <span>
                                                  <input type="checkbox" value="-" checked="checked"
                                                  onclick="switchStateForAll(this, parametersBoxes);"
                                                  class="control"/>
                                                </span>
                                                <span class="globalControlName">Parameters </span>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="string-length($usedByBoxes) > 0">
                                        <tr>
                                            <td>
                                                <span>
                                                  <input type="checkbox" value="-" checked="checked"
                                                  onclick="switchStateForAll(this, usedByBoxes);"
                                                  class="control"/>
                                                </span>
                                                <span class="globalControlName">Used by </span>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="string-length($referencesBoxes) > 0">
                                        <tr>
                                            <td>
                                                <span>
                                                  <input type="checkbox" value="-" checked="checked"
                                                  onclick="switchStateForAll(this, referencesBoxes);"
                                                  class="control"/>
                                                </span>
                                                <span class="globalControlName">References </span>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="string-length($supersedesBoxes) > 0">
                                        <tr>
                                            <td>
                                                <span>
                                                  <input type="checkbox" value="-" checked="checked"
                                                  onclick="switchStateForAll(this, supersedesBoxes);"
                                                  class="control"/>
                                                </span>
                                                <span class="globalControlName">Supersedes </span>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="string-length($overridingBoxes) > 0">
                                        <tr>
                                            <td>
                                                <span>
                                                  <input type="checkbox" value="-" checked="checked"
                                                  onclick="switchStateForAll(this, overridingBoxes);"
                                                  class="control"/>
                                                </span>
                                                <span class="globalControlName">Overriding </span>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="string-length($importsBoxes) > 0">
                                        <tr>
                                            <td>
                                                <span>
                                                  <input type="checkbox" value="-" checked="checked"
                                                  onclick="switchStateForAll(this, importsBoxes);"
                                                  class="control"/>
                                                </span>
                                                <span class="globalControlName">Imported modules
                                                </span>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="string-length($includesBoxes) > 0">
                                        <tr>
                                            <td>
                                                <span>
                                                  <input type="checkbox" value="-" checked="checked"
                                                  onclick="switchStateForAll(this, includesBoxes);"
                                                  class="control"/>
                                                </span>
                                                <span class="globalControlName">Included modules
                                                </span>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="string-length($importedFromBoxes) > 0">
                                        <tr>
                                            <td>
                                                <span>
                                                  <input type="checkbox" value="-" checked="checked"
                                                  onclick="switchStateForAll(this, importedFromBoxes);"
                                                  class="control"/>
                                                </span>
                                                <span class="globalControlName">Imported from
                                                </span>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="string-length($includedFromBoxes) > 0">
                                        <tr>
                                            <td>
                                                <span>
                                                  <input type="checkbox" value="-" checked="checked"
                                                  onclick="switchStateForAll(this, includedFromBoxes);"
                                                  class="control"/>
                                                </span>
                                                <span class="globalControlName">Included from
                                                </span>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="string-length($sourceBoxes) > 0">
                                        <tr>
                                            <td>
                                                <span>
                                                  <input type="checkbox" value="-" checked="checked"
                                                  onclick="switchStateForAll(this, sourceBoxes);"
                                                  class="control"/>
                                                </span>
                                                <span class="globalControlName">Source </span>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="string-length($charactersBoxes) > 0">
                                        <tr>
                                            <td>
                                                <span>
                                                  <input type="checkbox" value="-" checked="checked"
                                                  onclick="switchStateForAll(this, charactersBoxes);"
                                                  class="control"/>
                                                </span>
                                                <span class="globalControlName">Characters </span>
                                            </td>
                                        </tr>
                                    </xsl:if>
                                </table>
                                <div align="right">
                                    <span>
                                        <input type="button"
                                            onclick="getElementObject('global_controls').style.display = 'none';"
                                            value="Close"/>
                                    </span>
                                </div>
                            </xsl:with-param>
                        </xsl:call-template>
                    </div>
                </xsl:if>
            </xsl:if>
            <xsl:for-each select="index">
                <xsl:call-template name="index"/>
            </xsl:for-each>
            <xsl:apply-templates
                select="stylesheet | template | function | parameter | variable | attributeSet | key | output | decimalFormat | characterMap"/>
            <div class="footer">
                <hr/>
                <div align="center">Stylesheet documentation generated by <a
                        href="http://www.oxygenxml.com" target="_parent">
                        <span class="oXygenLogo"><span class="redX">&lt;</span>o<span class="redX"
                                >X</span>ygen<span class="redX">/&gt;</span></span>
                    </a><sup>&#174;</sup> XML <xsl:value-of select="$distribution"/>.</div>
            </div>
            <script type="text/javascript">
                <xsl:comment>
                    // The namespace is the selected option in the TOC combo.
                    
                    // The corresponding div is already visible conf. to its style attr.                     
                    <xsl:choose>                                            
                        <xsl:when test="$splitInfo/@criteria = $chunkValueLocation">
                            var selectToc = getElementObject('selectTOC');
                            if(selectToc != null){
                            // It can be null when having chunking, the combo of the TOC is in another frame.
                            selectToc.selectedIndex = 0;
                            }
                        </xsl:when>
                        <xsl:when test="$splitInfo/@criteria = $chunkValueComponent">
                            var selectToc = getElementObject('selectTOC');
                            if(selectToc != null){
                            // It can be null when having chunking, the combo of the TOC is in another frame.
                            selectToc.selectedIndex = 1;
                            }
                        </xsl:when>
                        <xsl:when test="$splitInfo/@criteria = $chunkValueNamespace">
                            var selectToc = getElementObject('selectTOC');
                            if(selectToc != null){
                            // It can be null when having chunking, the combo of the TOC is in another frame.
                            selectToc.selectedIndex = 2;
                            }
                        </xsl:when>
                    </xsl:choose>
                    
                    // Floats the toolbar.
                    var globalControls = getElementObject("global_controls"); 
                    
                    if(globalControls != null){
                    var browser=navigator.appName;
                    var version = parseFloat(navigator.appVersion.split('MSIE')[1]);
                    
                    var IE6 = false;
                    if ((browser=="Microsoft Internet Explorer") &amp;&amp; (version &lt; 7)){
                    IE6 = true;
                    }
                    
                    //alert (IE6 + " |V| " + version);
                    
                    if(IE6){
                    // On IE 6 the 'fixed' property is not supported. We must use javascript. 
                    globalControls.style.position='absolute';                         
                    // The global controls will do not exist in the TOC frame, when chunking.
                    findAndFloat("global_controls", 225, 30);    
                    } else {
                    globalControls.style.position='fixed';                     	
                    }
                    
                    globalControls.style.right='0';                       
                    }
                //</xsl:comment>
            </script>
        </body>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Displays the <xd:i>"import precedence"</xd:i> property of a component.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="importPrecedence">
        <tr>
            <td class="fCol">Import precedence</td>
            <td>
                <xsl:value-of select="text()"/>
            </td>
        </tr>
    </xsl:template>
    <xd:doc>
        <xd:desc>
            <xd:p>Displays the <xd:i>"priority"</xd:i> property of a component.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="priority">
        <tr>
            <td class="fCol">Priority</td>
            <td>
                <xsl:value-of select="text()"/>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>
