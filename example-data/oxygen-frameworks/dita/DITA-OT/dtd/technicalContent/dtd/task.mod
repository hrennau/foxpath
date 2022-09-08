<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================================= -->
<!--                    HEADER                                     -->
<!-- ============================================================= -->
<!--  MODULE:    DITA Task                                         -->
<!--  VERSION:   1.2                                               -->
<!--  DATE:      November 2009                                     -->
<!--                                                               -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!--                    PUBLIC DOCUMENT TYPE DEFINITION            -->
<!--                    TYPICAL INVOCATION                         -->
<!--                                                               -->
<!--  Refer to this file by the following public identifier or an 
      appropriate system identifier 
PUBLIC "-//OASIS//ELEMENTS DITA Task//EN"
      Delivered as file "task.mod"                                 -->

<!-- ============================================================= -->
<!-- SYSTEM:     Darwin Information Typing Architecture (DITA)     -->
<!--                                                               -->
<!-- PURPOSE:    Declaring the elements and specialization         -->
<!--             attributes for the DITA Tasks                     -->
<!--                                                               -->
<!-- ORIGINAL CREATION DATE:                                       -->
<!--             March 2001                                        -->
<!--                                                               -->
<!--             (C) Copyright OASIS Open 2005, 2009.              -->
<!--             (C) Copyright IBM Corporation 2001, 2004.         -->
<!--             All Rights Reserved.                              -->
<!--                                                               -->
<!--  UPDATES:                                                     -->
<!--    2005.11.15 RDA: Removed old declaration for                -->
<!--                    taskClasses entity                         -->
<!--    2005.11.15 RDA: Corrected LONG NAME for chdeschd           -->
<!--    2006.06.06 RDA: Changed model of choice to listitem.cnt    -->
<!--                    for completeness                           -->
<!--    2006.06.07 RDA: Added <abstract> element                   -->
<!--    2006.06.07 RDA: Make universal attributes universal        -->
<!--                      (DITA 1.1 proposal #12)                  -->
<!--    2006.11.30 RDA: Add -dita-use-conref-target to enumerated  -->
<!--                      attributes                               -->
<!--    2006.11.30 RDA: Remove #FIXED from DITAArchVersion         -->
<!--    2007.12.01 EK:  Reformatted DTD modules for DITA 1.2       -->
<!--    2008.01.30 RDA: Replace @conref defn. with %conref-atts;   -->
<!--    2008.02.06 RDA: Add note and itemgroup to step, substep    -->
<!--    2008.02.06 RDA: Loosen content model of taskbody; add      -->
<!--                    process and stepsection elements           -->
<!--    2008.02.13 RDA: Create .content and .attributes entities   -->
<!--    2008.05.06 RDA: Added sectiondiv to section specializations-->
<!--    2008.12.02 RDA: Rename process to steps-informal           -->
<!-- ============================================================= -->


<!-- ============================================================= -->
<!--                   ARCHITECTURE ENTITIES                       -->
<!-- ============================================================= -->

<!-- default namespace prefix for DITAArchVersion attribute can be
     overridden through predefinition in the document type shell   -->
<!ENTITY % DITAArchNSPrefix
  "ditaarch" 
>

<!-- must be instanced on each topic type                          -->
<!ENTITY % arch-atts 
             "xmlns:%DITAArchNSPrefix; 
                        CDATA 
                                  #FIXED 'http://dita.oasis-open.org/architecture/2005/'
              %DITAArchNSPrefix;:DITAArchVersion
                         CDATA 
                                  '1.2'
  "
>


<!-- ============================================================= -->
<!--                   SPECIALIZATION OF DECLARED ELEMENTS         -->
<!-- ============================================================= -->


<!-- ============================================================= -->
<!--                   ELEMENT NAME ENTITIES                       -->
<!-- ============================================================= -->

<!ENTITY % task        "task"                                        >
<!ENTITY % taskbody    "taskbody"                                    >
<!ENTITY % steps       "steps"                                       >
<!ENTITY % steps-unordered 
                       "steps-unordered"                             >
<!ENTITY % step        "step"                                        >
<!ENTITY % stepsection "stepsection"                                 >
<!ENTITY % cmd         "cmd"                                         >
<!ENTITY % substeps    "substeps"                                    >
<!ENTITY % substep     "substep"                                     >
<!ENTITY % tutorialinfo 
                       "tutorialinfo"                                >
<!ENTITY % info        "info"                                        >
<!ENTITY % stepxmp     "stepxmp"                                     >
<!ENTITY % stepresult  "stepresult"                                  >
<!ENTITY % choices     "choices"                                     >
<!ENTITY % choice      "choice"                                      >
<!ENTITY % steps-informal "steps-informal"                           >
<!ENTITY % result      "result"                                      >
<!ENTITY % prereq      "prereq"                                      >
<!ENTITY % postreq     "postreq"                                     >
<!ENTITY % context     "context"                                     >
<!ENTITY % choicetable "choicetable"                                 >
<!ENTITY % chhead      "chhead"                                      >
<!ENTITY % chrow       "chrow"                                       >
<!ENTITY % choptionhd  "choptionhd"                                  >
<!ENTITY % chdeschd    "chdeschd"                                    >
<!ENTITY % choption    "choption"                                    >
<!ENTITY % chdesc      "chdesc"                                      >


<!-- ============================================================= -->
<!--                    SHARED ATTRIBUTE LISTS                     -->
<!-- ============================================================= -->


<!--                    Provide an alternative set of univ-atts 
                        that allows importance to be redefined 
                        locally                                    -->
<!ENTITY % univ-atts-no-importance-task
             '%id-atts;
              %filter-atts;
              base 
                        CDATA 
                                  #IMPLIED
              %base-attribute-extensions;
              rev 
                        CDATA 
                                  #IMPLIED
              status 
                        (new | 
                         changed | 
                         deleted | 
                         unchanged | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              %localization-atts; 
 '
>

<!ENTITY % task-info-types 
  "%info-types;
  " 
>


<!-- ============================================================= -->
<!--                    DOMAINS ATTRIBUTE OVERRIDE                 -->
<!-- ============================================================= -->


<!ENTITY included-domains 
  ""
>


<!-- ============================================================= -->
<!--                    ELEMENT DECLARATIONS                       -->
<!-- ============================================================= -->


<!--                    LONG NAME: Task                            -->
<!ENTITY % task.content
                       "((%title;), 
                         (%titlealts;)?,
                         (%abstract; | 
                          %shortdesc;)?, 
                         (%prolog;)?, 
                         (%taskbody;)?, 
                         (%related-links;)?, 
                         (%task-info-types;)* )"
>
<!ENTITY % task.attributes
             "id 
                        ID 
                                  #REQUIRED
              %conref-atts;
              %select-atts;
              %localization-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <task> element is the top-level element for a task topic. Tasks are the main building blocks for task-oriented user assistance. They generally provide step-by-step instructions that will enable a user to perform a task. A task answers the question of "how to?" by telling the user precisely what to do and the order in which to do it. Tasks have the same high-level structure as other topics, with a title, short description and body.
Category: Task elements-->
<!ELEMENT task    %task.content;>
<!ATTLIST task    
              %task.attributes;
              %arch-atts;
              domains 
                        CDATA 
                                  "&included-domains;">



<!--                    LONG NAME: Task Body                       -->
<!ENTITY % taskbody.content
                       "(((%prereq;) | 
                          (%context;) |
                          (%section;))*,
                         ((%steps; | 
                           %steps-unordered; |
                           %steps-informal;))?, 
                         (%result;)?, 
                         (%example;)*, 
                         (%postreq;)*)"
