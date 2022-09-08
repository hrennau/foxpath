<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================================= -->
<!--                    HEADER                                     -->
<!-- ============================================================= -->
<!--  MODULE:    Task Requirements Domain                          -->
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
PUBLIC "-//OASIS//ELEMENTS DITA Task Requirements Domain//EN"
      Delivered as file "taskreqDomain.mod"                        -->

<!-- ============================================================= -->
<!-- SYSTEM:     Darwin Information Typing Architecture (DITA)     -->
<!--                                                               -->
<!-- PURPOSE:    Define elements and specialization atttributes    -->
<!--             for the Task Requirements Domain                  -->
<!--                                                               -->
<!-- ORIGINAL CREATION DATE:                                       -->
<!--             September 2007                                    -->
<!--                                                               -->
<!--             (C) Copyright OASIS Open 2007, 2009.              -->
<!--             All Rights Reserved.                              -->
<!--  UPDATES:                                                     -->
<!--    2009.10.20 CHK: Make safecond unbound               -->
<!-- ============================================================= -->


<!-- ============================================================= -->
<!--                    ELEMENT NAME ENTITIES                      -->
<!-- ============================================================= -->


<!ENTITY % prelreqs    	 "prelreqs"                                  >
<!ENTITY % closereqs     "closereqs"                                 >
<!ENTITY % reqconds      "reqconds"                                  >
<!ENTITY % noconds       "noconds"                                   >
<!ENTITY % reqcond       "reqcond"                                   >
<!ENTITY % reqcontp      "reqcontp"                                  >
<!ENTITY % reqpers       "reqpers"                                   >
<!ENTITY % personnel     "personnel"                                 >
<!ENTITY % perscat       "perscat"                                   >
<!ENTITY % perskill      "perskill"                                  >
<!ENTITY % esttime       "esttime"                                   >
<!ENTITY % supequip      "supequip"                                  >
<!ENTITY % nosupeq       "nosupeq"                                   >
<!ENTITY % supeqli       "supeqli"                                   >
<!ENTITY % supequi       "supequi"                                   >
<!ENTITY % supplies      "supplies"                                  >
<!ENTITY % nosupply      "nosupply"                                  >
<!ENTITY % supplyli      "supplyli"                                  >
<!ENTITY % supply        "supply"                                    >
<!ENTITY % spares        "spares"                                    >
<!ENTITY % nospares      "nospares"                                  >
<!ENTITY % sparesli      "sparesli"                                  >
<!ENTITY % spare         "spare"                                     >
<!ENTITY % safety        "safety"                                    >
<!ENTITY % nosafety      "nosafety"                                  >
<!ENTITY % safecond      "safecond"                                  >

<!-- ============================================================= -->
<!--                    ELEMENT DECLARATIONS                       -->
<!-- ============================================================= -->
 
<!--                    LONG NAME: Preliminary Requirements        -->
<!ENTITY % prelreqs.content
                       "((%reqconds;)?, 
                         (%reqpers;)?, 
                         (%supequip;)?, 
                         (%supplies;)?,
                         (%spares;)?,
                         (%safety;)?)"
>
<!ENTITY % prelreqs.attributes
             "%univ-atts; 
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The preliminary-requirements (<prelreqs>) section of a task should document things the user needs to know or do before starting the current task. The <prelreqs> element is similar to <prereq> but contains a more descriptive content model then <prereq>.-->
<!ELEMENT prelreqs    %prelreqs.content;>
<!ATTLIST prelreqs    %prelreqs.attributes;>


<!--                    LONG NAME: Closing Requirements        -->
<!ENTITY % closereqs.content
                       "(%reqconds;)"
>
<!ENTITY % closereqs.attributes
             "%univ-atts; 
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The closing-requirements (<closereqs>) element describes steps or tasks that the user should do after the successful completion of the current task. closereqs is similar to postreq but contains a more descriptive content model then postreq and has been developed basically to meet the requirements in the machinery industry.-->
<!ELEMENT closereqs    %closereqs.content;>
<!ATTLIST closereqs    %closereqs.attributes;>

<!--                    LONG NAME: Required Conditions             -->
<!ENTITY % reqconds.content
                       "((%noconds;) |
						  ((%reqcond;) |
                           (%reqcontp;))+)"
>
<!ENTITY % reqconds.attributes
             "%univ-atts; 
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The required-conditions (<reqconds>) element contains the description of all required conditions that have to be fulfilled before performing a task.-->
<!ELEMENT reqconds    %reqconds.content;>
<!ATTLIST reqconds    %reqconds.attributes;>

<!--                    LONG NAME: No Required Conditions            --><!-- specialized from li -->
<!ENTITY % noconds.content
                       "EMPTY"
