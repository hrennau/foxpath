<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================================= -->
<!--                    HEADER                                     -->
<!-- ============================================================= -->
<!--  MODULE:    DITA Bookmap                                      -->
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
PUBLIC "-//OASIS//ELEMENTS DITA BookMap//EN" 
      Delivered as file "bookmap.mod"                              -->

<!-- ============================================================= -->
<!-- SYSTEM:     Darwin Information Typing Architecture (DITA)     -->
<!--                                                               -->
<!-- PURPOSE:    Define elements and specialization atttributes    -->
<!--             for Book Maps                                     -->
<!--                                                               -->
<!-- ORIGINAL CREATION DATE:                                       -->
<!--             March 2004                                        -->
<!--                                                               -->
<!--             (C) Copyright OASIS Open 2005, 2009.              -->
<!--             (C) Copyright IBM Corporation 2004, 2005.         -->
<!--             All Rights Reserved.                              -->
<!--  UPDATES:                                                     -->
<!--    2007.12.01 EK:  Reformatted DTD modules for DITA 1.2       -->
<!--    2008.01.28 RDA: Removed enumerations for attributes:       -->
<!--                    publishtype/@value, bookrestriction/@value -->
<!--    2008.01.28 RDA: Added <metadata> to <bookmeta>             -->
<!--    2008.01.30 RDA: Replace @conref defn. with %conref-atts;   -->
<!--    2008.02.01 RDA: Added keys attributes, more keyref attrs   -->
<!--    2008.02.12 RDA: Add keyword to many data specializations   -->
<!--    2008.02.12 RDA: Add @format, @scope, and @type to          -->
<!--                    publisherinformation                       -->
<!--    2008.02.13 RDA: Create .content and .attributes entities   -->
<!--    2008.03.17 RDA: Add appendices element                     -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!--                   ARCHITECTURE ENTITIES                       -->
<!-- ============================================================= -->

<!-- default namespace prefix for DITAArchVersion attribute can be
     overridden through predefinition in the document type shell   -->
<!ENTITY % DITAArchNSPrefix
  "ditaarch" 
>

<!-- must be instanced on each topic type                          -->
<!ENTITY % arch-atts 
             "xmlns:%DITAArchNSPrefix; 
                         CDATA 
                                  #FIXED 'http://dita.oasis-open.org/architecture/2005/'
              %DITAArchNSPrefix;:DITAArchVersion
                         CDATA
                                  '1.2'
  "
>


<!-- ============================================================= -->
<!--                   ELEMENT NAME ENTITIES                       -->
<!-- ============================================================= -->
 
<!ENTITY % bookmap         "bookmap"                                 >

<!ENTITY % abbrevlist      "abbrevlist"                              >
<!ENTITY % bookabstract    "bookabstract"                            >
<!ENTITY % amendments      "amendments"                              >
<!ENTITY % appendices      "appendices"                              >
<!ENTITY % appendix        "appendix"                                >
<!ENTITY % approved        "approved"                                >
<!ENTITY % backmatter      "backmatter"                              >
<!ENTITY % bibliolist      "bibliolist"                              >
<!ENTITY % bookchangehistory "bookchangehistory"                     >
<!ENTITY % bookevent       "bookevent"                               >
<!ENTITY % bookeventtype   "bookeventtype"                           >
<!ENTITY % bookid          "bookid"                                  >
<!ENTITY % booklibrary     "booklibrary"                             >
<!ENTITY % booklist        "booklist"                                >
<!ENTITY % booklists       "booklists"                               >
<!ENTITY % bookmeta        "bookmeta"                                >
<!ENTITY % booknumber      "booknumber"                              >
<!ENTITY % bookowner       "bookowner"                               >
<!ENTITY % bookpartno      "bookpartno"                              >
<!ENTITY % bookrestriction "bookrestriction"                         >
<!ENTITY % bookrights      "bookrights"                              >
<!ENTITY % booktitle       "booktitle"                               >
<!ENTITY % booktitlealt    "booktitlealt"                            >
<!ENTITY % chapter         "chapter"                                 >
<!ENTITY % colophon        "colophon"                                >
<!ENTITY % completed       "completed"                               >
<!ENTITY % copyrfirst      "copyrfirst"                              >
<!ENTITY % copyrlast       "copyrlast"                               >
<!ENTITY % day             "day"                                     >
<!ENTITY % dedication      "dedication"                              >
<!ENTITY % draftintro      "draftintro"                              >
<!ENTITY % edited          "edited"                                  >
<!ENTITY % edition         "edition"                                 >
<!ENTITY % figurelist      "figurelist"                              >
<!ENTITY % frontmatter     "frontmatter"                             >
<!ENTITY % glossarylist    "glossarylist"                            >
<!ENTITY % indexlist       "indexlist"                               >
<!ENTITY % isbn            "isbn"                                    >
<!ENTITY % mainbooktitle   "mainbooktitle"                           >
<!ENTITY % maintainer      "maintainer"                              >
<!ENTITY % month           "month"                                   >
<!ENTITY % notices         "notices"                                 >
<!ENTITY % organization    "organization"                            >
<!ENTITY % part            "part"                                    >
<!ENTITY % person          "person"                                  >
<!ENTITY % preface         "preface"                                 >
<!ENTITY % printlocation   "printlocation"                           >
<!ENTITY % published       "published"                               >
<!ENTITY % publisherinformation "publisherinformation"               >
<!ENTITY % publishtype     "publishtype"                             >
<!ENTITY % reviewed        "reviewed"                                >
<!ENTITY % revisionid      "revisionid"                              >
<!ENTITY % started         "started"                                 >
<!ENTITY % summary         "summary"                                 >
<!ENTITY % tablelist       "tablelist"                               >
<!ENTITY % tested          "tested"                                  >
<!ENTITY % trademarklist   "trademarklist"                           >
<!ENTITY % toc             "toc"                                     >
<!ENTITY % volume          "volume"                                  >
<!ENTITY % year            "year"                                    >


<!-- ============================================================= -->
<!--                    DOMAINS ATTRIBUTE OVERRIDE                 -->
<!-- ============================================================= -->


