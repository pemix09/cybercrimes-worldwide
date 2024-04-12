# if (!require(shiny)) install.packages("shiny", repos = "http://cran.us.r-project.org")
# if (!require(shinydashboard)) install.packages("shinydashboard", repos = "http://cran.us.r-project.org")
# if (!require(leaflet)) install.packages("leaflet", repos = "http://cran.us.r-project.org")
# if (!require(geojsonio)) install.packages("geojsonio", repos = "http://cran.us.r-project.org")
# if (!require(RColorBrewer)) install.packages("RColorBrewer", repos = "http://cran.us.r-project.org")
library(shiny)
library(shinydashboard)
library(leaflet)
library(geojsonio)
library(RColorBrewer)

source("map.R")

ui <- navbarPage(
  title = "Cybersecurity Attacks",
  tabPanel("World Map",
    sidebarLayout(
      sidebarPanel(
        selectInput("datatype", "Data Type", choices = c("Target Count", "Source Count", "Anomaly Score", "Payload length")),
        checkboxInput("circles", "Show Circles", TRUE),
        checkboxInput("legend", "Show legend", TRUE)
      ),
      mainPanel(
        box(
          width = 12,
          leafletOutput(
            "map",
            height = "90vh"
          )
        )
      )
    ),
    icon = icon("globe"),
  )
)
server <- function(input, output) {
  chosenData <- reactive({
    if (input$datatype == "Target Count") {
      world_spdf$Destination_count
    } else if (input$datatype == "Source Count") {
      world_spdf$Source_count
    } else if (input$datatype == "Anomaly Score") {
      world_spdf$Payload_length
    } else if (input$datatype == "Payload length") {
      world_spdf$Average_score
    }
  })

  colorpal <- reactive({
    bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
    colorBin("Blues", domain = chosenData(), bins = bins)
  })
  maptext <- reactive({
    paste(
      "Country: ", world_spdf$name_pl, "<br/>",
      "ISO: ", world_spdf$adm0_iso, "<br/>",
      paste(input$datatype, ": "), chosenData(), "<br/>",
      sep = ""
    ) %>%
      lapply(htmltools::HTML)
  })
  output$map <- renderLeaflet({
    world_map
  })

  observe({
    pal <- colorpal()
    leafletProxy("map", data = world_spdf) %>%
      clearShapes() %>%
      addPolygons(
        fillColor = ~ pal(chosenData()),
        stroke = TRUE,
        fillOpacity = 0.9,
        color = "white",
        weight = 0.3,
        label = ~ maptext(),
        layerId = ~woe_id_eh,
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "13px",
          direction = "auto"
        )
      )
  })

  observe({
    proxy <- leafletProxy("map", data = world_spdf)
    proxy %>% clearControls()
    if (input$legend) {
      pal <- colorpal()
      proxy %>% addLegend(
        position = "bottomleft",
        pal = pal,
        values = ~ chosenData(),
        title = input$datatype,
        opacity = 0.9,
      )
    }
  })
  observeEvent(input$map_shape_click, {
    click <- input$map_shape_click
    if (is.null(click))
      return()
    print(click)
  
  })
  # observe({
  #   proxy <- leafletProxy("map", data = world_spdf)
  #   proxy %>% clearMarkers()
  #   if (input$circles) {
  #     pal <- colorpal()
  #     proxy %>% addCircles(
  #       lng = ~world_spdf@polygons[[1]]@labpt[1],
  #       lat = ~world_spdf@polygons[[1]]@labpt[2],
  #       radius = chosenData() / 100,
  #       fillColor = ~ pal(chosenData()),
  #       weight = 1,
  #       stroke = FALSE,
  #       fillOpacity = 0.6
  #     )
  #   }
  # })
}

shinyApp(ui, server)
