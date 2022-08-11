<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

  <xsl:variable name="xlsx_file_uri">zip:<xsl:value-of select="resolve-uri('Website_stats.xlsx', base-uri())"/>!</xsl:variable>
  <xsl:variable name="sheet1_uri" select="concat($xlsx_file_uri, '/xl/worksheets/sheet1.xml')"/>
  <xsl:variable name="chart1_uri" select="concat($xlsx_file_uri, '/xl/charts/chart1.xml')"/>

  <xsl:template match="/">
    <xsl:result-document href="{$sheet1_uri}">
      <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
        xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
        <dimension ref="B3:D9"/>
        <sheetViews>
          <sheetView tabSelected="1" workbookViewId="0">
            <selection activeCell="C2" sqref="C2"/>
          </sheetView>
        </sheetViews>
        <sheetFormatPr defaultRowHeight="15"/>
        <cols>
          <col min="2" max="2" width="9.5703125" bestFit="1" customWidth="1"/>
          <col min="3" max="3" width="15.85546875" customWidth="1"/>
          <col min="4" max="5" width="13" customWidth="1"/>
        </cols>
        <sheetData>

          <row r="3" spans="2:4" ht="26.25">
            <c r="C3" s="1" t="s">
              <v>0</v>
            </c>
          </row>
          <row r="6" spans="2:4">
            <c r="B6" t="s">
              <v>1</v>
            </c>
            <c r="C6" t="s">
              <v>2</v>
            </c>
            <c r="D6" t="s">
              <v>3</v>
            </c>
          </row>

          <xsl:for-each select="root/row">
            <xsl:variable name="pos" select="position() + 6"/>
            <row r="{$pos}">
              <c r="B{$pos}" t="str">
                <v>
                  <xsl:value-of select="substring-after(@DAY, '2008-')"/>
                </v>
              </c>
              <c r="C{$pos}">
                <v>
                  <xsl:value-of select="@UNIQUE_VISITORS"/>
                </v>
              </c>
              <c r="D{$pos}">
                <v>
                  <xsl:value-of select="@VISITORS"/>
                </v>
              </c>
            </row>
          </xsl:for-each>

        </sheetData>
        <pageMargins left="0.7" right="0.7" top="0.75" bottom="0.75" header="0.3" footer="0.3"/>
        <pageSetup orientation="portrait" horizontalDpi="4294967293" verticalDpi="0" r:id="rId1"/>
        <drawing r:id="rId2"/>
      </worksheet>
    </xsl:result-document>
    <xsl:call-template name="changeChartRange">
      <xsl:with-param name="range1">Sheet1!$C$7:$C$<xsl:value-of select="count(root/row) + 6"/></xsl:with-param>
      <xsl:with-param name="range2">Sheet1!$D$7:$D$<xsl:value-of select="count(root/row) + 6"
      /></xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="changeChartRange">
    <xsl:param name="range1"/>
    <xsl:param name="range2"/>

    <xsl:result-document href="{$chart1_uri}">
      <c:chartSpace xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart"
        xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
        xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
        <c:lang val="en-US"/>
        <c:chart>
          <c:plotArea>
            <c:layout>
              <c:manualLayout>
                <c:layoutTarget val="inner"/>
                <c:xMode val="edge"/>
                <c:yMode val="edge"/>
                <c:x val="9.2821741032370952E-2"/>
                <c:y val="6.9919072615923006E-2"/>
                <c:w val="0.73970734908136482"/>
                <c:h val="0.79822506561679785"/>
              </c:manualLayout>
            </c:layout>
            <c:barChart>
              <c:barDir val="col"/>
              <c:grouping val="clustered"/>
              <c:ser>
                <c:idx val="0"/>
                <c:order val="0"/>
                <c:val>
                  <c:numRef>
                    <c:f>
                      <xsl:value-of select="$range1"/>
                    </c:f>
                  </c:numRef>
                </c:val>
              </c:ser>
              <c:ser>
                <c:idx val="1"/>
                <c:order val="1"/>
                <c:val>
                  <c:numRef>
                    <c:f>
                      <xsl:value-of select="$range2"/>
                    </c:f>
                  </c:numRef>
                </c:val>
              </c:ser>
              <c:axId val="48880640"/>
              <c:axId val="43205376"/>
            </c:barChart>

            <c:catAx>
              <c:axId val="48880640"/>
              <c:scaling>
                <c:orientation val="minMax"/>
              </c:scaling>
              <c:axPos val="b"/>
              <c:tickLblPos val="nextTo"/>
              <c:crossAx val="43205376"/>
              <c:crosses val="autoZero"/>
              <c:auto val="1"/>
              <c:lblAlgn val="ctr"/>
              <c:lblOffset val="100"/>
            </c:catAx>
            <c:valAx>
              <c:axId val="43205376"/>
              <c:scaling>
                <c:orientation val="minMax"/>
              </c:scaling>
              <c:axPos val="l"/>
              <c:majorGridlines/>
              <c:numFmt formatCode="General" sourceLinked="1"/>
              <c:tickLblPos val="nextTo"/>
              <c:crossAx val="48880640"/>
              <c:crosses val="autoZero"/>
              <c:crossBetween val="between"/>
            </c:valAx>
            <c:spPr>
              <a:ln cmpd="sng"/>
            </c:spPr>
          </c:plotArea>
          <c:plotVisOnly val="1"/>
        </c:chart>
      </c:chartSpace>

    </xsl:result-document>
  </xsl:template>
</xsl:stylesheet>
