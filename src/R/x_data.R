library(tidyverse)

thermal_sensation_levels <- c(
  "Cold", "Cool", "Slightly cool",
  "Neutral",
  "Slightly warm", "Warm", "Hot"
)

thermal_preference_levels <- c(
  "Cooler", "No change", "Warmer"
)

acceptability_levels <- c(
  "Very unacceptable", "Somewhat unacceptable",
  "Neither nor",
  "Somewhat acceptable", "Very acceptable"
)


set.seed(123)  # for reproducibility

survey_ids <- c("Baseline", "Post-retrofit", "Control")

n_per_session <- 150

survey <- purrr::map_dfr(
  survey_ids,
  ~ tibble::tibble(
    survey_id = .x,
    thermal_sensation = sample(
      thermal_sensation_levels,
      size  = n_per_session,
      replace = TRUE,
      prob = dplyr::case_when(
        .x == "Baseline"      ~ c(0.10, 0.15, 0.15, 0.20, 0.20, 0.15, 0.05),
        .x == "Post-retrofit" ~ c(0.05, 0.10, 0.10, 0.25, 0.25, 0.15, 0.10),
        .x == "Control"       ~ c(0.08, 0.12, 0.15, 0.22, 0.20, 0.15, 0.08),
        TRUE                  ~ rep(1/7, 7)
      )
    ),
    thermal_preference = sample(
      thermal_preference_levels,
      size = n_per_session,
      replace = TRUE,
      prob = dplyr::case_when(
        .x == "Baseline"      ~ c(0.45, 0.35, 0.20),
        .x == "Post-retrofit" ~ c(0.25, 0.50, 0.25),
        .x == "Control"       ~ c(0.40, 0.40, 0.20),
        TRUE                  ~ rep(1/3, 3)
      )
    ),
    thermal_acceptability = sample(
      acceptability_levels,
      size = n_per_session,
      replace = TRUE,
      prob = dplyr::case_when(
        .x == "Baseline"      ~ c(0.05, 0.10, 0.20, 0.35, 0.30),
        .x == "Post-retrofit" ~ c(0.02, 0.05, 0.10, 0.33, 0.50),
        .x == "Control"       ~ c(0.06, 0.10, 0.20, 0.34, 0.30),
        TRUE                  ~ rep(1/5, 5)
      )
    )
  )
) %>%
  dplyr::mutate(
    survey_id         = factor(survey_id, levels = survey_ids),
    thermal_sensation    = factor(thermal_sensation,    levels = thermal_sensation_levels),
    thermal_preference   = factor(thermal_preference,   levels = thermal_preference_levels),
    thermal_acceptability = factor(thermal_acceptability, levels = acceptability_levels)
  )

