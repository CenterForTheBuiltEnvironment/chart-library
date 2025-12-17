library(tidyverse)
library(scales)

stacked_pct_data <- function(data, var) {
  
  var <- rlang::enquo(var)
  
  data %>%
    drop_na(!!var) %>%
    count(survey_id, !!var, name = "n") %>%
    group_by(survey_id) %>%
    mutate(
      pct = n / sum(n),
      pct_label = scales::percent(pct, accuracy = 1)
    ) %>%
    ungroup()
}

plot_stacked_pct <- function(data, var, palette) {
  
  df <- data %>%
    drop_na({{ var }})
  
  ggplot(df, aes(x = survey_id, fill = {{ var }})) +
    geom_bar(position = "fill") +
    scale_y_continuous(labels = percent, expand = expansion(mult = c(0, 0.01))) +
    scale_fill_manual(values = palette, labels = label_wrap_gen(width = 9)) +
    labs(y = "Percentage") +
    theme_minimal(base_size = 7) +
    theme(
      legend.position = "right",
      legend.direction = "vertical",
      legend.title = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      # axis.title.x = element_text(margin = margin(t = 6)),
      axis.title.x = element_blank(),
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


palette_strip_plot <- function(df) {

  ggplot(df, aes(x = x, y = y)) +
    geom_tile(aes(fill = color), height = 0.8) +
    geom_text(aes(label = level), y = 1.7, size = 3.5) +
    geom_text(aes(label = color),
              y = 1, size = 3.5, family = "mono") +
    geom_text(aes(label = label), y = 0.2, size = 3.5) +
    scale_fill_identity() +
    coord_cartesian(ylim = c(0.2, 1.8), clip = "off") +
    theme_void() +
    theme(
      plot.margin = margin(10, 5, 10, 5)
    )
}