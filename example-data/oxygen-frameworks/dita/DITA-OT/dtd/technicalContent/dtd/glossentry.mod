<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================================= -->
<!--                    HEADER                                     -->
<!-- ============================================================= -->
<!--  MODULE:    DITA Glossary                                     -->
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
PUBLIC "-//OASIS//ELEMENTS DITA Glossary Entry//EN"
      Delivered as file "glossentry.mod"                             -->

<!-- ============================================================= -->
<!-- SYSTEM:     Darwin Information Typing Architecture (DITA)     -->
<!--                                                               -->
<!-- PURPOSE:    Define elements and specialization atttributes    -->
<!--             for Glossary topics                               -->
<!--                                                               -->
<!-- ORIGINAL CREATION DATE:                                       -->
<!--             June 2006                                         -->
<!--                                                               -->
<!--             (C) Copyright OASIS Open 2006, 2009.              -->
<!--             All Rights Reserved.                              -->
<!--                                                               -->
<!--  UPDATES:                                                     -->
<!--    2007.12.01 EK:  Reformatted DTD modules for DITA 1.2       -->
<!--    2008.01.30 RDA: Replace @conref defn. with %conref-atts;   -->
<!--    2008.02.12 RDA: Expand glossary for DITA 1.2               -->
<!--    2008.02.13 RDA: Create .content and .attributes entities   -->
<!--    2009.09.21 WEK: Renamed glossentry.mod                     -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!--                   SPECIALIZATION OF DECLARED ELEMENTS         -->
<!-- ============================================================= -->


<!ENTITY % glossentry-info-types 
  "no-topic-nesting"
>


<!-- ============================================================= -->
<!--                   ELEMENT NAME ENTITIES                       -->
<!-- ============================================================= -->
 

<!ENTITY % glossAbbreviation "glossAbbreviation"                     >
<!ENTITY % glossAcronym "glossAcronym"                               >
<!ENTITY % glossAlt    "glossAlt"                                    >
<!ENTITY % glossAlternateFor "glossAlternateFor"                     >
<!ENTITY % glossBody   "glossBody"                                   >
<!ENTITY % glossdef    "glossdef"                                    >
<!ENTITY % glossentry  "glossentry"                                  >
<!ENTITY % glossPartOfSpeech "glossPartOfSpeech"                     >
<!ENTITY % glossProperty "glossProperty"                             >
<!ENTITY % glossScopeNote "glossScopeNote"                           >
<!ENTITY % glossShortForm "glossShortForm"                           >
<!ENTITY % glossStatus "glossStatus"                                 >
<!ENTITY % glossSurfaceForm "glossSurfaceForm"                       >
<!ENTITY % glossSymbol "glossSymbol"                                 >
<!ENTITY % glossSynonym "glossSynonym"                               >
<!ENTITY % glossterm   "glossterm"                                   >
<!ENTITY % glossUsage  "glossUsage"                                  >


<!-- ============================================================= -->
<!--                    DOMAINS ATTRIBUTE OVERRIDE                 -->
<!-- ============================================================= -->


<!ENTITY included-domains 
  ""
>


<!-- ============================================================= -->
<!--                    ELEMENT DECLARATIONS                       -->
<!-- ============================================================= -->


<!--                    LONG NAME: Glossary Entry                  -->
<!ENTITY % glossentry.content
                       "((%glossterm;), 
                         (%glossdef;)?, 
                         (%prolog;)?, 
                         (%glossBody;)?, 
                         (%related-links;)?,
                         (%glossentry-info-types;)* )"
>
<!ENTITY % glossentry.attributes
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
<!--doc:The <glossentry> element defines a single sense of a glossary term. The expected book processing is to sort and group the glossary entries based on the localized term so a back-of-the-book glossary can contain a collated list of terms with the definitions of the senses of the terms indented under the terms. The glossary can have a different organization in different languages depending on the translation of the terms. One possible online processing is to associate a hotspot for mentions of terms in <term> elements and display the definition on hover or click. Glossary entries for different term senses can be reused independently of one another.
Category: Glossentry elements-->
<!ELEMENT glossentry    %glossentry.content;>
<!ATTLIST glossentry    
              %glossentry.attributes;
              %arch-atts;
              domains 
                        CDATA 
                                  "&included-domains;"
