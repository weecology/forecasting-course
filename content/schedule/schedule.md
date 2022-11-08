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
      - 'Introduction to Time Series Data'
      - 'Paleoecological Dynamics'
      - 'Working with times and dates in R'
      - 'Changes in Phenology'
      - 'Time Series Decomposition in R'
      - 'Community Dynamics'
      - 'Time Series Autocorrelation in R'
      - 'Time series modeling in R'
      - 'Introduction to Ecological Forecasting'
      - 'Introduction to Forecasting in R'
      - 'Uncertainty in Forecasting'
      - 'Evaluating Forecasts in R'
      - 'Forecasting using state space models'
      - 'State space models in R'
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
      - '1'
      - '2'
      - '3'
      - '4'
      - '5'
      - '6'
      - '7'
      - '8'
      - '9'
      - '10'
      - '11'
      - '12'
      - '13'
      - '14'
      - '15'
      - '16'
      - '17'
      - '18'
      - '19'
      - '20'
      - '21'
      - '22'
      - '23'
      - '24'
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
  sort_by: 'Date'
  sort_ascending: false
design:
  # Choose a listing view
  view: community/schedule
  # Choose how many columns the section has. Valid values: '1' or '2'.
  columns: '1'
---