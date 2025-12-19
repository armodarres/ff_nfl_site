library(nflreadr)
library(dplyr)
library(arrow)
library(stringr)
library(purrr)

# -------------------------
# Load raw metadata
# -------------------------

# Seasons to pull
seasons <- 2016:2025

# Player rosters (season-aware)
rosters_raw <- map_df(seasons, ~ nflreadr::load_rosters(.x))

# Player seasonal stats (for headshots + team context)
player_stats_raw <- load_player_stats(seasons = TRUE)

# -------------------------
# Save raw pulls
# -------------------------
write_parquet(rosters_raw, "data/data_raw/rosters.parquet")
write_parquet(player_stats_raw, "data/data_raw/player_stats.parquet")

# -------------------------
# Deduplicate player_stats per player-season
# -------------------------
player_stats_unique <- player_stats_raw %>%
  select(player_id, season, headshot_url, team) %>%
  rename(recent_team = team) %>%
  distinct(player_id, season, .keep_all = TRUE)

# -------------------------
# Players dimension table
# -------------------------
players <- rosters_raw %>%
  mutate(
    season = as.integer(season),
    player_name = full_name
  ) %>%
  left_join(
    player_stats_unique,
    by = c("gsis_id" = "player_id", "season" = "season")
  ) %>%
  mutate(
    headshot_url = coalesce(headshot_url.x, headshot_url.y)
  ) %>%
  select(-headshot_url.x, -headshot_url.y) %>%
  arrange(gsis_id, season)




write_parquet(players, "data/data_processed/players.parquet")

# -------------------------
# Teams dimension table
# -------------------------
teams <- rosters_raw %>%
  select(season, team) %>%
  distinct() %>%
  mutate(
    season = as.integer(season),
    team = str_trim(team)
  ) %>%
  arrange(season, team)

write_parquet(teams, "data/data_processed/teams.parquet")

# -------------------------
# Confirmation message
# -------------------------
message(
  "Metadata load complete ✅\n",
  "Players table: ", nrow(players), " rows, seasons ", min(players$season), "-", max(players$season), "\n",
  "Teams table: ", nrow(teams), " rows, seasons ", min(teams$season), "-", max(teams$season)
)
