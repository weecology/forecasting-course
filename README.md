[![DOI](https://zenodo.org/badge/283032599.svg)](https://zenodo.org/badge/latestdoi/283032599)

# Ecological Forecasting & Dynamics Course

This is a course on how ecological systems change through time and how to forecast how they will change in the future.
It combines reading and discussing primary scientific literature with R tutorials on how to work with time-series data and make forecasts in R.
It is taught each Fall at the University of Florida by Drs. Morgan Ernest and Ethan White.
The full course including lecture notes and R tutorials is openly available so that students can learn these important approaches and skills for themselves and so that other teachers can reuse and remix the content of the course.

## Installation

The course website is written in Hugo using the [Wowchemy Documentation theme](https://github.com/wowchemy/hugo-documentation-theme) and broader [Wowchemy system](https://wowchemy.com/)

### Netlify

The easiest way to create your own version of the course is the create a deployed course on Netlify via this template. You need a GitHub account to do this.

Follow the Wowchemy instructions for [Creating a site with Hugo and GitHub](https://wowchemy.com/docs/getting-started/hugo-github-quickstart/),
but instead of using the "Choose a template" button [click this template link](https://app.netlify.com/start/deploy?repository=https://github.com/weecology/forecasting-course).

This will create a GitHub repository in your GitHub account and live version of the site.
You can then edit files in the GitHub repository and they will automatically deploy to the website.

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

## Contributing

Contributions are always welcome!

* Most content is stored in one folder per lesson in the [`content/lessons` folder](https://github.com/weecology/forecasting-course/tree/main/content/lessons)
* To add a new lesson make a copy of the [lesson template folder](https://github.com/weecology/forecasting-course/tree/main/content/lessons/LessonTemplate) and modifying the pages in the resulting folder using [markdown](https://www.markdownguide.org/)
* [Open an issue](https://github.com/weecology/forecasting-course/issues/new) to say Hi or if there’s anything we can do to help!
* Contributions of new lessons are welcome as Pull Requests or we can work with you to add new material and data to the site
* If you want to create a modified copy of the course including the website you should fork or copy the repository and [connect it to Netlify](https://wowchemy.com/docs/hugo-tutorials/deployment/) to automatically build the site

For more information see our [CONTRIBUTING page](https://github.com/weecology/forecasting-course/tree/main/CONTRIBUTING.md)