# ============================================================
# Position-specific Random Forest xFP models
#
# QB : pass attempts + QB runs (QB scoring)
# RB : rushes + receptions
# WR : targets + receptions
# TE : targets + receptions
#
# Output:
#   data/data_processed/player_season_xfp.parquet
# ============================================================

library(dplyr)
library(arrow)
library(randomForest)
library(fs)

# -------------------------
# Guards
# -------------------------
if (!dir_exists("data")) {
  stop("Run from repo root (nocap/)")
}
dir_create("data/data_processed", recurse = TRUE)

# -------------------------
# Load inputs
# -------------------------

pbp <- read_parquet("data/data_processed/pbp_clean.parquet")

players <- read_parquet("data/data_processed/players.parquet") %>%
  distinct(gsis_id, player_name, position)

# -------------------------
# Base features
# -------------------------

feature_cols <- c(
  "down",
  "ydstogo",
  "yardline_100",
  "air_yards",
  "score_differential",
  "goal_to_go",
  "is_pass",
  "is_rush"
)

pbp <- pbp %>%
  mutate(across(all_of(feature_cols), ~ coalesce(.x, 0)))

# ============================================================
# BUILD POSITION DATASETS
# ============================================================

# -------------------------
# QB DATA (pass attempts + QB runs)
# -------------------------

qb_df <- pbp %>%
  mutate(
    gsis_id = case_when(
      !is.na(passer_player_id) ~ passer_player_id,
      qb_scramble == 1 & !is.na(rusher_player_id) ~ rusher_player_id,
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(gsis_id)) %>%
  left_join(players, by = "gsis_id") %>%
  filter(position == "QB") %>%
  mutate(
    fantasy_points =
      0.04 * coalesce(passing_yards, 0) +
      4 * coalesce(pass_td, 0) -
      2 * coalesce(interception, 0) +
      0.1 * coalesce(rushing_yards, 0) +
      6 * coalesce(rush_td, 0)
  )

# -------------------------
# RB DATA
# -------------------------

rb_df <- pbp %>%
  mutate(
    gsis_id = case_when(
      !is.na(rusher_player_id) ~ rusher_player_id,
      !is.na(receiver_player_id) ~ receiver_player_id,
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(gsis_id)) %>%
  left_join(players, by = "gsis_id") %>%
  filter(position == "RB") %>%
  mutate(
    fantasy_points =
      0.1 * coalesce(rushing_yards, 0) +
      6 * coalesce(rush_td, 0) +
      0.1 * coalesce(receiving_yards, 0) +
      6 * coalesce(receiving_td, 0) +
      0.5 * coalesce(complete_pass, 0)
  )

# -------------------------
# WR DATA
# -------------------------

wr_df <- pbp %>%
  mutate(
    gsis_id = receiver_player_id
  ) %>%
  filter(!is.na(gsis_id)) %>%
  left_join(players, by = "gsis_id") %>%
  filter(position == "WR") %>%
  mutate(
    fantasy_points =
      0.1 * coalesce(receiving_yards, 0) +
      6 * coalesce(receiving_td, 0) +
      0.5 * coalesce(complete_pass, 0)
  )

# -------------------------
# TE DATA
# -------------------------

te_df <- pbp %>%
  mutate(
    gsis_id = receiver_player_id
  ) %>%
  filter(!is.na(gsis_id)) %>%
  left_join(players, by = "gsis_id") %>%
  filter(position == "TE") %>%
  mutate(
    fantasy_points =
      0.1 * coalesce(receiving_yards, 0) +
      6 * coalesce(receiving_td, 0) +
      0.5 * coalesce(complete_pass, 0)
  )

# ============================================================
# TRAIN & APPLY RANDOM FORESTS
# ============================================================

fit_and_score <- function(df) {
  rf <- randomForest(
    x = df[, feature_cols],
    y = df$fantasy_points,
    ntree = 300,
    nodesize = 50
  )
  
  df %>%
    mutate(
      xfp = predict(rf, newdata = df[, feature_cols]),
      oex = fantasy_points - xfp
    )
}

qb_scored <- fit_and_score(qb_df)
rb_scored <- fit_and_score(rb_df)
wr_scored <- fit_and_score(wr_df)
te_scored <- fit_and_score(te_df)

# ============================================================
# AGGREGATE TO PLAYER-SEASON
# ============================================================

aggregate_season <- function(df) {
  df %>%
    group_by(gsis_id, player_name, position, season) %>%
    summarise(
      fantasy_points = sum(fantasy_points, na.rm = TRUE),
      xfp = sum(xfp, na.rm = TRUE),
      oex = sum(oex, na.rm = TRUE),
      plays = n(),
      .groups = "drop"
    )
}

player_season_xfp <- bind_rows(
  aggregate_season(qb_scored),
  aggregate_season(rb_scored),
  aggregate_season(wr_scored),
  aggregate_season(te_scored)
)

# ============================================================
# OUTPUT
# ============================================================

write_parquet(
  player_season_xfp,
  "data/data_processed/player_season_xfp.parquet"
)

message("Position-specific RF xFP complete ✅")
