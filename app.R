library(shiny)
library(bslib)
library(shinyWidgets)
library(shinydashboard)
library(ggplot2)
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
library(rsconnect)

options(shiny.autoreload = TRUE)
options(max.print = 25)

data <- read.csv("data/processed/CA_youtube_trending_data_processed.csv")

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
          label = span("Trending Date Range:", style = 'font-size: 20px'),
          start = min(data$trending_date),
          end = max(data$trending_date),
          format = "yyyy-mm-dd"
        ),
        shinydashboard::valueBoxOutput("video_count_box", width = "100%"),
        shinydashboard::valueBoxOutput("channel_count_box", width = "100%"),
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
              span(icon("arrow-trend-up"), "Distribution Boxplots", style = 'font-size: 20px')),
            card_body_fill(
              fluidRow(
                column(6,
                  selectInput(
                    inputId = "boxplotdist",
                    label = "Distribution Metric:",
                    choices = boxplot_options,
                    selected = "Comments"
                  )
                ),
                column(6,
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
              span(icon("users"), "Trending Videos by Channel", style = 'font-size: 20px')),
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
              span(icon("hashtag"), "Common Tags by Category", style = 'font-size: 20px')),
            card_body_fill(
              fluidRow(
                column(6,
                  shinyWidgets::pickerInput(
                    inputId = "bubbleCats", 
                    label = "Category:", 
                    choices = sort(unique(data$categoryId)), 
                    selected = unique(data$categoryId),
                    multiple = TRUE,
                    options = shinyWidgets::pickerOptions(
                      actionsBox = TRUE,
                      countSelectedText = "{0} categories",
                      selectedTextFormat = "count > 2",
                      width = 'fit')
                  )
                ),
                column(6,
                  sliderInput(
                    inputId = "num_tags",
                    label = "Number of Tags:",
                    min = 1, max = 50, value = 30
                  )
                )
              ),
              plotlyOutput('bubble')
            )
          ),
          card(
            full_screen = TRUE,
            card_header(
              class="bg-dark",
              span(icon("clock"), "Popular Publishing Times", style = 'font-size: 20px')),
            card_body_fill(
              fluidRow(
                column(6,
                       selectInput(
                         inputId = "representation_format",
                         label = "Format:",
                         choices = interval_choices,
                         selected = "Day of Week"
                       )
                ),
                column(6,
                       selectInput(
                         inputId = "vid_category",
                         label = "Category:",
                         choices = unique(data$categoryId),
                         selected = "Music"
                       )
                )
              ),
              plotOutput('polar_coor', width = "100%")
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
  
  # Video Counter
  output$video_count_box <- renderValueBox({
    shinydashboard::valueBox(
      span(icon("video"), length(unique(data_by_date()$video_id))),
      subtitle = "Total Video Count"
    )
  })
  
  # Channel Counter
  output$channel_count_box <- renderValueBox({
    shinydashboard::valueBox(
      span(icon("user"), length(unique(data_by_date()$channelId))),
      subtitle = "Total Channel Count"
    )
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
      dplyr::distinct(video_id, .keep_all = TRUE) |> # keep most recent data point for accurate tracking (no aggregating the same video)
      ggplot2::ggplot() +
      ggplot2::geom_boxplot(
        aes(
          x = forcats::fct_reorder(categoryId, !!rlang::sym(input$boxplotdist)),
          y = !!rlang::sym(input$boxplotdist),
          fill = categoryId
        )
      ) +
      ggplot2::labs(
        y = names(boxplot_options[which(boxplot_options == input$boxplotdist)]),
        x = 'Category',
      ) +
      ggplot2::scale_y_continuous(labels = scales::label_number(scale_cut = cut_short_scale()), breaks = scales::breaks_pretty(n = 5)) +
      ggplot2::scale_fill_manual(values = boxplot_colours) + 
      ggplot2::guides(fill = FALSE) +
      ggplot2::theme(axis.title.x = element_text(size = 14, face = "bold"),
                     axis.title.y = element_text(size = 14, face = "bold")) +
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
          text = paste(
            "Count: ", video_count)
        )
      ) +
      ggplot2::geom_bar(
        stat = "identity",
        fill = names(barplot_colours[which(barplot_colours == input$barplotcat)])) +
      ggplot2::labs(
        x = 'Count of Videos',
        y = 'Channel Name'
      ) +
      ggplot2::scale_y_discrete(labels = function(x) {
        stringr::str_wrap(x, width = 20)
      }) +
      ggplot2::theme(axis.title.x = element_text(size = 14, face = "bold"),
                     axis.title.y = element_text(size = 14, face = "bold"))
      
    
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
    
    # Functions to "pack" the circles in a nice layout
    packing <- packcircles::circleProgressiveLayout(filtered_tag_counts$Freq[1:input$num_tags])
    packing$radius <- 0.95*packing$radius
    packing$counts <- filtered_tag_counts$Freq[1:input$num_tags]
    bubbleplot_data <- packcircles::circleLayoutVertices(packing)
    bubble_labels <- stringr::str_wrap(filtered_tag_counts$tag[1:input$num_tags], 10)
    
    # Create the plot
    bubble_plot <- ggplot2::ggplot(bubbleplot_data, aes(x, y, text = paste("Rank: ", id))) + 
      ggplot2::geom_polygon(aes(group = id, fill = id), 
                            colour = "black", show.legend = FALSE) +
      ggplot2::geom_text(data = packing,
                         aes(x, y, text = paste("Tag: ", filtered_tag_counts$tag[1:input$num_tags], "\nNumber of Videos: ", counts)),
                         label = bubble_labels, size = 3, color = "white") +
      ggplot2::scale_fill_viridis_c() +
      ggplot2::theme(
        axis.title = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank()
      )
    
    # Display the plot
    plotly::ggplotly(bubble_plot, tooltip = "text")
  })
  
  # Polar Coordinates
  # There is currently an open issue regarding the integration of coord_polar in plotly
  # (https://github.com/plotly/plotly.R/issues/878)
  output$polar_coor <- renderPlot({
    data_filtered <- data_by_date() |>
      # Filtering dataset by category
      dplyr::filter(categoryId == input$vid_category) |>
      # Creating new columns for date components
      dplyr::mutate(publishedAt = lubridate::ymd_hms(publishedAt)) |>
      dplyr::mutate(publish_date = lubridate::date(publishedAt),
                    publish_month = lubridate::month(publishedAt, label = TRUE),
                    publish_wday = lubridate::wday(publishedAt, label = TRUE),
                    publish_hour = lubridate::hour(publishedAt)) |>
      dplyr::group_by(!!rlang::sym(input$representation_format)) |>
      dplyr::summarise(video_count = length(unique(video_id)))
    
    # Render plot
    ggplot2::ggplot(data_filtered,
      aes(x = .data[[input$representation_format]], y = video_count, fill = video_count)) +
      ggplot2::geom_bar(stat = "identity") +
      ggplot2::xlab(names(interval_choices[which(interval_choices == input$representation_format)])) +
      ggplot2::scale_fill_distiller(palette = "YlGnBu", direction = 1, name = "Number of Videos") +
      ggplot2::coord_polar() +
      ggplot2::theme(axis.title.x = element_text(size = 22, face = "bold"),
                     axis.text.x = element_text(size = 26),
                     axis.title.y = element_blank(),
                     axis.ticks.y = element_blank(),
                     axis.text.y = element_blank(),
                     legend.text = element_text(size = 18),
                     legend.title = element_text(size = 20, face = "bold"),
                     legend.box.margin = margin(12, 12, 12, 12))
  })
}

shinyApp(ui, server)