>
<!ENTITY % taskbody.attributes
             "%id-atts;
              %localization-atts;
              base 
                        CDATA 
                                  #IMPLIED
              %base-attribute-extensions;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <taskbody> element is the main body-level element inside a task topic. A task body has a very specific structure, with the following elements in this order: <prereq>, <context>, <steps>, <result>, <example> and <postreq>. Each of the body sections are optional.
Category: Task elements-->
<!ELEMENT taskbody    %taskbody.content;>
<!ATTLIST taskbody    %taskbody.attributes;>



<!--                    LONG NAME: Prerequisites                   -->
<!ENTITY % prereq.content
                       "(%section.notitle.cnt;)*"
>
<!ENTITY % prereq.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The pre-requisite (<prereq>) section of a task should document things the user needs to know or do before starting the current task. Prerequisite links will be placed in a list after the related-links section; on output the <prereq> links from the related-links section are added to the <prereq> section.
Category: Task elements-->
<!ELEMENT prereq    %prereq.content;>
<!ATTLIST prereq    %prereq.attributes;>



<!--                    LONG NAME: Context                         -->
<!ENTITY % context.content
                       "(%section.notitle.cnt;)*"
>
<!ENTITY % context.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <context> section of a task provides background information for the task. This information helps the user understand what the purpose of the task is and what they will gain by completing the task. This section should be brief and does not replace or recreate a concept topic on the same subject, although the context section may include some conceptual information.
Category: Task elements-->
<!ELEMENT context    %context.content;>
<!ATTLIST context    %context.attributes;>


