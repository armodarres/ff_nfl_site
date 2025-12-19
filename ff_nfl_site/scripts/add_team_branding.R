library(dplyr)
library(arrow)
library(nflreadr)
library(nflfastR)
library(stringr)
library(tibble)
library(fs)

# -------------------------
# Guard
# -------------------------
if (!dir_exists("data")) {
  stop("Run from repo root")
}

out_dir <- "data/site_data/teams"
dir_create(out_dir, recurse = TRUE)

# -------------------------
# Load nflverse team dictionary (authoritative)
# -------------------------
teams_master <- nflreadr::load_teams() %>%
  select(
    team_abbr,
    team_name,
    team_id,
    team_nick,
    team_conf,
    team_division,
    team_color,
    team_color2,
    team_color3,
    team_color4,
    team_logo_wikipedia,
    team_logo_espn,
    team_wordmark,
    team_conference_logo,
    team_league_logo,
    team_logo_squared
  )

# -------------------------
# Load your existing teams table
# -------------------------
teams <- read_parquet("data/data_processed/teams.parquet")

# -------------------------
# Historical team mapping
# -------------------------
historical_map <- tibble(
  old_abbr = c("STL", "SD", "OAK"),
  current_abbr = c("LA", "LAC", "LV")
)

teams <- teams %>%
  left_join(historical_map, by = c("team" = "old_abbr")) %>%
  mutate(
    team_abbr_clean = if_else(!is.na(current_abbr), current_abbr, team)
  ) %>%
  select(-current_abbr)

# -------------------------
# nflfastR branding metadata
# KEEP NOTHING that overlaps — drop all color/logo columns
# -------------------------
team_branding <- nflfastR::teams_colors_logos %>%
  select(
    team_abbr
    # no further cols retained
  )

# -------------------------
# Merge metadata into master table
# -------------------------
teams_brand <- teams %>%
  left_join(
    teams_master,
    by = c("team_abbr_clean" = "team_abbr")
  ) %>%
  left_join(
    team_branding,
    by = c("team_abbr_clean" = "team_abbr")
  ) %>%
  arrange(season, team_abbr_clean)

# -------------------------
# Save enriched team table
# -------------------------
write_parquet(
  teams_brand,
  file.path(out_dir, "teams_master.parquet")
)

message("Full team metadata ingested and saved to teams_master.parquet ✅")
