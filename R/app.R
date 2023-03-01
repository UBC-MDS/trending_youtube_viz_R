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
  # Select List Input Control
  output$data <- renderTable({
    dataset[, c("dataset_column_name1", input$variable), drop = FALSE]
  }, rownames = TRUE)
  
  # Date Selector
  output$value <- renderPrint({ input$date })
  
  # Checkbox Group Input Control
  output$txt <- renderText({
    icons <- paste(input$icons, collapse = ", ")
    paste("You chose", icons)
  })
  
  # Circle packer
  # Couldnt find a template, might need to make from scratch
  
  # Polar coordinates
  # Couldnt find a template, might need to make from scratch
  
}

shinyApp(ui, server)
