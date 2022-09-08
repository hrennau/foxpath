<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:lc="urn:function:learningContent"
  xmlns:random="http://exslt.org/random"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  exclude-result-prefixes="xs xd lc random"
  version="2.0">
  <!-- ========================================================
        Learning Domain (questions and answers) XSL-FO generation.
        
        Provides base support for generating HTML from the 
        learning1 (DITA 1.2) and learning2 (DITA 1.3)
        interactions.
        
        Extension points:
        
        - The named template lcGetQuestionNumber generates the numbers
          for questions and implements the lc-number-questions
          parameter. You can extend or override this template to
          control how numbers are generated and formatted.
          
        
        NOTE: variables named "lc:doXXX" are global booleans set from
              global parameters. Tunnel parameters named "lc:xxx" where
              "xxx" is the same as "XXX" from the "lc:doXXX" parameter, 
              allow overriding of the global default from calling templates.
              This lets you override the handling of any element that contains
              interactions in order to change details, such as showing
              feedback or only showing correct answers (e.g., generating
              an answer key from questions also shown as full questions
              in another context).
  
  ======================================================== -->
  
  <!-- Control how questions are numbered. Values are:
    
       - true/yes/on/1  : Number questions sequentially within the scope of
         their direct parent container. This is the default. Same as
         "within-parent" option.
         
       - false/no/off/0  : Do not number questions.
         
       - within-parent  : Number the questions sequentially within the scope
         of their direct parent container.
         
       - within-topic   : Number the questions sequentially within the scope
         of the topic that contains them.
         
       - within-chapter : Number the questions sequentially within the scope
         of the top-level topic ("chapter") that contains them. Bookmap and
         pubmap part topics do not count as chapters.
         
       - within-publication: Number the questions sequentially through
         the entire publication.
         
   -->
  <xsl:param name="lc-number-questions" as="xs:string" select="'true'"/>
  <xsl:variable name="lc:doNumberQuestions" as="xs:boolean" 
    select="matches($lc-number-questions, '1|yes|true|on', 'i')"
  />
  
  <!-- Display only the feedback for a question, not the question (prompt)
       or any answer option content. This option lets you generate an
       answer key that has just answer option labels and feedback.
       
       Default is "no" (show other stuff in addition to feedback)
       
       If this is set to true, it implies lc-show-feedback.
    -->
  <xsl:param name="lc-show-only-feedback" as="xs:string" select="'no'"/>
  <xsl:variable name="lc:doShowOnlyFeedback" as="xs:boolean"
    select="matches($lc-show-only-feedback, '1|yes|true|on', 'i')"
  />

  <!-- When set on, show feedback for answer options and entire questions
       in the output.  Default is "false" (suppress feedback).
    -->
  <xsl:param name="lc-show-feedback" as="xs:string" select="'false'"/>
  <xsl:variable name="lc:doShowFeedback" as="xs:boolean" 
    select="matches($lc-show-feedback, '1|yes|true|on', 'i') or 
            $lc:doShowOnlyFeedback"
  />
  
  <!-- When set on, adds a class value to correct answer options to allow highlighting
       them using CSS. Default is "true"
    -->
  <xsl:param name="lc-style-correct-responses" as="xs:string" select="'true'"/>
  <xsl:variable name="lc:doStyleCorrectResponses" as="xs:boolean" 
    select="matches($lc-style-correct-responses, '1|yes|true|on', 'i')"
  />
  
  <!-- Default format string to use fordoShow generating question numbers. This
       value will be used by the xsl:number @format attribute.
    -->
  <xsl:param name="lc-question-number-format" as="xs:string" select="'1.'"/>

  <!-- Static prefix to put before question numbers. Default is "Q ". -->
  <xsl:param name="lc-question-number-prefix" as="xs:string" select="'Q '"/>

  <!-- Static suffix to put after question numbers. Default is " " (Single space). -->
  <xsl:param name="lc-question-number-suffix" as="xs:string" select="' '"/>
  
  <!-- Number format specification for answers options within an answer option group.
       
       Default is to number from A to D.
  -->
  <xsl:param name="lc-answer-option-number-format" as="xs:string" select="'A.'"/>
  
  <!-- Display only the question label and number (if numbered) and any 
       correct answers. Display of feedback is controlled through the
       separate lc-show-feedback parameter.
              
       Default is "no" (show whole question)
       
       NOTE: This option would only be used globally when producing
       a standalone answer-key publication. The corresponding 
       template-level parameter can be used from custom code
       to control this behavior dynamically within a single publication.
  -->
  <xsl:param name="lc-show-only-correct-answer" as="xs:string" select="'no'"/>
  <xsl:variable name="lc:doShowOnlyCorrectAnswer" as="xs:boolean"
    select="matches($lc-show-only-correct-answer, '1|yes|true|on', 'i')"
  />

  <xsl:param name="lc-hide-question-labels" as="xs:string" select="'no'"/>
  <xsl:variable name="lc:doShowQuestionLabels" as="xs:boolean"
    select="not(matches($lc-hide-question-labels, '1|yes|true|on', 'i'))"
  />

  <!-- Turn on debugging for the learning domain processing -->
  <xsl:param name="lc-debug" as="xs:string" select="'no'"/>
  <xsl:variable name="lc:doDebug" as="xs:boolean"
    select="matches($lc-debug, '1|yes|true|on', 'i')"
  />


  
  <xsl:variable name="lc:baseBlockTypes" as="xs:string*"
     select="('dl',
              'fig',
              'image',
              'lines',
              'lq',
              'note',
              'object',
              'ol',
              'p',
              'pre',
              'simpletable',
              'sl',
              'table',
              'ul',
              'shortdesc')"
  />

    
  <!-- ===================================
       Attribute sets for interactions
       =================================== -->
  
  <xsl:attribute-set name="lc-feedback" use-attribute-sets="common.block">
    
  </xsl:attribute-set>
  
  <xsl:attribute-set name="lc-answer-option-group">
    <xsl:attribute name="provisional-distance-between-starts" select="'14pt'"/>
    <xsl:attribute name="provisional-label-separation" select="'4pt'"/>
  </xsl:attribute-set>
  <xsl:attribute-set name="lc-answer-option-item"
     use-attribute-sets="common.block"
    >
    <xsl:attribute name="color" select="'from-parent()'"/>
  </xsl:attribute-set>
  <xsl:attribute-set name="lc-answer-option-item-correct"     
    >
    <xsl:attribute name="color" select="'blue'"/>
  </xsl:attribute-set>
  <xsl:attribute-set name="lc-answer-option-label">
    
  </xsl:attribute-set>
  <xsl:attribute-set name="lc-answer-option-body">
    
  </xsl:attribute-set>
  <xsl:attribute-set name="lc-answer-option-label-cell">
    
  </xsl:attribute-set>
  <xsl:attribute-set name="lc-item" use-attribute-sets="common.block">
    
  </xsl:attribute-set>
  <xsl:attribute-set name="lc-matching-item" use-attribute-sets="common.block">
    
  </xsl:attribute-set>
  <xsl:attribute-set name="lc-MatchingItem-blank">
    
  </xsl:attribute-set>
  <xsl:attribute-set name="lc-hotspot-map">
    
  </xsl:attribute-set>
  <xsl:attribute-set name="lc-hotspot-feedback" use-attribute-sets="lc-feedback">
    
  </xsl:attribute-set>
  <xsl:attribute-set name="lc-hotspot-area-feedback" use-attribute-sets="lc-feedback">
    
  </xsl:attribute-set>
  <xsl:attribute-set name="lc-area-feedback-label">
    
  </xsl:attribute-set>
  <xsl:attribute-set name="lc-interaction-wrapper">
    
  </xsl:attribute-set>
  <xsl:attribute-set name="lc-interaction-label">
    <xsl:attribute name="font-weight" select="'bold'"/>
  </xsl:attribute-set>
  <xsl:attribute-set name="lcQuestionText">
    
  </xsl:attribute-set>
  <xsl:attribute-set name="lc-question" use-attribute-sets="common.block">
    
  </xsl:attribute-set>
  <xsl:attribute-set name="lc-answer-content" use-attribute-sets="common.block">
    
  </xsl:attribute-set>
  <xsl:attribute-set name="lcQuestionNumber">
    <xsl:attribute name="font-weight" select="'bold'"/>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="lc-matchTable-col-answerItemLabel">
    <xsl:attribute name="column-width" select="'4em'"/>
  </xsl:attribute-set>
    
  <xsl:attribute-set name="lc-matchTable-col-item">
    <xsl:attribute name="column-width" select="'50%'"/>    
  </xsl:attribute-set>
  <xsl:attribute-set name="lc-matchTable-col-matchItem">
    <xsl:attribute name="column-width" select="'50%'"/>        
  </xsl:attribute-set>
  

  <!-- ===================================
       End of attribute sets
       =================================== -->
  
  <xsl:template match="*[contains(@class, ' learningInteractionBase2-d/lcInteractionBase2 ')]" priority="100">
    <xsl:param name="lc:doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:param name="lc:numberQuestions" as="xs:boolean" tunnel="yes" select="$lc:doNumberQuestions"/>
    <xsl:param name="lc:showOnlyFeedback" as="xs:boolean" tunnel="yes"  select="$lc:doShowOnlyFeedback"/>
    <xsl:param name="lc:showFeedback" as="xs:boolean" tunnel="yes" 
      select="$lc:doShowFeedback or $lc:showOnlyFeedback"/>
    <xsl:param name="lc:styleCorrectResponses" as="xs:boolean" tunnel="yes" select="$lc:doStyleCorrectResponses"/>
    <xsl:param name="lc:showOnlyCorrectAnswer" as="xs:boolean" tunnel="yes" select="$lc:doShowOnlyCorrectAnswer"/>
    <xsl:param name="lc:showQuestionLabels" as="xs:boolean" tunnel="yes" select="$lc:doShowQuestionLabels"/>
    
    <!-- This template is here mostly to enable debugging the learning-specific parameters. -->
    
    <xsl:next-match/>
    
  </xsl:template>
  
  <!-- =====================
       True/False
       ===================== -->
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcTrueFalse2 ')] |
                       *[contains(@class, ' learning-d/lcTrueFalse ')]">
    <xsl:param name="lc:doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:call-template name="constructInteraction"/>    
  </xsl:template>
    
   
  <!-- There are several different ways commonly used to present true/false questions:
    
        T   F     1. This is the question
        
        
        1. This is the question
           
           A. True
           B. False
           
        1. This is the question (T/F is not reflected anywhere, maybe because there's a separate answer sheet)
        
        For simplicity, using the second form, which makes it the same as single and multiple-select 
        questions.
     -->
  
  <!-- =====================
       Single Select
       ===================== -->
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcSingleSelect2 ')] |
                       *[contains(@class, ' learning-d/lcSingleSelect ')]">
    <xsl:param name="lc:doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:call-template name="constructInteraction"/>    
  </xsl:template>
  
  <!-- =====================
       Answer Option Group
       ===================== -->
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcAnswerOptionGroup2 ')] |
                       *[contains(@class, ' learning-d/lcAnswerOptionGroup ')]">
    <xsl:param name="lc:doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- NOTE: The attribute set must set the @provisional-distance-between-starts attribute -->
    <fo:list-block xsl:use-attribute-sets="lc-answer-option-group">
      <xsl:apply-templates/>
    </fo:list-block>
  </xsl:template>

   
  <xsl:template match="*[contains(@class, ' learning2-d/lcAnswerOption2 ')] |
                       *[contains(@class, ' learning-d/lcAnswerOption ')]">
    <xsl:param name="lc:doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="lc:showOnlyCorrectAnswer" as="xs:boolean" tunnel="yes"
      select="$lc:doShowOnlyCorrectAnswer"
    />
    <xsl:param name="lc:showOnlyFeedback" as="xs:boolean" tunnel="yes"
       select="$lc:doShowOnlyFeedback"
    />
    <xsl:param name="lc:styleCorrectResponses" as="xs:boolean" tunnel="yes" 
      select="$lc:doStyleCorrectResponses"
    />
    <xsl:param name="topicref" as="element()" select="." tunnel="yes"/>    
    
    <xsl:if test="$lc:doDebug">
      <xsl:message> + [DEBUG] lcAnswerOption:  <xsl:value-of select="substring(., 1, 20)"/></xsl:message>
      <xsl:message> + [DEBUG] lcAnswerOption:    topicref=<xsl:sequence select="$topicref"/></xsl:message>
      <xsl:message> + [DEBUG] lcAnswerOption:    lc:doDebug=<xsl:value-of select="$lc:doDebug"/></xsl:message>
      <xsl:message> + [DEBUG] lcAnswerOption:    lc:showOnlyFeedback=<xsl:value-of select="$lc:showOnlyFeedback"/></xsl:message>
      <xsl:message> + [DEBUG] lcAnswerOption:    lc:showOnlyCorrectAnswer=<xsl:value-of select="$lc:showOnlyCorrectAnswer"/></xsl:message>
      <xsl:message> + [DEBUG] lcAnswerOption:    lc:styleCorrectResponses=<xsl:value-of select="$lc:styleCorrectResponses"/></xsl:message>
    </xsl:if>
    
    <xsl:choose>
      <xsl:when test="$lc:showOnlyCorrectAnswer and not(lc:isCorrectAnswer(.))">
        <!-- Do nothing: incorrect answers are suppressed when showOnlyCorrectAnswer is true -->
        <xsl:if test="$lc:doDebug">
          <xsl:message> + [DEBUG] lcAnswerOption: suppressing answer: showOnlyCorrectAnswer is true and
                                  not(lc:isCorrectAnswer(.))=<xsl:value-of select="not(lc:isCorrectAnswer(.))"/>
          </xsl:message>      
        </xsl:if>
      </xsl:when>
      <xsl:when test="($lc:showOnlyCorrectAnswer and lc:isCorrectAnswer(.)) or 
                       ($lc:showOnlyFeedback and 
                        (.//*[contains(@class, ' learning2-d/lcFeedback2 ') or 
                              contains(@class, ' learning-d/lcFeedback ')]))">
        <xsl:if test="$lc:doDebug">
          <xsl:message> + [DEBUG] lcAnswerOption: lc:showOnlyCorrectAnswer=true and lc:isCorrectAnswer(.))=<xsl:value-of select="not(lc:isCorrectAnswer(.))"/> or
                                  lc:showOnlyFeedback=true and there is feedback
                                  
                                  Showing a correct answer, either the whole answer or just
                                  the feedback.
          </xsl:message>
        </xsl:if>
        
        <fo:list-item xsl:use-attribute-sets="lc-answer-option-item lc-answer-option-item-correct">
          <fo:list-item-label xsl:use-attribute-sets="lc-answer-option-label" 
                               end-indent="label-end()">   
            <fo:block>
              <xsl:apply-templates select="." mode="lc-set-answer-option-label"/>
            </fo:block>
          </fo:list-item-label>
          <fo:list-item-body 
              xsl:use-attribute-sets="lc-answer-option-body" 
              start-indent="body-start()">
            <fo:block>            
              <xsl:apply-templates select="if ($lc:showOnlyFeedback) 
                then (*[contains(@class, ' learning-d/lcFeedback ')] | 
                      *[contains(@class, ' learning2-d/lcFeedback2 ')])
                else node()"
              />
            </fo:block>
          </fo:list-item-body>
        </fo:list-item>
      </xsl:when>
      <xsl:when test="not($lc:showOnlyFeedback) or 
                      ($lc:showOnlyFeedback and 
                       (*[contains(@class, ' learning-d/lcFeedback ')] | 
                        *[contains(@class, ' learning2-d/lcFeedback2 ')]))">
        
        <xsl:if test="$lc:doDebug">
          <xsl:message> + [DEBUG] lcAnswerOption: Normal answer option processing. </xsl:message>      
          <xsl:message> + [DEBUG] answerOption: lx:isCorrectAnswer()=<xsl:value-of select="lc:isCorrectAnswer(.)"/></xsl:message>
        </xsl:if>
        
        <xsl:variable name="answerOptionContent" as="node()*">
          <fo:list-item-label xsl:use-attribute-sets="lc-answer-option-label" 
                               end-indent="label-end()">
            <fo:block>
            <xsl:apply-templates select="." mode="lc-set-answer-option-label"/>
            </fo:block>
          </fo:list-item-label>
          <fo:list-item-body xsl:use-attribute-sets="lc-answer-option-label" 
                               start-indent="body-start()">            
            <fo:block>
              <xsl:apply-templates/>
            </fo:block>
          </fo:list-item-body>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$lc:styleCorrectResponses and lc:isCorrectAnswer(.)">
            <fo:list-item xsl:use-attribute-sets="lc-answer-option-item lc-answer-option-item-correct">
              <xsl:sequence select="$answerOptionContent"/>
            </fo:list-item>
          </xsl:when>
          <xsl:otherwise>
            <fo:list-item xsl:use-attribute-sets="lc-answer-option-item">
              <xsl:sequence select="$answerOptionContent"/>
            </fo:list-item>
          </xsl:otherwise>
        </xsl:choose>        
      </xsl:when>
      <xsl:otherwise>
        <!-- Must be show only feedback but there's no feedback. -->
        <xsl:if test="$lc:doDebug">
          <xsl:message> + [DEBUG] lcAnswerOption: No output, must be show-only-feedback but there's no feedback. </xsl:message>      
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="lc-set-answer-option-label" 
    match="*[contains(@class, ' learning2-d/lcAnswerOption2 ')] |
           *[contains(@class, ' learning-d/lcAnswerOption ')]">
      <fo:inline xsl:use-attribute-sets="lc-answer-option-label">
        <xsl:number count="*[contains(@class, ' learning2-d/lcAnswerOption2 ')] |
                           *[contains(@class, ' learning-d/lcAnswerOption ')]"
          format="{$lc-answer-option-number-format}"
          from="*[contains(@class, ' learning2-d/lcAnswerOptionGroup2 ')] |
                *[contains(@class, ' learning-d/lcAnswerOptionGroup ')]"
        /><xsl:text>&#xa0;</xsl:text>
      </fo:inline>
  </xsl:template>

  <!-- =====================
       Multiple Select
       ===================== -->
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcMultipleSelect2 ')] | 
                       *[contains(@class, ' learning-d/lcMultipleSelect ')]">
    <xsl:call-template name="constructInteraction"/>    
  </xsl:template>

  <!-- =====================
       Sequencing
       ===================== -->

  <xsl:template match="*[contains(@class, ' learning2-d/lcSequencing2 ')] |
                       *[contains(@class, ' learning-d/lcSequencing ')]">
    <xsl:call-template name="constructInteraction"/>
  </xsl:template>
  
  <!-- =====================
       Matching
       ===================== -->
  <xsl:template match="*[contains(@class, ' learning2-d/lcMatching2 ')] |
                       *[contains(@class, ' learning-d/lcMatching ')]">
    <xsl:call-template name="constructInteraction"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcMatchTable2 ')] | 
                       *[contains(@class, ' learning-d/lcMatchTable ')]">
    <!-- Seed to use for generating a random number -->
    <xsl:variable name="seed"  as="xs:double"
      select="4.2"
    />
