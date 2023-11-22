# Load libraries ####
# if any package not installed use install.packages("package")
library(dplyr)
library(glue)

# Mapping Packages
# For installation instructions see the following link
# (shift + left click to open)
# https://public-health-scotland.github.io/knowledge-base/docs/Posit%20Infrastructure?doc=How%20to%20Install%20and%20Use%20Geospatial%20R%20Packages.md
# leaflet documentation can be found here: https://rstudio.github.io/leaflet/
library(leaflet)

# Reading shape files
library(sf)

# List different shapefiles in the shapefile folder
shapefiles_folder <- "/conf/linkage/output/lookups/Unicode/Geography/Shapefiles"
list.files(shapefiles_folder)

# Datazone shapefile from Shapefiles/Data Zone 2011/ folder
# .shp files are read in
datazone_shp <- read_sf(file.path(shapefiles_folder, "Data Zones 2011", "SG_DataZone_Bdry_2011.shp")) |>
  # converts the shapefile to use latitutde and longitude
  st_transform(4326) # EPSG4326

# Map 1: Choose an HSCP and plot a map ####
hscp <- "West Dunbartonshire"

# selecting and rename columns of interest and bring to hscp level
hscp_dz_shp <- datazone_shp |>
  select(
    datazone2011 = DataZone,
    datazone2011name = Name,
    hscp2019name = hscp2019na,
    geometry
  ) |>
  filter(hscp2019name == hscp)

# plot map
hscp_dz_shp |>
  leaflet() |>
  ## Plot the shape of the area on the map ####
  # https://rstudio.github.io/leaflet/map_widget.html
  addPolygons(
    # colour of the entire polygon
    color = "red",
    # Thickness of borders
    weight = 1,
    # adds a popup when the polygon is clicked on
    # using Datazone and Name columns
    popup = ~ glue("Datazone: {datazone2011name} ({datazone2011})"),
    # detail level of polygon (higher number = less accurate representation & better performance)
    smoothFactor = 1
  ) |>
  # Setting map prvider for map background
  # you can see the list by typing providers$ or visiting the following link
  # # http://leaflet-extras.github.io/leaflet-providers/preview/index.html
  addProviderTiles(provider = providers[["OpenStreetMap"]])


# Joining data onto shapefile ####
# SIMD file
# SIMD2020v2
simd <- readRDS("/conf/linkage/output/lookups/Unicode/Deprivation/DataZone2011_simd2020v2.rds") |>
  # Choose the required columns
  select(datazone2011, simd2020v2_sc_decile, simd2020v2_sc_quintile)

# SIMD deciles
simd_deciles_levels <- c(
  "1 (Most Deprived)",
  "2",
  "3",
  "4",
  "5",
  "6",
  "7",
  "8",
  "9",
  "10 (Least Deprived)"
)

# join simd data for chosen hscp to hscp_dz_shp
hscp_dz_shp <- hscp_dz_shp |>
  left_join(simd, by = join_by(datazone2011)) |>
  # simd deciles are numeric values but to add a bit more detail
  # change to a factor to indicate the most and least deprived deciles
  mutate(
    simd2020v2_sc_decile = case_match(
      simd2020v2_sc_decile,
      1 ~ "1 (Most Deprived)",
      10 ~ "10 (Least Deprived)",
      .default = as.character(simd2020v2_sc_decile)
    ),
    simd2020v2_sc_decile = ordered(
      x = simd2020v2_sc_decile,
      levels = simd_deciles_levels
    )
  )

# Add colours representing simd deciles ####

# More examples can be found here:
# https://rstudio.github.io/leaflet/colors.html
# Define colours for each decile by creating a palette

# Colour ranges for decile
# Use RColorBrewer - Pick a palette here - https://colorbrewer2.org/
# 'PuOr' is colour-blind safe and allows 10 colours.
library(RColorBrewer)

decile_colours <- brewer.pal(n = 10, name = "PuOr")

# Maps colours defined in decile_colours to the simd_deciles ####
# As we want our deciles be be in a certain order and they are not
# numeric values, it is useful to make them a factor  which will
# allow setting the order that the deciles will display
pal_decile <- colorFactor(
  palette = decile_colours,
  domain = simd_deciles_levels,
  ordered = TRUE
)


# Map 2: Plot map with simd ####
hscp_dz_shp |>
  leaflet() |>
  addPolygons(
    color = "grey",
    weight = 1,
    smoothFactor = 0.5,
    highlightOptions = highlightOptions(
      color = "white",
      weight = 2,
      bringToFront = TRUE
    ),
    # fillColor fills the colour based on the palette that was
    # created so datazones will be filled in with the specified
    # colour for their SIMD 2020 decile
    fillColor = ~ pal_decile(simd2020v2_sc_decile),
    popup = ~ glue(
      "Datazone: {datazone2011name} ({datazone2011})<br>",
      "SIMD 2020 Decile: {simd2020v2_sc_decile}"
    ),
    # transparency of borders and fillcolor
    opacity = 1,
    fillOpacity = 0.75
  ) |>
  ## Add legend to map ####
  # https://rstudio.github.io/leaflet/legends.html
  addLegend(
    # Colour palette to use
    pal = pal_decile,
    # Transparency of colours defined in pal
    opacity = 1,
    # Values to use in legend
    # values are displayed by using fct_rev() function from forcats. e.g.
    # values =  ~ fct_rev(simd2020v2_sc_decile)
    values = ~ simd2020v2_sc_decile,
    position = "bottomright",
    title = "SIMD 2020 Decile"
  ) |>
  addProviderTiles(provider = providers[["OpenStreetMap"]])


