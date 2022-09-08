<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================================= -->
<!--                    HEADER                                     -->
<!-- ============================================================= -->
<!--  MODULE:    DITA DITA Programming Domain                      -->
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
PUBLIC "-//OASIS//ELEMENTS DITA Programming Domain//EN"
      Delivered as file "programmingDomain.mod"                    -->

<!-- ============================================================= -->
<!-- SYSTEM:     Darwin Information Typing Architecture (DITA)     -->
<!--                                                               -->
<!-- PURPOSE:    Declaring the elements and specialization         -->
<!--             attributes for the Programming Domain             -->
<!--                                                               -->
<!-- ORIGINAL CREATION DATE:                                       -->
<!--             March 2001                                        -->
<!--                                                               -->
<!--             (C) Copyright OASIS Open 2005, 2009.              -->
<!--             (C) Copyright IBM Corporation 2001, 2004.         -->
<!--             All Rights Reserved.                              -->
<!--                                                               -->
<!--  UPDATES:                                                     -->
<!--    2005.11.15 RDA: Updated these comments to match template   -->
<!--    2005.11.15 RDA: Corrected Long Names for syntax groups,    -->
<!--                    codeph, and kwd                            -->
<!--    2005.11.15 RDA: Corrected the "Delivered as" system ID     -->
<!--    2006.06.07 RDA: Make universal attributes universal        -->
<!--                      (DITA 1.1 proposal #12)                  -->
<!--    2006.11.30 RDA: Add -dita-use-conref-target to enumerated  -->
<!--                      attributes                               -->
<!--    2007.12.01 EK:  Reformatted DTD modules for DITA 1.2       -->
<!--    2008.02.12 RDA: Add text to synph, items with only #PCDATA -->
<!--    2008.02.12 RDA: Add coderef element                        -->
<!--    2008.02.13 RDA: Create .content and .attributes entities   -->
<!-- ============================================================= -->


<!-- ============================================================= -->
<!--                    ELEMENT NAME ENTITIES                      -->
<!-- ============================================================= -->


<!ENTITY % apiname      "apiname"                                    >
<!ENTITY % codeblock    "codeblock"                                  >
<!ENTITY % codeph       "codeph"                                     >
<!ENTITY % coderef      "coderef"                                     >
<!ENTITY % delim        "delim"                                      >
<!ENTITY % kwd          "kwd"                                        >
<!ENTITY % oper         "oper"                                       >
<!ENTITY % option       "option"                                     >
<!ENTITY % parmname     "parmname"                                   >
<!ENTITY % sep          "sep"                                        >
<!ENTITY % synph        "synph"                                      >
<!ENTITY % var          "var"                                        >

<!ENTITY % parml        "parml"                                      >
<!ENTITY % pd           "pd"                                         >
<!ENTITY % plentry      "plentry"                                    >
<!ENTITY % pt           "pt"                                         >

<!ENTITY % fragment     "fragment"                                   >
<!ENTITY % fragref      "fragref"                                    >
<!ENTITY % groupchoice  "groupchoice"                                >
<!ENTITY % groupcomp    "groupcomp"                                  >
<!ENTITY % groupseq     "groupseq"                                   >
<!ENTITY % repsep       "repsep"                                     >
<!ENTITY % synblk       "synblk"                                     >
<!ENTITY % synnote      "synnote"                                    >
<!ENTITY % synnoteref   "synnoteref"                                 >
<!ENTITY % syntaxdiagram 
                        "syntaxdiagram"                              >


<!-- ============================================================= -->
<!--                    ELEMENT DECLARATIONS                       -->
<!-- ============================================================= -->


<!--                    LONG NAME: Universal Attributes Local
                                   Importance                      -->
<!--                    Provide an alternative set of univ-atts that 
                        allows importance to be redefined locally  -->
<!ENTITY % univ-atts-no-importance
             "base 
                        CDATA 
                                  #IMPLIED
              %base-attribute-extensions;
              %id-atts;
              %filter-atts;
              %localization-atts; 
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
  " 
> 


<!--                    LONG NAME: Code Phrase                     -->
<!ENTITY % codeph.content
                       "(#PCDATA | 
                         %basic.ph.notm; | 
                         %data.elements.incl; | 
                         %foreign.unknown.incl;)*"
>
<!ENTITY % codeph.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The code phrase (<codeph>) element represents a snippet of code within the main flow of text. The code phrase is displayed in a monospaced font for emphasis. This element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT codeph    %codeph.content;>
<!ATTLIST codeph    %codeph.attributes;>



