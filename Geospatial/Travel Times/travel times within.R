# needed for managing travel times data
library(tidyverse)
library(sf)
library(osrm)
library(sfheaders)

# Needed for reading in data
library(arrow)

# Needed for producing map
library(leaflet)

# Load in travel times functions - change the filepath to wherever you have saved the file travel times functions.R
source("Geospatial/Travel Times/travel times functions.R")

# Pick a Locality - this can be changed to whichever locality is needed
locality <- "North Perthshire"

# Read in the locality shapefile
shapefiles_folder <- file.path("/conf/linkage/output/lookups/Unicode/Geography/Shapefiles")
locality_shp <- read_sf(file.path(shapefiles_folder, "HSCP Locality (Datazone2011 Base)", "HSCP_Locality.shp")) %>% 
  # converts the shapefile to use latitude and longitude
  st_transform(4326) %>%  # EPSG4326
  rename(hscp_locality = hscp_local) %>% 
  # filter out appropriate locality
  filter(hscp_locality == locality)

# Get locality data
localities <- read_rds(file.path("/conf/linkage/output/lookups/Unicode/Geography",
                                 "HSCP Locality/HSCP Localities_DZ11_Lookup_20230804.rds")) %>%
  # Choose the required columns
  select(datazone2011, hscp_locality)

# Get GP Practices and filter to those in the locality
gp_practices <- read_parquet("/conf/linkage/output/lookups/Unicode/Geography/Scottish Postcode Directory/Scottish_Postcode_Directory_2023_2.parquet",
                             col_select = c(pc7, latitude, longitude, datazone2011)) %>% 
  left_join(localities, by = join_by(datazone2011)) %>% 
  filter(hscp_locality == locality) %>% 
  left_join(read_csv(file.path("/conf/linkage/output/lookups/Unicode/National Reference Files/gpprac.csv")),
            by = join_by(pc7 == postcode))  %>% 
  drop_na(praccode)

# Get locations to test 
# For the purposes of this I'm using a random selection of postcodes from within the locality
# In practice you would likely have this already (e.g. list of postcodes for patients within a practice)
patients <- read_parquet("/conf/linkage/output/lookups/Unicode/Geography/Scottish Postcode Directory/Scottish_Postcode_Directory_2023_2.parquet",
                         col_select = c(pc7, latitude, longitude, datazone2011)) %>% 
  left_join(localities, by = join_by(datazone2011)) %>% 
  filter(hscp_locality == locality) %>% 
  sample_n(300) # random sample of 300 postcodes within locality (postcodes sampled will change each time this runs)


# use get_travel_areas() to obtain travel areas for 10 minute drive - this time not bothered about within_region
car <- get_travel_areas(gp_practices$longitude, gp_practices$latitude, travel_time = 10, travel_method = "car")

# use get_locations_within() to obtain a list of the postcodes within 10 minute drive of a GP practice
within_10min_drive <- get_locations_within(patients, car)

# Plot to check result (but not needed in general)
locality_shp  %>% 
  leaflet() %>%
  addProviderTiles(provider = providers[["OpenStreetMap"]]) %>%
  # Locality
  addPolygons(color = "grey",weight = 1,smoothFactor = 0.001) %>%
  # Within 10 minutes drive
  addPolygons(data = car, color = "red") %>%
  # Markers for people within 10 minute drive (all are within the driveable areas)
  addCircleMarkers(data = within_10min_drive, radius = 1, color = "blue", opacity = 1)

# compare this to all selected postcodes:
locality_shp %>%
  leaflet() %>%
  addProviderTiles(provider = providers[["OpenStreetMap"]]) %>%
  # Locality
  addPolygons(color = "grey",weight = 1,smoothFactor = 0.001) %>%
  # areas within 10 minutes drive
  addPolygons(data = car, color = "red") %>%
  # All patients
  addCircleMarkers(data = patients, radius = 1, color = "blue", opacity = 1)
