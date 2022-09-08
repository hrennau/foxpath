<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2017 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
  <xsl:template match="*[@collection-type='sequence']/*[contains(@class, ' map/topicref ')]
    [not(ancestor::*[contains(concat(' ', @chunk, ' '), ' to-content ')])]" mode="link-to-next-prev" name="link-to-next-prev">
    <xsl:param name="pathBackToMapDirectory"/>
    
    <!--
      [not(ancestor::*[contains(concat(' ', @chunk, ' '), ' to-content ')])]
      EXM-30951 - The previous link should not be merged into a parent topic 
    -->
    <xsl:variable name="previous" select="(preceding::*|ancestor::*)[contains(@class, ' map/topicref ')]
      [@href][not(@href='')][not(@linking='none')]
      [not(ancestor::*[contains(concat(' ', @chunk, ' '), ' to-content ')])]
      [not(@linking='sourceonly')]
      [not(@processing-role='resource-only')][last()]"/>
    <xsl:choose>
      <xsl:when test="ancestor::*[contains(@class, ' map/relcell ')]">
        <xsl:if test="$previous/ancestor::*[contains(@class, ' map/relcell ')] 
                    and generate-id(ancestor::*[contains(@class, ' map/relcell ')]) = 
                           generate-id($previous/ancestor::*[contains(@class, ' map/relcell ')])">
          <xsl:apply-templates mode="link" select="$previous">
            <xsl:with-param name="role">previous</xsl:with-param>
            <xsl:with-param name="pathBackToMapDirectory" select="$pathBackToMapDirectory"/>
          </xsl:apply-templates>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="link" select="$previous">
          <xsl:with-param name="role">previous</xsl:with-param>
          <xsl:with-param name="pathBackToMapDirectory" select="$pathBackToMapDirectory"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
    <!--
      [not(ancestor::*[contains(concat(' ', @chunk, ' '), ' to-content ')])]
      EXM-30951 - The next link should not be merged into a parent topic 
    -->
    <xsl:variable name="next" select="(*|following::*)[contains(@class, ' map/topicref ')][@href][not(@href='')]
      [not(@linking='none')][not(@linking='sourceonly')]
      [not(ancestor::*[contains(concat(' ', @chunk, ' '), ' to-content ')])]
      [not(@processing-role='resource-only')][1]"/>
    <xsl:choose>
      <xsl:when test="ancestor::*[contains(@class, ' map/relcell ')]">
          <xsl:if test="$next/ancestor::*[contains(@class, ' map/relcell ')] 
                    and generate-id(ancestor::*[contains(@class, ' map/relcell ')]) 
                        = generate-id($next/ancestor::*[contains(@class, ' map/relcell ')])">
          <xsl:apply-templates mode="link" select="$next">
            <xsl:with-param name="role">next</xsl:with-param>
            <xsl:with-param name="pathBackToMapDirectory" select="$pathBackToMapDirectory"/>
          </xsl:apply-templates>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="link" select="$next">
          <xsl:with-param name="role">next</xsl:with-param>
          <xsl:with-param name="pathBackToMapDirectory" select="$pathBackToMapDirectory"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--
    WH-200 - Use the sequence as the default value if the collection type is not set. 
  -->
  <xsl:template match="*[contains(@class, ' map/topicref ')][not(ancestor::*[contains(concat(' ', @chunk, ' '), ' to-content ')])]" mode="link-to-next-prev" priority="-5">    
    <!--<xsl:variable name="preprocessPropsFileURI" select="resolve-uri('preprocess_props.xml', $WORKDIR)"/>        
    <xsl:variable name="default.collection.type.sequence">
      <xsl:choose>
        <xsl:when test="doc-available($preprocessPropsFileURI)">
          <xsl:value-of select="doc($preprocessPropsFileURI)//property[@name='webhelp.default.collection.type.sequence.prop']/@value"/>
        </xsl:when>
        <xsl:otherwise>no</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>-->
    
    <xsl:variable 
      name="default.collection.type.sequence" 
      select="system-property('webhelp.default.collection.type.sequence.prop')"/>
    
    <xsl:choose>
      <xsl:when test="$default.collection.type.sequence = 'yes'">
        <xsl:call-template name="link-to-next-prev"/>              
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>
</xsl:stylesheet>