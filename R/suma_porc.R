#' Función para calcular el porcentaje acumulado de una serie de tiempo.
#'
#' @param a Vector con las observaciones sin el signo porcentual 3.1094% ~ (3.1094)
#'
#' @returns A través de la función prod(), se multiplican de forma automática todos los elementos de un vector numérico.
#'
#' @export
#'
#' @examples
#' suma_porc(a= c(3.0434,5.2094,-2.3345))
#' suma_porc(a= c(2.1345,1.0345,3.0904))
suma_porc<-function(a) {
  resultado <- ((prod(1+(a/100))-1)*100)
  return(resultado)
}
