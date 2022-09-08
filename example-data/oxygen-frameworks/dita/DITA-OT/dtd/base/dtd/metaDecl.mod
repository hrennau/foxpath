<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================================= -->
<!--                    HEADER                                     -->
<!-- ============================================================= -->
<!--  MODULE:    DITA Metadata                                     -->
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
PUBLIC "-//OASIS//ELEMENTS DITA Metadata//EN"
      Delivered as file "metaDecl.mod"                             -->

<!-- ============================================================= -->
<!-- SYSTEM:     Darwin Information Typing Architecture (DITA)     -->
<!--                                                               -->
<!-- PURPOSE:    Declaring the elements and specialization         -->
<!--             attributes for the DITA XML Metadata              -->
<!--                                                               -->
<!-- ORIGINAL CREATION DATE:                                       -->
<!--             March 2001                                        -->
<!--                                                               -->
<!--             (C) Copyright OASIS Open 2005, 2009.              -->
<!--             (C) Copyright IBM Corporation 2001, 2004.         -->
<!--             All Rights Reserved.                              -->
<!--                                                               -->
<!--  UPDATES:                                                     -->
<!--    2005.11.15 RDA: Corrected the "Delivered as" system ID     -->
<!--    2006.06.06 RDA: Move indexterm into commonElements         -->
<!--    2006.06.07 RDA: Make universal attributes universal        -->
<!--                      (DITA 1.1 proposal #12)                  -->
<!--    2006.11.30 RDA: Add -dita-use-conref-target to enumerated  -->
<!--                      attributes                               -->
<!--    2007.12.01 EK:  Reformatted DTD modules for DITA 1.2       -->
<!--    2008.01.28 RDA: Removed enumerations for attributes:       -->
<!--                    author/@type, copyright/@type,             -->
<!--                    permissions/@view, audience/@type,         -->
<!--                    audience/@job, audience/@experiencelevel   -->
<!--    2008.01.28 RDA: Moved <metadata> defn. here from topic.mod -->
<!--    2008.01.30 RDA: Replace @conref defn. with %conref-atts;   -->
<!--    2008.02.12 RDA: Add ph to source                           -->
<!--    2008.02.12 RDA: Add @format, @scope, and @type to          -->
<!--                    publisher, source                          -->
<!--    2008.02.12 RDA: Add @format, @scope, to author             -->
<!--    2008.02.13 RDA: Create .content and .attributes entities   -->
<!--    2009.03.09 RDA: Corrected public ID in comments to use     -->
<!--                    ELEMENTS instead of ENTITIES               -->
<!-- ============================================================= -->


<!-- ============================================================= -->
<!--                    ELEMENT NAME ENTITIES                      -->
<!-- ============================================================= -->


<!ENTITY % date-format 
 "CDATA"
>

<!-- ============================================================= -->
<!--                    ELEMENT DECLARATIONS                       -->
<!-- ============================================================= -->

<!--                    LONG NAME: Author                          -->
<!ENTITY % author.content
                       "(%words.cnt;)*"
>
<!-- 20080128: Removed enumeration for @type for DITA 1.2. Previous values:
               contributor, creator, -dita-use-conref-target           -->
<!ENTITY % author.attributes
             "%univ-atts;
              href 
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
              keyref 
                        CDATA 
                                  #IMPLIED
              type 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <author> metadata element contains the name of the topic's author.
Category: Prolog elements-->
<!ELEMENT author    %author.content;> 
<!ATTLIST author    %author.attributes;>

<!--                     LONG NAME: Source                         -->
<!ENTITY % source.content
                       "(%words.cnt; |
                         %ph;)*"
>
<!ENTITY % source.attributes
             "%univ-atts;
              href 
                        CDATA 
                                  #IMPLIED
              format 
                        CDATA 
                                  #IMPLIED
              type 
                        CDATA 
                                  #IMPLIED
              scope 
                       (external | 
                        local | 
                        peer | 
                        -dita-use-conref-target) 
                                  #IMPLIED
              keyref 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <source> element contains a reference to a resource from which the present topic is derived, either completely or in part. The element can contain a description of the resource; the href reference can be a string or a URL that points to it.
Category: Prolog elements-->
<!ELEMENT source    %source.content;>
<!ATTLIST source    %source.attributes;>



<!--                    LONG NAME: Publisher                       -->
<!ENTITY % publisher.content
                       "(%words.cnt;)*"
