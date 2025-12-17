# Define the function to install packages
install_my_packages <- function() {
  # Vector of CRAN packages
  cran_packages <- c("tidybayes", "bayesplot", "brms",
    "HDInterval", "ggmcmc", "easystats", "Rgraphviz",
    "modelsummary", "pak", "mgcv", "gratia", "scales",
    "vegan", "mvabund", "gbm", "pdp", "randomForest",
    "caret", "xgboost",
    "tree", "PBSmapping", "gmodels", "dagitty", "ggdag",
    "geoR", "proj4", "rgdal", "targets", "future", "tarchetypes",
    "dbarts",
    "rstan", "DHARMa", "magick", "pdftools", "ggally", "V8")

  # Install missing CRAN packages
  installed <- rownames(installed.packages())
  missing_cran <- setdiff(cran_packages, installed)
  if (length(missing_cran) > 0) {
    install.packages(missing_cran, repos = "https://cloud.r-project.org/")
  }

  # Vector of GitHub packages (repository names)
  github_packages <- c("jmgirard/standist",
    "timcdlucas/INLAutils", "julianfaraway/brinla",
    "stan-dev/cmdstanr",
    "open-aims/synthos"
  )

  # Install missing GitHub packages
  if (!requireNamespace("pak", quietly = TRUE)) {
    install.packages("pak", repos = "https://cloud.r-project.org/")
  }
  missing_github <- setdiff(github_packages, installed)
  if (length(missing_github) > 0) {
    for (pkg in missing_github) {
      pak::pkg_install(pkg)
    }
  }

}

# Call the function
install_my_packages()
