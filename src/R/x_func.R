library(ggplot2)

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
