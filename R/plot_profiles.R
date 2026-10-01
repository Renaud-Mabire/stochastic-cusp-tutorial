# Functions for the conditional-profile display in the tutorial.
# Same design and parameterization as the archived density profiles.
# Drawing uses base R only; cusp::dcusp is used when the reader evaluates profiles.

# 1. Evaluate the conditional density at three fixed predictor settings.
# Resources stay at zero (the sample mean); stress is -1, 0, or 1 SD.
tutorial_profiles <- function(fit) {
  if (!inherits(fit, "cusp")) stop("A cusp fitted object is required.")
  cf <- stats::coef(fit)
  keys <- c("a[(Intercept)]", "b[(Intercept)]", "b[acute_stress_z]")
  if (!all(keys %in% names(cf)) || any(!is.finite(cf[keys]))) stop("Unexpected coefficients.")
  grid <- seq(-4, 4, length.out = 801L)
  do.call(rbind, lapply(seq_along(c(-1, 0, 1)), function(i) {
    stress <- c(-1, 0, 1)[i]
    a <- unname(cf["a[(Intercept)]"])
    b <- unname(cf["b[(Intercept)]"] + cf["b[acute_stress_z]"] * stress)
    data.frame(profile = i, resources_z = 0, stress_z = stress,
               alpha = a, beta = b, canonical_state = grid,
               density = cusp::dcusp(grid, a, b))
  }))
}

# 2. Combine the fitted control plane and these three density curves.
# This function uses the existing fit; it never calls cusp() to refit it.
plot_tutorial_profiles <- function(fit, profiles = NULL) {
  if (is.null(profiles)) profiles <- tutorial_profiles(fit)
  required <- c("profile", "resources_z", "stress_z", "alpha", "beta", "canonical_state", "density")
  if (!all(required %in% names(profiles)) ||
      !setequal(unique(profiles$profile), 1:3) ||
      any(!is.finite(as.matrix(profiles[required])))) stop("Invalid profiles.")
  # Observed predictor combinations supply the coordinates in panel A.
  ab <- fit$linear.predictors
  if (!is.matrix(ab) || !all(c("alpha", "beta") %in% colnames(ab))) stop("Invalid control coordinates.")
  inside <- ab[, "beta"] > 0 & 4 * ab[, "beta"]^3 > 27 * ab[, "alpha"]^2
  op <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(op), add = TRUE)
  graphics::par(mfrow = c(2, 2), mar = c(4.3, 4.4, 2.5, 1), oma = c(1, 0, 0, 0))
  graphics::plot(ab, type = "n", xlim = c(-2.8, 2.8), ylim = c(-2.5, 3.5),
                 xlab = expression(Asymmetry ~ (alpha)), ylab = expression(Bifurcation ~ (beta)),
                 main = "A  Fitted control plane", xaxs = "i", yaxs = "i")
  # The fold boundary comes from 4 * beta^3 = 27 * alpha^2.
  boundary_beta <- seq(0, 3.5, length.out = 161L)
  edge <- sqrt(4 * boundary_beta^3 / 27)
  graphics::polygon(c(-edge, rev(edge)), c(boundary_beta, rev(boundary_beta)),
                    col = "#E8EEF3", border = NA)
  graphics::points(ab[!inside, , drop = FALSE], pch = 4, cex = .45, col = "#7D858E")
  graphics::points(ab[inside, , drop = FALSE], pch = 16, cex = .45, col = "#174A72")
  graphics::lines(-edge, boundary_beta)
  graphics::lines(edge, boundary_beta)
  for (i in 1:3) {
    row <- profiles[profiles$profile == i, , drop = FALSE][1L, ]
    graphics::points(row$alpha, row$beta, pch = 22, bg = "white", col = "#8A4B08", cex = 1.25)
    graphics::rect(row$alpha + .08, row$beta - .16, row$alpha + .43, row$beta + .16, col = "white", border = NA)
    graphics::text(row$alpha + .25, row$beta, labels = LETTERS[i + 1L], col = "#8A4B08", font = 2)
  }
  # Panels B-D use canonical state units and a shared vertical scale.
  titles <- c("B  Lower stress (-1 SD)", "C  Mean stress (0 SD)", "D  Higher stress (+1 SD)")
  for (i in 1:3) {
    profile <- profiles[profiles$profile == i, , drop = FALSE]
    graphics::plot(profile$canonical_state, profile$density, type = "l", col = "#174A72", lwd = 2,
      xlim = c(-4, 4), ylim = c(0, .7), xaxs = "i", yaxs = "i",
      xlab = "Canonical state (y)", ylab = "Model-predicted density", main = titles[i])
    graphics::legend("top", legend = sprintf("alpha = %.3f; beta = %.3f", profile$alpha[1], profile$beta[1]),
                     bty = "n", cex = .85)
  }
  graphics::mtext("All three profiles hold resources at their sample mean.", side = 1, outer = TRUE, cex = .85)
  invisible(profiles)
}
