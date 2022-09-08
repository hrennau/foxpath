<?xml version="1.0"?>
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns="http://www.w3.org/1999/xhtml" 
	xmlns:p="http://www.stratml.net/PerformancePlanOrReport"
	exclude-result-prefixes="p" 
	version="1.0">

<!--
Copyright (C) 2010	01 COMMUNICATIONS INC.
http://stratml.DNAOS.com/stratml.html

This stylesheet started from a StratML Part1 display stylesheets developed by Crane Softwrights Ltd. 
Parts an design used from the Crane Softwrights Ltd. StratML Part1 stylesheets are

Copyright (C)	- Crane Softwrights Ltd. 
              	- http://www.CraneSoftwrights.com/links/res-stratml.htm
 
Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met:
 
- Redistributions of source code must retain the above copyright notices, 
  this list of conditions and the following disclaimer. 
- Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution. 
- The name of the author may not be used to endorse or promote products 
  derived from this software without specific prior written permission. 
 
THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR 
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN 
NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
Note: for your reference, the above is the "Modified BSD license", this text
      was obtained 2002-12-16 at http://www.xfree86.org/3.3.6/COPYRIGHT2.html#5
-->

<!-- 
January 2010: This script has been modified to accommodate the updated 
StratML schema.
 
http://xml.gov/stratml/references/PerformancePlanOrReport.xsd 
 
The primary changes involved changing xpath locations, adding a couple 
of elements (Name, Description, OtherInformation), and changing the linking
ids to use the Identifiers provided within the StratML file.
 
Redistribution and use in source and binary forms, with or without 
modification, are permitted per the copyright provided above.
 
Joe Carmel
-->

<!-- 
October 2010: StratML Part2 stylesheets where created starting from the StratML Part1 versions, 
with important fixes,changes, and additions.

The StratML document display stylesheet supports display of both StratML Part1 and Part2 specifications,
including Web browser support.

The easiest way to use it is probably to ensure that the first two lines of all StratML documents are as follows:
....................................................................................
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet href="http://stratml.DNAOS.com/stratml.xsl" type="text/xsl" ?>
....................................................................................

More information is available from stratml@DNAOS.com, and all questions, comments, and suggestions 
should also be sent to the same email address (stratml@DNAOS.com).

A copy of this XSLT-1 stylesheet is maintained and available along with corresponding StratML Part1 and Part2 Schema, 
as well as some documentation are maintained and accessible at the corresponding respective URLs:
- XSLT-1 Browser presentation stylesheet: http://stratml.DNAOS.com/stratml.xsl
- StratML Part1 XML Schema: http://stratml.DNAOS.com/stratml1.xsd
- StratML Part2 XML Schema: http://stratml.DNAOS.com/stratml2.xsd
- StratML Stylesheet documentation: http://stratml.DNAOS.com/stratml.html

Note that the portal sub-site http://stratml.dnaos.com/, refers to the same directory and has been provided for convenience.

An XSLT-2 version of the StratML (x)html presentation stylesheet has been integrated into 
01 COMMUNICATIONS' DNAOS technology (http://www.DNAOS.com/) 
along with StratML content and document management support.

More information on that version, as well as the associated DNAOS technologies and services are available at stratml@DNAOS.com.

Andre Cusson
01 COMMUNICATIONS INC.
acusson@01COMMUNICATIONS.com

George Bina - oXygen XML Editor http://www.oxygenxml.com
* Handle ISO specific elements, GivenName and Surname.

