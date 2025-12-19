# --------------------------------------------------
# helper_update_teams.R
# Generate correct teams.parquet from PBP
# --------------------------------------------------

library(dplyr)
library(arrow)

# Load raw PBP
pbp <- read_parquet("data_raw/pbp_raw.parquet")

# Extract unique season × team combinations
teams_full <- pbp %>%
  select(season, team = posteam) %>%
  distinct() %>%
  arrange(season, team)

# Save corrected teams table
write_parquet(teams_full, "data_processed/teams.parquet")

message("teams.parquet updated with correct season × team combinations ✅")
