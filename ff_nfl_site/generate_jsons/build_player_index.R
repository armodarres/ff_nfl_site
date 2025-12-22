library(dplyr)
library(arrow)
library(jsonlite)
library(stringr)
library(fs)

# -------------------------
# Guards
# -------------------------

if (!dir_exists("data")) {
  stop("Run this script from repo root (nocap/)")
}

# -------------------------
# Load Data
# -------------------------

player_season <- read_parquet(
  "data/data_processed/player_season_xfp.parquet"
)

# Ensure team_id exists — fallback
if (!"team_id" %in% names(player_season)) {
  player_season$team_id <- NA_character_
}

# -------------------------
# Helpers
# -------------------------

make_slug <- function(x) {
  x %>%
    str_to_lower() %>%
    str_replace_all("[^a-z0-9]+", "-") %>%
    str_replace_all("(^-|-$)", "")
}

# -------------------------
# Derive active season + team
# -------------------------

max_season <- max(player_season$season, na.rm = TRUE)

# get most recent team per player
recent_team <- player_season %>%
  arrange(season) %>%
  group_by(gsis_id) %>%
  slice_tail(n = 1) %>% 
  ungroup() %>%
  select(gsis_id, team_id)


# core years + status
player_years <- player_season %>%
  group_by(gsis_id, player_name, position) %>%
  summarise(
    first_season = min(season, na.rm = TRUE),
    last_season  = max(season, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(active = last_season == max_season)

# -------------------------
# Join + shape final index
# -------------------------

player_index <- player_years %>%
  left_join(recent_team, by = "gsis_id") %>%
  mutate(
    name = player_name,
    slug = make_slug(player_name),
    team = team_id
  ) %>%
  select(
    gsis_id,
    name,
    slug,
    position,
    team,
    active,
    first_season,
    last_season
  ) %>%
  arrange(name)

# -------------------------
# Output Directory
# -------------------------

dir_create("data/site_data", recurse = TRUE)

# -------------------------
# Write JSON
# -------------------------

write_json(
  player_index,
  "data/site_data/player_index.json",
  auto_unbox = TRUE,
  pretty = TRUE
)

file_copy(
  "data/site_data/player_index.json",
  "public/data/site_data/player_index.json",
  overwrite = TRUE
)


message("player_index.json written successfully 🚀")
