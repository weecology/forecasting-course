title: "Ecological Dynamics and Forecasting: A semester long course introducing fundamentals of time series and forecasting in ecology"
tags:
  - biology
  - forecasting
  - ecological dynamics
  - time series
  - programming
  - models
  - uncertainty
authors:
  - name: S. K. Morgan Ernest
    orcid: 0000-0002-6026-8530
    affiliation: "1, 2"
  - name: Hao Ye
    orcid:
    affiliation: "1,4"
  - name: Ethan P. White
    orcid: 0000-0001-6728-7745
    affiliation: "1, 2, 3"
affiliations:
 - name: Department of Wildlife Ecology and Conservation, University of Florida
   index: 1
 - name: Biodiversity Institute, University of Florida
   index: 2
 - name: Informatics Institute, University of Florida
   index: 3
 - name: 
   index: 4

date: 7 November 2022
bibliography: paper.bib
---

# Summary

Ecological Dynamics and Forecasting is a semester-long course to introduce students to the fundamentals of ecological dynamics and forecasting. This course implements a combination of paper-based discussion to introduce students to concepts and ideas and R-based tutorials for hands-on application and training. The course material includes a reading list with prompting questions for discussions, teachers notes for guiding discussions, lecture notes for live coding demonstrations, and video presentations of all R tutorials. The course is structured around two sessions per week - with most weeks consisting of a one hour paper discussion session and a 1-2 hour session focused on applications in R. R tutorials use publicly available ecological datasets to provide realistic applications. This course material can be used either as self-directed learning or as all or part of a college or university course. Individual learners have access to all of the necessary material - including discussion questions and instructor notes - on the website. The course does currently assume users have access to some closed-access papers, though open-access versions and links are provided when available and suitable open-access papers are recommended. Because the material is organized around content themes, university courses can modify and remix materials based on their course goals and student levels of background knowledge. Course videos have been viewed by thousands of users and course materials has been taught for several years at the authors' university. 

# Statement of Need

Ecological forecasting is an emerging field that attempts to project the current state of nature into uncertain futures. This approach to understanding and modeling nature benefits from traditional ecological approaches assessing processes by modeling known outcomes from short-term experiments or historical data, but also involves unique tools, methods, and ways of thinking [@houlahan2017; @dietze2018; @white2019]. Many ecologists lack fundamental exposure to core concepts necessary for engaging in forecasting [@brewer2003; @dietze2018] including: 1) understanding of ecological dynamics [@wolkovich2013]; the iterative cycle of model fitting, evaluation, and improvement [@dietze2018]; and 3) assessing and communicating uncertainty in forecasts [@bewer2003]. Building a community of practice around ecological forecasting require courses that provide students with foundational conceptual knowledge relevant to ecology and active training in methodologies and approaches [@dietze2018]. However, ecological forecasting is still a small field with a small number of practitioners relative to the educational need, creating a potential educational bottleneck. The 'Ecological Dynamics and Forecasting' course is designed to provide training in the fundamentals of ecological forecasting that will allow students to engage critically with the field and provide tools for students to deploy as they develop as forecasters. These materials can be used by instructors as modifiable core materials for their own courses or by individual students as an independent self-guided course.

# Features

## General instructional design

The course combines two key components for developing a community of practice around ecological forecasting: 1) learning and engaging with the background and current state of knowledge in the field; and 2) developing the quantitative tool set for using dynamic data to make and evaluate forecasts. A standard week in the course starts with discussing a paper on the core topic being covered and ends with an R tutorial on a related subject.

For discussion sessions students read a paper in advance and are given a list of discussion questions to help them focus on key aspects of the paper and prepare for group discussions. The instructors then lead a group discussion on the paper, guiding the students through the discussion questions and integrating mini-lectures where appropriate to address common points of confusion about the paper (e.g., walking through a complicated modeling approach). These discussions often involve having the students think about how the material being learned applies to questions or systems they are familiar with. Based on Constructivism and other learning theories this step of integrating the material with their existing knowledge this step will help support student learning [@bada2015].

