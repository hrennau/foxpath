<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    xmlns:oxy="http://www.oxygenxml.com/extensions/author"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:ImageInfo="java:ImageInfo" exclude-result-prefixes="#all">
    <!--
    	
    	
        Index fixes.
		
        Adds an id for each indexterm.
        In the group of indexterms make sure there are pointers back to the indexterms from the content.
        Prince needs this in order to create the index links.
		
    -->
    
    <!-- If the index structure is empty, do not copy it to the output. -->
    <xsl:template match="opentopic-index:index.groups[count(*) = 0]" priority="2"/>
    
    
    <xsl:key name="index-leaf-definitions" match="//*[contains(@class, ' topic/topic ')]//opentopic-index:refID[not(../opentopic-index:index.entry)]" use="@value"/>
    <!-- For each refID in the content, make sure there is an @id attribute for it. -->
    <xsl:template match="*[contains(@class, ' topic/topic ')]//opentopic-index:refID">
        <xsl:copy>
            <xsl:attribute name="id">
                <xsl:value-of select="generate-id(.)"/>
            </xsl:attribute>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="opentopic-index:index.groups//opentopic-index:refID[@value]">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>

            <xsl:variable name="for-value" select="@value"/>
            <!-- Find in the content all the definitions that are leafs. Add links from the index to these elements. -->
            <xsl:for-each
                select="key('index-leaf-definitions', $for-value)">
                <oxy:index-link href="#{generate-id(.)}"> [<xsl:value-of select="generate-id(.)"/>]
                </oxy:index-link>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

    <!-- Put an id on the index element, this way we can linked it from the table of contents. -->
    <xsl:template match="opentopic-index:index.groups">
        <xsl:copy>
            <xsl:attribute name="id">
                <xsl:value-of select="generate-id(.)"/>
            </xsl:attribute>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- 
        Deal with <index-see> and <index-see-also>. 
        
        The <index-see> should list the labels of the index terms the user needs to see. 
        No page number should be shown, since this is a pure redirection. 
        
        The <index-see-also> should list the labels of the index terms the user needs to see. 
        The page numbers must be shown.     
    -->
    <!-- No page numbers to the main index term, is a redirection -->
    <xsl:template match="opentopic-index:index.groups//opentopic-index:refID[../opentopic-index:see-childs]" priority="2"/>
    <!-- No page numbers into the list of index terms -->
    <xsl:template match="opentopic-index:index.groups//opentopic-index:see-childs//opentopic-index:refID" priority="2"/>
    <xsl:template match="opentopic-index:index.groups//opentopic-index:see-also-childs//opentopic-index:refID" priority="2"/>
    
    
    
</xsl:stylesheet>