<!--                    LONG NAME: Informal Steps                  -->
<!ENTITY % steps-informal.content
                       "(%section.notitle.cnt;)*"
>
<!ENTITY % steps-informal.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <steps-informal> element allows authors to describe procedural task information that would not normally be described as steps.-->
<!ELEMENT steps-informal    %steps-informal.content;>
<!ATTLIST steps-informal    %steps-informal.attributes;>


<!--                    LONG NAME: Steps                           -->
<!ENTITY % steps.content
                       "((%stepsection;)?,
                         (%step;))+"
>
<!ENTITY % steps.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <steps> section of a task provides the main content of the task topic. The task is described as a series of steps that the user must follow to accomplish the task. One or more <steps> elements is required inside the <steps> section.
Category: Task elements-->
<!ELEMENT steps    %steps.content;>
<!ATTLIST steps    %steps.attributes;>



<!--                    LONG NAME: Steps: Unordered                -->
<!ENTITY % steps-unordered.content
                       "((%stepsection;)?,
                         (%step;))+"
>
<!ENTITY % steps-unordered.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:Like the <steps> element, the <steps-unordered> section of a task provides the main content of the task topic, but particularly for cases in which the order of steps may vary from one situation to another. One or more steps is required inside the <steps-unordered> section.
Category: Task elements-->
<!ELEMENT steps-unordered    %steps-unordered.content;>
<!ATTLIST steps-unordered    %steps-unordered.attributes;>


<!--                    LONG NAME: Step section                    -->
<!ENTITY % stepsection.content
                       "(%listitem.cnt;)*"
>
<!ENTITY % stepsection.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <stepsection> element provides expository text before a step element. Although the element is specialized from <li> and has the same content model as a list item, this is not considered a step, and rendering engines may choose to skip this element when numbering steps.-->
<!ELEMENT stepsection    %stepsection.content;>
<!ATTLIST stepsection    %stepsection.attributes;>


<!--                    LONG NAME: Step                            -->
<!ENTITY % step.content
                       "((%note;)*,
                         %cmd;, 
                         (%choices; |
                          %choicetable; | 
                          %info; |
                          %itemgroup; |
                          %stepxmp; | 
                          %substeps; |
                          %tutorialinfo;)*, 
                         (%stepresult;)? )"