<!ENTITY included-domains 
  ""
>

<!-- ============================================================= -->
<!--                    COMMON ATTLIST SETS                        -->
<!-- ============================================================= -->

<!-- Currently: same as topicref, minus @query -->
<!ENTITY % chapter-atts 
             'navtitle 
                         CDATA 
                                   #IMPLIED
              href 
                         CDATA 
                                   #IMPLIED
              keyref 
                         CDATA 
                                   #IMPLIED
              keys 
                         CDATA 
                                   #IMPLIED
              copy-to 
                         CDATA 
                                   #IMPLIED
              outputclass 
                         CDATA 
                                   #IMPLIED
              %topicref-atts;
              %univ-atts;' 
>


<!-- ============================================================= -->
<!--                    ELEMENT DECLARATIONS                       -->
<!-- ============================================================= -->


<!--                    LONG NAME: Book Map                        -->
<!ENTITY % bookmap.content
                       "(((%title;) | 
                          (%booktitle;))?,
                         (%bookmeta;)?, 
                         (%frontmatter;)?,
                         (%chapter;)*, 
                         (%part;)*, 
                         ((%appendices;)? | (%appendix;)*),
                         (%backmatter;)?,
                         (%reltable;)*)"
>
<!ENTITY % bookmap.attributes
             "id 
                        ID 
                                  #IMPLIED
              %conref-atts;
              anchorref 
                        CDATA 
                                  #IMPLIED
              outputclass 
                        CDATA 
                                  #IMPLIED
              %localization-atts;
              %topicref-atts;
              %select-atts;"
>
<!--doc:The <bookmap> element is a map file used to organize DITA content into a traditional book format.
Category: Bookmap elements-->
<!ELEMENT bookmap    %bookmap.content;>
<!ATTLIST bookmap    
              %bookmap.attributes;
              %arch-atts;
              domains 
                        CDATA 
                                  '&included-domains;'
>

<!--                    LONG NAME: Book Metadata                   -->
<!ENTITY % bookmeta.content
                       "((%linktext;)?, 
                         (%searchtitle;)?, 
                         (%shortdesc;)?, 
                         (%author;)*, 
                         (%source;)?, 
                         (%publisherinformation;)*,
                         (%critdates;)?, 
                         (%permissions;)?, 
                         (%metadata;)*, 
                         (%audience;)*, 
                         (%category;)*, 
                         (%keywords;)*, 
                         (%prodinfo;)*, 
                         (%othermeta;)*, 
                         (%resourceid;)*, 
                         (%bookid;)?,
                         (%bookchangehistory;)*,
                         (%bookrights;)*,
                         (%data;)*)"
>
<!ENTITY % bookmeta.attributes
             "lockmeta 
                        (no | 
                         yes | 
                         -dita-use-conref-target)
                                  #IMPLIED
              %univ-atts;"
>
<!--doc:The <bookmeta> element contains information about the book that is not considered book content, such as copyright information, author information, and any classifications.
Category: Bookmap elements-->
<!ELEMENT bookmeta    %bookmeta.content;>
<!ATTLIST bookmeta    %bookmeta.attributes;>


<!--                    LONG NAME: Front Matter                    -->
<!ENTITY % frontmatter.content
                       "(%bookabstract; | 
                         %booklists; | 
                         %colophon; | 
                         %dedication; | 
                         %draftintro; | 
                         %notices; | 
                         %preface; | 
                         %topicref;)*"
>
<!ENTITY % frontmatter.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              query 
                        CDATA 
                                  #IMPLIED
              outputclass 
                        CDATA 
                                  #IMPLIED
              %topicref-atts;
              %univ-atts;"
>
<!--doc:The <frontmatter> element contains the material that precedes the main body of a document. It may include items such as an abstract, a preface, and various types of book lists such as a <toc>, <tablelist>, or <figurelist>.
Category: Bookmap elements-->
<!ELEMENT frontmatter    %frontmatter.content;>
<!ATTLIST frontmatter    %frontmatter.attributes;>


<!--                    LONG NAME: Back Matter                     -->
<!ENTITY % backmatter.content
                       "(%amendments; | 
                         %booklists; | 
                         %colophon; | 
                         %dedication; | 
                         %notices; | 
                         %topicref;)*"
>
<!ENTITY % backmatter.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              query 
                        CDATA 
                                  #IMPLIED
              outputclass 
                        CDATA 
                                  #IMPLIED
              %topicref-atts;
              %univ-atts;"
>
<!--doc:The <backmatter> element contains the material that follows the main body of a document and any appendixes. It may include items such as a colophon, legal notices, and various types of book lists such as a glossary or an index.
Category: Bookmap elements-->
<!ELEMENT backmatter    %backmatter.content;>
<!ATTLIST backmatter    %backmatter.attributes;>


<!--                    LONG NAME: Publisher Information           -->
<!ENTITY % publisherinformation.content
                       "(((%person;) | 
                          (%organization;))*, 
                         (%printlocation;)*, 
                         (%published;)*, 
                         (%data;)*)"
>
<!ENTITY % publisherinformation.attributes
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
<!--doc:The <publisherinformation> contains information about what group or person published the book, where it was published, and certain details about its publication history. Other publication history information is found in the <bookchangehistory> element.
Category: Bookmap elements-->
<!ELEMENT publisherinformation    %publisherinformation.content;>
<!ATTLIST publisherinformation    %publisherinformation.attributes;>


<!--                    LONG NAME: Person                          -->
<!ENTITY % person.content
                       "(%words.cnt;)*"
>
<!ENTITY % person.attributes
             "%data-element-atts;"
>
<!--doc:The <person> element contains information about the name of a person. Note that unlike the <personname> element, the <person> element is not restricted to describing the names of authors.
Category: Bookmap elements-->
<!ELEMENT person    %person.content;>
<!ATTLIST person    %person.attributes;>


<!--                    LONG NAME: Organization                    -->
<!ENTITY % organization.content
                       "(%words.cnt;)*"
>
<!ENTITY % organization.attributes
             "%data-element-atts;"
