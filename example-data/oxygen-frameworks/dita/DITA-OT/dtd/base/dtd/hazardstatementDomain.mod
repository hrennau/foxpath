<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================================= -->
<!--                    HEADER                                     -->
<!-- ============================================================= -->
<!--  MODULE:    DITA Hazard Statement Domain                      -->
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
PUBLIC "-//OASIS//ELEMENTS DITA Hazard Statement Domain//EN"
      Delivered as file "hazardstatementDomain.mod"                -->

<!-- ============================================================= -->
<!-- SYSTEM:     Darwin Information Typing Architecture (DITA)     -->
<!--                                                               -->
<!-- PURPOSE:    Declaring the elements and specialization         -->
<!--             attributes for the Hazard Statement Domain        -->
<!--                                                               -->
<!-- ORIGINAL CREATION DATE:                                       -->
<!--             February 2008                                     -->
<!--                                                               -->
<!--             (C) Copyright OASIS Open 2008, 2009.              -->
<!--             All Rights Reserved.                              -->
<!--                                                               -->
<!--  UPDATES:                                                     -->
<!--    2007.02.20 Chris Kravogel, SeicoDyne GmbH: Created domain  -->
<!--    2007.03.06 Chris Kravogel, SeicoDyne GmbH: Add howtoavoid  -->
<!--                    entity                                     -->
<!--    2007.11.20 Chris Kravogel, SeicoDyne GmbH: Reduced ATTLIST -->
<!--                    of hazardstatement to ATTLIST of note      -->
<!--    2008.02.05 Chris Kravogel, SeicoDyne GmbH: Renamed symbol  -->
<!--                    to hazardsymbol, added %words.cnt; and     -->
<!--                    %trademark; to consequences, typeofhazard  -->
<!--    2008.02.05 RDA: Reformatted for DITA 1.2; removed @alt     -->
<!--                    and added @scalefit on hazardsymbol        -->
<!--    2008.02.13 RDA: Create .content and .attributes entities   -->
<!--    2009.12.03 RDA: Removed caution1 and caution2 values to    -->
<!--                    match the revised note/@type values        -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!--                    COMMON ATTLIST SETS                        -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!--                    Hazard Statement Entities                  -->
<!-- ============================================================= -->

<!ENTITY % hazard.cnt 
  "#PCDATA | 
   %basic.ph; | 
   %sl; | 
   %simpletable;"
>

<!-- ============================================================= -->
<!--                   ELEMENT NAME ENTITIES                       -->
<!-- ============================================================= -->

 
<!ENTITY % hazardstatement "hazardstatement"                         >
<!ENTITY % messagepanel    "messagepanel"                            >
<!ENTITY % hazardsymbol    "hazardsymbol"                            >
<!ENTITY % typeofhazard    "typeofhazard"                            >
<!ENTITY % consequence     "consequence"                             >
<!ENTITY % howtoavoid      "howtoavoid"                              >

<!-- ============================================================= -->
<!--            HAZARDSTATEMENT KEYWORD TYPES ELEMENT DECLARATIONS -->
<!-- ============================================================= -->


<!--                    LONG NAME: Hazard Statement                -->
<!ENTITY % hazardstatement.content
                       "((%messagepanel;)+,
                         (%hazardsymbol;)*)"
>
<!ENTITY % hazardstatement.attributes
             "type 
                        (attention|
                         caution | 
                         danger | 
                         fastpath | 
                         important | 
                         note |
                         notice |
                         other | 
                         remember | 
                         restriction |
                         tip |
                         warning |
                         -dita-use-conref-target) 
                                  #IMPLIED 
              spectitle 
                        CDATA 
                                  #IMPLIED
              othertype 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <hazardstatement> element contains hazard warning information. It is based on the regulations of the ANSI Z535 and the ISO 3864 standards. It gives the author the opportunity to select the hazard statement, to add one or more safety signs and to add the required phrases.-->
<!ELEMENT hazardstatement    %hazardstatement.content;>
<!ATTLIST hazardstatement    %hazardstatement.attributes;>


<!--                    LONG NAME: Hazard Symbol                   -->
<!ENTITY % hazardsymbol.content
                       "((%alt;)?,
                         (%longdescref;)?)"
