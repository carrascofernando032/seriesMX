#' Estadísticos descriptivos de una o varias series de variación porcentual.
#'
#' La función estadisticos_ts calcula los estadísticos descriptivos de una o varias series de variación porcentual: frecuencia, máximo, mínimo, media, mediana, desviación estándar, primer y tercer cuartil, rango intercuartílico, sesgo y curtosis.
#' La media geométrica se calcula sobre los factores `1 + x/100`. Es la tasa promedio compuesta cuando las tasas no se traslapan; en variaciones anuales de series mensuales se interpreta como el promedio de tasas anuales.
#'
#'
#' @param df Data frame con las series, expresadas en porcentaje sin el signo (3.1094% se escribe 3.1094).
#' @param indicadores Vector de caracteres con los nombres de las columnas a resumir. Por defecto, todas las columnas deberán ser numéricas.
#' @param na.rm Argumento lógico (TRUE o FALSE) que significa «NA remove» (eliminar o ignorar valores perdidos). Si es `TRUE`, ignora los valores perdidos (`NA`) de cada serie.
#'
#'
#' @returns Un data frame con una fila por indicador y una columna por estadístico.
#'
#' @importFrom stats median sd quantile IQR
#' @importFrom moments skewness kurtosis
#'
#' @export
#'
#' @examples
#'
#' # Datos simulados: 72 meses desde enero de 2018 (con semilla fija).
#' # fix: caminata aleatoria que parte de 18 pesos por dólar (nivel).
#' # fbcf: variación anual simulada, normal con media 1 y desviación estándar 2.
#'
#' set.seed(123)
#' datos <- data.frame(
#'   fecha = seq(as.Date("2018-01-01"), by = "month", length.out = 72),
#'   fix = 18 + cumsum(rnorm(72, 0.02, 0.3)),
#'   fbcf = rnorm(72, 1, 2))
#'
#' # Variación porcentual anual del FIX (la FBCF ya está en variación anual):
#' datos$fix <- c(rep(NA, 12), (datos$fix[13:72] / datos$fix[1:60] - 1) * 100)
#'
#' estadisticos_ts(df = datos)
#'
#'
estadisticos_ts <- function(df, indicadores = NULL, na.rm = TRUE) {
  if (!is.data.frame(df)) stop("`df` debe ser un data frame.", call. = FALSE)
  if (is.null(indicadores)) {
    indicadores <- names(df)[vapply(df, is.numeric, logical(1))]
  }
  if (length(indicadores) == 0) stop("No hay columnas numericas.", call. = FALSE)
  if (!all(indicadores %in% names(df))) stop("Columnas no encontradas en `df`.", call. = FALSE)

  filas <- lapply(indicadores, function(v) {
    x <- df[[v]]
    if (na.rm) x <- x[!is.na(x)]
    if (length(x) < 2) stop("`", v, "` requiere al menos 2 observaciones.", call. = FALSE)
    factores <- 1 + x / 100
    if (any(factores <= 0, na.rm = TRUE)) {
      stop("`", v, "` tiene tasas <= -100%: la media geometrica no esta definida.", call. = FALSE)
    }
    data.frame(
      indicador        = v,
      observaciones    = length(x),
      maximo           = max(x),
      minimo           = min(x),
      media            = (exp(mean(log(factores))) - 1) * 100,
      media_aritmetica = mean(x),
      mediana          = stats::median(x),
      desv_esta        = stats::sd(x),
      Q1               = unname(stats::quantile(x, 0.25)),
      Q3               = unname(stats::quantile(x, 0.75)),
      RIQ              = stats::IQR(x),
      sesgo            = moments::skewness(x),
      curtosis         = moments::kurtosis(x)
    )})
  do.call(rbind, filas)
}
