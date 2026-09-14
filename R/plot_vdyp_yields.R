#' Plot VDYP7 yield curves for specified polygons
#'
#' This function takes the processed VDYP7 yield data, filters it for
#' a specified set of FEATURE_IDs, and generates two separate ggplot
#' visualizations: one for conifer volume and one for deciduous volume,
#' each with a distinct color scheme.
#'
#' @param processed_data A data.table or data.frame containing the processed
#'   VDYP7 yield curve data (e.g., from `process_vdyp_output()`).
#' @param feature_ids_to_plot A vector of FEATURE_ID values to plot. If NULL
#'   (the default), all features will be plotted.
#'
#' @return A named list containing two ggplot objects: `conifer_plot` and
#'   `deciduous_plot`. The function no longer saves the plot to a file.
#' @export
#' @importFrom ggplot2 ggplot aes geom_line labs scale_color_manual theme_classic
#' @importFrom dplyr filter
#' @importFrom RColorBrewer brewer.pal
#'
#' @examples
#' \dontrun{
#' # Assuming 'processed_vdyp' is your processed data.table
#'
#' # Plot specific features and save the results to a variable
#' my_plots <- plot_vdyp_yields(
#'   processed_vdyp,
#'   feature_ids_to_plot = c(4178474, 1234567)
#' )
#'
#' # To view the plots, you can call them directly
#' my_plots$conifer_plot
#' my_plots$deciduous_plot
#'
#' # Plot all features (default behavior)
#' all_plots <- plot_vdyp_yields(processed_vdyp)
#' all_plots$conifer_plot
#' }
plot_vdyp_yields <- function(processed_data, feature_ids_to_plot = NULL) {

  # Filter the data if a specific set of feature IDs is provided
  if (!is.null(feature_ids_to_plot)) {
    plot_data <- processed_data %>%
      dplyr::filter(FEATURE_ID %in% feature_ids_to_plot)
  } else {
    plot_data <- processed_data
  }

  # Check if the filtered data is empty
  if (nrow(plot_data) == 0) {
    stop("No data available for the specified FEATURE_IDs.")
  }

  # Convert FEATURE_ID to a factor for coloring and grouping
  plot_data$FEATURE_ID <- as.factor(plot_data$FEATURE_ID)

  # Check for unique FEATURE_IDs to determine the number of colors needed
  num_features <- length(unique(plot_data$FEATURE_ID))

  # Generate distinct color palettes for conifer and deciduous plots
  if (num_features <= 8) {
    conifer_colors <- RColorBrewer::brewer.pal(max(3, num_features), "Greens")
    deciduous_colors <- RColorBrewer::brewer.pal(max(3, num_features), "YlOrBr")
  } else {
    # For more than 8 features, use a continuous color scale
    conifer_colors <- viridis::viridis(num_features)
    deciduous_colors <- viridis::viridis(num_features, option = "inferno")
  }

  # --- Create the conifer plot with a green color scheme ---
  p_conifer <- ggplot2::ggplot(plot_data, ggplot2::aes(x = PRJ_TOTAL_AGE, y = Conifer_Vol_CU, color = FEATURE_ID)) +
    ggplot2::geom_line(linewidth = 1) +
    ggplot2::labs(
      title = "VDYP7 Conifer Yield Curves",
      x = "Total Age (Years)",
      y = expression(paste("Projected Conifer Volume (", m^3, "/ha)")),
      color = "Feature ID"
    ) +
    ggplot2::scale_color_manual(values = conifer_colors) +
    ggplot2::theme_classic()

  # --- Create the deciduous plot with a brown color scheme ---
  p_deciduous <- ggplot2::ggplot(plot_data, ggplot2::aes(x = PRJ_TOTAL_AGE, y = Decid_Vol_CU, color = FEATURE_ID)) +
    ggplot2::geom_line(linewidth = 1) +
    ggplot2::labs(
      title = "VDYP7 Deciduous Yield Curves",
      x = "Total Age (Years)",
      y = expression(paste("Projected Deciduous Volume (", m^3, "/ha)")),
      color = "Feature ID"
    ) +
    ggplot2::scale_color_manual(values = deciduous_colors) +
    ggplot2::theme_classic()

  # Return a named list of the two plots
  return(list(conifer_plot = p_conifer, deciduous_plot = p_deciduous))
}
