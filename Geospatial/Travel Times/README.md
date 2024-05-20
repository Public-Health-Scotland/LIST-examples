# Travel Times

This folder contains examples on using the package `{osrm}` to do analyses relating to travel times. You will need the following packages alongside:

-   `{osrm}`
-   `{sf}`
-   `{leaflet}`
-   `{dplyr}`

To install `{osrm}` on Posit Workbench you will need to install an older version of `{googlePolylines}` first. The following code will install both packages:

    devtools::install_version("googlePolylines", "0.8.1")
    install.packages("osrm")

## Files

-   **travel times functions.R** - functions to allow you to use the `{osrm}` functionality easily

-   **travel times map.R** - creating a map showing travellable areas from a specific location within a certain time using car, bike, and foot

-   **travel times within.R** - code to extract the number of locations within a certain travel time of another location (e.g. patients within certain travel time of GP surgery)

