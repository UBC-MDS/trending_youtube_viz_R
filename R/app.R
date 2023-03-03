library(shiny)
library(bslib)
library(shinyWidgets)
library(ggplot2)
library(tidyverse)
library(forcats)
library(plotly)
library(thematic)
library(scales)
library(rlang)
library(stringr)
library(showtext)
library(thematic)
library(sysfonts)
library(packcircles)
library(lubridate)

options(shiny.autoreload = TRUE)
options(max.print = 25)

data <- read.csv('../data/processed/CA_youtube_trending_data_processed.csv')

boxplot_options <- c(
  "Comments" = "comment_count",
  "Dislikes" = "dislikes",
  "Likes" = "likes",
  "Views" = "view_count"
)

interval_choices <- c("Day of Week" = "publish_wday",
                      "Month of Year" = "publish_month", 
                      "Time of Day" = "publish_hour")

boxplot_colours <- setNames(
  c("#35618f", "#2dadb8", "#2a6a45", "#0df38f", "#93c680",
    "#21a708", "#bce333", "#7e2b19", "#de592e", "#fcd107",
    "#b08965", "#d4d4d4", "#5c51b1", "#cc99d9", "#a53bb7"),
  unique(data$categoryId)
)

barplot_colours <- setNames(
  unique(data$categoryId),
  c("#35618f", "#2dadb8", "#2a6a45", "#0df38f", "#93c680",
    "#21a708", "#bce333", "#7e2b19", "#de592e", "#fcd107",
    "#b08965", "#d4d4d4", "#5c51b1", "#cc99d9", "#a53bb7")
)

light_theme <- bslib::bs_theme(
  bootswatch = "journal",
  base_font = bslib::font_google("Assistant"))

dark_theme <- bslib::bs_theme(
  bootswatch = "journal",
  bg = "#232323",
  fg = "white",
  base_font = bslib::font_google("Assistant"))

# Add fonts from Google
sysfonts::font_add_google("Assistant")

# Automatically use showtext to render text
showtext::showtext_auto()

# Let thematic know to update the plot fonts too
thematic::thematic_shiny(font = "auto")

ui <- fluidPage(theme = light_theme,
  navbarPage(
    # Import Font Awesome icons
    tags$style("@import url(https://use.fontawesome.com/releases/v5.7.2/css/all.css);"),
    
    theme = light_theme,
    title = span(icon("youtube", style = "color: #D80808"),
                 "YouTube Trend Visualizer", style = 'font-size: 30px'),
    
    sidebarLayout(
      sidebarPanel(
        width = 2,
        dateRangeInput(
          inputId = "daterange",
          label = "Trending Date Range:",
          start = min(data$trending_date),
          end = max(data$trending_date),
          format = "yyyy-mm-dd"
        ),
        shinyWidgets::materialSwitch(
          inputId = "toggle_theme",
          label = span(icon("moon"), "Dark Mode"),
          value = FALSE,
          status = "info"
        ),
      ),
      mainPanel(
        width = 10,
        layout_column_wrap(
          width = 1/2,
          card(
            full_screen = TRUE,
            card_header(
              class = "bg-dark",
              span(icon("arrow-trend-up"), "Category Boxplots")),
            card_body_fill(
              fluidRow(
                column(5,
                  selectInput(
                    inputId = "boxplotdist",
                    label = "Distribution Metric:",
                    choices = boxplot_options,
                    selected = "Comments"
                  )
                ),
                column(5,
                  shinyWidgets::materialSwitch(
                    inputId = "rm_outliers",
                    label = "Exclude Outliers (> 0.9 Quantile)",
                    status = "primary"
                  )
                )
              ),
              plotlyOutput(outputId = "boxplot")
            )
          ),
          card(
            full_screen = TRUE,
            card_header(
              class = "bg-dark",
              span(icon("users"), "Channel Barplot")),
            card_body_fill(
              selectInput(
                inputId = "barplotcat",
                label = "Category:",
                choices = unique(data$categoryId),
                selected = "Music"
              ),
              plotlyOutput(outputId = "barplot")
            )
          ),
          card(
            full_screen = TRUE,
            card_header(
              class="bg-dark",
              span(icon("hashtag"), "Common Tags by Category")),
            card_body_fill(
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
                  width = 'fit')
              ),
              plotlyOutput('bubble')
            )
          ),
          card(
            full_screen = TRUE,
            card_header(
              class="bg-dark",
              span(icon("hashtag"), "Publishing Time")),
            card_body_fill(
              fluidRow(
                column(5,
                       selectInput(
                         inputId = "representation_format",
                         label = "Format:",
                         choices = interval_choices,
                         selected = "Day of Week"
                       )
                ),
                column(5,
                       selectInput(
                         inputId = "vid_category",
                         label = "Category:",
                         choices = unique(data$categoryId),
                         selected = "Music"
                       )
                )
              ),
              plotlyOutput('polar_coor')
            )
          )
        )
      )
    ),
    footer = tags$div(
      class = "footer",
      p(
        hr(),
        column(4, p()),
        column(4, p()),
        column(4, p()),
      ),
      p("2023 © D. Cairns, N. Cho, L. Zung")
    )
  )
)