>

<!--                    LONG NAME: Glossary Term                   -->
<!ENTITY % glossterm.content
                       "(%title.cnt;)*"
>
<!ENTITY % glossterm.attributes
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
<!--doc:The <glossterm> element specifies the preferred term associated with a definition of a sense. If the same term has multiple senses, create a separate <glossentry> topic for each sense.
Category: Glossentry elements-->
<!ELEMENT glossterm    %glossterm.content;>
<!ATTLIST glossterm    %glossterm.attributes;>

 
<!--                    LONG NAME: Glossary Definition             -->
<!ENTITY % glossdef.content
                       "(%abstract.cnt;)*"
>
<!ENTITY % glossdef.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <glossdef> element specifies the definition of one sense of a term. If a term has multiple senses, create a separate <glossentry> topic to define each sense.
Category: Glossentry elements-->
<!ELEMENT glossdef    %glossdef.content;>
<!ATTLIST glossdef    %glossdef.attributes;>


<!--                    LONG NAME: Glossary Body                   -->
<!ENTITY % glossBody.content
                       "((%glossPartOfSpeech;)?,
                         (%glossStatus;)?,
                         (%glossProperty;)*,
                         (%glossSurfaceForm;)?,
                         (%glossUsage;)?,
                         (%glossScopeNote;)?,
                         (%glossSymbol;)*,
                         (%note;)*,
                         (%glossAlt;)*)"
>
<!ENTITY % glossBody.attributes
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
<!--doc:The <glossbody> element is used to provide details about a glossary term (such as part of speech or additional forms of the term).-->
<!ELEMENT glossBody    %glossBody.content;>
<!ATTLIST glossBody    %glossBody.attributes;>


<!--                    LONG NAME: Glossary Abbreviation           -->
<!ENTITY % glossAbbreviation.content
                       "(#PCDATA |
                         %keyword; |
                         %term; |
                         %tm;)*"
>
<!ENTITY % glossAbbreviation.attributes
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
<!--doc:The <glossAbbreviation> element provides an abbreviated form of the term contained in a <glossterm> element.-->
<!ELEMENT glossAbbreviation    %glossAbbreviation.content;>
<!ATTLIST glossAbbreviation    %glossAbbreviation.attributes;>


<!--                    LONG NAME: Glossary Acronym                -->
<!ENTITY % glossAcronym.content
                       "(#PCDATA |
                         %keyword; |
                         %term; |
                         %tm;)*"
>
<!ENTITY % glossAcronym.attributes
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
<!--doc:The <glossAcronym> element defines an acronym as an alternate form for the term defined in the <glossterm> element.-->
<!ELEMENT glossAcronym    %glossAcronym.content;>
<!ATTLIST glossAcronym    %glossAcronym.attributes;>


<!--                    LONG NAME: Glossary Short Form             -->
<!ENTITY % glossShortForm.content
                       "(#PCDATA |
                         %keyword; |
                         %term; |
                         %tm;)*"
>
<!ENTITY % glossShortForm.attributes
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
<!--doc:The <glossShortForm> element provides a shorter alternative to the primary term specified in the <glossterm> element.-->
<!ELEMENT glossShortForm    %glossShortForm.content;>
<!ATTLIST glossShortForm    %glossShortForm.attributes;>


<!--                    LONG NAME: Glossary Synonym                -->
<!ENTITY % glossSynonym.content
                       "(#PCDATA |
                         %keyword; |
                         %term; |
                         %tm;)*"
>
<!ENTITY % glossSynonym.attributes
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
<!--doc:Provides a term that is a synonym of the primary value in the <glossterm> element.-->
<!ELEMENT glossSynonym    %glossSynonym.content;>
<!ATTLIST glossSynonym    %glossSynonym.attributes;>


