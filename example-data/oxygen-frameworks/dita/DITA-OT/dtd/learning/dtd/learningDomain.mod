<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================================= -->
<!--                    HEADER                                     -->
<!-- ============================================================= -->
<!--  MODULE:    DITA Learning Domain                              -->
<!--  VERSION:   1.2                                               -->
<!--  DATE:      November 2009                                     -->
<!--                                                               -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!--                    PUBLIC DOCUMENT TYPE DEFINITION            -->
<!--                    TYPICAL INVOCATION                         -->
<!--                                                               -->
<!--  Refer to this file by the following public identfier or an 
      appropriate system identifier 
PUBLIC "-//OASIS//ELEMENTS DITA Learning Domain//EN"
      Delivered as file "learningDomain.mod"                      -->

<!-- ============================================================= -->
<!-- SYSTEM:     Darwin Information Typing Architecture (DITA)     -->
<!--                                                               -->
<!-- PURPOSE:    Declaring the elements and specialization         -->
<!--             attributes for Learning Domain                    -->
<!--                                                               -->
<!-- ORIGINAL CREATION DATE:                                       -->
<!--             May 2007                                          -->
<!--                                                               -->
<!--             (C) Copyright OASIS Open 2007, 2009.              -->
<!--             All Rights Reserved.                              -->
<!--                                                               -->
<!--  CHANGE LOG:                                                  -->
<!--                                                               -->
<!--    Sept 2009: WEK: added lcMatchingItemFeedback per           -->
<!--    TC decision.                                               -->
<!-- ============================================================= -->

 

<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   - Assessment interactions
   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   - ENTITY DECLARATIONS FOR DOMAIN SUBSTITUTION
   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

<!ENTITY % lcInstructornote "lcInstructornote">
<!ENTITY % lcTrueFalse              "lcTrueFalse">
<!ENTITY % lcSingleSelect           "lcSingleSelect">
<!ENTITY % lcMultipleSelect         "lcMultipleSelect">
<!ENTITY % lcSequencing             "lcSequencing">
<!ENTITY % lcMatching               "lcMatching">
<!ENTITY % lcHotspot                "lcHotspot">
<!ENTITY % lcOpenQuestion           "lcOpenQuestion">

<!ENTITY % lcQuestion               "lcQuestion">
<!ENTITY % lcOpenAnswer             "lcOpenAnswer">
<!ENTITY % lcAnswerOptionGroup    "lcAnswerOptionGroup">
<!ENTITY % lcAsset                  "lcAsset">
<!ENTITY % lcFeedbackCorrect        "lcFeedbackCorrect">
<!ENTITY % lcFeedbackIncorrect      "lcFeedbackIncorrect">
<!ENTITY % lcAnswerOption         "lcAnswerOption">
<!ENTITY % lcAnswerContent          "lcAnswerContent">
<!ENTITY % lcSequenceOptionGroup    "lcSequenceOptionGroup">
<!ENTITY % lcSequenceOption         "lcSequenceOption">
<!ENTITY % lcSequence               "lcSequence">

<!ENTITY % lcMatchTable             "lcMatchTable">
<!ENTITY % lcMatchingHeader         "lcMatchingHeader">
<!ENTITY % lcMatchingPair           "lcMatchingPair">
<!ENTITY % lcItem                   "lcItem">
<!ENTITY % lcMatchingItem           "lcMatchingItem">
<!ENTITY % lcMatchingItemFeedback   "lcMatchingItemFeedback">

<!ENTITY % lcHotspotMap             "lcHotspotMap">
<!ENTITY % lcArea                   "lcArea">
<!ENTITY % lcAreaShape              "lcAreaShape">
<!ENTITY % lcAreaCoords             "lcAreaCoords">

<!ENTITY % lcCorrectResponse        "lcCorrectResponse">
<!ENTITY % lcFeedback               "lcFeedback">


<!ENTITY % lcInstructornote.content
                       "(%note.cnt;)* "
>
<!ENTITY % lcInstructornote.attributes
             "spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:Use the <lcInstructornote> element to provide information or notes you want to provide to the course instructor. These notes can be condionalized out of content you intend to deliver to the learner.-->
<!ELEMENT lcInstructornote    %lcInstructornote.content;>
<!ATTLIST lcInstructornote    %lcInstructornote.attributes;>


