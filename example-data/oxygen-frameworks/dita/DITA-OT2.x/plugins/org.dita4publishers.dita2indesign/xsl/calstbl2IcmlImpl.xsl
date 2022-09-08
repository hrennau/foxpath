<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
      xmlns:xs="http://www.w3.org/2001/XMLSchema"
      xmlns:df="http://dita2indesign.org/dita/functions"
      xmlns:ctbl="http//dita2indesign.org/functions/cals-table-to-inx-mapping"
      xmlns:incxgen="http//dita2indesign.org/functions/incx-generation"
      xmlns:e2s="http//dita2indesign.org/functions/element-to-style-mapping"
      xmlns:relpath="http://dita2indesign/functions/relpath"
      exclude-result-prefixes="xs df ctbl incxgen e2s relpath"
      version="2.0">
  
  <!-- CALS table to IDML table 
    
    Generates InDesign IDML tables from DITA CALS tables.
    Implements the "tables" mode.
    
    Copyright (c) 2011, 2014 DITA for Publishers
    
  -->
 
 
<!-- 
  Required modules: 
  <xsl:import href="lib/icml_generation_util.xsl"/>
  <xsl:import href="elem2styleMapper.xsl"/>
  -->
  <xsl:template match="*[df:class(.,'topic/table')]" priority="20">
    <xsl:text>&#x0a;</xsl:text>
    <xsl:if test="*[df:class(., 'topic/title')]">
      <xsl:call-template name="makeTableCaption">
        <xsl:with-param name="caption" select="*[df:class(., 'topic/title')]" as="node()*"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="*[df:class(., 'topic/tgroup')]"/>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/tgroup')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:variable name="matrixTable" as="element()?">
      <xsl:apply-templates mode="make-matrix-table" select=".">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
        <xsl:with-param name="colspecElems" as="element()*" select="*[df:class(., 'topic/colspec')]" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:if test="$doDebug">
      <xsl:variable name="matrixTableURI" as="xs:string"
        select="relpath:newFile($outputPath, concat('matrixTable-', generate-id(.), '.xml'))"
      />
      <xsl:message> + [DEBUG] ============ Matrix table:</xsl:message>
      <xsl:message>
        <xsl:sequence select="$matrixTable"/>
      </xsl:message>
      <xsl:message> + [DEBUG] ============ end of matrix table ==========</xsl:message>
    </xsl:if>
    <xsl:variable name="numBodyRows"  as="xs:integer"
      select="count($matrixTable/tbody/row)"
    />
    <xsl:variable name="numHeaderRows"  as="xs:integer"
      select="count($matrixTable/thead/row)"
    />
    <xsl:variable name="numCols" select="count($matrixTable/*[1]/*[1]/cell)" as="xs:integer"/>
    <xsl:variable name="tableID" select="generate-id(.)"/>
    <xsl:variable name="tStyle" select="e2s:getTStyleForElement(.)" as="xs:string"/>
    <xsl:if test="$numCols != count(*[df:class(., 'topic/colspec')])">
      <xsl:message> + [WARN] Table <xsl:value-of select="../*[df:class(., 'topic/title')]"/>:</xsl:message>
      <xsl:message> + [WARN]   Maximum column count (<xsl:value-of select="$numCols"/>) not equal to number of colspec elements (<xsl:value-of select="count(*[df:class(., 'colspec')])"/>).</xsl:message>
    </xsl:if>
     <Table 
      AppliedTableStyle="TableStyle/$ID/{$tStyle}" 
      TableDirection="LeftToRightDirection"
      HeaderRowCount="{$numHeaderRows}" 
      FooterRowCount="0" 
      BodyRowCount="{$numBodyRows}" 
      ColumnCount="{$numCols}" 
      Self="rc_{generate-id()}"><xsl:text>&#x0a;</xsl:text>
      <xsl:apply-templates select="." mode="crow">
        <xsl:with-param name="matrixTable" as="element()" tunnel="yes" select="$matrixTable"/>
      </xsl:apply-templates>
       
      <!-- replace this apply templates with function to generate ccol elements.
        This apply-templates generates a ccol for every cell; just need one ccol for each column
        <xsl:apply-templates select="row" mode="ccol"/> -->
      <xsl:sequence 
        select="incxgen:makeColumnElems(
                 *[df:class(., 'topic/colspec')], 
                 $numCols,
                 $tableID)"
      />
      <xsl:apply-templates>
        <xsl:with-param name="colCount" select="$numCols" as="xs:integer" tunnel="yes"/>
        <xsl:with-param name="rowCount" select="$numHeaderRows + $numBodyRows" as="xs:integer" tunnel="yes"/>
        <xsl:with-param name="colspecElems" as="element()*" select="*[df:class(., 'topic/colspec')]" tunnel="yes"/>
      <xsl:with-param name="matrixTable" as="element()" tunnel="yes" select="$matrixTable"/>
      </xsl:apply-templates>
    </Table><xsl:text>&#x0a;</xsl:text>    
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/tgroup')]" mode="crow">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/colspec')]" mode="crow #default">
    <!-- Ignored in this mode -->
  </xsl:template>
  
  <xsl:template 
    match="
    *[df:class(., 'topic/tbody')] |
    *[df:class(., 'topic/thead')]
    " 
    mode="crow #default">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/row')]" mode="crow">
    <xsl:param name="matrixTable" as="element()" tunnel="yes"/>
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- In InDesign tables, the header and body rows are indexed together
      
      Note that the index is zero indexed.
      -->
    <xsl:variable name="rowid" as="xs:string" select="generate-id(.)"/>
    
    <xsl:variable name="rowIndex"  as="xs:integer"
      select="count(ancestor::*[df:class(., 'topic/tgroup')]//*[df:class(., 'topic/row')][. &lt;&lt; current()] )"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] crow: topic/row - rowIndex="<xsl:value-of select="$rowIndex"/>"</xsl:message>
    </xsl:if>
    <Row 
      Name="{$rowIndex}" 
      SingleRowHeight="1" 
      Self="{generate-id(..)}crow{$rowIndex}"/><xsl:text>&#x0a;</xsl:text>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/row')]">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/entry')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="articleType" as="xs:string" tunnel="yes"/>
    <xsl:param name="cellStyle" as="xs:string" tunnel="yes" select="'[None]'"/>
    <xsl:param name="colCount" as="xs:integer" tunnel="yes"/>
    <xsl:param name="rowCount" as="xs:integer" tunnel="yes"/>
    <xsl:param name="colspecElems" as="element()*" tunnel="yes" />

    <xsl:param name="matrixTable" as="element()" tunnel="yes" />
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] topic/entry: "<xsl:value-of select="substring(., 80)"/>"</xsl:message>
      <xsl:message> + [DEBUG] topic/entry:     namest: <xsl:value-of select="@namest"/></xsl:message>
      <xsl:message> + [DEBUG] topic/entry:     nameend: <xsl:value-of select="@nameend"/></xsl:message>
    </xsl:if>

    <xsl:variable name="entryId" as="xs:string" select="generate-id(.)"/>
    <xsl:variable name="parentRow" as="element()" select=".."/>
    <xsl:variable name="rowNumber" 
      as="xs:integer"
      select="count(ancestor::*[df:class(., 'topic/tgroup')]//*[df:class(., 'topic/row')][. &lt;&lt; $parentRow] )"
    />
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] topic/entry: entryId="<xsl:value-of select="$entryId"/>"</xsl:message>
    </xsl:if>
    
    <xsl:variable name="colNumber" as="xs:integer"
      select="if (($matrixTable//cell[@entryId = $entryId])[1]/@colnum)
      then (($matrixTable//cell[@entryId = $entryId])[1]/@colnum)
      else -1"
    />
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] topic/entry:   colNumber="<xsl:value-of select="$colNumber"/>"</xsl:message>
    </xsl:if>
    
    <xsl:choose>
      <xsl:when test="$colNumber = -1">
        <!-- Must be a cell that has been spanned away, such as a two-row span where the second row
             has a single cell. This should not happen in normal tables as there's no point in 
             doing this but it is allowed.
          -->
      </xsl:when>
      <xsl:otherwise>
        
        <xsl:variable name="colspan">
          <xsl:choose>
            <xsl:when test="incxgen:isColSpan(.,$colspecElems)">
              <xsl:value-of select="incxgen:numberColsSpanned(.,$colspecElems)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="1"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:if test="$doDebug">
          <xsl:message> + [DEBUG] topic/entry: colspan="<xsl:value-of select="$colspan"/>"</xsl:message>
        </xsl:if>
        <xsl:variable name="rowspan">
          <xsl:choose>
            <xsl:when test="@morerows">
              <xsl:value-of select="number(@morerows)+1"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="1"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colSpan" select="incxgen:makeCSpnAttr($colspan,$colCount)"/>
        <xsl:variable name="rowSpan" select="incxgen:makeRSpnAttr($rowspan,$rowCount)"/>
        <xsl:variable name="justification" as="xs:string"
          select="if (@align = 'center') then 'CenterAlign'
                     else if (@align = 'right') then 'RightAlign'
                          else ''"
        />
        <!-- <xsl:message select="concat('[DEBUG: r: ',$colSpan,' c: ',$rowSpan)"/> -->
        <xsl:text> </xsl:text><Cell 
          Name="{$colNumber}:{$rowNumber}" 
          RowSpan="{$rowSpan}" 
          ColumnSpan="{$colSpan}" 
          AppliedCellStyle="CellStyle/$ID/${cellStyle}" 
          ppcs="l_0" 
          Self="rc_{generate-id()}">
          <xsl:if test="@valign">
            <xsl:choose>
              <xsl:when test="@valign = 'bottom'">
                <xsl:attribute name="VerticalJustification" select="'BottomAlign'"/>
              </xsl:when>
              <xsl:when test="@valign='middle'">
                <xsl:attribute name="VerticalJustification" select="'CenterAlign'"/>
              </xsl:when>
              <xsl:otherwise>
                <!-- Top is the default -->
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
          <xsl:text>&#x0a;</xsl:text>
          <!-- must wrap cell contents in txsr and pcnt -->
          <xsl:variable name="pStyle" as="xs:string">
            <xsl:choose>
              <xsl:when test="ancestor::*[df:class(., 'topic/thead')]">
                <xsl:value-of select="'Columnhead'"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'Body Table Cell'"></xsl:value-of>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="cStyle" select="'$ID/[No character style]'" as="xs:string"/>
          <xsl:variable name="pStyleObjId" select="incxgen:getObjectIdForParaStyle($pStyle)" as="xs:string"/>
          <xsl:variable name="cStyleObjId" select="incxgen:getObjectIdForCharacterStyle($cStyle)" as="xs:string"/>
          <xsl:choose>
            <xsl:when test="df:hasBlockChildren(.)">
              <!-- FIXME: handle non-empty text before first block element -->
              <xsl:apply-templates>
                <xsl:with-param name="justification" tunnel="yes" select="$justification" as="xs:string"/>
              </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="makeBlock-cont">
                <xsl:with-param name="pStyle" tunnel="yes" select="e2s:getPStyleForElement(., $articleType)"/>
                <xsl:with-param name="justification" tunnel="yes" select="$justification" as="xs:string"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text> </xsl:text></Cell><xsl:text>&#x0a;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="makeTableCaption">
    <xsl:param name="caption" as="node()*"/>
    <xsl:variable name="pStyle" select="'tableCaption'" as="xs:string"/>
    <xsl:variable name="cStyle" select="'$ID/[No character style]'" as="xs:string"/>
    <xsl:variable name="pStyleEscaped" as="xs:string" select="incxgen:escapeStyleName($pStyle)"/>
    <xsl:variable name="cStyleEscaped" as="xs:string" select="incxgen:escapeStyleName($cStyle)"/>
    
    <ParagraphStyleRange
      AppliedParagraphStyle="ParagraphStyle/{$pStyleEscaped}"><xsl:text>&#x0a;</xsl:text>
      <CharacterStyleRange AppliedCharacterStyle="CharacterStyle/$ID/{$cStyleEscaped}" ParagraphBreakType="NextFrame"
        ><xsl:value-of select="$caption"/></CharacterStyleRange><xsl:text>&#x0a;</xsl:text>
    </ParagraphStyleRange><xsl:text>&#x0a;</xsl:text>  
  </xsl:template>
  
  <xsl:template match="text()" mode="calcRowEntryCounts"/>
  
  <xsl:template mode="crow" match="*" priority="-1">
    <xsl:message> + [WARNING] (crow mode): Unhandled element <xsl:sequence select="name(..)"/>/<xsl:sequence 
      select="concat(name(.), ' [', normalize-space(@class), ']')"/></xsl:message>
  </xsl:template>
  
  <!-- =======================
       Mode make matrix table
       
       Construct a table where every 
       cell of the table is explicit
       so that it's easy to account
       for vertical and horizontal
       spans when calculating the
       effective column number of 
       cells.       
       ======================= -->
  
  <xsl:template 
    match="
    *[df:class(., 'topic/tgroup')]
    " 
    mode="make-matrix-table">
   <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
   
   <xsl:if test="$doDebug">
     <xsl:message> + [DEBUG] make-matrix-table: <xsl:value-of select="name(.)"/>...</xsl:message>
   </xsl:if>
   <!-- Construct a table of rows and columns
        reflecting each logical row and column
        of the table so that we know, for any
        cell, what its absolute row/column
        position within the matrix is.     
     
       Do this in two phases:
     
        1. Generate a set of cells, each labeled with the 
           original row it was generated from and labeled
           with its absolute row and column number.
           
        2. Group the cells by row to create the set of 
           absolute rows and cells, over which spans
           are overlayed.
           
     -->
   <xsl:if test="$doDebug">
     <xsl:message> + [DEBUG] make-matrix-table: Constructing cell set...</xsl:message>
   </xsl:if>
   
   <xsl:variable name="numCols" as="xs:integer"
     select="max(for $row in */*[df:class(., 'topic/row')] 
                     return count($row/*[df:class(., 'topic/entry')]))"
   />

    <xsl:variable name="numRows" as="xs:integer"
     select="count(*/*[df:class(., 'topic/row')])"
   />

   <!-- Generate a matrix that we can then walk in order
        to drive handling of each row and generation
        of result cells in the result matrix.
        
     -->
   <xsl:variable name="baseMatrix" as="element()">
     <baseMatrixTable>
       <!-- InDesign cell and row numbers are zero indexed -->
       <xsl:for-each select="0 to $numRows - 1">
         <xsl:variable name="rownum" select="."/>
         <matrixRow rownum="{$rownum}">
           <xsl:for-each select="0 to $numCols -1 ">
             <cell rownum="{$rownum}" 
                   colnum="{.}"/>
           </xsl:for-each>
         </matrixRow>
       </xsl:for-each>
     </baseMatrixTable>
   </xsl:variable>
   
   <xsl:if test="$doDebug">
     <xsl:variable name="uri" as="xs:string"
       select="relpath:newFile($outputPath, concat('baseMatrix-', generate-id(.), '.xml'))"
     />
      <xsl:message> + [DEBUG] ========= base matrix to <xsl:value-of select="$uri"/></xsl:message>
      <xsl:message>
        <xsl:sequence select="$baseMatrix"/>
      </xsl:message>
     <xsl:message> + [DEBUG] ================= End of base matrix table =========== </xsl:message>
   </xsl:if>
   
   <xsl:if test="$doDebug">
    <xsl:message> + [DEBUG] make-matrix-table: topic/tgroup - constructing cell set...</xsl:message>
   </xsl:if>
   <xsl:variable name="cellSet" as="element()*" 
     >
     <!-- Process each row in a recursive process that passes the accumulated
          cell matrix cells to the next invocation, processing the next
          row in the base matrix.
          
          The corresponding source row is passed as parameter.
       -->
     <xsl:variable name="sourceRow" as="element()?"
       select="(.//*[df:class(., 'topic/row')])[1]"
     />
     <xsl:apply-templates select="$baseMatrix/matrixRow[1]" mode="make-cell-set">
       <xsl:with-param name="sourceRow" as="element()"
         select="$sourceRow"
       />
       <xsl:with-param name="accumulatedCells" as="element()*" select="()"/>
     </xsl:apply-templates>
   </xsl:variable>
   

    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] topic/tgroup: complete cellSet= <xsl:sequence select="$cellSet"/></xsl:message>
      <xsl:variable name="cellSetURI" as="xs:string"
        select="relpath:newFile($outputPath, concat('cellSet-', generate-id(.), '.xml'))"
      />
      <xsl:message> + [DEBUG] ==== cell set to <xsl:value-of select="$cellSetURI"/></xsl:message>
      <xsl:message>
        <cellSet>
          <xsl:sequence select="$cellSet"/>
        </cellSet>
      </xsl:message>
      <xsl:message> + [DEBUG] ==== End of cell set =======</xsl:message>
    </xsl:if>

   <xsl:if test="$doDebug">
     <xsl:message> + [DEBUG] make-matrix-table: Constructing matrix table...</xsl:message>
   </xsl:if>
   <xsl:variable name="matrixTable" as="element()">
     <matrixTable>
       <xsl:for-each-group select="$cellSet" group-by="@tableZone">
         <xsl:element name="{current()/@tableZone}">
           <xsl:for-each-group select="current-group()" group-by="@rownum">
             <row rowid="{current()/@rowid}" tableZone="{current()/@tableZone}">
               <xsl:for-each select="current-group()">
                 <xsl:sort select="@colnum"/>
                 <xsl:sequence select="."/>
               </xsl:for-each>
             </row>               
           </xsl:for-each-group>
         </xsl:element>
       </xsl:for-each-group>
     </matrixTable>
   </xsl:variable>
   <xsl:sequence select="$matrixTable"/>
  </xsl:template>
  <xsl:template mode="make-cell-set" match="matrixRow">
    <!-- This is recursive template, in that each row applies this template
         to its next sibling.
      -->
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="sourceRow" as="element()"/>
    <xsl:param name="accumulatedCells" as="element()*"/>
    
    <xsl:if test="$doDebug">
      <xsl:variable name="temp" select="count($accumulatedCells)"/>
      <xsl:message> + [DEBUG] make-cell-set: topic/row - rownum="<xsl:value-of select="@rownum"/></xsl:message>
      <xsl:message> + [DEBUG] make-cell-set: accumulatedCells="<xsl:sequence select="$accumulatedCells"/></xsl:message>
    </xsl:if>
    
    <xsl:variable name="newCells" as="element()*">
      <!-- Process each base matrix cell recursively, accounting for any
           row-spanning cells in order to determine the column number
           of each source <entry> element. We consume the source cells
           through this recursive process.
        -->
      <xsl:apply-templates select="cell[1]" mode="#current">
        <xsl:with-param name="accumulatedCells" as="element()*" 
          select="$accumulatedCells"
        />
        <xsl:with-param name="sourceEntryElems" as="element()*"
          select="$sourceRow/*[df:class(., 'topic/entry')]"
        />
      </xsl:apply-templates>
    </xsl:variable>
    
    <xsl:if test="$doDebug">
      <xsl:variable name="temp" select="count($newCells)"/>
      <xsl:message> + [DEBUG] matrixRow: newCells=<xsl:sequence select="$newCells"/></xsl:message>
    </xsl:if>
    
    <xsl:variable name="nextRow" as="element()?"
      select="
      if ($sourceRow/../self::*[df:class(., 'topic/thead')]) 
         then ($sourceRow/following-sibling::*[df:class(., 'topic/row')][1], 
               $sourceRow/../../*[df:class(., 'topic/tbody')]/*[df:class(., 'topic/row')][1])[1]
         else $sourceRow/following-sibling::*[df:class(., 'topic/row')][1]"
    />
     
    <xsl:choose>
      <xsl:when test="(following-sibling::matrixRow)[1]">
        <xsl:apply-templates mode="#current" select="(following-sibling::matrixRow)[1]">
          <xsl:with-param name="sourceRow"
          select="$nextRow"
          />
          <xsl:with-param name="doDebug" tunnel="yes" as="xs:boolean" select="$doDebug"/>
          <xsl:with-param name="accumulatedCells" as="element()*" 
            select="$accumulatedCells | $newCells"
          />
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$doDebug">
          <xsl:message> + [DEBUG] make-cell-set: matrixRow: No more rows, returning: <xsl:sequence select="$accumulatedCells | $newCells"/></xsl:message>
        </xsl:if>
        <xsl:sequence select="$accumulatedCells | $newCells"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="make-cell-set" match="cell">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="colspecElems" as="element()*" tunnel="yes" />
    <xsl:param name="accumulatedCells" as="element()*"/><!-- All cells created up to this point. -->
    <xsl:param name="sourceEntryElems" as="element()*"/>
    
<!--    <xsl:variable name="doDebug" as="xs:boolean" select="false()"/>-->
    
    <xsl:variable name="tableZone" as="xs:string" 
      select="name($sourceEntryElems[1]/../..)"
    />
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] make-cell-set: cell <xsl:value-of select="concat(@rownum, ':', @colnum)"/></xsl:message>
      <xsl:message> + [DEBUG]   accumulatedCells=<xsl:sequence select="$accumulatedCells"/></xsl:message>
    </xsl:if>    
    
    
    
    <xsl:variable name="curRowNum" as="xs:integer" select="@rownum"/>
    <xsl:variable name="curColNum" as="xs:integer" select="@colnum"/>
    <xsl:variable name="isEntryHandled" as="xs:boolean"
      select="not($accumulatedCells[@rownum = $curRowNum and @colnum = $curColNum])"
    />
    <xsl:variable name="newCells" as="element()*">
      <xsl:choose>
        <xsl:when test="not($isEntryHandled)">
          <xsl:if test="$doDebug">
            <xsl:message> + [DEBUG] make-cell-set:   already have an accumulated cell for this position.</xsl:message>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="$doDebug">
            <xsl:message> + [DEBUG] make-cell-set:   No accumulated cell in this position, creating new cells...</xsl:message>
          </xsl:if>
          <xsl:variable name="curEntry" as="element()?"
            select="$sourceEntryElems[1]"
          />
          <xsl:if test="$curEntry">
            <xsl:variable name="numColsSpanned" as="xs:integer"
              select="incxgen:numberColsSpanned($curEntry, $colspecElems)" 
            />
            <xsl:if test="$doDebug">
              <xsl:message> + [DEBUG] make-cell-set:   numColsSpanned=<xsl:value-of select="$numColsSpanned"/></xsl:message>
            </xsl:if>
            <!-- Number of *additional rows spanned -->
            <xsl:variable name="rowsSpanned" as="xs:integer"
              select="if ($curEntry/@morerows) 
                         then xs:integer($curEntry/@morerows) 
                         else 0"
            />
            <xsl:for-each select="$curRowNum to ($curRowNum + $rowsSpanned)">
              <xsl:variable name="rownum" as="xs:integer" select="."/>
              <xsl:for-each select="0 to ($numColsSpanned - 1)">
                <xsl:if test="$doDebug">
                  <xsl:message> + [DEBUG] make-cell-set:  making a cell, current()=<xsl:value-of select="."/></xsl:message>
                </xsl:if>
                <cell rownum="{$rownum}"
                      colnum="{$curColNum + .}"
                      entryId="{generate-id($curEntry)}"
                      tableZone="{$tableZone}"
                ><xsl:value-of select="substring($curEntry, 1, 20)"/></cell>
              </xsl:for-each>
            </xsl:for-each>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Sanity check: Make sure we run out of matrix cells before
         we run out of source entry elements:
         
      -->
    <xsl:choose>
      <xsl:when test="(following-sibling::cell)[1]">
        <xsl:apply-templates mode="#current" select="(following-sibling::cell)[1]">
          <xsl:with-param name="accumulatedCells" as="element()*" 
            select="$accumulatedCells | $newCells"
          />
          <xsl:with-param name="sourceEntryElems" as="element()*"
            select="if ($isEntryHandled) 
                       then $sourceEntryElems[position() > 1]
                       else $sourceEntryElems
            "
          />
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="count($sourceEntryElems) gt 1">
          <xsl:message> + [WARN] make-cell-set: Row <xsl:value-of select="$curRowNum"/>: After processing all base matrix cells in a row, have <xsl:value-of select="count($sourceEntryElems) - 1"/> source entry elements left over.</xsl:message>
        </xsl:if>
        <xsl:sequence select="$accumulatedCells | $newCells"/>    
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  <xsl:template mode="make-cell-set make-matrix-table" match="*" priority="-1">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!-- ======= End of make-matrix-table ============ -->
  <!-- This template returns values that must be added to the table matrix. Every cell in the box determined
     by start-row, end-row, start-col, and end-col will be added. First add every value from the first
     column. When past $end-row, move to the next column. When past $end-col, every value is added. -->
  <xsl:template name="add-to-matrix">
    <xsl:param name="start-row" as="xs:integer"/>       
    <xsl:param name="end-row" as="xs:integer"/>
    <xsl:param name="current-row" select="$start-row" as="xs:integer"/>
    <xsl:param name="start-col" as="xs:integer"/>
    <xsl:param name="end-col" as="xs:integer"/>
    <xsl:param name="current-col" select="$start-col" as="xs:integer"/>
    <xsl:choose>
      <xsl:when test="$current-col > $end-col"/>   <!-- Out of the box; every value has been added -->
      <xsl:when test="$current-row > $end-row">    <!-- Finished with this column; move to next -->
        <xsl:call-template name="add-to-matrix">
          <xsl:with-param name="start-row"  select="$start-row" as="xs:integer"/>
          <xsl:with-param name="end-row" select="$end-row" as="xs:integer"/>
          <xsl:with-param name="current-row" select="$start-row" as="xs:integer"/>
          <xsl:with-param name="start-col" select="$start-col" as="xs:integer"/>
          <xsl:with-param name="end-col" select="$end-col" as="xs:integer"/>
          <xsl:with-param name="current-col" select="$current-col + 1" as="xs:integer"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <!-- Output the value for the current entry -->
        <xsl:sequence select="concat('[', $current-row, ':', $current-col, ']')"/>
        <!-- Move to the next row, in the same column. -->
        <xsl:call-template name="add-to-matrix">
          <xsl:with-param name="start-row" select="$start-row" as="xs:integer"/>
          <xsl:with-param name="end-row" select="$end-row" as="xs:integer"/>
          <xsl:with-param name="current-row" select="$current-row + 1" as="xs:integer"/>
          <xsl:with-param name="start-col" select="$start-col" as="xs:integer"/>
          <xsl:with-param name="end-col" select="$end-col" as="xs:integer"/>
          <xsl:with-param name="current-col" select="$current-col" as="xs:integer"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:function name="incxgen:isColSpan" as="xs:boolean">
    <xsl:param name="elem" as="element()"/>
    <xsl:param name="colspecElems" as="element()*"/>
    <xsl:variable name="namest" select="if ($elem/@namest) then $elem/@namest else ''" as="xs:string" />
    <xsl:variable name="nameend" select="if ($elem/@nameend) then $elem/@nameend else ''" as="xs:string" />
    <xsl:variable name="isColSpan" select="
      if ($namest ne '' and $nameend ne '') then
      (if ($namest ne $nameend) then 
      (if ($colspecElems[@colname=$namest] and $colspecElems[@colname=$nameend]) then true()
      else false())
      else false ())
      else false ()"
      as="xs:boolean" />
    <xsl:sequence select="$isColSpan"/>
  </xsl:function>
  
  <xsl:function name="incxgen:numberColsSpanned" as="xs:integer">
    <xsl:param name="elem" as="element()"/>
    <xsl:param name="colspecElems" as="element()*"/>
    <xsl:variable name="namest" select="if ($elem/@namest) then $elem/@namest else ''" as="xs:string" />
    <xsl:variable name="nameend" select="if ($elem/@nameend) then $elem/@nameend else ''" as="xs:string" />
    <xsl:variable name="numColsBeforeStartColSpan" select="count($colspecElems[@colname=$namest]/preceding::*[self::colspec or df:class(.,'topic/colspec')])" as="xs:integer" />
    <xsl:variable name="numColsBeforeEndColSpan" select="count($colspecElems[@colname=$nameend]/preceding::*[self::colspec or df:class(.,'topic/colspec')])" as="xs:integer" />
    <xsl:sequence select="$numColsBeforeEndColSpan - $numColsBeforeStartColSpan + 1"/>    
  </xsl:function>
  
  
  
  
</xsl:stylesheet>
