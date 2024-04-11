library(geojsonio)
library(leaflet)
library(RColorBrewer)
library(dplyr)
source("data.R")

world_spdf <- geojson_read("world.geojson", what = "sp")

color_pal <- colorNumeric(  palette = "inferno", average_payload_lengths_per_country_sorted_like_map$Payload_length)


mytext <- paste(
  "Country: ", world_spdf@data$name_pl, "<br/>",
  "ISO: ", world_spdf@data$adm0_iso, "<br/>",
  "Average payload length: ", average_payload_lengths_per_country_sorted_like_map$Payload_length , "<br/>",
  sep = ""
) %>%
  lapply(htmltools::HTML)

# # Basic choropleth with leaflet?
payload_length_world_map <- leaflet(
  world_spdf,
  options = leafletOptions(
    zoomControl = TRUE,
    zoomSnap = 0.05,
    zoomDelta = 0.5,
    minZoom = 2.9,
    maxZoom = 10
  )
) %>%
  addProviderTiles("CartoDB.PositronNoLabels",
                   options = providerTileOptions(
                     noWrap = TRUE
                   )
  ) %>%
  setMaxBounds(-180, -70, 180, 90) %>%
  setView(lng = 0, lat = 20, zoom = 2.9) %>%
  addPolygons(
    fillColor = ~ color_pal(average_payload_lengths_per_country_sorted_like_map$Payload_length),
    stroke = TRUE,
    fillOpacity = 0.9,
    color = "white",
    weight = 0.3,
    label = mytext,
    layerId = ~woe_id_eh,
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "13px",
      direction = "auto"
    )
  ) %>%
  addLegend(pal = color_pal , values = ~average_payload_lengths_per_country_sorted_like_map$Payload_length, opacity = 0.9, title = "Averege payload length", position = "bottomleft")

