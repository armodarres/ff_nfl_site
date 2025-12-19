# ============================================================
# Ingest and normalize coaching datasets
#
# Sources:
#   - coaching_histories.csv
#   - all_playcallers.csv
#   - coaching_trees.csv
#
# Output:
#   data/site_data/coaches/*.parquet
# ============================================================

library(dplyr)
library(readr)
library(stringr)
library(arrow)
library(fs)

# -------------------------
# Guard
# -------------------------
if (!dir_exists("data")) {
  stop("Run from repo root")
}

# -------------------------
# Helpers
# -------------------------
normalize_name <- function(x) {
  x |>
    tolower() |>
    str_replace_all("[^a-z ]", "") |>
    str_squish()
}

out_dir <- "data/site_data/coaches"
dir_create(out_dir, recurse = TRUE)

# -------------------------
# Load data from GitHub
# -------------------------
coaching_histories <- read_csv(
  "https://raw.githubusercontent.com/samhoppen/NFL_public/main/data/coaching_histories.csv",
  show_col_types = FALSE
)

all_playcallers <- read_csv(
  "https://raw.githubusercontent.com/samhoppen/NFL_public/main/data/all_playcallers.csv",
  show_col_types = FALSE
)

coaching_trees <- read_csv(
  "https://raw.githubusercontent.com/samhoppen/NFL_public/main/data/coaching_trees.csv",
  show_col_types = FALSE
)

yearly_coaching_history <- read_csv(
  "https://raw.githubusercontent.com/samhoppen/NFL_public/main/data/yearly_coaching_history.csv",
  show_col_types = FALSE
)

# -------------------------
# Normalize names
# -------------------------

coach_names <- yearly_coaching_history %>%
  distinct(coach_id, coach_name = coach) %>%
  mutate(
    coach_name_norm = normalize_name(coach_name)
  )

coaching_histories_clean <- coaching_histories %>%
  left_join(coach_names, by = "coach_id")

coaching_trees_clean <- coaching_trees %>%
  mutate(
    name_norm = normalize_name(Name)
  )

all_playcallers_clean <- all_playcallers %>%
  mutate(
    off_play_caller_norm = normalize_name(off_play_caller),
    def_play_caller_norm = normalize_name(def_play_caller),
    head_coach_norm      = normalize_name(head_coach)
  )
# -------------------------
# Build name -> coach_id map
# -------------------------
name_map <- coach_names %>%
  select(coach_id, coach_name_norm)

name_map <- name_map %>%
  filter(!grepl("/", coach_id))

name_map <- name_map %>%
  distinct(coach_name_norm, coach_id)

name_map <- name_map %>%
  group_by(coach_name_norm) %>%
  arrange(coach_id) %>%   # MoraJi0 comes before MoraJi1
  slice(1) %>%            # keep the first (the *0 one)
  ungroup()


# -------------------------
# Attach coach_id to playcallers
# -------------------------

all_playcallers_clean_final <- all_playcallers_clean %>%
  # OFFENSIVE PLAYCALLER
  left_join(
    name_map %>%
      rename(
        off_play_caller_id = coach_id,
        off_play_caller_norm = coach_name_norm
      ),
    by = "off_play_caller_norm"
  ) %>%
  
  # DEFENSIVE PLAYCALLER
  left_join(
    name_map %>%
      rename(
        def_play_caller_id = coach_id,
        def_play_caller_norm = coach_name_norm
      ),
    by = "def_play_caller_norm"
  ) %>%
  
  # HEAD COACH
  left_join(
    name_map %>%
      rename(
        head_coach_id = coach_id,
        head_coach_norm = coach_name_norm
      ),
    by = "head_coach_norm"
  )



write_parquet(
  coaching_histories_clean,
  file.path(out_dir, "coaching_histories_clean.parquet")
)

write_parquet(
  coaching_trees_clean,
  file.path(out_dir, "coaching_trees_clean.parquet")
)

write_parquet(
  all_playcallers_clean_final,
  file.path(out_dir, "all_playcallers_clean.parquet")
)

message("Coaching data ingested + names merged ✅")