<!--                    LONG NAME: Code Block                      -->
<!ENTITY % codeblock.content
                       "(#PCDATA | 
                         %basic.ph.notm;  |
                         %coderef; |
                         %data.elements.incl; | 
                         %foreign.unknown.incl;| 
                         %txt.incl;)* 
 ">
<!ENTITY % codeblock.attributes
             "%display-atts;
              spectitle 
                        CDATA 
                                  #IMPLIED
              xml:space 
                        (preserve) 
                                  #FIXED 'preserve'
              %univ-atts; 
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <codeblock> element represents lines of program code. Like the <pre> element, content of this element has preserved line endings and is output in a monospaced font. This element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT codeblock    %codeblock.content;>
<!ATTLIST codeblock    %codeblock.attributes;>


<!--                    LONG NAME: Literal code reference          -->
<!ENTITY % coderef.content
                       "EMPTY"
>
<!ENTITY % coderef.attributes
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
<!--doc:The codref element allows a reference to an external file that contains literal code. When evaluated the coderef element should cause the target code to be displayed inline. If the target contains non-XML characters such as < and &amp;, those will need to be handled in a way that they may be displayed correctly by the final rendering engine.-->
<!ELEMENT coderef    %coderef.content;>
<!ATTLIST coderef    %coderef.attributes;>



<!--                    LONG NAME: Option                          -->
<!ENTITY % option.content
                       "(#PCDATA |
                         %text;)*
">
<!ENTITY % option.attributes
             "keyref
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED
">
<!--doc:The <option> element describes an option that can be used to modify a command (or something else, like a configuration). This element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT option    %option.content;>
<!ATTLIST option    %option.attributes;>



<!--                    LONG NAME: Variable                        -->
<!ENTITY % var.content
                       "(%words.cnt;)*"
>
<!ENTITY % var.attributes
             "importance 
                        (default | 
                         optional | 
                         required | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              %univ-atts-no-importance; 
              outputclass 
              CDATA
                                  #IMPLIED"
>
<!--doc:Within a syntax diagram, the <var> element defines a variable for which the user must supply content, such as their user name or password. It is represented in output in an italic font. This element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT var    %var.content;>
<!ATTLIST var    %var.attributes;>



<!--                    LONG NAME: Parameter Name                  -->
<!ENTITY % parmname.content
                       "(#PCDATA |
                         %text;)*
">
<!ENTITY % parmname.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts; 
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:When referencing the name of an application programming interface parameter within the text flow of your topic, use the parameter name (<parmname>) element to markup the parameter. This element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT parmname    %parmname.content;>
<!ATTLIST parmname    %parmname.attributes;>



<!--                    LONG NAME: Syntax Phrase                   -->
<!ENTITY % synph.content
                       "(#PCDATA | 
                         %codeph; | 
                         %delim; |
                         %kwd; | 
                         %oper; | 
                         %option; | 
                         %parmname; |
                         %sep; | 
                         %synph; |
                         %text; | 
                         %var; 
                         )*
">
<!ENTITY % synph.attributes
             "%univ-atts; 
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The syntax phrase (<synph>) element is a container for syntax definition elements. It is used when a complete syntax diagram is not needed, but some of the syntax elements, such as kwd, oper, delim, are used within the text flow of the topic content. This element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT synph    %synph.content;> 
<!ATTLIST  synph   %synph.attributes;>

<!--                    LONG NAME: Operator                        -->
<!ENTITY % oper.content
                       "(%words.cnt;)*"