>
<!ENTITY % noconds.attributes
             "%univ-atts;
              outputclass 
                        CDATA
                                  #IMPLIED    ">
<!--doc:The No-Required-Condition (<noconds>) element has to be used when there is no required condition. The information that no condition is required is as important as the information which conditions are required.-->
<!ELEMENT noconds    %noconds.content;>
<!ATTLIST noconds    %noconds.attributes;>


<!--                    LONG NAME: Required Condition                 --><!-- specialized from li -->
<!ENTITY % reqcond.content
                       "(%listitem.cnt;)*"
>
<!ENTITY % reqcond.attributes
             "%univ-atts;
              outputclass 
                        CDATA
                                  #IMPLIED    ">
<!--doc:The Required-Condition (<reqcond>) element has to be used to describe the required condition.-->
<!ELEMENT reqcond    %reqcond.content;>
<!ATTLIST reqcond    %reqcond.attributes;>


<!--                    LONG NAME: Required Condition Technical Publication  --><!-- specialized from li -->
<!ENTITY % reqcontp.content
                       "(%listitem.cnt;)*"
>
<!ENTITY % reqcontp.attributes
             "%univ-atts;
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The Required-Condition-Technical-Publication (<reqcontp>) element has to be used to list or describe further applicable documents.-->
<!ELEMENT reqcontp    %reqcontp.content;>
<!ATTLIST reqcontp    %reqcontp.attributes;>
 
<!--                    LONG NAME: Required Persons                --><!-- specialized from ol -->
<!ENTITY % reqpers.content
                       "((%personnel;),
						 ((%perscat;)?,
                          (%perskill;)?,
                          (%esttime;)?)?)+
">
<!ENTITY % reqpers.attributes
             "%univ-atts; 
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The Required-Personnel (<reqpers>) element contains information on the personnel required for the task.-->
<!ELEMENT reqpers    %reqpers.content;>
<!ATTLIST reqpers    %reqpers.attributes;>

 

<!--                    LONG NAME: Personnel                       --><!-- specialized from li -->
<!ENTITY % personnel.content
                       "(%listitem.cnt;)*"
>
<!ENTITY % personnel.attributes
             "%univ-atts;
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <personnel> element indicates the number of personnel required for the task.-->
<!ELEMENT personnel    %personnel.content;>
<!ATTLIST personnel    %personnel.attributes;>


<!--                    LONG NAME: Personnel Category               --><!-- specialized from li -->
<!ENTITY % perscat.content
                       "(%listitem.cnt;)*"
>
<!ENTITY % perscat.attributes
             "%univ-atts;
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The Personnel-Category (<perscat>) element contains the required category level of the person.-->
<!ELEMENT perscat    %perscat.content;>
<!ATTLIST perscat    %perscat.attributes;>


<!--                    LONG NAME: Personnel Skill Level             --><!-- specialized from li -->
<!ENTITY % perskill.content
                       "(%listitem.cnt;)*"
>
<!ENTITY % perskill.attributes
             "%univ-atts;
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The Personnel-Skill-Level (<perskill>) element describes the required skill level of the person.-->
<!ELEMENT perskill    %perskill.content;>
<!ATTLIST perskill    %perskill.attributes;>


<!--                    LONG NAME: Esttime                      --><!-- specialized from li -->
<!ENTITY % esttime.content
                       "(%listitem.cnt;)*"
>
<!ENTITY % esttime.attributes
             "%univ-atts;
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The Estimated-Time-Spent (<esttime>) element contains information on the estimated time required for a task.-->
<!ELEMENT esttime    %esttime.content;>
<!ATTLIST esttime    %esttime.attributes;>



<!--                    LONG NAME: Support Equipment             --><!-- specialized from p -->
<!ENTITY % supequip.content
                       "((%nosupeq;)|
                         (%supeqli;))"
>
<!ENTITY % supequip.attributes
             "%univ-atts; 
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The Support-Equipment (<supequip>) element lists any required support equipment for the task, along with optional descriptions.-->
<!ELEMENT supequip    %supequip.content;>
<!ATTLIST supequip    %supequip.attributes;>

<!--                    LONG NAME: No Support Equipment            --><!-- specialized from data -->
<!ENTITY % nosupeq.content
                       "EMPTY"
>
<!ENTITY % nosupeq.attributes
             "%data-element-atts;"
>
<!--doc:The No-Support-Equipment (<nosupeq>) element has to be used when there is no support equipment required. The information that no support equipment is required is as important as the information which support equipment is required.-->
<!ELEMENT nosupeq    %nosupeq.content;>
<!ATTLIST nosupeq    %nosupeq.attributes;>

<!--                    LONG NAME: Support Equipment List          --><!-- specialized from ul -->
<!ENTITY % supeqli.content
                       "(%supequi;)+"
