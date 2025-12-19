library(dplyr)
library(arrow)
library(tidyr)

# -------------------------
# Load modeled play-by-play
# -------------------------

pbp <- read_parquet("data/data_processed/pbp_with_xfp.parquet")

# -------------------------
# PLAYER SEASON (by role)
# -------------------------

pbp_player_long <- pbp %>%
  select(
    season,
    fantasy_points,
    xFP,
    rusher_player_id,
    passer_player_id,
    receiver_player_id
  ) %>%
  pivot_longer(
    cols = c(
      rusher_player_id,
      passer_player_id,
      receiver_player_id
    ),
    names_to = "player_role",
    values_to = "gsis_id"
  ) %>%
  filter(!is.na(gsis_id))

player_season_xfp <- pbp_player_long %>%
  group_by(gsis_id, player_role, season) %>%
  summarize(
    fantasy_points = sum(fantasy_points, na.rm = TRUE),
    xfp = sum(xFP, na.rm = TRUE),
    plays = n(),
    .groups = "drop"
  ) %>%
  mutate(
    oex = fantasy_points - xfp
  )

write_parquet(
  player_season_xfp,
  "data/data_processed/player_season_xfp.parquet"
)

# -------------------------
# TEAM SEASON
# -------------------------

team_season_xfp <- pbp %>%
  group_by(season, team) %>%
  summarize(
    fantasy_points = sum(fantasy_points, na.rm = TRUE),
    xfp = sum(xFP, na.rm = TRUE),
    plays = n(),
    pass_plays = sum(play_type == "pass", na.rm = TRUE),
    rush_plays = sum(play_type == "run", na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    oex = fantasy_points - xfp
  )

write_parquet(
  team_season_xfp,
  "data/data_processed/team_season_xfp.parquet"
)

# -------------------------
# COACH SEASON
# -------------------------
# NOTE:
# This assumes pbp already contains a stable offensive_coach_id.
# If not, that mapping should be created upstream in scripts/.

coach_season_xfp <- pbp %>%
  filter(!is.na(offensive_coach_id)) %>%
  group_by(season, offensive_coach_id) %>%
  summarize(
    fantasy_points = sum(fantasy_points, na.rm = TRUE),
    xfp = sum(xFP, na.rm = TRUE),
    plays = n(),
    pass_plays = sum(play_type == "pass", na.rm = TRUE),
    rush_plays = sum(play_type == "run", na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    oex = fantasy_points - xfp
  )

write_parquet(
  coach_season_xfp,
  "data/data_processed/coach_season_xfp.parquet"
)
