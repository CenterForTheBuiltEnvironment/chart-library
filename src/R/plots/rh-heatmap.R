library(tidyverse)
library(scales)

source(here::here("src", "R", "x_theme.R"))

# ------------------------------------------------------------
# DATA REQUIREMENTS
# ------------------------------------------------------------
# Your data should be a dataframe with:
#   - doy:       integer, day of year (1–365)
#   - hour_day:  integer, hour of day (0–23)
#   - living_rh: numeric, zone indoor relative humidity [%]
# ------------------------------------------------------------

# SAMPLE DATA (replace with your own hourly timeseries)
set.seed(42)
ep_synth <- expand.grid(doy = 1:365, hour_day = 0:23) %>%
  as_tibble() %>%
  mutate(
    annual    = -cos(2 * pi * doy / 365),
    diurnal   = sin(pi * hour_day / 12 - pi / 6),
    # RH peaks in the cool/wet season; summer heating/drying lowers it
    living_rh = 55 - 15 * annual - 3 * diurnal + rnorm(n(), 0, 2)
    # range ≈ 25–80 %, triggering both the <40 % and >70 % thresholds
  )

# ------------------------------------------------------------
# PLOT
# ------------------------------------------------------------
ep_synth %>%
  ggplot(aes(x = doy, y = hour_day, fill = living_rh)) +
  geom_tile() +
  scale_fill_gradientn(
    colours = c("#FFFFFF", "#C6DBEF", "#6BAED6", "#2171B5", "#084594"),
    limits  = c(15, 85),
    oob     = squish,
    name    = "RH (%)"
  ) +
  geom_tile(
    data   = . %>% filter(living_rh < 40),
    fill   = NA, colour = "#4BE07D", linewidth = 0.1, alpha = 0.6
  ) +
  geom_tile(
    data   = . %>% filter(living_rh > 70),
    fill   = NA, colour = "#F39704", linewidth = 0.1, alpha = 0.6
  ) +
  scale_x_continuous(
    breaks = c(0, cumsum(c(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31))),
    labels = c(month.abb, ""),
    expand = c(0, 0)
  ) +
  scale_y_continuous(breaks = seq(0, 23, 6), expand = c(0, 0)) +
  labs(
    title    = "Annual relative humidity heatmap — Living zone",
    subtitle = "Orange-outlined cells exceed 70 % RH (mold risk) · Green-outlined cells below 40 % RH (dryness risk)",
    x = "Month",
    y = "Hour of day"
  ) +
  theme_ep() +
  theme(
    panel.grid        = element_blank(),
    legend.position   = "right",
    legend.key.height = unit(1.5, "cm")
  )
