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

# -------------------------
# Load injuries
# -------------------------
injuries_raw <- nflreadr::load_injuries(2016:2025)

# -------------------------
# Clean / standardize
# -------------------------
injuries_clean <- injuries_raw %>%
  mutate(
    season = as.integer(season),
    week   = as.integer(week),
    player_name = paste(first_name, last_name),
    
    # Normalize practice status
    practice_status = case_when(
      practice_status == "Did Not Participate in Practice" ~ "DNP",
      practice_status == "Limited Participation in Practice" ~ "LP",
      practice_status == "Full Participation in Practice" ~ "FP",
      TRUE ~ NA_character_
    )
  ) %>%
  # Drop non-injury rows
  filter(
    !is.na(report_primary_injury),
    !tolower(report_primary_injury) %in% c(
      "not injury related",
      "illness",
      "personal",
      "rest"
    )
  ) %>%
  select(
    season,
    week,
    game_type,
    team,
    gsis_id,
    player_name,
    position,
    report_primary_injury,
    report_status,
    practice_status
  ) %>%
  arrange(gsis_id, season, week)

# -------------------------
# Write output
# -------------------------
out_dir <- "data/site_data/injuries"
dir_create(out_dir, recurse = TRUE)

write_parquet(
  injuries_clean,
  file.path(out_dir, "injuries.parquet")
)

message("Injuries ingested ✅")
