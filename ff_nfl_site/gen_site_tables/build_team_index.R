#!/usr/bin/env Rscript

library(dplyr)
library(arrow)
library(jsonlite)
library(fs)
library(httr)
library(tibble)

# -------------------------
# Guards
# -------------------------

if (!dir_exists("data")) {
  stop("Run this script from repo root (nocap/)")
}

# -------------------------
# Load Data
# -------------------------

team_season <- read_parquet(
  "data/data_processed/team_season_xfp.parquet"
)

teams <- tribble(
  ~team_abbr, ~name,
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
  "LA", "Los Angeles Rams",
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
# Build team index
# -------------------------

team_index <- team_season %>%
  distinct(team_abbr = team) %>%
  left_join(teams, by = "team_abbr") %>%
  mutate(
    slug = name %>%
      tolower() %>%
      gsub("[^a-z0-9]+", "-", .) %>%
      gsub("(^-|-$)", "", .),
    active = TRUE
  ) %>%
  select(
    team_abbr,
    name,
    slug,
    active
  ) %>%
  arrange(name)

# -------------------------
# Write JSON
# -------------------------

dir_create("data/site_data", recurse = TRUE)
dir_create("public/data/site_data", recurse = TRUE)

write_json(
  team_index,
  "data/site_data/team_index.json",
  auto_unbox = TRUE,
  pretty = TRUE
)

file_copy(
  "data/site_data/team_index.json",
  "public/data/site_data/team_index.json",
  overwrite = TRUE
)

message("team_index.json written + mirrored to public 🚀")

# -------------------------
# Download team logos
# -------------------------

dir_create("public/data/team_logos", recurse = TRUE)

logo_urls <- c(
  "ARI" = "https://a.espncdn.com/i/teamlogos/nfl/500/ari.png",
  "ATL" = "https://a.espncdn.com/i/teamlogos/nfl/500/atl.png",
  "BAL" = "https://a.espncdn.com/i/teamlogos/nfl/500/bal.png",
  "BUF" = "https://a.espncdn.com/i/teamlogos/nfl/500/buf.png",
  "CAR" = "https://a.espncdn.com/i/teamlogos/nfl/500/car.png",
  "CHI" = "https://a.espncdn.com/i/teamlogos/nfl/500/chi.png",
  "CIN" = "https://a.espncdn.com/i/teamlogos/nfl/500/cin.png",
  "CLE" = "https://a.espncdn.com/i/teamlogos/nfl/500/cle.png",
  "DAL" = "https://a.espncdn.com/i/teamlogos/nfl/500/dal.png",
  "DEN" = "https://a.espncdn.com/i/teamlogos/nfl/500/den.png",
  "DET" = "https://a.espncdn.com/i/teamlogos/nfl/500/det.png",
  "GB"  = "https://a.espncdn.com/i/teamlogos/nfl/500/gb.png",
  "HOU" = "https://a.espncdn.com/i/teamlogos/nfl/500/hou.png",
  "IND" = "https://a.espncdn.com/i/teamlogos/nfl/500/ind.png",
  "JAX" = "https://a.espncdn.com/i/teamlogos/nfl/500/jax.png",
  "KC"  = "https://a.espncdn.com/i/teamlogos/nfl/500/kc.png",
  "LV"  = "https://a.espncdn.com/i/teamlogos/nfl/500/lv.png",
  "LAC" = "https://a.espncdn.com/i/teamlogos/nfl/500/lac.png",
  "LA" = "https://a.espncdn.com/i/teamlogos/nfl/500/lar.png",
  "MIA" = "https://a.espncdn.com/i/teamlogos/nfl/500/mia.png",
  "MIN" = "https://a.espncdn.com/i/teamlogos/nfl/500/min.png",
  "NE"  = "https://a.espncdn.com/i/teamlogos/nfl/500/ne.png",
  "NO"  = "https://a.espncdn.com/i/teamlogos/nfl/500/no.png",
  "NYG" = "https://a.espncdn.com/i/teamlogos/nfl/500/nyg.png",
  "NYJ" = "https://a.espncdn.com/i/teamlogos/nfl/500/nyj.png",
  "PHI" = "https://a.espncdn.com/i/teamlogos/nfl/500/phi.png",
  "PIT" = "https://a.espncdn.com/i/teamlogos/nfl/500/pit.png",
  "SEA" = "https://a.espncdn.com/i/teamlogos/nfl/500/sea.png",
  "SF"  = "https://a.espncdn.com/i/teamlogos/nfl/500/sf.png",
  "TB"  = "https://a.espncdn.com/i/teamlogos/nfl/500/tb.png",
  "TEN" = "https://a.espncdn.com/i/teamlogos/nfl/500/ten.png",
  "WAS" = "https://a.espncdn.com/i/teamlogos/nfl/500/was.png"
)

message("downloading team logos...")

for (abbr in names(logo_urls)) {
  dest <- paste0("public/data/team_logos/", abbr, ".png")
  if (file_exists(dest)) {
    next
  }
  tryCatch(
    GET(logo_urls[[abbr]], write_disk(dest, overwrite = TRUE)),
    error = function(e) message("failed: ", abbr)
  )
}

message("team logos downloaded successfully 🟢")
