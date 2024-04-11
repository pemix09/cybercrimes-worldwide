library(shiny)
library(shinydashboard)
library(leaflet)
library(geojsonio)
library(RColorBrewer)

source("source_map.R")
source("target_map.R")
source("anomaly_score_map.R")
source("payload_length_map.R")

ui <- dashboardPage(
  dashboardHeader(title = "Cybersecurity Attacks"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Target of cybercrimes worldwide", tabName = "target-map", icon = icon("bullseye")),
      menuItem("Sources of cybercrimes worldwide", tabName = "source-map", icon = icon("play")),
      menuItem("Avarage payload lengths", tabName = "payload-length-map", icon = icon("database")),
      menuItem("Anomaly scores per country", tabName = "anomaly-score-map", icon = icon("snowflake"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "target-map",
        box(
          width = 12,
          leafletOutput(
            "target_worldmap",
            height = "90vh"
          ),
        ),
      ),
      tabItem(
        tabName = "source-map",
        box(
          width = 12,
          leafletOutput(
            "source_wordlmap",
            height = "90vh"
          ),
        ),
      ),
      tabItem(
        tabName = "payload-length-map",
        box(
          width = 12,
          leafletOutput(
            "payload_length_wordlmap",
            height = "90vh"
          ),
        ),
      ),
      tabItem(
        tabName = "anomaly-score-map",
        box(
          width = 12,
          leafletOutput(
            "anomaly_score_wordlmap",
            height = "90vh"
          ),
        ),
      ) 
    )
  )
)
server <- function(input, output) {
  output$target_worldmap <- renderLeaflet({
    target_world_map
  })
  output$source_wordlmap <- renderLeaflet({
    source_world_map
  })
  output$payload_length_wordlmap <- renderLeaflet({
    payload_length_world_map
  })
  output$anomaly_score_wordlmap <- renderLeaflet({
    anomaly_score_world_map
  })
}

shinyApp(ui, server)
