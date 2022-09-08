<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:df="http://dita2indesign.org/dita/functions" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:map2graphicmap="urn:d4p:map2graphicmap"  
  
  xmlns:gmap="http://dita4publishers/namespaces/graphic-input-to-output-map" exclude-result-prefixes="xs df relpath"
  version="2.0">

  <!--
  <xsl:import href="lib/dita-support-lib.xsl"/>
  <xsl:import href="lib/relpath_util.xsl"/>
-->
  <xsl:output name="graphic-map" method="xml" indent="yes"/>
  <xsl:output name="ant" method="xml" indent="yes"/>

  <xsl:template match="*[df:class(., 'map/map')]" mode="generate-graphic-map">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="effectiveCoverGraphicUri" select="''" as="xs:string" tunnel="yes"/>
    
<!--   <xsl:variable name="doDebug" as="xs:boolean" select="true()"/>  -->
    
    <xsl:variable name="docMapUri" select="concat(relpath:getParent(@xtrf), '/')" as="xs:string"/>
    <xsl:message> + [INFO] Generating graphic input-to-output map...</xsl:message>
    
    <xsl:variable name="graphicRefs" as="element()*">
      <xsl:if test="$doDebug">
        <xsl:message> + [DEBUG] ** generate-graphic-map: Applying templates in mode get-graphic-refs to all topicrefs...</xsl:message>
      </xsl:if>
      <xsl:apply-templates mode="get-graphic-refs" select=".//*[df:isTopicRef(.)]">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        <xsl:with-param name="docMapUri" select="$docMapUri" tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:if test="$doDebug">
        <xsl:message> + [DEBUG] ** generate-graphic-map: Done with topicrefs</xsl:message>
      </xsl:if>
      <xsl:if test="$FILTERDOC">
        <xsl:apply-templates mode="get-graphic-refs" select="$FILTERDOC/*">
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="$doDebug">
        <xsl:message> + [DEBUG] ** generate-graphic-map: Applying templates to map in mode additional-graphic-refs...</xsl:message>
      </xsl:if>
      <xsl:apply-templates mode="additional-graphic-refs" select=".">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        <xsl:with-param name="docMapUri" select="$docMapUri" tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:if test="$doDebug">
        <xsl:message> + [DEBUG] ** generate-graphic-map: Additional-graphic-refs done</xsl:message>
      </xsl:if>
    </xsl:variable>
    
    <xsl:message> + [INFO] Found <xsl:sequence select="count($graphicRefs)"/> graphic references.</xsl:message>
    <xsl:variable name="uniqueRefs" as="element()">
      <root>
        <xsl:for-each-group select="$graphicRefs" group-by="string(@href)">
          <xsl:sequence select="current-group()[1]"/>
        </xsl:for-each-group>
      </root>
    </xsl:variable>
    <xsl:message> + [INFO] Found <xsl:sequence select="count($uniqueRefs/*)"/> unique graphic references.</xsl:message>
    
    <gmap:graphic-map>
      <xsl:if test="$doDebug">
        <xsl:message> + [DEBUG] generate-graphic-map: Calling template handleImageListFile..."</xsl:message>
      </xsl:if>
      <xsl:call-template name="handleImageListFile">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:call-template>
      <xsl:if test="$doDebug">
        <xsl:message> + [DEBUG] generate-graphic-map: HandleImageListFile done."</xsl:message>
      </xsl:if>
      <xsl:if test="$doDebug">
        <xsl:message> + [DEBUG] generate-graphic-map: Applying templtaes to unique refs..."</xsl:message>
      </xsl:if>
      <xsl:apply-templates mode="#current" select="$uniqueRefs">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
      <xsl:if test="$doDebug">
        <xsl:message> + [DEBUG] generate-graphic-map: Unique ref processing done."</xsl:message>
      </xsl:if>
    </gmap:graphic-map>
    <xsl:message> + [INFO] Graphic input-to-output map generated.</xsl:message>
  </xsl:template>
  
  <xsl:template mode="generate-graphic-map" match="gmap:graphic-ref">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:variable name="absoluteUrl" as="xs:string" select="@href"/>
    <xsl:variable name="outputUrl" as="xs:string">
      <xsl:apply-templates select="." mode="gmap:get-output-url">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </xsl:variable>
    <gmap:graphic-map-item input-url="{$absoluteUrl}" output-url="{$outputUrl}">
      <xsl:if test="$doDebug">
        <xsl:message> + [DEBUG] generate-graphic-map: ref=<xsl:sequence select="."/></xsl:message>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="@id != ''">
          <xsl:sequence select="@id"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="id" select="generate-id(.)"/>
        </xsl:otherwise>
      </xsl:choose>
      <!-- Copy any additional attributes. This includes the EPUB3-specific @properties attribute: -->
      <xsl:sequence select="@* except (@href, @filename)"/>
      
    </gmap:graphic-map-item>
    
  </xsl:template>
  
  <!-- Default handler: assume it's a graphic and goes in the images directory -->
  <xsl:template mode="gmap:get-output-url" match="gmap:graphic-ref" >
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:variable name="absoluteUrl" as="xs:string" select="@href"/>
    <xsl:variable name="filename" as="xs:string" select="@filename"/>
    <xsl:variable name="namePart" as="xs:string" select="relpath:getNamePart($filename)"/>
    <xsl:variable name="extension" as="xs:string" select="relpath:getExtension($filename)"/>
    <xsl:variable name="key"
      select="
      if (count(preceding-sibling::*[@filename = $filename]) > 0)
      then concat($namePart, '-', count(preceding-sibling::*[@filename = $filename]) + 1, '.', $extension)
      else $filename
      "/>
    <xsl:choose>
      <xsl:when test="@targetDir">
        <xsl:variable name="outputPath" as="xs:string" select="relpath:toUrl(relpath:newFile($outdir, @targetDir))"/>
        <xsl:sequence select="relpath:newFile($outputPath, $key)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="relpath:newFile($imagesOutputPath, $key)"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  <xsl:template mode="additional-graphic-refs" match="*[df:class(., 'map/map')]">
    <!-- Nothing to do by default. Override this template to do something special,
         such as setting a default cover graphic or including branding components
         or whatever.
    -->
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] additional-graphic-refs: Base do-nothing implementation in common.xslt map2graphicMap.xsl.</xsl:message>
    </xsl:if>
  </xsl:template>


  <xsl:template mode="get-graphic-refs"
                match="*[df:isTopicRef(.)]
                             [not(@scope = ('external', 'peer'))]
                             "
    >
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:variable name="topic" select="df:resolveTopicRef(.)" as="element()*"/>

    <xsl:choose>
      <xsl:when test="not($topic)">
        <xsl:message> + [WARNING] get-graphic-refs: Failed to resolve topic reference to href
            "<xsl:sequence select="string(@href)"/>"</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <!-- If @copy-to is specified then we need to handle images and object.
          
          If @copy-to is not specified, then we only handle object elements as
          the images will have been handled by preprocessing and listed in image.list.
          -->
        <xsl:choose>
          <xsl:when test="@copy-to">
            <xsl:apply-templates
              select="$topic//*[df:class(.,'topic/image')] | 
                      $topic//*[df:class(.,'topic/object')]"
              mode="#current">
              <xsl:with-param name="copyto" select="string(@copy-to)" as="xs:string" tunnel="yes"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates
              select="$topic//*[df:class(.,'topic/object')]"
              mode="#current">
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="*[df:class(.,'topic/object')]" mode="get-graphic-refs">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] get-graphic-refs: <xsl:value-of select="concat(name(..), '/', name(.))"/></xsl:message>
    </xsl:if>

    <!-- NOTE: For object elements, the @data attribute points at the main
               object data object, but its location may be relative to @codebase.
               It's a bit ambiguous in practice whether the @data object will
               be managed with the source, and therefore needs to be copied,
               or will be managed separately, when @codebase is specified.
               This code assumes that if @codebase is specified, @data should
               be ignored. Override this template to change this behavior to
               match what you actually do, if necessary.
      -->

    <xsl:variable name="docUri" select="relpath:toUrl(@xtrf)" as="xs:string"/>
    <xsl:variable name="parentPath" select="relpath:getParent($docUri)" as="xs:string"/>
    <xsl:variable name="dataPath" select="@data" as="xs:string?"/>
    <xsl:variable name="codeBase" select="@codebase" as="xs:string?"/>
    <xsl:if test="$debugBoolean">
      <xsl:message> + [DEBUG] get-graphic-refs for object: docUri="<xsl:sequence select="$docUri"/>"
          parentPath="<xsl:sequence select="$parentPath"/>" dataPath="<xsl:sequence select="$dataPath"/>"
          codeBase="<xsl:sequence select="$codeBase"/>" </xsl:message>
    </xsl:if>
    <xsl:if test="$dataPath != '' and not(starts-with($dataPath, 'http:'))">
      <xsl:variable name="rawUrl"
        select="if (@codeBase != '')
        then relpath:newFile($codeBase, $dataPath)
        else relpath:newFile($parentPath, $dataPath)"
        as="xs:string"/>
      <xsl:variable name="absoluteUrl" select="relpath:getAbsolutePath($rawUrl)"/>
      <xsl:if test="$debugBoolean">
        <xsl:message> rawUrl="<xsl:sequence select="$rawUrl"/>" absoluteUrl="<xsl:sequence select="$absoluteUrl"/>"
        </xsl:message>
      </xsl:if>
      <xsl:if test="$dataPath and not($codeBase = '')">
        <gmap:graphic-ref href="{$absoluteUrl}" filename="{relpath:getName($absoluteUrl)}"/>
      </xsl:if>
    </xsl:if>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="*[df:class(.,'topic/param')][@valuetype = 'ref']" mode="get-graphic-refs">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] get-graphic-refs: <xsl:value-of select="concat(name(..), '/', name(.))"/></xsl:message>
    </xsl:if>
    
    
    <xsl:variable name="docUri" select="relpath:toUrl(@xtrf)" as="xs:string"/>
    <xsl:variable name="parentPath" select="relpath:getParent($docUri)" as="xs:string"/>
    <xsl:variable name="valuePath" select="@value" as="xs:string?"/>
    <xsl:variable name="rawUrl" select="concat($parentPath, '/', $valuePath)" as="xs:string"/>
    <xsl:variable name="absoluteUrl" select="relpath:getAbsolutePath($rawUrl)"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] get-graphic-refs for param: docUri="<xsl:sequence select="$docUri"/>"
          parentPath="<xsl:sequence select="$parentPath"/>" valuePath="<xsl:sequence select="$valuePath"/>"
      </xsl:message>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="not($valuePath)">
        <xsl:variable name="topic" as="element()?" select="(ancestor-or-self::*[df:class(., 'topic/topic')])[1]"/>
        <xsl:variable name="contextString" as="xs:string"
          select="if ($topic)
          then concat('Topic ', df:getNavtitleForTopic($topic))
          else name(..)"/>
        <xsl:message> + [WARN] param element with @valuetype of 'ref' but no @value attribute in <xsl:sequence
            select="$contextString"/></xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <gmap:graphic-ref href="{$absoluteUrl}" filename="{relpath:getName($absoluteUrl)}"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="val | val/prop | val/revprop" mode="get-graphic-refs">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="startflag[@imageref] | endflag[@imageref]" mode="get-graphic-refs">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:variable name="docUri" select="string(document-uri(root(.)))" as="xs:string"/>
    <xsl:variable name="parentPath" select="relpath:getParent($docUri)" as="xs:string"/>
    <xsl:variable name="graphicPath" select="@imageref" as="xs:string"/>
    <xsl:variable name="rawUrl" select="concat($parentPath, '/', $graphicPath)" as="xs:string"/>
    <xsl:variable name="absoluteUrl" select="relpath:getAbsolutePath($rawUrl)"/>

    <xsl:if test="$graphicPath">
      <gmap:graphic-ref href="{$absoluteUrl}" filename="{relpath:getName($absoluteUrl)}"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="text()" mode="generate-graphic-map get-graphic-refs"/>

  <xsl:template name="handleImageListFile">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="uplevels" as="xs:string" select="''" tunnel="yes" />
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] handleImageListFile: Starting...</xsl:message>
    </xsl:if>
    <xsl:variable name="imageListUri" as="xs:string"
      select="relpath:newFile($tempdir, 'image.list')"
    />
    <xsl:choose>
      <xsl:when test="unparsed-text-available($imageListUri)">
        <xsl:if test="$doDebug">
          <xsl:message> + [DEBUG] handleImageListFile: Image list file is available.</xsl:message>
        </xsl:if>
        <xsl:variable name="imageList"
          select="unparsed-text($imageListUri)"
        />
        <xsl:if test="$doDebug">
          <xsl:message> + [DEBUG] handleImageListFile: Image List:
            <xsl:sequence select="$imageList"/>
          </xsl:message>
        </xsl:if>
        <xsl:for-each select="tokenize($imageList, '&#x0a;')">
          <xsl:if test="$doDebug">
            <xsl:message> + [DEBUG] handleImageListFile: line[<xsl:value-of select="position()"/>]="<xsl:value-of select="."/>"</xsl:message>
          </xsl:if>
          <xsl:variable name="textNode" as="text()">
            <xsl:value-of select="."/>
          </xsl:variable>
          <xsl:apply-templates select="$textNode" mode="map2graphicmap:handleImageListFile">
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            <xsl:with-param name="uplevels" as="xs:string" tunnel="yes" select="$uplevels" />
            <xsl:with-param name="position" as="xs:integer" select="position()"/>
          </xsl:apply-templates>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message> + [INFO] Did not find image list file "<xsl:value-of select="$imageListUri"/>"</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="map2graphicmap:handleImageListFile" match="text()">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="uplevels" as="xs:string" select="''" tunnel="yes" />
    <xsl:param name="position" as="xs:integer"/>
    
    <xsl:variable name="inputdirUrl" as="xs:string"
      select="relpath:toUrl($inputdir)"
    />
    
    <xsl:variable name="absoluteUrl" as="xs:string"
      select="relpath:newFile($inputdirUrl, concat(replace($uplevels, '\\', '/'), .))"
    />
    
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] map2graphicmap:handleImageListFile: absoluteUrl="<xsl:value-of select="$absoluteUrl"/>"</xsl:message>
    </xsl:if>
    
    <gmap:graphic-map-item id="image-list-item-{$position}"
      input-url="{$absoluteUrl}"
      output-url="{relpath:toUrl(relpath:newFile($imagesOutputPath, relpath:getName($absoluteUrl)))}"/>
    
  </xsl:template>
  
  
</xsl:stylesheet>
