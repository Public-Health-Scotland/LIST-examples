
# get_travel_areas - Function to obtain the area that is travellable from location (longitude, latitude) within
#                    a specified travel_time using a particular travel_method.
# - longitude     - vector of longitudes of locations being travelled from
# - latitude      - vector of latitudes of locations being travelled from
# - travel_time   - Travel time of interest in minutes. Recommend that this be no less than 10
# - travel_method - Method of travel. One of "car", "bike", or "foot"
# - within_region - Optional region that the travel area should remain within. object of class sf

get_travel_areas <- function(longitude, latitude, travel_time, travel_method = "car", within_region = NULL){
  # Get travel areas
  iso <- purrr::map2(longitude, latitude, # Iterate over each point (slow)
    \(x, y) get_iso(x, y, travel_time, travel_method)
  )
  
  # remove empty areas - generally happens when travel time is set < 10
  iso <- iso[sapply(iso, nrow) != 0]
  
  # Combine into a single area to make plotting easier  
  iso <- suppressWarnings(purrr::reduce(iso, \(x, y) st_make_valid(x) %>% st_union(y)))
  
  # Remove odd small regions
  if(inherits(iso$geometry[[1]], "sfc_MULTIPOLYGON")){
    st_geometry(iso) <- st_sfc(st_multipolygon(iso$geometry[[1]][sapply(iso$geometry[[1]], function(x) nrow(x[[1]])) > 5]), crs = 4326)# Add the polygons together to make mapping simpler
  }
  
  # If a region is supplied for within_region....
  if(!is.null(within_region)){
    iso <- iso %>% 
      suppressWarnings(st_intersection(locality_shp)) # ....remove any bits which have gone outside the locality
  }
  
  # Return final object
  iso %>% sf_remove_holes()
}

# get_locations_within - function to extract a subset of locations that lie within a travel time
# locations - data frame containing columns latitude and longitude
# iso       - sf object. Intended to be output from get_travel_areas.
get_locations_within <- function(locations, iso){
  # Detect lat and long columns - does partial matching - note colname has to start with lat or lon
  long_col <- names(locations)[str_detect(names(locations), "^[lL]on")]
  lat_col <- names(locations)[str_detect(names(locations), "^[lL]at")]
  
  # Notify user which columns are being taken as long and lat
  message(paste0('Assuming "', long_col, '" and "', lat_col, '" are longitude and latitude respectively.'))
  
  # convert locations to an sf object to allow comparison with iso region
  points <- st_as_sf(locations, coords = c(long_col, lat_col), crs = st_crs(4326)) 
  
  # length of elements returned will be 1 if point lies within region and 0 otherwise
  within_ind <- sapply(st_intersects(points, iso), length)
  
  # Return appropriate locations
  locations[within_ind == 1, ]
}

# get_iso - function to be used within get_travel_times
get_iso <- function(lon, lat, travel_time, travel_method) {
  Sys.sleep(1) # Sleep to keep within the API usage limits
  osrmIsochrone(
    loc = c(lon, lat),
    breaks = travel_time, # Number of minutes travel time
    res = 10, # The resolution i.e. check res*res points. More points == Slow.
    osrm.profile = travel_method # Car/foot/bike
  ) %>% 
    st_make_valid()
}
