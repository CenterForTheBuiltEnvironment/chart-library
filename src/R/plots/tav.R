
source(here::here("src", "R", "x_data.R"))
source(here::here("src", "R", "x_func.R"))
source(here::here("src", "R", "x_theme.R"))

# OPTIONAL: Generate dataframe for manuscript writing
thermal_acceptability_d <- stacked_pct_data(survey, thermal_acceptability)

plot_stacked_pct(survey, thermal_acceptability, acceptability_palette)