<!--highlighting domain - class prefix hi-d -->
<!--add to ph element in doctype shell: 
	b | u | i | sup | sub 
-->
<!--add to included-domains in doctype shell:
	(topic hi-d)
-->

<!--                    LONG NAME: Bold content  -->
<!ELEMENT b             (%all-inline;)*        >
<!ATTLIST b
             %localization;
             %variable-content;
             class CDATA "- topic/ph hi-d/b ">

<!--                    LONG NAME: Italic content  -->
<!ELEMENT i             (%all-inline;)*        >
<!ATTLIST i
             %localization;
             %variable-content;
             class CDATA "- topic/ph hi-d/i ">

<!--                    LONG NAME: Underlined content  -->
<!ELEMENT u             (%all-inline;)*        >
<!ATTLIST u
             %localization;
             %variable-content;
             class CDATA "- topic/ph hi-d/u ">

<!--                    LONG NAME: Superscript content  -->
<!ELEMENT sup             (%all-inline;)*        >
<!ATTLIST sup
             %localization;
             %variable-content;
             class CDATA "- topic/ph hi-d/sup ">

<!--                    LONG NAME: Subscript content  -->
<!ELEMENT sub             (%all-inline;)*        >
<!ATTLIST sub
             %localization;
             %variable-content;
             class CDATA "- topic/ph hi-d/sub ">
