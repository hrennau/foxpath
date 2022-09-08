<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================================= -->
<!--                    HEADER                                     -->
<!-- ============================================================= -->
<!--  MODULE:    DITA learningPlan                                 -->
<!--  VERSION:   1.2                                               -->
<!--  DATE:      November 2009                                     -->
<!--                                                               -->
<!-- ============================================================= -->

<!-- ============================================================= -->
<!--                    PUBLIC DOCUMENT TYPE DEFINITION            -->
<!--                    TYPICAL INVOCATION                         -->
<!--                                                               -->
<!--  Refer to this file by the following public identfier or an 
      appropriate system identifier 
PUBLIC "-//OASIS//ELEMENTS DITA Learning Plan//EN"
      Delivered as file "learningPlan.mod                          -->

<!-- ============================================================= -->
<!-- SYSTEM:     Darwin Information Typing Architecture (DITA)     -->
<!--                                                               -->
<!-- PURPOSE:    Declaring the elements and specialization         -->
<!--             attributes for Learning Plan                      -->
<!--                                                               -->
<!-- ORIGINAL CREATION DATE:                                       -->
<!--             May 2007                                          -->
<!--                                                               -->
<!--             (C) Copyright OASIS Open 2007, 2009.              -->
<!--             All Rights Reserved.                              -->
<!-- ============================================================= -->


<!-- ============================================================= -->
<!--                   SPECIALIZATION OF DECLARED ELEMENTS         -->
<!-- ============================================================= -->

<!ENTITY % learningPlan "learningPlan">
<!ENTITY % learningPlanbody "learningPlanbody">

<!-- section -->
<!ENTITY % lcProject "lcProject">
<!ENTITY % lcNeedsAnalysis "lcNeedsAnalysis">
<!ENTITY % lcGapAnalysis "lcGapAnalysis">
<!ENTITY % lcIntervention "lcIntervention">
<!ENTITY % lcTechnical "lcTechnical">

<!-- fig -->
<!ENTITY % lcClient "lcClient">
<!ENTITY % lcPlanTitle "lcPlanTitle">
<!ENTITY % lcCIN "lcCIN">
<!ENTITY % lcModDate "lcModDate">
<!ENTITY % lcDelivDate "lcDelivDate">
<!ENTITY % lcPlanSubject "lcPlanSubject">
<!ENTITY % lcPlanDescrip "lcPlanDescrip">
<!ENTITY % lcPlanPrereqs "lcPlanPrereqs">

<!ENTITY % lcOrganizational "lcOrganizational">
<!ENTITY % lcPlanAudience "lcPlanAudience">
<!ENTITY % lcWorkEnv "lcWorkEnv">
<!ENTITY % lcTask "lcTask">

<!ENTITY % lcGapItem "lcGapItem">
<!ENTITY % lcInterventionItem "lcInterventionItem">
<!ENTITY % lcLMS "lcLMS">
<!ENTITY % lcNoLMS "lcNoLMS">
<!ENTITY % lcHandouts "lcHandouts">
<!ENTITY % lcClassroom "lcClassroom">
<!ENTITY % lcOJT "lcOJT">
<!ENTITY % lcConstraints "lcConstraints">
<!ENTITY % lcW3C "lcW3C">
<!ENTITY % lcPlayers "lcPlayers">
<!ENTITY % lcGraphics "lcGraphics">
<!ENTITY % lcViewers "lcViewers">
<!ENTITY % lcResolution "lcResolution">
<!ENTITY % lcFileSizeLimitations "lcFileSizeLimitations">
<!ENTITY % lcDownloadTime "lcDownloadTime">
<!ENTITY % lcSecurity "lcSecurity">

