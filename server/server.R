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
  new_Data <- raw_data[order(raw_data$`Country/Region`), ] %>%
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
  
  ############"Compare the datas of Countries"##########################
  countries = sort(unique(raw_data$`Country/Region`))
  updateSelectInput(
    session,
    "Country",
    choices = countries,
    selected = c("Azerbaijan", "Albania", "Poland")
  )
  
  observeEvent(input$Plottype, {
    if (input$Plottype != "Pie")
    {
      updateSelectInput(
        session,
        "DataTypeDATA",
        choices = c("Daily", "Cummulative"),
        selected = "Daily"
      )
    }
    else
    {
      updateSelectInput(
        session,
        "DataTypeDATA",
        choices = c("Daily", "Cummulative"),
        selected = "Daily"
      )
    }
  })
  
  output$selectDate <- renderUI({
    raw_data$date1 = format(as.Date(raw_data$date), format = "%Y-%m-%d")
    if (input$Plottype != "Pie")
    {
      dateRangeInput(
        'selectDate',
        label = 'Select a Date Range',
        start = min(raw_data$date1),
        end = max(raw_data$date1)
      )
    }
    else{
      dateInput('selectDate',
                label = 'Select a Date',
                value =  max(raw_data$date1))
    }
    
  })
  
  data1 = reactive({
    d = raw_data %>% mutate(
      dateStr = format(date, format = "%b %d, %Y"),
      NewConfirmed = CumConfirmed - lag(CumConfirmed, default = 0),
      NewRecovered = CumRecovered - lag(CumRecovered, default = 0),
      NewDeaths = CumDeaths - lag(CumDeaths, default = 0)
    )
    d[d$NewConfirmed < 0, "NewConfirmed"] = 0
    d[d$NewRecovered < 0, "NewRecovered"] = 0
    d[d$NewDeaths < 0, "NewDeaths"] = 0
    d = d %>%
      filter(`Country/Region` %in% input$Country)
    d$date1 = format(as.Date(d$date), format = "%Y-%m-%d")
    
    d1 = aggregate(
      cbind(
        d$NewConfirmed,
        d$NewRecovered,
        d$NewDeaths,
        d$CumConfirmed,
        d$CumRecovered,
        d$CumDeaths
      ),
      by = list(
        `Country/Region` = d$`Country/Region`,
        date1 = d$date1
      ),
      FUN = sum
    )
    colnames(d1) = c(
      'Country',
      'date1',
      'NewConfirmed',
      'NewRecovered',
      'NewDeaths',
      'CumConfirmed',
      'CumRecovered',
      'CumDeaths'
    )
    
    if ((input$DataSetDATA == 'Death') &
        (input$DataTypeDATA == 'Daily')) {
      d1$Y = d1$NewDeaths
    }
    if ((input$DataSetDATA == 'Death') &
        (input$DataTypeDATA == 'Cummulative')) {
      d1$Y = d1$CumDeaths
    }
    if ((input$DataSetDATA == 'Confirmed') &
        (input$DataTypeDATA == 'Daily')) {
      d1$Y = d1$NewConfirmed
    }
    if ((input$DataSetDATA == 'Confirmed') &
        (input$DataTypeDATA == 'Cummulative')) {
      d1$Y = d1$CumConfirmed
    }
    if ((input$DataSetDATA == 'Recover') &
        (input$DataTypeDATA == 'Daily')) {
      d1$Y = d1$NewRecovered
    }
    if ((input$DataSetDATA == 'Recover') &
        (input$DataTypeDATA == 'Cummulative')) {
      d1$Y = d1$CumRecovered
    }
    d1 = subset(d1, select = c(date1, Country, Y))
    d1 = d1[order(d1$date1),]
    d1
  })
  
  
  output$compplot <- renderPlotly({
    req(input$Plottype)
    df <- data1()
    
    
    if (input$Plottype == "Line")
    {
      df = df[(df$date1 >= input$selectDate[1]) &
                (df$date1 <= input$selectDate[2]),]
      p = df %>%
        ggplot(aes(
          x = date1,
          y = Y,
          group = Country,
          color = Country
        )) +
        geom_line(size = 1) +
        labs(x = "date") + theme_bw(base_size = 15) + theme(axis.text.x = element_text(angle = 90))
    }
    
    if (input$Plottype == "Pie")
    {
      df = df[(df$date1 == input$selectDate),]
      cols <- rainbow(nrow(df))
      df$percent = round(100 * df$Y / sum(df$Y), digits = 1)
      df$label = paste(df$Country, " (", df$percent, "%)", sep = "")
      #p=pie(df$Y, labels = df$label, col = cols)
      p =		plot_ly(df) %>%
        add_pie(
          labels = ~ label,
          values = ~ Y,
          customdata = ~ label
        )      
    }    
    if (input$Plottype == "Stacked Area")
    {
      df = df[(df$date1 >= input$selectDate[1]) &
                (df$date1 <= input$selectDate[2]),]
      df$Country <- factor(df$Country)
      p = df %>%
        ggplot(aes(
          x = date1,
          y = Y,
          group = Country,
          color = Country,
          fill = Country
        )) +
        geom_area(alpha = 0.6 ,
                  size = 1,
                  colour = "black") +
        labs(x = "date") + theme_bw(base_size = 15) + theme(axis.text.x = element_text(angle = 90))
    }
    if (input$Plottype == "Bar")
    {
      df = df[(df$date1 >= input$selectDate[1]) &
                (df$date1 <= input$selectDate[2]),]
      df$Country <- factor(df$Country)
      p = df %>%
        ggplot(aes(
          x = date1,
          y = Y,
          group = Country,
          color = Country,
          fill = Country
        )) +
        geom_bar(position = "stack", stat = "identity") +
        labs(x = "date") + theme_bw(base_size = 15) + theme(axis.text.x = element_text(angle = 90))
      
    }
    p
  })

}


