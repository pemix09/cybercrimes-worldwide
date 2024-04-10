library(geojsonio)
library(leaflet)
library(RColorBrewer)
library(dplyr)
source("data.R")

world_spdf <- geojson_read("world.geojson", what = "sp")

mytext <- paste(
  "Country: ", world_spdf@data$name_pl, "<br/>",
  "ISO: ", world_spdf@data$adm0_iso, "<br/>",
  "Registered attacks per country: ", attacks_sorted_like_map$Destination_count , "<br/>",
  sep = ""
) %>%
  lapply(htmltools::HTML)

# # Basic choropleth with leaflet?
target_world_map <- leaflet(
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
    fillColor = ~ mypalette(attacks_sorted_like_map$Destination_count),
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
  addLegend(pal = mypalette, values = ~pop_est, opacity = 0.9, title = "Number of incidents", position = "bottomleft")