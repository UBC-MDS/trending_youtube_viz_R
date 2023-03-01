library(shiny)
library(bslib)
library(ggplot2)
library(tidyverse)
library(forcats)
library(plotly)
library(thematic)
library(scales)
library(rlang)
library(stringr)

data <- read.csv('../data/processed/CA_youtube_trending_data_processed.csv')

ui <- navbarPage('YouTube Trend Visualizer',
                 theme = bs_theme(bootswatch = "lux"),
                 sidebarLayout(
                   sidebarPanel(
                     width = 3,
                     dateRangeInput(inputId = 'daterange',
                                    label = 'Trending Date Range:',
                                    start = min(data$trending_date),
                                    end = max(data$trending_date),
                                    format = 'yyyy-mm-dd')
                              ),
                   mainPanel(
                     fluidRow(
                       column(3, align = "center", offset = 0.5,
                              style="padding:40px;", "Category Boxplots"),
                       column(3,
                              selectInput(inputId = 'boxplotdist',
                                          label = 'Distribution Metric:',
                                          choices = c("Comments (in thousands)" = "comment_count",
                                                      "Dislikes (in thousands)" = "dislikes",
                                                      "Likes (in thousands)" = "likes",
                                                      "Views (in millions)" = "view_count"),
                                          selected = 'Comments (in thousands)')),
                     column(3, align = "center", offset = 0.5,
                            style="padding:40px;", "Channel Barplot"),
                     column(3,
                            selectInput(inputId = 'barplotcat',
                                        label = 'Category:',
                                        choices = unique(data$categoryId),
                                        selected = 'Film & Animation'))
                     ),
                     fluidRow(
                       column(6,
                              plotlyOutput(outputId = 'boxplot')),
                       column(6,
                              plotlyOutput(outputId = 'barplot'))
                       )
                     )
                   )
)

server <- function(input, output, session) {
  
  scaleInput <- reactive({
    if (input$boxplotdist == "view_count") return(1e-6)
    else return(1e-4)
  })
  
  suffixInput <- reactive({
    if (input$boxplotdist == "view_count") return("M")
    else return("K")
  })
  
  # Category Boxplot
  output$boxplot <- plotly::renderPlotly({
    
    thematic::thematic_shiny()
    
    plotly::ggplotly(
      data |>
        dplyr::filter(trending_date > input$daterange[1] & trending_date < input$daterange[2]) |>
        dplyr::arrange(trending_date) |>
        dplyr::distinct(video_id, .keep_all = TRUE) |> # keep most recent data for accurate tracking?
        ggplot2::ggplot() +
        ggplot2::geom_boxplot(
          aes(x = forcats::fct_reorder(categoryId, !!rlang::sym(input$boxplotdist)),
              y = !!rlang::sym(input$boxplotdist),
              fill = categoryId)
        ) +
        ggplot2::scale_y_continuous(labels = label_number(suffix = suffixInput(), scale = scaleInput())) +
        ggplot2::guides(fill = FALSE) +
        ggplot2::coord_flip()
    )
  })
  
  # Channel Barplot
  output$barplot <- plotly::renderPlotly({
    
    thematic::thematic_shiny()
    
    plotly::ggplotly(
      data |>
        dplyr::filter(trending_date > input$daterange[1] & trending_date < input$daterange[2]) |>
        dplyr::filter(categoryId == input$barplotcat) |>
        dplyr::group_by(channelId, channelTitle) |>
        dplyr::summarise(video_count = length(unique(video_id))) |>
        dplyr::arrange(dplyr::desc(video_count)) |>
        dplyr::ungroup() |>
        dplyr::slice(1:10) |>
        ggplot2::ggplot(
          aes(x = video_count,
              y = channelTitle)
        ) +
        ggplot2::geom_bar(stat = "identity") +
        ggplot2::scale_y_discrete(labels = function(x) 
          stringr::str_wrap(x, width = 15))
    )
  })
  
}

shinyApp(ui, server)