>
<!ENTITY % supeqli.attributes
             "compact
                        (yes |
                         no | 
                         -dita-use-conref-target)
                                  #IMPLIED
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The Support-Equipment-List (<supeqli>) element has to be used to list any support equipment required for the task.-->
<!ELEMENT supeqli    %supeqli.content;>
<!ATTLIST supeqli    %supeqli.attributes;>


<!--                    LONG NAME: Support Equipment Item          --><!-- specialized from li -->
<!ENTITY % supequi.content
                       "(%listitem.cnt;)*"
>
<!ENTITY % supequi.attributes
             "%univ-atts;
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The Support-Equipment-Item (<supequi>) element describes the support equipment.-->
<!ELEMENT supequi    %supequi.content;>
<!ATTLIST supequi    %supequi.attributes;>



 <!--                    LONG NAME: Supplies             --><!-- specialized from p -->
<!ENTITY % supplies.content
                       "((%nosupply;) |
                         (%supplyli;))"
>
<!ENTITY % supplies.attributes
             "%univ-atts; 
               outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <supplies> element has to be used to list and maybe to describe any supplies required for the task.-->
<!ELEMENT supplies    %supplies.content;>
<!ATTLIST supplies    %supplies.attributes;>


<!--                    LONG NAME: No Supplies            --><!-- specialized from data -->
<!ENTITY % nosupply.content
                       "EMPTY"
>
<!ENTITY % nosupply.attributes
             "%data-element-atts;"
>
<!--doc:The No-Supplies (<nosupply>) element has to be used when there are no supplies required. The information that no supplies are required is as important as the information which supplies are is required.-->
<!ELEMENT nosupply    %nosupply.content;>
<!ATTLIST nosupply    %nosupply.attributes;>


<!--                    LONG NAME: Supply List          --><!-- specialized from ul -->
<!ENTITY % supplyli.content
                       "(%supply;)+"
>
<!ENTITY % supplyli.attributes
             "compact
                        (yes |
                         no | 
                         -dita-use-conref-target)
                                  #IMPLIED
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The Supply-List (<supplyli>) element has to be used to list any supplies required for the task.-->
<!ELEMENT supplyli    %supplyli.content;>
<!ATTLIST supplyli    %supplyli.attributes;>


<!--                    LONG NAME: Supply Item          --><!-- specialized from li -->
<!ENTITY % supply.content
                       "(%listitem.cnt;)*"
>
<!ENTITY % supply.attributes
             "%univ-atts;
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <supply> element describes the supply.-->
<!ELEMENT supply    %supply.content;>
<!ATTLIST supply    %supply.attributes;>


 <!--                    LONG NAME: Spares             --><!-- specialized from p -->
<!ENTITY % spares.content
                       "((%nospares;) |
                        (%sparesli;))"
>
<!ENTITY % spares.attributes
             "%univ-atts; 
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <spares> element lists spare parts required for a task, and may include descriptions of those parts.-->
<!ELEMENT spares    %spares.content;>
<!ATTLIST spares    %spares.attributes;>


<!--                    LONG NAME: No Spares            --><!-- specialized from data -->
<!ENTITY % nospares.content
                       "EMPTY"
>
<!ENTITY % nospares.attributes
             "%data-element-atts;"
>
<!--doc:The No-Spares (<nospares>) element has to be used when there are no spares required for the task. As the information that no spares are required is as important as the information which spare is required.-->
<!ELEMENT nospares    %nospares.content;>
<!ATTLIST nospares    %nospares.attributes;>


<!--                    LONG NAME: Spare List          --><!-- specialized from ul -->
<!ENTITY % sparesli.content
                       "(%spare;)+"
>
<!ENTITY % sparesli.attributes
             "compact
                        (yes |
                         no | 
                         -dita-use-conref-target)
                                  #IMPLIED
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The Spares-List (<sparesli>) element has to be used to list any spares required for the task.-->
<!ELEMENT sparesli    %sparesli.content;>
<!ATTLIST sparesli    %sparesli.attributes;>


<!--                    LONG NAME: Spare Item          --><!-- specialized from li -->
<!ENTITY % spare.content
                       "(%listitem.cnt;)*"
>
<!ENTITY % spare.attributes
             "%univ-atts;
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The spare element describes a spare part required for the task, and may include a description of the part.-->
<!ELEMENT spare    %spare.content;>
<!ATTLIST spare    %spare.attributes;>


<!--                    LONG NAME: Safety Conditions             --><!-- specialized from ol -->
<!ENTITY % safety.content
                       "((%nosafety;) |
                         (%safecond;)+)">
