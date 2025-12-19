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

message("Loading players dimension table...")
players <- read_parquet(
  "data/data_processed/players.parquet"
)

message("Loading season stats...")
player_season <- read_parquet(
  "data/data_processed/player_season_xfp.parquet"
)

# -------------------------
# First + last season per player
# -------------------------

season_summary <- player_season %>%
  group_by(gsis_id) %>%
  summarise(
    first_season = min(season, na.rm = TRUE),
    last_season = max(season, na.rm = TRUE),
    .groups = "drop"
  )

# -------------------------
# Merge latest season metadata
# -------------------------

merged <- players %>%
  group_by(gsis_id) %>%
  arrange(desc(season)) %>%
  slice(1) %>%       
  ungroup() %>%
  left_join(season_summary, by = "gsis_id") %>%
  mutate(
    active = status == "ACT",
    team_logo = if_else(
      active,
      paste0("/logos/", team, ".png"),
      "/logos/retired.png"
    ),
    slug = full_name %>%
      str_to_lower() %>%
      str_replace_all("[^a-z0-9]+", "-") %>%
      str_replace_all("(^-|-$)", "")
  )

# -------------------------
# FILTER TO OFFENSIVE POSITIONS
# -------------------------

merged <- merged %>%
  filter(
    position %in% c("QB", "RB", "WR", "TE"),
    !is.na(first_season)
  )


# -------------------------
# Final searchable index
# -------------------------

player_index <- merged %>%
  transmute(
    gsis_id,
    name = full_name,
    slug,
    position,
    team = team,
    team_logo,
    active,
    jersey = jersey_number,
    first_season,
    last_season
  ) %>%
  arrange(name)

# -------------------------
# Output
# -------------------------

dir_create("data/site_data", recurse = TRUE)

write_json(
  player_index,
  "data/site_data/player_index.json",
  auto_unbox = TRUE,
  pretty = TRUE
)

message("\nplayer_index.json written successfully 🚀")
message("Rows: ", nrow(player_index))
