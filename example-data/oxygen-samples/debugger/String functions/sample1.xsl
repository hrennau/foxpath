<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:    String functions
     Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    This stylesheet demonstrates a situation where some arguments are out of range 
       or they are not integrals. The returned substring contains those characters for which the position
       of the character is greater than or equal to the second argument and, if the third argument is specified,
       less than the sum of the second and third arguments. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <DIV>
            <B>
                <xsl:text>Text from position </xsl:text>
                <xsl:value-of select="//start * -1"/>
                <xsl:text>: </xsl:text>
            </B>
            <xsl:value-of select="substring(//text,//start * -1)"/>
        </DIV>
        <DIV>
            <B>
                <xsl:text>Text from position </xsl:text>
                <xsl:value-of select="//start + 0.45"/>
                <xsl:text>: </xsl:text>
            </B>
            <xsl:value-of select="substring(//text,//start + 0.45)"/>
        </DIV>
        <DIV>
            <B>
                <xsl:text>Text from position </xsl:text>
                <xsl:value-of select="//start *-2"/>
                <xsl:text> of length </xsl:text>
                <xsl:value-of select="//end *1.5"/>
                <xsl:text>: </xsl:text>
            </B>
            <xsl:value-of select="substring(//text,//start * -2,//end * 1.5)"/>
        </DIV>
        <DIV>
            <B>
                <xsl:text>Text from position </xsl:text>
                <xsl:value-of select="//start + 0.4"/>
                <xsl:text> of length </xsl:text>
                <xsl:value-of select="//end div 10 + 0.7"/>
                <xsl:text>: </xsl:text>
            </B>
            <xsl:value-of select="substring(//text,//start + 0.4,//end div 10 + 0.7)"/>
        </DIV>
        <DIV>
            <B>
                <xsl:text>Text from position </xsl:text>
                <xsl:value-of select="//start + 0.4"/>
                <xsl:text> of length </xsl:text>
                <xsl:value-of select="//end div 10 + 0.2"/>
                <xsl:text>: </xsl:text>
            </B>
            <xsl:value-of select="substring(//text,//start + 0.4,//end div 10 + 0.2)"/>
        </DIV>
    </xsl:template>
</xsl:stylesheet>