>
<!ENTITY % step.attributes
             "importance 
                        (optional | 
                         required | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              %univ-atts-no-importance-task; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <step> element represents an action that a user must follow to accomplish a task. Each step in a task must contain a command <cmd> element which describes the particular action the user must do to accomplish the overall task. The step element can also contain information <info>, substeps <substeps>, tutorial information <tutorialinfo>, a step example <stepxmp>, choices <choices> or a stepresult <stepresult>, although these are optional.
Category: Task elements-->
<!ELEMENT step    %step.content;>
<!ATTLIST step    %step.attributes;>


<!--                    LONG NAME: Command                         -->
<!ENTITY % cmd.content
                       "(%ph.cnt;)*"
>
<!ENTITY % cmd.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The command (<cmd>) element is required as the first element inside a <step>. It provides the active voice instruction to the user for completing the step, and should not be more than one sentence. If the step needs additional explanation, this can follow the <cmd> element inside an <info > element.
Category: Task elements-->
<!ELEMENT cmd    %cmd.content;>
<!ATTLIST cmd    %cmd.attributes;>



<!--                    LONG NAME: Information                     -->
<!ENTITY % info.content
                       "(%itemgroup.cnt;)*"
>
<!ENTITY % info.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The information element (<info>) occurs inside a <step> element to provide additional information about the step.
Category: Task elements-->
<!ELEMENT info    %info.content;>
<!ATTLIST info    %info.attributes;>



<!--                    LONG NAME: Sub-steps                       -->
<!ENTITY % substeps.content
                       "(%substep;)+"
>
<!ENTITY % substeps.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <substeps> element allows you to break a step down into a series of separate actions, and should be used only if necessary. Try to describe the steps of a task in a single level of steps. If you need to use more than one level of substep nesting, you should probably rewrite the task to simplify it.
Category: Task elements-->
<!ELEMENT substeps    %substeps.content;>
<!ATTLIST substeps    %substeps.attributes;>



<!--                    LONG NAME: Sub-step                        -->
<!ENTITY % substep.content
                       "((%note;)*,
                         %cmd;, 
                         (%info; | 
                          %itemgroup; |
                          %stepxmp; | 
                          %tutorialinfo;)*, 
                         (%stepresult;)? )"
>
<!ENTITY % substep.attributes
             "importance 
                        (optional | 
                         required | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              %univ-atts-no-importance-task; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:A <substep> element has the same structure as a <step>, except that it does not allow lists of choices or substeps within it, in order to prevent unlimited nesting of steps.
Category: Task elements-->
<!ELEMENT substep    %substep.content;>
<!ATTLIST substep    %substep.attributes;>


<!--                    LONG NAME: Tutorial Information            -->
<!ENTITY % tutorialinfo.content
                       "(%itemgroup.cnt;)*"
>
<!ENTITY % tutorialinfo.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The tutorial info (<tutorialinfo>) element contains additional information that is useful when the task is part of a tutorial.
Category: Task elements-->
<!ELEMENT tutorialinfo    %tutorialinfo.content;>
<!ATTLIST tutorialinfo    %tutorialinfo.attributes;>



<!--                    LONG NAME: Step Example                    -->
<!ENTITY % stepxmp.content
                       "(%itemgroup.cnt;)*"
>
<!ENTITY % stepxmp.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The step example (<stepxmp>) element is used to illustrate a step of a task. The example can be a couple of words, or an entire paragraph.
Category: Task elements-->
<!ELEMENT stepxmp    %stepxmp.content;>
<!ATTLIST stepxmp    %stepxmp.attributes;>



<!--                    LONG NAME: Choices                         -->
<!ENTITY % choices.content
                       "(%choice;)+"
>
<!ENTITY % choices.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <choices> element contains a list of <choice> elements. It is used when the user will need to choose one of several actions while performing the steps of a task.
Category: Task elements-->
<!ELEMENT choices    %choices.content;>
<!ATTLIST choices    %choices.attributes;>


<!--                    LONG NAME: Choice                          -->
<!ENTITY % choice.content
                       "(%listitem.cnt;)*"
>
<!ENTITY % choice.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:Each <choice> element describes one way that the user could accomplish the current step.
Category: Task elements-->
<!ELEMENT choice    %choice.content;>
<!ATTLIST choice    %choice.attributes;>



<!--                    LONG NAME: Choice Table                    -->
<!ENTITY % choicetable.content
                       "((%chhead;)?, 
                         (%chrow;)+ )"