In the second session of the week a live-coding based R tutorial is presented on a topic related to the paper discussion. The R tutorials are designed to build from zero knowledge of time-series and forecasting in R. They follow a general progression of:

1. Loading and manipulating time-series data
2. Understanding patterns in time-series
3. Basic time-series modeling
4. Using time-series models to make and evaluate forecasts
5. Ecological forecasting methods (including species-distribution modeling and Bayesian state space modeling)

R tutorials follow explicit instruction principles, which combine active-learning with a gradual on ramp for students [@rosenshine1987; @archer2010]. This approach has been described as "a systematic method of teaching with emphasis on proceeding in small steps, checking for student understanding, and achieving active and successful participation by all students" [@rosenshine1987 p.34]. We have found it useful for teaching computational skills to researchers because it allows gradually developing comfort with quantitative material that can be intimidating to some students [@white2022]. The tutorials accomplish this by first demonstrating a new approach using live-coding, then having the students complete an exercise performing that approach on a different dataset in class, and then discussing this exercise as a group before proceeding to the next new concept.

## Self-guided online learning

All of the course materials are available online at <https://course.naturecast.org>. This includes links to papers, discussion questions, instructor notes for guiding discussions, and both written and video versions of R tutorials and associated student exercises. The R tutorials are also available as a [YouTube playlist](https://www.youtube.com/watch?v=Zr81Xn-sic4&list=PLD8eCxFKntVETvfPd-diUORGYLAL6idBv). To mirror the explicit instruction approach used during in-person R tutorials video-based lessons are typically split into a series of short videos with breaks for students to conduct exercises. To support self-guided students the video lessons discuss the expected output for each exercise after it has been conducted.

In order to allow self-guided students to check to make sure they understand the exercises, the expected output for each exercise is included on the website. This allows the learner to self-evaluate and troubleshoot their solution to the exercise, while still keeping the code solutions private for use in grading in traditional classroom settings. This is also beneficial to students using this material in traditional courses because it helps remove any uncertainty about exactly what each exercise expects the learner to do.

## Basis for other college and university courses

