ui <- fluidPage(
  navbarPage(
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
    tabPanel("Compare Countries")
  )
)
