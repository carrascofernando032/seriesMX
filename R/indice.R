#' Función para calcular un índice.
#'
#' @param serie Data frame con las columnas fecha y observacion.
#' @param base Valor de la observación correspondiente al periodo base.
#'
#' @returns Un data frame con la fecha, la observación y el índice.
#'
#' @export
#'
#' @examples
#' serie1 = data.frame(fecha = c("2020/04", "2021/01", "2021/02", "2021/03"),
#'     observacion = c(23901537.36, 24184104.65, 25181151.90, 25360618.49))
#' indice(serie = serie1, base = 24184104.65)
#' serie2 = data.frame(fecha = c("2020/04", "2021/01", "2021/02", "2021/03", "2021/04", "2022/01", "2022/02"),
#'     observacion = c(40901537.36, 94184104.65, 65181151.90, 75360618.49, 74184104.65, 90901537.36, 50901537.36))
#' indice(serie = serie2, base = 65181151.90)
indice <- function(serie, base) { resultado <- data.frame(fecha = serie$fecha,
                                                          observacion = serie$observacion,
                                                          indice = (serie$observacion / base) * 100)

  return(resultado)
}
