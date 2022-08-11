<?xml version="1.0" encoding="UTF-8" ?>
<!--    Category:    String functions
    Sample from Zvon XSLT tutorial (www.zvon.org)  
    Description:    The translate function returns the first argument string with occurrences of characters 
        in the second argument string replaced by the character at the corresponding position in the third argument string. 
        If a character occurs more than once in second argument string, then the first occurrence determines
        the replacement character. If the third argument string is longer than the second argument string, then excess characters are ignored. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <P>
            <xsl:value-of select="//text"/>
        </P>
        <P>
            <xsl:value-of select="translate(//text,'egos','EGOS')"/>
        </P>
        <P>
            <xsl:value-of select="translate(//text,'se','d')"/>
        </P>
        <P>
            <xsl:value-of select="translate(//text,'gseo','bad')"/>
        </P>
        <P>
            <xsl:value-of select="translate(//text,'gseg','bksC')"/>
        </P>
    </xsl:template>
</xsl:stylesheet>
