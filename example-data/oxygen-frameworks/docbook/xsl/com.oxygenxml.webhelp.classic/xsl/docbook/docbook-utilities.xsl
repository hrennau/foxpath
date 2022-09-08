<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp Plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <!--Use some code from DITA templates to i18n static texts-->
    <xsl:import href="../dita/original/dita-utilities.xsl"/>
    <xsl:include href="../common-utilities.xsl"/>
    <xsl:variable name="msgprefix">DOCBOOK</xsl:variable>
    
    <!-- Uses the DITA localization architecture, but our strings. -->
    <xsl:template name="getWebhelpString">
        <xsl:param name="stringName" />
        <xsl:param name="stringFileList" select="document('../../oxygen-webhelp/resources/localization/allstrings.xml')/allstrings/stringfile"/>
        <xsl:call-template name="getString">
            <xsl:with-param name="stringName" select="$stringName"/>
            <xsl:with-param name="stringFileList" select="$stringFileList"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="output-message">
        <xsl:param name="msg" select="'***'"/>
        <xsl:param name="msgcat" select="$msgprefix"/>
        <xsl:param name="msgnum" select="'000'"/>
        <xsl:param name="msgsev" select="'I'"/>
        <xsl:param name="msgparams" select="''"/>
        <!--EXM-34947 Avoid issuing deprecation warnings...-->
        <xsl:if test="not($msgnum='066' and $msgparams='%1=getString')">
            <xsl:variable name="msgid">
                <xsl:value-of select="$msgcat"/>
                <xsl:value-of select="$msgnum"/>
                <xsl:value-of select="$msgsev"/>
            </xsl:variable>
            <xsl:variable name="msgdoc" select="document('../../../oxygen-webhelp/resources/localization/messages.xml')"/>
            <xsl:variable name="msgcontent">
                <xsl:choose>
                    <xsl:when test="$msg!='***'">
                        <xsl:value-of select="$msg"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$msgdoc/messages/message[@id=$msgid]" mode="get-message-content">    
                            <xsl:with-param name="params" select="$msgparams"/>    
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="localclass"><xsl:value-of select="@class"/></xsl:variable>
            <xsl:variable name="debugloc">
                <!-- Information on how to find the error; file name, followed by element counter: -->
                <!-- (File = filename.dita, Element = searchtitle:1) -->
                <xsl:if test="@xtrf|@xtrc">
                    <xsl:text>(</xsl:text>
                    <xsl:if test="@xtrf">
                        <xsl:text>File = </xsl:text><xsl:value-of select="@xtrf"/>
                        <xsl:if test="@xtrc"><xsl:text>, </xsl:text></xsl:if>
                    </xsl:if>
                    <xsl:if test="@xtrc"><xsl:text>Element = </xsl:text><xsl:value-of select="@xtrc"/></xsl:if>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </xsl:variable>
            
            <xsl:variable name="m">
                <xsl:value-of select="$msgcontent"/>
                <xsl:if test="normalize-space($debugloc)">
                    <xsl:value-of select="concat(' The location of this problem was at ',$debugloc)"/>
                </xsl:if>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$msgsev = 'F'">
                    <xsl:message terminate="yes">
                        <xsl:value-of select="$m"/>
                    </xsl:message>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>
                        <xsl:value-of select="$m"/>
                    </xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="message" mode="get-message-content">
        <xsl:param name="params"/>
        <xsl:variable name="reason" select="reason/text()"/>
        <xsl:variable name="response" select="response/text()"/>    
        <xsl:variable name="messageType"><xsl:value-of select="@type"/></xsl:variable>  <!--record this messageType as Information in the log file  when parsing the xml  add by wxzhang 20070515 -->
        <xsl:text>[</xsl:text><xsl:value-of select="@id"/><xsl:text>]</xsl:text>
        <xsl:text>[</xsl:text><xsl:value-of select="@type"/><xsl:text>]</xsl:text>
        <xsl:text>: </xsl:text>
        <xsl:call-template name="replaceParams">
            <xsl:with-param name="string" select="$reason"/>
            <xsl:with-param name="params" select="$params"/>    
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <xsl:call-template name="replaceParams">
            <xsl:with-param name="string" select="$response"/>
            <xsl:with-param name="params" select="$params"/>    
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="replaceParams">
        <xsl:param name="string"/>
        <xsl:param name="params"/>
        <xsl:choose>
            <xsl:when test="contains($params,';')">
                <xsl:variable name="param" select="substring-before($params,';')"/>
                <xsl:variable name="newString">
                    <xsl:call-template name="replaceString">
                        <xsl:with-param name="string" select="$string"/>
                        <xsl:with-param name="match" select="substring-before($param,'=')"/>
                        <xsl:with-param name="replacement" select="substring-after($param,'=')"/>            
                    </xsl:call-template>          
                </xsl:variable>
                <xsl:call-template name="replaceParams">
                    <xsl:with-param name="string" select="$newString"/>
                    <xsl:with-param name="params" select="substring-after($params,';')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($params,'=')">
                <xsl:call-template name="replaceString">
                    <xsl:with-param name="string" select="$string"/>
                    <xsl:with-param name="match" select="substring-before($params,'=')"/>
                    <xsl:with-param name="replacement" select="substring-after($params,'=')"/>            
                </xsl:call-template>   
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="replaceString">
        <xsl:param name="string"/>
        <xsl:param name="match"/>
        <xsl:param name="replacement"/>
        <xsl:choose>
            <xsl:when test="contains($string,$match)">
                <xsl:value-of select="substring-before($string,$match)"/>
                <xsl:value-of select="$replacement"/>
                <xsl:call-template name="replaceString">
                    <xsl:with-param name="string"
                        select="substring-after($string,$match)"/>
                    <xsl:with-param name="replacement" select="$replacement"/>
                    <xsl:with-param name="match" select="$match"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>