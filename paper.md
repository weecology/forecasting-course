---
title: "Ecological Forecasting and Dynamics: A graduate course on the fundamentals of time series and forecasting in ecology"
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
    orcid: 0000-0002-8630-1458
    affiliation: "1, 4"
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
 - name: Health Science Center Libraries, University of Florida
   index: 4
date: 4 January 2023
bibliography: paper.bib
---

# Summary

'Ecological Forecasting and Dynamics' is a semester-long course to introduce students to the fundamentals of ecological forecasting & dynamics. This course implements paper-based discussion to introduce students to concepts and ideas and R-based tutorials for hands-on application and training. The course material includes a reading list with prompting questions for discussions, teachers notes for guiding discussions, lecture notes for live coding demonstrations, and video presentations of all R tutorials. This course material can be used either as self-directed learning or as all or part of a college or university course. Individual learners have access to all of the necessary material - including discussion questions and instructor notes - on the website. The course focuses on papers with an open-access or free-to-read version where possible, though some materials still rely on access to closed-access papers. The course is structured around two sessions per week, with most weeks consisting of a one hour paper discussion session and a 1-2 hour session focused on applications in R. R tutorials use publicly available ecological datasets to provide realistic applications. Because the material is organized around content themes, instructors can modify and remix materials based on their course goals and student levels of background knowledge. These course materials have been taught for several years at the authors’ university and have also generated significant online engagement with course videos tens of thousands of times.

# Statement of Need

Ecological forecasting is an emerging field that aims to project the current state of nature into uncertain futures. This goal of understanding and modeling nature benefits from traditional ecological approaches that assess processes by modeling known outcomes from short-term experiments or historical data, but also involves unique tools, methods, and ways of thinking [@houlahan2017; @dietze2018; @white2019]. Many ecologists have limited exposure to all of the core concepts necessary to engage in forecasting [@brewer2003; @dietze2018] including: 1) understanding of ecological dynamics [@wolkovich2014]; the iterative cycle of model fitting, evaluation, and improvement [@dietze2018]; and 3) assessing and communicating uncertainty in forecasts [@brewer2003]. Building a community of practice around ecological forecasting requires courses that provide students with foundational conceptual knowledge relevant to ecology in conjunction with active training in methodologies and approaches [@dietze2018]. However, ecological forecasting is still a small field with few practitioners, creating a potential educational bottleneck. The ‘Ecological Forecasting and Dynamics’ course provides training in the fundamentals of ecological forecasting that will allow students to engage critically with the field and provide tools for students to deploy as they develop as forecasters. These materials can be used by instructors as modifiable core materials for their own courses or by individual students as an independent self-guided course.

# Audience

The material is designed to be accessible to graduate students and advanced undergraduates. It assumes a basic ability to read and engage with the primary scientific literature, but provides guidance for engaging with each paper to help students who are learning how to do this. It assumes a basic understanding of R, including loading tabular data, working with variables, loading packages, and running functions. Some experience with `dplyr` and `ggplot2` is also helpful.

The discussion material is primarily designed to be used in a classroom environment centered on group discussion, but guidance is also provided for self-guided learners on how to engage with the material. The R tutorials are designed to work both as a live coding lecture in a classroom and as follow-along exercises for self-guided learners.

Examples of folks who we are trying to help:

Maya: An advanced undergraduate in natural resources who wants to understand what ecological forecasting is and how it might be applied in conservation and management. Maya has used basic R in some of their other courses and has just started reading the primary scientific literature in a classroom context.

Juniper: A graduate student with a thesis related to how populations change through time, but who doesn't yet know how to model time-series. Juniper wants to learn how to build and analyze time-series models for their thesis projects and finds the idea of forecasting interesting.

Jaylen: A professor who understands that ecological forecasting is becoming important for students to learn and wants to develop either a full course or a seminar on the topic. Jaylen understands the main concepts, but doesn't know what the best papers would be best for teaching and doesn't have the time to develop a bunch of R tutorials.

# Features

## General instructional design

The course combines two key components for developing a community of practice around ecological forecasting: 1) learning and engaging with the background and current state of knowledge in the field; and 2) developing the quantitative tool set for using time-series data to make and evaluate forecasts. A standard week in the course starts with discussing a paper on the core topic being covered and ends with an R tutorial demonstrating an application or implementation of that topic.

For discussion sessions, students read a paper in advance and are given a list of discussion questions to help them focus on key aspects of the paper and prepare for group discussions. The instructors then lead a group discussion on the paper, guiding the students through the discussion questions and integrating mini-lectures where appropriate to address common points of confusion about the paper (e.g., walking through a complicated modeling approach). A typical part of the discussion will involve the students reflecting on how the concepts apply to questions or systems they are familiar with. Based on Constructivism and other learning theories, this step of integrating the material into their existing knowledge will help students in constructing richer cognitive maps that better support retention and application [@bada2015].

