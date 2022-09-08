<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    xmlns:oxy="http://www.oxygenxml.com/extensions/author"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:ImageInfo="java:ImageInfo" exclude-result-prefixes="#all">
    <!-- 
    	https://github.com/oxygenxml/dita-css/issues/10
        Convert the CALS column and span attributes:
        
        @morerows
        @namest, @nameend 
        
        to:
        
        @rowspan
        @cospan 
        
        The CSS will match these attributes. Works with Prince and Antenna House.
    -->
	<xsl:template match="*[contains(@class, ' topic/entry ')]">
	    <xsl:copy>
	        <xsl:copy-of select="@*"/>
	        <xsl:if test="@morerows">
	              <xsl:attribute name="rowspan" select="number(@morerows) + 1"></xsl:attribute>  
	        </xsl:if>
	        <xsl:if test="@namest and @nameend">
	            <xsl:variable name="namest" select="@namest"/>
	            <xsl:variable name="nameend" select="@nameend"/>
	            <xsl:variable name="namestPos" select="number(parent::*/parent::*/parent::*/*[contains(@class, ' topic/colspec ')][@colname=$namest]/@colnum)"/>
	            <xsl:variable name="nameendPos" select="number(parent::*/parent::*/parent::*/*[contains(@class, ' topic/colspec ')][@colname=$nameend]/@colnum)"/>
	            <xsl:attribute name="colspan" select="$nameendPos - $namestPos + 1"/>  
	        </xsl:if>
	        <xsl:apply-templates/>
	    </xsl:copy>
	</xsl:template>
	
	
	<!-- Simple table. -->
	<xsl:template match="*[contains(@class, ' topic/simpletable ')]">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			
			<xsl:if test="@relcolwidth">
				<!--
					Compute the column widths for simple tables by extracting the propoprtions from relcolwidths and 
					set them as percents in a 'style' attribute, on an artificial 'colspec' element. 
				-->				
				<xsl:variable name="proportions" select="tokenize(normalize-space(replace(@relcolwidth, '\*',' ')),' ')"/>				
				<xsl:variable name="total-prop-width" select="sum(for $s in $proportions return number($s))"/>			
				<xsl:for-each select="$proportions">
					<colspec class=" topic/colspec ">
						<xsl:variable name="prop-width" select="number(.)"/>				
						<xsl:variable name="percent" select="round($prop-width div $total-prop-width*1000000) div 10000"/>
						<xsl:variable name="percent" select="if (round($percent) = $percent) then $percent else format-number($percent,'##0.0000')"/>						
						<xsl:attribute name="style">width:<xsl:value-of select="$percent"/>%;</xsl:attribute>
					</colspec>
				</xsl:for-each>
			</xsl:if>

			<xsl:choose>
				<xsl:when test="./*[contains(@class, ' topic/sthead ')]">
					<!--
						This is needed to create running headers for simpletables and other tables derived from it.
						Wrap the simpletable heading into an artificial element that will have its CSS display set to table-header-group
					-->			
					<oxy:table-header-group>
						<xsl:apply-templates select="*[contains(@class, ' topic/sthead ')]"/>
					</oxy:table-header-group>
					<oxy:table-row-group>
						<xsl:apply-templates select="*[not(contains(@class, ' topic/sthead '))]"/>
					</oxy:table-row-group>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>
	
	
		
	
	<!--
		Computes the column widths for normal tables and set them in a 'style' attribute on the existing
		'colspec' element.
		Proportional CALS units are converted to percents.
		The fixed values are copied unchanged.		
	-->
	<xsl:template match="*[contains(@class, ' topic/colspec ')]">
		<xsl:copy>
			<xsl:copy-of select="@*"/>

			<xsl:choose>
				<xsl:when test="contains(@colwidth, '*')">
					<!-- It is a proportional width. Solve it to % -->
					<xsl:variable name="total-prop-width" select="sum(
						..//*[contains(@colwidth, '*')]/number(
						if (string-length(normalize-space(substring-before(@colwidth, '*'))) = 0) 
						then 1 else normalize-space(substring-before(@colwidth, '*')) )
						)"/>
					
					
					<xsl:variable name="prop-width" 
						select="number(
						if (string-length(normalize-space(substring-before(@colwidth, '*'))) = 0) 
							then 1 
							else normalize-space(substring-before(@colwidth, '*')))"/>					
					<xsl:if test="string($total-prop-width) != 'NaN'">
						<xsl:variable name="percent" select="round($prop-width div $total-prop-width * 1000000) div 10000"/>
						<xsl:variable name="percent" select="if (round($percent) = $percent) then $percent else format-number($percent,'##0.0000')"/>
						<xsl:attribute name="style">width:<xsl:value-of select="$percent"/>%;</xsl:attribute>										
					</xsl:if>
				</xsl:when>
				<xsl:when test="@colwidth">
					<!-- It is a fixed value. Use it as it is -->
					<xsl:attribute name="style">width:<xsl:value-of select="@colwidth"/>;</xsl:attribute>
				</xsl:when>
			</xsl:choose>
			
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
		
</xsl:stylesheet>