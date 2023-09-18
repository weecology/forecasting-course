[![DOI](https://jose.theoj.org/papers/10.21105/jose.00198/status.svg)](https://doi.org/10.21105/jose.00198)
[![DOI](https://zenodo.org/badge/283032599.svg)](https://zenodo.org/badge/latestdoi/283032599)

# Ecological Forecasting & Dynamics Course

This is a course on how ecological systems change through time and how to forecast how they will change in the future.
It combines reading and discussing primary scientific literature with R tutorials on how to work with time-series data and make forecasts in R.
It is taught each Fall at the University of Florida by Drs. Morgan Ernest and Ethan White.
The full course including lecture notes and R tutorials is openly available so that students can learn these important approaches and skills for themselves and so that other teachers can reuse and remix the content of the course.

## Getting Started

### Using Materials to Learn About Ecological Forecasting

To use the materials for learning we recommend viewing them through [the rendered website](https://course.naturecast.org). Check out the [Getting Started page](https://course.naturecast.org/getting-started) to find out how to best use the site for independent learning.

### Using Materials to Teach Ecological Forecasting

All of the code, lesson content, data, and infrastructure for this site is openly licensed so you can use any of it in your own courses.

Lesson material can be accessed from [the website](https://course.naturecast.org) or using the raw markdown files in the [`content/lessons` directory](https://github.com/weecology/forecasting-course/tree/main/content/lessons) of this repository. Each lesson is stored in its own named subdirectory. 

There are three general approaches to using the material in teaching:

1. Use the existing website by linking to one or more lessons from your course site and reading the associated instructors material
2. Copy material from either the website or this GitHub repository and place it on your own site. You can modify this version however you would like (or leave it unchanged), just provide a link back to the original version for attribution.
3. Create a copy of the full website and (optionally) modify the lessons and/or change which lessons are included. More information on how to do this is provided in the rest of the README.

## Installation

The course website is written in Hugo using the [Wowchemy Documentation theme](https://github.com/wowchemy/hugo-documentation-theme) and broader [Wowchemy system](https://wowchemy.com/)

### Netlify

The easiest way to create your own version of the course is the create a deployed course on Netlify via this template. You need a GitHub account to do this.

Follow the Wowchemy instructions for [Creating a site with Hugo and GitHub](https://wowchemy.com/docs/getting-started/hugo-github-quickstart/),
but instead of using the "Choose a template" button [click this template link](https://app.netlify.com/start/deploy?repository=https://github.com/weecology/forecasting-course).

This will create a GitHub repository in your GitHub account and live version of the site.
You can then edit files in the GitHub repository and they will automatically deploy to the website.

Edit `config/_default/params.yaml` to match your version of course.
In particular update the repository url to match the new repository you created.
This will ensure that the `Edit this page` links on each page direct you to your version of the material.

### Locally

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

## Modifying the Site

* Most content is stored in one folder per lesson in the [`content/lessons` folder](https://github.com/weecology/forecasting-course/tree/main/content/lessons)
* To add a new lesson make a copy of the [lesson template folder](https://github.com/weecology/forecasting-course/tree/main/content/lessons/LessonTemplate) and modifying the pages in the resulting folder using [markdown](https://www.markdownguide.org/)
* To modify a lesson edit the markdown files in that lesson folder with the appropriate name. If you followed the instructions on installing on Netlify above, the easiest way to do this is to go to the page you want to edit on the deployed site and click the `Edit this page` link at the bottom.
* To modify the schedule edit `content/schedule/schedule.md`. In the `lessons` section list the titles of the lessons you want to teach in the order you want to teach them. If you want to include specific dates for each lesson then edit the `dates` section to include those dates in the same order.

## Contributing

Contributions are always welcome!

* [Open an issue](https://github.com/weecology/forecasting-course/issues/new) to say Hi or if there’s anything we can do to help!
* Contributions of new lessons are welcome as Pull Requests or we can work with you to add new material and data to the site
* If you want to create a modified copy of the course including the website either following the instructions for installing on Netlify above or fork/copy the repository and [connect it to Netlify](https://wowchemy.com/docs/hugo-tutorials/deployment/) to automatically build the site.

For more information see our [CONTRIBUTING page](https://github.com/weecology/forecasting-course/tree/main/CONTRIBUTING.md)
