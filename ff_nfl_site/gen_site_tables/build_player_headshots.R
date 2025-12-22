#!/usr/bin/env Rscript

library(dplyr)
library(arrow)
library(fs)
library(httr)

# ============================================================
# Player headshot downloader
#
# Input:
#   data/data_processed/players.parquet
#
# Output:
#   public/headshots/<gsis_id>.png
# ============================================================

# -------------------------
# Guards
# -------------------------

if (!dir_exists("data")) {
  stop("Run this script from repo root (nocap/)")
}

# -------------------------
# Load base player table
# -------------------------

players <- read_parquet(
  "data/data_processed/players.parquet"
)

# -------------------------
# Create local headshot directory
# -------------------------

dir_create("public/headshots")

# -------------------------
# Ensure fallback image exists
# -------------------------

fallback_src <- "public/headshots/missing.png"
if (!file_exists(fallback_src)) {
  file_copy("public/missing.png", fallback_src)
}

# -------------------------
# Download headshots
# -------------------------

message("Downloading headshots...")

players %>%
  filter(!is.na(headshot_url), headshot_url != "") %>%
  pull(gsis_id) %>%
  unique() %>%
  walk(function(pid) {
    
    url <- players %>%
      filter(gsis_id == pid) %>%
      slice(1) %>%
      pull(headshot_url)
    
    dest <- paste0("public/headshots/", pid, ".png")
    
    # Skip if exists
    if (file_exists(dest)) return()
    
    # Attempt download
    tryCatch(
      {
        GET(
          paste0(url, ".png"),
          write_disk(dest, overwrite = TRUE),
          timeout(20)
        )
      },
      error = function(e) {
        file_copy(fallback_src, dest, overwrite = TRUE)
      }
    )
  })

message("Headshot download complete 🟢")
