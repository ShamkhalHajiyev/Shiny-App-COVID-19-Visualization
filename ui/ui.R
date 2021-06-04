ui <- fluidPage(navbarPage(
  "COVID-19 Visualization Application",
  tabPanel("Main Graph",
           sidebarLayout(
             sidebarPanel(
               selectizeInput(
                 "country",
                 label = h4("Country"),
                 choices = NULL,
                 width = "100%"
               ),
               selectizeInput(
                 "state",
                 label = h4("State/Province"),
                 choices = NULL,
                 width = "100%"
               ),
               checkboxGroupInput(
                 "metrics",
                 label = h4("Selected Metrics"),
                 choices = c("Confirmed", "Deaths", "Recovered"),
                 selected = c("Confirmed", "Deaths", "Recovered"),
                 width = "100%"
               )
             ),
             mainPanel(tabsetPanel(
               tabPanel("Daily Cases per Day",
                        plotlyOutput("dailyMetrics")),
               tabPanel("Cumulated Cases",
                        plotlyOutput("cumulatedMetrics"))
             ))
           )),
  tabPanel("Compare Countries",
           sidebarLayout(
             sidebarPanel(
               selectInput(
                 inputId = "Country",
                 label = "Select Countries",
                 choices = NULL,
                 selected = "All",
                 multiple = TRUE
               ),
               selectInput(
                 "Plottype",
                 "Select Plot",
                 choices = c("Line", "Stacked Area", "Pie", "Bar"),
                 selected = "Pie"
               ),
               selectInput(
                 "DataSetDATA",
                 "Data set:",
                 choices = c("Death", "Confirmed", "Recover"),
                 selected = "Death"
               ),
               selectInput(
                 "DataTypeDATA",
                 "Data type:",
                 choices = NULL,
                 selected = "All"
               ),
               uiOutput("selectDate")
             ),
             mainPanel(plotlyOutput("compplot"))
           )),
  tabPanel(
    "Data Review",
    DT::dataTableOutput("Data_review"),
    downloadButton("downloadDataDaily", "Download Daily Data"),
    tags$br(),
    tags$br(),
    downloadButton("downloadDataCumulated", "Download Cumulated Data"),
    tags$br(),
    tags$br(),
    tags$br(),
    tags$br(),
    "This data is modified and taken from",
    tags$a(href = "https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series",
           "Johns Hopkins Center for Systems Science and Engineering.")
  )
))
