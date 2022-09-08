<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:x="com.elovirta.ooxml"
  exclude-result-prefixes="x xs" version="2.0">

  <xsl:variable name="x:block-content-classes" as="xs:string*"
    select="
      (
      ' topic/body ',
      ' topic/abstract ',
      ' topic/note ',
      ' topic/fig ',
      ' topic/fn ',
      (:' topic/figgroup ',:)
      ' topic/li ',
      ' topic/sli ',
      (:' topic/dt ',:)
      ' topic/dd ',
      ' topic/itemgroup ',
      ' topic/draft-comment ',
      ' topic/section ',
      ' topic/sectiondiv ',
      ' topic/div ',
      ' topic/lq ',
      ' topic/entry ',
      ' topic/stentry ',
      ' topic/example ')"/>

  <!-- Test if element can contain only block content -->
  <xsl:function name="x:block-content" as="xs:boolean">
    <xsl:param name="element" as="node()"/>
    <xsl:variable name="class" select="string($element/@class)" as="xs:string"/>
    <xsl:sequence
      select="
        some $c in $x:block-content-classes
          satisfies contains($class, $c)"
    />
  </xsl:function>

  <xsl:variable name="x:is-block-classes" as="xs:string*"
    select="
      (
      ' topic/body ',
      ' topic/bodydiv ',
      ' topic/shortdesc ',
      ' topic/abstract ',
      ' topic/title ',
      ' task/info ',
      ' topic/p ',
      ' topic/pre ',
      ' topic/note ',
      ' topic/fig ',
      (:' topic/figgroup ',:) ' pr-d/fragment ', ' pr-d/fragref ', (:' pr-d/groupchoice ', ' pr-d/groupcomp ', ' pr-d/groupseq ',:) ' pr-d/synblk ', ' pr-d/synnote ', ' pr-d/synnoteref ',
      ' topic/dl ',
      ' topic/sl ',
      ' topic/ol ',
      ' topic/ul ',
      ' topic/li ',
      ' topic/sli ',
      ' topic/lines ',
      ' topic/itemgroup ',
      ' topic/section ',
      ' topic/sectiondiv ',
      ' topic/div ',
      ' topic/lq ',
      ' topic/table ',
      ' topic/entry ',
      ' topic/simpletable ',
      ' topic/stentry ',
      ' topic/example ',
      ' task/cmd ')"/>

  <!-- Test is element is block -->
  <xsl:function name="x:is-block" as="xs:boolean">
    <xsl:param name="element" as="node()"/>
    <xsl:variable name="class" select="string($element/@class)" as="xs:string"/>
    <xsl:sequence
      select="
        some $c in $x:is-block-classes
          satisfies contains($class, $c) or
          (contains($class, ' topic/image ') and $element/@placement = 'break')"
    />
  </xsl:function>

  <xsl:template match="/">
    <xsl:apply-templates select="node()" mode="flatten"/>
  </xsl:template>

  <xsl:template match="@* | node()" mode="flatten" priority="-1000">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="flatten"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template
    match="
      *[contains(@class, ' task/step ') or
      contains(@class, ' task/substep ')]"
    mode="flatten" priority="100">
    <xsl:copy>
      <xsl:apply-templates select="@* | *" mode="flatten"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/p ')]" mode="flatten" name="flatten.p"
    priority="100">
    <xsl:choose>
      <xsl:when test="empty(node())"/>
      <xsl:when
        test="
          count(*) eq 1 and
          (*[contains(@class, ' topic/note ') or x:block-content(.)]) and
          empty(text()[normalize-space(.)])">
        <xsl:apply-templates mode="flatten"/>
      </xsl:when>
      <xsl:when test="descendant::*[x:is-block(.)]">
        <xsl:variable name="current" select="." as="element()"/>
        <xsl:for-each-group select="node()" group-adjacent="x:is-block(.)">
          <xsl:choose>
            <xsl:when test="current-grouping-key()">
              <xsl:apply-templates select="current-group()" mode="flatten"/>
            </xsl:when>
            <xsl:when
              test="count(current-group()) eq 1 and current-group()/self::text() and not(normalize-space(current-group()))"/>
            <xsl:otherwise>
              <xsl:for-each select="$current">
                <xsl:copy>
                  <xsl:apply-templates select="@* except @id | current-group()" mode="flatten"/>
                </xsl:copy>
              </xsl:for-each>
              <!--p class="- topic/p ">
                <xsl:apply-templates select="$current/@* except $current/@id | current-group()" mode="flatten"/>
              </p-->
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each-group>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@* | node()" mode="flatten"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' task/cmd ')]" mode="flatten" priority="100">
    <xsl:call-template name="flatten.p"/>
  </xsl:template>

  <!-- wrapper elements -->
  <xsl:template match="*[x:block-content(.)]" mode="flatten" priority="10">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="flatten"/>
      <xsl:for-each-group select="node()" group-adjacent="x:is-block(.)">
        <xsl:choose>
          <xsl:when test="current-grouping-key()">
            <xsl:apply-templates select="current-group()" mode="flatten"/>
          </xsl:when>
          <xsl:when
            test="count(current-group()) eq 1 and current-group()/self::text() and not(normalize-space(current-group()))"/>
          <xsl:otherwise>
            <p class="- topic/p ">
              <xsl:apply-templates select="current-group()" mode="flatten"/>
            </p>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