>
<!--doc:The <organization> element contains the name of an organization. Note that unlike <organizationname>, the <organization> element is not restricted to usage within <authorinformation>; it does not have to contain the name of an authoring organization.
Category: Bookmap elements-->
<!ELEMENT organization    %organization.content;>
<!ATTLIST organization    %organization.attributes;>


<!--                    LONG NAME: Book Change History             -->
<!ENTITY % bookchangehistory.content
                       "((%reviewed;)*, 
                         (%edited;)*, 
                         (%tested;)*, 
                         (%approved;)*, 
                         (%bookevent;)*)"
>
<!ENTITY % bookchangehistory.attributes
             "%data-element-atts;"
>
<!--doc:The <bookchangehistory> element contains information about the history of the book's creation and publishing lifecycle, who wrote, reviewed, edited, and tested the book, and when these events took place.
Category: Bookmap elements-->
<!ELEMENT bookchangehistory    %bookchangehistory.content;>
<!ATTLIST bookchangehistory    %bookchangehistory.attributes;>


<!--                    LONG NAME: Book ID                         -->
<!ENTITY % bookid.content
                       "((%bookpartno;)*, 
                         (%edition;)?, 
                         (%isbn;)?, 
                         (%booknumber;)?, 
                         (%volume;)*, 
                         (%maintainer;)?)"
>
<!ENTITY % bookid.attributes
             "%data-element-atts;"
>
<!--doc:The <bookid> element contains the publisher's identification information for the book, such as part number, edition number and ISBN number.
Category: Bookmap elements-->
<!ELEMENT bookid    %bookid.content;>
<!ATTLIST bookid    %bookid.attributes;>


<!--                    LONG NAME: Summary                         -->
<!ENTITY % summary.content
                       "(%words.cnt;)*"
>
<!ENTITY % summary.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <summary> element contains a text summary associated with a book event (such as <approved> or <reviewed>) or with the list of copyrights for the book.
Category: Bookmap elements-->
<!ELEMENT summary    %summary.content;>
<!ATTLIST summary    %summary.attributes;>


<!--                    LONG NAME: Print Location                  -->
<!ENTITY % printlocation.content
                       "(%words.cnt;)*"
>
<!ENTITY % printlocation.attributes
             "%data-element-atts;"
>
<!--doc:The <printlocation> element indicates the location where the book was printed. Customarily, the content is restricted to the name of the country.
Category: Bookmap elements-->
<!ELEMENT printlocation    %printlocation.content;>
<!ATTLIST printlocation    %printlocation.attributes;>


<!--                    LONG NAME: Published                       -->
<!ENTITY % published.content
                       "(((%person;) | 
                          (%organization;))*,
                         (%publishtype;)?, 
                         (%revisionid;)?,
                         (%started;)?, 
                         (%completed;)?, 
                         (%summary;)?, 
                         (%data;)*)"
>
<!ENTITY % published.attributes
             "%data-element-atts;"
>
<!--doc:The <published> element contains information about the person or organization publishing the book, the dates when it was started and completed, and any special restrictions associated with it.
Category: Bookmap elements-->
<!ELEMENT published    %published.content;>
<!ATTLIST published    %published.attributes;>

<!--                    LONG NAME: Publish Type                    -->
<!ENTITY % publishtype.content
                       "EMPTY"
>
<!-- 20080128: Removed enumeration for @value for DITA 1.2. Previous values:
               beta, general, limited, -dita-use-conref-target
               Matches data-element-atts, but value is required           -->
<!ENTITY % publishtype.attributes
             "%univ-atts;
              name 
                        CDATA 
                                  #IMPLIED
              datatype 
                        CDATA 
                                  #IMPLIED
              href 
                        CDATA 
                                  #IMPLIED
              keyref 
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
              outputclass
                        CDATA 
                                  #IMPLIED
              value 
                        CDATA 
                                  #REQUIRED"
>
<!--doc:The <publishtype> element indicates whether the book is generally available or is restricted in some way. The value attribute indicates the restrictions.
Category: Bookmap elements-->
<!ELEMENT publishtype    %publishtype.content;>
<!ATTLIST publishtype    %publishtype.attributes;>
 
<!--                    LONG NAME: Revision ID                     -->
<!ENTITY % revisionid.content
                       "(#PCDATA |
                         %keyword;)*
">
<!ENTITY % revisionid.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <revisionid> element indicates the revision number or revision ID of the book. The processing implementation determines how the level is displayed. Common methods include using a dash, for example "-01". or a period, such as ".01".
Category: Bookmap elements-->
<!ELEMENT revisionid    %revisionid.content;>
<!ATTLIST revisionid    %revisionid.attributes;>

 
<!--                    LONG NAME: Start Date                      -->
<!ENTITY % started.content
                       "(((%year;), 
                          ((%month;), 
                           (%day;)?)?) | 
                         ((%month;), 
                          (%day;)?, 
                          (%year;)) | 
                         ((%day;), 
                          (%month;), 
                          (%year;)))"
>
<!ENTITY % started.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <started> element indicates a start date for some type of book event, such as a review, editing, or testing.
Category: Bookmap elements-->
<!ELEMENT started    %started.content;>
<!ATTLIST started    %started.attributes;>

 
<!--                    LONG NAME: Completion Date                 -->
<!ENTITY % completed.content
                       "(((%year;), 
                          ((%month;), 
                           (%day;)?)?) | 
                         ((%month;), 
                          (%day;)?, 
                          (%year;)) | 
                         ((%day;), 
                          (%month;), 
                          (%year;)))"
>
<!ENTITY % completed.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <completed> element indicates a completion date for some type of book event, such as a review, editing, or testing.
Category: Bookmap elements-->
<!ELEMENT completed    %completed.content;>
<!ATTLIST completed    %completed.attributes;>

 
<!--                    LONG NAME: Year                            -->
<!ENTITY % year.content
                       "(#PCDATA |
                         %keyword;)*"
>
<!ENTITY % year.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <year> element denotes a year.
Category: Bookmap elements-->
<!ELEMENT year    %year.content;>
<!ATTLIST year    %year.attributes;>

 
<!--                    LONG NAME: Month                           -->
<!ENTITY % month.content
                       "(#PCDATA |
                         %keyword;)*"
