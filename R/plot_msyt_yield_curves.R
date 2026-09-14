#' Plot Merchantable Volume over Age for Selected Polygons
#'
#' This function generates a `ggplot2` line plot showing merchantable volume
#' (coniferous and deciduous) over age for a specified subset of polygons.
#'
#' The function takes a long-format data frame, typically created by
#' `match_vri_to_msyt_curves()`, and allows the user to filter for specific
#' `FEATURE_ID`s to visualize their unique yield curves.
#'
#' @param msyt_long_data A data frame in long format, containing columns
#'   `FEATURE_ID`, `volume_type`, `age`, and `volume`.
#' @param feature_ids_to_plot A numeric vector of `FEATURE_ID`s to be
#'   included in the plot.
#'
#' @return A `ggplot2` object displaying the volume-over-age curves,
#'   invisibly. The plot is also printed to the active graphics device.
#'
#' @examples
#' \dontrun{
#' msyt_for_plotting <- vri_msyt_joined$vri_with_msyt
#'
#' # Create the long-format data for the yield curve plots
#' msyt_long_data <- msyt_for_plotting %>%
#'   sf::st_drop_geometry() %>%
#'   tidyr::pivot_longer(
#'     cols = starts_with("MV"),
#'     names_to = c("volume_type", "age"),
#'     names_sep = "_",
#'     values_to = "volume"
#'   ) %>%
#'   dplyr::filter(!is.na(volume)) %>%
#'   dplyr::mutate(age = as.numeric(age))
#'
#' # Plotting a single Feature_ID
#' plot_yield_curves(long_data_frame, feature_ids_to_plot = c(4178474))
#' }
#' @export
#' @importFrom dplyr filter
#' @importFrom ggplot2 ggplot aes geom_line labs facet_wrap theme_minimal
plot_msyt_yield_curves <- function(msyt_long_data, feature_ids_to_plot) {

  # Check if feature_ids_to_plot is provided and is a vector
  if (is.null(feature_ids_to_plot) || !is.numeric(feature_ids_to_plot)) {
    stop("Please provide a numeric vector of one or more FEATURE_IDs to plot.")
  }

  # Filter the data for the specified IDs
  plot_data <- msyt_long_data %>%
    dplyr::filter(FEATURE_ID %in% feature_ids_to_plot)

  # Check if the filtered data is empty
  if (nrow(plot_data) == 0) {
    message("No data found for the specified Feature_ID(s). No plot will be generated.")
    return(invisible(NULL))
  }

  # Create the plot
  p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = age, y = volume, color = volume_type)) +
    ggplot2::geom_line(size = 1.2) +
    ggplot2::labs(
      x = "Age (years)",
      y = "Merch. Volume (m^3/ha)",
      title = "Volume over Age for Select Polygons",
      color = "Volume Type"
    ) +
    ggplot2::facet_wrap(~ FEATURE_ID, scales = "free_y") +
    ggplot2::theme_minimal()

  # Print the plot and return it invisibly
  print(p)
  return(invisible(p))
}
