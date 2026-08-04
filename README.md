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

Lesson material can be accessed from [the website](https://course.naturecast.org) or using the raw markdown files in the [`lessons` directory](https://github.com/weecology/forecasting-course/tree/main/lessons) of this repository. Each lesson is stored in its own named subdirectory. 

There are three general approaches to using the material in teaching:

1. Use the existing website by linking to one or more lessons from your course site and reading the associated instructors material
2. Copy material from either the website or this GitHub repository and place it on your own site. You can modify this version however you would like (or leave it unchanged), just provide a link back to the original version for attribution.
3. Create a copy of the full website and (optionally) modify the lessons and/or change which lessons are included. More information on how to do this is provided in the rest of the README.

## Installation

The course website is built with [Quarto](https://quarto.org/) and needs only Quarto and R installed.
R is used solely to regenerate the schedule table before each render; it uses base R with no packages, and the R code in the tutorials is displayed rather than executed.

### Locally

Install [Quarto](https://quarto.org/docs/get-started/) (1.8 or newer) and [R](https://cloud.r-project.org/), then clone the site:

```sh
git clone https://github.com/weecology/forecasting-course.git
cd forecasting-course
```

Preview the site locally with live reload:

```sh
quarto preview
```

Or build it into `_site/`:

```sh
quarto render
```

### Netlify

The site is rendered by GitHub Actions and uploaded to Netlify for hosting; Netlify itself does not build it.

To create your own deployed version, fork this repository, [add it as a site on Netlify](https://docs.netlify.com/welcome/add-new-site/), and set two repository secrets in GitHub — `NETLIFY_AUTH_TOKEN` (a Netlify personal access token) and `NETLIFY_SITE_ID` (the site's "API ID" in Netlify's site settings).
The workflow in `.github/workflows/publish.yml` then publishes on every push to `main` and posts a preview deploy on each pull request.

After forking, update `repo-url` in `_quarto.yml` to point at your repository.
This makes the `Edit this page` link on each page direct to your version of the material.

## Modifying the Site

* Most content is stored in one folder per lesson in the [`lessons` folder](https://github.com/weecology/forecasting-course/tree/main/lessons)
* To add a new lesson make a copy of the [lesson template folder](https://github.com/weecology/forecasting-course/tree/main/lessons/LessonTemplate), edit the pages in the resulting folder using [markdown](https://www.markdownguide.org/), and add the lesson to the `sidebar` section of `_quarto.yml`
* To modify a lesson edit the `.qmd` files in that lesson folder. The easiest way to find the right file is to go to the page on the deployed site and click the `Edit this page` link.
* To modify the schedule edit [`schedule/schedule.csv`](https://github.com/weecology/forecasting-course/blob/main/schedule/schedule.csv). The table on the Schedule page is regenerated automatically on every render, and a lesson title that doesn't match a real lesson fails the build. Each row is a date plus either a lesson title (`kind` of `lesson`, which must match a lesson's `title:` exactly) or a one-off event such as a project work day (`kind` of `event`).

## Contributing

Contributions are always welcome!

* [Open an issue](https://github.com/weecology/forecasting-course/issues/new) to say Hi or if there’s anything we can do to help!
* Contributions of new lessons are welcome as Pull Requests or we can work with you to add new material and data to the site
* If you want to create a modified copy of the course including the website, fork or copy the repository and [connect it to Netlify](https://docs.netlify.com/welcome/add-new-site/) to automatically build the site.

For more information see our [CONTRIBUTING page](https://github.com/weecology/forecasting-course/tree/main/CONTRIBUTING.md)
