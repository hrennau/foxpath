<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================================= -->
<!--                    HEADER                                     -->
<!-- ============================================================= -->
<!--  MODULE:    DITA Software Domain                              -->
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
PUBLIC "-//OASIS//ELEMENTS DITA Software Domain//EN"
      Delivered as file "softwareDomain.mod"                       -->

<!-- ============================================================= -->
<!-- SYSTEM:     Darwin Information Typing Architecture (DITA)     -->
<!--                                                               -->
<!-- PURPOSE:    Declaring the elements and specialization         -->
<!--             attributes for the Software Domain                -->
<!--                                                               -->
<!-- ORIGINAL CREATION DATE:                                       -->
<!--             March 2001                                        -->
<!--                                                               -->
<!--             (C) Copyright OASIS Open 2005, 2009.              -->
<!--             (C) Copyright IBM Corporation 2001, 2004.         -->
<!--             All Rights Reserved.                              -->
<!--                                                               -->
<!--  UPDATES:                                                     -->
<!--    2005.11.15 RDA: Corrected the PURPOSE in this comment      -->
<!--    2005.11.15 RDA: Corrected the "Delivered as" system ID     -->
<!--    2007.12.01 EK:  Reformatted DTD modules for DITA 1.2       -->
<!--    2008.02.12 RDA: Add text to msgnum, cmdname, varname       -->
<!--    2008.02.13 RDA: Create .content and .attributes entities   -->
<!-- ============================================================= -->


<!-- ============================================================= -->
<!--                   ELEMENT NAME ENTITIES                       -->
<!-- ============================================================= -->


<!ENTITY % msgph       "msgph"                                       >
<!ENTITY % msgblock    "msgblock"                                    >
<!ENTITY % msgnum      "msgnum"                                      >
<!ENTITY % cmdname     "cmdname"                                     >
<!ENTITY % varname     "varname"                                     >
<!ENTITY % filepath    "filepath"                                    >
<!ENTITY % userinput   "userinput"                                   >
<!ENTITY % systemoutput 
                       "systemoutput"                                >


<!-- ============================================================= -->
<!--                    ELEMENT DECLARATIONS                       -->
<!-- ============================================================= -->


<!--                    LONG NAME: Message Phrase                  -->
<!ENTITY % msgph.content
                       "(%words.cnt;)*"
>
<!ENTITY % msgph.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The message phrase (<msgph>) element contains the text content of a message produced by an application or program. It can also contain the variable name (varname) element to illustrate where variable text content can occur in the message. This element is part of the DITA software domain, a special set of DITA elements designed to document software tasks, concepts and reference information.
Category: Software elements-->
<!ELEMENT msgph    %msgph.content;>
<!ATTLIST msgph    %msgph.attributes;>



<!--                    LONG NAME: Message Block                   -->
<!ENTITY % msgblock.content
                       "(%words.cnt;)*"
>
<!ENTITY % msgblock.attributes
             "%display-atts;
              spectitle 
                        CDATA 
                                  #IMPLIED
              %univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED 
              xml:space 
                        (preserve) 
                                  #FIXED 'preserve'"
>
<!--doc:The message block (<msgblock>) element contains a multi-line message or set of messages. The message block can contain multiple message numbers and message descriptions, each enclosed in a <msgnum> and <msgph> element. It can also contain the message content directly. This element is part of the DITA software domain, a special set of DITA elements designed to document software tasks, concepts and reference information.
Category: Software elements-->
<!ELEMENT msgblock    %msgblock.content;>
<!ATTLIST msgblock    %msgblock.attributes;>



<!--                    LONG NAME: Message Number                  -->
<!ENTITY % msgnum.content
                       "(#PCDATA |
                         %text;)*"
>
<!ENTITY % msgnum.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The message number (<msgnum>) element contains the number of a message produced by an application or program. This element is part of the DITA software domain, a special set of DITA elements designed to document software tasks, concepts and reference information.
Category: Software elements-->
<!ELEMENT msgnum    %msgnum.content;>
<!ATTLIST msgnum    %msgnum.attributes;>



