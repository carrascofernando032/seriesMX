#' Panel de histogramas de las series de indicadores junto con sus estadísticos descriptivos
#'
#' Junta los histogramas de dos o más indicadores en un panel para compararlos. Los estadísticos se calculan internamente con [estadisticos_ts()], y el seleccionado en `estadistico` se marca con una línea naranja en cada panel. La interfaz es la misma que la de [graficar_ts()]: un data frame con una columna de fechas y una o más columnas numéricas.
#'
#' @param df Data frame con una columna de fechas y una o más columnas numéricas (indicadores).
#' @param indicadores Vector de caracteres con los nombres de las columnas a graficar.
#'   Cada columna una se convierte en un panel cuando se usa la función. Por defecto, todas las columnas numéricas excepto la de fechas.
#' @param fecha Nombre de la columna de fechas. Por defecto `"fecha"`. Solo se usa para recortar el periodo con `inicio` y `fin`.
#' @param inicio,fin Fechas (`Date` o texto `"AAAA-MM-DD"`) que delimitan el periodo de observación. Si son `NULL`, la función utilizará todo el periodo disponible.
#' @param estadistico Columna de [estadisticos_ts()] que se quiera visualizar con una línea naranja en cada panel: `"media"` (geométrica, por defecto), `"media_aritmetica"`,
#'   `"mediana"`, `"Q1"`, `"Q3"`, `"maximo"` o `"minimo".
#' @param titulo Título del panel.
#' @param subtitulo Texto sobre el área del panel.
#' @param fuente Nota de fuente al pie del panel.
#' @param ejex,ejey Etiquetas de los ejes.
#' @param etiquetas Títulos de las gráficas correspondientes al panel, en el mismo orden que `indicadores`. Por defecto, los nombres de las columnas.
#' @param bins Número de barras del histograma (30 por defecto).
#' @param ncol Número de columnas de la cuadrícula de paneles.
#' @param escalas Con `"fixed"` todos los paneles comparten ejes. Con `"free_x"`,`"free_y"` o `"free"` cada histograma usa los suyos.
#'
#' @returns Un objeto `ggplot` con un panel de histogramas de los indicadores.
#'
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' set.seed(123)
#' datos <- data.frame(
#'   fecha = seq(as.Date("2018-01-01"), by = "month", length.out = 72),
#'   fix = 19 + cumsum(rnorm(72, 0.02, 0.3)),
#'   fbcf = rnorm(72, 1, 2)
#' )
#'
#' # Variación porcentual anual del FIX (la FBCF ya está en variación anual):
#' datos$fix <- c(rep(NA, 12), (datos$fix[13:72] / datos$fix[1:60] - 1) * 100)
#'
#' comparar_est_ts(
#'   df = datos,
#'   inicio = "2019-01-01",
#'   titulo = "Gráfica 2. Histogramas de la var% anual del FIX y la FBCF, a.e.",
#'   ejex = "Puntos porcentuales",
#'   etiquetas = c("Tipo de cambio (FIX)", "Formación Bruta de Capital Fijo, a.e."),
#'   fuente = "Fuente: elaboración propia con datos del BIE (INEGI) y el SIE (Banxico).",
#'   subtitulo = "La línea naranja marca la media geométrica"
#' )
comparar_est_ts <- function(df,
                            indicadores = NULL,
                            fecha = "fecha",
                            inicio = NULL,
                            fin = NULL,
                            estadistico = "media",
                            titulo = NULL,
                            subtitulo = NULL,
                            fuente = NULL,
                            ejex = "Puntos porcentuales",
                            ejey = "Frecuencia",
                            etiquetas = NULL,
                            bins = 30,
                            ncol = 1,
                            escalas = "fixed") {

  # 1. Validaciones --------------------------------------------------------
  if (!is.data.frame(df)) stop("`df` debe ser un data frame. Validar con `str(df)`", call. = FALSE)
  if (is.null(indicadores)) {
    numericas <- names(df)[vapply(df, is.numeric, logical(1))]
    indicadores <- setdiff(numericas, fecha)
  }
  if (length(indicadores) == 0) stop("No hay variables numericas para graficar.", call. = FALSE)
  faltan <- setdiff(indicadores, names(df))
  if (length(faltan) > 0) {
    stop("Columnas no encontradas en `df`: ", paste(faltan, collapse = ", "), call. = FALSE)
  }
  if (!all(vapply(df[indicadores], is.numeric, logical(1)))) {
    stop("Todos los indicadores a graficar deben ser numericos.", call. = FALSE)
  }
  if (is.null(etiquetas)) etiquetas <- indicadores
  if (length(etiquetas) != length(indicadores)) {
    stop("`etiquetas` debe tener la misma longitud que `indicadores`.", call. = FALSE)
  }

  # 2. Recorte del periodo -------------------------------------------------
  if (!is.null(inicio) || !is.null(fin)) {
    if (!fecha %in% names(df)) {
      stop("No se encontro la columna de fechas '", fecha, "' en `df`.", call. = FALSE)
    }
    fechas <- .serie_a_fecha(df[[fecha]])
    inicio <- if (is.null(inicio)) min(fechas) else as.Date(inicio)
    fin <- if (is.null(fin)) max(fechas) else as.Date(fin)
    df <- df[fechas >= inicio & fechas <= fin, , drop = FALSE]
    if (nrow(df) == 0) stop("No hay observaciones entre `inicio` y `fin`.", call. = FALSE)
  }

  # 3. Estadisticos y datos en formato largo ---------------------------------
  est <- estadisticos_ts(df, indicadores = indicadores)
  if (!estadistico %in% names(est)) {
    stop("`estadistico` debe ser una columna de estadisticos_ts(), por ejemplo: 'media'.",
         call. = FALSE)
  }

  datos <- data.frame(
    valor = unlist(df[indicadores], use.names = FALSE),
    indicador = factor(rep(indicadores, each = nrow(df)),
                       levels = indicadores, labels = etiquetas)
  )
  datos <- datos[!is.na(datos$valor), ]
  est$indicador <- factor(est$indicador, levels = indicadores, labels = etiquetas)

  # 4. Grafica ---------------------------------------------------------------
  ggplot2::ggplot(datos, ggplot2::aes(x = .data$valor)) +
    ggplot2::geom_histogram(bins = bins) +
    ggplot2::geom_vline(data = est, ggplot2::aes(xintercept = .data[[estadistico]]),
                        color = "orange") +
    ggplot2::facet_wrap(~indicador, ncol = ncol, scales = escalas) +
    ggplot2::labs(title = titulo, subtitle = subtitulo, caption = fuente,
                  x = ejex, y = ejey) +
    ggplot2::theme(plot.subtitle = ggplot2::element_text(face = "italic"),
                   plot.caption = ggplot2::element_text(hjust = 0),
                   plot.caption.position = "plot")
}
