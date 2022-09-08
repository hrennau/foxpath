<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Copyright 2001-2012 Syncro Soft SRL. All rights reserved.
 -->
<xsl:stylesheet version="2.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:e="http://www.oxygenxml.com/xsl/conversion-elements"
                xmlns:f="http://www.oxygenxml.com/xsl/functions"
                exclude-result-prefixes="xsl e f">
    
    <xsl:param name="preferGenericSections" select="true()"/>
    
    <xsl:template match="e:h1[ancestor::e:dl] 
                                      | e:h2[ancestor::e:dl] 
                                      | e:h3[ancestor::e:dl] 
                                      | e:h4[ancestor::e:dl] 
                                      | e:h5[ancestor::e:dl]
                                      | e:h6[ancestor::e:dl]">
    <emphasis role="bold" xmlns="http://docbook.org/ns/docbook">
       <xsl:apply-templates select="@* | node()"/>
    </emphasis>
  </xsl:template>
     
  <xsl:template match="e:p">
     <xsl:choose>
         <xsl:when test="((parent::e:td | parent::e:th) and (count(parent::*[1]/*) = 1)) or parent::e:p">
             <xsl:apply-templates select="@* | node()"/>
         </xsl:when>
         <xsl:when test="parent::e:ul | parent::e:ol">
             <!-- EXM-27834  Workaround for bug in OpenOffice/LibreOffice -->
             <listitem xmlns="http://docbook.org/ns/docbook">
                 <para>
                     <xsl:call-template name="keepDirection"/>
                     <xsl:apply-templates select="@* | node()"/>
                 </para>
             </listitem>
         </xsl:when>
         <xsl:otherwise>
              <para xmlns="http://docbook.org/ns/docbook">
                 <xsl:call-template name="keepDirection"/>
                 <xsl:apply-templates select="@* | node()"/>
              </para>
         </xsl:otherwise>
     </xsl:choose>
  </xsl:template>

  <xsl:template match="e:span[preceding-sibling::e:p and not(following-sibling::*)]">
     <para xmlns="http://docbook.org/ns/docbook">
         <xsl:call-template name="keepDirection"/>
         <xsl:apply-templates select="@* | node()"/>
     </para>
  </xsl:template>
   
    <xsl:template match="e:pre">
        <xsl:choose>
             <xsl:when test="($context.path.last.name = 'blockquote' or $context.path.last.name = 'programlisting') 
                 and ($context.path.last.uri = 'http://docbook.org/ns/docbook'  
                            or empty($context.path.last.uri))">
                 <xsl:apply-templates select="@* | node()"/>
             </xsl:when>
             <xsl:otherwise>
                 <programlisting xmlns="http://docbook.org/ns/docbook">
                     <xsl:call-template name="keepDirection"/>
                     <xsl:apply-templates select="@* | node()"/>
                 </programlisting>
             </xsl:otherwise>
         </xsl:choose>
     </xsl:template>
     
  <xsl:template match="e:code">
    <xsl:choose>
      <xsl:when test="($context.path.last.name = 'blockquote') 
        and ($context.path.last.uri = 'http://docbook.org/ns/docbook'  
                    or empty($context.path.last.uri))">
        <xsl:apply-templates select="@* | node()"/>
      </xsl:when>
      <xsl:otherwise>
        <code xmlns="http://docbook.org/ns/docbook">
             <xsl:call-template name="keepDirection"/>
             <xsl:apply-templates select="@* | node()"/>
         </code>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="e:blockquote">
    <xsl:choose>
      <xsl:when test="($context.path.last.name = 'blockquote' or $context.path.last.name = 'programlisting') 
          and ($context.path.last.uri = 'http://docbook.org/ns/docbook'
                     or empty($context.path.last.uri))">
          <xsl:apply-templates select="@* | node()"/>
      </xsl:when>
      <xsl:otherwise>
        <blockquote xmlns="http://docbook.org/ns/docbook">
           <xsl:call-template name="keepDirection"/>
           <xsl:apply-templates select="@* | node()"/>
        </blockquote>
      </xsl:otherwise>
    </xsl:choose>
   </xsl:template>
   
  
     <!-- Hyperlinks -->
  <xsl:template match="e:a[contains(@href, ':')]"
                          priority="1.5">
      <!-- Links of type: http:// ..., ftp://..., mailto: ... -->
      <xsl:variable name="ulink">
          <link xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://docbook.org/ns/docbook">
             <xsl:attribute name="xlink:href">
                 <xsl:value-of select="normalize-space(@href)"/>
             </xsl:attribute>
             <xsl:call-template name="keepDirection"/>
             <xsl:apply-templates select="@* | * | text()"/>
         </link>
      </xsl:variable>
      <xsl:call-template name="insertParaInSection">
          <xsl:with-param name="childOfPara" select="$ulink"/>
      </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="e:a[contains(@href,'#')]" priority="0.6">
      <xsl:variable name="insertXref" select="not(*) and not(normalize-space())"/>
      <xsl:variable name="link">
          <xsl:element name="{if($insertXref) then 'xref' else 'link'}" namespace="http://docbook.org/ns/docbook">
              <xsl:attribute name="linkend">
                  <xsl:call-template name="makeID">
                      <xsl:with-param name="string" select="normalize-space(@href)"/>
                  </xsl:call-template>
              </xsl:attribute>
              <xsl:call-template name="keepDirection"/>
              <xsl:if test="not($insertXref)">
                  <!-- link element can have content in the Docbook schema. -->
                  <xsl:apply-templates select="* | text()"/>
              </xsl:if>
          </xsl:element>
          <xsl:if test="$insertXref">
              <!-- xref element is empty in the Docbook schema. -->
              <xsl:apply-templates select="* | text()"/>
          </xsl:if>
      </xsl:variable>
      <xsl:call-template name="insertParaInSection">
          <xsl:with-param name="childOfPara" select="$link"/>
      </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="e:a[@name != '']" priority="0.6">
   <anchor xmlns="http://docbook.org/ns/docbook">
     <xsl:attribute name="xml:id">
       <xsl:call-template name="makeID">
         <xsl:with-param name="string" select="normalize-space(@name)"/>
       </xsl:call-template>
     </xsl:attribute>
     <xsl:apply-templates select="@*"/>
   </anchor>
   <xsl:apply-templates select="* | text()"/>
  </xsl:template>
  
  <xsl:template match="e:a[@href != '']">
       <xsl:variable name="xref">
        <xref xmlns="http://docbook.org/ns/docbook">
         <xsl:attribute name="linkend">
           <xsl:call-template name="makeID">
               <xsl:with-param name="string" select="normalize-space(@href)"/>
             </xsl:call-template>
         </xsl:attribute>
         <xsl:call-template name="keepDirection"/>
        </xref>
       <!-- xref element is empty in the Docbook schema. -->
          <xsl:apply-templates select="* | text()"/>
      </xsl:variable>
      <xsl:call-template name="insertParaInSection">
          <xsl:with-param name="childOfPara" select="$xref"/>
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
    
    <xsl:variable name="tagName">
        <xsl:choose>
             <xsl:when test="boolean(parent::e:p) and 
                                        boolean(normalize-space(string-join(parent::e:p/text(), ' ')))">
                <xsl:text>inlinemediaobject</xsl:text>
             </xsl:when>
             <xsl:otherwise>mediaobject</xsl:otherwise>
        </xsl:choose>
   </xsl:variable>
   <xsl:element name="{$tagName}" namespace="http://docbook.org/ns/docbook">
    <imageobject xmlns="http://docbook.org/ns/docbook">
      <imagedata fileref="{$pastedImageURL}">
        <xsl:if test="@height != ''">
          <xsl:attribute name="depth">
            <xsl:value-of select="@height"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="@width != ''">
          <xsl:attribute name="width">
            <xsl:value-of select="@width"/>
          </xsl:attribute>
        </xsl:if>
      </imagedata>
    </imageobject>
   </xsl:element>
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
         <xsl:choose>
             <xsl:when test="starts-with($path, '#')">
                 <xsl:value-of select="substring-after($path, '#')"/>
             </xsl:when>
             <xsl:otherwise>
                 <xsl:value-of select="$path"/>
             </xsl:otherwise>
         </xsl:choose>
     </xsl:otherwise>
   </xsl:choose>
  </xsl:template>
  
  <!-- List elements -->
  <xsl:template match="e:ul">
    <itemizedlist xmlns="http://docbook.org/ns/docbook">
        <xsl:apply-templates select="@* | node()"/>
    </itemizedlist>
  </xsl:template>
  
  <xsl:template match="e:ol">
    <orderedlist xmlns="http://docbook.org/ns/docbook">
        <xsl:apply-templates select="@* | node()"/>
    </orderedlist>
  </xsl:template>
  
  
  <xsl:template match="e:kbd">
    <userinput xmlns="http://docbook.org/ns/docbook">
       <xsl:call-template name="keepDirection"/>
       <xsl:apply-templates select="@* | node()"/>
    </userinput>
  </xsl:template>
  
  <xsl:template match="e:samp">
    <screen xmlns="http://docbook.org/ns/docbook">
       <xsl:call-template name="keepDirection"/>
       <xsl:apply-templates select="@* | node()"/>
    </screen>
  </xsl:template>
  
  <xsl:template match="e:blockquote">
    <blockquote xmlns="http://docbook.org/ns/docbook">
       <xsl:call-template name="keepDirection"/>
       <xsl:apply-templates select="@* | node()"/>
    </blockquote>
  </xsl:template>
  
  <xsl:template match="e:q">
    <quote xmlns="http://docbook.org/ns/docbook">
       <xsl:call-template name="keepDirection"/>
       <xsl:apply-templates select="@* | node()"/>
    </quote>
  </xsl:template>
  
  <xsl:template match="e:dl">
    <variablelist xmlns="http://docbook.org/ns/docbook">
    	<xsl:apply-templates select="@*"/>
    	<xsl:variable name="dataBeforeTitle" select="e:dd[empty(preceding-sibling::e:dt)]"/>
    	<xsl:if test="not(empty($dataBeforeTitle))">
    		<varlistentry xmlns="http://docbook.org/ns/docbook">
    			<term/>
    			<listitem>
    			    <xsl:variable name="liContent">
    			        <xsl:apply-templates select="$dataBeforeTitle"/>
    			    </xsl:variable>
    			    <xsl:choose>
    			        <xsl:when test="$liContent/text()[normalize-space(.)!='']">
    			            <para xmlns="http://docbook.org/ns/docbook">
    			                <xsl:copy-of select="$liContent"/>
    			            </para>
    			        </xsl:when>
    			        <xsl:otherwise>
    			            <xsl:copy-of select="$liContent"/>
    			        </xsl:otherwise>
    			    </xsl:choose>
    			</listitem>
    		</varlistentry>
    	</xsl:if>
    	<xsl:for-each select="e:dt">
    		<varlistentry xmlns="http://docbook.org/ns/docbook">
    			<xsl:apply-templates select="."/>
    		    <listitem>
    		        <xsl:variable name="liContent">
    		            <xsl:apply-templates select="following-sibling::e:dd[current() is preceding-sibling::e:dt[1]]"/>
    		        </xsl:variable>
    		        <xsl:choose>
    		            <xsl:when test="$liContent/text()[normalize-space(.)!='']">
    		                <para xmlns="http://docbook.org/ns/docbook">
    		                    <xsl:copy-of select="$liContent"/>
    		                </para>
    		            </xsl:when>
    		            <xsl:otherwise>
    		                <xsl:copy-of select="$liContent"/>
    		            </xsl:otherwise>
    		        </xsl:choose>
    		      </listitem>
    		</varlistentry>
    	</xsl:for-each>
    </variablelist>
  </xsl:template>
  
  <xsl:template match="e:dt">
    <term xmlns="http://docbook.org/ns/docbook">
       <xsl:call-template name="keepDirection"/>
       <xsl:apply-templates select="@* | node()"/>
    </term>
  </xsl:template>
  
  <xsl:template match="e:dd">
        <xsl:choose>
            <xsl:when test="e:p">
                <xsl:apply-templates select="node()" mode="preprocess"/>
            </xsl:when>
            <xsl:otherwise>
                <para xmlns="http://docbook.org/ns/docbook">
                    <xsl:call-template name="keepDirection"/>
                    <xsl:apply-templates select="node()" mode="preprocess"/>
                </para>
            </xsl:otherwise>
        </xsl:choose>
  </xsl:template>
  
  <xsl:template match="e:li">
      <xsl:choose>
          <xsl:when test="parent::e:ul | parent::e:ol">
              <listitem xmlns="http://docbook.org/ns/docbook">
                  <xsl:call-template name="keepDirection"/>
                  <xsl:variable name="liContent">
                      <xsl:apply-templates/>
                  </xsl:variable>
                  <xsl:choose>
                      <xsl:when test="$liContent/text()[normalize-space(.)!='']">
                          <para xmlns="http://docbook.org/ns/docbook">
                              <xsl:copy-of select="$liContent"/>
                          </para>
                      </xsl:when>
                      <xsl:otherwise>
                          <xsl:copy-of select="$liContent"/>
                      </xsl:otherwise>
                  </xsl:choose>
              </listitem>
          </xsl:when>
          <xsl:otherwise>
              <para xmlns="http://docbook.org/ns/docbook">
                  <xsl:call-template name="keepDirection"/>
                  <xsl:apply-templates/>
              </para>
          </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
          
  <xsl:template match="@id"> 
    <xsl:attribute name="xml:id">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@dir">
      <xsl:attribute name="dir">
          <xsl:value-of select="lower-case(.)"/>
      </xsl:attribute>
  </xsl:template>
    
  <xsl:template match="@class[parent::e:table][$docbook.html.table != 0] 
                                | @title[parent::e:table][$docbook.html.table != 0]
                                | @style[parent::e:table][$docbook.html.table != 0]
                                | @width[parent::e:table][$docbook.html.table != 0]
                                | @border[parent::e:table][$docbook.html.table != 0]"> 
    <xsl:attribute name="{local-name()}">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="@*">
   <!--<xsl:message>No template for attribute <xsl:value-of select="name()"/></xsl:message>-->
  </xsl:template>
  
  
  <!-- Inline formatting -->
  <xsl:template match="e:b | e:strong">
      <xsl:variable name="emphasis">
          <emphasis role="bold" xmlns="http://docbook.org/ns/docbook">
              <xsl:apply-templates select="@* | node()"/>
          </emphasis>
      </xsl:variable>
      <xsl:if test="string-length(normalize-space($emphasis)) > 0">
          <xsl:call-template name="insertParaInSection">
              <xsl:with-param name="childOfPara" select="$emphasis"/>
          </xsl:call-template>
      </xsl:if>
  </xsl:template>
  
  <xsl:template match="e:i | e:em">
      <xsl:variable name="emphasis">
          <emphasis role="italic" xmlns="http://docbook.org/ns/docbook">
              <xsl:apply-templates select="@* | node()"/>
          </emphasis>
      </xsl:variable>
      <xsl:if test="string-length(normalize-space($emphasis)) > 0">
          <xsl:call-template name="insertParaInSection">
              <xsl:with-param name="childOfPara" select="$emphasis"/>
          </xsl:call-template>
      </xsl:if>
  </xsl:template>

  <xsl:template match="e:u">
      <xsl:variable name="emphasis">
          <emphasis role="underline" xmlns="http://docbook.org/ns/docbook">
              <xsl:apply-templates select="@* | node()"/>
          </emphasis>
      </xsl:variable>
      <xsl:if test="string-length(normalize-space($emphasis)) > 0">
          <xsl:call-template name="insertParaInSection">
              <xsl:with-param name="childOfPara" select="$emphasis"/>
          </xsl:call-template>
      </xsl:if>
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
            <xsl:when test="(parent::e:section or parent::e:span/parent::e:section)
                              and not(parent::e:i or parent::e:em or
                              parent::e:b or parent::e:strong or parent::e:u)
                              or parent::e:li[parent::e:ul or parent::e:ol]">
                <para xmlns="http://docbook.org/ns/docbook"><xsl:value-of select="translate(., '&#xA0;', ' ')"/></para>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="translate(., '&#xA0;', ' ')"/></xsl:otherwise>
        </xsl:choose>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:template>
  
  
  <xsl:template match="e:section">
        <xsl:variable name="contextNames" select="tokenize($context.path.names, $context.item.separator)"/>
        <xsl:variable name="sectNames" select="('sect1', 'sect2', 'sect3', 'sect4', 'sect5')"/>
        <xsl:variable name="allSectAncestors" select="for $i in 1 to count($sectNames) return 
            if (not(empty(index-of($contextNames, subsequence($sectNames, $i, 1))))) then
            subsequence($sectNames, $i, 1) else ()"/>
        <xsl:variable name="sectAncestor" select="$allSectAncestors[last()]"/>
        <xsl:variable name="sectLevel" select="1 + count(ancestor::e:section)"/>
        <xsl:variable name="elementName">
            <xsl:choose>
                <xsl:when test="count(index-of($contextNames, 'section')) > 0 or (empty($sectAncestor) and $preferGenericSections)">
                    <xsl:text>section</xsl:text>
                </xsl:when>
                <xsl:when test="empty($sectAncestor)">
                    <xsl:choose>
                        <xsl:when test="$sectLevel &lt; 6">
                            <xsl:text>sect</xsl:text>
                            <xsl:value-of select="$sectLevel"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>para</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$sectAncestor = 'sect1'">
                    <xsl:choose>
                        <xsl:when test="$sectLevel &lt; 5">
                            <xsl:text>sect</xsl:text>
                            <xsl:value-of select="1 + $sectLevel"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>para</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$sectAncestor = 'sect2'">
                    <xsl:choose>
                        <xsl:when test="$sectLevel &lt; 4">
                            <xsl:text>sect</xsl:text>
                            <xsl:value-of select="2 + $sectLevel"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>para</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$sectAncestor = 'sect3'">
                    <xsl:choose>
                        <xsl:when test="$sectLevel &lt; 3">
                            <xsl:text>sect</xsl:text>
                            <xsl:value-of select="3 + $sectLevel"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>para</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$sectAncestor = 'sect4'">
                    <xsl:choose>
                        <xsl:when test="$sectLevel &lt; 2">
                            <xsl:text>sect</xsl:text>
                            <xsl:value-of select="4 + $sectLevel"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>para</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>para</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="string($elementName) = 'para'">
                <para xmlns="http://docbook.org/ns/docbook">
                    <emphasis role="bold"><xsl:apply-templates select="e:title"/></emphasis>
                </para>
                <xsl:apply-templates 
                    select="node()[local-name() != 'title' and local-name() != 'section']"/>
                <xsl:apply-templates select="e:section"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{$elementName}" namespace="http://docbook.org/ns/docbook">
                    <title xmlns="http://docbook.org/ns/docbook">
                        <xsl:apply-templates select="e:title"/>
                    </title>
                    <xsl:apply-templates 
                        select="node()[local-name() != 'title' and local-name() != 'section']"/>
                    <xsl:apply-templates select="e:section"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template name="insertParaInSection">
        <xsl:param name="childOfPara"/>
        <xsl:choose>
            <xsl:when test="parent::e:section">
                <para xmlns="http://docbook.org/ns/docbook"><xsl:copy-of select="$childOfPara"/></para>
            </xsl:when>
            <xsl:otherwise><xsl:copy-of select="$childOfPara"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="keepDirection">
        <xsl:choose>
            <xsl:when test="@dir">
                <xsl:attribute name="dir">
                    <xsl:value-of select="lower-case(@dir)"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="@DIR">
                <xsl:attribute name="dir">
                    <xsl:value-of select="lower-case(@DIR)"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="count(e:span[@dir]|e:span[@DIR]) = 1">
                <xsl:attribute name="dir">
                    <xsl:value-of select="lower-case((e:span/@dir|e:span/@DIR)[1])"/>
                </xsl:attribute>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>