<!--                    LONG NAME: Command Name                    -->
<!ENTITY % cmdname.content
                       "(#PCDATA |
                         %text;)*"
>
<!ENTITY % cmdname.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The command name (<cmdname>) element specifies the name of a command when it is part of a software discussion. This element is part of the DITA software domain, a special set of DITA elements designed to document software tasks, concepts and reference information.
Category: Software elements-->
<!ELEMENT cmdname    %cmdname.content;>
<!ATTLIST cmdname    %cmdname.attributes;>



<!--                    LONG NAME: Variable Name                   -->
<!ENTITY % varname.content
                       "(#PCDATA |
                         %text;)*"
>
<!ENTITY % varname.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The variable name (<varname>) element defines a variable that must be supplied to a software application. The variable name element is very similar to the variable (var) element, but variable name is used outside of syntax diagrams. This element is part of the DITA software domain, a special set of DITA elements designed to document software tasks, concepts and reference information.
Category: Software elements-->
<!ELEMENT varname    %varname.content;>
<!ATTLIST varname    %varname.attributes;>


<!--                    LONG NAME: File Path                       -->
<!ENTITY % filepath.content
                       "(%words.cnt;)*"
>
<!ENTITY % filepath.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <filepath> element indicates the name and optionally the location of a referenced file by specifying the directory containing the file, and other directories that may precede it in the system hierarchy. This element is part of the DITA software domain, a special set of DITA elements designed to document software tasks, concepts and reference information.
Category: Software elements-->
<!ELEMENT filepath    %filepath.content;>
<!ATTLIST filepath    %filepath.attributes;>



<!--                    LONG NAME: User Input                      -->
<!ENTITY % userinput.content
                       "(%words.cnt;)*"
>
<!ENTITY % userinput.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The user input (<userinput>) element represens the text a user should input in response to a program or system prompt. This element is part of the DITA software domain, a special set of DITA elements designed to document software tasks, concepts and reference information.
Category: Software elements-->
<!ELEMENT userinput    %userinput.content;>
<!ATTLIST userinput    %userinput.attributes;>



<!--                    LONG NAME: System Output                   -->
<!ENTITY % systemoutput.content
                       "(%words.cnt;)*"
>
<!ENTITY % systemoutput.attributes
             "%univ-atts; 
              outputclass 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The system output (<systemoutput>) element represents computer output or responses to a command or situation. A generalized element, it represents any kind of output from the computer, so the author may wish to choose more specific markup, such as msgph, for messages from the application. The system output element is part of the DITA software domain, a special set of DITA elements designed to document software tasks, concepts and reference information.
Category: Software elements-->
<!ELEMENT systemoutput    %systemoutput.content;>
<!ATTLIST systemoutput    %systemoutput.attributes;>

 

<!-- ============================================================= -->
<!--                    SPECIALIZATION ATTRIBUTE DECLARATIONS      -->
<!-- ============================================================= -->
 

<!ATTLIST cmdname     %global-atts;  class CDATA "+ topic/keyword sw-d/cmdname ">
<!ATTLIST filepath    %global-atts;  class CDATA "+ topic/ph sw-d/filepath "    >
<!ATTLIST msgblock    %global-atts;  class CDATA "+ topic/pre sw-d/msgblock "   >
<!ATTLIST msgnum      %global-atts;  class CDATA "+ topic/keyword sw-d/msgnum " >
<!ATTLIST msgph       %global-atts;  class CDATA "+ topic/ph sw-d/msgph "       >
<!ATTLIST systemoutput
                      %global-atts;  class CDATA "+ topic/ph sw-d/systemoutput ">
<!ATTLIST userinput   %global-atts;  class CDATA "+ topic/ph sw-d/userinput "   >
<!ATTLIST varname     %global-atts;  class CDATA "+ topic/keyword sw-d/varname ">

 
<!-- ================== End Software Domain ====================== -->