<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   - INTERACTION DEFINITIONS
   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
<!ENTITY % lcTrueFalse.content
                       "((%title;)?,
                         (%lcQuestion;), 
                         (%lcAsset;)?,
                         (%lcAnswerOptionGroup;),
                         (%lcFeedbackIncorrect;)?,
                         (%lcFeedbackCorrect;)?,
                         (%data;)*)"
>
<!ENTITY % lcTrueFalse.attributes
             "id
                        NMTOKEN
                                  #REQUIRED
              %conref-atts;
              %select-atts;
              %localization-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:A lcTrueFalse interaction presents the learner with two choices, one correct, the other incorrect, often presented as true/false or yes/no responses.-->
<!ELEMENT lcTrueFalse    %lcTrueFalse.content;>
<!ATTLIST lcTrueFalse    %lcTrueFalse.attributes;>


<!ENTITY % lcSingleSelect.content
                       "((%title;)?,
                         (%lcQuestion;), 
                         (%lcAsset;)?,
                         (%lcAnswerOptionGroup;),
                         (%lcFeedbackIncorrect;)?,
                         (%lcFeedbackCorrect;)?,
                         (%data;)*)"
>
<!ENTITY % lcSingleSelect.attributes
             "id
                        NMTOKEN
                                  #REQUIRED
              %conref-atts;
              %select-atts;
              %localization-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:An lcSingleSelect interaction presents three or more choices, only one of which is correct.-->
<!ELEMENT lcSingleSelect    %lcSingleSelect.content;>
<!ATTLIST lcSingleSelect    %lcSingleSelect.attributes;>


<!ENTITY % lcMultipleSelect.content
                       "((%title;)?,
                         (%lcQuestion;), 
                         (%lcAsset;)?,
                         (%lcAnswerOptionGroup;),
                         (%lcFeedbackIncorrect;)?,
                         (%lcFeedbackCorrect;)?,
                         (%data;)*)"
>
<!ENTITY % lcMultipleSelect.attributes
             "id
                        NMTOKEN
                                  #REQUIRED
              %conref-atts;
              %select-atts;
              %localization-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:In an lcMultipleSelect interaction, the learner must indicate two or more correct answers from a list of choices.-->
<!ELEMENT lcMultipleSelect    %lcMultipleSelect.content;>
<!ATTLIST lcMultipleSelect    %lcMultipleSelect.attributes;>


<!ENTITY % lcSequencing.content
                       "((%title;)?,
                         (%lcQuestion;),
                         (%lcAsset;)?,
                         (%lcSequenceOptionGroup;),
                         (%lcFeedbackIncorrect;)?,
                         (%lcFeedbackCorrect;)?,
                         (%data;)*)"
>
<!ENTITY % lcSequencing.attributes
             "id
                        NMTOKEN
                                  #REQUIRED
              %conref-atts;
              %select-atts;
              %localization-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:An lcSequencing interaction asks the learner to arrange a list of choices into a predefined order, such as small to large.-->
<!ELEMENT lcSequencing    %lcSequencing.content;>
<!ATTLIST lcSequencing    %lcSequencing.attributes;>


<!ENTITY % lcMatching.content
                       "((%title;)?,
                         (%lcQuestion;),
                         (%lcAsset;)?,
                         (%lcMatchTable;),
                         (%lcFeedbackIncorrect;)?,
                         (%lcFeedbackCorrect;)?,
                         (%data;)*)"
>
<!ENTITY % lcMatching.attributes
             "id
                        NMTOKEN
                                  #REQUIRED
              %conref-atts;
              %select-atts;
              %localization-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:In an lcMatching interaction, the learner identifies the correct choice that matches another choice.-->
<!ELEMENT lcMatching    %lcMatching.content;>
<!ATTLIST lcMatching    %lcMatching.attributes;>


<!ENTITY % lcHotspot.content
                       "((%title;)?,
                         (%lcQuestion;),
                         (%lcHotspotMap;),
                         (%lcFeedbackIncorrect;)?,
                         (%lcFeedbackCorrect;)?,
                         (%data;)*)"
>
<!ENTITY % lcHotspot.attributes
             "id
                        NMTOKEN
                                  #REQUIRED
              %conref-atts;
              %select-atts;
              %localization-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:In a lcHotspot interaction, the learner clicks on a region of the screen to indicate a choice.-->
