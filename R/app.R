library(shiny)
library(bslib)
library(ggplot2)
library(tidyverse)
library(forcats)
library(plotly)
library(thematic)
library(scales)
library(rlang)

ui <- navbarPage('YouTube Trend Visualizer',
                 theme = bs_theme(bootswatch = "lux"),
                 sidebarLayout(
                   sidebarPanel(
                     dateRangeInput(inputId = 'daterange',
                                    label = 'Trending Date Range:',
                                    start = min(data$trending_date),
                                    end = max(data$trending_date),
                                    format = 'yyyy-mm-dd'))
                   )
)

server <- function(input, output, session) {
  
}

shinyApp(ui, server)