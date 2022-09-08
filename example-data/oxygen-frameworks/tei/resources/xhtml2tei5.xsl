<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Copyright 2001-2012 Syncro Soft SRL. All rights reserved.
 -->
<xsl:stylesheet version="2.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:e="http://www.oxygenxml.com/xsl/conversion-elements"
                xmlns:f="http://www.oxygenxml.com/xsl/functions"
                exclude-result-prefixes="xsl xhtml e f">

  <xsl:template match="e:h1[ancestor::e:dl] 
                                      | e:h2[ancestor::e:dl] 
                                      | e:h3[ancestor::e:dl] 
                                      | e:h4[ancestor::e:dl] 
                                      | e:h5[ancestor::e:dl]
                                      | e:h6[ancestor::e:dl]">
      <hi rend="bold" xmlns="http://www.tei-c.org/ns/1.0">
          <xsl:apply-templates select="@* | node()"/>
      </hi>
  </xsl:template>

  <xsl:template match="e:p">
     <xsl:choose>
         <xsl:when test="((parent::e:td | parent::e:th) and count(parent::*[1]/e:p) = 1) or parent::e:p">
             <xsl:apply-templates select="@* | node()"/>
         </xsl:when>
         <xsl:when test="parent::e:ul | parent::e:ol">
             <!-- EXM-27834  Workaround for bug in OpenOffice/LibreOffice -->
             <item xmlns="http://www.tei-c.org/ns/1.0">
                 <p>
                     <xsl:apply-templates select="@* | node()"/>
                 </p>
             </item>
         </xsl:when>
         <xsl:otherwise>
              <p xmlns="http://www.tei-c.org/ns/1.0">
                 <xsl:apply-templates select="@* | node()"/>
              </p>
         </xsl:otherwise>
     </xsl:choose>
  </xsl:template>

   <xsl:template match="e:span[preceding-sibling::e:p and not(following-sibling::*)]">
       <p xmlns="http://www.tei-c.org/ns/1.0">
          <xsl:apply-templates select="@* | node()"/>
       </p>
   </xsl:template>
   
  <xsl:template match="e:pre | e:code | e:blockquote">
    <xsl:choose>
      <xsl:when test="($context.path.last.name = 'quote') 
          and ($context.path.last.uri = 'http://www.tei-c.org/ns/1.0')">
          <xsl:apply-templates select="@* | node()"/>
      </xsl:when>
      <xsl:when test=".[contains(@about, 'MSOfficeGeneratedTag')]">
          <code xmlns="http://www.tei-c.org/ns/1.0">
              <xsl:apply-templates select="@* | node()"/>
          </code>
       </xsl:when>
        <xsl:otherwise>
            <quote xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:apply-templates select="@* | node()"/>
            </quote>
        </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="e:q">
      <hi rend="quoted" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:apply-templates select="@* | node()"/>
      </hi>
  </xsl:template>
  
  <!-- Hyperlinks -->
   <xsl:template match="e:a[starts-with(@href, 'https://') or
     starts-with(@href,'http://') or starts-with(@href,'ftp://')]" priority="1.5">
      <xsl:variable name="ptr">
          <ptr xmlns="http://www.tei-c.org/ns/1.0">
              <xsl:attribute name="target">
                  <xsl:value-of select="normalize-space(@href)"/>
              </xsl:attribute>
          </ptr>
          <xsl:apply-templates/>
          </xsl:variable>
          <xsl:call-template name="insertParaInSection">
              <xsl:with-param name="childOfPara" select="$ptr"/>
          </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="e:a[contains(@href,'#')]" priority="0.6">
      <xsl:variable name="ptr">
          <ptr xmlns="http://www.tei-c.org/ns/1.0">
              <xsl:attribute name="target">
                   <xsl:call-template name="makeID">
                       <xsl:with-param name="string" select="normalize-space(@href)"/>
                   </xsl:call-template>
              </xsl:attribute>
          </ptr>
          <xsl:apply-templates/>
      </xsl:variable>
      <xsl:call-template name="insertParaInSection">
          <xsl:with-param name="childOfPara" select="$ptr"/>
      </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="e:a[@name != '']" priority="0.6">
      <xsl:variable name="hi">
          <hi xmlns="http://www.tei-c.org/ns/1.0">
              <xsl:attribute name="xml:id">
                  <xsl:call-template name="makeID">
                      <xsl:with-param name="string" select="normalize-space(@name)"/>
                  </xsl:call-template>
              </xsl:attribute>
              <xsl:apply-templates select="@* | * | text()"/>
          </hi>
      </xsl:variable>
      <xsl:call-template name="insertParaInSection">
          <xsl:with-param name="childOfPara" select="$hi"/>
      </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="e:a[@href != '']">
      <xsl:variable name="ptr">
          <ptr xmlns="http://www.tei-c.org/ns/1.0">
              <xsl:attribute name="target">
                  <xsl:call-template name="makeID">
                      <xsl:with-param name="string" select="normalize-space(@href)"/>
                  </xsl:call-template>
              </xsl:attribute>
          </ptr>
          <xsl:apply-templates/>
      </xsl:variable>
      <xsl:call-template name="insertParaInSection">
          <xsl:with-param name="childOfPara" select="$ptr"/>
      </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="makeID">
   <xsl:param name="string" select="''"/>
     <xsl:call-template name="getFilename">
       <xsl:with-param name="path" select="translate($string,' \()','_/_')"/>
     </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="string.subst">
   <xsl:param name="string" select="''"/>
   <xsl:param name="substitute" select="''"/>
   <xsl:param name="with" select="''"/>
   <xsl:choose>
    <xsl:when test="contains($string,$substitute)">
     <xsl:variable name="pre" select="substring-before($string,$substitute)"/>
     <xsl:variable name="post" select="substring-after($string,$substitute)"/>
     <xsl:call-template name="string.subst">
      <xsl:with-param name="string" select="concat($pre,$with,$post)"/>
      <xsl:with-param name="substitute" select="$substitute"/>
      <xsl:with-param name="with" select="$with"/>
     </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="$string"/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:template>
  
  <!-- Images -->
    <xsl:template match="e:img">
        <xsl:variable name="pastedImageURL" 
            xmlns:URL="java:java.net.URL"
            xmlns:URLUtil="java:ro.sync.util.URLUtil"
            xmlns:UUID="java:java.util.UUID">
            <xsl:choose>
                <xsl:when test="namespace-uri-for-prefix('o', .) = 'urn:schemas-microsoft-com:office:office'">
                    <!-- Copy from MS Office. Copy the image from user temp folder to folder of XML document
            that is the paste target. -->
                    <xsl:variable name="imageFilename">
                        <xsl:variable name="fullPath" select="URL:getPath(URL:new(translate(@src, '\', '/')))"/>
                        <xsl:variable name="srcFile">
                            <xsl:choose>
                                <xsl:when test="contains($fullPath, ':')">
                                    <xsl:value-of select="substring($fullPath, 2)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$fullPath"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:call-template name="getFilename">
                            <xsl:with-param name="path" select="string($srcFile)"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="stringImageFilename" select="string($imageFilename)"/>
                    <xsl:variable name="uid" select="UUID:hashCode(UUID:randomUUID())"/>
                    <xsl:variable name="uniqueTargetFilename" select="concat(substring-before($stringImageFilename, '.'), '_', $uid, '.', substring-after($stringImageFilename, '.'))"/>
                    <xsl:variable name="sourceURL" select="URL:new(translate(@src, '\', '/'))"/>
                    <xsl:variable name="correctedSourceFile">
                        <xsl:choose>
                            <xsl:when test="contains(URL:getPath($sourceURL), ':')">
                                <xsl:value-of select="substring-after(URL:getPath($sourceURL), '/')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="URL:getPath($sourceURL)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="sourceFile" select="URLUtil:uncorrect($correctedSourceFile)"/>
                    <xsl:variable name="targetURL" select="URL:new(concat($folderOfPasteTargetXml, '/', $uniqueTargetFilename))"/>
                    <xsl:value-of select="substring-after(string($targetURL),
                        substring-before(string(URLUtil:copyURL($sourceURL, $targetURL)), $uniqueTargetFilename))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@src"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <graphic xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:if test="@src != ''">
                <xsl:attribute name="url">
                    <xsl:value-of select="$pastedImageURL"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@height != ''">
                <xsl:attribute name="height">
                    <xsl:value-of select="@height"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@width != ''">
                <xsl:attribute name="width">
                    <xsl:value-of select="@width"/>
                </xsl:attribute>
            </xsl:if>
        </graphic>
    </xsl:template>
    
    <xsl:template name="getFilename">
   <xsl:param name="path"/>
   <xsl:choose>
    <xsl:when test="contains($path,'/')">
     <xsl:call-template name="getFilename">
      <xsl:with-param name="path" select="substring-after($path,'/')"/>
     </xsl:call-template>
    </xsl:when>
    <xsl:when test="contains($path,'\')">
       <xsl:call-template name="getFilename">
         <xsl:with-param name="path" select="substring-after($path,'\')"/>
       </xsl:call-template>
     </xsl:when>
     <xsl:otherwise>
     <xsl:value-of select="$path"/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:template>
  
  <!-- List elements -->
  <xsl:template match="e:ul">
      <list type="simple" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:apply-templates select="@* | node()"/>
      </list>
  </xsl:template>
  
  <xsl:template match="e:ol">
      <list type="ordered" xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:apply-templates select="@* | node()"/>
      </list>
  </xsl:template>
  
     
    <!-- This template makes a TEI gloss list from an HTML definition list. -->
    <xsl:template match="e:dl">
        <xsl:variable name="dataBeforeTitle" select="e:dd[empty(preceding-sibling::e:dt)]"/>
        <xsl:if test="not(empty($dataBeforeTitle))">
            <list type="gloss" xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:apply-templates select="@*"/>
                <xsl:for-each select="$dataBeforeTitle">
                    <item>
                        <xsl:apply-templates select="."/>
                    </item>
                </xsl:for-each>
            </list>
        </xsl:if>
        <xsl:for-each select="e:dt">
            <list type="gloss" xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:apply-templates select="parent::e:dl/@*"/>
                <label>
                    <xsl:apply-templates select="@* | node()"/>
                </label>
                <item>
                    <xsl:apply-templates
                        select="following-sibling::e:dd[current() is preceding-sibling::e:dt[1]]"/>
                </item>
            </list>
        </xsl:for-each>
    </xsl:template>
    
  <xsl:template match="e:dd">
   <xsl:choose>
    <xsl:when test="e:p">
      <xsl:apply-templates/>
    </xsl:when>
    <xsl:otherwise>
        <p xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates/>
        </p>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:template>
  
  <xsl:template match="e:li">
      <item xmlns="http://www.tei-c.org/ns/1.0">
          <xsl:apply-templates/>
      </item>
  </xsl:template>
  
  <xsl:template match="@id"> 
    <xsl:attribute name="xml:id">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="@*">
   <!--<xsl:message>No template for attribute <xsl:value-of select="name()"/></xsl:message>-->
  </xsl:template>
  
  <!-- Inline formatting -->
  <xsl:template match="e:b | e:strong">
      <xsl:variable name="hi">
          <hi rend="bold" xmlns="http://www.tei-c.org/ns/1.0">
              <xsl:apply-templates select="@* | node()"/>
          </hi>
      </xsl:variable>
      <xsl:if test="string-length(normalize-space($hi)) > 0">
          <xsl:call-template name="insertParaInSection">
              <xsl:with-param name="childOfPara" select="$hi"/>
          </xsl:call-template>
      </xsl:if>
  </xsl:template>

  <xsl:template match="e:i | e:em">
      <xsl:variable name="hi">
          <hi rend="italic" xmlns="http://www.tei-c.org/ns/1.0">
              <xsl:apply-templates select="@* | node()"/>
          </hi>
      </xsl:variable>
      <xsl:if test="string-length(normalize-space($hi)) > 0">
          <xsl:call-template name="insertParaInSection">
              <xsl:with-param name="childOfPara" select="$hi"/>
          </xsl:call-template>
      </xsl:if>
  </xsl:template>

  <xsl:template match="e:u">
      <xsl:variable name="hi">
          <hi rend="underline" xmlns="http://www.tei-c.org/ns/1.0">
              <xsl:apply-templates select="@* | node()"/>
          </hi>
      </xsl:variable>
      <xsl:if test="string-length(normalize-space($hi)) > 0">
          <xsl:call-template name="insertParaInSection">
              <xsl:with-param name="childOfPara" select="$hi"/>
          </xsl:call-template>
      </xsl:if>
  </xsl:template>
          
  <xsl:template match="e:lb">
      <lb xmlns="http://www.tei-c.org/ns/1.0"/>
  </xsl:template>
    
  <!-- Ignored elements -->
  <xsl:template match="e:hr"/>
  <xsl:template match="e:meta"/>
  <xsl:template match="e:style"/>
  <xsl:template match="e:script"/>
  <xsl:template match="e:p[normalize-space() = '' and count(*) = 0]" priority="0.6"/>
  <xsl:template match="text()">
   <xsl:choose>
    <xsl:when test="normalize-space() = ''"><xsl:text> </xsl:text></xsl:when>
    <xsl:otherwise>
        <xsl:choose>
            <xsl:when test="parent::e:section or parent::e:span/parent::e:section">
                <p xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="translate(., '&#xA0;', ' ')"/></p>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="translate(., '&#xA0;', ' ')"/></xsl:otherwise>
        </xsl:choose>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:template>
  
  <!-- Table conversion -->
  
  <!-- In TEI P4 the XHTML table elements are transformed to the elements of TEI table. -->
  <xsl:template match="e:table">
      <table xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="e:caption, e:thead, e:tr | e:tbody/e:tr | text() | e:b | e:strong | e:i | e:em | e:u, e:tfoot/e:tr"/>
      </table>
  </xsl:template>
  
  <xsl:template match="e:caption">
      <head xmlns="http://www.tei-c.org/ns/1.0">
          <xsl:apply-templates select="@* | node()"/>
      </head>
  </xsl:template>
  
  <xsl:template match="e:thead/e:tr">
      <row role="label" xmlns="http://www.tei-c.org/ns/1.0">
          <xsl:apply-templates select="@* | node()"/>
      </row>
  </xsl:template>
  
  <xsl:template match="e:tr">
      <row xmlns="http://www.tei-c.org/ns/1.0">
          <xsl:apply-templates select="@* | node()"/>
      </row>
  </xsl:template>

  <xsl:template match="e:td | e:th">
    <cell xmlns="http://www.tei-c.org/ns/1.0">
      <xsl:if test="number(@rowspan) > 1">
        <xsl:attribute name="rows">
          <xsl:value-of select="@rowspan"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="number(@colspan) > 1">
        <xsl:attribute name="cols">
          <xsl:value-of select="@colspan"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="@* | node()"/>
    </cell>
  </xsl:template>
  
    <xsl:template match="e:section">
        <div xmlns="http://www.tei-c.org/ns/1.0">
            <head>
                <xsl:apply-templates select="e:title"/>
            </head>
            <xsl:apply-templates 
                select="node()[local-name() != 'title' and local-name() != 'section']"/>
            <xsl:apply-templates select="e:section"/>
        </div>
    </xsl:template>
    
    <xsl:template name="insertParaInSection">
        <xsl:param name="childOfPara"/>
        <xsl:choose>
            <xsl:when test="parent::e:section">
                <p xmlns="http://www.tei-c.org/ns/1.0"><xsl:copy-of select="$childOfPara"/></p>
            </xsl:when>
            <xsl:otherwise><xsl:copy-of select="$childOfPara"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>