--> 

	<xsl:template match="/">
		<xsl:variable name="doc-type">
			<xsl:choose>
			  	<xsl:when test="string(*/@Type)"><xsl:value-of select="*/@Type"/></xsl:when>
			  	<xsl:when test="local-name(*) = 'PerformancePlanOrReport'"><xsl:value-of select="'PerformancePlanOrReport'"/></xsl:when>
				<xsl:when test="local-name(*) = 'StrategicPlan'"><xsl:value-of select="'StrategicPlan'"/></xsl:when>
				<xsl:otherwise>
				    <xsl:message terminate="yes">Expected a "PerformancePlanOrReport" or "StrategicPlan" document element, but detected:
						"<xsl:value-of select="concat(namespace-uri(*), ':', local-name(*))"/>"
			    	</xsl:message> 
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="plan" select="*"/>
		<html>
			<xsl:text> 
	</xsl:text>
			<xsl:comment>End result created using http://stratml.hyperbase.com/stratml.xsl</xsl:comment>
			<xsl:text> 
	</xsl:text>
			<xsl:comment>See:  http://stratml.hyperbase.com/stratml.html</xsl:comment>
			<xsl:text> 
    </xsl:text>
			<head>
				<title><xsl:value-of select="concat($doc-type, ' - Source: ', //*[local-name(.) = 'Source'])"/></title>
				<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
				<!--these styles are assumed by the stylesheet; can be overridden-->
				<style type="text/css">
