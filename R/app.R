library(shiny)
library(bslib)
library(ggplot2)
library(tidyverse)
library(forcats)
library(plotly)
library(thematic)
library(scales)
library(rlang)

data <- read.csv('../data/processed/CA_youtube_trending_data_processed.csv')

ui <- navbarPage('YouTube Trend Visualizer',
                 theme = bs_theme(bootswatch = "lux"),
                 sidebarLayout(
                   sidebarPanel(
                     dateRangeInput(inputId = 'daterange',
                                    label = 'Trending Date Range:',
                                    start = min(data$trending_date),
                                    end = max(data$trending_date),
                                    format = 'yyyy-mm-dd')
                              ),
                   mainPanel(
                     fluidRow(
                       column(6, align="center",
                              "Category Boxplots"),
                       column(6,
                              selectInput(inputId = 'barplotdist',
                                          label = 'Distribution Metric:',
                                          choices = c("Comments (in thousands)" = "comment_count",
                                                      "Dislikes (in thousands)" = "dislikes",
                                                      "Likes (in thousands)" = "likes",
                                                      "Views (in millions)" = "view_count"),
                                          selected = 'Comments (in thousands)'))
                       ),
                       fluidRow(
                         plotlyOutput(
                           outputId = 'barplot',
                           width = '500px',
                           height = '500px')
                         )
                     )
                   )
)

server <- function(input, output, session) {
  
  scaleInput <- reactive({
    if (input$barplotdist == "view_count") return(1e-6)
    else return(1e-4)
  })
  
  suffixInput <- reactive({
    if (input$barplotdist == "view_count") return("M")
    else return("K")
  })
  
  # Category Barplot
  output$barplot <- plotly::renderPlotly({
    
    thematic::thematic_shiny()
    
    plotly::ggplotly(
      data |>
        dplyr::filter(trending_date > input$daterange[1] & trending_date < input$daterange[2]) |>
        dplyr::arrange(trending_date) |>
        dplyr::distinct(video_id, .keep_all = TRUE) |> # keep most recent data for accurate tracking?
        ggplot2::ggplot() +
        ggplot2::geom_boxplot(
          aes(x = categoryId,
              y = !!rlang::sym(input$barplotdist),
              fill = categoryId)
        ) +
        ggplot2::scale_y_continuous(labels = label_number(suffix = suffixInput(), scale = scaleInput())) +
        ggplot2::guides(fill = FALSE) +
        ggplot2::coord_flip()
    )
  })
  
}

shinyApp(ui, server)