<!-- p -->
<!ENTITY % lcGeneralDescription "lcGeneralDescription">
<!ENTITY % lcGoals "lcGoals">
<!ENTITY % lcNeeds "lcNeeds">
<!ENTITY % lcValues "lcValues">
<!ENTITY % lcOrgConstraints "lcOrgConstraints">
<!ENTITY % lcEdLevel "lcEdLevel">
<!ENTITY % lcAge "lcAge">
<!ENTITY % lcBackground "lcBackground">
<!ENTITY % lcSkills "lcSkills">
<!ENTITY % lcKnowledge "lcKnowledge">
<!ENTITY % lcMotivation "lcMotivation">
<!ENTITY % lcSpecChars "lcSpecChars">
<!ENTITY % lcWorkEnvDescription "lcWorkEnvDescription">
<!ENTITY % lcPlanResources "lcPlanResources">
<!ENTITY % lcProcesses "lcProcesses">
<!ENTITY % lcTaskItem "lcTaskItem">
<!ENTITY % lcAttitude "lcAttitude">
<!ENTITY % lcJtaItem "lcJtaItem">
<!ENTITY % lcGapItemDelta "lcGapItemDelta">
<!ENTITY % lcLearnStrat "lcLearnStrat">
<!ENTITY % lcPlanObjective "lcPlanObjective">
<!ENTITY % lcAssessment "lcAssessment">
<!ENTITY % lcDelivery "lcDelivery">

<!-- declare the structure and content models -->

<!-- declare the class derivations -->

<!ENTITY % learningPlan-info-types "no-topic-nesting">
<!ENTITY included-domains     "" >

<!ENTITY % learningPlan.content
                       "((%title;),
                         (%titlealts;)?,
                         (%shortdesc; | 
                          %abstract;)?,
                         (%prolog;)?, 
                         (%learningPlanbody;), 
                         (%related-links;)?, 
                         (%learningPlan-info-types;)* )"
>
<!ENTITY % learningPlan.attributes
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
<!--doc:A Learning Plan topic describes learning needs and goals, instructional design models, task analyses, learning taxonomies, and other information necessary to the lesson planning process.-->
<!ELEMENT learningPlan    %learningPlan.content;>
<!ATTLIST learningPlan    
              %learningPlan.attributes;
              %arch-atts;
              domains CDATA "&included-domains;"    >



<!ENTITY % learningPlanbody.content
                       "((%lcProject;)?,
                         (%lcNeedsAnalysis;)?,
                         (%lcGapAnalysis;)?,
                         (%lcIntervention;)?,
                         (%lcTechnical;)?,
                         (%section;)*)"
>
<!ENTITY % learningPlanbody.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <learningPlanbody> element is the main body-level element in a learningPlan topic.-->
<!ELEMENT learningPlanbody    %learningPlanbody.content;>
<!ATTLIST learningPlanbody    %learningPlanbody.attributes;>


<!-- section -->
<!ENTITY % lcProject.content
                       "((%title;)?,
                         (%lcClient;)?,
                         (%lcPlanTitle;)?,
                         (%lcCIN;)?,
                         (%lcModDate;)?,
                         (%lcDelivDate;)?,
                         (%lcPlanSubject;)?,
                         (%lcPlanDescrip;)?,
                         (%lcPlanPrereqs;)?)"
>
<!ENTITY % lcProject.attributes
             "%univ-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcProject> provides learning content project plan description information.-->
<!ELEMENT lcProject    %lcProject.content;>
<!ATTLIST lcProject    %lcProject.attributes;>


<!-- fig in lcProject -->
<!ENTITY % lcClient.content
                       "((%title;)?,
                         (%fig.cnt;)* )"
>
<!ENTITY % lcClient.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED">
<!--doc:The <lcClient> provides the person or organization sponsoring or requiring the learning event development.-->
<!ELEMENT lcClient    %lcClient.content;>
<!ATTLIST lcClient    %lcClient.attributes;>



<!ENTITY % lcPlanTitle.content
                       "((%title;)?,
                         (%fig.cnt;)* )"
>
<!ENTITY % lcPlanTitle.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED "
>
<!--doc:The <lcPlanTitle> provides a title for this plan.-->
<!ELEMENT lcPlanTitle    %lcPlanTitle.content;>
<!ATTLIST lcPlanTitle    %lcPlanTitle.attributes;>


<!ENTITY % lcCIN.content
                       "((%title;)?,
                         (%fig.cnt;)* )"
>
<!ENTITY % lcCIN.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED">
<!--doc:The <lcCIN> provides an alternate identifier for the project title.-->
<!ELEMENT lcCIN    %lcCIN.content;>
<!ATTLIST lcCIN    %lcCIN.attributes;>


