library(dplyr)
library(arrow)
library(nflreadr)
library(fs)

# -------------------------
# Guard
# -------------------------
if (!dir_exists("data")) {
  stop("Run from repo root")
}

# ============================================================
# LOAD PLAYER ID MAP FROM ROSTERS
# ============================================================
roster <- nflreadr::load_rosters(seasons = TRUE) %>%
  select(
    gsis_id,
    pfr_id,
    season,
    team
  ) %>%
  filter(!is.na(pfr_id)) %>%
  distinct(pfr_id, gsis_id, season, team)

# ============================================================
# SNAP COUNTS
# ============================================================
snap_out_dir <- "data/site_data/snap_counts"
dir_create(snap_out_dir, recurse = TRUE)

snap_counts_raw <- nflreadr::load_snap_counts(seasons = 2016:2025)

snap_counts_clean <- snap_counts_raw %>%
  mutate(
    season = as.integer(season),
    week   = as.integer(week)
  ) %>%
  # correct join key
  left_join(
    roster,
    by = c("pfr_player_id" = "pfr_id", "season", "team")
  ) %>%
  select(
    season,
    week,
    game_id,
    team,
    gsis_id,
    player,
    offense_snaps,
    defense_snaps,
    st_snaps
  ) %>%
  arrange(gsis_id, season, week)

write_parquet(
  snap_counts_clean,
  file.path(snap_out_dir, "snap_counts.parquet")
)

message("Snap counts ingested + gsis_id mapped ✅")


# ============================================================
# PARTICIPATION
# ============================================================
part_out_dir <- "data/site_data/participation"
dir_create(part_out_dir, recurse = TRUE)

participation_raw <- nflreadr::load_participation(2016:2025)
colnames(participation_raw)


participation_clean <- participation_raw %>%
  mutate(
    season = as.integer(str_sub(nflverse_game_id, 1, 4)),
    week   = as.integer(str_sub(nflverse_game_id, 6, 7))
  )

write_parquet(
  participation_clean,
  file.path(part_out_dir, "participation.parquet")
)

message("Participation ingested + gsis_id mapped ✅")
