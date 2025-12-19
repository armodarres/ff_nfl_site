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

# Ensure team_id exists — if not, placeholder
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
# Derive Index
# -------------------------

player_index <- player_season %>%
  group_by(gsis_id, player_name, position) %>%
  summarise(
    first_season = min(season, na.rm = TRUE),
    last_season = max(season, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    slug = make_slug(player_name),
    active = last_season == max(last_season),
    # Fetch most recent team_id if present
    team_id = player_season %>%
      filter(gsis_id == gsis_id) %>%
      arrange(desc(season)) %>%
      slice(1) %>%
      pull(team_id),
    # Simple logo rule (we fix later)
    team_logo = ifelse(
      active,
      paste0("/logos/", team_id, ".png"),
      "/logos/retired.png"
    )
  ) %>%
  select(
    gsis_id,
    name = player_name,
    slug,
    position,
    first_season,
    last_season,
    active,
    team_id,
    team_logo
  )

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

message("player_index.json written successfully 🚀")
