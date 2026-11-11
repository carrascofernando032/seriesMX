#' Panel de histogramas de las series de indicadores junto con sus estadísticos descriptivos.
#'
#' La función comparar_est_ts tiene el propósito de juntar los histogramas de dos o más indicadores en un panel para su comparación.
#' Para usar esta función, previamente se debió utilizar "estadisticos_ts" de seriesMdf para calcular los estadisticos descriptivos de las series.
#'
#' @param df Data frame compuesto por columnas con los estadísticos descriptivos calculados por la función seriesMX
#' @param indicadores Es un vector de caracteres con los nombres de las columnas que quieres graficar. Cada nombre se convierte en un panel del histograma, y el nombre aparece como título del panel.
#' @param estadistico Es la columna que proviene de estadisticos_ts() que se marca con la línea naranja en cada panel. Los valores útiles son "media" (geométrica, por defecto), "media_aritmetica", "mediana", "Q1", "Q3", "maximo" y "minimo".
#' @param bins Número de barras del histograma (30 por defecto).
#' @param ncol Número de columnas de la cuadrícula de paneles.
#' @param escalas Con "fixed" todos los paneles comparten ejes. Con "free_x", "free_y" o "free" cada histograma usa los suyos, útil si las simulaciones tienen rangos muy distintos.
#'
#' @returns Un panel compuesto por los histogramas de las series de los indicadores.
#'
#' @importFrom rlang .data
#'
#' @export
#'
#' @examples
#' datos <- data.frame(fecha = seq(as.Date("2018-01-01"), by = "month", length.out = 72),
#' fix = 18 + cumsum(rnorm(72, 0.02, 0.3)),
#' fbcf = rnorm(72, 1, 2))
#'
#' # Variación porcentual anual del FIX (la FBCF ya está en variación anual):
#' datos$fix <- c(rep(NA, 12), (datos$fix[13:72] / datos$fix[1:60] - 1) * 100)
#'
#' comparar_est_ts(datos,  indicadores = NULL, estadistico = "media",
#'  bins = 30, ncol = 1, escalas = "fixed")
#'
#'
comparar_est_ts <- function(df, indicadores = NULL, estadistico = "media",
                                      bins = 30, ncol = 1, escalas = "fixed") {
  if (is.data.frame(df)) {
    if (is.null(indicadores)) indicadores <- names(df)[vapply(df, is.numeric, logical(1))]
    lista <- as.list(df[indicadores])
  } else if (is.list(df) && !is.null(names(df)) && all(nzchar(names(df)))) {
    lista <- df
  } else {
    stop("`df` debe ser un data frame o una lista con nombres.", call. = FALSE)
  }
  if (length(lista) == 0) stop("No hay variables para graficar.", call. = FALSE)

  est <- do.call(rbind, lapply(names(lista), function(v) {
    estadisticos_ts(stats::setNames(data.frame(lista[[v]]), v))
  }))
  if (!estadistico %in% names(est)) {
    stop("`estadistico` debe ser una columna de estadisticos_ts(), por ejemplo: 'media'.",
         call. = FALSE)
  }

  datos <- data.frame( valor = unlist(lista, use.names = FALSE),
                       indicador = factor(rep(names(lista),
                                              lengths(lista)),
                                          levels = names(lista)))
  datos <- datos[!is.na(datos$valor), ]
  est$indicador <- factor(est$indicador, levels = names(lista))

  ggplot2::ggplot(datos, ggplot2::aes(x = .data$valor)) +
    ggplot2::geom_histogram(bins = bins) +
    ggplot2::geom_vline(data = est, ggplot2::aes(xintercept = .data[[estadistico]]),
                        color = "orange") +
    ggplot2::facet_wrap(~indicador, ncol = ncol, scales = escalas)
}
