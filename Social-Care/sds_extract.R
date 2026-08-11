library(dplyr) # install.packages("dplyr")
library(slfhelper) # install.packages("slfhelper")

# View available variables (optional)
# All of these objects are provided by slfhelper
ep_file_vars
sort(ep_file_vars) # Might be easier to view!
ep_file_bedday_vars
demog_vars
ltc_vars


# Extract all SDS data for 2024/25
sds_2425 <- read_slf_episode(
  year = "2425",
  # This will be a lot of (62) variables, so should be reduced as needed.
  col_select = c(
    "anon_chi",
    "social_care_id",
    "person_id", # Identifiers
    "record_keydate1",
    "record_keydate2",
    "smrtype", # Episode detail
    any_of(demog_vars), # Demographic detail
    starts_with("sc_") # Any variable starting 'sc_' i.e. Social Care
  ),
  recids = "SDS"
)
