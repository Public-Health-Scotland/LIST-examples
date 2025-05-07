library(dplyr)
library(slfhelper)

# View available variables (optional)
ep_file_vars
sort(ep_file_vars) # Might be easier to view!
demog_vars
ltc_vars


# Extract all Home Care data for 2223
home_care_2223 <- read_slf_episode(
  year = "2223",
  # This will be a lot of (62) variables, so should be reduced as needed.
  col_select = c(
    "anon_chi", "social_care_id", "person_id", # Identifiers
    "record_keydate1", "record_keydate2", "smrtype", # Episode detail
    any_of(demog_vars), # Demographic detail
    starts_with("hc_"), # Any variable starting 'hc_' i.e. Home Care
    starts_with("sc_") # Any variable starting 'sc_' i.e. Social Care
  ),
  recids = "HC"
)