<!ENTITY % lcModDate.content
                       "((%title;)?, 
                         (%fig.cnt;)* )"
>
<!ENTITY % lcModDate.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED">
<!--doc:The <lcModDate> provides the project modification date.-->
<!ELEMENT lcModDate    %lcModDate.content;>
<!ATTLIST lcModDate    %lcModDate.attributes;>


<!ENTITY % lcDelivDate.content
                       "((%title;)?,
                         (%fig.cnt;)* )"
>
<!ENTITY % lcDelivDate.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED "
>
<!--doc:The <lcDelivDate> provides the project delivery date.-->
<!ELEMENT lcDelivDate    %lcDelivDate.content;>
<!ATTLIST lcDelivDate    %lcDelivDate.attributes;>


<!ENTITY % lcPlanSubject.content
                       "((%title;)?,
                         (%fig.cnt;)* )"
>
<!ENTITY % lcPlanSubject.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED">
<!--doc:The <lcPlanSubject> provides a complete description of the subject of the planned learning.-->
<!ELEMENT lcPlanSubject    %lcPlanSubject.content;>
<!ATTLIST lcPlanSubject    %lcPlanSubject.attributes;>


<!ENTITY % lcPlanDescrip.content
                       "((%title;)?, 
                         (%fig.cnt;)* )"
>
<!ENTITY % lcPlanDescrip.attributes
             "%display-atts;
              spectitle
                        CDATA
                                   #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                   #IMPLIED "
>
<!--doc:The <lcPlanDescrip> provides a plan description.-->
<!ELEMENT lcPlanDescrip    %lcPlanDescrip.content;>
<!ATTLIST lcPlanDescrip    %lcPlanDescrip.attributes;>


<!ENTITY % lcPlanPrereqs.content
                       "((%title;)?, 
                         (%fig.cnt;)* )"
>
<!ENTITY % lcPlanPrereqs.attributes
             "%display-atts;
              spectitle
                        CDATA
                                   #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                   #IMPLIED"
>
<!--doc:<lcPlanPrereqs> provides the knowledge, skills, abilities, courses and other activities learners must have satisfied to take the instruction.-->
<!ELEMENT lcPlanPrereqs    %lcPlanPrereqs.content;>
<!ATTLIST lcPlanPrereqs    %lcPlanPrereqs.attributes;>


<!-- section -->
<!ENTITY % lcNeedsAnalysis.content
                       "((%title;)?,
                         (%lcOrganizational;)?,
                         (%lcPlanAudience;)?,
                         (%lcWorkEnv;)?,
                         (%lcTask;)*)"
>
<!ENTITY % lcNeedsAnalysis.attributes
             "%univ-atts;
              spectitle  
                        CDATA
                                  #IMPLIED
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcNeedsAnalysis> describes the training requirement and identifies the need to develop or revise content. These include periodic training gap analyses, changes to operational or maintenance requirements, and changes to equipment or systems.-->
<!ELEMENT lcNeedsAnalysis    %lcNeedsAnalysis.content;>
<!ATTLIST lcNeedsAnalysis    %lcNeedsAnalysis.attributes;>

<!-- fig in lcNeedsAnalysis-->
<!ENTITY % lcOrganizational.content
                       "((%title;)?, 
                         (%lcGeneralDescription;)?,
                         (%lcGoals;)?,
                         (%lcNeeds;)?,
                         (%lcValues;)?,
                         (%lcOrgConstraints;)?)"
>
<!ENTITY % lcOrganizational.attributes
             "%display-atts;
               spectitle
                        CDATA
                                   #IMPLIED
               %univ-atts;
               outputclass
                        CDATA
                                   #IMPLIED"
>
<!--doc:The <lcOrganizational> describes an organization's learning requirements.-->
<!ELEMENT lcOrganizational    %lcOrganizational.content;>
<!ATTLIST lcOrganizational    %lcOrganizational.attributes;>

<!ENTITY % lcGeneralDescription.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcGeneralDescription.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcGeneralDescription> provides a space to develop a general description about the organization's training needs.-->
<!ELEMENT lcGeneralDescription    %lcGeneralDescription.content;>
<!ATTLIST lcGeneralDescription    %lcGeneralDescription.attributes;>

