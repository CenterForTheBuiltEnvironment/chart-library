thermal_sensation_palette <- c("#6b8dd6", "#82c6ed","#b8e4f7","#c9e0b0","#f7a9b7","#eb6b58","#b44a4a")

thermal_preference_palette <- c("#82c6ed", "#c9e0b0", "#eb6b58")

acceptability_palette <- c('#bc3e4d','#d99fa8','#f0f0f0','#c1e0b9','#38a257')

# Shared theme for simulation / timeseries comfort plots
theme_ep <- function(...) {
  theme_minimal(base_size = 11) +
    theme(
      plot.title    = element_text(size = 13, face = "bold", margin = margin(b = 4)),
      plot.subtitle = element_text(size = 10, colour = "grey35", margin = margin(b = 10)),
      plot.caption  = element_text(size = 8,  colour = "grey45", hjust = 0),
      panel.grid.minor = element_blank(),
      legend.position  = "bottom",
      legend.key.size  = unit(0.4, "cm"),
      strip.text       = element_text(face = "bold"),
      ...
    )
}

# ASHRAE 55 comfort category colours (used for PMV and SET categorisation)
comfort_colours <- c(
  "Cool discomfort" = "#3A85C6",
  "Comfortable"     = "#4CAF7D",
  "Warm discomfort" = "#E05C4B"
)