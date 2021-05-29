source("Functions/Functions.R")

options(scipen = 999)


data_url = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/"



allD =
  loadD("time_series_covid19_confirmed_global.csv", "CumConfirmed") %>%
  inner_join(loadD("time_series_covid19_deaths_global.csv", "CumDeaths")) %>%
  inner_join(loadD("time_series_covid19_recovered_global.csv", "CumRecovered"))


countries = read_csv("Data/countries_codes_and_coordinates.csv")

