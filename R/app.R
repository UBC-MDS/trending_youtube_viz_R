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
library(showtext)
library(thematic)
library(sysfonts)

data <- read.csv('../data/processed/CA_youtube_trending_data_processed.csv')

boxplot_options <- c(
  "Comments" = "comment_count",
  "Dislikes" = "dislikes",
  "Likes" = "likes",
  "Views" = "view_count"
)

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

main_theme <- bslib::bs_theme(
  bootswatch = "journal",
  base_font = bslib::font_google("Assistant"))

# Add fonts from Google
sysfonts::font_add_google("Assistant")

# Automatically use showtext to render text
showtext::showtext_auto()

# Let thematic know to update the plot fonts too
thematic::thematic_shiny(font = "auto")

ui <- fluidPage(theme = main_theme,
  navbarPage(
    theme = main_theme,
    
    # Import Font Awesome icons
    tags$style("@import url(https://use.fontawesome.com/releases/v5.7.2/css/all.css);"),
    
    # tags$head(
    #   tags$style(HTML("
    #     .navbar-static-top {
    #       background-color: #E96161;
    #     }"))
    # ),
    
    title = span(icon("youtube"), "YouTube Trend Visualizer"),
    
    tabPabel(
      "Options",
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
          radioButtons(
            inputId = "toggle_theme",
            label = "Mode",
            choices = c("Light" = "journal", "Dark" = "darkly")),
          )
      ),
      mainPanel(
        width = 10,
        # fluidRow(
        #   column(3,
        #     align = "center", offset = 0.5,
        #     style = "padding:40px;", "Category Boxplots"
        #   ),
        #   column(
        #     3,
        #     selectInput(
        #       inputId = "boxplotdist",
        #       label = "Distribution Metric:",
        #       choices = c(
        #         "Comments (in thousands)" = "comment_count",
        #         "Dislikes (in thousands)" = "dislikes",
        #         "Likes (in thousands)" = "likes",
        #         "Views (in millions)" = "view_count"
        #       ),
        #       selected = "Comments (in thousands)"
        #     )
        #   ),
        #   column(3,
        #     align = "center", offset = 0.5,
        #     style = "padding:40px;", "Channel Barplot"
        #   ),
        #   column(
        #     3,
        #     selectInput(
        #       inputId = "barplotcat",
        #       label = "Category:",
        #       choices = unique(data$categoryId),
        #       selected = "Film & Animation"
        #     )
        #   )
        # ),
        # fluidRow(
        #   column(
        #     6,
        #     plotlyOutput(outputId = "boxplot")
        #   ),
        #   column(
        #     6,
        #     plotlyOutput(outputId = "barplot")
        #   )
        # ),
        layout_column_wrap(
          width = 1/2,
          card(
            full_screen = TRUE,
            card_header("Category Boxplots"),
            card_body_fill(
              selectInput(
                inputId = "boxplotdist",
                label = "Distribution Metric:",
                choices = boxplot_options,
                selected = "Comments"
              ),
              plotlyOutput(outputId = "boxplot")
            )
          ),
          card(
            full_screen = TRUE,
            card_header("Channel Barplot"),
            card_body_fill(
              selectInput(
                inputId = "barplotcat",
                label = "Category:",
                choices = unique(data$categoryId),
                selected = "Music"
              ),
              plotlyOutput(outputId = "barplot")
            )
          )
        )
      )
    )
  )

server <- function(input, output, session) {
  # Dark Mode
  observe({
    session$setCurrentTheme(
      bs_theme_update(main_theme, bootswatch = input$toggle_theme)
    )
  })
  
  # Category Boxplot
  output$boxplot <- plotly::renderPlotly({
    plotly::ggplotly(
      data |>
        dplyr::filter(trending_date > input$daterange[1] & trending_date < input$daterange[2]) |>
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
    )
  })

  # Channel Barplot
  output$barplot <- plotly::renderPlotly({
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
          aes(
            x = video_count,
            y = channelTitle
          )
        ) +
        ggplot2::geom_bar(stat = "identity", fill = names(barplot_colours[which(barplot_colours == input$barplotcat)])) +
        ggplot2::labs(
          x = 'Count of Videos',
          y = 'Channel Title'
        ) +
        ggplot2::scale_y_discrete(labels = function(x) {
          stringr::str_wrap(x, width = 15)
        })
    )
  })
}

shinyApp(ui, server)
