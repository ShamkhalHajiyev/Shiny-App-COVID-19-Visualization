source("Functions/Functions.R")

options(scipen = 999)

f1 = list(family = "Courier New, monospace",
          size = 12,
          color = "rgb(0,0,0)")

data_url = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/"



raw_data =
  loadD("time_series_covid19_confirmed_global.csv", "CumConfirmed") %>%
  inner_join(loadD("time_series_covid19_deaths_global.csv", "CumDeaths")) %>%
  inner_join(loadD("time_series_covid19_recovered_global.csv", "CumRecovered"))


raw_data <- delete.na(raw_data)
