# ============================================================
# THERMAL SENSATION DISTRIBUTION PLOT
# ============================================================
# This script creates a 100% stacked bar chart showing the
# distribution of thermal sensation votes across survey conditions.
#
# Required packages: tidyverse, scales
# Color palette: source from src/R/x_theme.R
# ============================================================

library(tidyverse)
library(scales)

# Load color palette
source(here::here("src", "R", "x_theme.R"))

# ------------------------------------------------------------
# DATA REQUIREMENTS
# ------------------------------------------------------------
# Your data should be a dataframe with:
#   - survey_id: factor identifying survey condition (e.g., "Baseline", "Post-retrofit")
#   - thermal_sensation: factor with levels c("Cold", "Cool", "Slightly cool", "Neutral", "Slightly warm", "Warm", "Hot")
#
# Example structure:
#   survey_id         thermal_sensation
#   <fct>             <fct>
#   Baseline          Neutral
#   Baseline          Slightly warm
#   Post-retrofit     Cool
#   ...
# ------------------------------------------------------------

# SAMPLE DATA (replace with your own data)
# This demonstrates the required data structure
thermal_sensation_levels <- c(
  "Cold", "Cool", "Slightly cool",
  "Neutral",
  "Slightly warm", "Warm", "Hot"
)
survey_ids <- c("Baseline", "Post-retrofit", "Control")

set.seed(123)
survey <- purrr::map_dfr(
  survey_ids,
  ~ tibble::tibble(
    survey_id = .x,
    thermal_sensation = sample(
      thermal_sensation_levels,
      size = 150,
      replace = TRUE,
      prob = case_when(
        .x == "Baseline"      ~ c(0.10, 0.15, 0.15, 0.20, 0.20, 0.15, 0.05),
        .x == "Post-retrofit" ~ c(0.05, 0.10, 0.10, 0.25, 0.25, 0.15, 0.10),
        .x == "Control"       ~ c(0.08, 0.12, 0.15, 0.22, 0.20, 0.15, 0.08),
        TRUE ~ rep(1/7, 7)
      )
    )
  )
) %>%
  mutate(
    survey_id = factor(survey_id, levels = survey_ids),
    thermal_sensation = factor(thermal_sensation, levels = thermal_sensation_levels)
  )

# ------------------------------------------------------------
# PLOT CODE
# ------------------------------------------------------------
ggplot(survey %>% drop_na(thermal_sensation),
       aes(x = survey_id, fill = thermal_sensation)) +
  geom_bar(position = position_fill(reverse = TRUE), show.legend = TRUE) +
  scale_y_continuous(labels = percent, expand = expansion(mult = c(0, 0.01))) +
  scale_fill_manual(values = thermal_sensation_palette, labels = label_wrap_gen(width = 9), drop = FALSE) +
  labs(y = "Percentage") +
  theme_minimal(base_size = 7) +
  theme(
    legend.position = "right",
    legend.direction = "vertical",
    legend.title = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.title.x = element_blank(),
    axis.ticks.y = element_line(color = "grey", linewidth = 0.25),
    axis.ticks.x = element_blank(),
    axis.ticks.length = unit(1, "mm")
  ) +
  guides(
    fill = guide_legend(
      reverse = TRUE,
      ncol = 1,
      byrow = TRUE,
      label.position = "right",
      keywidth = unit(7.5, "mm"),
      keyheight = unit(5, "mm"),
      label.hjust = 0,
      label.vjust = 0.5
    )
  )
