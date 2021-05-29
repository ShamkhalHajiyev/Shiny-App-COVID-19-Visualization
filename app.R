# 1. PACKAGES
source("Library/Libraries.R")

# 2. Fucntions

source("Functions/Functions.R")

# 3. Global 

source("Global/Global.R")


# 4. Ui

source("ui/ui.R")

# 4. Server

source("server/server.R")
    
# Run the application 
shinyApp(ui = ui, server = server)
