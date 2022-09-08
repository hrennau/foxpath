<!-- 
    This stylesheet identifies the "chapters" and book "parts" from the map (can be a bookmap or ordinary map) both
    in the TOC and the content.
    
    The identified chapters are marked with the attribute @is-chapter='true'.
    The identified parts are marked with the attribute @is-part='true'.         
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    xmlns:oxy="http://www.oxygenxml.com/extensions/author"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:ImageInfo="java:ImageInfo" exclude-result-prefixes="#all">
    
    
    <!-- 
        
        Mark the chapters, so their titles can be presented differently in the TOC. 
    
        Details:
        
        We are using the @class attribute as a "hook" to inject the new attributes. We use this 
        technique to avoid writing a template that generates a new element and would override the fixes from
        the "post-process-toc.xsl".
        
    -->
    <xsl:template match="opentopic:map//*[oxy:is-chapter(/, .)]/@class">
        <xsl:attribute name="is-chapter">true</xsl:attribute>
        <xsl:if test="oxy:is-part(..)">
            <xsl:attribute name="is-part">true</xsl:attribute>
        
        </xsl:if>
        <!-- Process the @class -->
        <xsl:next-match/>
    </xsl:template>    
    
    
    <!-- 
    
        Matches all topics from the merged content.
        
        Marks the ones referred from the TOC chapter entries. Additionally copies the "@class" 
        attribute from the topicref to "@oxy:topicref-class", so one can use CSS to style 
        differently the chapters and parts from the rest.
        
        Details:
        
        We use an optimisation, since we cannot have chapters on a level greater that 3 (the first 
        is the root, the second are the chapter topics for normal maps, the third are the chapters from the bookmaps with parts.)
        
        We are using the @class attribute as a "hook" to inject the new attributes. We use this 
        technique to avoid writing a template that generates a new element and would override the fixes from
        the "post-process-toc.xsl".
    
    -->
    <xsl:template match="*[contains(@class, ' topic/topic')][count(ancestor::*) &lt; 3]/@class">
            
        <xsl:variable name="possible-id" select="../@id"/>
        <xsl:if test="$possible-id">
            <xsl:variable name="possible-href" select="concat('#', ../@id)" />                
            <xsl:variable name="topic-ref" select="(//opentopic:map//*[contains(@class, ' map/topicref ')][@href = $possible-href or @id = $possible-id])[1]" as="node()*"/>
            <xsl:variable name="is-chapter" select="oxy:is-chapter(/, $topic-ref)" as="xs:boolean"/>
            <xsl:variable name="is-part" select="oxy:is-part($topic-ref)"  as="xs:boolean"/>
            
            <xsl:if test="$is-chapter">
                <!-- The topic was referred from the map  by a topic reference marked as chapter. -->
                <xsl:attribute name="break-before">true</xsl:attribute>
                <xsl:attribute name="is-chapter">true</xsl:attribute>
                
                <xsl:if test="$is-part">
                    <!-- The topic was referred from the map  by a topic reference marked as a part. -->
                    <xsl:attribute name="is-part">true</xsl:attribute>
                </xsl:if>
                
                <xsl:attribute name="oxy:topicref-class" select="$topic-ref/@class"/>
            </xsl:if>
        </xsl:if>
        
        <!-- Process the @class -->
        <xsl:next-match/>            
    </xsl:template>
    
    
    <!-- 
        Function that checks that an item from the TOC is a chapter 
        (book parts are also considered to be chapters).
        
        @param doc The document
        @param toc-item The element from the TOC.
        @return true if the item is a chapter.
    -->    
    <xsl:function name="oxy:is-chapter" as="xs:boolean">
        <xsl:param name="doc"/>
        <xsl:param name="toc-item"/>
        
        <xsl:choose>
            <xsl:when test="$doc/*[contains(@class, ' bookmap/bookmap ')]">
                <!-- For the bookmaps, the chapters are the "chapter" elements, and all the first level children of a "part", and the parts themselves.. -->
                <xsl:choose>
                    <xsl:when test="contains($toc-item/@class,' bookmap/chapter ')">
                        <xsl:value-of select="true()"/>
                    </xsl:when>
                    <xsl:when test="contains($toc-item/@class,' bookmap/part ')">
                        <xsl:value-of select="true()"/>
                    </xsl:when>
                    <xsl:when test="contains($toc-item/@class,' map/topicref ') and $toc-item/parent::*[contains(@class, ' bookmap/part ')]">
                        <xsl:value-of select="true()"/>
                    </xsl:when>                    
                    <xsl:when test="contains($toc-item/@class,' map/topicref ') and $toc-item/parent::opentopic:map">
                        <!-- Consider the first level childred, like appendix or index as chapters. 
                             Makes them looks better in the output (breaks pages in the content, styled like a chapter in the TOC). -->
                        <xsl:value-of select="true()"/>
                    </xsl:when>                    
                    <xsl:otherwise>
                        <xsl:value-of select="false()"/>                        
                    </xsl:otherwise>
                </xsl:choose>        
            </xsl:when>
            <xsl:otherwise>
                <!-- For a normal map, consider the first level topics of the TOC to be chapters. -->
                <xsl:choose>
                    <xsl:when test="$toc-item/parent::opentopic:map">
                        <xsl:value-of select="true()"/>
                    </xsl:when>        
                    <xsl:otherwise>
                        <xsl:value-of select="false()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <!-- 
        Function that checks that an item from the TOC is a book part.
        
        @param doc The document
        @param toc-item The element from the TOC.
        @return true if the item is a chapter.
    -->
    <xsl:function name="oxy:is-part" as="xs:boolean">
        <xsl:param name="toc-item"/>
        
        <xsl:choose>
            <xsl:when test="contains($toc-item/@class,' bookmap/part ')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>