>
<!ENTITY % publisher.attributes
             "href 
                        CDATA 
                                  #IMPLIED
              format 
                        CDATA 
                                  #IMPLIED
              type 
                        CDATA 
                                  #IMPLIED
              scope 
                       (external | 
                        local | 
                        peer | 
                        -dita-use-conref-target) 
                                  #IMPLIED
              keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts;"
>
<!--doc:The <publisher> metadata element contains the name of the person, company, or organization responsible for making the content or subject of the topic available.
Category: Prolog elements-->
<!ELEMENT publisher    %publisher.content;>
<!ATTLIST publisher    %publisher.attributes;>

<!--                    LONG NAME: Copyright                       -->
<!ENTITY % copyright.content
                       "((%copyryear;)+, 
                         (%copyrholder;))"
>
<!-- 20080128: Removed enumeration for @type for DITA 1.2. Previous values:
               primary, secondary, -dita-use-conref-target           -->
<!ENTITY % copyright.attributes
             "%univ-atts;
              type 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <copyright> element is used for a single copyright entry. It includes the copyright years and the copyright holder. Multiple <copyright> statements are allowed.
Category: Prolog elements-->
<!ELEMENT copyright    %copyright.content;> 
<!ATTLIST copyright    %copyright.attributes;>

<!--                    LONG NAME: Copyright Year                  -->
<!ENTITY % copyryear.content
                       "EMPTY"
>
<!ENTITY % copyryear.attributes
             "year 
                        %date-format; 
                                  #REQUIRED
              %univ-atts;"
>
<!--doc:The <copyryear> element contains the copyright year as specified by the year attribute.
Category: Prolog elements-->
<!ELEMENT copyryear    %copyryear.content;>
<!ATTLIST copyryear    %copyryear.attributes;>



<!--                    LONG NAME: Copyright Holder                -->
<!ENTITY % copyrholder.content
                       "(%words.cnt;)*"
>
<!ENTITY % copyrholder.attributes
             "%univ-atts;"
>
<!--doc:The copyright holder (<copyrholder>) element names the entity that holds legal rights to the material contained in the topic.
Category: Prolog elements-->
<!ELEMENT copyrholder    %copyrholder.content;>
<!ATTLIST copyrholder    %copyrholder.attributes;>



<!--                    LONG NAME: Critical Dates                  -->
<!ENTITY % critdates.content
                       "((%created;)?, 
                         (%revised;)*)"
>
<!ENTITY % critdates.attributes
             "%univ-atts;"
>
<!--doc:The <critdates> element contains the critical dates in a document life cycle, such as the creation date and multiple revision dates.
Category: Prolog elements-->
<!ELEMENT critdates    %critdates.content;>
<!ATTLIST critdates    %critdates.attributes;>



<!--                    LONG NAME: Created Date                    -->
<!ENTITY % created.content
                       "EMPTY"
>
<!ENTITY % created.attributes
             "date 
                        %date-format; 
                                  #REQUIRED
              golive 
                        %date-format; 
                                  #IMPLIED
              expiry 
                        %date-format; 
                                  #IMPLIED 
              %univ-atts;"
>
<!--doc:The <created> element specifies the document creation date using the date attribute.
Category: Prolog elements-->
<!ELEMENT created    %created.content;>
<!ATTLIST created    %created.attributes;>



<!--                    LONG NAME: Revised Date                    -->
<!ENTITY % revised.content
                       "EMPTY"
>
<!ENTITY % revised.attributes
             "modified 
                        %date-format; 
                                  #REQUIRED
              golive 
                        %date-format; 
                                  #IMPLIED
              expiry 
                        %date-format; 
                                  #IMPLIED 
              %univ-atts;"
>
<!--doc:The <revised> element in the prolog is used to maintain tracking dates that are important in a topic development cycle, such as the last modification date, the original availability date, and the expiration date.
Category: Prolog elements-->
<!ELEMENT revised    %revised.content;>
<!ATTLIST revised    %revised.attributes;>


<!--                    LONG NAME: Permissions                     -->
<!ENTITY % permissions.content
                       "EMPTY"
>
<!-- 20080128: Removed enumeration for @type for DITA 1.2. Previous values:
               all, classified, entitled, internal, -dita-use-conref-target -->
<!ENTITY % permissions.attributes
             "%univ-atts;
              view 
                        CDATA 
                                  #REQUIRED"