>
<!ENTITY % oper.attributes
             "importance 
                        (default | 
                         optional | 
                         required | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              %univ-atts-no-importance; 
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The operator (<oper>) element defines an operator within a syntax definition. Typical operators are equals (=), plus (+) or multiply (*). This element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT oper    %oper.content;>
<!ATTLIST oper    %oper.attributes;>



<!--                    LONG NAME: Delimiter                       -->
<!ENTITY % delim.content
                       "(%words.cnt;)*"
>
<!ENTITY % delim.attributes
             "importance 
                        (optional | 
                         required | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              %univ-atts-no-importance;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:Within a syntax diagram, the delimiter (<delim>) element defines a character marking the beginning or end of a section or part of the complete syntax. Typical delimiter characters are the parenthesis, comma, tab, vertical bar or other special characters. This element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT delim    %delim.content;>
<!ATTLIST delim    %delim.attributes;>



<!--                    LONG NAME: Separator                       -->
<!ENTITY % sep.content
                       "(%words.cnt;)*"
>
<!ENTITY % sep.attributes
             "importance 
                        (optional | 
                         required | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              %univ-atts-no-importance; 
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The separator (<sep>) element defines a separator character that is inline with the content of a syntax diagram. The separator occurs between keywords, operators or groups in a syntax definition. This element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT sep    %sep.content;>
<!ATTLIST sep    %sep.attributes;>



<!--                    LONG NAME: API Name                        -->
<!ENTITY % apiname.content
                       "(#PCDATA |
                         %text;)*
">
<!ENTITY % apiname.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <apiname> element provides the name of an application programming interface (API) such as a Java class name or method name. This element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT apiname    %apiname.content;>
<!ATTLIST apiname    %apiname.attributes;>



<!--                    LONG NAME: Parameter List                  -->
<!ENTITY % parml.content
                       "(%plentry;)+"
>
<!ENTITY % parml.attributes
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
<!--doc:The parameter list (<parml>) element contains a list of terms and definitions that describes the parameters in an application programming interface. This is a special kind of definition list that is designed for documenting programming parameters. This element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT parml    %parml.content;>
<!ATTLIST parml    %parml.attributes;>



<!--                    LONG NAME: Parameter List Entry            -->
<!ENTITY % plentry.content
                       "((%pt;)+, 
                         (%pd;)+)"
>
<!ENTITY % plentry.attributes
             "%univ-atts;
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The parameter list entry element (<plentry>) contains one or more parameter terms and definitions (pd and pt). This element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT plentry    %plentry.content;>
<!ATTLIST plentry    %plentry.attributes;>



<!--                    LONG NAME: Parameter Term                  -->
<!ENTITY % pt.content
                       "(%term.cnt;)*"
>
<!ENTITY % pt.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:A parameter term, within a parameter list entry, is enclosed by the <pt> element. This element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT pt    %pt.content;>
<!ATTLIST pt    %pt.attributes;>



<!--                    LONG NAME: Parameter Description           -->
<!ENTITY % pd.content
                       "(%defn.cnt;)*"
>
<!ENTITY % pd.attributes
             "%univ-atts;
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:A parameter definition, within a parameter list entry, is enclosed by the <pd> element. This element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT pd    %pd.content;>
<!ATTLIST pd    %pd.attributes;>



<!--                    LONG NAME: Syntax Diagram                  -->
<!ENTITY % syntaxdiagram.content
                       "((%title;)?,
                         (%fragment; | 
                          %fragref; | 
                          %groupchoice; | 
                          %groupcomp; |
                          %groupseq; | 
                          %synblk; |
                          %synnote; | 
                          %synnoteref;)* )"
>
<!ENTITY % syntaxdiagram.attributes
             "%display-atts;
              %univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The syntax diagram (<syntaxdiagram>) element is the main container for all the syntax elements that make up a syntax definition. The syntax diagram represents the syntax of a statement from a computer language, or a command, function call or programming language statement. Traditionally, the syntax diagram is formatted with railroad tracks that connect the units of the syntax together, but this presentation may differ depending on the output media. The syntax diagram element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT syntaxdiagram    %syntaxdiagram.content;>
<!ATTLIST syntaxdiagram    %syntaxdiagram.attributes;>


<!--                    LONG NAME: Syntax Block                    -->
<!ENTITY % synblk.content
                       "((%title;)?, 
                        (%fragment; | 
                         %fragref; | 
                         %groupchoice; | 
                         %groupcomp; |
                         %groupseq; | 
                         %synnote; |
                         %synnoteref;)* )"
>
<!ENTITY % synblk.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The syntax block (<synblk>) element organizes small pieces of a syntax definition into a larger piece. The syntax block element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT synblk    %synblk.content;>
<!ATTLIST synblk    %synblk.attributes;>



<!--                    LONG NAME: Sequence Group                  -->
<!ENTITY % groupseq.content
                       "((%title;)?, 
                         (%repsep;)?,
                         (%delim; | 
                          %fragref; | 
                          %groupchoice; | 
                          %groupcomp; |
                          %groupseq; | 
                          %kwd; | 
                          %oper; | 
                          %sep; | 
                          %synnote; | 
                          %synnoteref; | 
                          %var;)* )"
