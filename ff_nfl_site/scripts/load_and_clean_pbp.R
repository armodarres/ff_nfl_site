library(dplyr)
library(purrr)
library(arrow)
library(nflreadr)
library(fs)

# -------------------------
# Guard
# -------------------------
if (!dir_exists("data")) {
  stop("Run from repo root")
}

# -------------------------
# Config
# -------------------------
seasons <- 2016:2025

# -------------------------
# Load raw PBP
# -------------------------
pbp_raw <- map_df(seasons, ~ nflreadr::load_pbp(.x))

write_parquet(
  pbp_raw,
  "data/data_raw/pbp_raw.parquet"
)

# -------------------------
# Clean + filter offensive plays
# -------------------------
pbp_clean <- pbp_raw %>%
  mutate(
    is_pass = play_type == "pass",
    is_rush = play_type == "run",
    is_qb_scramble = qb_scramble == 1,
    is_2pt = two_point_attempt == 1,
    has_target = !is.na(receiver_player_id),
    has_rush = !is.na(rusher_player_id),
    is_offensive_play = is_pass | is_rush | is_qb_scramble | is_2pt
  ) %>%
  filter(is_offensive_play) %>%
  mutate(
    complete_pass = ifelse(complete_pass == 1, 1L, 0L),
    touchdown = ifelse(touchdown == 1, 1L, 0L),
    yards_gained = ifelse(is.na(yards_gained), 0, yards_gained),
    team = posteam
  )

# -------------------------
# Fantasy scoring
# -------------------------
pbp_clean <- pbp_clean %>%
  mutate(
    rush_td = ifelse(rush == 1 & touchdown == 1, 1, 0),
    pass_td = ifelse(pass == 1 & touchdown == 1 & !is.na(passer_player_id), 1, 0),
    receiving_td = ifelse(pass == 1 & touchdown == 1 & !is.na(receiver_player_id), 1, 0),
    fantasy_points =
      0.1 * ifelse(rush == 1, yards_gained, 0) +
      0.1 * ifelse(!is.na(receiver_player_id), receiving_yards, 0) +
      0.04 * ifelse(pass == 1, passing_yards, 0) +
      6 * rush_td +
      6 * receiving_td +
      4 * pass_td +
      0.5 * ifelse(!is.na(receiver_player_id), 1, 0) +
      -2 * fumble_lost +
      -2 * interception
  )

# -------------------------
# Load cleaned playcaller data
# -------------------------
playcallers <- read_parquet(
  "data/site_data/coaches/all_playcallers_clean.parquet"
) %>%
  select(
    season,
    week,
    team,
    off_play_caller_id,
    def_play_caller_id,
    head_coach_id
  )

# -------------------------
# Join offensive (posteam) coaches
# -------------------------
pbp_clean <- pbp_clean %>%
  left_join(
    playcallers,
    by = c(
      "season" = "season",
      "week"   = "week",
      "posteam" = "team"
    )
  ) %>%
  rename(
    posteam_play_caller_id = off_play_caller_id,
    posteam_head_coach_id  = head_coach_id
  ) %>%
  select(-def_play_caller_id)

# -------------------------
# Join defensive (defteam) coaches
# -------------------------
pbp_clean <- pbp_clean %>%
  left_join(
    playcallers,
    by = c(
      "season" = "season",
      "week"   = "week",
      "defteam" = "team"
    )
  ) %>%
  rename(
    defteam_play_caller_id = def_play_caller_id,
    defteam_head_coach_id  = head_coach_id
  ) %>%
  select(-off_play_caller_id)

# -------------------------
# Save final PBP
# -------------------------
write_parquet(
  pbp_clean,
  "data/data_processed/pbp_clean.parquet"
)

message("Canonical PBP with coach IDs saved ✅")
