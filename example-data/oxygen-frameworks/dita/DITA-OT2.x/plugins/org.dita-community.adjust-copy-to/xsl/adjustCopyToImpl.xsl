<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:local="urn:local-functions"
  exclude-result-prefixes="xs xd df relpath local"
  version="2.0">

<!-- ===================================================
     Implementation of custom @copy-to adjustment.
     
     See adjustCopyTo.xsl for details.
     
     Copyright (c) 2014, 2015 DITA Community

     The input to this transform is a fully-resolved map, e.g.,
     the output of the Open Toolkit mappull process (that is, 
     the copy of the original input map that is in the OT's
     temp directory).
     
     The output is a new single-document map with the @copy-to
     values adjusted as appropriate.
     
     Also generates:
     
     * a job XML file that reflects only those
       files whose copy-to value has changed
       
     * An updated full job XML file reflecting the 
       adjusted copy-tos
       
     * An updated keydef.xml file with additional keydef
       entries for updated copy-tos.
     
     Default mode is a normal identity transform.

     =================================================== -->
  
  <xsl:import href="plugin:org.dita-community.common.xslt:xsl/relpath_util.xsl"/>
  <xsl:import href="plugin:org.dita-community.common.xslt:xsl/dita-support-lib.xsl"/>
  
  <!-- Use navigation keys to determine source filenames. Default
       is to use first only only key on the topicref.
       
       Default is "no" (nav keys not used).
    -->
  <xsl:param name="use-nav-keys" as="xs:string" select="'no'"/>
  <xsl:variable name="isUseNavKeys" as="xs:boolean"
    select="matches($use-nav-keys, 'yes|true|on|1', 'i')"
  />
  
  <!-- Override existing copy-to values when the topicref would otherwise
       get a copy-to value (e.g., when use-nav-keys is in effect).
       
       Default is "no" (do not override existing copy-to values).
    -->
  <xsl:param name="override-existing-copy-to" as="xs:string" select="'no'"/>
  <xsl:variable name="isOverrideExistingCopyTo" as="xs:boolean"
    select="matches($override-existing-copy-to, 'yes|true|on|1', 'i')"
  />
  
  <!-- Expand topicrefs in relationship table cells such that
       references to topics that are not to a specific use of 
       the topic (i.e., not to a navigation topicref by key)
       are duplicated, once for each unique copy-to value 
       produced for that topic.
       
       Implementation TBD
    -->
  <xsl:param name="expand-reltable-refs" as="xs:string" select="'no'"/>
  <xsl:param name="isExpandReltableRefs" as="xs:boolean" 
    select="matches($expand-reltable-refs, 'yes|true|on|1', 'i')"
  />
  
  <!-- Absolute path to the directory containing the job.xml.dir (normally the dita temp dir) -->
  <xsl:param name="job.xml.dir.url" as="xs:string"/><!-- URL of directory containing .job.xml file -->
  <xsl:param name="copyToChangesJob.filename" as="xs:string" select="'copyToChangesJob.xml'"/>
  <xsl:param name="updatedJob.filename" as="xs:string" select="'updatedJob.xml'"/>
  <xsl:param name="updatedKeydefs.filename" as="xs:string" select="'updatedKeydefs.xml'"/>
  
  <xsl:variable name="jobXmlDoc" as="document-node()"
    select="document(relpath:newFile($job.xml.dir.url, '.job.xml'))"
  />
  <xsl:variable name="keydefXmlDoc" as="document-node()"
    select="document(relpath:newFile($job.xml.dir.url, 'keydef.xml'))"
  />
  
  <xsl:param name="debug" as="xs:string" select="'false'"/>
  <xsl:variable name="doDebug" as="xs:boolean"
    select="matches($debug, 'yes|true|on|1', 'i')"
  />
  
  <xsl:template match="/">
    <!-- Context is resolved map -->
    
    <xsl:variable name="doDebug" as="xs:boolean" select="$doDebug"/>
    
    <xsl:call-template name="report-parameters"/>
    
    <xsl:variable name="mapFileName" as="xs:string"
      select="relpath:getName(document-uri(.))"
    />
    
    <!-- Map of topics to their copy-to values. Also 
         captures the set of navigation topicrefs that
         points to a given topic.
      -->
    <xsl:variable name="topicToCopyToMap" as="element()">
      <xsl:apply-templates mode="makeCopyToMap">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </xsl:variable>
    
    <xsl:if test="true() or $doDebug">
      <xsl:variable name="uri" as="xs:string"
        select="relpath:newFile(relpath:getParent(document-uri(root(.))), 'topicToCopyToMap.xml')"/>
      <xsl:message> + [DEBUG] saving topicToCopyToMap to file "<xsl:value-of select="$uri"/>"...</xsl:message>
      <xsl:result-document href="{$uri}"
        method="xml"
        indent="yes"
        >
        <xsl:sequence select="$topicToCopyToMap"/>
      </xsl:result-document>
    </xsl:if>
    
    <xsl:apply-templates select="$topicToCopyToMap" mode="reportCopyToAdjustments">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    
    <!-- Now we know about any new or changed copy-tos.
      
         Update the map, generate a temporary job XML file, and
         update the full job XML file.
      -->
    
    <xsl:apply-templates mode="makeJobFiles" select="$topicToCopyToMap">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    
    <!-- The generate-result-files mode is an extension point that 
         enables generating additional result files during preprocessing,
         for example, generating title-only topics for topicheads where
         the the topicheads will then be replaced by topicrefs to the
         generated files.
         
         This processing needs to be done outside the default-mode map processing
         as you cannot generate result files when constructing the value of
         a variable.
         
      -->
    <xsl:apply-templates mode="generate-result-files" select=".">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
    
    <!-- Generate the updated DITA map: -->
    <xsl:variable name="updatedMap" as="node()*">
      <xsl:apply-templates select="node()">
        <xsl:with-param name="doDebug" as="xs:boolean" select="$doDebug" tunnel="yes"/>
        <xsl:with-param name="topicToCopyToMap" as="element()" tunnel="yes"
          select="$topicToCopyToMap"
        />      
      </xsl:apply-templates>
    </xsl:variable>
    
    <!-- Generate the updated keydef file, reflecting any changed copy-tos: -->
    
    <xsl:call-template name="updateKeydefXml">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      <xsl:with-param name="updatedMap" as="node()*" select="$updatedMap"/>
      <xsl:with-param name="mapFileName" as="xs:string" tunnel="yes" select="$mapFileName"/>
      <xsl:with-param name="topicToCopyToMap" as="element()" tunnel="yes" select="$topicToCopyToMap"/>
    </xsl:call-template>
    
    <xsl:message> + [INFO] Writing updated map document...</xsl:message>
    <!-- The updated map is the direct output of this transform. -->
    
    <xsl:sequence select="$updatedMap"/>
    
    <xsl:message> + [INFO] Done.</xsl:message>
  </xsl:template>
  
  <xsl:template name="report-parameters">
    <xsl:message> + [INFO] ========================================</xsl:message>
    <xsl:message> + [INFO] Adjust copy-to parameters:</xsl:message>
    <xsl:message> + [INFO] </xsl:message>
    <xsl:message> + [INFO] use-nav-keys: "<xsl:value-of select="$use-nav-keys"/>" (<xsl:value-of select="$isUseNavKeys"/>)</xsl:message>
    <xsl:message> + [INFO] override-existing-copy-to: "<xsl:value-of select="$override-existing-copy-to"/>" (<xsl:value-of select="$isOverrideExistingCopyTo"/>)</xsl:message>
    <xsl:message> + [INFO] expand-reltable-refs: "<xsl:value-of select="$expand-reltable-refs"/>" (<xsl:value-of select="$isExpandReltableRefs"/>)</xsl:message>
    <xsl:message> + [INFO] ========================================</xsl:message>
  </xsl:template>
  
  <!-- ==================================
       Mode reportCopyToAdjustments
       ================================== -->
  
  <xsl:template mode="reportCopyToAdjustments" match="topicToCopyToMap">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes"/>
    
    <xsl:message> + [INFO] Copy-to Adjustments:</xsl:message>
    <xsl:choose>
      <xsl:when test="count(mapItem/*/copyTo) = 0">
        <xsl:message> + [INFO]   No adjustments made.</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="mapItem" mode="#current">
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="reportCopyToAdjustments" match="mapItem">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes"/>

    <xsl:message> + [INFO]  For topic <xsl:value-of select="key"/>:</xsl:message>
    <xsl:apply-templates mode="#current" select="value">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="reportCopyToAdjustments" match="value">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes"/>
    <xsl:apply-templates mode="#current" select="copyTo">
      <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template mode="reportCopyToAdjustments" match="copyTo">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes"/>

    <xsl:message> + [INFO]   copy-to: "<xsl:value-of select="@copy-to"/>" <xsl:value-of select="if (@isNew = ('true')) then '[New]' else ''"/></xsl:message>
  </xsl:template>

  <!-- ==================================
       Mode updateKeydefXml
       ================================== -->
  
  <xsl:template name="updateKeydefXml">
    <xsl:param name="doDebug" as="xs:boolean" select="false()" tunnel="yes"/>
    <xsl:param name="updatedMap" as="node()*"/>
    <xsl:param name="topicToCopyToMap" as="element()" tunnel="yes"/>

    <xsl:variable name="updatedKeydefXmlUrl" as="xs:string"
      select="relpath:newFile($job.xml.dir.url, $updatedKeydefs.filename)"
    />
    
    <xsl:message> + [INFO] updateKeydefXml: Generating updatedKeydef.xml file: <xsl:value-of select="$updatedKeydefXmlUrl"/>... </xsl:message>
    
    <xsl:result-document href="{$updatedKeydefXmlUrl}" method="xml" indent="no">
      <stub>
        <xsl:apply-templates mode="updateKeydefXml"
          select="$updatedMap//*[df:class(., 'map/topicref')]
                                [@keys != '']">
          <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        </xsl:apply-templates>
      </stub>
    </xsl:result-document>    
  </xsl:template>
  
  <xsl:template mode="updateKeydefXml" 
    match="*[df:class(., 'map/topicref')]">
    <xsl:param name="doDebug" as="xs:boolean" select="false()" tunnel="yes"/>
    <xsl:param name="mapFileName" as="xs:string" tunnel="yes"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] updateKeydefXml: Handling topicref <xsl:sequence select="df:reportTopicref(.)"/></xsl:message>
    </xsl:if>
    
    <xsl:variable name="thisTopicref" as="element()" select="."/>
    <xsl:variable name="keys" as="xs:string*"
      select="tokenize(normalize-space(@keys), ' ')"
    />
    
    <xsl:for-each select="$keys">
      <xsl:variable name="key" as="xs:string" select="."/>
      <xsl:choose>
        <xsl:when test="$thisTopicref/preceding::*[$key = tokenize(normalize-space(@keys), ' ')]">
          <!-- Key is already defined in the map, skip this key -->
          <xsl:if test="$doDebug">
            <xsl:message> + [DEBUG] updateKeydefXml: key "<xsl:value-of select="."/>" already defined in map, skipping. </xsl:message>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="$doDebug">
            <xsl:message> + [DEBUG] updateKeydefXml: key "<xsl:value-of select="."/>" is first definition, capturing the keydef. </xsl:message>
          </xsl:if>
          <!-- Generate a keydef entry for this key 
          
               Not sure how best to set the @source attribute. May
               not be essential.
          -->
        <keydef
          keys="{$key}"
          source="{$mapFileName}"          
          >
          <xsl:attribute name="href" 
            select="($thisTopicref/@copy-to, $thisTopicref/@href)[1]"
          />
          <xsl:choose>
            <xsl:when test="$thisTopicref/@scope">
              <xsl:sequence select="$thisTopicref/@scope"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="scope" select="'local'"/>
            </xsl:otherwise>
          </xsl:choose>          
        </keydef>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  
  <!-- ==================================
       Mode makeCopyToMap 
       ================================== -->
  
  <xsl:template match="/*" mode="makeCopyToMap">
    <xsl:param name="doDebug" as="xs:boolean" select="false()" tunnel="yes"/>
    
    <xsl:message> + [INFO] Analyzing topicrefs to determine copy-to adjustments...</xsl:message>
    

    <topicToCopyToMap>
      <!-- Group topicrefs to topics by
           absolute URL of the topic referenced.
           
           Each map entry reflects one topic and lists
           all the topicrefs to it.
           
           The map resulting from mappull has both
           keyref and href values on topicrefs
           that only had keyrefs, so this should
           reliably include all topicrefs.
      
      -->
      <xsl:if test="$doDebug">
          <xsl:message> + [DEBUG] Topicrefs selected for analysis:</xsl:message>
        <xsl:for-each-group 
          select=".//*[local:isCopytoCandidate(.)]"
          group-by="local:makeHrefAbsolute(.)"
          >
          <xsl:message> + [DEBUG] Group "<xsl:value-of select="current-grouping-key()"/>"</xsl:message>
          <xsl:for-each select="current-group()">
            <xsl:message> + [DEBUG] ++++</xsl:message>
            <xsl:message> + [DEBUG]   href="<xsl:sequence select="@href"/>"</xsl:message>
            <xsl:message> + [DEBUG]   keyref="<xsl:sequence select="@keyref"/>"</xsl:message>
            <xsl:message> + [DEBUG]   keys="<xsl:sequence select="@keys"/>"</xsl:message>
            <xsl:message> + [DEBUG]   not(ancestor::*[contains(@chunk, 'to-content')]=<xsl:value-of select="not(./ancestor::*[contains(@chunk, 'to-content')])"/></xsl:message>
          </xsl:for-each>
        </xsl:for-each-group>
      </xsl:if>
      <xsl:for-each-group 
        select=".//*[local:isCopytoCandidate(.)]"
        group-by="local:makeHrefAbsolute(.)"
        >     
        
        <xsl:if test="$doDebug">
          <xsl:message> + [DEBUG] topicref: grouping-key="<xsl:sequence select="current-grouping-key()"/>", href="<xsl:sequence select="string(current-group()[1]/@href)"/>"
          <xsl:message> + [DEBUG] makeCopyToMap: Handling <xsl:value-of select="count(current-group())"/> topicrefs to topic <xsl:value-of
                               select="@href"/></xsl:message>
          </xsl:message>
        </xsl:if>

        <xsl:choose>
          <xsl:when test="count(current-group()) gt 1">
            <xsl:message> + [INFO]   Found <xsl:value-of select="count(current-group())"/> references to topic <xsl:value-of select="current-grouping-key()"/></xsl:message>
          </xsl:when>
          <xsl:when test="$isUseNavKeys and .[@keys != '']">
            <xsl:message> + [INFO]   Using navigation keys, @keys value "<xsl:value-of select="./@keys"/>" (<xsl:value-of select="current-grouping-key()"/>)</xsl:message>
          </xsl:when>
          <xsl:otherwise>
            <!-- Shouldn't get here -->
          </xsl:otherwise>
        </xsl:choose>

        <mapItem>
          <key><xsl:sequence select="current-grouping-key()"></xsl:sequence></key>
          <value>
            <!-- Value is a sequence of <copy-to> elements that relate topicrefs by generated ID
                 to the @copy-to value to use on that topicref.
              -->
            <xsl:apply-templates select="current-group()" mode="makeCopyToMap">
              <xsl:with-param name="topicrefsForTopic" as="element()+" tunnel="yes"
                select="current-group()"
              />
            </xsl:apply-templates>
          </value>
        </mapItem>
      </xsl:for-each-group>      
    </topicToCopyToMap>

    <xsl:message> + [INFO] Analysis complete.</xsl:message>

  </xsl:template>
  
  <xsl:template mode="makeCopyToMap" match="*[df:class(., 'map/topicref')]">
    <xsl:param name="doDebug" as="xs:boolean" select="false()" tunnel="yes"/>
    <xsl:param name="topicrefsForTopic" as="element()+" tunnel="yes"/>
 
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] makeCopyToMap: Handling topicref <xsl:sequence select="df:reportTopicref(.)"/></xsl:message>
    </xsl:if>
 
    <xsl:variable name="copytoValue">
      <!-- Must be '' for unchanged or unset copy-to. Must have a value
           for new or modified copy-to values.
        -->
      <xsl:apply-templates select="." mode="determineCopytoValue"/>
    </xsl:variable>
    <!-- If the copy-to value is empty, then don't create an item for this
         topicref.
      -->
    <xsl:if test="$copytoValue != ''">
      <xsl:if test="$doDebug">
        <xsl:message> + [DEBUG] makeCopyToMap:   $copytoValue="<xsl:sequence select="$copytoValue"/>, adding copyTo entry to copy-to map.</xsl:message>
      </xsl:if>
      <!-- If a topicref did not have a @copy-to value, then this must
           be a new copy-to otherwise it must be an updated. Unchanged
           copy-to values should not get here.
        -->
        
      <copyTo 
        topicrefId="{generate-id(.)}" 
        copy-to="{normalize-space($copytoValue)}"
        isNew="{not(@copy-to)}"        
      />
    </xsl:if>
  </xsl:template>
  
  <!-- ==================================
       Mode  determineCopytoValue
       
       Handles topicrefs in the context of all
       topicrefs to a single topic. Determines
       the value to use for the @copy-to attribute
       of the topicref.
       
       Override templates in this mode to customize
       the copy-to values.
       ================================== -->
  
  <xsl:template mode="determineCopytoValue" match="*[df:class(., 'map/topicref')][@href]">
    <xsl:param name="doDebug" as="xs:boolean" select="false()" tunnel="yes"/>
    <xsl:param name="topicrefsForTopic" as="element()+" tunnel="yes"/>
    
     <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] determineCopytoValue: Handling topicref <xsl:sequence select="df:reportTopicref(.)"/></xsl:message>
    </xsl:if>

    <!-- Needs to return a non-empty string if the copy-to value is being set
         or modified.
         
         Return '' if the copy-to value is either unchanged or no value is being
         set.
      -->
    
    <!-- Default implementation: Ensure result filename is unique by adding number
         to the base filename.
      -->
    
    <!-- In the resolved map the @href value is always present and is the relative
         path to the topic.
      -->
    <xsl:variable name="thisTopicref" as="element()" select="."/>
    <xsl:variable name="precedingTopicrefs" as="element()*"
      select="$topicrefsForTopic[. &lt;&lt; $thisTopicref]"
    />
    <xsl:variable name="hrefValue" as="xs:string" 
      select="relpath:getResourcePartOfUri(@href)"
    />
    <xsl:variable name="existingCopyToValue" as="xs:string" 
      select="if (@copy-to) then string(@copy-to) else ''"
    />
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] isUseNavKeys="<xsl:value-of select="$isUseNavKeys"/>"</xsl:message>
    </xsl:if>
    <xsl:choose>
      <!-- If there is an existing copy-to value, only replace
           it with a key if override existing copy-to is on.
        -->
      <xsl:when test="$isUseNavKeys and (@keys != '') and
                      ($isOverrideExistingCopyTo or $existingCopyToValue = '')">
        <!-- Use the @keys value as the copy-to value.
          
             There are some complexities here:
             - While a key will be unique within its scope,
               it may not be unique with respect to topic
               source filenames. Will need some way to 
               make the key-defined copy-to values reliably unique.
               Options include:
               - Separate directory for all key-defined copy-tos
               - A distinguishing prefix or suffix.
               - Don't worry about it.
               - Make copy-to values unique by adding numbers, etc.
               - Leave it up to authors.
               
             - If there are multiple @keys values, we have to choose
               one. Ideal solution would provide a way to choose among
               alternatives using some pattern match. For now, just
               choosing the first one.
           -->
        <xsl:value-of select="concat(tokenize(@keys, ' ')[1], '.dita')"/>
      </xsl:when>
      <xsl:when test="$existingCopyToValue = '' and count($precedingTopicrefs) = 0">
        <xsl:if test="$doDebug">
          <xsl:message> + [DEBUG]     First reference. Not adjusting @copy-to.</xsl:message>
        </xsl:if>
        <xsl:value-of select="''"/><!-- First topicref to the topic, no copy-to value -->
      </xsl:when>
      <xsl:otherwise>
        <!-- If there's already a copy-to on the topicref and it hasn't already been used, 
             use it, otherwise, construct a new value.
        -->
        <xsl:choose>
          <xsl:when test="$existingCopyToValue != '' and 
                          (not($precedingTopicrefs[@copy-to = $existingCopyToValue][. &lt;&lt; $thisTopicref]))">
            <xsl:if test="$doDebug">
              <xsl:message> + [DEBUG]     Existing topicref value "<xsl:value-of select="@copy-to"/>" is fine. Not adjusting.</xsl:message>
            </xsl:if>

            <xsl:sequence select="''"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- Adjusting the copy-to value. We want generated numbers to start at 01. -->
            <xsl:variable name="ordinal" as="xs:integer" select="count($precedingTopicrefs)"/>
            <xsl:variable name="countPicture" as="xs:string"
              select="if ($ordinal gt 999) then '0000'
                      else if ($ordinal gt 99) then '000'
                      else if ($ordinal gt 9) then '00'
                      else '00'
              "
            />
            <xsl:variable name="count"            
              as="xs:string"
              select="format-number($ordinal, $countPicture)"
            />
            <xsl:variable name="namePart" as="xs:string" 
              select="if ($existingCopyToValue != '') 
                         then relpath:getNamePart($existingCopyToValue)
                         else relpath:getNamePart($hrefValue)" 
              
            />
            <xsl:variable name="ext" select="relpath:getExtension($hrefValue)" as="xs:string"/>
            <xsl:variable name="dir" as="xs:string"
              select="if ($existingCopyToValue != '') 
                         then relpath:getParent($existingCopyToValue)
                         else relpath:getParent($hrefValue)"
            />
            <xsl:variable name="copytoValue" select="relpath:newFile($dir, concat($namePart, '-', $count, '.', $ext))"/>
            <xsl:if test="$doDebug">
              <xsl:message> + [DEBUG]     Setting copy-to to "<xsl:value-of select="$copytoValue"/>".</xsl:message>
            </xsl:if>
            <xsl:value-of select="$copytoValue"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    
    
  </xsl:template>
  
  <!-- ==================================
       Mode makeJobFiles
       ================================== -->
  
  <xsl:template mode="makeJobFiles" match="topicToCopyToMap">
    <xsl:param name="doDebug" as="xs:boolean" select="false()" tunnel="yes"/>
    
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] makeJobFiles: Handling <xsl:value-of select="concat(name(..), '/', name(.))"/> element...</xsl:message>
    </xsl:if>
    
    <xsl:variable name="changesUrl" as="xs:string"
      select="relpath:newFile($job.xml.dir.url, $copyToChangesJob.filename)"
    />
    
    <xsl:message> + [INFO] makeJobFiles: Generating copyToChangesJob file: <xsl:value-of select="$changesUrl"/> </xsl:message>
    
    <xsl:variable name="propertiesToKeep" as="xs:string*"
      select="('user.input.file', 
               'user.input.dir',
               'uplevels',
               'tempdirToinputmapdir.relative.value')"
    />
    
    <!-- Keys for files that have had their copy-to value adjusted: 
    
         In the .job.xml file, files are indexed by relative path
         from the temp dir they were copied into.
    -->
    <xsl:variable name="fileKeys" as="xs:string*"
      select="for $key in .//mapItem[value/copyTo]/key 
      return relpath:getRelativePath($job.xml.dir.url, string($key))"
    />
    
    <!-- Now generate the copy-to changes version of the job XML file: -->
    <xsl:result-document href="{$changesUrl}"
      method="xml" indent="no"
      >      
      <job>
        <!-- Preserve required properties: -->
        <xsl:apply-templates 
          mode="updateJobXml" 
          select="$jobXmlDoc/*/property[@name = $propertiesToKeep]"
        />
        <!-- Construct copytotarget2sourcemaplist: -->
        <property
          name="copytotarget2sourcemaplist">
          <map>
            <xsl:apply-templates mode="updateJobXml" select=".//mapItem[value/copyTo]"/>
          </map>
        </property>
        <files>
          <!-- Files with keyrefs have to be reprocessed as the key binding may
               have changed. (See https://github.com/dita-ot/dita-ot/issues/1760)
            -->
          <xsl:apply-templates mode="makeJobFileEntries" 
            select="$jobXmlDoc/*/files/file[string(@path) = $fileKeys or @has-keyref = 'true']">
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            <xsl:with-param name="topicToCopyToMap" as="element()" tunnel="yes"
                        select="."
            />      
          </xsl:apply-templates>
        </files>
      </job>
    </xsl:result-document>
    
    <xsl:variable name="updatedJobUrl" as="xs:string"
      select="relpath:newFile($job.xml.dir.url, $updatedJob.filename)"
    />
    
    <xsl:message> + [INFO] makeJobFiles: Generating updatedJob file: <xsl:value-of select="$updatedJobUrl"/> </xsl:message>

    <xsl:result-document href="{$updatedJobUrl}"
      method="xml" indent="no"
      >
      <!-- Update the job.xml file with the new and updated copy-to entries. -->
      <xsl:apply-templates select="$jobXmlDoc/*" mode="updateJobXml">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        <xsl:with-param name="topicToCopyToMap" as="element()" tunnel="yes"
                    select="."
        />      
        <xsl:with-param name="fileKeys" as="xs:string*" tunnel="yes" select="$fileKeys"/>
      </xsl:apply-templates>
    </xsl:result-document>
    
  </xsl:template>
  
  <xsl:template mode="makeJobFileEntries" match="file">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="topicToCopyToMap" as="element()" tunnel="yes"/>
    
    <xsl:variable name="key" select="@path" as="xs:string"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] makeJobFileEntries: file: $key="<xsl:value-of select="$key"/></xsl:message>
    </xsl:if>
      
    <!-- Incoming <file> is for the copy-to source. Need to generate
         <file> elements for each copy-to target as well.
      -->
    <xsl:copy>
      <xsl:sequence select="@* except @copy-to-source"/>
      <xsl:attribute name="copy-to-source" 
        select="'true'"
      />
    </xsl:copy>
    <xsl:variable name="origAtts" as="attribute()*"
      select="@* except (@path)"
    />
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] makeJobFileEntries:   mapItem=<xsl:sequence select="$topicToCopyToMap//mapItem[ends-with(normalize-space(key), $key)]"/></xsl:message>
    </xsl:if>
    
    
    <xsl:for-each select="$topicToCopyToMap//mapItem[ends-with(normalize-space(key), $key)]/value/copyTo">
      <file>
        <xsl:sequence select="$origAtts"/>
        <xsl:attribute name="path" select="string(@copy-to)"/>
      </file>
    </xsl:for-each>
  </xsl:template>

  <!-- ==================================
       Mode updateKeydefXml
       ================================== -->
  
  <xsl:template mode="updateKeydefXml" match="*" priority="-1">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@*, node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- ==================================
       Mode updateJobXml
       ================================== -->
  
  <xsl:template match="property[@name= 'copytotarget2sourcemaplist']/map" mode="updateJobXml">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="topicToCopyToMap" as="element()" tunnel="yes"/>

    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] updateJobXml: property[@name= 'copytotarget2sourcemaplist']/map...</xsl:message>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates select="@*, node(), $topicToCopyToMap" mode="#current">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </xsl:copy>    
  </xsl:template>
  
  <xsl:template mode="updateJobXml" match="topicToCopyToMap">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] updateJobXml: topicToCopyToMap</xsl:message>
    </xsl:if>

    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template mode="updateJobXml" match="mapItem">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] updateJobXml: <xsl:sequence select="."/></xsl:message>
    </xsl:if>
     <!--
       job.xml:
       
       <entry
        key="epub-test/chapters/subtopic-02-2nd-ref.xml">
        <string>chapters/subtopic-02.xml</string>
      </entry>

      Our copyTo map: 
      
        <mapItem>
          <key><xsl:sequence select="current-grouping-key()"></xsl:sequence></key>
          <value>
            <copyTo 
              topicrefId="{generate-id(.)}" 
              copy-to="{normalize-space($copytoValue)}"
              isNew="{not(@copy-to)}"        
            />
          </value>
       </mapItem>

     -->
    <!-- The value in the job file is the path to the copy-to source relative to the
         temp directory.
      -->
    <xsl:variable name="tempDir" as="xs:string"
      select="$job.xml.dir.url"
    />
    <xsl:variable name="key" as="xs:string" 
      select="relpath:getRelativePath($tempDir, string(key))"
    />
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] updateJobXml: mapItem - $tempDir="<xsl:value-of select="$tempDir"/>"</xsl:message>
      <xsl:message> + [DEBUG] updateJobXml: mapItem - key="<xsl:sequence select="string(key)"/>"</xsl:message>
      <xsl:message> + [DEBUG] updateJobXml: mapItem - $key="<xsl:value-of select="$key"/>"</xsl:message>
    </xsl:if>
    <xsl:for-each select="value/copyTo">
      <entry key="{@copy-to}"><string><xsl:value-of select="$key"/></string></entry>
    </xsl:for-each>
    
  </xsl:template>
  
  <xsl:template mode="updateJobXml" match="file">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="fileKeys" as="xs:string*" tunnel="yes"/>
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] updateJobXml: file - fileKeys=<xsl:sequence select="$fileKeys"/></xsl:message>
      <xsl:message> + [DEBUG] updateJobXml: file - @path="<xsl:value-of select="@file"/>"</xsl:message>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="string(@path) = $fileKeys">
        <xsl:apply-templates mode="makeJobFileEntries" select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  

  <!-- ==================================
       Default templates
       ================================== -->
  
  <xsl:template match="*[df:class(., 'map/topicref')]">
    <xsl:param name="topicToCopyToMap" as="element()" tunnel="yes"/>
    <xsl:variable name="copyToAtt" as="attribute()?">
      <xsl:variable name="topicrefID" as="xs:string" select="generate-id(.)" />
      <xsl:variable name="copyToItem" as="element()?"
        select="$topicToCopyToMap//copyTo[@topicrefId = $topicrefID]"
      />
      <xsl:sequence select="$copyToItem/@copy-to"/>
    </xsl:variable>
    <xsl:copy>
      <xsl:apply-templates select="@*, $copyToAtt, node()"/>
    </xsl:copy>
    
  </xsl:template>
  
  <xsl:template mode="#default updateJobXml" priority="-1"
    match="text() | processing-instruction() | comment() | @*">
    <xsl:sequence select="."/>
  </xsl:template>
  
  <xsl:template mode="#default updateJobXml" priority="-1"
    match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*,node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- ==================================
       Local Functions
       ================================== -->
  
  <xsl:function name="local:makeHrefAbsolute" as="xs:string?">
    <!-- Given a topicref, make it's @href, if any, absolute.
      -->
    <xsl:param name="topicref" as="element()"/>
    <!-- For now ignoring the case where there is an absolute
         URL to a local-scope topic.
      -->
    <xsl:variable name="fullUrl" as="xs:string"
      select="relpath:newFile(relpath:getParent(base-uri($topicref)), 
                 relpath:getResourcePartOfUri(string($topicref/@href)))"
    />
    <xsl:variable name="result"
      select="relpath:getAbsolutePath($fullUrl)"
    />
    <xsl:sequence select="$result"/>
  </xsl:function>
  
  <xsl:function name="local:isLocalScope" as="xs:boolean">
    <xsl:param name="context" as="element()"/>
    <xsl:variable name="result" as="xs:boolean"
      select="not($context/@scope) or 
                  $context/@scope = '' or 
                  $context/@scope = ('local')"
    />
    <xsl:sequence select="$result"/>
  </xsl:function>
  
  <xsl:function name="local:isDitaFormat" as="xs:boolean">
    <xsl:param name="context" as="element()"/>
    <xsl:variable name="result" as="xs:boolean"
      select="(not($context/@format) or
               $context/@format = 'dita' or 
               $context/@format = '' 
               )"
    />
    <xsl:sequence select="$result"/>
  </xsl:function>
  
  <xsl:function name="local:isCopytoCandidate" as="xs:boolean">
    <xsl:param name="context" as="element()"/>
    <xsl:variable name="result" as="xs:boolean"
      select="df:isTopicRef($context) and 
              not($context/ancestor::*[df:class(., 'map/reltable')]) and
              not($context/@processing-role = 'resource-only') and
              not($context/ancestor::*[contains(@chunk, 'to-content')]) and
              local:isLocalScope($context) and
              local:isDitaFormat($context) and
              ($context/@href != '' or $context/@keyref != '') "
    />
    <xsl:sequence select="$result"/>
  </xsl:function>
</xsl:stylesheet>