>
<!ENTITY % choicetable.attributes
             "relcolwidth 
                        CDATA 
                                  #IMPLIED
              keycol 
                        NMTOKEN 
                                  '1'
              refcols 
                        NMTOKENS 
                                  #IMPLIED
              spectitle 
                        CDATA 
                                  #IMPLIED
              %display-atts;
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <choicetable> element contains a series of optional choices available within a step of a task.
Category: Task elements-->
<!ELEMENT choicetable    %choicetable.content;>
<!ATTLIST choicetable    %choicetable.attributes;>



<!--                    LONG NAME: Choice Head                     -->
<!ENTITY % chhead.content
                       "((%choptionhd;), 
                         (%chdeschd;) )"
>
<!ENTITY % chhead.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <chhead> element is a container inside the <choicetable> element that provides specific heading text to override the default Options and Description headings. The <chhead> element contains both a <choptionhd> and <chdeschd> element as a pair.
Category: Task elements-->
<!ELEMENT chhead    %chhead.content;>
<!ATTLIST chhead    %chhead.attributes;>



<!--                    LONG NAME: Choice Option Head              -->
<!ENTITY % choptionhd.content
                       "(%tblcell.cnt;)*"
>
<!ENTITY % choptionhd.attributes
             "specentry 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <choptionhd> element provides a specific label for the list of options that a user chooses from to accomplish a step. The default label for options is Option.
Category: Task elements-->
<!ELEMENT choptionhd    %choptionhd.content;>
<!ATTLIST choptionhd    %choptionhd.attributes;>



<!--                    LONG NAME: Choice Description Head         -->
<!ENTITY % chdeschd.content
                       "(%tblcell.cnt;)*"
>
<!ENTITY % chdeschd.attributes
             "specentry 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <chdeschd> option provides a specific label for the list of descriptions of options that a user must choose to accomplish a step of a task. The default label overridden by <chdeschd> is Description.
Category: Task elements-->
<!ELEMENT chdeschd    %chdeschd.content;>
<!ATTLIST chdeschd    %chdeschd.attributes;>



<!--                    LONG NAME: Choice Row                      -->
<!ENTITY % chrow.content
                       "((%choption;), 
                         (%chdesc;))"
>
<!ENTITY % chrow.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <chrow> element is a container inside the <choicetable> element. The <chrow> element contains both a <choption> and <chdesc> element as a pair.
Category: Task elements-->
<!ELEMENT chrow    %chrow.content;>
<!ATTLIST chrow    %chrow.attributes;>



<!--                    LONG NAME: Choice Option                   -->
<!ENTITY % choption.content
                       "(%tblcell.cnt;)*
">
<!ENTITY % choption.attributes
             "specentry 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <choption> element describes an option that a user could choose to accomplish a step of a task. In a user interface, for example, this might be the name of radio button.
Category: Task elements-->
<!ELEMENT choption    %choption.content;>
<!ATTLIST choption    %choption.attributes;>



<!--                    LONG NAME: Choice Description              -->
<!ENTITY % chdesc.content
                       "(%tblcell.cnt;)*
">
<!ENTITY % chdesc.attributes
             "specentry 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <chdesc> element is a description of an option that a user chooses while performing a step to accomplish a task. It explains why the user would choose that option, and might explain the result of the choice when it is not immediately obvious.
Category: Task elements-->
<!ELEMENT chdesc    %chdesc.content;>
<!ATTLIST chdesc    %chdesc.attributes;>



<!--                    LONG NAME: Step Result                     -->
<!ENTITY % stepresult.content
                       "(%itemgroup.cnt;)*"
>
<!ENTITY % stepresult.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <stepresult> element provides information on the expected outcome of a step. If a user interface is being documented, the outcome could describe a dialog box opening, or the appearance of a progress indicator. Step results are useful to assure a user that they are on track, but should not be used for every step, as this quickly becomes tedious.
Category: Task elements-->
<!ELEMENT stepresult    %stepresult.content;>
<!ATTLIST stepresult    %stepresult.attributes;>