The course is designed to be modified and remixed to meet the needs of the particular instructor and students and allow using the material broadly across college and university classrooms. This allows faculty who have enough expertise to teach an introductory R course, but who lack either the time or expertise to develop the course, to be able to teach this course at their institutions. To facilitate this, the course site has a modular design that allows modifying and remixing exercises, assignments, readings, and coding lessons, along with detailed documentation for doing so (https://datacarpentry.org/semester-biology/docs/).

Access to a separate private repository that includes the code solutions for all of the exercises is available to instructors at colleges and universities by opening an issue in the main course repository (https://github.com/datacarpentry/semester-biology/). This allows the code solutions to the exercises to be shared among instructors while still enabling the use of the exercises for summative evaluation purposes.

The course material and infrastructure is and has been used for a number of college and university courses including:

* [Data Science for Biologists](https://catherinehulshof.github.io/Fall2020-biology/) at Virginia Commonwealth University
* [Data Science for Agriculture](https://palderman.github.io/DataSciAg/) at Oklahoma State University
* [Data Visualization for Plant Pathologists](https://ufvegpathology.github.io/phyto-data-viz/) at the University of Florida
* [Data Science for SAFS](https://sr320.github.io/course-fish497-2018/) at the University of Washington
* [Data Carpentry for Pharmacists](https://ory-data-science.github.io/semester-pharmacy/) at the University of Health Sciences and Pharmacy in St. Louis 
* [R Programming for Biologists](https://www.stonehill.edu/summer-courses-2021/undergraduate-courses/bio316a/) at Stonehill College
* [Data Carpentry for Ecologists](https://mvevans89.github.io/ECOL-8030/) at the University of Georgia
* [Introduction to Data Analysis for Aquatic Sciences](https://sr320.github.io/course-fish274-2019/) at the University of Washington
* [Data Science in Omics Introduction](https://hoytpr.github.io/bioinformatics-semester/) at Oklahoma State University
* [Ecoinformatics](https://globalecologybiogeography.github.io/Ecoinformatics/) at Kenyon College
* [Data Management for Biologists](https://ericlind.github.io/data-mgmt-4-biologists/syllabus/) at the University of Minnesota
* [Introducing Agroecology: The Basics of Agroecology for Practitioners](https://trec-agroecology.github.io/introducing-agroecology/) at the University of Florida
* [Data Science with R](https://datasciencer.tychen.us/)

## Course Infrastructure

The course website is built using the [Jekyll static site generator](https://jekyllrb.com/) with a customized version of the [Lanyon theme](https://github.com/poole/lanyon). Development is conducted in the [course's GitHub repository](https://github.com/datacarpentry/semester-biology/) and the site is automatically deployed from this repository using [GitHub Pages](https://pages.github.com/).

The modular design of the course is supported by "assignments" that automatically combine "readings" and "lecture notes" on a topic with "exercises" and associated point values provided by YAML lists that indicate the exercises to include and the point values to be assigned to them. The course schedule is automatically generated based on selected assignments, also provided in a YAML list. This allows both exercises and assignments to be reused and remixed by changing the selections in YAML lists.

The online materials for the course are designed to be accessible to all learners. The site has been reviewed using the [WAVE web accessibility evaluation tool](https://wave.webaim.org/) and [pa11y](https://pa11y.org/), and all videos have been manually captioned by the instructor presenting the material. In order to ensure that accessibility is maintained as the site is continuously updated, we use [pa11y-ci](https://github.com/pa11y/pa11y-ci) and continuous integration ([GitHub Actions](https://github.com/features/actions)) to automatically scan all pull requests for accessibility.

This general infrastructure for modular, collaborative, and accessible course development is useful regardless of the content of the course. For example, one of the authors (Zachary Brym) uses the same infrastructure for  [extension programs on agroecology at the University of Florida](https://trec-agroecology.github.io/introducing-agroecology/). We hope that open courses on other topics can be built on this infrastructure to support the broader adoption of collaborative course development for college and university classrooms.

# Course Development Background

The initial development of this material and infrastructure was started in 2008 by Ethan White (with help and advice from Morgan Ernest) at Utah State University as part of an NSF CAREER award to develop a [Programming for Biologists course](http://www.programmingforbiologists.org/) to address the need for more computational training in biology. It was then converted to R and the current [Data Carpentry for Biologists](https://datacarpentry.org/semester-biology/) course structure by Zachary Brym and Ethan White for use at the University of Florida. While being taught at the University of Florida, the TA for the course, Andrew Marx, contributed substantially to improving the materials, and a number of members of White and Ernest's Weecology Research Group (including Kristina Riemer, Sergio Marconi, David Harris, and Virnaliz Cruz) contributed new material and improved existing material. Weecology is an interdisciplinary research group that conducts research at the intersection of computation, technology, and ecology, with a long history of involvement in computational training including founding, leadership, maintainer, and instructor roles within The Carpentries. The authors of this material have extensive background in both computational biology and teaching computational tools in workshop and classroom environments.

# Acknowledgements

The development of this material was supported by the University of Florida, the National Science Foundation through CAREER award 0953694 to E.P. White, and the Gordon and Betty Moore Foundation’s Data-Driven Discovery Initiative through grant GBMF4563 to E.P. White. Thanks to Tracy Teal and The Carpentries for supporting the development and Data Carpentry branding of this course and associated material. Thanks to Claire Williams for her exceptional assistance in course management at the University of Florida and Eric Hellgren for supporting the open development of the course. A huge thanks to the many students who have taken this and earlier versions of this course for their enthusiasm for the material and essential feedback that dramatically improved how the course is structured and taught.

# References