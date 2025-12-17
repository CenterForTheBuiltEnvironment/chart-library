# CBE Chart Library

A curated gallery of data visualizations for building science and indoor environmental quality research, maintained by UC Berkeley's [Center for the Built Environment](https://cbe.berkeley.edu/).

**[View the live site](https://centerforthebuiltenvironment.github.io/chart-library/)**

## Overview

The CBE Chart Library provides:

- **Plot Gallery** — Reusable visualization patterns for survey data, thermal comfort metrics, and building performance analysis
- **Styling Guidelines** — Standards for publication-ready figures including color palettes, typography, and layout recommendations
- **Code Examples** — Tutorials and templates for R, Python, and reproducible research workflows

The goal is to promote consistency across CBE research outputs and reduce time spent reformatting figures for publications.

## Quick Start

### View the Site Locally

```bash
# Clone the repository
git clone https://github.com/centerforthebuiltenvironment/chart-library.git
cd chart-library

# Restore R packages
R -e "renv::restore()"

# Preview the site
quarto preview
```

### Requirements

- [Quarto](https://quarto.org/) (v1.3 or later)
- [R](https://www.r-project.org/) (v4.4+)
- R packages managed via `renv`

## Project Structure

```
chart-library/
├── pages/
│   ├── plots/          # Gallery entries (one .qmd per visualization)
│   ├── styling/        # Color palettes, typography, guidelines
│   ├── code/           # R, Python, Git tutorials
│   └── resources/      # External references
├── src/
│   └── R/
│       ├── plots/      # Standalone R scripts for each plot
│       ├── x_data.R    # Sample data and factor definitions
│       ├── x_func.R    # Reusable plotting functions
│       └── x_theme.R   # Color palette definitions
├── styles/
│   └── custom.css      # Site styling
├── docs/               # Generated site (GitHub Pages)
└── _quarto.yml         # Quarto configuration
```

## Contributing

Contributions are welcome! Here's how you can help:

### Adding a New Plot

1. **Create the R script** in `src/R/plots/` following the existing pattern:
   ```r
   source(here::here("src", "R", "x_data.R"))
   source(here::here("src", "R", "x_func.R"))
   source(here::here("src", "R", "x_theme.R"))

   # Your plotting code here
   ```

2. **Create the gallery page** in `pages/plots/` as a `.qmd` file:
   ```yaml
   ---
   title: "Your Plot Title"
   description: "Brief description of the visualization."
   categories: ["Survey data", "R"]
   code-contributor: "Your Name"
   ---
   ```

   ```{r}
   #| file: "../../src/R/plots/your-plot.R"
   #| code-fold: true
   ```

3. **Preview locally** with `quarto preview` to verify rendering

4. **Submit a pull request** with your changes

### Adding Color Palettes

Add new palettes to `src/R/x_theme.R` and document them in `pages/styling/color-palettes.qmd`.

### Improving Documentation

- Fix typos or clarify explanations
- Add examples to the code tutorials in `pages/code/`
- Expand the styling guidelines

### Guidelines

- Follow the [styling standards](https://centerforthebuiltenvironment.github.io/chart-library/pages/styling/) for all visualizations
- Use existing color palettes when appropriate
- Keep code examples minimal and focused
- Test that the site builds without errors before submitting

## Building the Site

```bash
# Full site build (outputs to docs/)
quarto render

# Render a single page
quarto render pages/plots/your-plot.qmd

# Preview with live reload
quarto preview
```

## License

This project is maintained by the Center for the Built Environment at UC Berkeley.

## Acknowledgments

Created by [t-kramer](https://github.com/t-kramer). Built with [Quarto](https://quarto.org/).