/*Global*/
pre,samp {font-family:monospace;font-size:80%}
/*Heading information*/
.doc {font-family:serif; font-size:14pt}
.docheading {font-size:20pt;text-align:center;font-weight:bold}
.docsubheading {font-size:15pt;text-align:center;color:green}
.sourceheading {}
.herald {font-family:sans-serif;font-size:12pt;font-weight:bold}
.subtitle {text-align:left; font-size:14pt;color:black;font-weight:bold}
.orgstaketitle {text-align:left; font-size:14pt;color:black;font-weight:bold}
.orgstakeholder {margin-left:0.5in;font-family:sans-serif;font-size:12pt;}
/*TOC*/
.toctitle {text-align:center; font-size:16pt;color:green;font-weight:bold}
.tocsubtitle {text-align:left; font-size:14pt;color:black;font-weight:bold}
.tocentry {margin-left:.5in;text-indent:.25in;margin-top:0pt;margin-bottom:0pt}
.tocsubentry {margin-left:1in;text-indent:.25in;margin-top:0pt;margin-bottom:0pt}
/*Body*/
.vmvhead {font-size:15pt;font-weight:bold}
.vmvdesc {margin-left:.25in}
.goalsep {margin-top:16pt;margin-bottom:0pt}
.goalhead {text-align:center;font-size:16pt;color:green;font-weight:bold;margin-top:8pt}
.goaldesc {text-align:center;margin-left:25%;margin-right:25%}
.goalstaketitle {margin-left:0.5in;text-align:left; font-size:14pt;color:black;font-weight:bold}
.goalstakeholder {margin-left:1in;text-align:left;margin-left:5%;margin-right:5%}
.objhead {font-size:15pt}
.objstaketitle {margin-left:0.5in; text-align:left; font-size:12pt;color:black;font-weight:bold}
.objstakeholder {margin-left:1in}
.infotitle {margin-left:0.5in;text-indent:.25in;margin-top:0pt;margin-bottom:0pt;font-weight:bold;}
.para {margin-left:.25in;margin-right:.25in;text-indent:.25in}
.para-c { margin-left:.25in; margin-right:.25in; text-align: center; }
/*Meta*/
.meta {font-size:8pt;text-align:right;margin-top:0pt;margin-bottom:0pt}</style>
				<xsl:text> 
		      </xsl:text>
				<xsl:comment>End-user styles override built-in styles.</xsl:comment>
				<xsl:text> 
   			   </xsl:text>
				<link type="text/css" rel="stylesheet" href="http://stratml.hyperbase.com/stratml.css"/>
			</head>
			<body class="doc">
				<!--present all of the title information-->
				<p class="docheading"><xsl:value-of select="$doc-type"/></p>
				<p class="docsubheading"><xsl:value-of select="$plan/*[local-name(.) = 'Name']"/></p>
				<p class="para"><xsl:value-of select="$plan/*[local-name(.) = 'Description']"/></p>
				<p class="para"><xsl:value-of select="$plan/*[local-name(.) = 'OtherInformation']"/></p>
				<xsl:for-each select="$plan//*[local-name(.) = 'AdministrativeInformation']">
					<xsl:variable name="anchor"><xsl:call-template name="getid"/></xsl:variable>
					<p class="docsubheading" id="{$anchor}">Source: <br/>
						<a href="{*[local-name(.) = 'Source']}" target="_blank">
							<samp class="sourceheading"><xsl:value-of select="*[local-name(.) = 'Source']"/></samp>
						</a>
					</p>
					<p class="docsubheading">
						Start: <xsl:value-of select="*[local-name(.) = 'StartDate']"/> 
	        			End: <xsl:value-of select="*[local-name(.) = 'EndDate']"/> 
	        			Publication Date: <xsl:value-of select="*[local-name(.) = 'PublicationDate']"/>
					</p>
				</xsl:for-each>
				<table summary="submitter and organization information" class="doc" align="center">
					<tr valign="top">
						<td>
							<xsl:variable name="submitter" select="$plan//*[local-name(.) = 'Submitter']"/>
							<xsl:if test="normalize-space($submitter)">
								<p class="subtitle">Submitter:</p>
								<xsl:apply-templates select="$submitter"/>
							</xsl:if>
						</td>
						<td>
							<xsl:variable name="org" select="$plan/*[local-name(.) = 'StrategicPlanCore']/*[local-name(.) = 'Organization']"/>
							<xsl:if test="normalize-space($org)">
								<p class="subtitle">Organization:</p>
								<xsl:apply-templates select="$org"/>
							</xsl:if>
						</td>
					</tr>
				</table>
				<xsl:call-template name="toc"><xsl:with-param name="tocid" select="generate-id(//*[local-name(.) = 'StrategicPlanCore'])"/></xsl:call-template>
				<xsl:apply-templates select="//*[contains('Vision Mission', local-name(.))]"/>
				<xsl:if test="//*[local-name(.) = 'Value' and normalize-space(.)]">
					<p class="vmvhead" id="values_">Value<xsl:if test="count(//*[local-name(.) = 'Value' and normalize-space(.)])&gt;1">s</xsl:if></p>
					<xsl:for-each select="//*[local-name(.) = 'Value']">
						<p class="vmvdesc" id="{generate-id()}">
							<xsl:apply-templates select="*[local-name(.) = 'Name']"/>
							<xsl:for-each select="*[local-name(.) = 'Description' and normalize-space(.)]">
								<xsl:text>: </xsl:text>
								<xsl:value-of select="normalize-space(.)"/>
							</xsl:for-each>
						</p>
					</xsl:for-each>
				</xsl:if>
				<xsl:apply-templates select="//*[local-name(.) = 'Goal']"/>
				<!--meta data-->
				<p class="meta">
					<a href="http://stratml.DNAOS.com/stratml.html" target="_blank">01 COMMUNICATIONS INC.<br/>
						<samp>http://stratml.DNAOS.com/stratml.html</samp>
					</a>
				</p>
				<p class="meta">Stylesheet revision (main): 2010-10-20T20:10:10.20Z
					<br/>Stylesheet revision (base): 2010-10-20T20:10:10.20Z</p>
				<p class="meta">
					<a href="http://www.xmldatasets.net/StratML" target="_blank">XMLDatasets.net<br/>
						<samp>http://www.xmldatasets.net/StratML</samp>
					</a>
				</p>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="getid">
		<xsl:choose>
			<xsl:when test="normalize-space(*[local-name(.) = 'Identifier'])"><xsl:value-of select="*[local-name(.) = 'Identifier']"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="generate-id(.)"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*[local-name(.) = 'Submitter']">
		<xsl:variable name="anchor"><xsl:call-template name="getid"/></xsl:variable>
		<blockquote id="{$anchor}">
			<xsl:for-each select="*[local-name(.) = 'FirstName' and normalize-space(.)]">
				<p>
					<b class="herald">First name: </b>
					<xsl:value-of select="."/>
				</p>
			</xsl:for-each>
			<xsl:for-each select="*[local-name(.) = 'GivenName' and normalize-space(.)]">
				<p>
					<b class="herald">Given name: </b>
					<xsl:value-of select="."/>
				</p>
			</xsl:for-each>
			<xsl:for-each select="*[local-name(.) = 'LastName' and normalize-space(.)]">
				<p>
					<b class="herald">Last name: </b>
					<xsl:value-of select="."/>
				</p>
			</xsl:for-each>
			<xsl:for-each select="*[local-name(.) = 'Surname' and normalize-space(.)]">
				<p>
					<b class="herald">Surname: </b>
					<xsl:value-of select="."/>
				</p>
			</xsl:for-each>
			<xsl:for-each select="*[local-name(.) = 'PhoneNumber' and normalize-space(.)]">
				<p>
					<b class="herald">Phone Number: </b>
					<xsl:value-of select="."/>
				</p>
			</xsl:for-each>
			<xsl:for-each select="*[local-name(.) = 'EmailAddress' and normalize-space(.)]">
				<p>
					<b class="herald">Email Address: </b>
					<a href="mailto:{.}"><samp><xsl:value-of select="."/></samp></a>
				</p>
			</xsl:for-each>
		</blockquote>
	</xsl:template>

	<xsl:template match="*[local-name(.) = 'Organization']">
		<xsl:variable name="anchor"><xsl:call-template name="getid"/></xsl:variable>
		<blockquote id="{$anchor}">
			<xsl:for-each select="*[local-name(.) = 'Name' and normalize-space(.)]">
				<p>
					<b class="herald">Name: </b>
					<xsl:value-of select="."/>
				</p>
			</xsl:for-each>
			<xsl:for-each select="*[local-name(.) = 'Acronym' and normalize-space(.)]">
				<p>
					<b class="herald">Acronym: </b>
					<xsl:value-of select="."/>
				</p>
			</xsl:for-each>
			<xsl:for-each select="*[local-name(.) = 'Description' and normalize-space(.)]">
				<p>
					<b class="herald">Description: </b>
					<xsl:value-of select="."/>
				</p>
			</xsl:for-each>
			<xsl:call-template name="stakeholder"><xsl:with-param name="level" select="'org'"/></xsl:call-template>
		</blockquote>
	</xsl:template>

	<xsl:template name="toc">
		<xsl:param name="tocid" select="toc"/>
		<xsl:for-each select="*/*[local-name(.) = 'StrategicPlanCore']">
			<p class="toctitle" id="{$tocid}">
				Table of contents
				<br/><hr width="60%"/>
			</p>
			<xsl:for-each select="*[local-name(.) = 'Vision']">
				<p class="tocentry">
					<xsl:variable name="anchor"><xsl:call-template name="getid"/></xsl:variable>
					<a href="#{$anchor}">Vision</a>
				</p>
			</xsl:for-each>
			<xsl:for-each select="*[local-name(.) = 'Mission']">
				<p class="tocentry">
					<xsl:variable name="anchor1"><xsl:call-template name="getid"/></xsl:variable>
					<a href="#{$anchor1}">Mission</a>
				</p>
			</xsl:for-each>
			<xsl:if test="*[local-name(.) = 'Value']">
				<p class="tocentry">
					<a href="#values_">Value<xsl:if test="count(*[local-name(.) = 'Value'])&gt;1">s</xsl:if></a>
				</p>
				<xsl:for-each select="*[local-name(.) = 'Value']">
					<p class="tocsubentry">
						<a href="#{generate-id(.)}">
							<xsl:apply-templates select="*[local-name(.) = 'Name']"/>
						</a>
					</p>
				</xsl:for-each>
			</xsl:if>
			<xsl:for-each select="*[local-name(.) = 'Goal']">
				<p class="tocentry">
					<xsl:variable name="anchor2"><xsl:call-template name="getid"/></xsl:variable>
					<a href="#{$anchor2}">
						<xsl:apply-templates select="*[local-name(.) = 'SequenceIndicator']"/>
						<xsl:apply-templates select="*[local-name(.) = 'Name']"/>
					</a>
				</p>
				<xsl:for-each select="*[local-name(.) = 'Objective']">
					<p class="tocsubentry">
						<xsl:variable name="anchor3"><xsl:call-template name="getid"/></xsl:variable>
						<a href="#{$anchor3}">
							<xsl:apply-templates select="*[local-name(.) = 'SequenceIndicator']"/>
							<xsl:apply-templates select="*[local-name(.) = 'Name']"/>
						</a>
					</p>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:for-each>
		<br/><hr width="60%"/>
	</xsl:template>

	<xsl:template match="*[local-name(.) = 'SequenceIndicator' and normalize-space(.)]">
		<xsl:value-of select="concat(., ': ')"/>
	</xsl:template>

	<xsl:template match="*[local-name(.) = 'Goal']">
		<hr class="goalsep"/>
		<xsl:variable name="anchor"><xsl:call-template name="getid"/></xsl:variable>
		<p class="goalhead" id="{$anchor}">
			<a href="#{$anchor}">
				<xsl:if test="not(contains(*[local-name(.) = 'SequenceIndicator'], 'Goal'))"><xsl:text>Goal </xsl:text></xsl:if>
				<xsl:apply-templates select="*[local-name(.) = 'SequenceIndicator']"/>
			</a>
			<xsl:for-each select="*[local-name(.) = 'Name' and normalize-space(.)]">
				<xsl:apply-templates select="."/>
			</xsl:for-each>
		</p>
		<xsl:for-each select="*[local-name(.) = 'Description' and normalize-space(.)]">
			<p class="goaldesc"><xsl:apply-templates/></p>
		</xsl:for-each>
		<xsl:call-template name="stakeholder"><xsl:with-param name="level" select="'goal'"/></xsl:call-template>
		<p class="infotitle">Objective(s):</p>
		<xsl:for-each select="*[local-name(.) = 'Objective' and normalize-space(.)]">
			<p class="tocsubentry">
				<xsl:variable name="anchor2"><xsl:call-template name="getid"/></xsl:variable>
				<a href="#{$anchor2}">
					<xsl:apply-templates select="*[local-name(.) = 'SequenceIndicator']"/>
					<xsl:apply-templates select="*[local-name(.) = 'Name']"/>
					<br/>
				</a>
			</p>
		</xsl:for-each>
		<br/>
		<xsl:apply-templates select="*[local-name(.) = 'OtherInformation']"/>
		<xsl:apply-templates select="*[contains('Objective  ', local-name(.))]"/>
	</xsl:template>

	<xsl:template name="stakeholder">
		<xsl:param name="level" select="'org'"/>
		<xsl:if test="*[local-name(.) = 'Stakeholder' and normalize-space(.)]">
			<p class="{concat($level, 'staketitle')}">Stakeholder(s):</p>
			<xsl:apply-templates select="*[local-name(.) = 'Stakeholder']">
				<xsl:with-param name="level" select="$level"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*[local-name(.) = 'Stakeholder' and normalize-space(.)]">
		<xsl:param name="level" select="'org'"/>
		<p class="{concat($level, 'stakeholder')}">
			<xsl:call-template name="name-desc"/>
		</p>
	</xsl:template>

	<xsl:template name="name-desc">
		<b><xsl:apply-templates select="*[local-name(.) = 'Name' and 
			normalize-space(.)]"/></b><xsl:if test="normalize-space(*[local-name(.) = 'Description'])"><b>: </b> 
			<xsl:apply-templates select="*[local-name(.) = 'Description']"/>
		</xsl:if>
		<xsl:if test="*[local-name(.) = 'RoleType' and normalize-space(.)]"> (<xsl:for-each select="*[local-name(.) = 'RoleType' 
			and normalize-space(.)]"><xsl:if test="not(position() = 1)">, </xsl:if><xsl:apply-templates select="."/></xsl:for-each>)</xsl:if><br/>
			<xsl:if test="*[local-name(.) = 'Role' and normalize-space(.)]">As <xsl:for-each select="*[local-name(.) = 'Role' and 
			normalize-space(.)]"><xsl:call-template name="name-desc"/></xsl:for-each>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[contains('Vision Mission', local-name(.))]">
		<xsl:variable name="anchor"><xsl:call-template name="getid"/></xsl:variable>
		<p class="vmvhead" id="{$anchor}">
			<a href="#{$anchor}">
				<xsl:choose>
					<xsl:when test="local-name(.) = 'Vision'">Vision</xsl:when>
					<xsl:otherwise>Mission</xsl:otherwise>
				</xsl:choose>
			</a>
		</p>
		<p class="vmvdesc"><xsl:apply-templates select="*[local-name(.) = 'Description']"/></p>
	</xsl:template>

	<xsl:template match="*[local-name(.) = 'Objective']">
		<xsl:variable name="anchor"><xsl:call-template name="getid"/></xsl:variable>
		<p class="objhead" id="{$anchor}">
			<a href="#{$anchor}">
				<xsl:text>Objective </xsl:text>
				<xsl:apply-templates select="*[local-name(.) = 'SequenceIndicator']"/>
			</a>
			<xsl:for-each select="*[local-name(.) = 'Name']">
				<xsl:apply-templates select="."/>
			</xsl:for-each>
		</p>
		<xsl:for-each select="*[local-name(.) = 'Description']">
			<p class="para"><xsl:apply-templates select="."/></p>
		</xsl:for-each>
		<xsl:call-template name="stakeholder"><xsl:with-param name="level" select="'obj'"/></xsl:call-template>
		<xsl:apply-templates select="*[local-name(.) = 'OtherInformation']"/>
		<xsl:apply-templates select="*[local-name(.) = 'PerformanceIndicator' and normalize-space(.)]"/>
	</xsl:template>

	<xsl:template match="*[local-name(.) = 'OtherInformation' and normalize-space(.)]">
		<p class="infotitle" id="{generate-id(.)}">Other Information:</p>
		<p class="para"><xsl:apply-templates/></p>
	</xsl:template>

	<xsl:template match="*[local-name(.) = 'PerformanceIndicator' and normalize-space(.)]">
		<xsl:if test="position() = 1">
			<p class="para-c">INDICATORS</p>
		</xsl:if>
		<xsl:variable name="anchor"><xsl:call-template name="getid"/></xsl:variable>
		<p class="para-c" id="{$anchor}">
			<a href="#{$anchor}">
				<xsl:apply-templates select="*[local-name(.) = 'SequenceIndicator']"/><xsl:value-of select="normalize-space(*[local-name(.) = 'Name'])"/>
				<xsl:if test="normalize-space(concat(@PerformanceIndicatorType, 
					@ValueChainStage))">[<xsl:value-of select="normalize-space(@PerformanceIndicatorType)"/><xsl:if test="normalize-space(@PerformanceIndicatorType) and 
					normalize-space(@ValueChainStage)">, </xsl:if><xsl:value-of select="normalize-space(@ValueChainStage)"/>] 
				</xsl:if>
				Measurements <xsl:if test="*[local-name(.) = 'MeasurementDimension' and normalize-space(.)]">in <xsl:apply-templates select="*[local-name(.) = 'MeasurementDimension']"/></xsl:if>
			</a>
		</p>
		<p class="para"><xsl:apply-templates select="*[local-name(.) = 'Description']"/></p>
		<xsl:if test="normalize-space(*[local-name(.) = 'Relationship'])">
			<p class="para">Relationships:</p>
			<xsl:apply-templates select="*[local-name(.) = 'Relationship' and normalize-space(.)]"/>
		</xsl:if>
		<xsl:apply-templates select="*[local-name(.) = 'MeasurementInstance' and normalize-space(.)]"/>
		<xsl:apply-templates select="*[local-name(.) = 'OtherInformation']"/>
	</xsl:template>

	<xsl:template match="*[local-name(.) = 'Relationship']">
		<xsl:variable name="anchor"><xsl:call-template name="getid"/></xsl:variable>
		<p class="tocsubentry" id="{$anchor}">
			<a href="#{$anchor}">
				<xsl:value-of select="*[local-name(.) = 'Name']"/><xsl:if test="normalize-space(@RelationshipType)"><xsl:value-of select="concat(' - ', @RelationshipType)"/></xsl:if>
			</a>
		</p>
		<p class="para"><xsl:apply-templates select="*[local-name(.) = 'Description']"/></p>
	</xsl:template>

	<xsl:template match="*[local-name(.) = 'MeasurementInstance']">
		<table align="center" border="1">
			<tr>
				<th>Type</th>
				<th>&#160;&#160;&#160;&#160;&#160;&#160;Start&#160;&#160;&#160;&#160;&#160;&#160;</th>
				<th>&#160;&#160;&#160;&#160;&#160;&#160;&#160;End&#160;&#160;&#160;&#160;&#160;&#160;&#160;</th>
				<th><xsl:choose><xsl:when test="normalize-space(../*[local-name(.) = 'UnitOfMeasurement'])"><xsl:value-of select="../*[local-name(.) = 'UnitOfMeasurement']"/></xsl:when><xsl:otherwise>Units</xsl:otherwise></xsl:choose></th>
				<th>Description</th>
			</tr>
			<xsl:for-each select="*[normalize-space(.)]">
				<xsl:sort select="*[local-name(.) = 'StartDate']"/>
				<xsl:sort select="local-name(.)" order="descending"/>
				<tr>
					<td align="center">
						<xsl:variable name="type">
							<xsl:choose>
								<xsl:when test="starts-with(local-name(.), 'Actual')">Actual</xsl:when>
								<xsl:otherwise>Target</xsl:otherwise> 
							</xsl:choose>
						</xsl:variable>
						<xsl:value-of select="concat('&#160;', $type, '&#160;')"/>
					</td>
					<td align="center"><xsl:value-of select="concat('&#160;', *[local-name(.) = 'StartDate'], '&#160;')"/></td>
					<td align="center"><xsl:value-of select="concat('&#160;', *[local-name(.) = 'EndDate'], '&#160;')"/></td>
					<td align="right"><xsl:value-of select="concat('&#160;', *[local-name(.) = 'NumberOfUnits'], '&#160;')"/></td>
					<td align="left" width="*"><xsl:value-of select="concat('&#160;', *[local-name(.) = 'Description'], '&#160;')"/></td>
				</tr>
			</xsl:for-each>
		</table>
	</xsl:template>
</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2007. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios ><scenario default="yes" name="test" userelativepaths="yes" externalpreview="no" url="gaopar2009.xml" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator="" ><advancedProp name="sInitialMode" value=""/><advancedProp name="bXsltOneIsOkay" value="true"/><advancedProp name="bSchemaAware" value="false"/><advancedProp name="bXml11" value="false"/><advancedProp name="iValidation" value="0"/><advancedProp name="bExtensions" value="true"/><advancedProp name="iWhitespace" value="0"/><advancedProp name="sInitialTemplate" value=""/><advancedProp name="bTinyTree" value="true"/><advancedProp name="bWarnings" value="true"/><advancedProp name="bUseDTD" value="false"/><advancedProp name="iErrorHandling" value="0"/></scenario></scenarios><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->