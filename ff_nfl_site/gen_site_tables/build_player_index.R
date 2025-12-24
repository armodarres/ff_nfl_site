library(dplyr)
library(arrow)
library(jsonlite)
library(stringr)
library(lubridate)
library(purrr)

# -------------------------
# Paths
# -------------------------

players_path <- "data/data_processed/players.parquet"
output_root <- "data/site_data/players"

# -------------------------
# Load players
# -------------------------

players <- read_parquet(players_path)

# -------------------------
# Team colors lookup
# -------------------------

team_colors <- tibble::tribble(
  ~team, ~primary, ~secondary,
  "ARI", "#97233F", "#000000",
  "ATL", "#A71930", "#000000",
  "BAL", "#241773", "#000000",
  "BUF", "#00338D", "#C60C30",
  "CAR", "#0085CA", "#101820",
  "CHI", "#0B162A", "#C83803",
  "CIN", "#FB4F14", "#000000",
  "CLE", "#311D00", "#FF3C00",
  "DAL", "#003594", "#869397",
  "DEN", "#FB4F14", "#0A2342",
  "DET", "#0076B6", "#B0B7BC",
  "GB", "#203731", "#FFB612",
  "HOU", "#03202F", "#A71930",
  "IND", "#002C5F", "#A2AAAD",
  "JAX", "#006778", "#9F792C",
  "KC", "#E31837", "#FFB81C",
  "LV", "#000000", "#A5ACAF",
  "LAC", "#0080C6", "#FFC20E",
  "LAR", "#003594", "#FFD100",
  "MIA", "#008E97", "#F58220",
  "MIN", "#4F2683", "#FFC62F",
  "NE", "#002244", "#C60C30",
  "NO", "#D3BC8D", "#101820",
  "NYG", "#0B2265", "#A71930",
  "NYJ", "#125740", "#000000",
  "PHI", "#004C54", "#A5ACAF",
  "PIT", "#FFB612", "#101820",
  "SEA", "#002244", "#69BE28",
  "SF", "#AA0000", "#B3995D",
  "TB", "#D50A0A", "#34302B",
  "TEN", "#0C2340", "#4B92DB",
  "WAS", "#5A1414", "#FFB612"
)

# -------------------------
# Vectorized helpers
# -------------------------

compute_age <- function(dob_vec) {
  suppressWarnings({
    out <- floor(interval(ymd(dob_vec), today()) / years(1))
    out[is.na(dob_vec)] <- NA_real_
    out
  })
}

compute_seasons <- function(entry_year_vec) {
  current <- year(Sys.Date())
  out <- current - entry_year_vec + 1
  out[is.na(entry_year_vec)] <- NA_real_
  out
}

# -------------------------
# Create root if missing
# -------------------------

if (!dir.exists(output_root)) {
  dir.create(output_root, recursive = TRUE)
}

# -------------------------
# Generate JSON for each player
# -------------------------

players_clean <- players %>%
  # dedupe to one row per player
  arrange(desc(season)) %>%
  group_by(gsis_id) %>%
  slice(1) %>%
  ungroup() %>%
  mutate(
    age = compute_age(birth_date),
    seasons_played = years_exp,  # prefer years_exp over rookie_year logic
  ) %>%
  left_join(team_colors, by = c("recent_team" = "team")) %>%
  mutate(
    primary = ifelse(is.na(primary), "#888888", primary),
    secondary = ifelse(is.na(secondary), "#DDDDDD", secondary)
  )

players_clean %>% pwalk(function(
    season, team, position, depth_chart_position, jersey_number, status,
    full_name, first_name, last_name, birth_date, height, weight, college,
    gsis_id, espn_id, sportradar_id, yahoo_id, rotowire_id, pff_id, pfr_id,
    fantasy_data_id, sleeper_id, years_exp, ngs_position, week, game_type,
    status_description_abbr, football_name, esb_id, gsis_it_id, smart_id,
    entry_year, rookie_year, draft_club, draft_number, player_name,
    recent_team, headshot_url, age, seasons_played, primary, secondary
) {
  
  out_dir <- file.path(output_root, paste0("player_id=", gsis_id))
  
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
  
  json_obj <- list(
    name = full_name,
    team = recent_team,
    pos = position,
    gsis_id = gsis_id,
    age = age,
    season = seasons_played,
    college = college,
    jersey_number = jersey_number,
    status = status,
    height = height,
    weight = weight,
    draft_team = draft_club,
    draft_pick = draft_number,
    highest_finish = NA,
    avg_finish = NA,
    archetype = NA,
    team_colors = list(
      primary = primary,
      secondary = secondary
    ),
    headshot_url = headshot_url
  )
  
  write_json(
    json_obj,
    file.path(out_dir, "player.json"),
    auto_unbox = TRUE,
    pretty = TRUE
  )
})

cat("Header player JSONs generated successfully.\n")