<!ENTITY % lcGoals.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcGoals.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcGoals> provides the outcomes desired by the organization to be addressed by the training effort. These goals may require concurrent efforts outside of training such as technology acquisition, reorganization, and so forth.-->
<!ELEMENT lcGoals    %lcGoals.content;>
<!ATTLIST lcGoals    %lcGoals.attributes;>

<!ENTITY % lcNeeds.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcNeeds.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcNeeds> provides the needs behind the outcomes described by the <lcGoals>.-->
<!ELEMENT lcNeeds    %lcNeeds.content;>
<!ATTLIST lcNeeds    %lcNeeds.attributes;>

<!ENTITY % lcValues.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcValues.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcValues> describes affective components of desired instructional outcomes.-->
<!ELEMENT lcValues    %lcValues.content;>
<!ATTLIST lcValues    %lcValues.attributes;>

<!ENTITY % lcOrgConstraints.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcOrgConstraints.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcOrgConstraints> provides organizational aspects that may limit the organization's ability to effectively use the instruction to meet its goals.-->
<!ELEMENT lcOrgConstraints    %lcOrgConstraints.content;>
<!ATTLIST lcOrgConstraints    %lcOrgConstraints.attributes;>


<!ENTITY % lcPlanAudience.content
                       "((%title;)?,
                         (%lcGeneralDescription;)?,
                         (%lcEdLevel;)?,
                         (%lcAge;)?,
                         (%lcBackground;)?,
                         (%lcSkills;)?,
                         (%lcKnowledge;)?,
                         (%lcMotivation;)?,
                         (%lcSpecChars;)?)"
>
<!ENTITY % lcPlanAudience.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcPlanAudience> describes characteristics of the learners who take the instruction.-->
<!ELEMENT lcPlanAudience    %lcPlanAudience.content;>
<!ATTLIST lcPlanAudience    %lcPlanAudience.attributes;>

<!ENTITY % lcEdLevel.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcEdLevel.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcEdLevel> provides the range of learners' education level and the relevancy to the learning plan.-->
<!ELEMENT lcEdLevel    %lcEdLevel.content;>
<!ATTLIST lcEdLevel    %lcEdLevel.attributes;>

<!ENTITY % lcAge.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcAge.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcAge> provides the age range of the intended learner audience, for use by curriculum developers and course planners.-->
<!ELEMENT lcAge    %lcAge.content;>
<!ATTLIST lcAge    %lcAge.attributes;>

<!ENTITY % lcBackground.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcBackground.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcBackground> provides the learners' professional background and the relevancy to the learning plan.-->
<!ELEMENT lcBackground    %lcBackground.content;>
<!ATTLIST lcBackground    %lcBackground.attributes;>

<!ENTITY % lcSkills.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcSkills.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcSkills> describes the learners' current skill set and the relevancy to the learning plan.-->
<!ELEMENT lcSkills    %lcSkills.content;>
<!ATTLIST lcSkills    %lcSkills.attributes;>

<!ENTITY % lcKnowledge.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcKnowledge.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:<lcKnowledge> provides the learners' current knowledge of the learning topics.-->
<!ELEMENT lcKnowledge    %lcKnowledge.content;>
<!ATTLIST lcKnowledge    %lcKnowledge.attributes;>

<!ENTITY % lcMotivation.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcMotivation.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcMotivation> provides the reasons why the learners want and/or need to take the instruction.-->
<!ELEMENT lcMotivation    %lcMotivation.content;>
<!ATTLIST lcMotivation    %lcMotivation.attributes;>

<!ENTITY % lcSpecChars.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcSpecChars.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcSpecChars> provides learner characteristics specific to the population that will influence the design, including learning disabilities, physical handicaps, and so forth.-->
<!ELEMENT lcSpecChars    %lcSpecChars.content;>
<!ATTLIST lcSpecChars    %lcSpecChars.attributes;>


<!ENTITY % lcWorkEnv.content
                       "((%title;)?,
                         (%lcWorkEnvDescription;)?,
                         (%lcPlanResources;)?,
                         (%lcProcesses;)?)"
>
<!ENTITY % lcWorkEnv.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcWorkEnv> describes the working conditions and contexts in which the training will be applied.-->
<!ELEMENT lcWorkEnv    %lcWorkEnv.content;>
<!ATTLIST lcWorkEnv    %lcWorkEnv.attributes;>