<!--                    LONG NAME: Part of Speech                  -->
<!ENTITY % glossPartOfSpeech.content
                       "EMPTY
">
<!ENTITY % glossPartOfSpeech.attributes
             "%data-element-atts;"
>
<!--doc:Identifies the part of speech for the preferred and alternate terms. Alternate terms must have the same part of speech as the preferred term because all terms in the glossentry topic designate the same subject. If the part of speech isn't specified, the default is a noun for the standard enumeration.-->
<!ELEMENT glossPartOfSpeech    %glossPartOfSpeech.content;>
<!ATTLIST glossPartOfSpeech    %glossPartOfSpeech.attributes;>


<!--                    LONG NAME: Glossary Status                 -->
<!ENTITY % glossStatus.content
                       "EMPTY
">
<!ENTITY % glossStatus.attributes
             "%data-element-atts;"
>
<!--doc:Identifies the usage status of a preferred or alternate term. If the status isn't specified, the <glossterm> provides a preferred term and an alternate term provides an allowed term.-->
<!ELEMENT glossStatus    %glossStatus.content;>
<!ATTLIST glossStatus    %glossStatus.attributes;>


<!--                    LONG NAME: Glossary Status                 -->
<!ENTITY % glossProperty.content
                       "(%data.cnt;)*
">
<!ENTITY % glossProperty.attributes
             "%data-element-atts;"
>
<!--doc:The <glossProperty> element is an extension point which allows additional details about the preferred term or its subject.-->
<!ELEMENT glossProperty    %glossProperty.content;>
<!ATTLIST glossProperty    %glossProperty.attributes;>


<!--                    LONG NAME: Glossary Surface Form           -->
<!ENTITY % glossSurfaceForm.content
                       "(#PCDATA |
                         %keyword; |
                         %term; |
                         %tm;)*
">
<!ENTITY % glossSurfaceForm.attributes
             "%univ-atts;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <glossSurfaceForm> element specifies an unambiguous presentation of the <glossterm> that may combine multiple forms. The surface form is suitable to introduce the term in new contexts.-->
<!ELEMENT glossSurfaceForm    %glossSurfaceForm.content;>
<!ATTLIST glossSurfaceForm    %glossSurfaceForm.attributes;>


<!--                    LONG NAME: Glossary Usage                  -->
<!ENTITY % glossUsage.content
                       "(%note.cnt;)*"
>
<!ENTITY % glossUsage.attributes
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
              othertype 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <glossUsage> element provides information about the correct use of a term, such as where or how it can be used.-->
<!ELEMENT glossUsage    %glossUsage.content;>
<!ATTLIST glossUsage    %glossUsage.attributes;>


<!--                    LONG NAME: Glossary Scope Note             -->
<!ENTITY % glossScopeNote.content
                       "(%note.cnt;)*"
>
<!ENTITY % glossScopeNote.attributes
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
              othertype 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:A clarification of the subject designated by the <glossterm> such as examples of included or excluded companies or products. For instance, a scope note for "Linux" might explain that the term doesn't apply to UNIX products and give some examples of Linux products that are included as well as UNIX products that are excluded.-->
<!ELEMENT glossScopeNote    %glossScopeNote.content;>
<!ATTLIST glossScopeNote    %glossScopeNote.attributes;>


<!--                    LONG NAME: Glossary Symbol                 -->
<!ENTITY % glossSymbol.content
                       "((%alt;)?,
                         (%longdescref;)?)
">
<!ENTITY % glossSymbol.attributes
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
<!--doc:The <glossSymbol> element identifies a standard image associated with the subject of the <glossterm>.-->
<!ELEMENT glossSymbol    %glossSymbol.content;>
<!ATTLIST glossSymbol    %glossSymbol.attributes;>


