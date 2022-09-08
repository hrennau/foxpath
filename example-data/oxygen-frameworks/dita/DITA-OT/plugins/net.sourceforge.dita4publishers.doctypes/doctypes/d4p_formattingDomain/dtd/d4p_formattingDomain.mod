<?xml version="1.0" encoding="utf-8"?>
<!-- =============================================================
     DITA For Publishers Formatting Domain
     
     Defines specializations of p and ph for requesting specific
     formatting effects.
     
     Copyright (c) 2009, 2012 DITA For Publishers
     
     ============================================================= -->
     
 <!ENTITY % art-ph        "art-ph" >
 <!ENTITY % art           "art" >
 <!ENTITY % art_title     "art_title" >
 <!ENTITY % b-i           "b-i">
 <!ENTITY % br            "br" >
 <!ENTITY % b-sc          "b-sc">
 <!-- d4pSidebarAnchor is the preferred spelling. -->
 <!ENTITY % d4p_sidebar-anchor "d4p_sidebar-anchor" >
 <!ENTITY % d4pSidebarAnchor "d4pSidebarAnchor" >
 <!ENTITY % dropcap       "dropcap" >
 <!ENTITY % eqn_inline    "eqn_inline" >
 <!ENTITY % eqn_block     "eqn_block" >
 <!ENTITY % d4pMathML     "d4pMathML" >
 <!ENTITY % frac          "frac" >
 <!ENTITY % inx_snippet   "inx_snippet" >
 <!ENTITY % linethrough   "linethrough" >
 <!ENTITY % roman         "roman">
 <!ENTITY % sc            "sc">
 <!ENTITY % tab           "tab" >
     

<!ENTITY % MATHML.prefixed "INCLUDE">
<!--
  NOTE: As of version 0.9.19, the mathML DTD is included
        by the D4P Math domain. 
        

<!ENTITY % mathml2.dtd 
  SYSTEM "../../mathml2/dtd/mathml2.dtd"
>%mathml2.dtd;
-->

<!-- ============================================================= -->
<!--                   ELEMENT NAME ENTITIES                       -->
<!-- ============================================================= -->

<!ENTITY % inx 
  SYSTEM "inx-decls.ent"
>
%inx;

<!-- ============================================================= -->
<!--                    ELEMENT DECLARATIONS                       -->
<!-- ============================================================= -->

<!ENTITY % br.content "EMPTY" >
<!ENTITY % br.attributes
 "
   %id-atts;
  %localization-atts;
  base       
    CDATA                            
    #IMPLIED
  %base-attribute-extensions;
  outputclass 
    CDATA                            
    #IMPLIED    

 "
> 
<!ELEMENT br %br.content; >
<!ATTLIST br %br.attributes; >



<!ENTITY % tab.content "EMPTY" >
<!ENTITY % tab.attributes
 "
   %id-atts;
  %localization-atts;
  base       
    CDATA                            
    #IMPLIED
  %base-attribute-extensions;
  outputclass 
    CDATA                            
    #IMPLIED    

 "
> 
<!ELEMENT tab %tab.content; >
<!ATTLIST tab %tab.attributes; >


<!ENTITY % frac.content
"
  (#PCDATA | 
   ph|
   i |
   b)*
  " 
>
<!ENTITY % frac.attributes
 "
   %id-atts;
  %localization-atts;
  base       
    CDATA                            
    #IMPLIED
  %base-attribute-extensions;
  outputclass 
    CDATA                            
    #IMPLIED    

 "
> 
<!ELEMENT frac %frac.content; >
<!ATTLIST frac %frac.attributes; >


<!ENTITY % eqn_inline.content 
"
  (%inx_snippet; |
   %d4pMathML; |
   %art; |
   %data;)*
">
<!ENTITY % eqn_inline.attributes
 "
   %id-atts;
  %localization-atts;
  base       
    CDATA                            
    #IMPLIED
  %base-attribute-extensions;
  outputclass 
    CDATA                            
    #IMPLIED    

 "
> 
<!ELEMENT eqn_inline %eqn_inline.content; >
<!ATTLIST eqn_inline %eqn_inline.attributes; >

<!ENTITY % eqn_block.content
"
  (%inx_snippet; |
   %d4pMathML; |
   %art; |
   %data;)*
