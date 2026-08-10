healthboard_oi <- "NHS Ayrshire and Arran"

# 0. Load Packages ----

library(dplyr)
library(janitor)
library(leaflet)
library(stringr)
library(sf)
library(phsmethods)
library(phslookups)

# 1. Load Scottish Postcode Directory ----
# This gets all postcodes in Scotland + associated HB, HSCP + postcodes centroid (midpoint)

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
  mutate(pc8 = format_postcode(pc8, format = "pc8"))

# 2. Load Scottish Postcode Shapefiles ----

postcode_sf <- list.files(
  "/conf/linkage/output/lookups/Unicode/Geography/Shapefiles",
  pattern = "PC_Cut_\\d{2}_\\d$",
  full.names = TRUE
) %>%
  sort(decreasing = TRUE) %>%
  .[1] %>%
  read_sf() %>%
  clean_names()

# In these "postcode" shapefiles, some postcodes have actually been split into parts
# Some are in the form of a normal postcode plus a letter, e.g. postcode is G744JF, but it's been split into G744JFA + G744JFB
# These parts have to be combined to get the actual shapes of the postcodes
# + to be able to attach on the SPD

postcode_sf <- postcode_sf %>%
  mutate(
    true_postcode = mapply(
      FUN = function(a, b) {
        gsub(a, "", b, fixed = TRUE)
      },
      sector,
      postcode
    )
  ) %>%
  mutate(
    true_postcode = case_when(
      nchar(true_postcode) == 2 ~ postcode,
      nchar(true_postcode) != 2 ~ substr(postcode, 1, nchar(postcode) - 1)
    )
  )

split_postcodes_sf <- postcode_sf %>%
  filter(postcode != true_postcode) %>%
  summarise(
    # This function takes the Postcodes and combines them all by HSCP
    geometry = st_union(geometry),
    .by = "true_postcode"
  ) %>%
  rename(postcode = true_postcode)


non_split_postcodes_sf <- postcode_sf %>%
  filter(postcode == true_postcode) %>%
  select(postcode)


postcode_sf <- non_split_postcodes_sf %>%
  bind_rows(split_postcodes_sf)

# 3. Attach SPD To Shapefiles ----

postcode_sf <- postcode_sf %>%
  mutate(postcode = format_postcode(postcode, format = "pc8")) %>%
  left_join(
    spd_lookup,
    by = join_by(postcode == pc8),
    relationship = "one-to-one"
  ) %>%
  select(
    hb2019,
    hb2019name,
    hscp2019,
    hscp2019name,
    postcode,
    geometry
  )


# 3. Group Up Postcodes Into HSCPs -----

hscp_sf <- postcode_sf %>%
  filter(hb2019name == healthboard_oi) %>%
  summarise(
    # This function takes the Postcodes and combines them all by HSCP
    geometry = st_union(geometry),
    .by = c("hb2019", "hb2019name", "hscp2019", "hscp2019name")
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
  domain = sort(unique(hscp_sf$hscp2019name))
)


# 5. Create Map ----

leaflet() %>%
  addTiles() %>%
  addPolygons(
    data = hscp_sf,
    popup = ~ paste(hscp2019name, "HSCP Approximation (Using Postcodes)"),
    fillColor = ~ pal(hscp2019name),
    color = ~ pal(hscp2019name),
    fillOpacity = 0.3,
  ) %>%
  addLegend(
    data = hscp_sf,
    pal = pal,
    values = ~hscp2019name,
    position = "bottomleft",
    title = "HSCP Name:",
    opacity = 0.9
  )
