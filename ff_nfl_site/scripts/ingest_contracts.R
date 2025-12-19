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
# Load contracts
# -------------------------
contracts_raw <- nflreadr::load_contracts()

# -------------------------
# Clean / standardize
# -------------------------
contracts_clean <- contracts_raw %>%
  mutate(
    start_year = as.integer(start_year),
    end_year   = as.integer(end_year)
  ) %>%
  select(
    gsis_id,
    player,
    position,
    team,
    start_year,
    end_year,
    years,
    value,
    apy,
    guaranteed,
    practical_guarantee
  ) %>%
  arrange(gsis_id, start_year)

# -------------------------
# Write output
# -------------------------
out_dir <- "data/site_data/contracts"
dir_create(out_dir, recurse = TRUE)

write_parquet(
  contracts_clean,
  file.path(out_dir, "contracts.parquet")
)

message("Contracts ingested ✅")