# Map 3: Adding markers to map and setting groups ####

# Markers - https://rstudio.github.io/leaflet/markers.html
# Groups - https://rstudio.github.io/leaflet/showhide.html

# Will use the postcode directory to put down markers for
# 75 postcodes in the HSCP. Longitude and latitude are needed
# to do this
# NOTE: If you are using the postcode directory to locate
# buildings please be aware that if two or more are in the
# same postcode, the markers will overlap

library(arrow)

## Postcode lookup for markers ####
pc_lookup <- read_parquet(
  file.path(
    "/conf/linkage/output/lookups/Unicode/Geography",
    "Scottish Postcode Directory", "Scottish_Postcode_Directory_2023_2.parquet"
  ),
  col_select = c(pc7, latitude, longitude, hscp2019name)
) |>
  filter(hscp2019name == hscp) |>
  select(!hscp2019name) |>
  rename(postcode = pc7)

# shuffle postcodes and use the first 75
# rerun this to get different postcodes
sample_postcodes <- pc_lookup |>
  slice_sample(n = 75)

sample_postcodes2 <- pc_lookup |>
  slice_sample(n = 75)


### Customising sample_postcodes2 icons ####
sample_postcodes2_icon <- awesomeIcons(
  iconColor = "white",
  library = "ion",
  markerColor = "black"
)

## Plot map ####
hscp_dz_shp |>
  leaflet() |>
  addPolygons(
    color = "grey",
    weight = 1,
    smoothFactor = 0.5,
    highlightOptions = highlightOptions(
      color = "white",
      weight = 2,
      bringToFront = TRUE
    ),
    fillColor = ~ pal_decile(simd2020v2_sc_decile),
    popup = ~ glue(
      "Datazone: {datazone2011name} ({datazone2011})<br>",
      "SIMD 2020 Decile: {simd2020v2_sc_decile}"
    ),
    # transparency of borders and fillcolor
    opacity = 1,
    fillOpacity = 0.75,
    ### Assign group to toggle layer on or off ####
    group = "SIMD Fill"
  ) |>
  ### Adding another layer with no fillColor ####
  # set fillOpacity to 0 so that only polygon borders are shown
  addPolygons(
    color = "grey",
    weight = 1,
    smoothFactor = 0.5,
    highlightOptions = highlightOptions(
      color = "white",
      weight = 2,
      bringToFront = TRUE
    ),
    popup = ~ glue(
      "Datazone: {datazone2011name} ({datazone2011})<br>",
      "SIMD 2020 Decile: {simd2020v2_sc_decile}"
    ),
    # transparency of borders and fillcolor
    opacity = 1,
    fillOpacity = 0,
    ## Assign group to toggle layer on or off
    group = "No SIMD Fill"
  ) |>
  addLegend(
    # Colour palette to use
    pal = pal_decile,
    # Transparency of colours defined in pal
    opacity = 1,
    values = ~ simd2020v2_sc_decile,
    position = "bottomright",
    title = "SIMD 2020 Decile",
    ### Assign group to toggle legend on or off ####
    group = "SIMD Fill"
  ) |>
  ## Add markers ####
  addAwesomeMarkers(
    data = sample_postcodes,
    popup = ~ glue(
      "Postcode: {postcode}<br>",
      "Latitude: {latitude}, Longitude: {longitude}"
    ),
    # Set group for markers
    group = "PC Sample 1"
  ) |>
  addAwesomeMarkers(
    data = sample_postcodes2,
    icon = ~ sample_postcodes2_icon,
    popup = ~ glue(
      "Postcode: {postcode}<br>",
      "Latitude: {latitude}, Longitude: {longitude}"
    ),
    # Set group for markers
    group = "PC Sample 2"
  ) |>
  ## Add control for groups ####
  # Will add a set of controls in the top right of the map
  addLayersControl(
    # Groups will show in order they are set here
    baseGroups = c("SIMD Fill", "No SIMD Fill"),
    overlayGroups = c("PC Sample 1", "PC Sample 2"),
    position = "topright",
    # set collapsed = FALSE so that controls always displayed
    options = layersControlOptions(collapsed = FALSE)
  ) |>
  # overlay groups will always start as ticked on the controls
  # can change this using hideGroup
  hideGroup("PC Sample 2") |>
  addProviderTiles(provider = providers[["OpenStreetMap"]])
