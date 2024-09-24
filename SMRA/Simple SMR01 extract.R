# Install packages (if required)
# install.packages("odbc")
# install.packages("dplyr")
# install.packages("dbplyr")

#  Load Libraries
library(odbc)
library(dplyr)
library(dbplyr)

# Create a connection to SMRA
smra_conn <- dbConnect(
  drv = odbc(),
  dsn = "SMRA",
  uid = Sys.getenv("USER"),
  pwd = rstudioapi::askForPassword("SMRA Password:")
)

# Set a start date - format must be "DD-MMM-YYYY"
# Alternatively use TO_DATE(start_date, "<format>") instead of
# just start_date in the filter() below.
start_date <- "01-AUG-2023"
end_date <- format(Sys.Date(), "%d-%b-%Y")

# Check what variables are available - Optional
colnames(tbl(smra_conn, in_schema("ANALYSIS", "SMR01_PI")))

# Take an extract from SMR01
smr01_query <- tbl(smra_conn, in_schema("ANALYSIS", "SMR01_PI")) |>
  # Select the variables
  select(LINK_NO, ADMISSION_DATE, DISCHARGE_DATE) |>
  filter(between(DISCHARGE_DATE, start_date, end_date)) |>
  show_query() # Print the translated SQL to console


# Preview the data - Optional
smr01_query

# Return the data
smr01_extract <- collect(smr01_query)

# close the connection
dbDisconnect(smra_conn)
