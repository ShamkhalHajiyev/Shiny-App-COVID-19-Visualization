server <- function(input, output, session) {
  data = reactive({
    modified_data = raw_data %>%
      filter(`Country/Region` == input$country)
    if (input$state != "<all>") {
      modified_data = modified_data %>%
        filter(`Province/State` == input$state)
    } else {
      modified_data = modified_data %>%
        group_by(date) %>%
        summarise_if(is.numeric, sum, na.rm = TRUE)
    }
    modified_data %>%
      mutate(
        dateStr = format(date, format = "%b %d, %Y"),
        NewConfirmed = CumConfirmed - lag(CumConfirmed, default =
                                            0),
        NewRecovered = CumRecovered - lag(CumRecovered, default =
                                            0),
        NewDeaths = CumDeaths - lag(CumDeaths, default = 0)
      )
  })
  observeEvent(input$country, {
    states = raw_data %>%
      filter(`Country/Region` == input$country) %>%
      pull(`Province/State`)
    states = c("<all>", sort(unique(states)))
    updateSelectInput(session,
                      "state",
                      choices = states,
                      selected = states[1])
  })
  
  countries = sort(unique(raw_data$`Country/Region`))
  updateSelectInput(session, "country", choices = countries, selected =
                      "Poland")
  
  
  output$dailyMetrics = BarPlot_MainGraph("New", legendPrefix = "New", yaxisTitle =
                                        "New Cases per Day")
  output$cumulatedMetrics = BarPlot_MainGraph("Cum", legendPrefix = "Cumulated", yaxisTitle =
                                            "Cumulated Cases")
  
  }


 