<!ENTITY % lcWorkEnvDescription.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcWorkEnvDescription.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcWorkEnvDescription> provides the general working environment in which the training will be applied.-->
<!ELEMENT lcWorkEnvDescription    %lcWorkEnvDescription.content;>
<!ATTLIST lcWorkEnvDescription    %lcWorkEnvDescription.attributes;>

<!ENTITY % lcPlanResources.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcPlanResources.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcPlanResources> describes resource needs.-->
<!ELEMENT lcPlanResources    %lcPlanResources.content;>
<!ATTLIST lcPlanResources    %lcPlanResources.attributes;>

<!ENTITY % lcProcesses.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcProcesses.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcProcesses> describes processes learners routinely follow.-->
<!ELEMENT lcProcesses    %lcProcesses.content;>
<!ATTLIST lcProcesses    %lcProcesses.attributes;>


<!ENTITY % lcTask.content
                       "((%title;)?,
                         (%lcTaskItem;)*,
                         (%lcKnowledge;)?,
                         (%lcSkills;)?,
                         (%lcAttitude;)?)"
>
<!ENTITY % lcTask.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcTask> captures a work item to be performed, as part of the learning plan.-->
<!ELEMENT lcTask    %lcTask.content;>
<!ATTLIST lcTask    %lcTask.attributes;>

<!ENTITY % lcTaskItem.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcTaskItem.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcTaskItem> describes a discreet task to be taught.-->
<!ELEMENT lcTaskItem    %lcTaskItem.content;>
<!ATTLIST lcTaskItem    %lcTaskItem.attributes;>

<!ENTITY % lcAttitude.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcAttitude.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcAttitude> describes mental state that influences the choices of personal actions.-->
<!ELEMENT lcAttitude    %lcAttitude.content;>
<!ATTLIST lcAttitude    %lcAttitude.attributes;>


<!-- section -->
<!ENTITY % lcGapAnalysis.content
                       "((%title;)?,
                         (%lcGapItem;)*)"
>
<!ENTITY % lcGapAnalysis.attributes
             "%univ-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcGapAnalysis> compares existing learning objectives to current job task analysis.-->
<!ELEMENT lcGapAnalysis    %lcGapAnalysis.content;>
<!ATTLIST lcGapAnalysis    %lcGapAnalysis.attributes;>

<!-- fig in lcGapAnalysis-->
<!ENTITY % lcGapItem.content
                       "((%title;)?,
                         (%lcPlanObjective;)?,
                         (%lcJtaItem;)?,
                         (%lcGapItemDelta;)?)"
>
<!ENTITY % lcGapItem.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcGapItem> describes gaps between existing training objectives and related job-task-analysis content.-->
<!ELEMENT lcGapItem    %lcGapItem.content;>
<!ATTLIST lcGapItem    %lcGapItem.attributes;>

<!ENTITY % lcPlanObjective.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcPlanObjective.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcPlanObjective> describes the objective to be addressed by a gap analysis or intervention.-->
<!ELEMENT lcPlanObjective    %lcPlanObjective.content;>
<!ATTLIST lcPlanObjective    %lcPlanObjective.attributes;>

<!ENTITY % lcJtaItem.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcJtaItem.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcJtaItem> provides description of job task analysis (JTA) as related to a particular learning objective.-->
<!ELEMENT lcJtaItem    %lcJtaItem.content;>
<!ATTLIST lcJtaItem    %lcJtaItem.attributes;>

<!ENTITY % lcGapItemDelta.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcGapItemDelta.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcGapItemDelta> describes the gap between the learning objective and the task analysis.-->
<!ELEMENT lcGapItemDelta    %lcGapItemDelta.content;>
<!ATTLIST lcGapItemDelta    %lcGapItemDelta.attributes;>


<!-- section -->
<!ENTITY % lcIntervention.content
                       "((%title;)?,
                         (%lcInterventionItem;)*)"
>
<!ENTITY % lcIntervention.attributes
             "%univ-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              outputclass
                        CDATA
                                  #IMPLIED "