<!--    <xsl:message> + [DEBUG] matchTable: seed=<xsl:sequence select="$seed"/></xsl:message>-->

      <fo:table>
        <fo:table-column xsl:use-attribute-sets="lc-matchTable-col-answerItemLabel"/>
        <fo:table-column xsl:use-attribute-sets="lc-matchTable-col-item"/>
        <fo:table-column xsl:use-attribute-sets="lc-matchTable-col-matchItem"/>
      
      <xsl:variable name="matchFromItems" as="element()*"
        select="*[contains(@class, ' learning2-d/lcMatchingPair2 ')]/*[contains(@class, ' learning2-d/lcItem2 ')] | 
                *[contains(@class, ' learning-d/lcMatchingPair ')]/*[contains(@class, ' learning-d/lcItem ')]"
      />
      <xsl:variable name="matchToItems" as="element()*"
        select="*[contains(@class, ' learning2-d/lcMatchingPair2 ')]/*[contains(@class, ' learning2-d/lcMatchingItem2 ')] | 
                *[contains(@class, ' learning-d/lcMatchingPair ')]/*[contains(@class, ' learning-d/lcMatchingItem ')]"
      />
      <xsl:variable name="matchToItemsShuffled" as="element()*"
        select="lc:shuffleItems($matchToItems, (), $seed)"
      />
<!--      <xsl:message> + [DEBUG] matchTable: matchToItemsShuffled=<xsl:sequence select="$matchToItemsShuffled"/></xsl:message>-->
        <fo:table-body>
          <xsl:for-each select="$matchFromItems">
            <xsl:variable name="pos" as="xs:integer" select="position()"/>
            <fo:table-row>         
              <fo:table-cell xsl:use-attribute-sets="lc-answer-option-label-cell">
                <fo:block xsl:use-attribute-sets="lc-answer-option-label">
                  <xsl:number count="*[contains(@class, ' learning2-d/lcMatchingPair2 ')] |
                                     *[contains(@class, ' learning-d/lcMatchingPair ')]"
                    format="{$lc-answer-option-number-format}"
                    from="*[contains(@class, ' learning2-d/lcMatchTable2 ')] |
                          *[contains(@class, ' learning-d/lcMatchTable ')]"
                  /><xsl:text>&#xa0;</xsl:text>
                </fo:block>
              </fo:table-cell>
              <xsl:apply-templates select="."/>
              <xsl:apply-templates select="$matchToItemsShuffled[$pos]"/>
            </fo:table-row>
          </xsl:for-each>
        </fo:table-body>      
    </fo:table>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcItem2 ')] | 
                       *[contains(@class, ' learning-d/lcItem ')]">
    <fo:table-cell xsl:use-attribute-sets="lc-item">
      <fo:block>
        <xsl:apply-templates/>
      </fo:block>
    </fo:table-cell>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcMatchingItem2 ')] | 
                       *[contains(@class, ' learning-d/lcMatchingItem ')]">
    <fo:table-cell xsl:use-attribute-sets="lc-matching-item">
      <fo:block>
        <fo:inline xsl:use-attribute-sets="lc-MatchingItem-blank">___</fo:inline>     
        <xsl:apply-templates/>
      </fo:block>
    </fo:table-cell>
  </xsl:template>
  
  <!-- =====================
       Hotspot
       ===================== -->
  <xsl:template match="*[contains(@class, ' learning2-d/lcHotspot2 ')] |
                       *[contains(@class, ' learning-d/lcHotspot ')]">
    <xsl:call-template name="constructInteraction"/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcHotspotMap2 ')] |
                       *[contains(@class, ' learning-d/lcHotspotMap ')]">
    <xsl:variable name="mapId" as="xs:string" select="concat('hsMap-', generate-id(.))"/>
    <fo:block xsl:use-attribute-sets="lc-hotspot-map">
      <xsl:apply-templates select="*[contains(@class, ' topic/image ')]">
        <xsl:with-param name="mapId" as="xs:string" tunnel="yes" select="$mapId"/>
      </xsl:apply-templates>
      <fo:block xsl:use-attribute-sets="lc-hotspot-feedback">
        <xsl:choose>
          <xsl:when 
            test="*/*[contains(@class, ' learning2-d/lcFeedback2 ')] |
                  */*[contains(@class, ' learning-d/lcFeedback ')]">
            <xsl:apply-templates mode="lc:hotspotFeedback"
              select="*[contains(@class, ' learning2-d/lcArea2 ')] |
                      *[contains(@class, ' learning-d/lcArea ')]">
              <!-- For hot spots we show the feedback if there're no xrefs in the areas -->
              <xsl:with-param name="lc:showFeedback" as="xs:boolean" tunnel="yes"                
                             select="true()"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="not(*[contains(@class, ' topic/xref ')])">
            <!-- No feedback and no xref, synthesize correct/incorrect feedback -->
            <xsl:apply-templates mode="lc:hotspotFeedbackSynthesize"
              select="*[contains(@class, ' learning2-d/lcArea2 ')] |
                      *[contains(@class, ' learning-d/lcArea ')]"/>
              
          </xsl:when>
          <xsl:otherwise>
            <!-- There must be feedback or an xref, nothing to do. -->
          </xsl:otherwise>
        </xsl:choose>
      </fo:block>
    </fo:block>
  </xsl:template>
  
  <xsl:template mode="lc:imagemap" 
    match="*[contains(@class, ' learning2-d/lcArea2 ')] |
           *[contains(@class, ' learning-d/lcArea ')]">
    <!-- WEK :Not sure what it do with areas in XSL-FO. Can probably 
         create links to the region but not trying to do that now.
      -->
  </xsl:template>
  
  <xsl:template mode="lc:set-area-href" 
    match="*[contains(@class, ' learning2-d/lcArea2 ')] |
           *[contains(@class, ' learning-d/lcArea ')]">
    <!-- Default template for setting the @href on the area. Override
         this template to link somewhere else.
      -->
    
    <xsl:variable name="targetUri" as="xs:string">
      <xsl:choose>
        <xsl:when test="*[contains(@class, ' topic/xref ')]">
          <!-- Use the xref's target URI -->
          <xsl:value-of select="'{xref in area not implemented}'"/>
        </xsl:when>
        <xsl:when test="*[contains(@class, ' learning2-d/lcFeedback2 ')] |
           *[contains(@class, ' learning-d/lcFeedback ')]">
          <xsl:sequence select="concat('#', lc:getLcAreaFeedbackId(.))"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- If there's no feedback or xref we generate a correct/incorrect feedback. -->
          <xsl:sequence select="concat('#', lc:getLcAreaFeedbackId(.))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="href" select="$targetUri"/>
    
  </xsl:template>

  <xsl:template mode="lc:set-attributes" match="text()"/><!-- Suppress all text -->
  
  <xsl:template mode="lc:set-attributes" 
    match="*[contains(@class, ' learning2-d/lcAreaShape2 ')] |
           *[contains(@class, ' learning-d/lcAreaShape ')]">
    <!-- WEK: Not sure what to do here, if anything -->
  </xsl:template>

  <xsl:template mode="lc:set-attributes" 
    match="*[contains(@class, ' learning2-d/lcAreaCoords2 ')] |
           *[contains(@class, ' learning-d/lcAreaCoords ')]">
    <!-- WEK: Not sure what to do here, if anything -->
  </xsl:template>

  <xsl:template mode="lc:hotspotFeedback" 
    match="*[contains(@class, ' learning2-d/lcArea2 ')] |
           *[contains(@class, ' learning-d/lcArea ')]">
    <fo:block id="{lc:getLcAreaFeedbackId(.)}" xsl:use-attribute-sets="lc-hotspot-area-feedback">
      <fo:block xsl:use-attribute-sets="lc-area-feedback-label">
        <xsl:apply-templates select="." mode="lc:hotspotAreaFeedbackLabel"/>
      </fo:block>
      <xsl:apply-templates 
        select="*[contains(@class, ' learning2-d/lcFeedback2 ')] |
                *[contains(@class, ' learning-d/lcFeedback ')]"/>
    </fo:block>
  </xsl:template>
  
  <xsl:template mode="lc:hotspotAreaFeedbackLabel" 
    match="*[contains(@class, ' learning2-d/lcArea2 ')] |
           *[contains(@class, ' learning-d/lcArea ')]">
    <xsl:text>Area </xsl:text>
    <xsl:number count="*[contains(@class, ' learning2-d/lcArea2 ')] |
           *[contains(@class, ' learning-d/lcArea ')]"
           level="single"
           from="*[contains(@class, ' learning2-d/lcHotspotMap2 ')] |
           *[contains(@class, ' learning-d/lcHotspotMap ')]"
           format="1"
    />
    <xsl:text>: </xsl:text>
  </xsl:template>

  <xsl:template mode="lc:hotspotFeedbackSynthesize" 
    match="*[contains(@class, ' learning2-d/lcArea2 ')] |
           *[contains(@class, ' learning-d/lcArea ')]">
    <fo:block id="{lc:getLcAreaFeedbackId(.)}" xsl:use-attribute-sets="lc-hotspot-area-feedback">
        <fo:inline xsl:use-attribute-sets="lc-area-feedback-label"><xsl:apply-templates select="." mode="lc:hotspotAreaFeedbackLabel"/></fo:inline>
        <xsl:choose>
          <xsl:when test="lc:isCorrectAnswer(.)">
            <xsl:text>Correct.</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Incorrect.</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
    </fo:block>
  </xsl:template>


  <xsl:template match="*[contains(@class, ' learning2-d/lcHotspotMap2 ')]/*[contains(@class, ' topic/image ')] |
                       *[contains(@class, ' learning-d/lcHotspotMap ')]/*[contains(@class, ' topic/image ')]">
    
    <xsl:next-match/>    
  </xsl:template>
  
  <xsl:template mode="addUsemapAtt" match="img" >
    <xsl:param name="mapId" as="xs:string" tunnel="yes"/>
    <xsl:copy>
      <xsl:attribute name="usemap" select="$mapId"/>
      <xsl:apply-templates mode="#current" select="@*,node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="addUsemapAtt" match="*" priority="-1">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@*,node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="addUsemapAtt" match="@* | text() | processing-instruction()" priority="-1">
    <xsl:sequence select="."/>
  </xsl:template>
  
  <!-- =====================
       Open question
       ===================== -->
  <xsl:template match="*[contains(@class, ' learning2-d/lcOpenQuestion2 ')] |
                       *[contains(@class, ' learning-d/lcOpenQuestion ')]">
    <xsl:call-template name="constructInteraction"/>    
  </xsl:template>
  
  <!-- =====================
       Fallback handling
       ===================== -->
  <xsl:template match="*[contains(@class, ' learningInteractionBase2-d/lcInteractionBase2 ')] |
                       *[contains(@class, ' learningInteractionBase-d/lcInteractionBase ')]"
      priority="-0.5"
    >
    <!-- Fallback handling for interactions -->
    <fo:block>
      <xsl:call-template name="commonattributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>
  
  <!-- ====================================================
       General interaction support templates and functions.
       ==================================================== -->
  
  <xsl:template name="constructInteraction">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="baseClass" as="xs:string*" select="lc:getBaseLcTypeForElement(.)"/>
    <xsl:param name="lc:numberQuestions" as="xs:boolean" tunnel="yes" select="$lc:doNumberQuestions"/>
    <xsl:param name="lc:showOnlyFeedback" as="xs:boolean" tunnel="yes" select="$lc:doShowOnlyFeedback"/>
    <xsl:param name="lc:showFeedback" as="xs:boolean" tunnel="yes" 
      select="$lc:doShowFeedback or $lc:showOnlyFeedback"/>
    <xsl:param name="lc:styleCorrectResponses" as="xs:boolean" tunnel="yes" select="$lc:doStyleCorrectResponses"/>
    <xsl:param name="lc:showOnlyCorrectAnswer" as="xs:boolean" tunnel="yes" select="$lc:doShowOnlyCorrectAnswer"/>
    <xsl:param name="lc:showQuestionLabels" as="xs:boolean" tunnel="yes" select="$lc:doShowQuestionLabels"/>
    
<!--    <xsl:variable name="doDebug" as="xs:boolean" select="true()"/>-->
    
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] constructInteraction: Starting...</xsl:message>
      <xsl:message> + [DEBUG]       lc:showOnlyFeedback=<xsl:value-of select="$lc:showOnlyFeedback"/></xsl:message>
    </xsl:if>

    <xsl:variable name="interactionContents" as="node()*">
    </xsl:variable>
    <fo:block xsl:use-attribute-sets="lc-interaction-wrapper">
      <xsl:call-template name="commonattributes"/>
      <xsl:if test="$lc:showQuestionLabels">
        <!-- NOTE: We have to put the control here because interactionLabel2 specializes
                   topic/p and if there are any higher-priority overrides to topic/p base processing
                   then our template for lcInteractionLabel2 will never match.
          -->
        <xsl:apply-templates 
            select="*[contains(@class, ' learningInteractionBase2-d/lcInteractionLabel2 ')]">
          <xsl:with-param name="lc:doDebug" as="xs:boolean" tunnel="yes" select="$lc:doDebug"/>
        </xsl:apply-templates>
      </xsl:if>
      <xsl:if test="not($lc:showOnlyCorrectAnswer or $lc:showOnlyFeedback)">
        <xsl:apply-templates 
          select="*[contains(@class, ' learningInteractionBase2-d/lcQuestionBase2 ')] |
                  *[contains(@class, ' learningInteractionBase-d/lcQuestionBase ')]"
        >
          <xsl:with-param name="lc:doDebug" as="xs:boolean" tunnel="yes" select="$lc:doDebug"/>
        </xsl:apply-templates>
      </xsl:if>
      <!-- The question options, whatever form they might take: -->
      <xsl:apply-templates 
        select="*[contains(@class, ' learning2-d/lcOpenAnswer2 ')] |
                *[contains(@class, ' learning-d/lcOpenAnswer ')] |
                *[contains(@class, ' learning2-d/lcAnswerOptionGroup2 ')] |
                *[contains(@class, ' learning-d/lcAnswerOptionGroup ')] |
                *[contains(@class, ' learning2-d/lcMatchTable2 ')] |
                *[contains(@class, ' learning-d/lcMatchTable ')] |
                *[contains(@class, ' learning2-d/lcHotspotMap2 ')] |
                *[contains(@class, ' learning-d/lcHotspotMap ')]"
      >
        <xsl:with-param name="lc:doDebug" as="xs:boolean" tunnel="yes" select="$lc:doDebug"/>
      </xsl:apply-templates>
    </fo:block>
  </xsl:template>
  
  <xsl:template match="lcInteractionLabel2 | *[contains(@class, ' learningInteractionBase2-d/lcInteractionLabel2 ')]" priority="100">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="lc:showQuestionLabels" as="xs:boolean" tunnel="yes" select="$lc:doShowQuestionLabels"/>
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] lcInteractionLabel2: lc:showQuestionLabels="<xsl:value-of select="$lc:showQuestionLabels"/>"</xsl:message>
    </xsl:if>

    <xsl:if test="$lc:showQuestionLabels">
      <fo:block xsl:use-attribute-sets="lc-interaction-label">
        <xsl:apply-templates/>
      </fo:block>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learningInteractionBase2-d/lcQuestionBase2 ')] |
                       *[contains(@class, ' learningInteractionBase-d/lcQuestionBase ')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:variable name="baseClass" as="xs:string*"
      select="concat(lc:getBaseLcTypeForElement(..), 'Question')"
    />
    <!-- For learning2, lcQuestionBase specializes <div> and may contain just text
         or block elements.
      -->
    <xsl:variable name="questionNumber" as="node()*">
      <xsl:call-template name="lcGetQuestionNumber"/>
    </xsl:variable>
    <fo:block xsl:use-attribute-sets="lc-question">
      <xsl:for-each-group select="*|text()[matches(.,'\S')]" group-adjacent="lc:isBlock(.)">
        <xsl:choose>
          <xsl:when test="position() = 1">
            <!-- Add the question number to the first block, whatever it is -->
            <xsl:choose>
              <xsl:when test="current-grouping-key() = true()">
                <!-- Block element -->
                <xsl:apply-templates select="." mode="lc:addQuestionNumberToBlock">
                  <xsl:with-param name="questionNumber" as="node()*" select="$questionNumber"/>
                </xsl:apply-templates>
                <xsl:apply-templates select="current-group()[position() > 1]"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="$questionNumber"/>
                <xsl:apply-templates select="current-group()"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </fo:block>
  </xsl:template>
  
  <xsl:template mode="lc:addQuestionNumberToBlock" match="*[contains(@class, ' topic/p ')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="questionNumber" as="node()*"/>
    <fo:block>
      <xsl:sequence select="$questionNumber"/>
      <xsl:apply-templates/>      
    </fo:block>
  </xsl:template>
  
  <xsl:template mode="lc:addQuestionNumberToBlock" match="*" priority="-1">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:message> + [WARN] lc:addQuestionNumberToBlock: Unhandled element <xsl:value-of select="concat(name(..), '/', name(.))"/></xsl:message>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' learning-d/lcAnswerContent ')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <fo:inline xsl:use-attribute-sets="lc-answer-content">
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcAnswerContent2 ')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <fo:inline xsl:use-attribute-sets="lc-answer-content">
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcFeedback2 ')] |
                       *[contains(@class, ' learning-d/lcFeedback ')] |
                       *[contains(@class, ' learning2-d/lcFeedbackCorrect2 ')] |
                       *[contains(@class, ' learning-d/lcFeedbackCorrect ')] |
                       *[contains(@class, ' learning2-d/lcOpenAnswer2 ')] |
                       *[contains(@class, ' learning-d/lcOpenAnswer ')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="lc:showOnlyFeedback" as="xs:boolean" tunnel="yes"
      select="$lc:doShowOnlyFeedback"
    />
    <xsl:param name="lc:showFeedback" as="xs:boolean" tunnel="yes"
      select="$lc:doShowFeedback or $lc:showOnlyFeedback"
    />
    
    <xsl:if test="$lc:showFeedback">
      <fo:block>
        <xsl:apply-templates select="." mode="lc:generate-feedback-label">
          <xsl:with-param 
            name="lc:showFeedback" 
            as="xs:boolean" 
            tunnel="yes" 
            select="$lc:showFeedback"
          />
        </xsl:apply-templates>
        <xsl:apply-templates/>
      </fo:block>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*" mode="lc:generate-feedback-label">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- No default feedback label. Implement templates in this mode to generate
         feedback labels.
      -->
  </xsl:template>
  
  <xsl:function name="lc:getBaseLcTypeForElement" as="xs:string*">
    <xsl:param name="elem" as="element()"/>
    
    <!-- + topic/div learningInteractionBase2-d/lcInteractionBase2 learning2-d/lcMultipleSelect2  -->
    <xsl:if test="count(tokenize($elem/@class, ' ')) lt 4">
      <xsl:message> + [WARN] getBaseLcTypeForElement(): @class value does not have the expected 4 tokens, got "<xsl:value-of select="$elem/@class"/>"</xsl:message>
    </xsl:if>

    <xsl:variable name="lcType" as="xs:string?"
      select="tokenize(tokenize($elem/@class, ' ')[4], '/')[2]"
    />
    <xsl:variable name="baseType" as="xs:string?"
      select="if (contains($lcType, '2')) 
                 then substring-before($lcType, '2')
                 else $lcType"
    />
   <xsl:sequence select="$baseType"/>
  </xsl:function>
 
  <xsl:function name="lc:hasBlockChildren" as="xs:boolean">
    <xsl:param name="context" as="element()"/>
    <xsl:sequence select="boolean($context[
      *[contains(@class, ' topic/p ')] |
      *[contains(@class, ' topic/ol ')] |
      *[contains(@class, ' topic/ul ')] |
      *[contains(@class, ' topic/sl ')] |
      *[contains(@class, ' topic/example ')] |
      *[contains(@class, ' topic/fig ')] |
      *[contains(@class, ' topic/figgroup ')] |
      *[contains(@class, ' topic/lines ')] |
      *[contains(@class, ' topic/note ')] |
      *[contains(@class, ' topic/pre ')] |
      *[contains(@class, ' topic/simpletable ')] |
      *[contains(@class, ' topic/table')]
      ])"/>
  </xsl:function>
  
  <xsl:function name="lc:isBlock" as="xs:boolean">
    <xsl:param name="context" as="node()"/>
    <xsl:variable name="result" as="xs:boolean">
      <xsl:choose>
          <xsl:when test="contains($context/@class, ' topic/')">
            <xsl:variable name="baseType"
              select="substring-after(tokenize($context/@class, ' ')[2], '/')"
            />
            <xsl:sequence select="$baseType = $lc:baseBlockTypes"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="false()"/>
          </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>  
    <xsl:sequence select="$result"/>
  </xsl:function>
  
  <xsl:function name="lc:getLcAreaFeedbackId" as="xs:string">
    <!-- Generates a unique ID to use for linking to the feedback associated with a hotspot area. -->
    <xsl:param name="areaElem" as="element()"/>
    <xsl:variable name="result" select="concat('lc-area-feedback_', generate-id($areaElem))"/>
    <xsl:sequence select="$result"/>
  </xsl:function>
  
  <xsl:function name="lc:isCorrectAnswer" as="xs:boolean">
    <!-- Returns true if the element is a correct response. 
         Context element must be an element that may directly contain
         an lcCorrectResponse element.
      -->
    <xsl:param name="context" as="element()"/>
    <xsl:variable name="result" as="xs:boolean"
      select="boolean($context/*[contains(@class, ' learning2-d/lcCorrectResponse2 ')] |
                      $context/*[contains(@class, ' learning-d/lcCorrectResponse ')])"
    />
    <xsl:sequence select="$result"/>
  </xsl:function>
  
  <xsl:function name="lc:shuffleItems" as="node()*">
    <xsl:param name="sourceItems" as="node()*"/>
    <xsl:param name="resultItems" as="node()*"/>
    <xsl:param name="seed" as="xs:double"/>
    <xsl:choose>
      <xsl:when test="count($sourceItems) = 1">
        <xsl:sequence select="$resultItems, $sourceItems"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="itemIndex" 
          select="xs:integer(random:random-sequence(1, $seed)*10) + 1" 
          as="xs:integer"/>
        <xsl:variable name="nextResultItem" select="$sourceItems[$itemIndex]"/>
        <xsl:choose>
          <xsl:when test="$nextResultItem">
            <xsl:sequence 
              select="lc:shuffleItems(
                 ($sourceItems except $nextResultItem), 
                 ($resultItems, $nextResultItem), 
                 $seed + $itemIndex)"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- Try again -->
            <xsl:sequence 
              select="lc:shuffleItems(
                 $sourceItems, 
                 $resultItems, 
                 $seed + $itemIndex)"
            />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
              
  <xsl:template name="lcGetQuestionNumber">
    <!-- Generates the question number. Note that without
         map-driven processing some of the possible options
         cannot be implemented using XSLT alone.
      -->
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <xsl:param name="numberFormat" as="xs:string" select="$lc-question-number-format"/>
    <xsl:param name="lc:numberQuestions" as="xs:boolean" tunnel="yes" select="$lc:doNumberQuestions"/>
    
    <xsl:variable name="questionNumber" as="xs:string">
      <xsl:choose>
        <xsl:when test="not($lc:numberQuestions)">
          <xsl:sequence select="''"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:number 
            count="*[contains(@class, ' learningInteractionBase2-d/lcInteractionBase2 ')] |
                   *[contains(@class, ' learningInteractionBase-d/lcInteractionBase ')]"
            format="{$numberFormat}"
          />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:if test="$questionNumber != ''">
      <fo:inline xsl:use-attribute-sets="lcQuestionNumber">
        <xsl:value-of select="$lc-question-number-prefix"/>
        <xsl:value-of select="$questionNumber"/>
        <xsl:value-of select="$lc-question-number-suffix"/>
      </fo:inline>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>