<?xml version="1.0" encoding="UTF-8"?>
<!--This stylesheet generates documentation from a WSDL file-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://schemas.xmlsoap.org/wsdl/">
    <xsl:output indent="yes" method="html"/>
    <xsl:param name="fileName"/>

    <!-- Write XML tags to HTML output (escape) -->
    <xsl:template name="WriteElement">
        <xsl:param name="element"/>
        <!-- Start Tag -->
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="name($element)"/>
        <!-- Attributes -->
        <xsl:for-each select="$element/@*">
            <xsl:text> </xsl:text>
            <xsl:value-of select="name(.)"/>
            <xsl:text>="</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>"</xsl:text>
        </xsl:for-each>
        <xsl:choose>
            <xsl:when test="$element/* | $element/text()">
                <!-- Close Start Tag -->
                <xsl:text>> </xsl:text>
                <!-- Content -->
                <xsl:for-each select="$element/*">
                    <xsl:call-template name="WriteElement">
                        <xsl:with-param name="element" select="."/>
                    </xsl:call-template>
                </xsl:for-each>
                <!-- End Tag -->
                <xsl:text>&lt;/</xsl:text>
                <xsl:value-of select="name($element)"/>
                <xsl:text>></xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <!-- Close Start Tag -->
                <xsl:text>/></xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Overview presenter -->
    <xsl:template name="overview">
        <h3>Overview:</h3>
        <table class="properties" width="100%">
            <tr>
                <td valign="top">
                    <table cellspacing="10" width="100%">
                        <tr valign="top">
                            <th align="left"> Services </th>
                        </tr>
                        <xsl:for-each select="//service">
                            <tr>
                                <td>
                                    <a href="#Service_{@name}">
                                        <xsl:value-of select="@name"/>
                                    </a>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </table>
                </td>
                <td valign="top">
                    <table cellspacing="10" width="100%">
                        <tr valign="top">
                            <th align="left">Bindings</th>
                        </tr>
                        <xsl:for-each select="//binding">
                            <tr>
                                <td>
                                    <a href="#Binding_{@name}">
                                        <xsl:value-of select="@name"/>
                                    </a>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </table>
                </td>
                <td valign="top">
                    <table cellspacing="10" width="100%">
                        <tr valign="top">
                            <th align="left">Port types</th>
                        </tr>
                        <xsl:for-each select="//portType">
                            <tr>
                                <td>
                                    <a href="#PortType_{@name}">
                                        <xsl:value-of select="@name"/>
                                    </a>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </table>
                </td>
                <td valign="top">
                    <table cellspacing="10">
                        <tr valign="top">
                            <th align="left">Messages</th>
                        </tr>
                        <tr>
                            <td>
                                <xsl:for-each select="//message">
                                    <a href="#Message_{@name}">
                                        <xsl:value-of select="@name"/>
                                    </a>, </xsl:for-each>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
        <br/>
    </xsl:template>

    <!-- Defnition name -->
    <xsl:template name="definitions">
        <xsl:if test="not(count(//definitions/@name | //definitions/documentation) = 0)">
            <table border="1" align="center" width="100%" cellspacing="0" class="properties">
                <tr>
                    <th colspan="2">
                        <b>
                            <xsl:text>WSDL Definition</xsl:text>
                        </b>
                    </th>
                </tr>
                <tr>
                    <th>Name</th>
                    <th>Documentation</th>
                </tr>
                <tr>
                    <td>
                        <xsl:choose>
                            <xsl:when test="count(//definitions/@name) = 0"> N/A </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="//definitions/@name"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                    <td>
                        <xsl:choose>
                            <xsl:when test="count(//definitions/documentation) = 0"> N/A </xsl:when>
                            <xsl:otherwise>
                                <!-- TODO -->
                                <xsl:value-of select="//definitions/documentation"
                                    disable-output-escaping="yes"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                </tr>
            </table>
            <br/>
        </xsl:if>
    </xsl:template>

    <!-- Service name/description -->
    <xsl:template name="services">
        <table border="1" align="center" width="100%" cellspacing="0" class="properties">
            <tr>
                <th colspan="2">
                    <b>
                        <xsl:text>Services</xsl:text>
                    </b>
                </th>
            </tr>
            <tr>
                <th>Name</th>
                <th>Documentation</th>
            </tr>
            <xsl:for-each select="//service">
                <tr>
                    <td>
                        <a href="#Service_{@name}">
                            <xsl:value-of select="@name"/>
                        </a>
                    </td>
                    <td>
                        <xsl:call-template name="copyDocumentation"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
        <br/>
        <br/>
    </xsl:template>

    <!-- Copy documentation node to output -->
    <xsl:template name="copyDocumentation">
        <table class="doc">
            <tr>
                <td>
                    
            <xsl:choose>
                <xsl:when test="count(documentation) = 0"> N/A </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="count(documentation/*) != 0">
                            <xsl:apply-templates select="documentation/(*|text())" mode="copy"/>
                        </xsl:when>
                        <xsl:when test="contains(documentation, '&lt;')">
                            <xsl:value-of select="documentation" disable-output-escaping="yes"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="documentation"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
                </td>
            </tr>
        </table>
        
    </xsl:template>

    <!-- Deep copy template -->
    <xsl:template match="*|text()|@*" mode="copy">
        <xsl:copy>
            <xsl:apply-templates mode="copy" select="@*"/>
            <xsl:apply-templates mode="copy"/>
        </xsl:copy>
    </xsl:template>

    <!-- Enumeration of ports name/binding.... for each service -->
    <xsl:template name="services_enum">
        <xsl:for-each select="//service">
            <table border="1" align="center" width="100%" cellspacing="0" class="properties">
                <tr>
                    <th colspan="4">
                        <b>
                            <xsl:text>Service : </xsl:text>
                            <a name="Service_{@name}">
                                <xsl:value-of select="@name"/>
                            </a>
                        </b>
                    </th>
                </tr>
                <tr>
                    <th>Port Name</th>
                    <th>Binding</th>
                    <th>Address Extensibility</th>
                    <th>Documentation</th>
                </tr>
                <xsl:for-each select="port">
                    <tr>
                        <td>
                            <xsl:value-of select="@name"/>
                        </td>
                        <td>
                            <a href="#Binding_{substring-after(@binding, ':')}">
                                <xsl:value-of select="substring-after(@binding, ':')"/>
                            </a>
                        </td>
                        <td>
                            <xsl:for-each select="*[local-name()='address']">
                                <code>
                                    <xsl:call-template name="WriteElement">
                                        <xsl:with-param name="element" select="."/>
                                    </xsl:call-template>
                                </code>
                                <xsl:if test="last() != position()">
                                    <br/>
                                </xsl:if>
                            </xsl:for-each>
                        </td>
                        <td>
                            <xsl:call-template name="copyDocumentation"/>

                        </td>
                    </tr>
                </xsl:for-each>
            </table>
            <br/>
            <br/>
        </xsl:for-each>
    </xsl:template>

    <!-- Enumeration of port types for each binding -->
    <xsl:template name="bindings_enum">
        <xsl:for-each select="/*/binding">
            <table border="1" align="center" width="100%" cellspacing="0" class="properties">
                <tr>
                    <th colspan="2">
                        <b>
                            <xsl:text>Binding : </xsl:text>
                            <a name="Binding_{@name}">
                                <xsl:value-of select="@name"/>
                            </a>
                        </b>
                    </th>
                </tr>
                <tr>
                    <td>Port Type</td>
                    <td>
                        <a href="#PortType_{substring-after(@type, ':')}">
                            <xsl:value-of select="substring-after(@type, ':')"/>
                        </a>
                    </td>
                </tr>
                <tr>
                    <td>Extensibility</td>
                    <td>
                        <code>
                            <xsl:call-template name="WriteElement">
                                <xsl:with-param name="element" select="*[local-name()='binding']"/>
                            </xsl:call-template>
                        </code>
                    </td>
                </tr>
                <tr>
                    <td>Operations</td>
                    <td>
                        <xsl:for-each select="operation">
                            <xsl:value-of select="@name"/>, </xsl:for-each>
                    </td>
                </tr>
            </table>
            <br/>
            <br/>
        </xsl:for-each>
    </xsl:template>

    <!-- Enumerate operations for each port type -->
    <xsl:template name="portTypes">
        <xsl:for-each select="//portType">
            <table border="1" align="center" width="100%" cellspacing="0" class="properties">
                <tr>
                    <th colspan="4"> Port Type : <a name="PortType_{@name}">
                            <xsl:value-of select="@name"/>
                        </a>
                    </th>
                </tr>
                <tr>
                    <th>Operation Name</th>
                    <th>Input message</th>
                    <th>Output message</th>
                    <th>Documentation</th>
                </tr>
                <xsl:for-each select="operation">
                    <tr>
                        <td>
                            <xsl:value-of select="@name"/>
                        </td>
                        <td>
                            <a href="#Message_{substring-after(input/@message, ':')}">
                                <xsl:value-of select="substring-after(input/@message, ':')"/>
                            </a>
                        </td>
                        <td>
                            <a href="#Message_{substring-after(output/@message, ':')}">
                                <xsl:value-of select="substring-after(output/@message, ':')"/>
                            </a>
                        </td>
                        <td>
                            <xsl:call-template name="copyDocumentation"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </table>
            <br/>
            <br/>
        </xsl:for-each>
    </xsl:template>

    <!-- Enumerate all messages. -->
    <xsl:template name="operations_enum">
        <h2>Messages:</h2>
        <br/>
        <xsl:for-each select="//message">
            <br/>
            <h2>
                <a name="Message_{@name}">
                    <xsl:value-of select="@name"/>
                </a>
            </h2>
            <h3>
                <xsl:text>Documentation : </xsl:text>
            </h3>
            <p>
                <xsl:call-template name="copyDocumentation"/>
            </p>
            <table border="1" align="center" width="100%" cellspacing="0" class="properties">
                <tr>
                    <th width="25%">Part Name</th>
                    <th width="25%">Element</th>
                    <th width="25%">Type</th>
                    <th width="25%">Documentation</th>
                </tr>
                <xsl:for-each select="part">
                    <tr>
                        <td>
                            <xsl:value-of select="@name"/>
                        </td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="@element">
                                    <xsl:value-of select="@element"/>
                                </xsl:when>
                                <xsl:otherwise> N/A </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="@type">
                                    <xsl:value-of select="@type"/>
                                </xsl:when>
                                <xsl:otherwise> N/A </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td>
                            <xsl:call-template name="copyDocumentation"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </table>
            <br/>
            <br/>
        </xsl:for-each>
    </xsl:template>

    <!-- Main entry -->
    <xsl:template match="/">
        <html>
            <head>
                <style type="text/css">
                    body {
                    color: Black;
                    background-color: White;
                    font-family: Arial, sans-serif;
                    font-size: 10pt;
                    }                    
                    table.properties th, table.properties th a {
                    color: black;
                    background-color: #FFDDDD; /* Pinkish */
                    }
                    table.properties td {
                    background-color: #eee; /* Gray */
                    }                    
                    table.doc{
                    background-color: #eee; 
                    }
                    table.doc td{
                    background-color: #eee; 
                    }
                    
                </style>
                <title>Documentation for file " <xsl:value-of select="$fileName"/>" </title>
            </head>
            <body>
                <h2>WSDL file: "<xsl:value-of select="$fileName"/>"</h2>
                <h2>Target namespace: <xsl:value-of select="//definitions/@targetNamespace"/></h2>
                <xsl:call-template name="overview"/>
                <xsl:call-template name="definitions"/>
                <xsl:call-template name="services"/>
                <xsl:call-template name="services_enum"/>
                <xsl:call-template name="bindings_enum"/>
                <xsl:call-template name="portTypes"/>
                <xsl:call-template name="operations_enum"/>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
