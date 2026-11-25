#' Buscar una serie del SIE de Banxico por su clave
#'
#' Busca una coincidencia exacta en [catalogo_maestro_banxico]. No requiere token.
#' @param clave Una clave del SIE como texto, por ejemplo `"SF17908"`.
#' @returns Un data frame con todas las columnas y filas correspondientes.
#'   Si la clave no existe, devuelve cero filas.
#' @export
#' @examples
#' buscar_clave_sie("SF17908")
#' buscar_clave_sie("SF331451")
buscar_clave_sie <- function(clave) {
  if (!is.character(clave) || length(clave) != 1L || is.na(clave) ||
      !grepl("^[A-Z]+[0-9]+$", clave)) {
    stop("Proporciona una sola clave del SIE, como texto: por ejemplo, 'SF17908'.", call. = FALSE)
  }
  catalogo <- seriesMX::catalogo_maestro_banxico
  catalogo[catalogo$clave_sie == clave, , drop = FALSE]
}