>
<!ENTITY % month.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <month> element denotes a month of the year.
Category: Bookmap elements-->
<!ELEMENT month    %month.content;>
<!ATTLIST month    %month.attributes;>

 
<!--                    LONG NAME: Day                             -->
<!ENTITY % day.content
                       "(#PCDATA |
                         %keyword;)*"
>
<!ENTITY % day.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <day> element denotes a day of the month.
Category: Bookmap elements-->
<!ELEMENT day    %day.content;>
<!ATTLIST day    %day.attributes;>

 
<!--                    LONG NAME: Reviewed                        -->
<!ENTITY % reviewed.content
                       "(((%organization;) | 
                          (%person;))*, 
                         (%revisionid;)?, 
                         (%started;)?, 
                         (%completed;)?, 
                         (%summary;)?, 
                         (%data;)*)"
>
<!ENTITY % reviewed.attributes
             "%data-element-atts;"
>
<!--doc:The <reviewed> element contains information about when and by whom the book was reviewed during its publication history.
Category: Bookmap elements-->
<!ELEMENT reviewed    %reviewed.content;>
<!ATTLIST reviewed    %reviewed.attributes;>


<!--                    LONG NAME: Editeded                        -->
<!ENTITY % edited.content
                       "(((%organization;) | 
                          (%person;))*, 
                          (%revisionid;)?, 
                          (%started;)?, 
                          (%completed;)?, 
                          (%summary;)?, 
                          (%data;)*)"
>
<!ENTITY % edited.attributes
             "%data-element-atts;"
>
<!--doc:The <edited> element contains information about when and by whom the book was edited during its publication history.
Category: Bookmap elements-->
<!ELEMENT edited    %edited.content;>
<!ATTLIST edited    %edited.attributes;>


<!--                    LONG NAME: Tested                          -->
<!ENTITY % tested.content
                       "(((%organization;) | 
                          (%person;))*, 
                          (%revisionid;)?, 
                          (%started;)?, 
                          (%completed;)?, 
                          (%summary;)?, 
                          (%data;)*)"
>
<!ENTITY % tested.attributes
             "%data-element-atts;"
>
<!--doc:The <tested> element contains information about when and by whom the book was tested during its publication history.
Category: Bookmap elements-->
<!ELEMENT tested    %tested.content;>
<!ATTLIST tested    %tested.attributes;>


<!--                    LONG NAME: Approved                        -->
<!ENTITY % approved.content
                       "(((%organization;) | 
                          (%person;))*, 
                          (%revisionid;)?, 
                          (%started;)?, 
                          (%completed;)?, 
                          (%summary;)?, 
                          (%data;)*)"
>
<!ENTITY % approved.attributes
             "%data-element-atts;"
>
<!--doc:The <approved> element contains information about when and by whom the book was approved during its publication history.
Category: Bookmap elements-->
<!ELEMENT approved    %approved.content;>
<!ATTLIST approved    %approved.attributes;>


<!--                    LONG NAME: Book Event                      -->
<!ENTITY % bookevent.content
                       "((%bookeventtype;)?, 
                         (((%organization;) | 
                           (%person;))*, 
                          (%revisionid;)?, 
                          (%started;)?, 
                          (%completed;)?, 
                          (%summary;)?, 
                          (%data;)*))"
>
<!ENTITY % bookevent.attributes
             "%data-element-atts;"
>
<!--doc:The <bookevent> element indicates a general event in the publication history of a book. This is an appropriate element for specialization if the current set of specific book event types, that is, review, edit, test or approval, does not meed your needs.
Category: Bookmap elements-->
<!ELEMENT bookevent    %bookevent.content;>
<!ATTLIST bookevent    %bookevent.attributes;>

<!--                    LONG NAME: Book Event Type                 -->
<!ENTITY % bookeventtype.content
                       "EMPTY"
>
<!-- Attributes are the same as data-element-atts except that 
     @name is required                                             -->
<!ENTITY % bookeventtype.attributes
             "name 
                        CDATA 
                                  #REQUIRED 
              datatype 
                        CDATA 
                                  #IMPLIED
              value 
                        CDATA 
                                  #IMPLIED
              href 
                        CDATA 
                                  #IMPLIED
              keyref 
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
              %univ-atts;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <bookeventtype> element indicates the specific nature of a <bookevent>, such as updated, indexed, or deprecated. The required name attribute indicates the event's type.
Category: Bookmap elements-->
<!ELEMENT bookeventtype    %bookeventtype.content;>
<!ATTLIST bookeventtype    %bookeventtype.attributes;>

<!--                    LONG NAME: Book Part Number                -->
<!ENTITY % bookpartno.content
                       "(%words.cnt;)*"
>
<!ENTITY % bookpartno.attributes
             "%data-element-atts;"
>
<!--doc:The <bookpartno> element contains the book's part number; such as 99F1234. This is generally the number that the publisher uses to identify the book for tracking purposes.
Category: Bookmap elements-->
<!ELEMENT bookpartno    %bookpartno.content;>
<!ATTLIST bookpartno    %bookpartno.attributes;>


<!--                    LONG NAME: Edition                         -->
<!ENTITY % edition.content
                       "(#PCDATA |
                         %keyword;)*"
>
<!ENTITY % edition.attributes
             "%data-element-atts;"
>
<!--doc:The <edition> element contains the edition number information, such as First Edition, or Third Edition, used by a publisher to identify a book.
Category: Bookmap elements-->
<!ELEMENT edition    %edition.content;>
<!ATTLIST edition    %edition.attributes;>


<!--                    LONG NAME: ISBN Number                     -->
<!ENTITY % isbn.content
                       "(#PCDATA |
                         %keyword;)*"
>
<!ENTITY % isbn.attributes
             "%data-element-atts;"
>
<!--doc:The <isbn> element contains the book's International Standard Book Number (ISBN).
Category: Bookmap elements-->
<!ELEMENT isbn    %isbn.content;>
<!ATTLIST isbn    %isbn.attributes;>


