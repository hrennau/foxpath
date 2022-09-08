<?xml version="1.0" encoding="UTF-8"?>
<!--   /* The Syncro Soft SRL License
  *
  *
  *  Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights
  *  reserved.
  *
  *  Redistribution and use in source and binary forms, with or without
  *  modification, are permitted provided that the following conditions
  *  are met:
  *
  *  1. Redistribution of source or in binary form is allowed only with
  *  the prior written permission of Syncro Soft SRL.
  *
  *  2. Redistributions of source code must retain the above copyright
  *  notice, this list of conditions and the following disclaimer.
  *
  *  2. Redistributions in binary form must reproduce the above copyright
  *  notice, this list of conditions and the following disclaimer in
  *  the documentation and/or other materials provided with the
  *  distribution.
  *
  *  3. The end-user documentation included with the redistribution,
  *  if any, must include the following acknowledgment:
  *  "This product includes software developed by the
  *  Syncro Soft SRL (http://www.sync.ro/)."
  *  Alternately, this acknowledgment may appear in the software itself,
  *  if and wherever such third-party acknowledgments normally appear.
  *
  *  4. The names "Oxygen" and "Syncro Soft SRL" must
  *  not be used to endorse or promote products derived from this
  *  software without prior written permission. For written
  *  permission, please contact support@oxygenxml.com.
  *
  *  5. Products derived from this software may not be called "Oxygen",
  *  nor may "Oxygen" appear in their name, without prior written
  *  permission of the Syncro Soft SRL.
  *
  *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
  *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
  *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  *  DISCLAIMED.  IN NO EVENT SHALL THE SYNCRO SOFT SRL OR
  *  ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
  *  USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  *  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  *  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
  *  OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
  *  SUCH DAMAGE.
  */
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:File="java.io.File"
  exclude-result-prefixes="File xhtml"
  version="1.0">

  <!-- The XHTML file that contains the images. -->
  <xsl:param name="inputFile"/>
  
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="opf:manifest">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
      <xsl:variable name="backslashToSlashInputFile" select="translate($inputFile, '\\', '/')"/>
      <xsl:variable name="htmlFile" select="File:toURL(File:new($backslashToSlashInputFile))"/>
        <xsl:variable name="numberOfExistingImages" 
            select="count(opf:item[starts-with(@media-type, 'image/')]|opf:item[starts-with(@media-type, 'video/')])"/>
      <xsl:variable name="manifestElement" select="."/>
      <xsl:for-each select="document($htmlFile)//xhtml:img[@src]
                                      [not(@src = $manifestElement/opf:item/@href)]
                                      [not(preceding::xhtml:img/@src = ./@src)] 
                                    | document($htmlFile)//xhtml:object[@type='image/svg+xml']
                                      [not(@data = $manifestElement/opf:item/@href)]
                                      [not(preceding::xhtml:object/@data = ./@data)]
                                    | document($htmlFile)//xhtml:video[xhtml:source[@src]][parent::xhtml:div[contains(@class, 'mediaobject')]]
                                    [not(xhtml:source/@src = $manifestElement/opf:item/@href)]
                                    [not(preceding::xhtml:video[parent::xhtml:div[contains(@class, 'mediaobject')]]/xhtml:source/@src = ./xhtml:source/@src)]
                                    | document($htmlFile)//xhtml:embed[@src][parent::xhtml:div[contains(@class, 'mediaobject')]]
                                      [not(@src = $manifestElement/opf:item/@href)]
                                      [not(preceding::xhtml:embed[parent::xhtml:div[contains(@class, 'mediaobject')]]/@src = ./@src)]">
          <xsl:element namespace="http://www.idpf.org/2007/opf" name="item">
            <xsl:choose>
              <xsl:when test="parent::xhtml:div[@id = 'cover-image']">
                <xsl:attribute name="id">
                  <xsl:value-of select="'cover-image'"/> 
                </xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="id"> 
                  <xsl:value-of select="concat('imageID-', string($numberOfExistingImages + position()))"/> 
                </xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:attribute name="media-type">
              <xsl:choose>
                <xsl:when test="contains(@src, '.gif') or contains(@src, 'GIF')">
                  <xsl:text>image/gif</xsl:text>
                </xsl:when>
                <xsl:when test="contains(@src, '.png') or contains(@src, 'PNG')">
                  <xsl:text>image/png</xsl:text>
                </xsl:when>
                <xsl:when test="contains(@src, '.jpeg') or contains(@src, 'JPEG') or contains(@src, '.jpg') or contains(@src, 'JPG')">
                  <xsl:text>image/jpeg</xsl:text>
                </xsl:when>
                <xsl:when test="contains(@src, '.svg') or contains(@src, 'SVG')">
                  <xsl:text>image/svg+xml</xsl:text>
                </xsl:when>
                <xsl:when test="contains(@type, 'image/svg+xml')">
                  <xsl:text>image/svg+xml</xsl:text>
                </xsl:when>
                <xsl:when test="contains(@src, '.mathml') or contains(@src, 'MATHML') 
                             or contains(@src, '.mml') or contains(@src, 'MML')">
                  <xsl:text>image/mathml+xml</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>video/</xsl:text>
                  <xsl:value-of select="substring-after(xhtml:source/@src, '.')"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:choose>
              <xsl:when test="@src">
                <xsl:attribute name="href"><xsl:value-of select="@src"/></xsl:attribute>
              </xsl:when>
              <xsl:when test="@data">
                <xsl:attribute name="href"><xsl:value-of select="@data"/></xsl:attribute>
              </xsl:when>
              <xsl:when test="xhtml:source/@src">
                <xsl:attribute name="href"><xsl:value-of select="xhtml:source/@src"/></xsl:attribute>
              </xsl:when>
            </xsl:choose>
          </xsl:element>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>