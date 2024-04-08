data <- read.csv("cybersecurity_attacks.csv")

library(geojsonio)
world_spdf <- geojson_read("world.geojson", what = "sp")

library(RColorBrewer)
mybins <- c(0, 10, 20, 50, 100, 500, 1000, Inf)

world_spdf@data$pop_est[which(world_spdf@data$pop_est == 0)] <- NA
world_spdf@data$pop_est <- as.numeric(as.character(world_spdf@data$pop_est)) / 1000000 %>% round(2)

mypalette <- colorBin(palette = "Blues", domain = world_spdf@data$pop_est, na.color = "transparent", bins = mybins)

mytext <- paste(
  "Country: ", world_spdf@data$name_pl, "<br/>",
  "ISO: ", world_spdf@data$adm0_iso, "<br/>",
  "Population: ", world_spdf@data$pop_est, "<br/>",
  sep = ""
) %>%
  lapply(htmltools::HTML)

library(leaflet)
# # Basic choropleth with leaflet?
world_map <- leaflet(
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
    fillColor = ~ mypalette(pop_est),
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
  addLegend(pal = mypalette, values = ~pop_est, opacity = 0.9, title = "Area", position = "bottomleft")