<!--                    LONG NAME: Book Number                     -->
<!ENTITY % booknumber.content
                       "(%words.cnt;)*"
>
<!ENTITY % booknumber.attributes
             "%data-element-atts;"
>
<!--doc:The <booknumber> element contains the book's form number, such as SC21-1920.
Category: Bookmap elements-->
<!ELEMENT booknumber    %booknumber.content;>
<!ATTLIST booknumber    %booknumber.attributes;>


<!--                    LONG NAME: Volume                          -->
<!ENTITY % volume.content
                       "(#PCDATA |
                         %keyword;)*"
>
<!ENTITY % volume.attributes
             "%data-element-atts;"
>
<!--doc:The <volume> element contains the book's volume number, such as Volume 2.
Category: Bookmap elements-->
<!ELEMENT volume    %volume.content;>
<!ATTLIST volume    %volume.attributes;>


<!--                    LONG NAME: Maintainer                      -->
<!ENTITY % maintainer.content
                       "(((%person;) | 
                          (%organization;))*, 
                         (%data;)*)
">
<!ENTITY % maintainer.attributes
             "%data-element-atts;"
>
<!--doc:The <maintainer> element contains information about who maiintains the document; this can be an organization or a person.
Category: Bookmap elements-->
<!ELEMENT maintainer    %maintainer.content;>
<!ATTLIST maintainer    %maintainer.attributes;>


<!--                    LONG NAME: Book Rights                     -->
<!ENTITY % bookrights.content
                       "((%copyrfirst;)?, 
                         (%copyrlast;)?,
                         (%bookowner;), 
                         (%bookrestriction;)?, 
                         (%summary;)?)"
>
<!ENTITY % bookrights.attributes
             "%data-element-atts;"
>
<!--doc:The <bookrights> element contains the information about the legal rights associated with the book, including copyright dates and owners.
Category: Bookmap elements-->
<!ELEMENT bookrights    %bookrights.content;>
<!ATTLIST bookrights    %bookrights.attributes;>


<!--                    LONG NAME: First Copyright                 -->
<!ENTITY % copyrfirst.content
                       "(%year;)"
>
<!ENTITY % copyrfirst.attributes
             "%data-element-atts;"
>
<!--doc:The <copyfirst> element contains the first copyright year within a multiyear copyright statement.
Category: Bookmap elements-->
<!ELEMENT copyrfirst    %copyrfirst.content;>
<!ATTLIST copyrfirst    %copyrfirst.attributes;>

 
<!--                    LONG NAME: Last Copyright                  -->
<!ENTITY % copyrlast.content
                       "(%year;)"
>
<!ENTITY % copyrlast.attributes
             "%data-element-atts;"
>
<!--doc:The <copylast> element contains the last copyright year within a multiyear copyright statement.
Category: Bookmap elements-->
<!ELEMENT copyrlast    %copyrlast.content;>
<!ATTLIST copyrlast    %copyrlast.attributes;>


<!--                    LONG NAME: Book Owner                      -->
<!ENTITY % bookowner.content
                       "((%organization;) | 
                         (%person;))* 
 ">
<!ENTITY % bookowner.attributes
             "%data-element-atts;"
>
<!--doc:The <bookowner> element contains the owner of the copyright.
Category: Bookmap elements-->
<!ELEMENT bookowner    %bookowner.content;>
<!ATTLIST bookowner    %bookowner.attributes;>

<!--                    LONG NAME: Book Restriction                -->
<!ENTITY % bookrestriction.content
                       "EMPTY"
>
<!-- Same attributes as data-element-atts, except for @value -->
<!-- 20080128: Removed enumeration for @value for DITA 1.2. Previous values:
               confidential, licensed, restricted, 
               unclassified, -dita-use-conref-target               -->
<!ENTITY % bookrestriction.attributes
             "%univ-atts;
              name 
                        CDATA 
                                  #IMPLIED
              datatype 
                        CDATA 
                                  #IMPLIED
              href 
                        CDATA 
                                  #IMPLIED
              keyref 
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
              outputclass
                        CDATA 
                                  #IMPLIED
              value 
                        CDATA 
                                  #REQUIRED"
>
<!--doc:The <bookrestriction> element indicates whether the book is classified, or restricted in some way. The value attribute indicates the restrictions; this may be a string like "All Rights Reserved," representing the publisher's copyright restrictions.
Category: Bookmap elements-->
<!ELEMENT bookrestriction    %bookrestriction.content;>
<!ATTLIST bookrestriction    %bookrestriction.attributes;>

<!--                    LONG NAME: Book Title                      -->
<!ENTITY % booktitle.content
                       "((%booklibrary;)?,
                         (%mainbooktitle;),
                         (%booktitlealt;)*)"
>
<!ENTITY % booktitle.attributes
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
<!--doc:The <booktitle> element contains the title information for a book. , including <booklibrary> data, a <maintitle> and subtitle (<titlealt>) as required.
Category: Bookmap elements-->
<!ELEMENT booktitle    %booktitle.content;>
<!ATTLIST booktitle    %booktitle.attributes;>


<!-- The following three elements are specialized from <ph>. They are
     titles, which have a more limited content model than phrases. The
     content model here matches title.cnt; that entity is not reused
     in case it is expanded in the future to include something not
     allowed in a phrase.                                          -->
<!--                    LONG NAME: Library Title                   -->
<!ENTITY % booklibrary.content
                       "(#PCDATA | 
                         %basic.ph.noxref; | 
                         %image;)*"
>
<!ENTITY % booklibrary.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <booklibrary> element contains the library information for a book. Library entries contain information about the series, library, or collection of documents to which the book belongs.
Category: Bookmap elements-->
<!ELEMENT booklibrary    %booklibrary.content;>
<!ATTLIST booklibrary    %booklibrary.attributes;>

 
<!--                    LONG NAME: Main Book Title                 -->
<!ENTITY % mainbooktitle.content
                       "(#PCDATA | 
                         %basic.ph.noxref; | 
                         %image;)*"