>
<!ENTITY % hazardsymbol.attributes
             "href 
                        CDATA 
                                  #REQUIRED

              scope 
                        (external | 
                         local | 
                         peer | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              keyref 
                        CDATA 
                                  #IMPLIED
              longdescref 
                        CDATA 
                                  #IMPLIED
              height 
                        NMTOKEN 
                                  #IMPLIED
              width 
                        NMTOKEN 
                                  #IMPLIED
              align 
                        CDATA 
                                  #IMPLIED
              scale 
                        NMTOKEN 
                                  #IMPLIED
              scalefit
                        (yes |
                         no |
                         -dita-use-conref-target)
                                  #IMPLIED
              placement 
                        (break | 
                         inline | 
                         -dita-use-conref-target) 
                                  'inline'
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:A graphic representation intended to convey a message without the use of words. It may represent a hazard, a hazardous situation, a precaution to avoid a hazard, a result of not avoiding a hazard, or any combination of these messages.-->
<!ELEMENT hazardsymbol    %hazardsymbol.content;>
<!ATTLIST hazardsymbol    %hazardsymbol.attributes;>


<!--                    LONG NAME: Hazard Message panel            -->
<!ENTITY % messagepanel.content
                       "((%typeofhazard;),
                         (%consequence;)*,
                         (%howtoavoid;)+)"
>
<!ENTITY % messagepanel.attributes
             "spectitle 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <messagepanel> element describes the area of a safety sign or label that contains the word message which identifies a hazard, indicates how to avoid the hazard, and advises of the probable consequences of not avoiding the hazard.-->
<!ELEMENT messagepanel    %messagepanel.content;>
<!ATTLIST messagepanel    %messagepanel.attributes;>



<!--                    LONG NAME: The Type of Hazard              -->
<!ENTITY % typeofhazard.content
                   "(%words.cnt; |
                     %ph; |
                     %tm;)*"
>
<!ENTITY % typeofhazard.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <typeofhazard> element is the container for the first text entry of a safety label. It contains the description of the type of hazard, such as "Moving parts can crush and cut".-->
<!ELEMENT typeofhazard    %typeofhazard.content;>
<!ATTLIST typeofhazard    %typeofhazard.attributes;>



<!--            LONG NAME: Consequences of not Avoiding the Hazard -->
<!ENTITY % consequence.content
                       "(%words.cnt; |
                         %ph; | 
                         %tm;)*
">
<!ENTITY % consequence.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <consequence> element is the container for the second text entry of a safety label. It contains the description of the consequences of not avoiding the hazard, such as "Keep guard in place".-->
<!ELEMENT consequence    %consequence.content;>
<!ATTLIST consequence    %consequence.attributes;>


<!--                    LONG NAME: How to Avoid the Hazard         -->
<!ENTITY % howtoavoid.content
                       "(%hazard.cnt;)*
">
<!ENTITY % howtoavoid.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <howtoavoid> element is the container for the third text entry of a safety label. It contains the description of how to avoid the hazard, such as "Lock out power before servicing".-->
<!ELEMENT howtoavoid    %howtoavoid.content;>
<!ATTLIST howtoavoid    %howtoavoid.attributes;>


<!-- ============================================================= -->
<!--               SPECIALIZATION ATTRIBUTE DECLARATIONS           -->
<!-- ============================================================= -->

<!ATTLIST hazardstatement %global-atts;  class CDATA "+ topic/note hazard-d/hazardstatement "> 
<!ATTLIST messagepanel    %global-atts;  class CDATA "+ topic/ul hazard-d/messagepanel "     > 
<!ATTLIST hazardsymbol    %global-atts;  class CDATA "+ topic/image hazard-d/hazardsymbol "  > 
<!ATTLIST typeofhazard    %global-atts;  class CDATA "+ topic/li hazard-d/typeofhazard "     >
<!ATTLIST consequence     %global-atts;  class CDATA "+ topic/li hazard-d/consequence "      >
<!ATTLIST howtoavoid      %global-atts;  class CDATA "+ topic/li hazard-d/howtoavoid "       >
 
<!-- ================== End DITA Hazard Statement Domain ========= -->
