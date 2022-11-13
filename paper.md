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

Ecological forecasting is an emerging field that attempts to project the current state of nature into uncertain futures. This approach to understanding and modeling nature benefits from traditional ecological approaches assessing processes by modeling known outcomes from short-term experiments or historical data, but also involves unique tools, methods, and ways of thinking [@houlahan2017; @dietze2018; @white2019]. Many ecologists lack fundamental exposure to core concepts necessary for engaging in forecasting [@brewer2003; @dietze2018] including: 1) understanding of ecological dynamics [@wolkovich2014]; the iterative cycle of model fitting, evaluation, and improvement [@dietze2018]; and 3) assessing and communicating uncertainty in forecasts [@brewer2003]. Building a community of practice around ecological forecasting require courses that provide students with foundational conceptual knowledge relevant to ecology and active training in methodologies and approaches [@dietze2018]. However, ecological forecasting is still a small field with a small number of practitioners relative to the educational need, creating a potential educational bottleneck. The 'Ecological Dynamics and Forecasting' course is designed to provide training in the fundamentals of ecological forecasting that will allow students to engage critically with the field and provide tools for students to deploy as they develop as forecasters. These materials can be used by instructors as modifiable core materials for their own courses or by individual students as an independent self-guided course.

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

## Reuse and remixing

Both individual components of the course (e.g., individual R tutorials) and the course as a whole are designed to be reused in other classroom environments. To allow instructors to customize which material they use to suit their classroom, the course site has a modular design to allow choosing which materials to include and when. This is accomplished using changes to YAML on a single schedule page allowing other instructors to easily setup a version of the course that works for their needs and those of their students.

## Course infrastructure

The course website is built using the [Hugo static site generator](https://gohugo.io/) with a customized version of the [Wowchemy Documentation theme](https://github.com/wowchemy/hugo-documentation-theme). The website and course materials are developed in the open on the [course's GitHub repository](https://github.com/weecology/forecasting-course). The site is automatically following every change to the main branch using [Netlify](https://www.netlify.com/).

# Course Development Background

The course has been developed Morgan Ernest and Ethan White at the University of Florida to meet the need for more training in ecological forecasting. The primary development has been supported by the National Science Foundation and the Gordon and Betty Moore Foundation. Hao Ye contributed lesson material on the use of Empirical Dynamic Modeling for making ecological forecasts. The authors of this material have extensive background in long-term data [@yenni2019, @ernest2020], time-series analysis [@christensen2018, @diaz2022], ecological forecasting [@harris2018, @white2019, @simonis2021], and teaching computational tools to scientists [@hampton2017, @white2022].

# Acknowledgements

Work on this course was supported by the National Science Foundation through grant 1929730 to S.K.M. Ernest and E.P. White, the Gordon and Betty Moore Foundation’s Data-Driven Discovery Initiative through grant GBMF4563 to E.P. White, and the University of Florida. Thanks to Claire Williams and Kelley Graff for their work scheduling and managing courses at UF and to Eric Hellgren for providing us the time to make the course openly available. Also, many thanks to our students over the last 7 years for their enthusiasm in learning about ecological forecasting and openness in providing feedback that has helped us improve the course with every iteration.

# References