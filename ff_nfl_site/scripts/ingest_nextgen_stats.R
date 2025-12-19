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

out_dir <- "data/site_data/nextgen"
dir_create(out_dir, recurse = TRUE)

seasons <- TRUE  # load all available

# -------------------------
# Passing
# -------------------------
ngs_passing <- nflreadr::load_nextgen_stats(
  seasons = seasons,
  stat_type = "passing",
  file_type = "parquet"
)

write_parquet(
  ngs_passing,
  file.path(out_dir, "ngs_passing_week.parquet")
)

# -------------------------
# Receiving
# -------------------------
ngs_receiving <- nflreadr::load_nextgen_stats(
  seasons = seasons,
  stat_type = "receiving",
  file_type = "parquet"
)

write_parquet(
  ngs_receiving,
  file.path(out_dir, "ngs_receiving_week.parquet")
)

# -------------------------
# Rushing
# -------------------------
ngs_rushing <- nflreadr::load_nextgen_stats(
  seasons = seasons,
  stat_type = "rushing",
  file_type = "parquet"
)

write_parquet(
  ngs_rushing,
  file.path(out_dir, "ngs_rushing_week.parquet")
)

message("Next Gen Stats ingested (separate dfs) ✅")
