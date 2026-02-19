library(dplyr) # install.packages("dplyr")
library(slfhelper) # install.packages("slfhelper")

# View available variables (optional)
# All of these objects are provided by slfhelper
ep_file_vars
sort(ep_file_vars) # Might be easier to view!
ep_file_bedday_vars
demog_vars
ltc_vars


# Extract all Care Home data for 2024/25
care_home_2425 <- read_slf_episode(
  year = "2425",
  # This will be a lot of (52) variables, so should be reduced as needed.
  col_select = c(
    "anon_chi",
    "social_care_id",
    "person_id", # Identifiers
    "record_keydate1",
    "record_keydate2",
    "smrtype", # Episode detail
    any_of(demog_vars), # Demographic detail
    all_of(ep_file_bedday_vars), # All 'bedday related' variables
    starts_with("ch_"), # Any variable starting 'ch_' i.e. Care Home
    starts_with("sc_") # Any variable starting 'sc_' i.e. Social Care
  ),
  recids = "CH" # Only Care Home episodes
)

# Use the built-in data to match on Local Authority
gla_care_home_2425 <- care_home_2425 |>
  mutate(sc_send_lca = sc_send_lca) |>
  left_join(sc_partnerships, join_by(sc_send_lca == lca)) |>
  filter(partnership_name == "Fife")

library(ggplot2)
gla_care_home_2425 |>
  ggplot(aes(x = ch_name, fill = factor(ch_adm_reason))) +
  geom_bar() +
  labs(
    title = "Admission type by Care Home",
    x = "Care Home Name",
    y = "Count of episodes",
    fill = "Admission Reason"
  )