>
<!--doc:The <permissions> prolog element can indicate any preferred controls for access to a topic. Topics can be filtered based on the permissions element. This capability depends on your output formatting process.
Category: Prolog elements-->
<!ELEMENT permissions    %permissions.content;>  
<!ATTLIST permissions    %permissions.attributes;>

<!--                    LONG NAME: Category                        -->
<!ENTITY % category.content
                       "(%words.cnt;)*"
>
<!ENTITY % category.attributes
             "%univ-atts;"
>
<!--doc:The <category> element can represent any category by which a topic might be classified for retrieval or navigation; for example, the categories could be used to group topics in a generated navigation bar. Topics can belong to multiple categories.
Category: Prolog elements-->
<!ELEMENT category    %category.content;>
<!ATTLIST category    %category.attributes;>


<!--                    LONG NAME: Metadata                        -->
<!ENTITY % metadata.content
                       "((%audience;)*, 
                         (%category;)*, 
                         (%keywords;)*,
                         (%prodinfo;)*, 
                         (%othermeta;)*, 
                         (%data.elements.incl; |
                          %foreign.unknown.incl;)*)"
>
<!ENTITY % metadata.attributes
             "%univ-atts; 
              mapkeyref 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <metadata> section of the prolog contains information about a topic such as audience and product information. Metadata can be used by computational processes to select particular topics or to prepare search indexes or to customize navigation. Elements inside of <metadata> provide information about the content and subject of a topic; prolog elements outside of <metadata> provide lifecycle information for the content unit (such as the author or copyright), which are unrelated to the subject.
Category: Prolog elements-->
<!ELEMENT metadata    %metadata.content;>
<!ATTLIST metadata    %metadata.attributes;>


<!--                    LONG NAME: Audience                        -->
<!ENTITY % audience.content
                       "EMPTY"
>
<!-- 20080128: Removed enumerations for DITA 1.2. Previous values:
         @type: administrator, executive, other, purchaser, programmer, 
                services, user, -dita-use-conref-target
         @job: administering, customizing, evaluating, installing,
               maintaining, migrating, other, planning, programming,
               troubleshooting, using, -dita-use-conref-target
         @experiencelevel: expert, general, novice, -dita-use-conref-target -->
<!ENTITY % audience.attributes
             "type 
                        CDATA 
                                  #IMPLIED
              othertype 
                        CDATA 
                                  #IMPLIED
              job 
                        CDATA
                                  #IMPLIED
              otherjob 
                        CDATA 
                                  #IMPLIED
              experiencelevel
                        CDATA 
                                  #IMPLIED
              name 
                        NMTOKEN 
                                  #IMPLIED
              %univ-atts;"
>
<!--doc:The <audience> metadata element indicates, through the value of its type attribute, the intended audience for a topic. Since a topic can have multiple audiences, you can include multiple audience elements. For each audience you specify, you can identify the high-level task (job) they are trying to accomplish and the level of experience (experiencelevel) expected. The audience element may be used to provide a more detailed definition of values used throughout the map or topic on the audience attribute.
Category: Prolog elements-->
<!ELEMENT audience    %audience.content;> 
<!ATTLIST audience    %audience.attributes;>

<!--                    LONG NAME: Keywords                        -->
<!ENTITY % keywords.content
                       "(%indexterm; | 
                         %keyword;)*"
>
<!ENTITY % keywords.attributes
             "%univ-atts;"
>
<!--doc:The <keywords> element contains a list of key words (using <indexterm> or <keyword> markup) that can be used by a search engine.
Category: Prolog elements-->
<!ELEMENT keywords    %keywords.content;>
<!ATTLIST keywords    %keywords.attributes;>



<!--                    LONG NAME: Product Information             -->
<!ENTITY % prodinfo.content
                       "((%prodname;), 
                         (%vrmlist;),
                         (%brand; | 
                          %component; | 
                          %featnum; | 
                          %platform; | 
                          %prognum; | 
                          %series;)* )"
>
<!ENTITY % prodinfo.attributes
             "%univ-atts;"
>
<!--doc:The <prodinfo> metadata element in the prolog contains information about the product or products that are the subject matter of the current topic. The prodinfo element may be used to provide a more detailed definition of values used throughout the map or topic on the product attribute.
Category: Prolog elements-->
<!ELEMENT prodinfo    %prodinfo.content;>
<!ATTLIST prodinfo    %prodinfo.attributes;>



