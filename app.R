library(shiny)
library(shinydashboard)
library(leaflet)
library(geojsonio)
library(RColorBrewer)

source("map.R")

ui <- dashboardPage(
  dashboardHeader(title = "Cybersecurity Attacks"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("World Map", tabName = "map", icon = icon("globe"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "map",
        box(
          width = 12,
          leafletOutput(
            "worldmap",
            height = "90vh"
          ),
        ),
      )
    )
  )
)
server <- function(input, output) {
  output$worldmap <- renderLeaflet({
    world_map
  })
}

shinyApp(ui, server)
