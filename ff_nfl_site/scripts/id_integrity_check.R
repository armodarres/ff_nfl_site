# --------------------------------------------------
# 04_id_integrity.R
# Check player and team ID integrity, plus headshots
# --------------------------------------------------

library(dplyr)
library(arrow)
library(tidyr)
library(readr)
library(tibble)

# -------------------------
# Load PBP and metadata
# -------------------------
pbp     <- read_parquet("data/data_processed/pbp_clean.parquet")
players <- read_parquet("data/data_processed/players.parquet")
teams   <- read_parquet("data/data_processed/teams.parquet")  # updated via helper script

# -------------------------
# Extract unique player IDs from PBP by season
# -------------------------
pbp_players <- pbp %>%
  select(season, passer_player_id, rusher_player_id, receiver_player_id) %>%
  pivot_longer(
    cols = c(passer_player_id, rusher_player_id, receiver_player_id),
    names_to = "role",
    values_to = "player_id"
  ) %>%
  filter(!is.na(player_id)) %>%
  distinct(season, player_id)

# -------------------------
# Player ID integrity check
# -------------------------
metadata_players <- players %>%
  select(season, gsis_id) %>%
  distinct()

unmatched_players <- pbp_players %>%
  anti_join(metadata_players,
            by = c("season" = "season", "player_id" = "gsis_id"))

if(nrow(unmatched_players) > 0){
  warning("Some PBP player IDs NOT in players.parquet ⚠️")
  write_csv(unmatched_players, "data/data_processed/unmatched_players.csv")
} else {
  message("All PBP player IDs found in players.parquet for all seasons ✅")
}

# -------------------------
# Headshot check
# -------------------------
players_missing_headshots <- players %>%
  filter(is.na(headshot_url)) %>%
  distinct(gsis_id, full_name, season)

if(nrow(players_missing_headshots) > 0){
  warning("Some players are missing headshots ⚠️")
  write_csv(players_missing_headshots, "data/data_processed/missing_headshots.csv")
} else {
  message("All players have headshots ✅")
}

# -------------------------
# Team integrity check
# -------------------------
pbp_teams <- pbp %>%
  select(season, team) %>%
  distinct()

missing_teams <- anti_join(pbp_teams, teams, by = c("season", "team"))

if(nrow(missing_teams) > 0){
  warning("Some PBP teams missing in teams.parquet ⚠️")
  write_csv(missing_teams, "data/data_processed/missing_teams.csv")
} else {
  message("All PBP teams found in teams.parquet for all seasons ✅")
}

# -------------------------
# Summary message
# -------------------------
message("Player and team ID integrity check complete. CSVs saved in data_processed/")
