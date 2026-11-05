#' Resumen estadístico de una muestra porcentual.
#'
#'El propósito de esta función es calcular las medidas de tendencia central de una muestra porcentual: frecuencia, máximo, mínimo, media, mediana, desviación estándar, primer y tercer cuartíl, rango intercuartílico, sesgo y curtosis.
#'
#' @param df Data frame que se utilizará para generar el resumen estadístico de la muestra porcentual.
#' @param muestra Vector con las observaciones sin el signo porcentual 3.1094% ~ (3.1094)
#'
#'
#' @returns Un vector con las medidas de tendencia central calculadas.
#'
#' @importFrom dplyr summarise
#' @importFrom stats median sd quantile IQR
#' @importFrom moments skewness kurtosis
#'
#' @export
#'
#' @examples
#' datos1<- data.frame(a= c(3.0434,5.2094,-2.3345, 1.0902, -3.4713))
#' resumen_porc(df=datos1, muestra=datos1$a)
#' datos2<- data.frame(a= c(2.1345,1.0345,3.0904, 3.0896, 9.0736))
#' resumen_porc(df=datos2, muestra=datos2$a)
#'
resumen_porc <- function(df, muestra) {

  datos <- dplyr::summarise(
    df,
    observaciones = length(muestra),
    maximo = max(muestra),
    minimo = min(muestra),
    media = (((prod(1+(muestra/100))-1)/length(muestra)*100)),
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