In the second session of the week a live-coding R tutorial is presented on a topic related to the paper discussion. The R tutorials are designed to build from zero knowledge of time-series and forecasting in R. They assume that students have a working version of R and RStudio and a small amount of experience with basic R is beneficial for fully understanding all of the steps. However, it is possible to follow and work with the tutorials with no R background. The tutorials follow a general progression of:

1. Loading time series data and performing basic data transformations
2. Decomposing a time series into long-term trends and seasonal patterns
3. Computing basic properties of time-series data to build basic models
4. Using time-series models to make and evaluate forecasts
5. Exploring further applications of models in ecological contexts (including species-distribution modeling and Bayesian state space modeling)


R tutorials follow the principles of "explicit teaching" and "scaffolding", in combining active-learning with a gradual on ramp for students [@rosenshine1987; @archer2010]. This approach has been described as “a systematic method of teaching with emphasis on proceeding in small steps, checking for student understanding, and achieving active and successful participation by all students” [@rosenshine1987 p.34]. This is useful for teaching computational skills to researchers because it allows students to gradually develop comfort with quantitative material that can be intimidating otherwise. As a result it has served as the foundation for [The Carpentries](https://carpentries.org/) general approach to teaching computational skills in workshops [@wilson2014; @teal2015] and university classes [@white2022]. The tutorials accomplish this by first demonstrating a new approach using live-coding, then having the students complete an exercise applying that approach to a different dataset in class, and then discussing this exercise as a group.

## Self-guided online learning

All of the course materials are available online at <https://course.naturecast.org>. This includes links to the reading materials (papers), discussion questions, instructor notes for guiding discussions, and both written and video versions of R tutorials and associated student exercises. The R tutorials are also available as a [YouTube playlist](https://www.youtube.com/watch?v=Zr81Xn-sic4&list=PLD8eCxFKntVETvfPd-diUORGYLAL6idBv). To mirror the scaffolding approach used during in-person R tutorials, video-based lessons are typically split into a series of short videos with natural breakpoints for students to conduct exercises. To support self-guided students the video lessons review the expected output for each exercise at the beginning of the next video (i.e. immediately after the pause wherein the student is expected to complete the exercise). The [Getting Started](https://course.naturecast.org/getting-started/) on the website introduces self-guided learners to approaches for engaging in the material in a self-guided context.

## Reuse and remixing

Individual components of the course (e.g., individual R tutorials) and the course as a whole are designed to be reused in other classroom environments. To allow instructors to customize which material they use to suit their classroom, the course website has a modular design that allows instructors to remix the lessons into a different order or to add or remove lessons as desired. This is accomplished through changes to the YAML markup in a single file in the website contents. The modular structure of the website thus allows other instructors to easily set up a version of the course that works for their needs and those of their students. The [Getting Started](https://course.naturecast.org/getting-started/) on the website introduces instructors to different approaches to using the material in their own courses.

## Course infrastructure

The course website is built using the [Hugo static site generator](https://gohugo.io/) with a customized version of the [Wowchemy Documentation theme](https://github.com/wowchemy/hugo-documentation-theme). The website and course materials are developed as open source code and open educational resources on the [course's GitHub repository](https://github.com/weecology/forecasting-course). The site is automatically rebuilt following every change to the `main` branch through the [Netlify](https://www.netlify.com/) service. Materials are available for reuse under the following licenses: CC-BY 4.0 license for written content and videos; MIT license for R tutorial code; and Apache 2.0 for website code.

# Course Development Background

The course was developed by Morgan Ernest and Ethan White at the University of Florida to meet the need for more training in ecological forecasting. The primary development has been supported by the National Science Foundation and the Gordon and Betty Moore Foundation. Hao Ye contributed lesson material on the use of Empirical Dynamic Modeling for making ecological forecasts. The authors of this material have extensive background in long-term data [@yenni2019; @ernest2020], time-series analysis [@christensen2018; @diaz2022], ecological forecasting [@harris2018; @white2019; @simonis2021], and teaching computational tools to scientists [@hampton2017; @white2022].

# Acknowledgements

Work on this course was supported by the National Science Foundation through grant 1929730 to S.K.M. Ernest and E.P. White, the Gordon and Betty Moore Foundation’s Data-Driven Discovery Initiative through grant GBMF4563 to E.P. White, and the University of Florida. Thanks to Claire Williams and Kelley Graff for their work scheduling and managing courses at UF and to Eric Hellgren for providing us the time to make the course openly available. Also, many thanks to our students over the last 7 years for their enthusiasm in learning about ecological forecasting and openness in providing feedback that has helped us improve the course with every iteration.

# References