"
>
<!ENTITY % eqn_block.attributes
 "
   %id-atts;
  %localization-atts;
  base       
    CDATA                            
    #IMPLIED
  %base-attribute-extensions;
  outputclass 
    CDATA                            
    #IMPLIED    

 "
> 
<!ELEMENT eqn_block %eqn_block.content; >

<!ATTLIST eqn_block %eqn_block.attributes; >
<!ENTITY % d4pMathML.content
"
  (m:math)*
"
>
<!ENTITY % d4pMathML.attributes
 "
   %id-atts;
  %localization-atts;
  base       
    CDATA                            
    #IMPLIED
  %base-attribute-extensions;
  outputclass 
    CDATA                            
    #IMPLIED    

 "
> 
<!ELEMENT d4pMathML %d4pMathML.content; >
<!ATTLIST d4pMathML %d4pMathML.attributes; >

<!ENTITY % art.content
"
  ((%art_title;)?,
   (%image; |
    %object; |
    %foreign;)*,
   (%data;)*)
">
<!ENTITY % art.attributes
"
  %id-atts;
  %localization-atts;
  base       
    CDATA                            
    #IMPLIED
  %base-attribute-extensions;
  outputclass 
    CDATA                            
    #IMPLIED    
">
<!ELEMENT art %art.content; >
<!ATTLIST art %art.attributes; >

<!ENTITY % art-ph.content
"
  ((%art_title;)?,
   (%image; |
    %object; |
    %foreign;)*,
   (%data;)*)
">
<!ENTITY % art-ph.attributes
"
  %id-atts;
  %localization-atts;
  base       
    CDATA                            
    #IMPLIED
  %base-attribute-extensions;
  outputclass 
    CDATA                            
    #IMPLIED    
">
<!ELEMENT art-ph %art-ph.content; >
<!ATTLIST art-ph %art-ph.attributes; >

<!ENTITY % art_title.content
"
  (%ph.cnt;)*
">
<!ENTITY % art_title.attributes
" 
  %id-atts;
  %localization-atts;
  base       
    CDATA                            
    #IMPLIED
  %base-attribute-extensions;
  outputclass 
    CDATA                            
    #IMPLIED    
">
<!ELEMENT art_title %art_title.content; >
<!ATTLIST art_title %art_title.attributes; >

<!ENTITY % inx_snippet.content
"
  (%inx-components;)*
">
<!ENTITY % inx_snippet.attributes
"
  %id-atts;
  %localization-atts;
  base       
    CDATA                            
    #IMPLIED
  %base-attribute-extensions;
  outputclass 
    CDATA                            
    #IMPLIED    
">
<!ELEMENT inx_snippet %inx_snippet.content; >
<!ATTLIST inx_snippet %inx_snippet.attributes; >

<!ENTITY % linethrough.content 
 "(%ph.cnt;)*"
>
<!ENTITY % linethrough.attributes 
 "
  %id-atts;
  %localization-atts;
  base       
    CDATA                            
    #IMPLIED
  %base-attribute-extensions;
  outputclass 
    CDATA                            
    #IMPLIED    
 "
 >
<!ELEMENT linethrough %linethrough.content; >
<!ATTLIST linethrough %linethrough.attributes; >


<!ENTITY % roman.content
                       "(#PCDATA | 
                         %basic.ph; | 
                         %data.elements.incl; |
                         %foreign.unknown.incl;)*"
>
<!ENTITY % roman.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!ELEMENT roman    %roman.content;>
<!ATTLIST roman    %roman.attributes;>



<!--                    LONG NAME: Small Caps                     -->
<!ENTITY % sc.content
                       "(#PCDATA | 
                         %basic.ph; | 
                         %data.elements.incl; |
                         %foreign.unknown.incl;)*"
>
<!ENTITY % sc.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!ELEMENT sc    %sc.content;>
<!ATTLIST sc    %sc.attributes;>

<!--                    LONG NAME: Drop Cap                     -->
<!ENTITY % dropcap.content
                       "(#PCDATA | 
                         %basic.ph; | 
                         %data.elements.incl; |
                         %foreign.unknown.incl;)*"
