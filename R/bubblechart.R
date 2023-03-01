library(shiny)
library(bslib)
library(dplyr)
library(stringr)
library(packcircles)
library(ggplot2)
library(plotly)
library(shinyWidgets)

options(shiny.autoreload = TRUE)
options(max.print = 25)

data <- read.csv('../data/processed/CA_youtube_trending_data_processed.csv')
#str(data)

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
                     verticalLayout(
                       fluidRow(
                         column(6, 
                                titlePanel("Common Tags by Category"),
                         ),
                         column(6, 
                                pickerInput(
                                  inputId = "bubbleCats", 
                                  label = "Category", 
                                  choices = sort(unique(data$categoryId)), 
                                  selected = unique(data$categoryId),
                                  multiple = TRUE,
                                  options = pickerOptions(
                                    actionsBox = TRUE,
                                    countSelectedText = "{0} categories",
                                    selectedTextFormat = "count > 2",
                                    width = 'fit'
                                  ),
                                  width = "fit"
                                )
                         )
                       ),
                       plotlyOutput('bubble')
                     )
                   )
                 ),
)

server <- function(input, output, session) {

  # Bubble Tags Plot
  output$bubble <- renderPlotly({
    # Couldnt find a template, might need to make from scratch
    filtered_tag_counts <- data |>
      # Filter date and categories
      filter(trending_date >= input$daterange[1]) |> 
      filter(trending_date <= input$daterange[2]) |> 
      filter(categoryId %in% input$bubbleCats) |>
      # Count and sort remaining tags
      pull(tags) |>
      str_split(fixed("|")) |>
      unlist() |>
      table(dnn = c("tag")) |>
      sort(decreasing = TRUE) |>
      as.data.frame() |>
      subset(tag != "[None]")
      

    # Parameter to tinker with.. how many circles to display
    n_circles <- 30
    
    # Functions to "pack" the circles in a nice layout
    packing <- circleProgressiveLayout(filtered_tag_counts$Freq[1:n_circles])
    bubbleplot_data <- circleLayoutVertices(packing)
    
    # Display the plot
    ggplotly(
      ggplot(bubbleplot_data, aes(x, y)) + 
        geom_polygon(aes(group = id, fill = id), 
                     colour = "black", show.legend = FALSE) +
        geom_text(data = packing, aes(x, y), label = filtered_tag_counts$tag[1:n_circles]) +
        scale_fill_distiller(palette = "Blues") +
        theme_void(),
      tooltip = NULL
    )
  })
  
}

shinyApp(ui, server)