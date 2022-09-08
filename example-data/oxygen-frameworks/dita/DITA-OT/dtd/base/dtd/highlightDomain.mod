<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================================= -->
<!--                    HEADER                                     -->
<!-- ============================================================= -->
<!--  MODULE:    DITA Highlight Domain                             -->
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
PUBLIC "-//OASIS//ELEMENTS DITA Highlight Domain//EN"
      Delivered as file "highlightDomain.mod"                      -->

<!-- ============================================================= -->
<!-- SYSTEM:     Darwin Information Typing Architecture (DITA)     -->
<!--                                                               -->
<!-- PURPOSE:    Define elements and specialization attributes     -->
<!--             for Highlight Domain                              -->
<!--                                                               -->
<!-- ORIGINAL CREATION DATE:                                       -->
<!--             March 2001                                        -->
<!--                                                               -->
<!--             (C) Copyright OASIS Open 2005, 2009.              -->
<!--             (C) Copyright IBM Corporation 2001, 2004.         -->
<!--             All Rights Reserved.                              -->
<!--                                                               -->
<!--  UPDATES:                                                     -->
<!--    2005.11.15 RDA: Corrected descriptive names for all        -->
<!--                    elements except bold                       -->
<!--    2005.11.15 RDA: Corrected the "Delivered as" system ID     -->
<!--    2007.12.01 EK:  Reformatted DTD modules for DITA 1.2       -->
<!--    2008.02.13 RDA: Create .content and .attributes entities   -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!--                   ELEMENT NAME ENTITIES                       -->
<!-- ============================================================= -->

<!ENTITY % b           "b"                                           >
<!ENTITY % i           "i"                                           >
<!ENTITY % u           "u"                                           > 
<!ENTITY % tt          "tt"                                          >
<!ENTITY % sup         "sup"                                         >
<!ENTITY % sub         "sub"                                         >


<!-- ============================================================= -->
<!--                    ELEMENT DECLARATIONS                       -->
<!-- ============================================================= -->


<!--                    LONG NAME: Bold                            -->
<!ENTITY % b.content
                       "(#PCDATA | 
                         %basic.ph; | 
                         %data.elements.incl; |
                         %foreign.unknown.incl;)*"
>
<!ENTITY % b.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The bold (<b>) element is used to apply bold highlighting to the content of the element. Use this element only when there is not some other more proper element. For example, for specific items such as GUI controls, use the <uicontrol> element. This element is part of the DITA highlighting domain.
Category: Typographic elements-->
<!ELEMENT b    %b.content;>
<!ATTLIST b    %b.attributes;>



<!--                    LONG NAME: Underlined                      -->
<!ENTITY % u.content
                       "(#PCDATA | 
                         %basic.ph; | 
                         %data.elements.incl; |
                         %foreign.unknown.incl;)*"
>
<!ENTITY % u.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The underline (<u>) element is used to apply underline highlighting to the content of the element.
Category: Typographic elements-->
<!ELEMENT u    %u.content;>
<!ATTLIST u    %u.attributes;>



<!--                    LONG NAME: Italic                          -->
<!ENTITY % i.content
                       "(#PCDATA | 
                         %basic.ph; | 
                         %data.elements.incl; |
                         %foreign.unknown.incl;)*"
>
<!ENTITY % i.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The italic (<i>) element is used to apply italic highlighting to the content of the element.
Category: Typographic elements-->
<!ELEMENT i    %i.content;>
<!ATTLIST i    %i.attributes;>



<!--                    LONG NAME: Teletype (monospaced)           -->
<!ENTITY % tt.content
                       "(#PCDATA | 
                         %basic.ph; | 
                         %data.elements.incl; |
                         %foreign.unknown.incl;)*"
>
<!ENTITY % tt.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The teletype (<tt>) element is used to apply monospaced highlighting to the content of the element.
Category: Typographic elements-->
<!ELEMENT tt    %tt.content;>
<!ATTLIST tt    %tt.attributes;>



<!--                    LONG NAME: Superscript                     -->
<!ENTITY % sup.content
                       "(#PCDATA | 
                         %basic.ph; | 
                         %data.elements.incl; |
                         %foreign.unknown.incl;)*"
>
<!ENTITY % sup.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The superscript (<sup>) element indicates that text should be superscripted, or vertically raised in relationship to the surrounding text. Superscripts are usually a smaller font than the surrounding text. Use this element only when there is not some other more proper tag. This element is part of the DITA highlighting domain.
Category: Typographic elements-->
<!ELEMENT sup    %sup.content;>
<!ATTLIST sup    %sup.attributes;>



<!--                    LONG NAME: Subscript                       -->
<!ENTITY % sub.content
                       "(#PCDATA | 
                         %basic.ph; | 
                         %data.elements.incl; |
                         %foreign.unknown.incl;)*"
>
<!ENTITY % sub.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:A subscript (<sub>) indicates that text should be subscripted, or placed lower in relationship to the surrounding text. Subscripted text is often a smaller font than the surrounding text. Formatting may vary depending on your output process. This element is part of the DITA highlighting domain.
Category: Typographic elements-->
<!ELEMENT sub    %sub.content;>
<!ATTLIST sub    %sub.attributes;>

 

<!-- ============================================================= -->
<!--                    SPECIALIZATION ATTRIBUTE DECLARATIONS      -->
<!-- ============================================================= -->


<!ATTLIST b           %global-atts;  class CDATA "+ topic/ph hi-d/b "  >
<!ATTLIST i           %global-atts;  class CDATA "+ topic/ph hi-d/i "  >
<!ATTLIST sub         %global-atts;  class CDATA "+ topic/ph hi-d/sub ">
<!ATTLIST sup         %global-atts;  class CDATA "+ topic/ph hi-d/sup ">
<!ATTLIST tt          %global-atts;  class CDATA "+ topic/ph hi-d/tt " >
<!ATTLIST u           %global-atts;  class CDATA "+ topic/ph hi-d/u "  >


<!-- ================== DITA Highlight Domain ==================== -->