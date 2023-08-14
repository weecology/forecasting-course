---
title: "Getting Started"
weight: 26
---

{{< toc >}}

## Self-Guided Learning About Ecological Forecasting & Dynamics

There are two primary sets of information on this site:
1. The background and conceptual foundation for ecological forecasting and dynamics, which focuses on reading and engaging with the primary scientific literature.
2. The computational tools for working with, modeling, and making forecasts from (mostly time-series) data.

The original design of this course material is that two sets of information are taught in the integrated manner shown on the [Schedule page](../schedule).
Where possible the conceptual material is paired with related material in R.

While taking a self-guided approach to the material you can either follow this general approach by following the order of the [Schedule page](../schedule) or choose to focus on either of the components in isolation.

### Self-Guided Learning - Conceptual Material

For the background and conceptual material we recommend that self-guided learners first read the Discussion Questions page for the lesson to get an idea of what they should be learning from the paper.
Then read the paper itself, trying to develop your own answers to the Discussion Questions.
Finally read through the Instructors Notes page for the lesson to see what we thought were the key take homes from the paper.
Don't worry if you didn't get all of them yourself, that's part of the learning process.

### Self-Guided Learning - R Material

The R material is generally sequential with most lessons building on previous lessons.
As such we recommend following the R material in the order present on the [Schedule page](../schedule).

To start an R lesson go the the Material page for the lesson to find any data or packages you will need for the tutorial. 
The R material is available in two formats - written notes and video.
We recommend choosing the format you prefer and following along with the tutorial by typing and running the code yourself each step of the way.
There are also periodic stopping points to allow learners to practice the material on their own.
We recommend stopping at these points, trying the exercise, and then proceeding to see if your approach matches those present in the notes and videos.
Once you've finished the tutorial it can be useful to practice the approaches learned on your own data or another similar dataset.

## Teaching Ecological Forecasting & Dynamics

All of the code, lesson content, data, and infrastructure for this site is openly licensed so you can use any of it in your own courses.

Lesson material can be accessed from this website or using the raw markdown files in the associated [GitHub repository](https://github.com/weecology/forecasting-course).
The core lesson material is stored in the [`content/lessons` directory](https://github.com/weecology/forecasting-course/tree/main/content/lessons) of the GitHub repository and each lesson is stored in it's own named subdirectory. 

There are three general approaches to using the material in teaching:

1. Use the existing website by linking to one or more lessons from your course site and reading the associated instructors material
2. Copy material from either the website or this GitHub repository and place it on your own site. You can modify this version however you would like (or leave it unchanged), just provide a link back to the original version for attribution.
3. Create a copy of the full website and (optionally) modify the lessons and/or change which lessons are included. More information on how to do this is provided below.

### Creating a Copy of the Course Website

The course website is written in Hugo using the [Wowchemy Documentation theme](https://github.com/wowchemy/hugo-documentation-theme) and broader [Wowchemy system](https://wowchemy.com/)

#### Netlify

The easiest way to create your own version of the course is the create a deployed course on Netlify via this template. You need a GitHub account to do this.

[Click this template link](https://app.netlify.com/start/deploy?repository=https://github.com/weecology/forecasting-course) to create a copy of the GitHub repository in your GitHub account. Then follow the Wowchemy instructions for [Creating a site with Hugo and GitHub](https://wowchemy.com/docs/getting-started/hugo-github-quickstart/), skipping the "Choose a template" button on that page.

You can then edit files in the GitHub repository and they will automatically deploy to the website.

Edit `config/_default/params.yaml` to match your version of the course.
In particular, update the repository URL to match the new repository you created.
This will ensure that the `Edit this page` links on each page direct you to your version of the material.

#### Locally

Building a Hugo site locally requires that Go, git, NodeJS, and Hugo all be installed.
Detailed instructions for all operating systems are available on the [Wowchemy - Edit on your PC with Hugo Extended page](https://wowchemy.com/docs/getting-started/install-hugo-extended/).

Once you have a local Hugo installation working clone the site using:

```sh
git clone https://github.com/weecology/forecasting-course.git
```

You can build the site locally in the terminal from the root directory of this repository using:

```sh
hugo server
```

### Modifying the Site

* Most content is stored in one folder per lesson in the [`content/lessons` folder](https://github.com/weecology/forecasting-course/tree/main/content/lessons)
* To add a new lesson make a copy of the [lesson template folder](https://github.com/weecology/forecasting-course/tree/main/content/lessons/LessonTemplate) and modify the pages in the resulting folder using [markdown](https://www.markdownguide.org/)
* To modify a lesson edit the markdown files in that lesson folder with the appropriate name. If you followed the instructions on installing on Netlify above, the easiest way to do this is to go to the page you want to edit on the deployed site and click the `Edit this page` link at the bottom.
* To modify the schedule edit `content/schedule/schedule.md`. In the `lessons` section list the titles of the lessons you want to teach in the order you want to teach them. If you want to include specific dates for each lesson then edit the `dates` section to include those dates in the same order.

### Contributing

Contributions are always welcome!

* [Open an issue](https://github.com/weecology/forecasting-course/issues/new) to say Hi or if there’s anything we can do to help!
* Contributions of new lessons are welcome as Pull Requests or we can work with you to add new material and data to the site
* If you want to create a modified copy of the course including the website either follow the instructions for installing on Netlify above or fork/copy the repository and [connect it to Netlify](https://wowchemy.com/docs/hugo-tutorials/deployment/) to automatically build the site.

For more information see our [CONTRIBUTING page](https://github.com/weecology/forecasting-course/tree/main/CONTRIBUTING.md)