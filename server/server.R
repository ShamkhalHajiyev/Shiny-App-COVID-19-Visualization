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
  
  ### Graph of main page
  BarPlot_MainGraph = function(varPrefix, legendPrefix, yaxisTitle) {
    renderPlotly({
      data = data()
      plt = data %>%
        plot_ly() %>%
        config(displayModeBar = FALSE) %>%
        layout(
          barmode = 'group',
          xaxis = list(
            title = "",
            tickangle = -90,
            type = 'category',
            ticktext = as.list(data$dateStr),
            tickvals = as.list(data$date),
            gridwidth = 1
          ),
          yaxis = list(title = yaxisTitle),
          legend = list(
            x = 0.05,
            y = 0.95,
            font = list(size = 15),
            bgcolor = 'rgba(240,240,240,0.5)'
          ),
          font = f1
        )
      for (metric in input$metrics)
        plt = plt %>%
        add_trace(
          x = ~ date,
          y = data[[paste0(varPrefix, metric)]],
          type = 'bar',
          name = paste(legendPrefix, metric, "Cases"),
          marker = list(
            color = switch(
              metric,
              Deaths = 'rgb(0,0,0)',
              Recovered = 'rgb(30,200,30)',
              Confirmed = 'rgb(200,30,30)'
            ),
            line = list(color = 'rgb(8,48,107)', width = 1.0)
          )
        )
      plt
    })
  }
  
  output$dailyMetrics = BarPlot_MainGraph("New", legendPrefix = "New", yaxisTitle =
                                        "New Cases per Day")
  output$cumulatedMetrics = BarPlot_MainGraph("Cum", legendPrefix = "Cumulated", yaxisTitle =
                                            "Cumulated Cases")
  ########### DATA REVIEW ########### 
  new_Data <- raw_data[order(raw_data$`Country/Region`),] %>%
    group_by(`Province/State`, `Country/Region`) %>%
    arrange(desc(raw_data$date)) %>%
    slice(1)
  output$Data_review <- DT::renderDataTable({
    DT::datatable(new_Data[, drop = FALSE])
  })
  output$downloadDataDaily <- downloadHandler(
    filename = function() {
      paste("Covid-19_Daily", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(new_Data, file)
    }
  )
  
  output$downloadDataCumulated <- downloadHandler(
    filename = function() {
      paste("Covid-19_Cumulated", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(new_Data, file)
    }
  )
  }


 