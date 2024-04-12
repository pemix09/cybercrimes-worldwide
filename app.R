library(shiny)
library(shinydashboard)
library(leaflet)
library(geojsonio)
library(RColorBrewer)
library(ggplot2)
library(dplyr)
library(geosphere)

source("map.R")

# Definicja UI
ui <- navbarPage(
  title = "Cybersecurity Attacks",
  tabPanel("World Map",
    sidebarLayout(
      sidebarPanel(
        selectInput("datatype", "Data Type", choices = c("Target Count", "Source Count", "Anomaly Score", "Payload length")),
        checkboxInput("legend", "Show legend", TRUE),
        actionButton("clear_markers", "Clear Markers")
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
  ),
  tabPanel(
    "Charts",
    fluidRow(
      box(
        title = "Attack Type",
        status = "primary",
        plotOutput("attack_type_pie")
      ),
      box(
        title = "Action Taken",
        status = "primary",
        plotOutput("action_taken_pie")
      ),
      box(
        title = "Attack Distribution Over Time",
        status = "primary",
        plotOutput("attack_time_line")
      ),
      box(
        title = "Countries with Same Source and Destination",
        status = "primary",
        plotOutput("same_source_dest_pie")
      ),
      box(
        title = "Packet Type",
        status = "primary",
        plotOutput("packet_type_pie")
      ),
      box(
        title = "Traffic Type",
        status = "primary",
        plotOutput("traffic_type_pie")
      )
    ),
    icon = icon("chart-simple")
  )
)

# Definicja server
server <- function(input, output) {
  # Wczytanie danych do mapy
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

  # Funkcja generująca paletę kolorów
  colorpal <- reactive({
    bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
    colorBin("Blues", domain = chosenData(), bins = bins)
  })

  # Tekst do wyświetlenia na mapie
  maptext <- reactive({
    paste(
      "Country: ", world_spdf$name_pl, "<br/>",
      "ISO: ", world_spdf$adm0_iso, "<br/>",
      paste(input$datatype, ": "), chosenData(), "<br/>",
      sep = ""
    ) %>%
      lapply(htmltools::HTML)
  })

  # Renderowanie mapy
  output$map <- renderLeaflet({
    world_map
  })

  # Aktualizacja mapy
  observe({
    pal <- colorpal()
    leafletProxy("map", data = world_spdf) %>%
      clearShapes() %>%
      clearMarkers() %>%
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

  # Dodawanie legendy
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

  # Czyszczenie markerów
  observeEvent(input$clear_markers, {
    leafletProxy("map") %>%
      clearMarkers()
  })

  # Skąd ataki na wybrany kraj
  observeEvent(input$map_shape_click, {
    if (input$datatype != "Target Count") {
      return()
    }
    click <- input$map_shape_click
    country <- world_spdf[world_spdf$woe_id_eh == click$id, ]

    attacking_countries <- data[data$Destination.Country == country$iso_a2, ] %>%
      select(Source.Country) %>%
      distinct() %>%
      rename(iso_a2 = Source.Country)
    attacking_countries <- left_join(attacking_countries, countries_coords, by = "iso_a2")

    proxy <- leafletProxy("map", data = world_spdf) %>%
      clearMarkers() %>%
      addCircleMarkers(
        data = attacking_countries,
        lat = ~latitude,
        lng = ~longitude,
        radius = 5,
        color = "red",
        fill = TRUE,
        fillOpacity = 0.7,
        label = ~ paste(iso_a2),
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "13px",
          direction = "auto"
        )
      )
  })

  # Wykres z typem ataków
  output$attack_type_pie <- renderPlot({
    pie(table(data$Attack.Type))
  })

  # Wykres z typem podjętej akcji
  output$action_taken_pie <- renderPlot({
    pie(table(data$Action.Taken))
  })

  # Wykres z typem pakietów
  output$packet_type_pie <- renderPlot({
    pie(table(data$Packet.Type))
  })
  # Wykres z typem ruchu
  output$traffic_type_pie <- renderPlot({
    pie(table(data$Traffic.Type))
  })

  # Wykres liniowy z rozkładem ataków w czasie
  output$attack_time_line <- renderPlot({
    data$Timestamp <- as.Date(data$Timestamp)
    data$Timestamp <- format(data$Timestamp, "%Y-%m")
    data_attackTime <- data.frame(table(data$Timestamp))
    data_attackTime$Var1 <- as.Date(paste(data_attackTime$Var1, "-01", sep = ""),
      format = "%Y-%m-%d"
    )

    ggplot(data_attackTime, aes(x = Var1, y = Freq)) +
      geom_point(size = 1) +
      geom_line() +
      labs(x = "Czas", y = "Ilość ataków") +
      theme_minimal()
  })

  # Procent krajów, w których source = destination
  output$same_source_dest_pie <- renderPlot({
    data <- mutate(data, is.same = Destination.Country == Source.Country)
    pie(table(data$is.same))
  })
}

# Uruchomienie aplikacji Shiny
shinyApp(ui, server)
