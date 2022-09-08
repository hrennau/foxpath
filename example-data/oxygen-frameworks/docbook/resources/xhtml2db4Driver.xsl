<!-- 
  Copyright 2001-2012 Syncro Soft SRL. All rights reserved.
 -->
<xsl:stylesheet version="3.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:e="http://www.oxygenxml.com/xsl/conversion-elements"
    xmlns:f="http://www.oxygenxml.com/xsl/functions"
    exclude-result-prefixes="xsl xhtml e f">
    
    <xsl:import href="filterNodes.xsl"/>
    <xsl:import href="convertToCode.xsl"/>
    <xsl:import href="mergeCodeSiblings.xsl"/>
    <xsl:import href="breakLines.xsl"/>
    <xsl:import href="wrapGlobalInlineNodesInPara.xsl"/>
    <xsl:import href="nestedSections.xsl"/>
    <xsl:import href="nestedLists.xsl"/>
    <xsl:import href="processInTableContext.xsl"/>
    <xsl:import href="setNamespace.xsl"/>
    <xsl:include href="xhtml2db4.xsl"/>
    <xsl:include href="xhtml2db4HtmlTable.xsl"/>
    <xsl:include href="xhtml2db4CalsTable.xsl"/>
    
    <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
    
    <xsl:param name="folderOfPasteTargetXml"/>
    
    <!-- 
           Set it to non-zero if you want to paste a table 
           as a HTML table in a Docbook XML file. 
           If it is zero only CALS tables are pasted in a Docbook document.
     -->
    <xsl:param name="docbook.html.table" select="0"/>
  
    <!-- 
        The item separator.
      -->
    <xsl:param name="context.item.separator" select="','"/>
    
    <!-- 
      The context where the generated fragment will be inserted. 
      This parameter lists the local names, starting with the root up to the context element. 
     -->   
    <xsl:param name="context.path.names" select="''"/>
    <xsl:param name="context.path.names.sequence" 
                        select="tokenize($context.path.names, $context.item.separator)"/>
    
    <!-- 
      The context where the generated fragment will be inserted. 
      This parameter lists the namespaces, starting with the root up to the context element. 
     -->   
    <xsl:param name="context.path.uris" select="''"/>
    <xsl:param name="context.path.uris.sequence" 
                        select="tokenize($context.path.uris, $context.item.separator)"/>
    
    <!-- Helper variables. -->
    <xsl:variable name="context.path.last.name" select="tokenize($context.path.names, $context.item.separator)[last()]"/>
    <xsl:variable name="context.path.last.uri" select="tokenize($context.path.uris, $context.item.separator)[last()]"/>

    <!-- true if we are pasting in a table context (between rows for example or having various table cells selected.
    If so, we'll paste only table rows.
    -->
    <xsl:param name="inTableContext"/>

    <xsl:template match="/">
        <!--
        <xsl:message>======== folderOfPasteTargetXml: <xsl:value-of select="$folderOfPasteTargetXml"/></xsl:message>
        <xsl:message>======== context.path.names: <xsl:value-of select="$context.path.names"/></xsl:message>
        <xsl:message>======== context.path.uris: <xsl:value-of select="$context.path.uris"/></xsl:message>
        <xsl:message>======== context.item.separator: <xsl:value-of select="$context.item.separator"/></xsl:message>
        -->
        
        <!-- Convert all spans with Courier New font to "code" elements-->
        <xsl:variable name="codeWrap">
            <xsl:apply-templates mode="code"/>
        </xsl:variable>
        <!--        <xsl:message> CODE WRAP <xsl:copy-of select="$codeWrap"/></xsl:message>        -->
        
        <!-- Merge siblings "code"s. -->
        <xsl:variable name="mergeCodeSiblings">
            <xsl:apply-templates select="$codeWrap" mode="merge"/>
        </xsl:variable>
<!--        <xsl:message> MERGE SIBLINGS: <xsl:copy-of select="$mergeCodeSiblings"></xsl:copy-of>$></xsl:message>-->

        <!-- Filter unused tags, transform MS Word titles to H1 elements. -->
        <xsl:variable name="processedFilterNodes">
            <xsl:apply-templates select="$mergeCodeSiblings" mode="filterNodes"/>
        </xsl:variable>
        <!--
        <xsl:message>111111111  <xsl:copy-of select="$processedFilterNodes"/></xsl:message>
        <xsl:result-document href="output-filterNodes-1.xml">
            <xsl:copy-of select="$processedFilterNodes"/>
        </xsl:result-document>
        -->
        
        <!-- Breask lines at <br/> elements. -->
        <xsl:variable name="processedBreakLines">
            <xsl:apply-templates select="$processedFilterNodes" mode="breakLines"/>
        </xsl:variable>
        <!--
        <xsl:message>222222222  <xsl:copy-of select="$processedBreakLines"/></xsl:message>
        <xsl:result-document href="output-breakLines-2.xml">
            <xsl:copy-of select="$processedBreakLines"/>
        </xsl:result-document>
        -->
        
        <!-- Wrap inline nodes at global level (xhtml:body) in xhtml:p elements. -->
        <xsl:variable name="processedWrapGlobalText">
            <xsl:apply-templates select="$processedBreakLines" mode="wrapGlobalText"/>
        </xsl:variable>
        <!--
        <xsl:message>333333333  <xsl:copy-of select="$processedWrapGlobalText"/></xsl:message>
        <xsl:result-document href="output-wrapGlobalText-3.xml">
            <xsl:copy-of select="$processedWrapGlobalText"/>
        </xsl:result-document>
        -->
        
        <!-- Transform list of header and para elements to nested sections. -->
        <xsl:variable name="processedSections">
            <xsl:apply-templates select="$processedWrapGlobalText" mode="nestedSections"/>
        </xsl:variable>
        <!--
        <xsl:message>444444444  <xsl:copy-of select="$processedSections"/></xsl:message>
        <xsl:result-document href="output-sections-4.xml">
            <xsl:copy-of select="$processedSections"/>
        </xsl:result-document>
        -->
        
        <!-- Transform list of para elements from MS Word to nested lists.-->
        <xsl:variable name="processedLists">
            <xsl:apply-templates select="$processedSections" mode="nestedLists"/>
        </xsl:variable>
        <!--
        <xsl:message>555555555   <xsl:copy-of select="$processedLists"/></xsl:message>
        <xsl:result-document href="output-lists-5.xml">
            <xsl:copy-of select="$processedLists"/>
        </xsl:result-document>
        -->
        
        <xsl:variable name="processedNamespace">
            <xsl:apply-templates select="$processedLists" mode="setNamespace"/>
        </xsl:variable>
        <!--
        <xsl:message>666666666 <xsl:copy-of select="$processedNamespace"/></xsl:message>
        <xsl:result-document href="output-namespace-6.xml">
            <xsl:copy-of select="$processedNamespace"/>
        </xsl:result-document>
        -->
        
        <!-- Generate content for current Author framework. -->
        <xsl:variable name="processed">
            <xsl:apply-templates select="$processedNamespace/*"/>
        </xsl:variable>
        <!-- If we are inside a table and pasting there, unwrap the table structure above the rows. -->
        <xsl:apply-templates select="$processed" mode="processInTableContext"/>
        
    </xsl:template>
</xsl:stylesheet>