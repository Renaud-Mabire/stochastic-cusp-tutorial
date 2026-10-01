# Interactive companion to the main article, in the order of its code blocks.
# Open Cusp_Tutorial.Rproj first. Run one block at a time in RStudio.
# This script fits fixed data; it does not generate observations.
# The guard stops a sourced run on failed basic fit checks. When stepping through
# blocks manually, do not continue past an error.
# Use R/run_tutorial.R for the automated export and warning/error logs.

# Block 1
if (!requireNamespace("cusp", quietly = TRUE) ||
    as.character(packageVersion("cusp")) != "2.3.8") {
  stop("Install cusp 2.3.8; see README.md.")
}
dat <- readRDS("data/analysis_data.rds")

# Block 2
fit <- cusp::cusp(
  y ~ adaptive_functioning_z,
  alpha ~ personal_resources_z,
  beta ~ acute_stress_z,
  data = dat,
  optim.method = "L-BFGS-B"
)

# Block 3
list(code = fit$code, converged = fit$converged,
     OK = fit$OK, rank = fit$rank)

# Block 4
if (!identical(as.integer(fit$code), 0L) ||
    !isTRUE(fit$converged) || !isTRUE(fit$OK) ||
    !isTRUE(as.integer(fit$rank) == 6L)) {
  stop("Fit checks failed; inspect fit$message before interpreting tests.")
}

# Block 5
str(fit, max.level = 1)

# Block 6
sm <- summary(fit)
sm

# Block 7
confint(fit, level = 0.95)

# Block 8
plot(fit)

# Block 9
cf <- coef(fit)
a <- unname(cf["a[(Intercept)]"])
b <- unname(cf["b[(Intercept)]"] + cf["b[acute_stress_z]"])
state_grid <- seq(-4, 4, length.out = 801)
density_here <- cusp::dcusp(state_grid, a, b)
plot(state_grid, density_here, type = "l",
     xlab = "Canonical state (y)", ylab = "Model-predicted density")

# Block 10
source("R/plot_profiles.R")
plot_tutorial_profiles(fit)

# Record the environment when reproducing the example.
sessionInfo()