<!ENTITY % safety.attributes
             "%univ-atts; 
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The Safety-Condition (<safety>) element has to be used to list and maybe to describe any safety condition that has to be taken in account for the task.-->
<!ELEMENT safety    %safety.content;>
<!ATTLIST safety    %safety.attributes;>


<!--                    LONG NAME: No Safety Conditions            --><!-- specialized from li -->
<!ENTITY % nosafety.content
                       "EMPTY"
>
<!ENTITY % nosafety.attributes
             "%univ-atts;
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The No-Safety-Conditions (<nosafety>) element has to be used to indicate that there are no safety requirements for the task. The information that no safety requirements have to be taken in account is as important as the information which safety conditions has to be considered.-->
<!ELEMENT nosafety    %nosafety.content;>
<!ATTLIST nosafety    %nosafety.attributes;>

<!--                    LONG NAME: Safety Condition                 --><!-- specialized from li -->
<!ENTITY % safecond.content
                       "(%listitem.cnt;)*"
>
<!ENTITY % safecond.attributes
             "%univ-atts;
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The Safety-Conditions (<safecond>) element has to be used if there are safety requirements.-->
<!ELEMENT safecond    %safecond.content;>
<!ATTLIST safecond    %safecond.attributes;>


<!-- ============================================================= -->
<!--                    SPECIALIZATION ATTRIBUTE DECLARATIONS      -->
<!-- ============================================================= -->


<!ATTLIST prelreqs    %global-atts;  class  CDATA "+ topic/section task/prereq taskreq-d/prelreqs "  >
<!ATTLIST closereqs   %global-atts;  class  CDATA "+ topic/section task/postreq taskreq-d/closereqs " >
<!ATTLIST reqconds    %global-atts;  class  CDATA "+ topic/ol task/ol taskreq-d/reqconds "       >
<!ATTLIST noconds     %global-atts;  class  CDATA "+ topic/li task/li taskreq-d/noconds "        >
<!ATTLIST reqcond     %global-atts;  class  CDATA "+ topic/li task/li taskreq-d/reqcond "        >
<!ATTLIST reqcontp    %global-atts;  class  CDATA "+ topic/li task/li taskreq-d/reqcontp "       >
<!ATTLIST reqpers     %global-atts;  class  CDATA "+ topic/ol task/ol taskreq-d/reqpers "        >
<!ATTLIST personnel   %global-atts;  class  CDATA "+ topic/li task/li taskreq-d/personnel "      >
<!ATTLIST perscat     %global-atts;  class  CDATA "+ topic/li task/li taskreq-d/perscat "        >
<!ATTLIST perskill    %global-atts;  class  CDATA "+ topic/li task/li taskreq-d/perskill "       >
<!ATTLIST esttime     %global-atts;  class  CDATA "+ topic/li task/li taskreq-d/esttime "        >
<!ATTLIST supequip    %global-atts;  class  CDATA "+ topic/p task/p taskreq-d/supequip "        >
<!ATTLIST nosupeq     %global-atts;  class  CDATA "+ topic/data task/data taskreq-d/nosupeq "      >
<!ATTLIST supeqli     %global-atts;  class  CDATA "+ topic/ul task/ul taskreq-d/supeqli "        >
<!ATTLIST supequi     %global-atts;  class  CDATA "+ topic/li task/li taskreq-d/supequi "        >
<!ATTLIST supplies    %global-atts;  class  CDATA "+ topic/p task/p taskreq-d/supplies "        >
<!ATTLIST nosupply    %global-atts;  class  CDATA "+ topic/data task/data taskreq-d/nosupply "     >
<!ATTLIST supplyli    %global-atts;  class  CDATA "+ topic/ul task/ul taskreq-d/supplyli "       >
<!ATTLIST supply      %global-atts;  class  CDATA "+ topic/li task/li taskreq-d/supply "         >
<!ATTLIST spares      %global-atts;  class  CDATA "+ topic/p task/p taskreq-d/spares "          >
<!ATTLIST nospares    %global-atts;  class  CDATA "+ topic/data task/data taskreq-d/nospares "     >
<!ATTLIST sparesli    %global-atts;  class  CDATA "+ topic/ul task/ul taskreq-d/sparesli "       >
<!ATTLIST spare       %global-atts;  class  CDATA "+ topic/li task/li taskreq-d/spare "          >
<!ATTLIST safety      %global-atts;  class  CDATA "+ topic/ol task/ol taskreq-d/safety "         >
<!ATTLIST nosafety    %global-atts;  class  CDATA "+ topic/li task/li taskreq-d/nosafety "       >
<!ATTLIST safecond    %global-atts;  class  CDATA "+ topic/li task/li taskreq-d/safecond "       >

<!-- ================== End DITA Task Requirements Domain  ==================== -->
