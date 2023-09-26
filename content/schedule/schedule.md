---
widget: pages # As of v5.8-dev, 'pages' is renamed 'collection'
headless: true  # This file represents a page section.

# Put Your Section Options Here (title, background, etc.) ...
title: Schedule
subtitle: ''

# Position of this section on the page
weight: 1

content:
  # Filter content to display
  filters:
    # The folders to display content from
    lessons:
      - 'Course Introduction'
      - 'Paleoecological Dynamics'
      - 'Working with times and dates in R'
      - 'Changes in Phenology'
      - 'Time Series Decomposition in R'
      - 'Community Dynamics'
      - 'Time Series Autocorrelation in R'
      - 'Introduction to Time Series Data'
      - 'Time series modeling in R 1'
      - 'Time series modeling in R 2'
      - 'Time series modeling in R 3'
      - 'Introduction to Ecological Forecasting'
      - 'Introduction to Forecasting in R'
      - 'Uncertainty in Forecasting'
      - 'Evaluating Forecasts in R'
      - 'Forecasting using state space models'
      - 'State space models in R 1'
      - 'State space models in R 2'
      - 'Ask us anything 2'
      - 'Forecasting using species distribution models'
      - 'Species Distribution Models in R'
      - 'Hurricane Forecasts'
      - 'Election forecasts'
      - 'Data-driven models for forecasting'
      - 'Empirical Dynamic Modeling in R'
      - 'Scenario based forecasting'
      - 'Ethics of Ecological Forecasting'
      - 'Wrap up: Can we (and what should we) forecast in ecology?'
    dates:
      - 'August 24th'
      - 'August 29th'
      - 'August 31st'
      - 'September 5th'
      - 'September 7th'
      - 'September 12th'
      - 'September 14th'
      - 'September 19th'
      - 'September 21st'
      - 'September 26th'
      - 'September 28th'
      - 'October 3rd'
      - 'October 5th'
      - 'October 10th'
      - 'October 12th'
      - 'October 17th'
      - 'October 19th'
      - 'October 24th'
      - 'October 26th'
      - 'October 31st'
      - 'November 2nd'
      - 'November 7th'
      - 'November 9th'
      - 'November 14th'
      - 'November 16th'
      - 'November 28th'
      - 'November 30th'
      - 'December 5th'
    folders:
    tag: ''
    category: ''
    publication_type: ''
    author: ''
    featured_only: false
    exclude_featured: false
    exclude_future: false
    exclude_past: false
  # Choose how many pages you would like to display (0 = all pages)
  count: 100
  # Choose how many pages you would like to offset by
  # Useful if you wish to show the first item in the Featured widget
  offset: 0
  # Field to sort by, such as Date or Title
  sort_by: 'Weight'
  sort_ascending: true
design:
  # Choose a listing view
  view: community/schedule
  # Choose how many columns the section has. Valid values: '1' or '2'.
  columns: '1'
---