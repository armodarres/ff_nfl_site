#!/usr/bin/env Rscript

library(dplyr)
library(arrow)
library(jsonlite)
library(stringr)
library(fs)

# ============================================================
# Coach index builder
#
# Input:
#   data/site_data/coaches/coaching_histories_clean.parquet
#
# Output:
#   data/site_data/coach_index.json
#
# Fields:
#   coach_id   (string)
#   name       (string)
#   slug       (string)
#   team       (3-letter team abbr)
#   role       (HC, OC, DC, ST, PC, RC, QB, RB, WR, TE, OL, DL, LB, DB, STC, ASC)
#   active     (TRUE/FALSE)
# ============================================================

# -------------------------
# Guard
# -------------------------
if (!dir_exists("data")) {
  stop("Run this script from repo root (nocap/)")
}

# -------------------------
# Load data
# -------------------------

# renamed from `hist` → `hist_c` to avoid shadowing base::hist
hist_c <- read_parquet(
  "data/site_data/coaches/coaching_histories_clean.parquet"
)

# -------------------------
# Team name → abbreviation map
# -------------------------

teams_lookup <- tribble(
  ~team_abbr, ~Employer,
  "ARI", "Arizona Cardinals",
  "ATL", "Atlanta Falcons",
  "BAL", "Baltimore Ravens",
  "BUF", "Buffalo Bills",
  "CAR", "Carolina Panthers",
  "CHI", "Chicago Bears",
  "CIN", "Cincinnati Bengals",
  "CLE", "Cleveland Browns",
  "DAL", "Dallas Cowboys",
  "DEN", "Denver Broncos",
  "DET", "Detroit Lions",
  "GB",  "Green Bay Packers",
  "HOU", "Houston Texans",
  "IND", "Indianapolis Colts",
  "JAX", "Jacksonville Jaguars",
  "KC",  "Kansas City Chiefs",
  "LV",  "Las Vegas Raiders",
  "LAC", "Los Angeles Chargers",
  "LAR", "Los Angeles Rams",
  "MIA", "Miami Dolphins",
  "MIN", "Minnesota Vikings",
  "NE",  "New England Patriots",
  "NO",  "New Orleans Saints",
  "NYG", "New York Giants",
  "NYJ", "New York Jets",
  "PHI", "Philadelphia Eagles",
  "PIT", "Pittsburgh Steelers",
  "SEA", "Seattle Seahawks",
  "SF",  "San Francisco 49ers",
  "TB",  "Tampa Bay Buccaneers",
  "TEN", "Tennessee Titans",
  "WAS", "Washington Commanders"
)

# -------------------------
# Helper: slug
# -------------------------

make_slug <- function(x) {
  x %>%
    str_to_lower() %>%
    str_replace_all("[^a-z0-9]+", "-") %>%
    str_replace_all("(^-|-$)", "")
}

# -------------------------
# Clean + compress roles
# -------------------------
# goal: map messy text like "D coordinator", "O coord",
#       "Secondary", etc. to clean tags like DC, OC, DB, etc.

clean_role <- function(raw) {
  if (is.na(raw) || raw == "") return("ASC")
  
  raw_low <- tolower(raw)
  
  case_when(
    # Head coach (this will also tag "Assistant Head Coach" as HC,
    # which I think you're fine with for now)
    grepl("head coach", raw_low) ~ "HC",
    
    # Offensive coordinator: lots of variants
    grepl("offensive coordinator", raw_low) ~ "OC",
    grepl("coordinator", raw_low) & grepl("off", raw_low) ~ "OC",
    grepl("\\bo coord", raw_low) ~ "OC",
    grepl("\\bo-coord", raw_low) ~ "OC",
    grepl("\\boc\\b", raw_low) ~ "OC",
    
    # Defensive coordinator & D-coord variants
    grepl("defensive coordinator", raw_low) ~ "DC",
    grepl("coordinator", raw_low) & grepl("def", raw_low) ~ "DC",
    grepl("\\bd coordinator", raw_low) ~ "DC",
    grepl("\\bd-coord", raw_low) ~ "DC",
    grepl("\\bdc\\b", raw_low) ~ "DC",
    
    # Special teams (coordinator or general ST role)
    grepl("special teams", raw_low) ~ "ST",
    
    # Strength & conditioning
    grepl("strength", raw_low) ~ "STC",
    
    # Passing / pass game coordinator
    grepl("passing game", raw_low) | grepl("pass game", raw_low) ~ "PC",
    
    # Run game coordinator
    grepl("run game", raw_low) ~ "RC",
    
    # QB / Quarterbacks
    grepl("quarterbacks", raw_low) ~ "QB",
    grepl("\\bqb\\b", raw_low) ~ "QB",
    
    # RB / Running backs
    grepl("running backs", raw_low) ~ "RB",
    grepl("\\brb\\b", raw_low) ~ "RB",
    
    # WR / Wide receivers
    grepl("wide receivers", raw_low) ~ "WR",
    grepl("\\bwr\\b", raw_low) ~ "WR",
    
    # TE / Tight ends
    grepl("tight ends", raw_low) ~ "TE",
    grepl("\\bte\\b", raw_low) ~ "TE",
    
    # OL / Offensive line
    grepl("offensive line", raw_low) ~ "OL",
    grepl("\\bol\\b", raw_low) ~ "OL",
    
    # DL / Defensive line
    grepl("defensive line", raw_low) ~ "DL",
    grepl("\\bdl\\b", raw_low) ~ "DL",
    
    # LB / Linebackers
    grepl("linebackers", raw_low) ~ "LB",
    grepl("\\blb\\b", raw_low) ~ "LB",
    
    # DB / Secondary / Safeties / Defensive backs
    grepl("defensive backs", raw_low) ~ "DB",
    grepl("secondary", raw_low) ~ "DB",
    grepl("safeties", raw_low) ~ "DB",
    grepl("\\bdb\\b", raw_low) ~ "DB",
    
    # Everything else → Assistant (ASC)
    TRUE ~ "ASC"
  )
}

# -------------------------
# Attach team abbreviation
# -------------------------

hist2 <- hist_c %>%
  left_join(teams_lookup, by = "Employer")

# -------------------------
# Determine active status
# -------------------------

max_year <- max(hist2$Year, na.rm = TRUE)

coach_status <- hist2 %>%
  group_by(coach_id, coach_name) %>%
  summarise(
    last_year = max(Year, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(active = last_year == max_year)

# -------------------------
# Determine most recent team & role
# -------------------------

recent <- hist2 %>%
  group_by(coach_id) %>%
  slice_tail(n = 1) %>%          # most recent row per coach
  ungroup() %>%
  mutate(
    role = clean_role(Role)
  ) %>%
  select(
    coach_id,
    team = team_abbr,
    role
  )

# -------------------------
# Final index
# -------------------------

coach_index <- coach_status %>%
  left_join(recent, by = "coach_id") %>%
  mutate(
    name = coach_name,
    slug = make_slug(name)
  ) %>%
  select(
    coach_id,
    name,
    slug,
    team,
    role,
    active
  ) %>%
  arrange(name)

# -------------------------
# Output
# -------------------------

dir_create("data/site_data", recurse = TRUE)

write_json(
  coach_index,
  "data/site_data/coach_index.json",
  auto_unbox = TRUE,
  pretty = TRUE
)

file_copy(
  "data/site_data/coach_index.json",
  "public/data/site_data/coach_index.json",
  overwrite = TRUE
)

message("coach_index.json written successfully with cleaned roles + teams + active 🚀")