>
<!ENTITY % mainbooktitle.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <mainbooktitle> element contains the primary title information for a book.
Category: Bookmap elements-->
<!ELEMENT mainbooktitle    %mainbooktitle.content;>
<!ATTLIST mainbooktitle    %mainbooktitle.attributes;>

 
<!--                    LONG NAME: Alternate Book Title            -->
<!ENTITY % booktitlealt.content
                       "(#PCDATA | 
                         %basic.ph.noxref; | 
                         %image;)*"
>
<!ENTITY % booktitlealt.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA 
                                  #IMPLIED"
>
<!--doc:The <booktitlealt> element contains the alternative title, subtitle, or short title for a book.
Category: Bookmap elements-->
<!ELEMENT booktitlealt    %booktitlealt.content;>
<!ATTLIST booktitlealt    %booktitlealt.attributes;>


<!--                    LONG NAME: Draft Introduction              -->
<!ENTITY % draftintro.content
                       "((%topicmeta;)?, 
                         (%topicref;)*)"
>
<!ENTITY % draftintro.attributes
             "%chapter-atts;"
>
<!--doc:The <draftintro> element references a topic used as an introduction to the draft of this book.
Category: Bookmap elements-->
<!ELEMENT draftintro    %draftintro.content;>
<!ATTLIST draftintro    %draftintro.attributes;>


<!--                    LONG NAME: Book Abstract                   -->
<!ENTITY % bookabstract.content
                       "EMPTY"
>
<!ENTITY % bookabstract.attributes
             "%chapter-atts;"
>
<!--doc:The <bookabstract> element references a topic used within a bookmap as a brief summary of book content, generally output as part of the book's front matter. It is used to help the reader quickly evaluate the book's purpose
Category: Bookmap elements-->
<!ELEMENT bookabstract    %bookabstract.content;>
<!ATTLIST bookabstract    %bookabstract.attributes;>


<!--                    LONG NAME: Dedication                      -->
<!ENTITY % dedication.content
                       "EMPTY"
>
<!ENTITY % dedication.attributes
             "%chapter-atts;"
>
<!--doc:The <dedication> element references a topic containing a dedication for the book, such as to a person or group.
Category: Bookmap elements-->
<!ELEMENT dedication    %dedication.content;>
<!ATTLIST dedication    %dedication.attributes;>


<!--                    LONG NAME: Preface                         -->
<!ENTITY % preface.content
                       "((%topicmeta;)?, 
                         (%topicref;)*)"
>
<!ENTITY % preface.attributes
             "%chapter-atts;"
>
<!--doc:The <preface> element references introductory information about a book, such as the purpose and structure of the document.
Category: Bookmap elements-->
<!ELEMENT preface    %preface.content;>
<!ATTLIST preface    %preface.attributes;>


<!--                    LONG NAME: Chapter                         -->
<!ENTITY % chapter.content
                       "((%topicmeta;)?, 
                         (%topicref;)*)"
>
<!ENTITY % chapter.attributes
             "%chapter-atts;"
>
<!--doc:The <chapter> element references a topic as a chapter within a book.
Category: Bookmap elements-->
<!ELEMENT chapter    %chapter.content;>
<!ATTLIST chapter    %chapter.attributes;>


<!--                    LONG NAME: Part                            -->
<!ENTITY % part.content
                       "((%topicmeta;)?,
                         ((%chapter;) | 
                          (%topicref;))* )"
>
<!ENTITY % part.attributes
             "%chapter-atts;"
>
<!--doc:The <part> element references a part topic for the book. A new part is started. Use <part> to divide a document's chapters into logical groupings. For example, in a document that contains both guide and reference information, you can define two parts, one containing the guide information and the other containing the reference information.
Category: Bookmap elements-->
<!ELEMENT part    %part.content;>
<!ATTLIST part    %part.attributes;>


<!--                    LONG NAME: Appendix                        -->
<!ENTITY % appendix.content
                       "((%topicmeta;)?, 
                         (%topicref;)*)"
>
<!ENTITY % appendix.attributes
             "%chapter-atts;"
>
<!--doc:The <appendix> element references a topic as a appendix within a book.
Category: Bookmap elements-->
<!ELEMENT appendix    %appendix.content;>
<!ATTLIST appendix    %appendix.attributes;>


<!--                    LONG NAME: Appendices                      -->
<!ENTITY % appendices.content
                       "((%topicmeta;)?, 
                         (%appendix;)*)"
>
<!ENTITY % appendices.attributes
             "%chapter-atts;"
>
<!--doc:The <appendices> element is an optional wrapper for <appendix> elements within a bookmap.-->
<!ELEMENT appendices    %appendices.content;>
<!ATTLIST appendices    %appendices.attributes;>

<!--                    LONG NAME: Notices                         -->
<!ENTITY % notices.content
                       "((%topicmeta;)?, 
                         (%topicref;)*)"
>
<!ENTITY % notices.attributes
             "%chapter-atts;"
>
<!--doc:The <notices> element references special notice information, for example, legal notices about supplementary copyrights and trademarks associated with the book. .
Category: Bookmap elements-->
<!ELEMENT notices    %notices.content;>
<!ATTLIST notices    %notices.attributes;>


<!--                    LONG NAME: Amendments                      -->
<!ENTITY % amendments.content
                       "EMPTY"
>
<!ENTITY % amendments.attributes
             "%chapter-atts;"
>
<!--doc:The <amendments> element references a list of amendments or updates to the book. It indicates to the processing software that the author wants an amendments list generated at the particular location.
Category: Bookmap elements-->
<!ELEMENT amendments    %amendments.content;>
<!ATTLIST amendments    %amendments.attributes;>


<!--                    LONG NAME: Colophon                        -->
<!ENTITY % colophon.content
                       "EMPTY"
>
<!ENTITY % colophon.attributes
             "%chapter-atts;"
>
<!--doc:The <colophon> element references a topic describing how this document was created. In publishing, a colophon describes details of the production of a book. This information generally includes the typefaces used, and often the names of their designers; the paper, ink and details of the binding materials and methods may also receive mention. In the case of technical books, a colophon may specify the software used to prepare the text and diagrams for publication.
Category: Bookmap elements-->
<!ELEMENT colophon    %colophon.content;>
<!ATTLIST colophon    %colophon.attributes;>


