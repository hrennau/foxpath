<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0"
    xmlns:fo="http://www.w3.org/1999/XSL/Format">
    
    <!--
      Specifies if custom images will be used when generating PDF output with the 'pdf2' transtype. 
      Set this parameter to 'no' to use the default images from the PDF2 plugin or your custom images.
    -->
    <xsl:param name="com.oxygenxml.use.custom.note.images" select="'yes'"/>
    
    <xsl:template match="*[contains(@class,' topic/fig ')]/*[contains(@class,' topic/title ')]">
        <fo:block xsl:use-attribute-sets="fig.title">
           <!-- OXYGEN PATCH START  EXM-18109 -->
          <xsl:if test="following-sibling::*[contains(@class,' topic/image ')][@placement='break']">
              <xsl:attribute name="text-align" 
                  select="if (empty(following-sibling::*[contains(@class,' topic/image ')]/@align)) then 'center' 
                              else following-sibling::*[contains(@class,' topic/image ')]/@align"/>
          </xsl:if>
          <!-- OXYGEN PATCH END  EXM-18109 -->

            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'Figure.title'"/>
                <xsl:with-param name="params">
                    <number>
                        <xsl:apply-templates select="." mode="fig.title-number"/>
                    </number>
                    <title>
                        <xsl:apply-templates/>
                    </title>
                </xsl:with-param>
            </xsl:call-template>
        </fo:block>
    </xsl:template>
    
    <!--Custom Oxygen note images for PDF-->
    <xsl:template match="*[contains(@class,' topic/note ')][$com.oxygenxml.use.custom.note.images eq 'yes']" mode="setNoteImagePath">
      <xsl:variable name="noteType" as="xs:string">
          <xsl:choose>
              <xsl:when test="@type">
                  <xsl:value-of select="@type"/>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:value-of select="'note'"/>
              </xsl:otherwise>
          </xsl:choose>
      </xsl:variable>
       <xsl:choose>
           <xsl:when test="$noteType = 'note'">Configuration/OpenTopic/cfg/common/artwork/note.png</xsl:when>
           <xsl:when test="$noteType = 'notice'">Configuration/OpenTopic/cfg/common/artwork/important.png</xsl:when>
           <xsl:when test="$noteType = 'attention'">Configuration/OpenTopic/cfg/common/artwork/important.png</xsl:when>
           <xsl:when test="$noteType = 'caution'">Configuration/OpenTopic/cfg/common/artwork/important.png</xsl:when>
           <xsl:when test="$noteType = 'danger'">Configuration/OpenTopic/cfg/common/artwork/danger.png</xsl:when>
           <xsl:when test="$noteType = 'warning'">Configuration/OpenTopic/cfg/common/artwork/warning.png</xsl:when>
           <xsl:when test="$noteType = 'fastpath'">Configuration/OpenTopic/cfg/common/artwork/nav_right16.png</xsl:when>
           <xsl:when test="$noteType = 'important'">Configuration/OpenTopic/cfg/common/artwork/important.png</xsl:when>
           <xsl:when test="$noteType = 'remember'">Configuration/OpenTopic/cfg/common/artwork/remember.png</xsl:when>
           <xsl:when test="$noteType = 'restriction'">Configuration/OpenTopic/cfg/common/artwork/restriction.png</xsl:when>
           <xsl:when test="$noteType = 'tip'">Configuration/OpenTopic/cfg/common/artwork/tip.png</xsl:when>
           <xsl:when test="$noteType = 'other'">Configuration/OpenTopic/cfg/common/artwork/nav_right16.png</xsl:when>
           <xsl:otherwise>
               <xsl:call-template name="getVariable">
                   <xsl:with-param name="id" select="concat($noteType, ' Note Image Path')"/>
               </xsl:call-template>
           </xsl:otherwise>
       </xsl:choose>
    </xsl:template>
</xsl:stylesheet>