<!ELEMENT lcHotspot    %lcHotspot.content;>
<!ATTLIST lcHotspot    %lcHotspot.attributes;>


<!ENTITY % lcOpenQuestion.content
                       "((%title;)?,
                         (%lcQuestion;), 
                         (%lcAsset;)?,
                         (%lcOpenAnswer;)?,
                         (%lcFeedbackIncorrect;)?,
                         (%lcFeedbackCorrect;)?,
                         (%data;)*)"
>
<!ENTITY % lcOpenQuestion.attributes
             "id
                        NMTOKEN
                                  #REQUIRED
              %conref-atts;
              %select-atts;
              %localization-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:Use <lcOpenQuestion> to pose an open-ended question in an assessment interaction.-->
<!ELEMENT lcOpenQuestion    %lcOpenQuestion.content;>
<!ATTLIST lcOpenQuestion    %lcOpenQuestion.attributes;>


<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   - OPTION DEFINITIONS
   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
<!ENTITY % lcQuestion.content
                       "(%ph.cnt;)*"
>
<!ENTITY % lcQuestion.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:Use the <lcQuestion> element in an interaction to ask the question.-->
<!ELEMENT lcQuestion    %lcQuestion.content;>
<!ATTLIST lcQuestion    %lcQuestion.attributes;>


<!ENTITY % lcOpenAnswer.content
                       "(%ph.cnt;)*"
>
<!ENTITY % lcOpenAnswer.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:Use >lcOpenAnswer< to provide a suggested answer for an >lcOpenQuestion< interaction.-->
<!ELEMENT lcOpenAnswer    %lcOpenAnswer.content;>
<!ATTLIST lcOpenAnswer    %lcOpenAnswer.attributes;>


<!ENTITY % lcAnswerOptionGroup.content
                       "((%lcAnswerOption;)+)"
>
<!ENTITY % lcAnswerOptionGroup.attributes
             "%univ-atts; 
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcAnswerOptionGroup> element provides a container for the options for a true-false, single-select, or multiple-select assessment interaction.-->
<!ELEMENT lcAnswerOptionGroup    %lcAnswerOptionGroup.content;>
<!ATTLIST lcAnswerOptionGroup    %lcAnswerOptionGroup.attributes;>


<!ENTITY % lcSequenceOptionGroup.content
                       "((%lcSequenceOption;)+)"
>
<!ENTITY % lcSequenceOptionGroup.attributes
             "%univ-atts; 
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcSequenceOptionGroup> element provides the options for an assessment sequence interaction.-->
<!ELEMENT lcSequenceOptionGroup    %lcSequenceOptionGroup.content;>
<!ATTLIST lcSequenceOptionGroup    %lcSequenceOptionGroup.attributes;>


									
<!ENTITY % lcAsset.content
                       "((%imagemap; | 
                          %image; | 
                          %object;)*)"
>
<!ENTITY % lcAsset.attributes
             "%univ-atts; 
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcAsset> element in an assessment interaction provides the images or other graphic assets to support the interaction.-->
<!ELEMENT lcAsset    %lcAsset.content;>
<!ATTLIST lcAsset    %lcAsset.attributes;>


<!ENTITY % lcSequenceOption.content
                       "((%lcAnswerContent;),
                         (%lcSequence;))"
>
<!ENTITY % lcSequenceOption.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcSequenceOption> element in an assessment interaction provides the contents of an item in a sequence interaction.-->
<!ELEMENT lcSequenceOption    %lcSequenceOption.content;>
<!ATTLIST lcSequenceOption    %lcSequenceOption.attributes;>


<!ENTITY % lcFeedback.content
                       "(%ph.cnt;)*"
>
<!ENTITY % lcFeedback.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcFeedback> element in an assessment interaction provides information to the learner about a correct or incorrect response.-->
<!ELEMENT lcFeedback    %lcFeedback.content;>
<!ATTLIST lcFeedback    %lcFeedback.attributes;>


<!ENTITY % lcFeedbackCorrect.content
                       "(%ph.cnt;)*"