>
<!--doc:The <lcIntervention> describes the approach and strategies to building the learning materials, based on the needs analysis.-->
<!ELEMENT lcIntervention    %lcIntervention.content;>
<!ATTLIST lcIntervention    %lcIntervention.attributes;>

<!-- fig in lcIntervention-->
<!ENTITY % lcInterventionItem.content
                       "((%title;)?,
                         (%lcLearnStrat;)?,
                         (%lcPlanObjective;)?,
                         (%lcAssessment;)?,
                         (%lcDelivery;)?)"
>
<!ENTITY % lcInterventionItem.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcInterventionItem> describes how learning content is built, based on a systems approach to analyzing, designing, developing, implementing, and evaluating any instructional experience.-->
<!ELEMENT lcInterventionItem    %lcInterventionItem.content;>
<!ATTLIST lcInterventionItem    %lcInterventionItem.attributes;>

<!ENTITY % lcLearnStrat.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcLearnStrat.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcLearnStrat> describes the manner in which the learning content will be instructed. This should be a high level design that applies instructional-design theories and models.-->
<!ELEMENT lcLearnStrat    %lcLearnStrat.content;>
<!ATTLIST lcLearnStrat    %lcLearnStrat.attributes;>

<!ENTITY % lcAssessment.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcAssessment.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcAssessment> describes assessment plans.-->
<!ELEMENT lcAssessment    %lcAssessment.content;>
<!ATTLIST lcAssessment    %lcAssessment.attributes;>

<!ENTITY % lcDelivery.content
                       "(%para.cnt;)*"
>
<!ENTITY % lcDelivery.attributes
             "%univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcDelivery> describes the delivery method for this learning content.-->
<!ELEMENT lcDelivery    %lcDelivery.content;>
<!ATTLIST lcDelivery    %lcDelivery.attributes;>


<!-- section -->
<!ENTITY % lcTechnical.content
                       "((%title;)?,
                         (%lcLMS;)?,
                         (%lcNoLMS;)?,
                         (%lcHandouts;)?,
                         (%lcClassroom;)?,
                         (%lcOJT;)?,
                         (%lcConstraints;)?,
                         (%lcW3C;)?,
                         (%lcPlayers;)?,
                         (%lcGraphics;)?,
                         (%lcViewers;)?,
                         (%lcResolution;)?,
                         (%lcFileSizeLimitations;)?,
                         (%lcDownloadTime;)?,
                         (%lcSecurity;)?)">
<!ENTITY % lcTechnical.attributes
             "%univ-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcTechnical> describes the technical requirements to the learning content and how those requirements are supported by the instructional design.-->
<!ELEMENT lcTechnical    %lcTechnical.content;>
<!ATTLIST lcTechnical    %lcTechnical.attributes;>

<!-- fig in lcTechnical-->
<!ENTITY % lcLMS.content
                       "((%title;)?,
                         (%fig.cnt;)* )"
>
<!ENTITY % lcLMS.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcLMS> provides the LMS name and version number used in the learning event.-->
<!ELEMENT lcLMS    %lcLMS.content;>
<!ATTLIST lcLMS    %lcLMS.attributes;>

<!ENTITY % lcNoLMS.content
                       "((%title;)?,
                         (%fig.cnt;)* )"
>
<!ENTITY % lcNoLMS.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:Use <lcNoLMS> when you plan to deliver the content as a standalone package, without a learning management system (LMS).-->
<!ELEMENT lcNoLMS    %lcNoLMS.content;>
<!ATTLIST lcNoLMS    %lcNoLMS.attributes;>

<!ENTITY % lcHandouts.content
                       "((%title;)?,
                         (%fig.cnt;)* )"
>
<!ENTITY % lcHandouts.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcHandouts> provides aspects of the course that are provided by the instructor in support of the course learning objectives.-->
<!ELEMENT lcHandouts    %lcHandouts.content;>
<!ATTLIST lcHandouts    %lcHandouts.attributes;>

<!ENTITY % lcClassroom.content
                       "((%title;)?, 
                         (%fig.cnt;)* )"
>
<!ENTITY % lcClassroom.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcClassroom> describes the classroom environment.-->
<!ELEMENT lcClassroom    %lcClassroom.content;>
<!ATTLIST lcClassroom    %lcClassroom.attributes;>

