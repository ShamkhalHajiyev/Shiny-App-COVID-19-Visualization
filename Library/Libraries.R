requiredPackages = c(
  'dplyr',
  'ggplot2',
  'plotly',
  'tidyr',
  'shiny',
  'shinythemes',
  'shinydashboard',
  'leaflet',
  'DT',
  'RColorBrewer'
)




for (p in requiredPackages) {
  if (!require(p, character.only = TRUE))
    install.packages(p)
  library(p, character.only = TRUE)
}