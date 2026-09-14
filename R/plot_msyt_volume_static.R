#' Plot Merch Vol maps from MSYT yield curve data
#'
#' This function generates and displays two `ggplot2` maps showing the
#' coniferous and deciduous merchantable volume by VRI polygon at age 80.
#'
#' The function is intended to be used with the data output from
#' the `match_vri_to_msyt_curves()` function, which prepares the
#' data in the required format.
#'
#' @param vri_with_msyt An `sf` data frame, typically the `vri_with_msyt`
#'   element from the list returned by `match_vri_to_msyt_curves()`.
#'   It must contain the geometry.
#' @param age_to_plot A numeric value specifying the age (in years) at which
#'   to plot the spatial merchantable volume maps. Defaults to 80.
#'
#' @return A list containing the two `ggplot` objects (`p1` and `p2`),
#'   invisibly. The function also prints the plots to the active
#'   graphics device.
#'
#' @examples
#' \dontrun{
#' # Assuming you have already run match_vri_to_msyt_curves()
#' # and saved the output to a variable named 'msyt_results'
#'
#' # The function will automatically display the plots
#' plot_msyt_volume_static(msyt_results$vri_with_msyt)
#'
#' # To save the plots to a variable for later use:
#' my_plots <- plot_msyt_volume_static(msyt_results$vri_with_msyt)
#'
#' # Access and save a specific plot
#' ggsave("conifer_volume_map.png", plot = my_plots$conifer_volume_map)
#' }
#' @export
plot_msyt_volume_static <- function(vri_with_msyt, age_to_plot = 80) {

  # Initialize a list to hold the plots
  plot_list <- list()

  # Construct dynamic column names for plotting
  conifer_col <- paste0("MVcon_", age_to_plot)
  deciduous_col <- paste0("MVdec_", age_to_plot)

  # Ensure the required columns exist
  if (!all(c(conifer_col, deciduous_col) %in% names(vri_with_msyt))) {
    stop(paste0("The 'vri_with_msyt' data frame does not contain the required columns for age ",
                age_to_plot, ". Please check your data."))
  }

  # Map 1: Conifer volume
  p1 <- ggplot2::ggplot(vri_with_msyt) +
    ggplot2::geom_sf(ggplot2::aes(fill = !!rlang::sym(conifer_col))) +
    ggplot2::scale_fill_gradient(low = "white", high = "darkgreen",
                                 name = "Conifer\nMerch Vol\n(m^3/ha)") +
    ggplot2::theme_minimal() +
    ggplot2::labs(title = paste0("Coniferous Merch Volume at Age ", age_to_plot),
                  subtitle = "Polygons with MSYT Curves")
  print(p1)
  plot_list$conifer_map <- p1

  # Map 2: Deciduous volume
  p2 <- ggplot2::ggplot(vri_with_msyt) +
    ggplot2::geom_sf(ggplot2::aes(fill = !!rlang::sym(deciduous_col))) +
    ggplot2::scale_fill_gradient(low = "white", high = "saddlebrown",
                                 name = "Deciduous\nMerch Vol\n(m^3/ha)") +
    ggplot2::theme_minimal() +
    ggplot2::labs(title = paste0("Deciduous Merch Volume at Age ", age_to_plot),
                  subtitle = "Polygons with MSYT Curves")
  print(p2)
  plot_list$deciduous_map <- p2

  return(invisible(plot_list))
}