<!ENTITY % lcOJT.content
                       "((%title;)?,
                         (%fig.cnt;)* )"
>
<!ENTITY % lcOJT.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcOJT> is "the job training" and describes aspects of the course taking place in the work environment.-->
<!ELEMENT lcOJT    %lcOJT.content;>
<!ATTLIST lcOJT    %lcOJT.attributes;>

<!ENTITY % lcConstraints.content
                       "((%title;)?,
                         (%fig.cnt;)* )"
>
<!ENTITY % lcConstraints.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcConstraints> describes the organizational or technical aspects that may limit the organization's ability to effectively use the instruction to meet its goals.-->
<!ELEMENT lcConstraints    %lcConstraints.content;>
<!ATTLIST lcConstraints    %lcConstraints.attributes;>

<!ENTITY % lcW3C.content
                       "((%title;)?,
                         (%fig.cnt;)* )"
>
<!ENTITY % lcW3C.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcW3C> provides requirements for use of world wide web consortium standards.-->
<!ELEMENT lcW3C    %lcW3C.content;>
<!ATTLIST lcW3C    %lcW3C.attributes;>

<!ENTITY % lcPlayers.content
                       "((%title;)?,
                         (%fig.cnt;)* )"
>
<!ENTITY % lcPlayers.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcPlayers> describes tools and plugins used for time-sequenced display at runtime.-->
<!ELEMENT lcPlayers    %lcPlayers.content;>
<!ATTLIST lcPlayers    %lcPlayers.attributes;>

<!ENTITY % lcGraphics.content
                       "((%title;)?,
                         (%fig.cnt;)* )"
>
<!ENTITY % lcGraphics.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcGraphics> describes standards and system requirements for displaying graphics and other related content types.-->
<!ELEMENT lcGraphics    %lcGraphics.content;>
<!ATTLIST lcGraphics    %lcGraphics.attributes;>

<!ENTITY % lcViewers.content
                       "((%title;)?,
                         (%fig.cnt;)* )"
>
<!ENTITY % lcViewers.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcViewers> describes viewers used for time-sequenced display at runtime.-->
<!ELEMENT lcViewers    %lcViewers.content;>
<!ATTLIST lcViewers    %lcViewers.attributes;>

<!ENTITY % lcResolution.content
                       "((%title;)?, 
                         (%fig.cnt;)* )"
>
<!ENTITY % lcResolution.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcResolution> describes the required computer screen resolution for the online instruction.-->
<!ELEMENT lcResolution    %lcResolution.content;>
<!ATTLIST lcResolution    %lcResolution.attributes;>

<!ENTITY % lcFileSizeLimitations.content
                       "((%title;)?, 
                         (%fig.cnt;)* )"
>
<!ENTITY % lcFileSizeLimitations.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcFileSizeLimitations> describes any file size limitation in the download environment.-->
<!ELEMENT lcFileSizeLimitations    %lcFileSizeLimitations.content;>
<!ATTLIST lcFileSizeLimitations    %lcFileSizeLimitations.attributes;>

<!ENTITY % lcDownloadTime.content
                       "((%title;)?,
                         (%fig.cnt;)* )"
>
<!ENTITY % lcDownloadTime.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED"
>
<!--doc:The <lcDownloadTime> describes the maximum time allowed for download time in the client's delivery environment.-->
<!ELEMENT lcDownloadTime    %lcDownloadTime.content;>
<!ATTLIST lcDownloadTime    %lcDownloadTime.attributes;>

<!ENTITY % lcSecurity.content
                       "((%title;)?, 
                         (%fig.cnt;)* )"
>
<!ENTITY % lcSecurity.attributes
             "%display-atts;
              spectitle
                        CDATA
                                  #IMPLIED
              %univ-atts;
              outputclass
                        CDATA
                                  #IMPLIED">
<!--doc:The <lcSecurity> describes the security requirements in the delivered instruction.-->
<!ELEMENT lcSecurity    %lcSecurity.content;>
<!ATTLIST lcSecurity    %lcSecurity.attributes;>


