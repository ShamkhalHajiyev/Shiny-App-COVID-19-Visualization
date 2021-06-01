last_update = function(fileName) {
  (as.numeric(as.POSIXlt(Sys.time())) - as.numeric(file.info(fileName)$ctime)) / 60
}


loadD = function(fileName, columnName) {
  if (!file.exists(fileName) || last_update(fileName) > 5) {
    data = read.csv(
      file.path(data_url, fileName),
      check.names = FALSE,
      stringsAsFactors = FALSE
    ) %>%
      pivot_longer(-(1:2), names_to = "date", values_to = columnName) %>%
      mutate(
        date = as.Date(date, format = "%m/%d/%y"),
        `Country/Region` = if_else(`Country/Region` == "", "?", `Country/Region`),
        `Province/State` = if_else(`Province/State` == "", "<all>", `Province/State`)
      )
    save(data, file = file.path('Data/', fileName))
  } else {
    load(file = file.path('Data/', fileName))
  }
  return(data)
}



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
