library(tidyverse)
library(scales)

source(here::here("src", "R", "x_theme.R"))

# ------------------------------------------------------------
# DATA REQUIREMENTS
# ------------------------------------------------------------
# Your data should be a dataframe with:
#   - living_oat:  numeric, zone operative temperature [°C]
#   - living_rh:   numeric, zone relative humidity [%]
#   - pmv:         numeric, Predicted Mean Vote (e.g. Pierce model)
#   - occupied:    integer, 0/1 occupancy indicator
#   - season:      factor, "Winter" / "Spring" / "Summer" / "Autumn"
#   - run_avg_oat: numeric, prevailing mean outdoor air temperature [°C]
# ------------------------------------------------------------

# SAMPLE DATA (replace with your own hourly timeseries)
set.seed(42)
ep_synth <- tibble(
  doy      = rep(1:365, each = 24),
  hour_day = rep(0:23, 365)
) %>%
  mutate(
    month_num   = as.integer(format(as.Date(doy - 1, origin = "2025-01-01"), "%m")),
    annual      = -cos(2 * pi * doy / 365),
    diurnal     = sin(pi * hour_day / 12 - pi / 6),
    living_oat  = 21 + 5.5 * annual + 2.5 * diurnal + rnorm(n(), 0, 0.6),
    living_rh   = 55 - 15 * annual - 3 * diurnal + rnorm(n(), 0, 2),
    run_avg_oat = 15 + 7 * annual,
    pmv         = (living_oat - 23) / 4 + rnorm(n(), 0, 0.2),
    occupied    = as.integer(hour_day >= 7 & hour_day <= 22),
    season      = factor(case_when(
      month_num %in% c(12, 1, 2) ~ "Winter",
      month_num %in% c(3, 4, 5)  ~ "Spring",
      month_num %in% c(6, 7, 8)  ~ "Summer",
      TRUE                        ~ "Autumn"
    ), levels = c("Winter", "Spring", "Summer", "Autumn"))
  )

# ASHRAE 55 adaptive comfort polygon (one rectangle spanning all seasons)
ashrae_bands <- ep_synth %>%
  group_by(season) %>%
  summarise(mean_pma = mean(run_avg_oat, na.rm = TRUE), .groups = "drop") %>%
  mutate(
    ashrae_upper = 0.31 * mean_pma + 21.3,
    ashrae_lower = 0.31 * mean_pma + 14.3
  )

temp_low_bound <- min(ashrae_bands$ashrae_lower)
temp_up_bound  <- max(ashrae_bands$ashrae_upper)

ashrae_poly <- tibble(
  x = c(temp_low_bound, temp_up_bound, temp_up_bound, temp_low_bound),
  y = c(40, 40, 70, 70)
)

# PMV comfort categories for occupied hours
psychro_data <- ep_synth %>%
  filter(occupied > 0) %>%
  mutate(
    pmv_cat = factor(case_when(
      pmv < -0.5 ~ "Cool discomfort",
      pmv >  0.5 ~ "Warm discomfort",
      TRUE        ~ "Comfortable"
    ), levels = names(comfort_colours))
  )

# ------------------------------------------------------------
# PLOT
# ------------------------------------------------------------
ggplot(psychro_data, aes(x = living_oat, y = living_rh, colour = pmv_cat)) +
  geom_point(alpha = 0.35, size = 0.8) +
  geom_polygon(
    data = ashrae_poly, aes(x = x, y = y),
    inherit.aes = FALSE, fill = "#4CAF7D", alpha = 0.08,
    colour = "#4CAF7D", linetype = "dashed", linewidth = 0.5
  ) +
  annotate("text",
           x = temp_low_bound + 0.5, y = 68,
           label = "ASHRAE 55 indicative region",
           size = 2.6, colour = "#4CAF7D", hjust = 0) +
  scale_colour_manual(values = comfort_colours, name = "Comfort category (PMV)") +
  guides(colour = guide_legend(override.aes = list(size = 3, alpha = 1))) +
  labs(
    title    = "Operative temperature vs relative humidity — Living zone",
    subtitle = "Each point = 1 occupied hour  |  Coloured by PMV comfort category",
    x = "Operative temperature (°C)",
    y = "Relative humidity (%)"
  ) +
  theme_ep()