server <- function(input, output, session) {
  # Dark Mode
  observe({
    session$setCurrentTheme(
      if (isTRUE(input$toggle_theme)) {
        dark_theme
      } else { light_theme }
    )
  })
  
  # Filter data by date universally
  data_by_date <- reactive({
    data <- data |>
      dplyr::filter(trending_date > input$daterange[1] & trending_date < input$daterange[2])
    return(data)
  })
  
  # Filter out outliers if toggled
  boxplot_data <- reactive({
    if (isTRUE(input$rm_outliers)) {
      data <- data_by_date() |>
        dplyr::filter(!!rlang::sym(input$boxplotdist) < quantile(!!rlang::sym(input$boxplotdist), 0.9))
      return(data)
    } else {
      return(data_by_date())
    }
  })
  
  # Category Boxplot
  output$boxplot <- plotly::renderPlotly({
    #Create plot
    box_plot <- boxplot_data() |>
      dplyr::arrange(trending_date) |>
      dplyr::distinct(video_id, .keep_all = TRUE) |> # keep most recent data for accurate tracking?
      ggplot2::ggplot() +
      ggplot2::geom_boxplot(
        aes(
          x = forcats::fct_reorder(categoryId, !!rlang::sym(input$boxplotdist)),
          y = !!rlang::sym(input$boxplotdist),
          fill = categoryId
        )
      ) +
      ggplot2::labs(
        x = names(boxplot_options[which(boxplot_options == input$boxplotdist)]),
        y = 'Category',
      ) +
      ggplot2::scale_y_continuous(labels = scales::label_number(scale_cut = cut_short_scale()), breaks = scales::breaks_pretty(n = 5)) +
      ggplot2::scale_fill_manual(values = boxplot_colours) + 
      ggplot2::guides(fill = FALSE) +
      ggplot2::coord_flip()
    
    # Display the plot
    plotly::ggplotly(box_plot, tooltip = "text")
  })

  # Channel Barplot
  output$barplot <- plotly::renderPlotly({
    # Create plot
    bar_plot <- data_by_date() |>
      dplyr::filter(categoryId == input$barplotcat) |>
      dplyr::group_by(channelId, channelTitle) |>
      dplyr::summarise(video_count = length(unique(video_id))) |>
      dplyr::arrange(dplyr::desc(video_count)) |>
      dplyr::ungroup() |>
      dplyr::slice(1:10) |>
      ggplot2::ggplot(
        aes(
          x = video_count,
          y = reorder(channelTitle, video_count),
          text = paste("Count: ", video_count)
        )
      ) +
      ggplot2::geom_bar(
        stat = "identity",
        fill = names(barplot_colours[which(barplot_colours == input$barplotcat)])) +
      ggplot2::labs(
        x = 'Count of Videos',
        y = 'Channel Title'
      ) +
      ggplot2::scale_y_discrete(labels = function(x) {
        stringr::str_wrap(x, width = 20)
      })
    
    # Display the plot
    plotly::ggplotly(bar_plot, tooltip = "text")
  })
  
  # Bubble Tags Plot
  output$bubble <- plotly::renderPlotly({
    filtered_tag_counts <- data_by_date() |>
      # Filter date and categories
      dplyr::filter(categoryId %in% input$bubbleCats) |>
      # Lowercase, count and sort remaining tags
      dplyr::mutate(tags = tolower(tags)) |>
      dplyr::pull(tags) |>
      stringr::str_split(fixed("|")) |>
      unlist() |>
      table(dnn = c("tag")) |>
      sort(decreasing = TRUE) |>
      as.data.frame() |>
      subset(tag != "[none]")
    
    # Parameter to tinker with.. how many circles to display
    n_circles <- 30
    
    # Functions to "pack" the circles in a nice layout
    packing <- packcircles::circleProgressiveLayout(filtered_tag_counts$Freq[1:n_circles])
    packing$radius <- 0.95*packing$radius
    packing$counts <- filtered_tag_counts$Freq[1:n_circles]
    bubbleplot_data <- packcircles::circleLayoutVertices(packing)
    bubble_labels <- stringr::str_wrap(filtered_tag_counts$tag[1:n_circles], 10)
    
    # Create the plot
    bubble_plot <- ggplot2::ggplot(bubbleplot_data, aes(x, y, text = paste("Rank: ", id))) + 
      ggplot2::geom_polygon(aes(group = id, fill = id), 
                            colour = "black", show.legend = FALSE) +
      ggplot2::geom_text(data = packing, aes(x, y, text = paste("Number of Videos: ", counts)), label = bubble_labels) +
      ggplot2::scale_fill_distiller(palette = "Spectral") +
      ggplot2::theme(
        axis.title = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank()
      )
    
    # Display the plot
    plotly::ggplotly(bubble_plot, tooltip = "text")
  })
  
  # Polar Coordinates
  output$polar_coor <- renderPlot({
    data_filtered <- data_by_date() |>
      # Filtering dataset by category
      dplyr::filter(categoryId == input$vid_category) |>
      # Creating new columns for date components
      dplyr::mutate("publishedAt" = lubridate::ymd_hms(publishedAt)) |>
      dplyr::mutate("publish_date" = lubridate::date(publishedAt),
                    "publish_month" = lubridate::month(publishedAt, label = TRUE),
                    "publish_wday" = lubridate::wday(publishedAt, label = TRUE),
                    "publish_hour" = lubridate::hour(publishedAt))
    
    # Render plot
    chart <- ggplot2::ggplot(data_filtered,
      aes(x = .data[[input$representation_format]], fill = after_stat(count))) + 
      ggplot2::stat_count(show.legend = TRUE) +
      ggplot2::xlab(names(interval_choices[which(interval_choices == input$representation_format)])) +
      ggplot2::scale_fill_continuous(name = "Number of Videos")
    
    pol_coor <- chart + 
      ggplot2::coord_polar() +
      ggplot2::theme(axis.title.y = element_blank(),
                     axis.ticks.y = element_blank(),
                     axis.text.y = element_blank()
      )
    
    # Display the plot
    plotly::ggplotly(pol_coor, tooltip = "text")
  })
}

shinyApp(ui, server)