>
<!ENTITY % dropcap.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!ELEMENT dropcap    %dropcap.content;>
<!ATTLIST dropcap    %dropcap.attributes;>


<!--                    LONG NAME: Bold Italic                     -->
<!ENTITY % b-i.content
                       "(#PCDATA | 
                         %basic.ph; | 
                         %data.elements.incl; |
                         %foreign.unknown.incl;)*"
>
<!ENTITY % b-i.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!ELEMENT b-i    %b-i.content;>
<!ATTLIST b-i    %b-i.attributes;>


<!--                    LONG NAME: Bold Small Caps                     -->
<!ENTITY % b-sc.content
                       "(#PCDATA | 
                         %basic.ph; | 
                         %data.elements.incl; |
                         %foreign.unknown.incl;)*"
>
<!ENTITY % b-sc.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!ELEMENT b-sc    %b-sc.content;>
<!ATTLIST b-sc    %b-sc.attributes;>

<!ENTITY % d4p_sidebar-anchor.content
                       "(%data.elements.incl;)*"
>
<!ENTITY % d4p_sidebar-anchor.attributes
  "%xref.attributes;"
>
<!ELEMENT d4p_sidebar-anchor    %d4p_sidebar-anchor.content;>
<!ATTLIST d4p_sidebar-anchor    %d4p_sidebar-anchor.attributes;>

<!ENTITY % d4pSidebarAnchor.content
                       "(%data.elements.incl;)*"
>
<!ENTITY % d4pSidebarAnchor.attributes
  "%xref.attributes;"
>
<!ELEMENT d4pSidebarAnchor    %d4pSidebarAnchor.content;>
<!ATTLIST d4pSidebarAnchor    %d4pSidebarAnchor.attributes;>


<!-- ============================================================= -->
<!--                    SPECIALIZATION ATTRIBUTE DECLARATIONS      -->
<!-- ============================================================= -->

<!ATTLIST art-ph           %global-atts;  class CDATA "+ topic/ph    d4p-formatting-d/art-ph ">
<!ATTLIST art              %global-atts;  class CDATA "+ topic/p     d4p-formatting-d/art ">
<!ATTLIST art_title        %global-atts;  class CDATA "+ topic/data  d4p-formatting-d/art_title ">

<!ATTLIST b-i              %global-atts;  class CDATA "+ topic/ph    d4p-formatting-d/b-i "  >
<!ATTLIST br               %global-atts;  class CDATA "+ topic/ph    d4p-formatting-d/br ">
<!ATTLIST b-sc             %global-atts;  class CDATA "+ topic/ph    d4p-formatting-d/b-sc "  >
<!ATTLIST eqn_inline       %global-atts;  class CDATA "+ topic/ph    d4p-formatting-d/eqn_inline ">
<!ATTLIST eqn_block        %global-atts;  class CDATA "+ topic/p     d4p-formatting-d/eqn_block ">
<!ATTLIST d4p_sidebar-anchor %global-atts;  class CDATA "+ topic/xref d4p-formatting-d/d4p_sidebar-anchor ">
<!ATTLIST d4pSidebarAnchor %global-atts;  class CDATA "+ topic/xref d4p-formatting-d/d4pSidebarAnchor ">
<!ATTLIST d4pMathML        %global-atts;  class CDATA "+ topic/foreign d4p-formatting-d/d4pMathML ">
<!ATTLIST dropcap          %global-atts;  class CDATA "+ topic/ph    d4p-formatting-d/dropcap "  >
<!ATTLIST frac             %global-atts;  class CDATA "+ topic/ph    d4p-formatting-d/frac ">
<!ATTLIST inx_snippet      %global-atts;  class CDATA "+ topic/foreign d4p-formatting-d/inx_snippet ">
<!ATTLIST linethrough      %global-atts;  class CDATA "+ topic/ph    d4p-formatting-d/linethrough ">
<!ATTLIST roman            %global-atts;  class CDATA "+ topic/ph    d4p-formatting-d/roman "  >
<!ATTLIST sc               %global-atts;  class CDATA "+ topic/ph    d4p-formatting-d/sc "  >
<!ATTLIST tab              %global-atts;  class CDATA "+ topic/ph    d4p-formatting-d/tab ">


<!-- ================== End Formatting Domain ==================== -->