<!--                    LONG NAME: Product Name                    -->
<!ENTITY % prodname.content
                       "(%words.cnt;)*"
>
<!ENTITY % prodname.attributes
             "%univ-atts;"
>
<!--doc:The <prodname> metadata element contains the name of the product that is supported by the information in this topic.
Category: Prolog elements-->
<!ELEMENT prodname    %prodname.content;>
<!ATTLIST prodname    %prodname.attributes;>



<!--                    LONG NAME: Version Release and Modification
                                   List                            -->
<!ENTITY % vrmlist.content
                       "(%vrm;)+"
>
<!ENTITY % vrmlist.attributes
             "%univ-atts;"
>
<!--doc:The <vrmlist> element contains a set of <vrm> elements for logging the version, release, and modification information for multiple products or versions of products to which the topic applies.
Category: Prolog elements-->
<!ELEMENT vrmlist    %vrmlist.content;>
<!ATTLIST vrmlist    %vrmlist.attributes;>



<!--                    LONG NAME: Version Release and Modification-->
<!ENTITY % vrm.content
                       "EMPTY"
>
<!ENTITY % vrm.attributes
             "version 
                        CDATA 
                                  #REQUIRED
              release 
                        CDATA 
                                  #IMPLIED
              modification 
                        CDATA 
                                  #IMPLIED 
              %univ-atts;"
>
<!--doc:The vrm empty element contains information about a single product's version, modification, and release, to which the current topic applies.
Category: Prolog elements-->
<!ELEMENT vrm    %vrm.content;>
<!ATTLIST vrm    %vrm.attributes;>

 
<!--                    LONG NAME: Brand                           -->
<!ENTITY % brand.content
                       "(%words.cnt;)*"
>
<!ENTITY % brand.attributes
             "%univ-atts;"
>
<!--doc:The <brand> element indicates the manufacturer or brand associated with the product described by the parent <prodinfo> element.
Category: Prolog elements-->
<!ELEMENT brand    %brand.content;>
<!ATTLIST brand    %brand.attributes;>



<!--                    LONG NAME: Series                          -->
<!ENTITY % series.content
                       "(%words.cnt;)*"
>
<!ENTITY % series.attributes
             "%univ-atts;"
>
<!--doc:The <series> metadata element contains information about the product series that the topic supports.
Category: Prolog elements-->
<!ELEMENT series    %series.content;>
<!ATTLIST series    %series.attributes;>



<!--                    LONG NAME: Platform                        -->
<!ENTITY % platform.content
                       "(%words.cnt;)*"
>
<!ENTITY % platform.attributes
             "%univ-atts;"
>
<!--doc:The <platform> metadata element contains a description of the operating system and/or hardware related to the product being described by the <prodinfo> element. The platform element may be used to provide a more detailed definition of values used throughout the map or topic on the platform attribute.
Category: Prolog elements-->
<!ELEMENT platform    %platform.content;>
<!ATTLIST platform    %platform.attributes;>


<!--                    LONG NAME: Program Number                  -->
<!ENTITY % prognum.content
                       "(%words.cnt;)*"
>
<!ENTITY % prognum.attributes
             "%univ-atts;"
>
<!--doc:The <prognum> metadata element identifies the program number of the associated program product. This is typically an order number or a product tracking code that could be replaced by an order number when a product completes development.
Category: Prolog elements-->
<!ELEMENT prognum    %prognum.content;>
<!ATTLIST prognum    %prognum.attributes;>



<!--                    LONG NAME: Feature Number                  -->
<!ENTITY % featnum.content
                       "(%words.cnt;)*"
>
<!ENTITY % featnum.attributes
             "%univ-atts;"
>
<!--doc:The <featnum> element contains the feature number of a product in the metadata.
Category: Prolog elements-->
<!ELEMENT featnum    %featnum.content;>
<!ATTLIST featnum    %featnum.attributes;>



<!--                    LONG NAME: Component                       -->
<!ENTITY % component.content
                       "(%words.cnt;)*"
>
<!ENTITY % component.attributes
             "%univ-atts;"
>
<!--doc:The <component> element describes the component of the product that this topic is concerned with. For example, a product might be made up of many components, each of which is installable separately. Components might also be shared by several products so that the same component is available for installation with many products. An implementation may (but need not) use this identification to check cross-component dependencies when some components are installed, but not others. An implementation may also (but need not) use the identification make sure that topics are hidden, removed, or flagged in some way when the component they describe isn't installed.
Category: Prolog elements-->
<!ELEMENT component    %component.content;>
<!ATTLIST component    %component.attributes;>



