<?xml version="1.0" encoding="UTF-8"?>
<!-- 
  Copyright 2001-2012 Syncro Soft SRL. All rights reserved.
 -->
<xsl:stylesheet version="2.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:e="http://www.oxygenxml.com/xsl/conversion-elements"
                xmlns:f="http://www.oxygenxml.com/xsl/functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xsl e f xs">
  
  <xsl:template match="e:h1[ancestor::e:dl]
                     | e:h1[ancestor::e:section] 
                     | e:h2[ancestor::e:dl] 
                     | e:h2[ancestor::e:section] 
                     | e:h3[ancestor::e:dl] 
                     | e:h3[ancestor::e:section] 
                     | e:h4[ancestor::e:dl] 
                     | e:h4[ancestor::e:section] 
                     | e:h5[ancestor::e:dl]
                     | e:h5[ancestor::e:section]
                     | e:h6[ancestor::e:dl]
                     | e:h6[ancestor::e:section]">
      <b>
       <xsl:apply-templates select="@* | node()"/>
    </b>
  </xsl:template>

  <xsl:template match="e:p">
      <xsl:choose>
          <xsl:when test="(parent::e:td | parent::e:th) and count(parent::*[1]/*) = 1">
               <xsl:apply-templates select="@* | node()"/>
          </xsl:when>
          <xsl:when test="parent::e:ul | parent::e:ol">
              <!-- EXM-27834  Workaround for bug in OpenOffice/LibreOffice -->
              <li>
                  <p>
                      <xsl:call-template name="keepDirection"/>
                      <xsl:apply-templates select="@* | node()"/>
                  </p>
              </li>
          </xsl:when>
          <xsl:otherwise>
              <p>
                  <xsl:call-template name="keepDirection"/>
                  <xsl:apply-templates select="@* | node()"/>
              </p>
          </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
    
  <xsl:template match="e:span[preceding-sibling::e:p and not(following-sibling::*)]">
     <p>
        <xsl:call-template name="keepDirection"/>
        <xsl:apply-templates select="@* | node()"/>
     </p>
  </xsl:template>
     
  <xsl:template match="e:pre">
    <xsl:choose>
      <xsl:when test="($context.path.last.name = 'codeblock' or $context.path.last.name = 'pre') and $context.path.last.uri = ''">
         <xsl:apply-templates select="@* | node()"/>
      </xsl:when>
      <xsl:otherwise>
        <pre>
          <xsl:call-template name="keepDirection"/>
          <xsl:apply-templates select="@* | node()"/>
        </pre>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="e:code">
    <xsl:choose>
      <xsl:when test="($context.path.last.name = 'codeblock' or $context.path.last.name = 'pre') and $context.path.last.uri = ''">
           <xsl:apply-templates select="@* | node()"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- Multimple lines content, insert codeblock. -->
        <xsl:choose>
          <xsl:when test="contains(string-join(text(), ' '), '&#10;')">
            <codeblock>
              <xsl:call-template name="keepDirection"/>
              <xsl:apply-templates select="@* | node()"/>
            </codeblock>
          </xsl:when>
          <xsl:otherwise>
            <!-- For inline content use codeph. -->
            <codeph>
              <xsl:call-template name="keepDirection"/>
              <xsl:apply-templates select="@* | node()"/>
            </codeph>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
   
  
  <!-- Hyperlinks -->
  <xsl:template match="e:a[starts-with(@href, 'https://') or
                                        starts-with(@href,'http://') or starts-with(@href,'ftp://')]" 
                          priority="1.5">
       <xsl:variable name="xref">
            <xref>
              <xsl:attribute name="href">
                <xsl:value-of select="normalize-space(@href)"/>
              </xsl:attribute>
              <xsl:attribute name="format">html</xsl:attribute>
              <xsl:attribute name="scope">external</xsl:attribute>
              <xsl:call-template name="keepDirection"/>
              <xsl:apply-templates select="@* | * | text()"/>
           </xref>
       </xsl:variable>
       <xsl:call-template name="insertParaInSection">
           <xsl:with-param name="childOfPara" select="$xref"/>
       </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="e:a[contains(@href,'#')]" priority="0.6">
      <xsl:variable name="xref">
            <xref>
              <xsl:attribute name="href">
                <xsl:choose>
                  <xsl:when test="starts-with(@href, '#')">
                    <xsl:value-of select="concat('#./', normalize-space(substring(@href, 2)))"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:call-template name="makeID">
                      <xsl:with-param name="string" select="normalize-space(@href)"/>
                    </xsl:call-template>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
              <xsl:call-template name="keepDirection"/>
              <xsl:apply-templates select="@* | * | text()"/>
            </xref>
      </xsl:variable>
      <xsl:call-template name="insertParaInSection">
          <xsl:with-param name="childOfPara" select="$xref"/>
      </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="e:a[@name != '']" priority="0.6">
    <ph>
      <xsl:attribute name="id">
          <xsl:call-template name="makeID">
            <xsl:with-param name="string" select="normalize-space(@name)"/>
          </xsl:call-template>
      </xsl:attribute>
      <xsl:call-template name="keepDirection"/>
      <xsl:apply-templates select="@* | * | text()"/>
    </ph>
  </xsl:template>
  
  <xsl:template match="e:a[@href != '']">
      <xsl:variable name="xref">
        <xref>
          <xsl:attribute name="href">
            <xsl:call-template name="makeID">
              <xsl:with-param name="string" select="normalize-space(@href)"/>
            </xsl:call-template>
          </xsl:attribute>
          
          <xsl:attribute name="format">
            <xsl:variable name="location">
              <xsl:call-template name="makeID">
                <xsl:with-param name="string" select="normalize-space(@href)"/>
              </xsl:call-template>
            </xsl:variable>
            
            <xsl:variable name="extractedFormat">
              <xsl:call-template name="substring-after-last">
                <xsl:with-param name="whereToSearch" select="$location" />
                <xsl:with-param name="whatYouSearch" select="'.'" />
              </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="$extractedFormat" />
          </xsl:attribute>
          
          <xsl:attribute name="scope" select="'external'"></xsl:attribute>
          
          <xsl:call-template name="keepDirection"/>
          <xsl:apply-templates select="@* | * | text()"/>
        </xref>
      </xsl:variable>
      <xsl:call-template name="insertParaInSection">
          <xsl:with-param name="childOfPara" select="$xref"/>
      </xsl:call-template>
  </xsl:template>
  
  <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl">
    <xd:desc> Search and returns the value after the last occurrence of a token
    </xd:desc>
    <xd:param name="whereToSearch"/>
    <xd:param name="whatYouSearch"/>
  </xd:doc>
  <xsl:template name="substring-after-last">
    <xsl:param name="whereToSearch" select="''" />
    <xsl:param name="whatYouSearch" select="''" />
    
    <xsl:if test="$whereToSearch != '' and $whatYouSearch != ''">
      <xsl:variable name="head" select="substring-before($whereToSearch, $whatYouSearch)" />
      <xsl:variable name="tail" select="substring-after($whereToSearch, $whatYouSearch)" />
      <xsl:value-of select="$tail" />
      <xsl:if test="contains($tail, $whatYouSearch)">
        <xsl:value-of select="$whatYouSearch" />
        <xsl:call-template name="substring-after-last">
          <xsl:with-param name="whereToSearch" select="$tail" />
          <xsl:with-param name="whatYouSearch" select="$whatYouSearch" />
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
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
        <xsl:when test="(namespace-uri-for-prefix('o', .) = 'urn:schemas-microsoft-com:office:office') and $copy.image.resources">
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
    
    <image href="{$pastedImageURL}">
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
    </image>
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
  

    <xsl:template match="e:ul">
        <ul>
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    
    
    <xsl:template match="e:ol">
        <ol>
            <xsl:apply-templates/>
        </ol>
    </xsl:template>


  <xsl:template match="e:kbd">
    <userinput>
      <xsl:call-template name="keepDirection"/>
      <xsl:apply-templates select="@* | node()"/>
    </userinput>
  </xsl:template>
  
  <xsl:template match="e:samp">
    <systemoutput>
      <xsl:call-template name="keepDirection"/>
      <xsl:apply-templates select="@* | node()"/>
    </systemoutput>
  </xsl:template>
  
  <xsl:template match="e:blockquote">
    <lq>
        <xsl:call-template name="keepDirection"/>
        <xsl:apply-templates select="@* | node()"/>
    </lq>
  </xsl:template>
  
  <xsl:template match="e:q">
    <q>
        <xsl:call-template name="keepDirection"/>
        <xsl:apply-templates select="@* | node()"/>
    </q>
  </xsl:template>
  
  <xsl:template match="e:dl">
    <dl>
    	<xsl:apply-templates select="@*"/>
    	<xsl:variable name="dataBeforeTitle" select="e:dd[empty(preceding-sibling::e:dt)]"/>
    	<xsl:if test="not(empty($dataBeforeTitle))">
    		<dlentry>
    			<dt/>
    			<xsl:for-each select="$dataBeforeTitle">
    				<xsl:apply-templates select="."/>
    			</xsl:for-each>
    		</dlentry>
    	</xsl:if>
    	<xsl:for-each select="e:dt">
    		<dlentry>
    			<xsl:apply-templates select="."/>
    			<xsl:apply-templates select="following-sibling::e:dd[current() is preceding-sibling::e:dt[1]]"/>
    		</dlentry>
    	</xsl:for-each>
    </dl>
  </xsl:template>
  
  <xsl:template match="e:dt">
    <dt>
        <xsl:call-template name="keepDirection"/>
        <xsl:apply-templates select="@* | node()"/>
    </dt>
  </xsl:template>
  
  <xsl:template match="e:dd">
    <dd>
        <xsl:call-template name="keepDirection"/>
        <xsl:apply-templates select="@* | node()"/>
    </dd>
  </xsl:template>
    
  <xsl:template match="e:li">
      <li>
          <xsl:call-template name="keepDirection"/>
          <xsl:apply-templates/>
      </li>
  </xsl:template>
          
  <xsl:template match="@id"> 
    <xsl:attribute name="id">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="@dir">
    <xsl:attribute name="dir">
      <xsl:value-of select="lower-case(.)"/>
    </xsl:attribute>
  </xsl:template>
    
  <xsl:template match="@*">
    <!--<xsl:message>No template for attribute <xsl:value-of select="name()"/></xsl:message>-->
  </xsl:template>
  
  <!-- Inline formatting -->
  <xsl:template match="e:b | e:strong">
      <xsl:variable name="bold">
          <b><xsl:apply-templates select="@* | node()"/></b>
      </xsl:variable>
      <xsl:if test="string-length(normalize-space($bold)) > 0">
          <xsl:call-template name="insertParaInSection">
              <xsl:with-param name="childOfPara" select="$bold"/>
          </xsl:call-template>
      </xsl:if>
  </xsl:template>
    
  <xsl:template match="e:i | e:em">
      <xsl:variable name="italic">
          <i><xsl:apply-templates select="@* | node()"/></i>
      </xsl:variable>
      <xsl:if test="string-length(normalize-space($italic)) > 0">
          <xsl:call-template name="insertParaInSection">
              <xsl:with-param name="childOfPara" select="$italic"/>
          </xsl:call-template>
      </xsl:if>
  </xsl:template>
    
  <xsl:template match="e:u">
      <xsl:variable name="underline">
          <u><xsl:apply-templates select="@* | node()"/></u>
      </xsl:variable>
      <xsl:if test="string-length(normalize-space($underline)) > 0">
          <xsl:call-template name="insertParaInSection">
              <xsl:with-param name="childOfPara" select="$underline"/>
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
    <xsl:when test="normalize-space(.) = ''"><xsl:text> </xsl:text></xsl:when>
    <xsl:otherwise><xsl:value-of select="translate(., '&#xA0;', ' ')"/></xsl:otherwise>
   </xsl:choose>
  </xsl:template>
  
  
  <!-- Table conversion -->
    
  <xsl:template match="e:table">
    <xsl:choose>
      <xsl:when test="not(empty(parent::e:td))">
        <p>
          <xsl:call-template name="table"/>
        </p>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="table"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="table">
    <table>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="e:caption">
        <title>
          <xsl:call-template name="keepDirection"/>
          <xsl:apply-templates select="e:caption/node()"/>
        </title>
      </xsl:if>
      <tgroup>
        <xsl:variable name="columnCount">
          <xsl:for-each select="e:tr | e:tbody/e:tr | e:thead/e:tr">
            <xsl:sort
              select="sum(*[@colspan castable as xs:integer]/@colspan) + count(e:td[not(@colspan castable as xs:integer)] | e:th[not(@colspan castable as xs:integer)])"
              data-type="number" order="descending"/>
            <xsl:if test="position() = 1">
              <xsl:value-of
                select="sum(*[@colspan castable as xs:integer]/@colspan) + count(e:td[not(@colspan castable as xs:integer)] | e:th[not(@colspan castable as xs:integer)])"
              />
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:attribute name="cols">
          <xsl:value-of select="$columnCount"/>
        </xsl:attribute>
        <xsl:if
          test="
            e:tr/e:td/@rowspan
            | e:tr/e:td/@colspan
            | e:tbody/e:tr/e:td/@rowspan
            | e:tbody/e:tr/e:td/@colspan
            | e:thead/e:tr/e:th/@rowspan
            | e:thead/e:tr/e:th/@colspan">
          <xsl:call-template name="generateColspecs">
            <xsl:with-param name="count" select="number($columnCount)"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates select="e:thead"/>
        <tbody>
          <xsl:apply-templates
            select="e:tr | e:tbody/e:tr | text() | e:b | e:strong | e:i | e:em | e:u, e:tfoot/e:tr"
          />
        </tbody>
      </tgroup>
    </table>
  </xsl:template>
  
  <xsl:template match="e:thead">
    <thead>
       <xsl:apply-templates select="@* | node()"/>
    </thead>
  </xsl:template>
  
  <xsl:template match="e:tr">
    <row>
       <xsl:apply-templates select="@* | node()"/>
    </row>
  </xsl:template>
  
  <xsl:function name="f:getRowIndex" as="xs:integer">
    <xsl:param name="cell" as="node()"/>
    <xsl:variable name="precedingRows" select="$cell/parent::e:tr/preceding-sibling::e:tr"/>
    <xsl:variable name="currentRowIndex" select="count($precedingRows) + 1"/>
    <xsl:value-of select="$currentRowIndex"/>
  </xsl:function>
  
  <xsl:function name="f:getColIndex" as="xs:integer">
    <xsl:param name="cell" as="node()"/>
    <xsl:value-of select="count($cell/preceding-sibling::e:td) + count($cell/preceding-sibling::e:th)"/>
  </xsl:function>
    
  <xsl:template match="e:th | e:td">
    <xsl:variable name="position" select="count(preceding-sibling::*) + 1"/>
    <entry>
      <xsl:if test="(@colspan castable as xs:integer) and (@colspan > 1)">
        <!-- Current row and column index -->
        <xsl:variable name="currentRowIndex" select="f:getRowIndex(.)"/>
        <xsl:variable name="currentColIndex" select="f:getColIndex(.)"/>
        <!-- Set of preceding rows -->
        <xsl:variable name="precedingRows" select="parent::e:tr/preceding-sibling::e:tr[position() &lt; $currentRowIndex]"/>
        <!-- Preceding cells in column which have row spans over the current row. -->
        <xsl:variable name="previousCellsWithRowSpans" select="
          ancestor::e:table//(e:th | e:td)[@rowspan castable as xs:integer][@rowspan][f:getRowIndex(.) &lt; $currentRowIndex][f:getColIndex(.) &lt;= $currentColIndex][@rowspan + f:getRowIndex(.) &gt; $currentRowIndex]"/>
        <!-- Namestart and name end must be shifted with this shift offset. -->
        <xsl:variable name="shiftColNumber" as="xs:integer" select="count($previousCellsWithRowSpans)"/>
        <!-- The current cell might be pushed to the right by previous cells that span over multiple columns.  -->
        <xsl:variable name="previousCellsWithColSpan" select="preceding-sibling::*[(@colspan castable as xs:integer) and (@colspan > 1)]"/>
        <!-- Compute how many additional columns are occupied by the cells located to the left of the current cell. -->
        <xsl:variable name="colspanShift" select="sum(($previousCellsWithRowSpans, $previousCellsWithColSpan)/(@colspan - 1))"/>    
        
        <xsl:attribute name="namest">
          <xsl:value-of select="concat('col', $position + $shiftColNumber + $colspanShift)"/>
        </xsl:attribute>
        <xsl:attribute name="nameend">
          <xsl:value-of select="concat('col', $position + number(@colspan) - 1 + $shiftColNumber + $colspanShift)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@rowspan castable as xs:integer and @rowspan > 1">
          <xsl:attribute name="morerows">
            <xsl:value-of select="number(@rowspan) - 1"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:call-template name="keepDirection"/>
        <xsl:apply-templates select="@* | node()"/>
    </entry>
  </xsl:template>
  

  <xsl:template name="generateColspecs">
    <xsl:param name="count" select="0"/>
    <xsl:param name="number" select="1"/>
    <xsl:choose>
      <xsl:when test="$count &lt; $number"/>
      <xsl:otherwise>
        <colspec>
          <xsl:attribute name="colnum">
            <xsl:value-of select="$number"/>
          </xsl:attribute>
          <xsl:attribute name="colname">
            <xsl:value-of select="concat('col', $number)"/>
          </xsl:attribute>
        </colspec>
        <xsl:call-template name="generateColspecs">
          <xsl:with-param name="count" select="$count"/>
          <xsl:with-param name="number" select="$number + 1"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <xsl:template match="e:section">
    <xsl:if test="e:title">
      <xsl:choose>
        <xsl:when test="$context.path.last.name = 'body'">
          <p><b><xsl:apply-templates select="e:title"/></b></p>
        </xsl:when>
        <xsl:otherwise>
          <b><xsl:apply-templates select="e:title"/></b>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates 
      select="node()[local-name() != 'title' and local-name() != 'section']"/>
    <xsl:apply-templates select="e:section"/>
  </xsl:template>
  
  
  <xsl:template match="e:section[e:title][empty(parent::e:section)][$replace.entire.root.contents][$context.path.last.name = 'topic']">
    <xsl:element name="topic">
      <title>
        <xsl:apply-templates select="e:title"/>
      </title>
      <body>
        <!-- Process all children except the title -->
        <xsl:apply-templates 
          select="node()[not(self::e:title)]"/>
      </body>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="e:section[e:title][parent::e:section][$replace.entire.root.contents][$context.path.last.name = 'topic']">
    <section>
      <title><xsl:apply-templates select="e:title"/></title>
      <xsl:apply-templates 
        select="node()[local-name() != 'title' and local-name() != 'section']"/>
    </section>
  </xsl:template>
    
    <xsl:template name="insertParaInSection">
        <xsl:param name="childOfPara"/>
        <!--<xsl:choose>
            <xsl:when test="parent::e:section">
                <p><xsl:copy-of select="$childOfPara"/></p>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$childOfPara"/>
            </xsl:otherwise>
        </xsl:choose>-->
      <xsl:copy-of select="$childOfPara"/>
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