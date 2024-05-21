# get_travel_areas - Function to obtain the area that is travellable from location (longitude, latitude) within
#                    a specified travel_time using a particular travel_method.
# - longitude     - vector of longitudes of locations being travelled from
# - latitude      - vector of latitudes of locations being travelled from
# - travel_time   - Travel time of interest in minutes. Recommend that this be no less than 10
# - travel_method - Method of travel. One of "car", "bike", or "foot"
# - within_region - Optional region that the travel area should remain within. object of class sf

get_travel_areas <- function(longitude, latitude, travel_time, travel_method = c("car", "bike", "foot"), within_region = NULL) {
  travel_method <- rlang::arg_match(travel_method)

  if (length(latitude) > 10) {
    cli::cli_inform("This process may take a bit of time.")
  }
  # Get travel areas
  iso <- purrr::map2(
    longitude, latitude, # Iterate over each point (slow)
    \(x, y) get_iso(x, y, travel_time, travel_method),
    .progress = "Calculating travel times"
  )

  # remove empty areas - generally happens when travel time is set < 10
  iso <- iso[purrr::map_int(iso, nrow) != 0]

  # Combine into a single area to make plotting easier
  # suppress warnings related to assumptions being made about spatial attributes
  # there is one wanring for each area merged which isn't relevant as all areas are generated using the same crs
  iso <- suppressWarnings(purrr::reduce(iso, \(x, y) st_union(st_make_valid(x), y)))

  # Remove odd small regions
  # [[1]] subsetting needed as the geometry column is a list with one entry because of st_union()
  if (inherits(iso$geometry, "sfc_MULTIPOLYGON")) {
    iso_geometry <- unlist(iso$geometry, recursive = FALSE)
    small_area <- purrr::map_lgl(unlist(iso_geometry, recursive = FALSE), \(x) nrow(x) <= 5)
    st_geometry(iso) <- st_sfc(st_multipolygon(iso_geometry[!small_area]), crs = 4326) # Add the polygons together to make mapping simpler
  }

  # If a region is supplied for within_region....
  if (!is.null(within_region)) {
    iso <- st_intersection(iso, locality_shp) # ....remove any bits which have gone outside the locality
  }

  # Return final object
  sfheaders::sf_remove_holes(iso)
}

# get_locations_within - function to extract a subset of locations that lie within a travel time
# locations - data frame containing columns latitude and longitude
# iso       - sf object. Intended to be output from get_travel_areas.
get_locations_within <- function(locations, iso) {
  # Detect lat and long columns - does partial matching - note colname has to start with lat or lon
  long_col <- stringr::str_subset(names(locations), stringr::regex("^long(:?itude)?$", ignore_case = TRUE))
  lat_col <- stringr::str_subset(names(locations), stringr::regex("^lat(:?itude)?$", ignore_case = TRUE))

  # Notify user which columns are being taken as long and lat
  cli::cli_inform("Assuming {.val {long_col}} and {.val {lat_col}} are longitude and latitude respectively.")

  # convert locations to an sf object to allow comparison with iso region
  points <- st_as_sf(locations, coords = c(long_col, lat_col), crs = st_crs(4326))

  # length of elements returned will be 1 if point lies within region and 0 otherwise
  within_ind <- purrr::map_int(st_intersects(points, iso), length)

  # Return appropriate locations
  locations[within_ind == 1, ]
}

# get_iso - function to be used within get_travel_times
get_iso <- function(lon, lat, travel_time, travel_method) {
  Sys.sleep(1) # Sleep to keep within the API usage limits
  st_make_valid(
    osrmIsochrone(
      loc = c(lon, lat),
      breaks = travel_time, # Number of minutes travel time
      res = 10, # The resolution i.e. check res*res points. More points == Slow.
      osrm.profile = travel_method # Car/foot/bike
    )
  )
}
