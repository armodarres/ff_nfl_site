library(dplyr)
library(arrow)
library(jsonlite)
library(stringr)
library(fs)
library(httr)

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
# Merge latest metadata
# -------------------------

merged <- players %>%
  group_by(gsis_id) %>%
  arrange(desc(season)) %>%
  slice(1) %>%
  ungroup() %>%
  left_join(season_summary, by = "gsis_id") %>%
  mutate(
    active = status == "ACT",
    slug = full_name %>%
      str_to_lower() %>%
      str_replace_all("[^a-z0-9]+", "-") %>%
      str_replace_all("(^-|-$)", "")
  ) %>%
  filter(
    position %in% c("QB", "RB", "WR", "TE"),
    !is.na(first_season)
  )

# -------------------------
# Create local headshot directory
# -------------------------

dir_create("public/headshots")

# -------------------------
# Download headshots by gsis_id
# -------------------------

message("Downloading headshots locally...")

# Ensure fallback exists
fallback_src <- "public/headshots/missing.png"
if (!file_exists(fallback_src)) {
  file_copy("public/missing.png", fallback_src)
}

# Download each headshot safely
for (i in 1:nrow(merged)) {
  pid <- merged$gsis_id[i]
  url <- merged$headshot_url[i]
  
  # Skip NA / blank URLs
  if (is.na(url) || url == "") {
    next
  }
  
  # Build final URL
  full_url <- paste0(url, ".png")
  dest <- paste0("public/headshots/", pid, ".png")
  
  # Skip if file already exists
  if (file_exists(dest)) next
  
  # Attempt download with retry
  tryCatch(
    {
      GET(
        full_url,
        write_disk(dest, overwrite = TRUE),
        timeout(20)
      )
    },
    error = function(e) {
      message("⚠️ Failed: ", pid)
      # write fallback
      file_copy(fallback_src, dest, overwrite = TRUE)
    }
  )
}

message("Headshot download complete 🟢")


# -------------------------
# Create final index table
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
    headshot = paste0("/headshots/", gsis_id, ".png"),
    first_season,
    last_season
  ) %>%
  arrange(name)

# -------------------------
# Write final JSON
# -------------------------

dir_create("data/site_data", recurse = TRUE)

write_json(
  player_index,
  "data/site_data/player_index.json",
  auto_unbox = TRUE,
  pretty = TRUE
)

# -------------------------
# Mirror to public
# -------------------------

dir_create("public/data/site_data", recurse = TRUE)

file_copy(
  "data/site_data/player_index.json",
  "public/data/site_data/player_index.json",
  overwrite = TRUE
)

message("\nplayer_index.json written + mirrored to public 🌐")
message("Total players: ", nrow(player_index))
