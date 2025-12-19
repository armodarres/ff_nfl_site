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

options(arrow.verbose_warnings = FALSE)

out_dir <- "data/site_data/pfr_advstats"
dir_create(out_dir, recurse = TRUE)

seasons <- TRUE  # all available (2018+)

# -------------------------
# Passing
# -------------------------
pfr_pass <- nflreadr::load_pfr_advstats(
  seasons = seasons,
  stat_type = "pass",
  summary_level = "week",
  file_type = "parquet"
)

write_parquet(
  pfr_pass,
  file.path(out_dir, "pfr_pass_week.parquet")
)

# -------------------------
# Rushing
# -------------------------
pfr_rush <- nflreadr::load_pfr_advstats(
  seasons = seasons,
  stat_type = "rush",
  summary_level = "week",
  file_type = "parquet"
)

write_parquet(
  pfr_rush,
  file.path(out_dir, "pfr_rush_week.parquet")
)

# -------------------------
# Receiving
# -------------------------
pfr_rec <- nflreadr::load_pfr_advstats(
  seasons = seasons,
  stat_type = "rec",
  summary_level = "week",
  file_type = "parquet"
)

write_parquet(
  pfr_rec,
  file.path(out_dir, "pfr_rec_week.parquet")
)

# -------------------------
# Defense
# -------------------------
pfr_def <- nflreadr::load_pfr_advstats(
  seasons = seasons,
  stat_type = "def",
  summary_level = "week",
  file_type = "parquet"
)

write_parquet(
  pfr_def,
  file.path(out_dir, "pfr_def_week.parquet")
)

message("PFR advanced stats ingested (separate dfs) ✅")