>
<!ENTITY % groupseq.attributes
             "importance 
                        (default |
                         required | 
                         optional | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              %univ-atts-no-importance; 
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <groupseq> element is part of the subset of elements that define syntax diagrams in DITA. A group is a logical set of pieces of syntax that go together. Within the syntax definition, groups of keywords, delimiters and other syntax units act as a combined unit, and they occur in a specific sequence, as delimited by the <groupseq> element. This element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT groupseq    %groupseq.content;>
<!ATTLIST groupseq    %groupseq.attributes;>

<!--                    LONG NAME: Choice Group                    -->
<!ENTITY % groupchoice.content
                       "((%title;)?, 
                         (%repsep;)?,
                         (%delim; |
                          %fragref; | 
                          %groupchoice; | 
                          %groupcomp; |
                          %groupseq; | 
                          %kwd; | 
                          %oper; | 
                          %sep; | 
                          %synnote; | 
                          %synnoteref; | 
                          %var;)* )"
>
<!ENTITY % groupchoice.attributes
             "importance 
                        (default |
                         required | 
                         optional | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              %univ-atts-no-importance; 
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <groupchoice> element is part of the subset of elements that define syntax diagrams in DITA. A group is a logical set of pieces of syntax that go together. A group choice specifies that the user must make a choice about which part of the syntax to use. Groups are often nested. This element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT groupchoice    %groupchoice.content;> 
<!ATTLIST groupchoice    %groupchoice.attributes;>

<!--                    LONG NAME: Composite group                 -->
<!ENTITY % groupcomp.content
                       "((%title;)?, 
                         (%repsep;)?,
                         (%delim; |
                          %fragref; | 
                          %groupchoice; | 
                          %groupcomp; |
                          %groupseq; | 
                          %kwd; | 
                          %oper; | 
                          %sep; | 
                          %synnote; | 
                          %synnoteref; | 
                          %var;)* )"
>
<!ENTITY % groupcomp.attributes
             "importance 
                        (default |
                         required | 
                         optional | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              %univ-atts-no-importance; 
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <groupcomp> element is part of the subset of elements that define syntax diagrams in DITA. A group is a logical set of pieces of syntax that go together. The group composite means that the items that make up the syntax diagram will be formatted close together rather than being separated by a horizontal or vertical line, which is the usual formatting method. This element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT groupcomp    %groupcomp.content;> 
<!ATTLIST groupcomp    %groupcomp.attributes;>

<!--                    LONG NAME: Fragment                        -->
<!ENTITY % fragment.content
                       "((%title;)?, 
                         (%fragref; | 
                          %groupchoice; | 
                          %groupcomp; |
                          %groupseq; | 
                          %synnote; | 
                          %synnoteref;)* )"
>
<!ENTITY % fragment.attributes
             "%univ-atts; 
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:Within a syntax definition, a <fragment> is a labeled subpart of the syntax. The <fragment> element allows breaking out logical chunks of a large syntax diagram into named fragments. This element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT fragment    %fragment.content;>
<!ATTLIST fragment    %fragment.attributes;>

 


<!--                    LONG NAME: Fragment Reference              -->
<!ENTITY % fragref.content
                       "(%xrefph.cnt;)*
">
<!ENTITY % fragref.attributes
             "href 
                        CDATA 
                                  #IMPLIED
              importance 
                        (optional | 
                         required | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              %univ-atts-no-importance; 
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The fragment reference (<fragref>) element provides a logical reference to a syntax definition fragment so that you can reference a syntax fragment multiple times, or pull a large section of syntax out of line for easier reading. This element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT fragref    %fragref.content;>
<!ATTLIST fragref    %fragref.attributes;>


<!--                    LONG NAME: Syntax Diagram Note             -->
<!ENTITY % synnote.content
                       "(#PCDATA | 
                         %basic.ph;)*"
>
<!ENTITY % synnote.attributes
             "callout 
                        CDATA 
                                  #IMPLIED
              %univ-atts; 
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The syntax note (<synnote>) element contains a note (similar to a footnote) within a syntax definition group or fragment. The syntax note explains aspects of the syntax that cannot be expressed in the markup itself. The note will appear at the bottom of the syntax diagram instead of at the bottom of the page. The syntax block element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT synnote    %synnote.content;>
<!ATTLIST synnote    %synnote.attributes;>



<!--                    LONG NAME: Syntax Note Reference           -->
<!ENTITY % synnoteref.content
                       "EMPTY"
>
<!ENTITY % synnoteref.attributes
             "href 
                        CDATA 
                                  #IMPLIED
              %univ-atts; 
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The syntax note (<synnoteref>) reference element references a syntax note element (<synnote>) that has already been defined elsewhere in the syntax diagram. The same notation can be used in more than one syntax definition. The syntax note reference element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT synnoteref    %synnoteref.content;>
<!ATTLIST synnoteref    %synnoteref.attributes;>



