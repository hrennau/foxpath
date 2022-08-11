<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">    
    <xsl:output method="xml" indent="yes" version="1.0" encoding="ISO-8859-1"/>
    <xsl:template match="data">
        <!-- Define the sizes-->
        <svg xmlns="http://www.w3.org/2000/svg" width="540" height="300" viewBox="0 0 800 400">
            <g transform="translate(-60,20)">
                <!-- The title -->
                <text style="font-size:18" x="400" y="5" font-family="Dialog">
                    <xsl:value-of select="description"/>
                </text>
                <!-- The x and y axes  -->
                <g style="stroke-width:2; stroke:black">
                    <path d="M 80 263 L  80  10 L 80 263 L 850 263 Z"/>
                </g>
                <g style="stroke-width:2; stroke:grey">
                    <path d="M 80 203 L 850 203 Z"/>
                </g>
                <g style="stroke-width:2; stroke:grey">
                    <path d="M 80 143 L 850 143 Z"/>
                </g>
                <g style="stroke-width:2; stroke:grey">
                    <path d="M 80 83 L 850 83 Z"/>
                </g>
                <!-- y-axis labels -->
                <g style="text-anchor:end; font-size:10">
                    <text x="76" y="263" font-family="Dialog">0</text>
                    <text x="76" y="243" font-family="Dialog">10</text>
                    <text x="76" y="223" font-family="Dialog">20</text>
                    <text x="76" y="203" font-family="Dialog">30</text>
                    <text x="76" y="183" font-family="Dialog">40</text>
                    <text x="76" y="163" font-family="Dialog">50</text>
                    <text x="76" y="143" font-family="Dialog">60</text>
                    <text x="76" y="123" font-family="Dialog">70</text>
                    <text x="76" y="103" font-family="Dialog">80</text>
                    <text x="76" y="83" font-family="Dialog">90</text>
                    <text x="76" y="63" font-family="Dialog">100</text>
                    <text x="76" y="43" font-family="Dialog">110</text>
                    <text x="76" y="23" font-family="Dialog">120</text>
                </g>
                <!-- Gradients -->
                <radialGradient id="gradient1" fx=".1" fy=".1">
                    <stop style="stop-color:cyan" offset=".1"/>
                    <stop style="stop-color:blue" offset="1"/>
                </radialGradient>
                <radialGradient id="gradient2" fx=".1" fy=".1">
                    <stop style="stop-color:yellow" offset=".1"/>
                    <stop style="stop-color:green" offset="1"/>
                </radialGradient>
                <radialGradient id="gradient3" fx=".1" fy=".1">
                    <stop style="stop-color:white" offset=".1"/>
                    <stop style="stop-color:red" offset="1"/>
                </radialGradient>
                <!-- Draw one bar for entry-->
                <xsl:for-each select="entry">
                    <!-- Select the gradient. -->
                    <xsl:variable name="gradient-index" select="(position() mod 3) + 1"/>
                    <!-- Maps the position into a name of the month.-->
                    <xsl:variable name="month">
                        <xsl:choose>
                            <xsl:when test="position() = 1">january</xsl:when>
                            <xsl:when test="position() = 2">february</xsl:when>
                            <xsl:when test="position() = 3">march</xsl:when>
                            <xsl:when test="position() = 4">april</xsl:when>
                            <xsl:when test="position() = 5">may</xsl:when>
                            <xsl:when test="position() = 6">june</xsl:when>
                            <xsl:when test="position() = 7">july</xsl:when>
                            <xsl:when test="position() = 8">august</xsl:when>
                            <xsl:when test="position() = 9">september</xsl:when>
                            <xsl:when test="position() = 10">october</xsl:when>
                            <xsl:when test="position() = 11">november</xsl:when>
                            <xsl:when test="position() = 12">december</xsl:when>
                            <xsl:otherwise>blue</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <!-- Defines the gradient -->
                    <xsl:variable name="grad">gradient<xsl:value-of select="$gradient-index"/>
                    </xsl:variable>
                    <xsl:variable name="x-offset" select="76 + (position() * 60)"/>
                    <xsl:variable name="y-offset" select="261"/>
                    <!-- Calculate height of bar for a specific entry-->
                    <xsl:variable name="y" select="$y-offset - sum(text())"/>
                    <!-- The bar uses the gradient-->
                    <path d="M {$x-offset - 20} {$y-offset} L {$x-offset - 20} {$y} L {$x-offset + 20} {$y} L {$x-offset + 20} {$y-offset} Z">
                        <xsl:attribute name="style" xml:space="preserve">stroke-width:2; stroke:black; fill:url(#<xsl:value-of select="$grad"/>)</xsl:attribute>
                    </path>
                    <!-- Bottom of bar -->
                    <text style="text-anchor:middle" x="{$x-offset}" y="280" font-family="Dialog"> 
                        <xsl:value-of select="$month"/>
                    </text>
                </xsl:for-each>
            </g>
        </svg>
    </xsl:template>
</xsl:stylesheet>
