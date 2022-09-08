<?xml version="1.0" encoding="UTF-8" ?>
<!--
    
Oxygen Webhelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->
<!-- 
    This stylesheet includes DITA-OT patches.
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    xmlns:dita2html="http://dita-ot.sourceforge.net/ns/200801/dita2html"
    xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"
    xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="dita-ot dita2html ditamsg exsl">
    
    <xsl:param name="genAddDiv" select="false()"/>
    
    <xsl:template match="*" mode="chapterBody">
        <body>
            <!-- Already put xml:lang on <html>; do not copy to body with commonattributes -->
            <xsl:apply-templates
                select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]/@outputclass"
                mode="add-ditaval-style"/>
            <!--output parent or first "topic" tag's outputclass as class -->
            <xsl:if test="@outputclass">
                <xsl:attribute name="class">
                    <xsl:value-of select="@outputclass"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="self::dita">
                <xsl:if test="*[contains(@class, ' topic/topic ')][1]/@outputclass">
                    <xsl:attribute name="class">
                        <xsl:value-of select="*[contains(@class, ' topic/topic ')][1]/@outputclass"
                        />
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates select="." mode="addAttributesToBody"/>
            <xsl:call-template name="setidaname"/>
            <xsl:value-of select="$newline"/>
            <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]"
                mode="out-of-line"/>
            <xsl:call-template name="generateBreadcrumbs"/>
            <xsl:call-template name="gen-user-header"/>
            <!-- include user's XSL running header here -->
            <xsl:call-template name="processHDR"/>
            <xsl:if test="$INDEXSHOW = 'yes'">
                <xsl:apply-templates
                    select="
                        /*/*[contains(@class, ' topic/prolog ')]/*[contains(@class, ' topic/metadata ')]/*[contains(@class, ' topic/keywords ')]/*[contains(@class, ' topic/indexterm ')] |
                        /dita/*[1]/*[contains(@class, ' topic/prolog ')]/*[contains(@class, ' topic/metadata ')]/*[contains(@class, ' topic/keywords ')]/*[contains(@class, ' topic/indexterm ')]"
                />
            </xsl:if>
            <!-- Include a user's XSL call here to generate a toc based on what's a child of topic -->
            <xsl:call-template name="gen-user-sidetoc"/>

            <!-- EXM-33701 Wrap the topic content in a div element. 
        In this way it can be identified in the output.  -->
            <!--<xsl:apply-templates/>-->
            <xsl:choose>
                <xsl:when test="$genAddDiv">
                    <div id="topicContent">
                        <xsl:apply-templates/>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
            <!-- this will include all things within topic; therefore, -->
            <!-- title content will appear here by fall-through -->
            <!-- followed by prolog (but no fall-through is permitted for it) -->
            <!-- followed by body content, again by fall-through in document order -->
            <!-- followed by related links -->
            <!-- followed by child topics by fall-through -->

            <xsl:call-template name="gen-endnotes"/>
            <!-- include footnote-endnotes -->
            <xsl:call-template name="gen-user-footer"/>
            <!-- include user's XSL running footer here -->
            <xsl:call-template name="processFTR"/>
            <!-- Include XHTML footer, if specified -->
            <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]"
                mode="out-of-line"/>
        </body>
        <xsl:value-of select="$newline"/>
    </xsl:template>
</xsl:stylesheet>
