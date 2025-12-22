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
# Determine current season dynamically
# -------------------------

current_season <- max(player_season$season, na.rm = TRUE)

# -------------------------
# Latest name from latest stats season -> players table
# -------------------------

latest_season_per_player <- player_season %>%
  group_by(gsis_id) %>%
  summarise(
    latest_season = max(season, na.rm = TRUE),
    .groups = "drop"
  )

latest_name <- latest_season_per_player %>%
  left_join(players, by = c("gsis_id", "latest_season" = "season")) %>%
  select(gsis_id, full_name)

# -------------------------
# Merge + enforce latest name
# -------------------------

merged <- players %>%
  group_by(gsis_id) %>%
  arrange(desc(season)) %>%
  slice(1) %>%
  ungroup() %>%
  left_join(latest_name, by = "gsis_id", suffix = c("", "_latest")) %>%
  left_join(season_summary, by = "gsis_id") %>%
  mutate(
    full_name = coalesce(full_name_latest, full_name),
    
    slug = full_name %>%
      str_to_lower() %>%
      str_replace_all("[^a-z0-9]+", "-") %>%
      str_replace_all("(^-|-$)", ""),
    
    # -------------------------
    # NEW ACTIVE LOGIC
    # -------------------------
    active = last_season >= current_season - 1
  ) %>%
  select(-full_name_latest) %>%
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

file_copy(
  "data/site_data/player_index.json",
  "public/data/site_data/player_index.json",
  overwrite = TRUE
)

message("\nplayer_index.json written successfully 🚀")
message("Rows: ", nrow(player_index))
