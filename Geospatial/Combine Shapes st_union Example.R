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

# In these "postcode" shapefiles some postcodes have actually been split into parts
# Some are in the form of a nromal postcode plues a letter e.g. o.g. postcode is G744JF but its been split into G744JFA + G744JFB
# These parts have to be combined in order to get the actual shapes of the postcodes
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
    # This function takes the Postcodes and combines them all together by HSCP
    geometry = st_union(geometry),
    .by = c("true_postcode")
  ) %>%
  rename(postcode = true_postcode)


non_split_postcodes_sf <- postcode_sf %>%
  filter(postcode == true_postcode) %>%
  dplyr::select(postcode)


postcode_sf <- non_split_postcodes_sf %>%
  bind_rows(split_postcodes_sf)

# 3. Attach SPD To Shapefiles ----

postcode_sf <- postcode_sf %>%
  mutate(postcode = format_postcode(postcode, format = "pc8")) %>%
  left_join(
    spd_lookup,
    by = c("postcode" = "pc8"),
    relationship = "one-to-one"
  ) %>%
  dplyr::select(
    hb2019,
    hb2019name,
    hscp2019,
    hscp2019name,
    postcode,
    geometry
  )


# 3. Filter For Postcodes Of Interest + Convert To Correct Coordinates -----

postcode_sf <- postcode_sf %>%
  filter(hb2019name == healthboard_oi) %>%
  st_transform(4326)


# 4. Create Map ----

leaflet() %>%
  addTiles() %>%
  addPolygons(
    data = postcode_sf,
    popup = ~ paste(postcode),
    color = "blue",
    fillOpacity = 0,
  )