>
<!ENTITY % lcFeedbackCorrect.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcFeedbackCorrect> element in an assessment interaction provides feedback to the learner about a correct response.-->
<!ELEMENT lcFeedbackCorrect    %lcFeedbackCorrect.content;>
<!ATTLIST lcFeedbackCorrect    %lcFeedbackCorrect.attributes;>


<!ENTITY % lcFeedbackIncorrect.content
                       "(%ph.cnt;)*"
>
<!ENTITY % lcFeedbackIncorrect.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcFeedbackIncorrect> element in an assessment interaction provides feedback about incorrect response.-->
<!ELEMENT lcFeedbackIncorrect    %lcFeedbackIncorrect.content;>
<!ATTLIST lcFeedbackIncorrect    %lcFeedbackIncorrect.attributes;>


<!ENTITY % lcAnswerOption.content
                       "((%lcAnswerContent;),
                         (%lcCorrectResponse;)?,
                         (%lcFeedback;)? )"
>
<!ENTITY % lcAnswerOption.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcAnswerOption> element in an assessment interaction provides the content and feedback for a question option, and can indicate the correct option.-->
<!ELEMENT lcAnswerOption    %lcAnswerOption.content;>
<!ATTLIST lcAnswerOption    %lcAnswerOption.attributes;>


<!ENTITY % lcAnswerContent.content
                       "(%ph.cnt;)*"
>
<!ENTITY % lcAnswerContent.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcAnswerContent> element in a learning assessment interaction provides the content for an answer option, which the learner can select as correct or incorrect.-->
<!ELEMENT lcAnswerContent    %lcAnswerContent.content;>
<!ATTLIST lcAnswerContent    %lcAnswerContent.attributes;>


<!ENTITY % lcMatchTable.content
                       "((%lcMatchingHeader;)?,
                         (%lcMatchingPair;)+)"
>
<!ENTITY % lcMatchTable.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcMatchTable> element in an assessment interaction provides a format for matching items.-->
<!ELEMENT lcMatchTable    %lcMatchTable.content;>
<!ATTLIST lcMatchTable    %lcMatchTable.attributes;>


<!ENTITY % lcMatchingHeader.content
                       "((%lcItem;),
                         (%lcMatchingItem;))"
>
<!ENTITY % lcMatchingHeader.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcMatchingHeader> element in an assessment interaction provides column headings for items to present in a matching table.-->
<!ELEMENT lcMatchingHeader    %lcMatchingHeader.content;>
<!ATTLIST lcMatchingHeader    %lcMatchingHeader.attributes;>


<!ENTITY % lcMatchingPair.content
                       "((%lcItem;),
                         (%lcMatchingItem;),
                         (%lcMatchingItemFeedback;)?)">
<!ENTITY % lcMatchingPair.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcMatchingPair> element in an assessment interaction provides a table row with the pair of items that comprise a correct match in a matching interaction.-->
<!ELEMENT lcMatchingPair    %lcMatchingPair.content;>
<!ATTLIST lcMatchingPair    %lcMatchingPair.attributes;>


<!ENTITY % lcItem.content
                       "(%ph.cnt;)*"
>
<!ENTITY % lcItem.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcItem> element in an assessment interaction provides the content for an item that matches the match item in a match table.-->
<!ELEMENT lcItem    %lcItem.content;>
<!ATTLIST lcItem    %lcItem.attributes;>


<!ENTITY % lcMatchingItem.content
                       "(%ph.cnt; )*"
>
<!ENTITY % lcMatchingItem.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcMatchingItem> element in an assessment interaction provides the content for the matching side of a matching pair of items in a match table interaction.-->
<!ELEMENT lcMatchingItem    %lcMatchingItem.content;>
<!ATTLIST lcMatchingItem    %lcMatchingItem.attributes;>

<!ENTITY % lcMatchingItemFeedback.content
                       "((%lcFeedback;) |
                         (%lcFeedbackCorrect;) |
                         (%lcFeedbackIncorrect;))*"
>
<!ENTITY % lcMatchingItemFeedback.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!ELEMENT lcMatchingItemFeedback    %lcMatchingItemFeedback.content;>
<!ATTLIST lcMatchingItemFeedback    %lcMatchingItemFeedback.attributes;>


<!ENTITY % lcHotspotMap.content
                       "((%image;),
                         (%lcArea;)+)"
