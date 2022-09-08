<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
   <xsl:template name="place-fig-lbl">
<xsl:param name="stringName"/>
  <!-- Number of fig/title's including this one -->
  <xsl:variable name="fig-count-actual" select="count(preceding::*[contains(@class, ' topic/fig ')]/*[contains(@class, ' topic/title ')])+1"/>
  <xsl:variable name="ancestorlang">
    <xsl:call-template name="getLowerCaseLang"/>
  </xsl:variable>
  <xsl:choose>
    <!-- title -or- title & desc -->
    <xsl:when test="*[contains(@class, ' topic/title ')]">
            <!-- OXYGEN PATCH START  EXM-18109 -->
      <!--<span class="figcap">-->
      <p>
        <xsl:choose>
          <xsl:when test="*[contains(@class, ' topic/image ')][@placement='break'][@align='center']">
            <xsl:attribute name="class">figcapcenter</xsl:attribute>
          </xsl:when>
          <xsl:when test="*[contains(@class, ' topic/image ')][@placement='break'][@align='right']">
            <xsl:attribute name="class">figcapright</xsl:attribute>
          </xsl:when>
          <xsl:when test="*[contains(@class, ' topic/image ')][@placement='break'][@align='justify']">
            <xsl:attribute name="class">figcapjustify</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class">figcap</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
        <!-- OXYGEN PATCH END  EXM-18109 -->
        <!-- OXYGEN PATCH START EXM-31371 Using just the "Figure: " static text, without the figure number. This number is reset at each topic, it is not useful. -->        
        <span class='figtitleprefix'>
          <xsl:call-template name="getVariable">
          	<xsl:with-param name="id" select="'Figure'"/>
          </xsl:call-template><xsl:text>: </xsl:text>
        </span>
       <!--<xsl:choose>      <!-\- Hungarian: "1. Figure " -\->
        <xsl:when test="$ancestorlang = ('hu', 'hu-hu')">
         <xsl:value-of select="$fig-count-actual"/>
         <xsl:text>. </xsl:text>
         <xsl:call-template name="getVariable">
          <xsl:with-param name="id" select="'Figure'"/>
         </xsl:call-template>
         <xsl:text> </xsl:text>
        </xsl:when>
        <xsl:otherwise>
         <xsl:call-template name="getVariable">
          <xsl:with-param name="id" select="'Figure'"/>
         </xsl:call-template>
         <xsl:text> </xsl:text>
         <xsl:value-of select="$fig-count-actual"/>
         <xsl:text>. </xsl:text>
        </xsl:otherwise>
       </xsl:choose>-->
       <xsl:apply-templates select="*[contains(@class, ' topic/title ')]" mode="figtitle"/>
       <xsl:if test="*[contains(@class, ' topic/desc ')]">
         <xsl:text>. </xsl:text>
       </xsl:if>
          <xsl:for-each select="*[contains(@class, ' topic/desc ')]">
              <span class="figdesc">
                  <xsl:call-template name="commonattributes"/>
                  <xsl:apply-templates select="." mode="figdesc"/>
              </span>
          </xsl:for-each>
      </p>
    </xsl:when>
    
    <!-- desc -->
    <xsl:when test="*[contains(@class, ' topic/desc ')]">
      <xsl:for-each select="*[contains(@class, ' topic/desc ')]">
       <span class="figdesc">
         <xsl:call-template name="commonattributes"/>
         <xsl:apply-templates select="." mode="figdesc"/>
       </span>
      </xsl:for-each>
    </xsl:when>
  </xsl:choose>
</xsl:template>
</xsl:stylesheet>