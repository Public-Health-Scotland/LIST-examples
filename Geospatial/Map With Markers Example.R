healthboard_oi <- "NHS Greater Glasgow and Clyde"

# 0. Load Packages ----

library(dplyr)
library(phsopendata)
library(rvest) # Web scraping
library(ckanr) # Web scraping
library(janitor)
library(leaflet)
library(phslookups)
library(phsmethods)

# 1. Load Scottish Postcode Directory ----
# This gets all postcodes in Scotland + associated HB, HSCP + postcodes centroid (midpoint)
# These Postcode Centroids are what we will use to plot our GP Practices

spd_lookup <- get_spd(
  col_select = c(
    hb2019,
    hb2019name,
    hscp2019,
    hscp2019name,
    pc8,
    latitude,
    longitude
  )
) %>%
  distinct() %>%
  mutate(pc8 = format_postcode(pc8, format = "pc8")) # need to format so all data and lookups match


# 2. Load GP Practice Data ----

gp_practice_data <- get_latest_resource(
  "gp-practice-contact-details-and-list-sizes"
) %>%
  clean_names() %>%
  mutate(practice_code = as.character(practice_code)) %>%
  mutate(location_type = "GP Practice")

# 3. Attach SPD Info To GP Practice Data ----
# After this step we have a dataset of GP Practices + their associated postcode centroids which we will use for plotting

gp_practice_data <- gp_practice_data %>%
  mutate(postcode = format_postcode(postcode, format = "pc8")) %>% # need to format so all data and lookups match
  left_join(spd_lookup, by = c("postcode" = "pc8")) %>% # Attach information about practice postcode
  select(
    location_type,
    hb2019,
    hb2019name,
    hscp2019,
    hscp2019name,
    location_code = practice_code,
    location_name = gp_practice_name,
    postcode,
    latitude,
    longitude
  )


# 3. Pull Accident And Emergency Locations ----

accident_and_emergency_data <- get_dataset(
  "nhs-scotland-accident-emergency-sites"
) %>%
  clean_names() %>%
  filter(status == "Open") %>%
  mutate(treatment_location_code = as.character(treatment_location_code)) %>%
  mutate(location_type = "Emergency Department")


# 3. Attach SPD Info To A + E Data ----
# After this step we have a dataset of A + E locations + their associated postcode centroids which we will use for plotting

accident_and_emergency_data <- accident_and_emergency_data %>%
  mutate(
    treatment_location_postcode = format_postcode(
      treatment_location_postcode,
      format = "pc8"
    )
  ) %>%
  left_join(spd_lookup, by = c("treatment_location_postcode" = "pc8")) %>% # Attach on information about hospital postcode
  select(
    location_type,
    hb2019,
    hb2019name,
    hscp2019,
    hscp2019name,
    location_code = treatment_location_code,
    location_name = treatment_location_name,
    postcode = treatment_location_postcode,
    latitude,
    longitude
  )


# 3. Combine GP Data & A + E Data and Filter For Healthboard Of Interest ----

location_data <- gp_practice_data %>%
  bind_rows(accident_and_emergency_data) %>%
  filter(hb2019name == healthboard_oi)


# 4. Create Logos For The Different Services On The Map ----

logos <- awesomeIconList(
  "Emergency Department" = makeAwesomeIcon(
    icon = "glyphicon-header",
    markerColor = "darkred"
  ),
  "GP Practice" = makeAwesomeIcon(
    icon = "glyphicon-user",
    markerColor = "green"
  )
)

# 4. Specify the Colours For The Legend ----

pal <- colorFactor(
  palette = c("darkred", "#6ea728"),
  domain = c("Emergency Department", "GP Practice")
)


# 5. Create Map ----

leaflet() %>%
  addTiles() %>%
  addAwesomeMarkers(
    data = location_data,
    lng = ~longitude,
    lat = ~latitude,
    icon = ~ logos[location_type],
    group = ~location_type,
    popup = ~location_name
  ) %>%
  addLayersControl(
    position = "topright",
    overlayGroups = unique(location_data$location_type),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  addLegend(
    data = location_data,
    position = "bottomleft",
    title = "Site Type",
    pal = pal,
    values = ~location_type
  )
