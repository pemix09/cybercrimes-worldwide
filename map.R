library(geojsonio)
library(leaflet)
library(RColorBrewer)
library(dplyr)
source("data.R")

world_spdf <- geojson_read("world.geojson", what = "sp")

world_spdf <- sp::merge(world_spdf, attacks_per_country, by.x = "iso_a2", by.y = "Country")
world_spdf <- sp::merge(world_spdf, anomaly_scores_average_per_country, by.x = "iso_a2", by.y = "Country")
world_spdf <- sp::merge(world_spdf, average_payload_lengths_per_country, by.x = "iso_a2", by.y = "Country")

countries_coords <- world_spdf@data %>%
  select(iso_a2, longitude = label_x, latitude = label_y)

world_map <- leaflet(
  world_spdf,
  options = leafletOptions(
    zoomControl = TRUE,
    zoomSnap = 0.05,
    zoomDelta = 0.5,
    minZoom = 2,
    maxZoom = 10
  )
) %>%
  addProviderTiles("CartoDB.PositronNoLabels",
    options = providerTileOptions(
      noWrap = TRUE
    )
  ) %>%
  setMaxBounds(-180, -70, 180, 90) %>%
  setView(lng = 0, lat = 20, zoom = 2) %>%
  addScaleBar(position = "bottomleft")

