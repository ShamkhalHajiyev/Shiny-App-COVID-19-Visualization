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