>
<!ENTITY % lcHotspotMap.attributes 
              "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED" 
> 

<!--doc:A lcHotspotMap interaction lets you designate an action area or region over an image, allowing a click in that region to get scored as correct or incorrect in respoinse to an interaction question.-->
<!ELEMENT lcHotspotMap    %lcHotspotMap.content;>
<!ATTLIST lcHotspotMap    %lcHotspotMap.attributes;>


<!ENTITY % lcArea.content 
                       "((%lcAreaShape;), 
                         (%lcAreaCoords;), 
                         (%xref;)?, 
                         (%lcCorrectResponse;)?, 
                         (%lcFeedback;)?)" 
> 
<!ENTITY % lcArea.attributes 
              "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED" 
> 
<!--doc:A lcArea defines an area of a hotspot image that contains a correct or incorrect choice in a hotspot assessment interaction.-->
<!ELEMENT lcArea    %lcArea.content;>
<!ATTLIST lcArea    %lcArea.attributes;>

<!--                    LONG NAME: Shape of the Hotspot            --> 
<!ENTITY % lcAreaShape.content 
                       "(#PCDATA | 
                         %text;)* 
"> 
<!ENTITY % lcAreaShape.attributes 
             "keyref 
                        CDATA 
                                  #IMPLIED 
              %univ-atts-translate-no; 
              outputclass 
                        CDATA 
                                  #IMPLIED" 
> 


<!ELEMENT lcAreaShape    %lcAreaShape.content;> 
<!ATTLIST lcAreaShape    %lcAreaShape.attributes;> 



<!--                    LONG NAME: Coordinates of the Hotspot      --> 
<!ENTITY % lcAreaCoords.content 
                       "(%words.cnt;)*" 
> 
<!ENTITY % lcAreaCoords.attributes 
             "keyref 
                        CDATA 
                                  #IMPLIED 
              %univ-atts-translate-no; 
              outputclass 
                        CDATA 
                                  #IMPLIED" 
> 
<!ELEMENT lcAreaCoords    %lcAreaCoords.content;> 
<!ATTLIST lcAreaCoords    %lcAreaCoords.attributes;> 


<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   - CHOICE DEFINITIONS
   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
<!ENTITY % lcCorrectResponse.content
                       "EMPTY">
<!ENTITY % lcCorrectResponse.attributes
             "name
                        CDATA
                                  'lcCorrectResponse'
              value
                        CDATA
                                  'lcCorrectResponse'
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcCorrectResponse> element in an assessment interaction indicates a correct response.-->
<!ELEMENT lcCorrectResponse    %lcCorrectResponse.content;>
<!ATTLIST lcCorrectResponse    %lcCorrectResponse.attributes;>


<!ENTITY % lcSequence.content
                       "EMPTY">
<!ENTITY % lcSequence.attributes
             "name
                       CDATA
                                 'lcSequence'
              value
                        CDATA
                                  #REQUIRED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcSequence> element in an assessment interaction provides the position of a sequence option in a sequence.-->
<!ELEMENT lcSequence    %lcSequence.content;>
<!ATTLIST lcSequence    %lcSequence.attributes;>


<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   - CLASS ATTRIBUTES FOR ANCESTRY DECLARATION
   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
<!ATTLIST lcInstructornote        %global-atts; 
    class CDATA "+ topic/note learningInteractionBase-d/note learning-d/lcInstructornote ">
<!ATTLIST lcTrueFalse %global-atts;
    class CDATA "+ topic/fig learningInteractionBase-d/lcInteractionBase learning-d/lcTrueFalse ">
<!ATTLIST lcSingleSelect %global-atts;
    class CDATA "+ topic/fig learningInteractionBase-d/lcInteractionBase learning-d/lcSingleSelect ">
<!ATTLIST lcMultipleSelect %global-atts;
    class CDATA "+ topic/fig learningInteractionBase-d/lcInteractionBase learning-d/lcMultipleSelect ">
<!ATTLIST lcSequencing %global-atts;
    class CDATA "+ topic/fig learningInteractionBase-d/lcInteractionBase learning-d/lcSequencing ">
<!ATTLIST lcMatching %global-atts;
    class CDATA "+ topic/fig learningInteractionBase-d/lcInteractionBase learning-d/lcMatching ">