<!--                    LONG NAME: Book Lists                      -->
<!ENTITY % booklists.content
                       "((%abbrevlist;) |
                         (%bibliolist;) |
                         (%booklist;) |
                         (%figurelist;) |
                         (%glossarylist;) |
                         (%indexlist;) |
                         (%tablelist;) |
                         (%trademarklist;) |
                         (%toc;))*"
>
<!ENTITY % booklists.attributes
             "keyref 
                        CDATA 
                                  #IMPLIED
              %topicref-atts;
              %id-atts;
              %select-atts;
              %localization-atts;"
>
<!--doc:The <booklists> element references lists of various kinds within the book. For example, it can be used within front matter to reference a <toc>, <tablelist>, and <figurelist>, or within back matter to reference a <glossarylist>, <indexlist>, and <abbrevlist>. It indicates to the processing software that the author wants the lists generated at the <booklists> location.
Category: Bookmap elements-->
<!ELEMENT booklists    %booklists.content;>
<!ATTLIST booklists    %booklists.attributes;>


<!--                    LONG NAME: Table of Contents               -->
<!ENTITY % toc.content
                       "EMPTY"
>
<!ENTITY % toc.attributes
             "%chapter-atts;"
>
<!--doc:The <toc> element references the table of contents within the book. It indicates to the processing software that the author wants a table of contents generated at the particular location.
Category: Bookmap elements-->
<!ELEMENT toc    %toc.content;>
<!ATTLIST toc    %toc.attributes;>


<!--                    LONG NAME: Figure List                     -->
<!ENTITY % figurelist.content
                       "EMPTY"
>
<!ENTITY % figurelist.attributes
             "%chapter-atts;"
>
<!--doc:The <figurelist> element references a list of figures in the book. It indicates to the processing software that the author wants a list of figures generated at the particular location.
Category: Bookmap elements-->
<!ELEMENT figurelist    %figurelist.content;>
<!ATTLIST figurelist    %figurelist.attributes;>


<!--                    LONG NAME: Table List                      -->
<!ENTITY % tablelist.content
                       "EMPTY"
>
<!ENTITY % tablelist.attributes
             "%chapter-atts;"
>
<!--doc:The <tablelist> element references a list of tables within the book. It indicates to the processing software that the author wants a list of tables generated at the particular location.
Category: Bookmap elements-->
<!ELEMENT tablelist    %tablelist.content;>
<!ATTLIST tablelist    %tablelist.attributes;>


<!--                    LONG NAME: Abbreviation List               -->
<!ENTITY % abbrevlist.content
                       "EMPTY"
>
<!ENTITY % abbrevlist.attributes
             "%chapter-atts;"
>
<!--doc:The <abbrevlist> element references a list of abbreviations. It indicates to the processing software that the author wants an abbreviation list generated at the particular location.
Category: Bookmap elements-->
<!ELEMENT abbrevlist    %abbrevlist.content;>
<!ATTLIST abbrevlist    %abbrevlist.attributes;>


<!--                    LONG NAME: Trademark List                  -->
<!ENTITY % trademarklist.content
                       "EMPTY"
>
<!ENTITY % trademarklist.attributes
             "%chapter-atts;"
>
<!--doc:The <trademarklist> element references a list of trademarks within the book. It indicates to the processing software that the author wants a list of trademarks generated at the particular location.
Category: Bookmap elements-->
<!ELEMENT trademarklist    %trademarklist.content;>
<!ATTLIST trademarklist    %trademarklist.attributes;>


<!--                    LONG NAME: Bibliography List               -->
<!ENTITY % bibliolist.content
                       "EMPTY"
>
<!ENTITY % bibliolist.attributes
             "%chapter-atts;"
>
<!--doc:The <bibliolist> element references a list of bibliographic entries within the book. It indicates to the processing software that the author wants a bibliography, containing links to related books, articles, published papers, or other types of material, generated at the particular location.
Category: Bookmap elements-->
<!ELEMENT bibliolist    %bibliolist.content;>
<!ATTLIST bibliolist    %bibliolist.attributes;>


<!--                    LONG NAME: Glossary List                   -->
<!ENTITY % glossarylist.content
                       "((%topicmeta;)?, 
                         (%topicref;)*)"
>
<!ENTITY % glossarylist.attributes
             "%chapter-atts;"
>
<!--doc:The <glossarylist> element references a list of glossary entries within the book. It indicates to the processing software that the author wants a glossary list generated at the particular location.
Category: Bookmap elements-->
<!ELEMENT glossarylist    %glossarylist.content;>
<!ATTLIST glossarylist    %glossarylist.attributes;>


<!--                    LONG NAME: Index List                      -->
<!ENTITY % indexlist.content
                       "EMPTY"
>
<!ENTITY % indexlist.attributes
             "%chapter-atts;"
>
<!--doc:The <indexlist> element lists the index entries in the book. It indicates to the processing software that the author wants an index generated at the particular location.
Category: Bookmap elements-->
<!ELEMENT indexlist    %indexlist.content;>
<!ATTLIST indexlist    %indexlist.attributes;>


<!--                    LONG NAME: Book List                       -->
<!ENTITY % booklist.content
                       "EMPTY"
>
<!ENTITY % booklist.attributes
             "%chapter-atts;"
>
<!--doc:The <booklist> element is a general purpose element, designed for use in specializations, that references a list of particular types of topics within the book. It indicates to the processing software that the author wants that list of topics generated at the particular location. For example, it could be used in a specialization to reference the location of a list of program listings or of authors of topics.
Category: Bookmap elements-->
<!ELEMENT booklist    %booklist.content;>
<!ATTLIST booklist    %booklist.attributes;>


 
<!-- ============================================================= -->
<!--                    SPECIALIZATION ATTRIBUTE DECLARATIONS      -->
<!-- ============================================================= -->