<!--                    LONG NAME: Result                          -->
<!ENTITY % result.content
                       "(%section.notitle.cnt;)*"
>
<!ENTITY % result.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <result> element describes the expected outcome for the task as a whole.
Category: Task elements-->
<!ELEMENT result    %result.content;>
<!ATTLIST result    %result.attributes;>



<!--                    LONG NAME: Post Requirements               -->
<!ENTITY % postreq.content
                       "(%section.notitle.cnt;)*"
>
<!ENTITY % postreq.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <postreq> element describes steps or tasks that the user should do after the successful completion of the current task. It is often supported by links to the next task or tasks in the <related-links> section.
Category: Task elements-->
<!ELEMENT postreq    %postreq.content;>
<!ATTLIST postreq    %postreq.attributes;>

 

<!-- ============================================================= -->
<!--                    SPECIALIZATION ATTRIBUTE DECLARATIONS      -->
<!-- ============================================================= -->


<!ATTLIST task        %global-atts;  class  CDATA "- topic/topic task/task "        >
<!ATTLIST taskbody    %global-atts;  class  CDATA "- topic/body task/taskbody "     >
<!ATTLIST steps       %global-atts;  class  CDATA "- topic/ol task/steps "          >
<!ATTLIST steps-unordered 
                      %global-atts;  class  CDATA "- topic/ul task/steps-unordered ">
<!ATTLIST stepsection %global-atts;  class  CDATA "- topic/li task/stepsection "    >
<!ATTLIST step        %global-atts;  class  CDATA "- topic/li task/step "           >
<!ATTLIST cmd         %global-atts;  class  CDATA "- topic/ph task/cmd "            >
<!ATTLIST substeps    %global-atts;  class  CDATA "- topic/ol task/substeps "       >
<!ATTLIST substep     %global-atts;  class  CDATA "- topic/li task/substep "        >
<!ATTLIST tutorialinfo 
                      %global-atts;  class  CDATA "- topic/itemgroup task/tutorialinfo ">
<!ATTLIST info        %global-atts;  class  CDATA "- topic/itemgroup task/info "    >
<!ATTLIST stepxmp     %global-atts;  class  CDATA "- topic/itemgroup task/stepxmp " >
<!ATTLIST stepresult  %global-atts;  class  CDATA "- topic/itemgroup task/stepresult ">

<!ATTLIST choices     %global-atts;  class  CDATA "- topic/ul task/choices "        >
<!ATTLIST choice      %global-atts;  class  CDATA "- topic/li task/choice "         >
<!ATTLIST result      %global-atts;  class  CDATA "- topic/section task/result "    >
<!ATTLIST prereq      %global-atts;  class  CDATA "- topic/section task/prereq "    >
<!ATTLIST postreq     %global-atts;  class  CDATA "- topic/section task/postreq "   >
<!ATTLIST context     %global-atts;  class  CDATA "- topic/section task/context "   >
<!ATTLIST steps-informal %global-atts; class CDATA "- topic/section task/steps-informal ">

<!ATTLIST choicetable %global-atts;  class  CDATA "- topic/simpletable task/choicetable ">
<!ATTLIST chhead      %global-atts;  class  CDATA "- topic/sthead task/chhead "     >
<!ATTLIST chrow       %global-atts;  class  CDATA "- topic/strow task/chrow "       >
<!ATTLIST choptionhd  %global-atts;  class  CDATA "- topic/stentry task/choptionhd ">
<!ATTLIST chdeschd    %global-atts;  class  CDATA "- topic/stentry task/chdeschd "  >
<!ATTLIST choption    %global-atts;  class  CDATA "- topic/stentry task/choption "  >
<!ATTLIST chdesc      %global-atts;  class  CDATA "- topic/stentry task/chdesc "    >

 
<!-- ================== End DITA Task  =========================== -->
