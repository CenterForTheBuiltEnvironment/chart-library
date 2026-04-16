# ============================================================
# THERMAL PERCEPTION PATCHWORK PLOT
# ============================================================
# This script creates a combined patchwork figure showing
# thermal sensation, preference, and acceptability distributions.
#
# Required packages: tidyverse, scales, patchwork
# Color palette: source from src/R/x_theme.R
# ============================================================

library(tidyverse)
library(scales)
library(patchwork)

# Load color palette
source(here::here("src", "R", "x_theme.R"))

# ------------------------------------------------------------
# DATA REQUIREMENTS
# ------------------------------------------------------------
# Your data should be a dataframe with:
#   - session_type: factor identifying survey condition
#   - thermal_sensation: factor with 7 levels (Cold to Hot)
#   - thermal_preference: factor with 3 levels (Warmer, No change, Cooler)
#   - acceptability_thermal: factor with 5 levels
# ------------------------------------------------------------

# SAMPLE DATA (replace with your own data)
thermal_sensation_levels <- c(
  "Cold", "Cool", "Slightly cool",
  "Neutral",
  "Slightly warm", "Warm", "Hot"
)
thermal_preference_levels <- c("Warmer", "No change", "Cooler")
acceptability_levels <- c(
  "Very unacceptable", "Somewhat unacceptable",
  "Neither nor",
  "Somewhat acceptable", "Very acceptable"
)
session_types <- c("Baseline", "Post-retrofit", "Control")

set.seed(123)
survey <- purrr::map_dfr(
  session_types,
  ~ tibble::tibble(
    session_type = .x,
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
    ),
    thermal_preference = sample(
      thermal_preference_levels,
      size = 150,
      replace = TRUE,
      prob = case_when(
        .x == "Baseline"      ~ c(0.45, 0.35, 0.20),
        .x == "Post-retrofit" ~ c(0.25, 0.50, 0.25),
        .x == "Control"       ~ c(0.40, 0.40, 0.20),
        TRUE ~ rep(1/3, 3)
      )
    ),
    acceptability_thermal = sample(
      acceptability_levels,
      size = 150,
      replace = TRUE,
      prob = case_when(
        .x == "Baseline"      ~ c(0.05, 0.10, 0.20, 0.35, 0.30),
        .x == "Post-retrofit" ~ c(0.02, 0.05, 0.10, 0.33, 0.50),
        .x == "Control"       ~ c(0.06, 0.10, 0.20, 0.34, 0.30),
        TRUE ~ rep(1/5, 5)
      )
    )
  )
) %>%
  mutate(
    session_type = factor(session_type, levels = session_types),
    thermal_sensation = factor(thermal_sensation, levels = thermal_sensation_levels),
    thermal_preference = factor(thermal_preference, levels = thermal_preference_levels),
    acceptability_thermal = factor(acceptability_thermal, levels = acceptability_levels)
  )

# ------------------------------------------------------------
# PLOT CODE
# ------------------------------------------------------------

# Create reusable function
plot_stacked_pct <- function(data, var, palette, legend_title = NULL) {
  
  df <- data %>%
    drop_na({{ var }})
  
  ggplot(df, aes(x = session_type, fill = {{ var }})) +
    geom_bar(position = "fill") +
    scale_y_continuous(labels = percent, expand = expansion(mult = c(0, 0.01))) +
    scale_fill_manual(values = palette, labels = label_wrap_gen(width = 9)) +
    labs(
      x = "Session type",
      y = "Percentage",
      fill = legend_title   # <-- key addition
    ) +
    theme_minimal(base_size = 7) +
    theme(
      legend.position = "right",
      legend.direction = "vertical",
      legend.title = if (is.null(legend_title)) element_blank() else element_text(size = 6),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      axis.title.x = element_text(margin = margin(t = 6)),
      axis.ticks.y = element_line(color = "grey", linewidth = 0.25),
      axis.ticks.x = element_blank(),
      axis.ticks.length = unit(1, "mm")
    ) +
    guides(
      fill = guide_legend(
        ncol = 1,
        byrow = TRUE,
        label.position = "right",
        keywidth  = unit(7.5, "mm"),
        keyheight = unit(5, "mm"),
        label.hjust = 0,
        label.vjust = 0.5
      )
    )
}

# Generate subplots
thermal_sensation_p <- plot_stacked_pct(survey, thermal_sensation, thermal_sensation_palette, "I feel ...") + labs(subtitle = "Thermal sensation")
thermal_preference_p <- plot_stacked_pct(survey, thermal_preference, thermal_preference_palette, "I prefer to be ...") + labs(subtitle = "Thermal preference")
thermal_acceptability_p <- plot_stacked_pct(survey, acceptability_thermal, acceptability_palette, "I find the thermal\nenvironment ...") + labs(subtitle = "Thermal acceptability")

thermal_perception <- (thermal_sensation_p / thermal_preference_p / thermal_acceptability_p) +
  plot_layout(axis_titles = "collect") +
  plot_annotation(tag_levels = "a", tag_suffix = ".") &
  theme(
    plot.subtitle = element_text(hjust = 0.1, margin = margin(b = 3, unit = "mm")),
    plot.tag = element_text(size = 7, face = "bold"),
    axis.title = element_text(margin = margin(r = 2, unit = "mm")),
    legend.position = "right",
    legend.justification = "left",
    legend.box.margin = margin(l = 0)
  )

thermal_perception