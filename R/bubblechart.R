library(shiny)
library(bslib)
library(dplyr)
library(stringr)
library(packcircles)
library(ggplot2)

options(shiny.autoreload = TRUE)
options(max.print = 25)

data <- read.csv('../data/processed/CA_youtube_trending_data_processed.csv')

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
                     plotOutput('bubble')
                   )
                 ),
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
  
  output$bubble <- renderPlot({
    # Circle packer
    # Couldnt find a template, might need to make from scratch
    filtered_tag_counts <- data |>
    # Filter for categories here
      pull(tags) |>
      str_split(fixed("|")) |>
      unlist() |>
      table(dnn = c("tag")) |>
      sort(decreasing = TRUE) |>
      as.data.frame() |>
      subset(tag != "[None]")
      
  
    print(filtered_tag_counts$Freq[1:30])
    
    n_circles <- 30
    packing <- circleProgressiveLayout(filtered_tag_counts$Freq[1:n_circles])
    bubbleplot_data <- circleLayoutVertices(packing)
    
    ggplot(bubbleplot_data, aes(x, y)) + 
      geom_polygon(aes(group = id, fill = id), 
                   colour = "black", show.legend = FALSE) +
      geom_text(data = packing, aes(x, y), label = filtered_tag_counts$tag[1:n_circles]) +
      scale_fill_distiller(palette = "RdGy") +
      theme_void()
    
    # https://stackoverflow.com/questions/37186172/bubble-chart-without-axis-in-r
  })
  
  # Polar coordinates
  # Couldnt find a template, might need to make from scratch
  
}

shinyApp(ui, server)