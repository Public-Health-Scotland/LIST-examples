library(dplyr)
library(slfhelper)

# View available variables (optional)
ep_file_vars
sort(ep_file_vars) # Might be easier to view!
ep_file_bedday_vars
demog_vars
ltc_vars


# Extract all Care Home data for 2223
care_home_2223 <- read_slf_episode(
  year = "2223",
  # This will be a lot of (52) variables, so should be reduced as needed.
  col_select = c(
    "anon_chi", "social_care_id", "person_id", # Identifiers
    "record_keydate1", "record_keydate2", "smrtype", # Episode detail
    any_of(demog_vars), # Demographic detail
    all_of(ep_file_bedday_vars), # All 'bedday related' variables
    starts_with("ch_"), # Any variable starting 'ch_' i.e. Care Home
    starts_with("sc_") # Any variable starting 'sc_' i.e. Social Care
  ),
  recids = "CH"
)

library(ggplot2)
care_home_2223 |>
  filter(sc_send_lca == 24L) |>
  ggplot(aes(x = ch_name, fill = factor(ch_adm_reason))) +
  geom_bar() +
  labs(
    title = "Admission type by Care Home",
    x = "Care Home Name",
    y = "Count of episodes",
    fill = "Admission Reason"
  )
