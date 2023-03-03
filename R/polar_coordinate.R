library(shiny)
library(bslib)
library(ggplot2)
library(tidyverse)
library(lubridate)
library(glue)

data <- read.csv('../data/processed/CA_youtube_trending_data_processed.csv')

interval_choices <- c("Day of Week" = "publish_wday",
                      "Month of Year" = "publish_month", 
                      "Time of Day" = "publish_hour")

ui <- navbarPage('YouTube Trend Visualizer',
                 theme = bs_theme(bootswatch = "lux"),
                 sidebarLayout(
                   sidebarPanel(
                     dateRangeInput(inputId = 'daterange',
                                    label = 'Trending Date Range:',
                                    start = min(data$trending_date),
                                    end = max(data$trending_date),
                                    format = 'yyyy-mm-dd')),
                   mainPanel(
                     fluidRow(selectInput("representation_format", "Format", choices = interval_choices),
                              selectInput("vid_category", "Category", choices = unique(data$categoryId))),
                     plotOutput("polar_coor")
                   )
                 )
)

server <- function(input, output, session) {
  # Date Selector
  output$value <- renderPrint({ input$date })
  
  # Polar Coordinates
  output$polar_coor <- renderPlot({
    # Creating new columns for date components
    data$publishedAt <- ymd_hms(data$publishedAt)
    data_mutated <- data |> dplyr::mutate("publish_date" = date(publishedAt),
                                          "publish_month" = month(publishedAt, label = TRUE),
                                          "publish_wday" = wday(publishedAt, label = TRUE),
                                          "publish_hour" = hour(publishedAt))
    
    # Filtering dataset by specified date and category
    data_filtered <- data_mutated |>
      filter(publish_date %within% interval(input$daterange[1], input$daterange[2]),
             categoryId == input$vid_category)
    
    # Render plot
    chart <- ggplot(data_filtered, aes(x=.data[[input$representation_format]], fill=after_stat(count))) + 
      stat_count(show.legend = TRUE) +
      xlab(names(interval_choices[which(interval_choices == input$representation_format)])) +
      ggtitle(glue("{input$vid_category} Videos by Publishing Day")) +
      scale_fill_continuous(name = "Number of Videos")
    
    pol_coor <- chart + 
      coord_polar() + 
      theme(axis.title.y = element_blank(),
            axis.ticks.y = element_blank(),
            axis.text.y = element_blank()
      )
    pol_coor
  })
}

shinyApp(ui, server)