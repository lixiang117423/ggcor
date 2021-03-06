#' Star Geom
#'
#' @inheritParams ggplot2::layer
#' @inheritParams ggplot2::geom_polygon
#' @section Aesthetics:
#' \code{geom_star()}, \code{geom_upper_star()} and \code{geom_lower_star()}
#' understands the following aesthetics (required aesthetics are in bold):
#'     \itemize{
#'       \item \strong{\code{x}}
#'       \item \strong{\code{y}}
#'       \item \code{n}
#'       \item \code{r0}
#'       \item \code{ratio}
#'       \item \code{alpha}
#'       \item \code{colour}
#'       \item \code{fill}
#'       \item \code{linetype}
#'       \item \code{size}
#'       \item \code{upper_n}
#'       \item \code{upper_r0}
#'       \item \code{upper_ratio}
#'       \item \code{upper_alpha}
#'       \item \code{upper_colour}
#'       \item \code{upper_fill}
#'       \item \code{upper_linetype}
#'       \item \code{upper_size}
#'       \item \code{lower_n}
#'       \item \code{lower_r0}
#'       \item \code{lower_ratio}
#'       \item \code{lower_alpha}
#'       \item \code{lower_colour}
#'       \item \code{lower_fill}
#'       \item \code{lower_linetype}
#'       \item \code{lower_size}
#'    }
#' @importFrom ggplot2 layer ggproto GeomPolygon aes
#' @importFrom grid grobTree
#' @rdname geom_star
#' @author Houyun Huang, Lei Zhou, Jian Chen, Taiyun Wei
#' @export
geom_star <- function(mapping = NULL, data = NULL,
                          stat = "identity", position = "identity",
                          ...,
                          na.rm = FALSE,
                          show.legend = NA,
                          inherit.aes = TRUE) {
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomStar,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      na.rm = na.rm,
      ...
    )
  )
}

#' @rdname geom_star
#' @export
geom_upper_star <- function(mapping = NULL,
                            data = get_data(type = "upper"),
                            stat = "identity",
                            position = "identity",
                            ...,
                            na.rm = FALSE,
                            show.legend = NA,
                            inherit.aes = TRUE) {
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomUpperStar,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = aes_short_to_long(
      list(
        na.rm = na.rm,
        ...
      ), prefix = "upper", short_aes
    )
  )
}

#' @rdname geom_star
#' @export
geom_lower_star <- function(mapping = NULL,
                            data = get_data(type = "lower"),
                            stat = "identity",
                            position = "identity",
                            ...,
                            na.rm = FALSE,
                            show.legend = NA,
                            inherit.aes = TRUE) {
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomLowerStar,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = aes_short_to_long(
      list(
        na.rm = na.rm,
        ...
      ), prefix = "lower", short_aes
    )
  )
}

#' @rdname geom_star
#' @format NULL
#' @usage NULL
#' @export
GeomStar <- ggproto(
  "GeomStar", GeomPolygon,
  default_aes = aes(n = 5, r0 = 0.5, ratio = 0.618, colour = "grey35", fill = NA,
                    size = 0.25, linetype = 1, alpha = NA),
  required_aes = c("x", "y"),
  draw_panel = function(self, data, panel_params, coord, linejoin = "mitre") {
    aesthetics <- setdiff(names(data), c("x", "y"))
    star <- lapply(split(data, seq_len(nrow(data))), function(row) {
      if(row$n <= 2)
        return(grid::nullGrob())
      dd <- point_to_star(row$x, row$y, row$n, row$r0, row$ratio)
      aes <- new_data_frame(row[aesthetics])[rep(1, 2 * row$n + 1), ]
      GeomPolygon$draw_panel(cbind(dd, aes), panel_params, coord)
    })
    ggplot2:::ggname("star", do.call("grobTree", star))
  },
  draw_key = draw_key_star
)

#' @rdname geom_star
#' @format NULL
#' @usage NULL
#' @export
GeomUpperStar <- ggproto(
  "GeomUpperStar", GeomStar,
  default_aes = aes(upper_n = 5, upper_r0 = 0.5, upper_ratio = 0.618,
                    upper_colour = NA, upper_fill = "grey20",
                    upper_size = 0.1, upper_linetype = 1, upper_alpha = NA),
  required_aes = c("x", "y"),
  draw_panel = function(self, data, panel_params, coord, linejoin = "mitre") {
    data <- remove_short_aes(data, short_aes)
    data <- aes_long_to_short(data, "upper", long_aes_upper)
    GeomStar$draw_panel(data, panel_params, coord)
  },

  draw_key = draw_key_upper_star
)

#' @rdname geom_star
#' @format NULL
#' @usage NULL
#' @export
GeomLowerStar <- ggproto(
  "GeomLowStar", GeomStar,
  default_aes = aes(lower_n = 5, lower_r0 = 0.5, lower_ratio = 0.618,
                    lower_colour = NA, lower_fill = "grey20",
                    lower_size = 0.1, lower_linetype = 1, lower_alpha = NA),
  required_aes = c("x", "y"),
  draw_panel = function(self, data, panel_params, coord, linejoin = "mitre") {
    data <- remove_short_aes(data, short_aes)
    data <- aes_long_to_short(data, "lower", long_aes_lower)
    GeomStar$draw_panel(data, panel_params, coord)
  },

  draw_key = draw_key_lower_star
)

#' @noRd
point_to_star <- function(x, y, n, r0, ratio = 0.618) {
  p <- 0:n / n
  if (n %% 2 == 0) p <- p + p[2] / 2
  pos <- p * 2 * pi
  x_tmp <- 0.5 * sign(r0) * sqrt(abs(r0)) * sin(pos)
  y_tmp <- 0.5 * sign(r0) * sqrt(abs(r0)) * cos(pos)
  angle <- pi / n
  xx <- numeric(2 * n + 2)
  yy <- numeric(2 * n + 2)
  xx[seq(2, 2 * n + 2, by = 2)] <- x + x_tmp
  yy[seq(2, 2 * n + 2, by = 2)] <- y + y_tmp
  xx[seq(1, 2 * n + 2, by = 2)] <- x + ratio * (x_tmp * cos(angle) - y_tmp * sin(angle))
  yy[seq(1, 2 * n + 2, by = 2)] <- y + ratio * (x_tmp * sin(angle) + y_tmp * cos(angle))
  new_data_frame(list(
    x = xx[- (2 * n + 2)],
    y = yy[- (2 * n + 2)]
  ))
}
