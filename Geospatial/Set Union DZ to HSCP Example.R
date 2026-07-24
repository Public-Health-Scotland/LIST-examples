healthboard_oi <- "NHS Lothian"

# 0. Load Packages ----

library(dplyr)
library(phsopendata)
library(rvest) # Web scraping
library(ckanr) # Web scraping
library(janitor)
library(leaflet)
library(stringr)
library(sf)

# 1. Load Scottish Postcode Directory ----
# This is a list of all postcodes in Scotland + associated HB, HSCP etc.
# We only want HSCPs + Datazones so we get a Datazone to HSCP Lookup

dz_hscp_lookup <- phslookups::get_spd(col_select = c(
  "hb2019", "hb2019name",
  "hscp2019", "hscp2019name",
  "datazone2022", "datazone2022name"
)) %>%
  distinct()

# 2. Load Scottish Datazone Shapefiles ----

datazone2022_sf <- read_sf("/conf/linkage/output/lookups/Unicode/Geography/Shapefiles/Data Zone Boundaries 2022") %>%
  clean_names() %>%
  dplyr::select(datazone2022 = dzcode)

# 3. Attach Datazone to HSCP Lookup ----

datazone2022_sf <- datazone2022_sf %>%
  left_join(dz_hscp_lookup, by = "datazone2022") %>%
  dplyr::select(
    hb2019,
    hb2019name,
    hscp2019,
    hscp2019name,
    datazone2022,
    datazone2022name,
    geometry
  )

# 3. Group Up Postcodes Into HSCPs -----

hscp2019_sf <- datazone2022_sf %>%
  filter(hb2019name == healthboard_oi) %>%
  summarise(
    # This function takes the Postcodes and combines them all together by HSCP
    geometry = st_union(geometry),
    .by = c("hscp2019", "hscp2019name")
  ) %>%
  st_transform(4326)


# 4. Define Palette Colours ----

pal <- colorFactor(
  palette = c(
    "#006d77",
    "#3e7730",
    "#ff3b75",
    "#1d568e",
    "#31A845",
    "#AA3EBD"
  ),
  domain = sort(unique(hscp2019_sf$hscp2019name))
)


# 5. Create Map ----

leaflet() %>%
  # Add Base Map
  addTiles() %>%
  # Add HSCP Boundaries to Map
  addPolygons(
    data = hscp2019_sf,
    popup = ~ paste(hscp2019name, "HSCP Approximation (Using Postcodes)"),
    fillColor = ~ pal(hscp2019name),
    color = ~ pal(hscp2019name),
    fillOpacity = 0.3,
  ) %>%
  # Add Legend To Map
  addLegend(
    data = hscp2019_sf,
    pal = pal,
    values = ~hscp2019name,
    position = "bottomleft",
    title = "HSCP Name:",
    opacity = 0.9
  )
