# Travel Times

This folder contains examples of using the package `{osrm}` to analyse travel times. You will need the following packages alongside:

-   [`{osrm}`](https://cran.r-project.org/package=osrm)
-   [`{sf}`](https://r-spatial.github.io/sf/)
-   [`{leaflet}`](https://rstudio.github.io/leaflet/)
-   [`{dplyr}`](https://dplyr.tidyverse.org/)

To install `{osrm}` on Posit Workbench you will need to install an older version of `{googlePolylines}` first. The following code will install both packages:

    devtools::install_version("googlePolylines", "0.8.1")
    install.packages("osrm")

## Files

-   [**travel times functions.R**](Geospatial/travel times functions.R) - functions to allow you to use the `{osrm}` functionality easily

-   [**travel times map.R**](Geospatial/travel times map.R) - creating a map showing travellable areas from a specific location within a certain time using car, bike, and foot

-   [**travel times within.R**](Geospatial/travel times within.R) - code to extract the number of locations within a certain travel time of another location (e.g. patients within a certain travel time of GP surgery)