<!--specialization attributes-->
<!ATTLIST learningPlan        %global-atts; class CDATA "- topic/topic learningBase/learningBase learningPlan/learningPlan ">
<!ATTLIST learningPlanbody    %global-atts; class CDATA "- topic/body  learningBase/learningBasebody learningPlan/learningPlanbody ">
<!ATTLIST lcProject    %global-atts; class CDATA "- topic/section  learningBase/section learningPlan/lcProject ">
<!ATTLIST lcNeedsAnalysis    %global-atts; class CDATA "- topic/section  learningBase/section learningPlan/lcNeedsAnalysis ">
<!ATTLIST lcGapAnalysis    %global-atts; class CDATA "- topic/section  learningBase/section learningPlan/lcGapAnalysis ">
<!ATTLIST lcIntervention    %global-atts; class CDATA "- topic/section  learningBase/section learningPlan/lcIntervention ">
<!ATTLIST lcTechnical    %global-atts; class CDATA "- topic/section  learningBase/section learningPlan/lcTechnical ">

<!ATTLIST lcClient  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcClient ">
<!ATTLIST lcPlanTitle  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcPlanTitle ">
<!ATTLIST lcCIN  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcCIN ">
<!ATTLIST lcModDate  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcModDate ">
<!ATTLIST lcDelivDate  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcDelivDate ">
<!ATTLIST lcPlanSubject  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcPlanSubject ">
<!ATTLIST lcPlanDescrip  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcPlanDescrip ">
<!ATTLIST lcPlanPrereqs  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcPlanPrereqs ">

<!ATTLIST lcOrganizational  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcOrganizational ">
<!ATTLIST lcGoals  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcGoals ">
<!ATTLIST lcNeeds  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcNeeds ">
<!ATTLIST lcValues  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcValues ">
<!ATTLIST lcOrgConstraints  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcOrgConstraints ">
<!ATTLIST lcPlanAudience  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcPlanAudience ">
<!ATTLIST lcGeneralDescription  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcGeneralDescription ">
<!ATTLIST lcEdLevel  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcEdLevel ">
<!ATTLIST lcAge  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcAge ">
<!ATTLIST lcBackground  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcBackground ">
<!ATTLIST lcSkills  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcSkills ">
<!ATTLIST lcKnowledge  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcKnowledge ">
<!ATTLIST lcMotivation  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcMotivation ">
<!ATTLIST lcSpecChars  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcSpecChars ">
<!ATTLIST lcWorkEnv  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcWorkEnv ">
<!ATTLIST lcWorkEnvDescription  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcWorkEnvDescription ">
<!ATTLIST lcPlanResources  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcPlanResources ">
<!ATTLIST lcProcesses  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcProcesses ">
<!ATTLIST lcTask  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcTask ">
<!ATTLIST lcTaskItem  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcTaskItem ">
<!ATTLIST lcAttitude  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcAttitude ">

<!ATTLIST lcGapItem  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcGapItem ">
<!ATTLIST lcPlanObjective  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcPlanObjective ">
<!ATTLIST lcJtaItem  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcJtaItem ">
<!ATTLIST lcGapItemDelta  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcGapItemDelta ">

<!ATTLIST lcInterventionItem  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcInterventionItem ">
<!ATTLIST lcLearnStrat  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcLearnStrat ">
<!ATTLIST lcAssessment  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcAssessment ">
<!ATTLIST lcDelivery  %global-atts; class CDATA "- topic/p  learningBase/p learningPlan/lcDelivery ">

<!ATTLIST lcLMS  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcLMS ">
<!ATTLIST lcNoLMS  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcNoLMS ">
<!ATTLIST lcHandouts  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcHandouts ">
<!ATTLIST lcClassroom  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcClassroom ">
<!ATTLIST lcOJT  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcOJT ">
<!ATTLIST lcConstraints  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcConstraints ">
<!ATTLIST lcW3C  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcW3C ">
<!ATTLIST lcPlayers  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcPlayers ">
<!ATTLIST lcGraphics  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcGraphics ">
<!ATTLIST lcViewers  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcViewers ">
<!ATTLIST lcResolution  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcResolution ">
<!ATTLIST lcFileSizeLimitations  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcFileSizeLimitations ">
<!ATTLIST lcDownloadTime  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcDownloadTime ">
<!ATTLIST lcSecurity  %global-atts; class CDATA "- topic/fig  learningBase/fig learningPlan/lcSecurity ">
