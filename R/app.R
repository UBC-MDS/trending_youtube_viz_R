library(shiny)

ui <- fluidPage(
  # Select List Input Control
  selectInput("variable", "Variable:",
              c("Name1" = "dataset_column_name1",
                "Name2" = "dataset_column_name2",
                "Name3" = "dataset_column_name3")),
  tableOutput("data"),
  
  # Date Selector
  dateInput("date", label = h3("Date input"), value = "2014-01-01"),
  hr(),
  fluidRow(column(3, verbatimTextOutput("value"))),
  
  # Checkbox Group Input Control
  checkboxGroupInput("variable", "Variables to show:",
                     c("Name1" = "dataset_column_name1",
                       "Name2" = "dataset_column_name2",
                       "Name3" = "dataset_column_name3")),
  tableOutput("data"),
  
  # Circle packer
  # Couldnt find a template, might need to make from scratch
  
  # Polar coordinates
  # Couldnt find a template, might need to make from scratch
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