
source(here::here("src", "R", "x_data.R"))
source(here::here("src", "R", "x_func.R"))
source(here::here("src", "R", "x_theme.R"))

# OPTIONAL: Generate dataframe for manuscript writing
thermal_preference_d <- stacked_pct_data(survey, thermal_preference)

plot_stacked_pct(survey, thermal_preference, thermal_preference_palette)