<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:       Axes
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    Axes play a very important role in XSLT. All axes were used in this example. 
        Axis child:: can be be omitted from a location step as it is the default axis. 
        Axis attribute:: can be abbreviatet to @. // is short for /descendant-or-self::,
        . is short for self:: and .. is short for parent::. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <xsl:apply-templates select="//me"/>
    </xsl:template>
    <xsl:template match="br">
        <br/>
    </xsl:template>
    <xsl:template match="me" priority="10">
        <html>
            <head>
                <title>
                    <xsl:text>Document</xsl:text>
                </title>
            </head>
            <body>
                <H2>Following Axis</H2>
                <b>
                    <xsl:apply-templates select="following::*/p"/>
                </b>
                <H2>Descendant or Self Axis</H2>
                <b>
                    <xsl:apply-templates select="descendant-or-self::*/p"/>
                </b>
                <H2>Descendant Axis</H2>
                <b>
                    <xsl:apply-templates select="descendant::*/p"/>
                </b>
                <H2>Self Axis</H2>
                <b>
                    <xsl:apply-templates select="self::*/p"/>
                </b>
                <H2>Child Axis</H2>
                <b>
                    <xsl:apply-templates select="child::*/p"/>
                </b>
                <H2>Following Axis</H2>
                <p>
                    <b>
                        <xsl:apply-templates select="following::*/p"/>
                    </b>
                    <br/>
                    <i>Note the lack of ancestors here? <br/>Learned anything about document order
                        yet? </i>
                </p>
                <H2>Following Sibling Axis</H2>
                <b>
                    <xsl:apply-templates select="following-sibling::*"/>
                </b>
                <H2>Attribute Axis</H2>
                <b>
                    <xsl:apply-templates select="attribute::*"/>
                </b>
                <H2>Parent Axis</H2>
                <b>
                    <xsl:apply-templates select="parent::*/p"/>
                </b>
                <H2>Ancestor or Self Axis</H2>
                <b>
                    <xsl:apply-templates select="ancestor-or-self::*/p"/>
                </b>
                <H2>Ancestor Axis</H2>
                <b>
                    <xsl:apply-templates select="ancestor::*/p"/>
                </b>
                <H2>Preceding Sibling Axis</H2>
                <b>
                    <xsl:apply-templates select="preceding-sibling::*/p"/>
                </b>
                <H2>Preceeding Axis</H2>
                <b>
                    <i>Not Implemented in XT 22 09 99</i>
                </b>
                <H2>Namespace Axis</H2>
                <b>
                    <i>Not Implemented in XT 22 09 99</i>
                </b>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