<!--                    LONG NAME: Glossary Alternate Form         -->
<!ENTITY % glossAlt.content
                       "((%glossAbbreviation; |
                          %glossAcronym; |
                          %glossShortForm; |
                          %glossSynonym;)?,
                         (%glossStatus;)?,
                         (%glossProperty;)*,
                         (%glossUsage;)?,
                         (%note;)*,
                         (%glossAlternateFor;)*)

">
<!ENTITY % glossAlt.attributes
             "%univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <glossAlt> element contains a variant term for the preferred term. The variant should have the same meaning as the term in the <glossterm> element; the variant is simply another way to refer to the same term. There may be many ways to refer to a term; each variant is placed in its own <glossAlt> element.-->
<!ELEMENT glossAlt    %glossAlt.content;>
<!ATTLIST glossAlt    %glossAlt.attributes;>


<!--                    LONG NAME: Glossary - Alternate For        -->
<!ENTITY % glossAlternateFor.content
                       "EMPTY
">
<!ENTITY % glossAlternateFor.attributes
             "href 
                        CDATA 
                                  #IMPLIED
              keyref 
                        CDATA 
                                  #IMPLIED
              type 
                        CDATA 
                                  #IMPLIED
              format 
                        CDATA 
                                  #IMPLIED
              scope 
                        (external | 
                         local | 
                         peer | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <glossAlternateFor> element indicates when a variant term has a relationship to another variant term as well as to the preferred term.-->
<!ELEMENT glossAlternateFor    %glossAlternateFor.content;>
<!ATTLIST glossAlternateFor    %glossAlternateFor.attributes;>


<!-- ============================================================= -->
<!--                    SPECIALIZATION ATTRIBUTE DECLARATIONS      -->
<!-- ============================================================= -->


<!ATTLIST glossentry  %global-atts;  class CDATA "- topic/topic concept/concept glossentry/glossentry ">
<!ATTLIST glossterm   %global-atts;  class CDATA "- topic/title concept/title glossentry/glossterm ">
<!ATTLIST glossdef    %global-atts;  class CDATA "- topic/abstract concept/abstract glossentry/glossdef ">
<!ATTLIST glossBody   %global-atts;  class CDATA "- topic/body concept/conbody glossentry/glossBody ">

<!ATTLIST glossAbbreviation %global-atts;  class CDATA "- topic/title concept/title glossentry/glossAbbreviation ">
<!ATTLIST glossAcronym %global-atts;  class CDATA "- topic/title concept/title glossentry/glossAcronym ">
<!ATTLIST glossShortForm %global-atts;  class CDATA "- topic/title concept/title glossentry/glossShortForm ">
<!ATTLIST glossSynonym %global-atts;  class CDATA "- topic/title concept/title glossentry/glossSynonym ">

<!ATTLIST glossPartOfSpeech %global-atts;  class CDATA "- topic/data concept/data glossentry/glossPartOfSpeech ">
<!ATTLIST glossProperty %global-atts;  class CDATA "- topic/data concept/data glossentry/glossProperty ">
<!ATTLIST glossStatus %global-atts;  class CDATA "- topic/data concept/data glossentry/glossStatus ">

<!ATTLIST glossAlt    %global-atts;  class CDATA "- topic/section concept/section glossentry/glossAlt ">
<!ATTLIST glossAlternateFor %global-atts;  class CDATA "- topic/xref concept/xref glossentry/glossAlternateFor ">
<!ATTLIST glossScopeNote %global-atts;  class CDATA "- topic/note concept/note glossentry/glossScopeNote ">
<!ATTLIST glossSurfaceForm %global-atts;  class CDATA "- topic/p concept/p glossentry/glossSurfaceForm ">
<!ATTLIST glossSymbol %global-atts;  class CDATA "- topic/image concept/image glossentry/glossSymbol ">
<!ATTLIST glossUsage  %global-atts;  class CDATA "- topic/note concept/note glossentry/glossUsage ">
 
<!-- ================== End DITA Glossary ======================== -->