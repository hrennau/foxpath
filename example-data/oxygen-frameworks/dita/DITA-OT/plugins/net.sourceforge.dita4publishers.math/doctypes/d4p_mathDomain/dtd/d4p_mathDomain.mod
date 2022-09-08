<?xml version="1.0" encoding="utf-8"?>
<!-- =============================================================
     DITA For Publishers Math Domain
     
     Defines specializations for the use of MathML.
     
     Copyright (c) 2012 DITA For Publishers
     
     ============================================================= -->
     
 <!ENTITY % d4p_eqn_inline    "d4p_eqn_inline" >
 <!ENTITY % d4p_eqn_block     "d4p_eqn_block" >
 <!ENTITY % d4p_MathML        "d4p_MathML" >
 <!ENTITY % d4p_display-equation  "d4p_display-equation" >

<!ENTITY % MATHML.prefixed "INCLUDE">

<!-- Using a D4P-specific URN here to ensure that resolution goes
     through the D4P catalog so that we don't inadvertently get
     some other version of the MathML DTD configured in the context
     of another doctype, such as Docbook, TEI, or JATS/NLM.
  -->
<!ENTITY % mathml3.dtd 
  SYSTEM "urn:urn:pubid:dita4publishers.sourceforge.net:doctypes:dita:mathml3.dtd"
>%mathml3.dtd;

<!-- ============================================================= -->
<!--                   ELEMENT NAME ENTITIES                       -->
<!-- ============================================================= -->


<!-- ============================================================= -->
<!--                    ELEMENT DECLARATIONS                       -->
<!-- ============================================================= -->

<!-- 
   %div; |
-->
<!ENTITY % d4p_eqn_inline.content 
"
  (%foreign; |
   %ph; |
   %keyword; |
   %term; |
   %text; |
   %image; |
   %data;)*
">
<!ENTITY % d4p_eqn_inline.attributes
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
<!ELEMENT d4p_eqn_inline %d4p_eqn_inline.content; >
<!ATTLIST d4p_eqn_inline %d4p_eqn_inline.attributes; >

<!ENTITY % d4p_eqn_block.content
"
  (%image; |
   %object; |
   %foreign; |
   %p; |
   %image; |
   %sectiondiv; |   
   %data;)*
"
>
<!ENTITY % d4p_eqn_block.attributes
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
<!ELEMENT d4p_eqn_block %d4p_eqn_block.content; >

<!ATTLIST d4p_eqn_block %d4p_eqn_block.attributes; >
<!ENTITY % d4p_MathML.content
"
  (m:math)*
"
>
<!ENTITY % d4p_MathML.attributes
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
<!ELEMENT d4p_MathML %d4p_MathML.content; >
<!ATTLIST d4p_MathML %d4p_MathML.attributes; >


<!-- Display equation: Specialization of <fig> that allows for separate numbering
     of equations.
  -->
<!ENTITY % d4p_display-equation.content
                       "((%title;)?, 
                         (%desc;)?, 
                         (%figgroup; | 
                          %fig.cnt;)* )"
>
<!ENTITY % d4p_display-equation.attributes
             "%display-atts;
              spectitle 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!ELEMENT d4p_display-equation    %d4p_display-equation.content;>
<!ATTLIST d4p_display-equation    %d4p_display-equation.attributes;>


<!-- ============================================================= -->
<!--                    SPECIALIZATION ATTRIBUTE DECLARATIONS      -->
<!-- ============================================================= -->

<!ATTLIST d4p_eqn_inline       %global-atts;  class CDATA "+ topic/ph      d4p-math-d/d4p_eqn_inline ">
<!ATTLIST d4p_eqn_block        %global-atts;  class CDATA "+ topic/p       d4p-math-d/d4p_eqn_block ">
<!ATTLIST d4p_display-equation %global-atts;  class CDATA "+ topic/fig     d4p-math-d/d4p_display-equation ">
<!ATTLIST d4p_MathML           %global-atts;  class CDATA "+ topic/foreign d4p-math-d/d4p_MathML ">


<!-- ================== End Formatting Domain ==================== -->