<!ATTLIST lcHotspot %global-atts;
    class CDATA "+ topic/fig learningInteractionBase-d/lcInteractionBase learning-d/lcHotspot ">
<!ATTLIST lcOpenQuestion %global-atts;
    class CDATA "+ topic/fig learningInteractionBase-d/lcInteractionBase learning-d/lcOpenQuestion ">

<!ATTLIST lcQuestion %global-atts;
    class CDATA "+ topic/p learningInteractionBase-d/lcQuestionBase learning-d/lcQuestion ">
<!ATTLIST lcOpenAnswer %global-atts;
    class CDATA "+ topic/p learningInteractionBase-d/p learning-d/lcOpenAnswer ">
<!ATTLIST lcAsset %global-atts;
    class CDATA "+ topic/p learningInteractionBase-d/p learning-d/lcAsset ">
<!ATTLIST lcFeedback %global-atts;
    class CDATA "+ topic/p learningInteractionBase-d/p learning-d/lcFeedback ">
<!ATTLIST lcFeedbackCorrect %global-atts;
    class CDATA "+ topic/p learningInteractionBase-d/p learning-d/lcFeedbackCorrect ">
<!ATTLIST lcFeedbackIncorrect %global-atts;
    class CDATA "+ topic/p learningInteractionBase-d/p learning-d/lcFeedbackIncorrect ">
<!ATTLIST lcAnswerOption %global-atts;
    class CDATA "+ topic/li learningInteractionBase-d/li learning-d/lcAnswerOption ">
<!ATTLIST lcAnswerOptionGroup     %global-atts; 
    class CDATA "+ topic/ul learningInteractionBase-d/ul learning-d/lcAnswerOptionGroup ">
<!ATTLIST lcAnswerContent %global-atts;
    class CDATA "+ topic/p learningInteractionBase-d/p learning-d/lcAnswerContent ">
<!ATTLIST lcMatchTable %global-atts;
    class CDATA "+ topic/simpletable learningInteractionBase-d/simpletable learning-d/lcMatchTable ">
<!ATTLIST lcMatchingHeader %global-atts;
    class CDATA "+ topic/sthead learningInteractionBase-d/sthead learning-d/lcMatchingHeader ">
<!ATTLIST lcMatchingPair %global-atts;
    class CDATA "+ topic/strow learningInteractionBase-d/strow learning-d/lcMatchingPair ">
<!ATTLIST lcItem %global-atts;
    class CDATA "+ topic/stentry learningInteractionBase-d/stentry learning-d/lcItem ">
<!ATTLIST lcMatchingItem %global-atts;
    class CDATA "+ topic/stentry learningInteractionBase-d/stentry learning-d/lcMatchingItem ">
<!ATTLIST lcMatchingItemFeedback %global-atts;
    class CDATA "+ topic/stentry learningInteractionBase-d/stentry learning-d/lcMatchingItemFeedback ">
<!ATTLIST lcSequenceOptionGroup     %global-atts; 
    class CDATA "+ topic/ol learningInteractionBase-d/ol learning-d/lcSequenceOptionGroup ">
<!ATTLIST lcSequenceOption %global-atts;
    class CDATA "+ topic/li learningInteractionBase-d/li learning-d/lcSequenceOption ">
<!ATTLIST lcSequence %global-atts;
    class CDATA "+ topic/data learningInteractionBase-d/data learning-d/lcSequence ">
<!ATTLIST lcCorrectResponse %global-atts;
    class CDATA "+ topic/data learningInteractionBase-d/data learning-d/lcCorrectResponse ">

<!ATTLIST lcHotspotMap %global-atts; 
   class CDATA "+ topic/fig learningInteractionBase-d/figgroup learning-d/lcHotspotMap " >
<!ATTLIST lcArea       %global-atts; 
   class CDATA "+ topic/figgroup learningInteractionBase-d/figgroup learning-d/lcArea ">
<!ATTLIST lcAreaShape    %global-atts;  
    class CDATA "+ topic/keyword learningInteractionBase-d/keyword learning-d/lcAreaShape "> 
<!ATTLIST lcAreaCoords   %global-atts;  
    class CDATA "+ topic/ph learningInteractionBase-d/ph learning-d/lcAreaCoords "    > 

<!-- End of declaration set -->
