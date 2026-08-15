library(tidyverse)
library(scales)
library(patchwork)

source(here::here("src", "R", "x_theme.R"))

# ------------------------------------------------------------
# DATA REQUIREMENTS
# ------------------------------------------------------------
# Your data should be a dataframe with:
#   - set:       numeric, Standard Effective Temperature [°C]
#   - month_num: integer, month number (1–12)
#   - occupied:  integer, 0/1 occupancy indicator
#   - cooling:   numeric, cooling energy per timestep [J]
#   - heating:   numeric, heating energy per timestep [J]
# ------------------------------------------------------------

# SAMPLE DATA (replace with your own hourly timeseries)
set.seed(42)
ep_synth <- expand.grid(doy = 1:365, hour_day = 0:23) %>%
  as_tibble() %>%
  mutate(
    month_num = as.integer(format(as.Date(doy - 1, origin = "2025-01-01"), "%m")),
    annual    = -cos(2 * pi * doy / 365),
    diurnal   = sin(pi * hour_day / 12 - pi / 6),
    set       = 23 + 2.5 * annual + 1.2 * diurnal + rnorm(n(), 0, 0.5),
    occupied  = as.integer(hour_day >= 7 & hour_day <= 22),
    cooling   = pmax(0, 2e6 * annual + rnorm(n(), 0, 3e5)),
    heating   = pmax(0, -1.2e6 * annual + rnorm(n(), 0, 2e5))
  )

# Monthly SET breakdown (ASHRAE 55 comfort range: 22.2–25.6 °C)
monthly_comfort <- ep_synth %>%
  filter(occupied > 0) %>%
  mutate(
    comfort_cat = factor(case_when(
      set < 22.2 ~ "Cool discomfort",
      set > 25.6 ~ "Warm discomfort",
      TRUE        ~ "Comfortable"
    ), levels = names(comfort_colours))
  ) %>%
  count(month_num, comfort_cat) %>%
  group_by(month_num) %>%
  mutate(pct = n / sum(n) * 100) %>%
  ungroup() %>%
  mutate(month = factor(month.abb[month_num], levels = month.abb))

# Monthly HVAC energy (J → kWh)
monthly_energy <- ep_synth %>%
  group_by(month_num) %>%
  summarise(
    cool_kwh = sum(cooling, na.rm = TRUE) / 3.6e6,
    heat_kwh = sum(heating, na.rm = TRUE) / 3.6e6,
    .groups  = "drop"
  ) %>%
  mutate(month = factor(month.abb[month_num], levels = month.abb))

max_kwh <- max(monthly_energy$cool_kwh, monthly_energy$heat_kwh)

# ------------------------------------------------------------
# PLOT
# ------------------------------------------------------------
p_stack <- ggplot(monthly_comfort, aes(x = month, y = pct, fill = comfort_cat)) +
  geom_col(width = 0.7) +
  scale_fill_manual(values = comfort_colours, name = NULL) +
  scale_y_continuous(labels = label_percent(scale = 1)) +
  labs(
    title    = "Energy vs comfort tradeoff",
    subtitle = "Monthly SET comfort breakdown and HVAC energy consumption",
    x = NULL, y = "% occupied hours"
  ) +
  theme_ep()

p_energy <- ggplot(monthly_energy, aes(x = month)) +
  geom_col(aes(y = cool_kwh),  fill = "#3A85C6", alpha = 0.8, width = 0.7) +
  geom_col(aes(y = -heat_kwh), fill = "#E05C4B", alpha = 0.8, width = 0.7) +
  geom_hline(yintercept = 0, linewidth = 0.3) +
  annotate("text", x = 0.6, y =  max_kwh * 0.7,
           label = "Cooling (↑)", size = 2.8, colour = "#3A85C6", hjust = 0) +
  annotate("text", x = 0.6, y = -max_kwh * 0.7,
           label = "Heating (↓)", size = 2.8, colour = "#E05C4B", hjust = 0) +
  labs(x = NULL, y = "HVAC energy (kWh)") +
  theme_ep()

p_stack / p_energy + plot_layout(heights = c(2, 1.2))