<!--                    LONG NAME: Repeat Separator                -->
<!ENTITY % repsep.content
                       "(%words.cnt;)*"
>
<!ENTITY % repsep.attributes
             "importance 
                        (optional | 
                         required | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              %univ-atts-no-importance; 
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The repeat separator (<repsep>) element in a syntax diagram defines a group of syntax elements that can (or should) be repeated. If the <repsep> element contains a separator character, such as a plus (+), this indicates that the character must be used between repetitions of the syntax elements. This element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT repsep    %repsep.content;>
<!ATTLIST repsep    %repsep.attributes;>



<!--                    LONG NAME: Syntax Keyword                  -->
<!ENTITY % kwd.content
                       "(#PCDATA |
                         %text;)*"
>
<!ENTITY % kwd.attributes
             "keyref 
                         CDATA 
                                   #IMPLIED
               importance 
                        (default |
                         required | 
                         optional | 
                         -dita-use-conref-target) 
                                  #IMPLIED
              %univ-atts-no-importance; 
              outputclass 
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <kwd> element defines a keyword within a syntax diagram. A keyword must be typed or output, either by the user or application, exactly as specified in the syntax definition. This element is part of the DITA programming domain, a special set of DITA elements designed to document programming tasks, concepts and reference information.
Category: Programming elements-->
<!ELEMENT kwd    %kwd.content;>
<!ATTLIST kwd    %kwd.attributes;>



<!-- ============================================================= -->
<!--                    SPECIALIZATION ATTRIBUTE DECLARATIONS      -->
<!-- ============================================================= -->
 

<!ATTLIST  apiname    %global-atts; class CDATA "+ topic/keyword pr-d/apiname "  >
<!ATTLIST  codeblock  %global-atts; class CDATA "+ topic/pre pr-d/codeblock "    >
<!ATTLIST  codeph     %global-atts; class CDATA "+ topic/ph pr-d/codeph "        >
<!ATTLIST  coderef    %global-atts; class CDATA "+ topic/xref pr-d/coderef "     >
<!ATTLIST  delim      %global-atts; class CDATA "+ topic/ph pr-d/delim "         >
<!ATTLIST  fragment   %global-atts; class CDATA "+ topic/figgroup pr-d/fragment ">
<!ATTLIST  fragref    %global-atts; class CDATA "+ topic/xref pr-d/fragref "     >
<!ATTLIST  groupchoice 
                      %global-atts; class CDATA "+ topic/figgroup pr-d/groupchoice ">
<!ATTLIST  groupcomp  %global-atts; class CDATA "+ topic/figgroup pr-d/groupcomp ">
<!ATTLIST  groupseq   %global-atts; class CDATA "+ topic/figgroup pr-d/groupseq ">
<!ATTLIST  kwd        %global-atts; class CDATA "+ topic/keyword pr-d/kwd "      >
<!ATTLIST  oper       %global-atts; class CDATA "+ topic/ph pr-d/oper "          >
<!ATTLIST  option     %global-atts; class CDATA "+ topic/keyword pr-d/option "   >
<!ATTLIST  parml      %global-atts; class CDATA "+ topic/dl pr-d/parml "         >
<!ATTLIST  parmname   %global-atts; class CDATA "+ topic/keyword pr-d/parmname " >
<!ATTLIST  pd         %global-atts; class CDATA "+ topic/dd pr-d/pd "            >
<!ATTLIST  plentry    %global-atts; class CDATA "+ topic/dlentry pr-d/plentry "  >
<!ATTLIST  pt         %global-atts; class CDATA "+ topic/dt pr-d/pt "            >
<!ATTLIST  repsep     %global-atts; class CDATA "+ topic/ph pr-d/repsep "        >
<!ATTLIST  sep        %global-atts; class CDATA "+ topic/ph pr-d/sep "           >
<!ATTLIST  synblk     %global-atts; class CDATA "+ topic/figgroup pr-d/synblk "  >
<!ATTLIST  synnote    %global-atts; class CDATA "+ topic/fn pr-d/synnote "       >
<!ATTLIST  synnoteref %global-atts; class CDATA "+ topic/xref pr-d/synnoteref "  >
<!ATTLIST  synph      %global-atts; class CDATA "+ topic/ph pr-d/synph "         >
<!ATTLIST  syntaxdiagram 
                      %global-atts; class CDATA "+ topic/fig pr-d/syntaxdiagram ">
<!ATTLIST  var        %global-atts; class CDATA "+ topic/ph pr-d/var "           >


<!-- ================== End Programming Domain  ====================== -->