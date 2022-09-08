<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="xs xd"
  version="2.0">

 <xsl:character-map name="chars-127to160">
    <!-- Map characters 127 to 160, which are invalid HTML characters
         but valid (but non-printing Unicode characters). Characters in this
         range seem to be a side effect of differences between Windows codepage
         1252 and ISO-8859-1 (see http://stackoverflow.com/questions/631406/what-is-the-difference-between-em-dash-151-and-8212)
       -->
    <xsl:output-character character="&#x9;" string="&#x0a;"/><!-- \t (tab) x9 -->
    <xsl:output-character character="&#127;" string="''"/><!-- Control character (delete), no mapping -->
    <xsl:output-character character="&#128;" string="&#x20AC;"/><!-- € x80 -->
   <!-- NOTE: CP 1252 does not have a character 129 -->
    <xsl:output-character character="&#130;" string="&#x201A;"/><!-- ‚ x82 -->
    <xsl:output-character character="&#131;" string="&#x0192;"/><!-- ƒ x83 -->
    <xsl:output-character character="&#132;" string="&#x201E;"/><!-- „ x84 -->
    <xsl:output-character character="&#133;" string="&#x2026;"/><!-- … x85 -->
    <xsl:output-character character="&#134;" string="&#x2020;"/><!-- † x86 -->
    <xsl:output-character character="&#135;" string="&#x2021;"/><!-- ‡ x87 -->
    <xsl:output-character character="&#136;" string="&#x02C6;"/><!-- ˆ x88 -->
    <xsl:output-character character="&#137;" string="&#x2030;"/><!-- ‰ x89 -->
    <xsl:output-character character="&#138;" string="&#x0160;"/><!-- Š x8A -->
    <xsl:output-character character="&#139;" string="&#x2039;"/><!-- ‹ x8B -->
    <xsl:output-character character="&#140;" string="&#x0152;"/><!-- Œ x8C -->
    <xsl:output-character character="&#142;" string="&#x017D;"/><!-- Ž x8E -->
    <xsl:output-character character="&#145;" string="&#x2018;"/><!-- ‘ x91 -->
    <xsl:output-character character="&#146;" string="&#x2019;"/><!-- ’ x92 -->
    <xsl:output-character character="&#147;" string="&#x201C;"/><!-- “ x93 -->
    <xsl:output-character character="&#148;" string="&#x201D;"/><!-- ” x94 -->
    <xsl:output-character character="&#149;" string="&#x2022;"/><!-- • x95-->
    <xsl:output-character character="&#150;" string="&#x2013;"/><!-- – x96 -->
    <xsl:output-character character="&#151;" string="&#x2014;"/><!-- — x97 -->
    <xsl:output-character character="&#152;" string="&#x02DC;"/><!-- ˜ x98 -->
    <xsl:output-character character="&#153;" string="&#x2122;"/><!-- ™ x99 -->
    <xsl:output-character character="&#154;" string="&#x0161;"/><!-- š x9A -->
    <xsl:output-character character="&#155;" string="&#x203A;"/><!-- › x9B -->
    <xsl:output-character character="&#156;" string="&#x0153;"/><!-- œ x9C -->
    <xsl:output-character character="&#157;" string="''"/><!-- Control character, no equivalent -->
    <xsl:output-character character="&#158;" string="&#x017E;"/><!-- ž x9E -->
    <xsl:output-character character="&#159;" string="&#x0178;"/><!-- Ÿ x9F -->
  </xsl:character-map>

</xsl:stylesheet>
