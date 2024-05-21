# needed for managing travel times data
library(tidyverse)
library(sf)
library(osrm)
library(sfheaders)

# Needed for reading in data
library(arrow)

# Needed for producing map
library(leaflet)
library(glue)

# Load in travel times functions - change the filepath to wherever you have saved the file travel times functions.R
source("Geospatial/Travel Times/travel times functions.R")

# Pick a Locality - this can be changed to whichever locality is needed
locality <- "Kilmarnock"

lookups_folder <- file.path("/conf/linkage/output/lookups/Unicode")

# Read in the locality shapefile
shapefiles_folder <- file.path(lookups_folder, "Geography/Shapefiles")
locality_shp <- read_sf(file.path(shapefiles_folder, "HSCP Locality (Datazone2011 Base)", "HSCP_Locality.shp")) %>% 
  # converts the shapefile to use latitude and longitude
  st_transform(4326) %>%  # EPSG4326
  rename(hscp_locality = hscp_local) %>% 
  # filter out appropriate locality
  filter(hscp_locality == locality)

# Get locality data
localities <- read_rds(file.path(lookups_folder, "Geography","HSCP Locality/HSCP Localities_DZ11_Lookup_20230804.rds")) %>% 
  # Choose the required columns
  select(datazone2011, hscp_locality)

# Get GP Practices and filter to those in the locality
gp_practices <- read_parquet(file.path(lookups_folder, "Geography/Scottish Postcode Directory/Scottish_Postcode_Directory_2023_2.parquet"),
                             col_select = c(pc7, latitude, longitude, datazone2011)) %>% 
  left_join(localities, by = join_by(datazone2011)) %>% 
  filter(hscp_locality == locality) %>% 
  left_join(read_csv(file.path(lookups_folder, "National Reference Files/gpprac.csv")),
            by = join_by(pc7 == postcode))  %>% 
  drop_na(praccode)

# use get_travel_areas() to obtain travel areas for car, bike and foot
# using within_region to restrict to locality only - within_region can be omitted 
# completely if you don't want to restrict
car  <- get_travel_areas(gp_practices$longitude, gp_practices$latitude, travel_time = 10, travel_method = "car", within_region = locality_shp)
bike <- get_travel_areas(gp_practices$longitude, gp_practices$latitude, travel_time = 10, travel_method = "bike", within_region = locality_shp)
foot <- get_travel_areas(gp_practices$longitude, gp_practices$latitude, travel_time = 10, travel_method = "foot", within_region = locality_shp)

# plot map
locality_shp %>% 
  leaflet() %>% 
  addProviderTiles(provider = providers[["OpenStreetMap"]]) %>% 
  # add locality boundary
  addPolygons(color = "grey", weight = 1, smoothFactor = 0.001) %>% 
  # within 10 minutes drive area
  addPolygons(data = car, color = "red", weight = 0.5) %>% 
  # within 10 minutes cycle area
  addPolygons(data = bike,  color = "blue", weight = 0.5) %>% 
  # within 10 minutes walk area
  addPolygons(data = foot,  color = "green", weight = 0.5) %>% 
  # GP Practice markers
  addAwesomeMarkers(
    data = gp_practices,
    popup = ~ glue(
      "Practice: {`add 1`} ({praccode})<br>",
      "Postcode: {pc7}<br>",
      "Latitude: {latitude}, Longitude: {longitude}"
    )
  )
