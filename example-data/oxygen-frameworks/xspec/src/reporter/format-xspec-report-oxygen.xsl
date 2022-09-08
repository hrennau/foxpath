<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:oxy="http://www.oxygenxml.com/xslt/xspec"
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:x="http://www.jenitennison.com/xslt/xspec"
    xmlns:test="http://www.jenitennison.com/xslt/unit-test"
    exclude-result-prefixes="x xs test pkg"
    xmlns:pkg="http://expath.org/ns/pkg"
    xmlns="http://www.w3.org/1999/xhtml">
    <xsl:import href="format-xspec-report.xsl"/>
    
    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
        <desc>Overridden to change the structure of the table. passed/pending/failed/total were
        split into 4 columns in order to make them easier to read.</desc>
    </doc>
    <xsl:template match="x:report" mode="x:html-report">
        <p>
            <xsl:value-of select="if ( exists(@query) ) then 'Query: ' else 'Stylesheet: '"/>
            <a href="{ @stylesheet|@query }">
                <xsl:value-of select="test:format-URI(@stylesheet|@query)"/>
            </a>
        </p>
        <p>
            <xsl:text>Tested: </xsl:text>
            <xsl:value-of select="format-dateTime(@date, '[D] [MNn] [Y] at [H01]:[m01]')" />
        </p>
        <h2>Contents</h2>
        <table class="xspec">
            <col width="80%" />
            <!-- Oxygen patch start -->
            <col width="5%" />
            <col width="5%" />
            <col width="5%" />
            <col width="5%" />
            <!-- Oxygen patch end -->
            <thead>
                <tr>
                    <th></th>
                    <!-- Oxygen patch start -->
                    <xsl:for-each select="oxy:totals(//x:scenario/x:test, true())">
                        <th class="result"><xsl:value-of select="."/></th>                        
                    </xsl:for-each>
                    <!-- Oxygen patch end -->
                </tr>
            </thead>
            <tbody>
                <xsl:for-each select="x:scenario">
                    <xsl:variable name="pending" as="xs:boolean"
                        select="exists(@pending)" />
                    <xsl:variable name="any-failure" as="xs:boolean"
                        select="exists(.//x:test[parent::x:scenario][@successful = 'false'])" />
                    <tr class="{if ($pending) then 'pending' else if ($any-failure) then 'failed' else 'successful'}">
                        <th>
                            <xsl:copy-of select="x:pending-callback(@pending)"/>
                            <a href="#{generate-id()}">
                                <xsl:apply-templates select="x:label" mode="x:html-report" />
                            </a>
                        </th>
                        <!-- Oxygen patch start -->
                        <xsl:for-each select="oxy:totals(.//x:test[parent::x:scenario], false())">
                            <th class="result"><xsl:value-of select="."/></th>                        
                        </xsl:for-each>
                        <!-- Oxygen patch end -->
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
        <xsl:for-each select="x:scenario[not(@pending)]">
            <xsl:call-template name="x:format-top-level-scenario"/>
        </xsl:for-each>
    </xsl:template>
    
    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
        <desc>the same functionality of <ref type="template" name="x:totals">x:totals</ref> template but the result
        is a sequence to allow an iterator.</desc>
    </doc>
    <xsl:function name="oxy:totals">
        <xsl:param name="tests" as="element(x:test)*"/>
        <xsl:param name="labels"/>
        <xsl:if test="$tests">
            <xsl:variable name="passed" as="element(x:test)*" select="$tests[@successful = 'true']" />
            <xsl:variable name="pending" as="element(x:test)*" select="$tests[exists(@pending)]" />
            <xsl:variable name="failed" as="element(x:test)*" select="$tests[@successful = 'false']" />
            <xsl:choose>
                <xsl:when test="$labels">
                    <xsl:value-of select="concat('passed:', count($passed))" />
                    <xsl:value-of select="concat('pending:', count($pending))" />
                    <xsl:value-of select="concat('failed:', count($failed))" />
                    <xsl:value-of select="concat('total:', count($tests))" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="count($passed)" />
                    <xsl:value-of select="count($pending)" />
                    <xsl:value-of select="count($failed)" />
                    <xsl:value-of select="count($tests)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>
    
    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
        <desc>Overridden to give more space to the second column.</desc>
    </doc>
    <xsl:template name="x:format-top-level-scenario">
        <xsl:variable name="pending" as="xs:boolean"
            select="exists(@pending)" />
        <xsl:variable name="any-failure" as="xs:boolean"
            select="exists(x:test[@successful = 'false'])" />
        <div id="{generate-id()}">
            <h2 class="{if ($pending) then 'pending' else if ($any-failure) then 'failed' else 'successful'}">
                <xsl:copy-of select="x:pending-callback(@pending)"/>
                <xsl:apply-templates select="x:label" mode="x:html-report" />
                <span class="scenario-totals">
                    <xsl:call-template name="x:totals">
                        <xsl:with-param name="tests" select=".//x:test[parent::x:scenario]" />
                    </xsl:call-template>
                </span>
            </h2>
            <table class="xspec" id="t-{generate-id()}">
                <col width="80%" />
                <!-- Oxygen patch. Present the labels too because the values are too cryptic by themselves.
                     So the column is a little bigger. -->
                <col width="20%" />
                <tbody>
                    <tr class="{if ($pending) then 'pending' else if ($any-failure) then 'failed' else 'successful'}">
                        <th>
                            <xsl:copy-of select="x:pending-callback(@pending)"/>
                            <xsl:apply-templates select="x:label" mode="x:html-report" />
                        </th>
                        <th>
                            <xsl:call-template name="x:totals">
                                <xsl:with-param name="tests" select=".//x:test[parent::x:scenario]" />
                            </xsl:call-template>
                        </th>
                    </tr>
                    <xsl:apply-templates select="x:test" mode="x:html-summary" />
                    <xsl:for-each select=".//x:scenario[x:test]">
                        <xsl:variable name="pending" as="xs:boolean"
                            select="exists(@pending)" />
                        <xsl:variable name="any-failure" as="xs:boolean"
                            select="exists(x:test[@successful = 'false'])" />
                        <xsl:variable name="label" as="node()+">
                            <xsl:for-each select="ancestor-or-self::x:scenario[position() != last()]">
                                <xsl:apply-templates select="x:label" mode="x:html-report" />
                                <xsl:if test="position() != last()">
                                    <xsl:copy-of select="x:separator-callback()"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <tr class="{if ($pending) then 'pending' else if ($any-failure) then 'failed' else 'successful'}">
                            <th>
                                <xsl:copy-of select="x:pending-callback(@pending)"/>
                                <xsl:choose>
                                    <xsl:when test="$any-failure">
                                        <a href="#{generate-id()}">
                                            <xsl:sequence select="$label" />
                                        </a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:sequence select="$label" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </th>
                            <th>
                                <xsl:call-template name="x:totals">
                                    <xsl:with-param name="tests" select="x:test" />
                                </xsl:call-template>
                            </th>
                        </tr>
                        <xsl:apply-templates select="x:test" mode="x:html-summary" />
                    </xsl:for-each>
                </tbody>
            </table>
            <xsl:apply-templates select="descendant-or-self::x:scenario[x:test[@successful = 'false']]" mode="x:html-report" />
        </div>
    </xsl:template>
    
    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
        <desc>Overridden to change a little the text rendered with labels: 'passed:' instead of 'passed: '.
            The default for 'labels' parameter also changed because the values without labels are very cryptic.</desc>
    </doc>
    <xsl:template name="x:totals">
        <xsl:param name="tests" as="element(x:test)*" required="yes" />
        <xsl:param name="labels" as="xs:boolean" select="true()" />
        <xsl:if test="$tests">
            <xsl:variable name="passed" as="element(x:test)*" select="$tests[@successful = 'true']" />
            <xsl:variable name="pending" as="element(x:test)*" select="$tests[exists(@pending)]" />
            <xsl:variable name="failed" as="element(x:test)*" select="$tests[@successful = 'false']" />
            <xsl:if test="$labels">passed:</xsl:if>
            <xsl:value-of select="count($passed)" />
            <xsl:if test="$labels"><xsl:text> </xsl:text></xsl:if>
            <xsl:text>/</xsl:text>
            <xsl:if test="$labels"> pending:</xsl:if>
            <xsl:value-of select="count($pending)" />
            <xsl:if test="$labels"><xsl:text> </xsl:text></xsl:if>
            <xsl:text>/</xsl:text>
            <xsl:if test="$labels"> failed:</xsl:if>
            <xsl:value-of select="count($failed)" />
            <xsl:if test="$labels"><xsl:text> </xsl:text></xsl:if>
            <xsl:text>/</xsl:text>
            <xsl:if test="$labels"> total:</xsl:if>
            <xsl:value-of select="count($tests)" />
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>