<!ATTLIST bookmap     %global-atts; class CDATA "- map/map bookmap/bookmap ">
<!ATTLIST abbrevlist  %global-atts; class CDATA "- map/topicref bookmap/abbrevlist ">
<!ATTLIST amendments  %global-atts; class CDATA "- map/topicref bookmap/amendments ">
<!ATTLIST appendices  %global-atts; class CDATA "- map/topicref bookmap/appendices ">
<!ATTLIST appendix    %global-atts; class CDATA "- map/topicref bookmap/appendix ">
<!ATTLIST approved    %global-atts; class CDATA "- topic/data bookmap/approved ">
<!ATTLIST backmatter  %global-atts; class CDATA "- map/topicref bookmap/backmatter ">
<!ATTLIST bibliolist  %global-atts; class CDATA "- map/topicref bookmap/bibliolist ">
<!ATTLIST bookabstract %global-atts; class CDATA "- map/topicref bookmap/bookabstract ">
<!ATTLIST bookchangehistory %global-atts; class CDATA "- topic/data bookmap/bookchangehistory ">
<!ATTLIST bookevent   %global-atts; class CDATA "- topic/data bookmap/bookevent ">
<!ATTLIST bookeventtype %global-atts; class CDATA "- topic/data bookmap/bookeventtype ">
<!ATTLIST bookid      %global-atts; class CDATA "- topic/data bookmap/bookid ">
<!ATTLIST booklibrary %global-atts;  class CDATA "- topic/ph bookmap/booklibrary ">
<!ATTLIST booklist    %global-atts; class CDATA "- map/topicref bookmap/booklist ">
<!ATTLIST booklists   %global-atts; class CDATA "- map/topicref bookmap/booklists ">
<!ATTLIST bookmeta    %global-atts; class CDATA "- map/topicmeta bookmap/bookmeta ">
<!ATTLIST booknumber  %global-atts; class CDATA "- topic/data bookmap/booknumber ">
<!ATTLIST bookowner   %global-atts; class CDATA "- topic/data bookmap/bookowner ">
<!ATTLIST bookpartno  %global-atts; class CDATA "- topic/data bookmap/bookpartno ">
<!ATTLIST bookrestriction %global-atts; class CDATA "- topic/data bookmap/bookrestriction ">
<!ATTLIST bookrights  %global-atts; class CDATA "- topic/data bookmap/bookrights ">
<!ATTLIST booktitle   %global-atts;  class CDATA "- topic/title bookmap/booktitle ">
<!ATTLIST booktitlealt %global-atts;  class CDATA "- topic/ph bookmap/booktitlealt ">
<!ATTLIST chapter     %global-atts; class CDATA "- map/topicref bookmap/chapter ">
<!ATTLIST colophon    %global-atts; class CDATA "- map/topicref bookmap/colophon ">
<!ATTLIST completed   %global-atts; class CDATA "- topic/ph bookmap/completed ">
<!ATTLIST copyrfirst  %global-atts; class CDATA "- topic/data bookmap/copyrfirst ">
<!ATTLIST copyrlast   %global-atts; class CDATA "- topic/data bookmap/copyrlast ">
<!ATTLIST day         %global-atts; class CDATA "- topic/ph bookmap/day ">
<!ATTLIST dedication  %global-atts; class CDATA "- map/topicref bookmap/dedication ">
<!ATTLIST draftintro  %global-atts; class CDATA "- map/topicref bookmap/draftintro ">
<!ATTLIST edited      %global-atts; class CDATA "- topic/data bookmap/edited ">
<!ATTLIST edition     %global-atts; class CDATA "- topic/data bookmap/edition ">
<!ATTLIST figurelist  %global-atts; class CDATA "- map/topicref bookmap/figurelist ">
<!ATTLIST frontmatter %global-atts; class CDATA "- map/topicref bookmap/frontmatter ">
<!ATTLIST glossarylist %global-atts; class CDATA "- map/topicref bookmap/glossarylist ">
<!ATTLIST indexlist   %global-atts; class CDATA "- map/topicref bookmap/indexlist ">
<!ATTLIST isbn        %global-atts; class CDATA "- topic/data bookmap/isbn ">
<!ATTLIST mainbooktitle %global-atts;  class CDATA "- topic/ph bookmap/mainbooktitle ">
<!ATTLIST maintainer  %global-atts; class CDATA "- topic/data bookmap/maintainer ">
<!ATTLIST month       %global-atts; class CDATA "- topic/ph bookmap/month ">
<!ATTLIST notices     %global-atts; class CDATA "- map/topicref bookmap/notices ">
<!ATTLIST organization %global-atts; class CDATA "- topic/data bookmap/organization ">
<!ATTLIST part        %global-atts; class CDATA "- map/topicref bookmap/part ">
<!ATTLIST person      %global-atts; class CDATA "- topic/data bookmap/person ">
<!ATTLIST preface     %global-atts; class CDATA "- map/topicref bookmap/preface ">
<!ATTLIST printlocation %global-atts; class CDATA "- topic/data bookmap/printlocation ">
<!ATTLIST published   %global-atts; class CDATA "- topic/data bookmap/published ">
<!ATTLIST publisherinformation %global-atts; class CDATA "- topic/publisher bookmap/publisherinformation ">
<!ATTLIST publishtype %global-atts; class CDATA "- topic/data bookmap/publishtype ">
<!ATTLIST reviewed    %global-atts; class CDATA "- topic/data bookmap/reviewed ">
<!ATTLIST revisionid  %global-atts; class CDATA "- topic/ph bookmap/revisionid ">
<!ATTLIST started     %global-atts; class CDATA "- topic/ph bookmap/started ">
<!ATTLIST summary     %global-atts; class CDATA "- topic/ph bookmap/summary ">
<!ATTLIST tablelist   %global-atts; class CDATA "- map/topicref bookmap/tablelist ">
<!ATTLIST tested      %global-atts; class CDATA "- topic/data bookmap/tested ">
<!ATTLIST toc         %global-atts; class CDATA "- map/topicref bookmap/toc ">
<!ATTLIST trademarklist %global-atts; class CDATA "- map/topicref bookmap/trademarklist ">
<!ATTLIST volume      %global-atts; class CDATA "- topic/data bookmap/volume ">
<!ATTLIST year        %global-atts; class CDATA "- topic/ph bookmap/year ">

<!-- ================== End book map ============================= -->