<!--                    LONG NAME: Other Metadata                  -->
<!--                    NOTE: needs to be HTML-equiv, at least     -->
<!ENTITY % othermeta.content
                       "EMPTY"
>
<!ENTITY % othermeta.attributes
             "name 
                        CDATA 
                                  #REQUIRED
              content 
                        CDATA 
                                  #REQUIRED
              translate-content
                        (no | 
                         yes | 
                         -dita-use-conref-target) 
              #IMPLIED
              %univ-atts;"
>
<!--doc:The <othermeta> element can be used to identify properties not otherwise included in <metadata> and assign name/content values to those properties. The name attribute identifies the property and the content attribute specifies the property's value. The values in this attribute are output as HTML metadata elements, and have no defined meaning for other possible outputs such as PDF.
Category: Prolog elements-->
<!ELEMENT othermeta    %othermeta.content;>
<!ATTLIST othermeta    %othermeta.attributes;>



<!--                    LONG NAME: Resource Identifier             -->
<!ENTITY % resourceid.content
                       "EMPTY"
>
<!ENTITY % resourceid.attributes
             "%select-atts;
              %localization-atts;
              id 
                        CDATA 
                                  #REQUIRED
              %conref-atts;
              appname 
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <resourceid> element provides an identifier for applications that require them in a particular format, when the normal id attribute of the topic can't be used. Each resourceid entry should be unique. It is one of the metadata elements that can be included within the prolog of a topic, along with document tracking and product information, etc. The element has no content, but takes an id attribute and an appname attribute.
Category: Prolog elements-->
<!ELEMENT resourceid    %resourceid.content;>
<!ATTLIST resourceid    %resourceid.attributes;>



<!-- ============================================================= -->
<!--                    SPECIALIZATION ATTRIBUTE DECLARATIONS      -->
<!-- ============================================================= -->
 

<!ATTLIST author      %global-atts;  class CDATA "- topic/author "      >
<!ATTLIST source      %global-atts;  class CDATA "- topic/source "      >
<!ATTLIST publisher   %global-atts;  class CDATA "- topic/publisher "   >
<!ATTLIST copyright   %global-atts;  class CDATA "- topic/copyright "   >
<!ATTLIST copyryear   %global-atts;  class CDATA "- topic/copyryear "   >
<!ATTLIST copyrholder %global-atts;  class CDATA "- topic/copyrholder " >
<!ATTLIST critdates   %global-atts;  class CDATA "- topic/critdates "   >
<!ATTLIST created     %global-atts;  class CDATA "- topic/created "     >
<!ATTLIST revised     %global-atts;  class CDATA "- topic/revised "     >
<!ATTLIST permissions %global-atts;  class CDATA "- topic/permissions " >
<!ATTLIST category    %global-atts;  class CDATA "- topic/category "    >
<!ATTLIST metadata    %global-atts;  class CDATA "- topic/metadata "   >
<!ATTLIST audience    %global-atts;  class CDATA "- topic/audience "    >
<!ATTLIST keywords    %global-atts;  class CDATA "- topic/keywords "    >
<!ATTLIST prodinfo    %global-atts;  class CDATA "- topic/prodinfo "    >
<!ATTLIST prodname    %global-atts;  class CDATA "- topic/prodname "    >
<!ATTLIST vrmlist     %global-atts;  class CDATA "- topic/vrmlist "     >
<!ATTLIST vrm         %global-atts;  class CDATA "- topic/vrm "         >
<!ATTLIST brand       %global-atts;  class CDATA "- topic/brand "       >
<!ATTLIST series      %global-atts;  class CDATA "- topic/series "      >
<!ATTLIST platform    %global-atts;  class CDATA "- topic/platform "    >
<!ATTLIST prognum     %global-atts;  class CDATA "- topic/prognum "     >
<!ATTLIST featnum     %global-atts;  class CDATA "- topic/featnum "     >
<!ATTLIST component   %global-atts;  class CDATA "- topic/component "   >
<!ATTLIST othermeta   %global-atts;  class CDATA "- topic/othermeta "   >
<!ATTLIST resourceid  %global-atts;  class CDATA "- topic/resourceid "  >

<!-- ================== End Metadata  ================================ -->