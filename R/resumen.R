#' Resumen estadístico de una muestra.
#'
#' El propósito de esta función es calcular las medidas de tendencia central de una muestra: frecuencia, máximo, mínimo, media, mediana, desviación estándar, primer y tercer cuartíl, rango intercuartílico, sesgo y curtosis.
#'
#' @param df Data frame que se utilizará para generar el resumen estadístico de la muestra.
#' @param muestra Vector numérico (observaciones) que se desea analizar estadísticamente.
#'
#' @return Un vector con las medidas de tendencia central calculadas.
#'
#' @importFrom dplyr summarise
#' @importFrom stats median sd quantile IQR
#' @importFrom moments skewness kurtosis
#'
#' @export
#'
#' @examples
#' datos <- data.frame(a = c(10, 20, 25, 40, 50))
#' resumen(df = datos, muestra = datos$a)
#'
#' datos2 <- data.frame(a = c(5, 8, 12, 15, 20, 25))
#' resumen(df = datos2, muestra = datos2$a)
#'
resumen <- function(df,muestra) {

  datos <- dplyr::summarise(
    df,
    observaciones = length(muestra),
    maximo = max(muestra),
    minimo = min(muestra),
    media = mean(muestra),
    mediana = stats::median(muestra),
    desv_esta = stats::sd(muestra),
    Q1 = stats::quantile(muestra, 0.25),
    Q3 = stats::quantile(muestra, 0.75),
    RIQ = stats::IQR(muestra),
    sesgo = moments::skewness(muestra),
    curtosis = moments::kurtosis(muestra)
  )

  return(datos)
}


