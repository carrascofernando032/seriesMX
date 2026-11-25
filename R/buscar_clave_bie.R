#' Buscar un indicador del Banco de Información Económica (BIE) de INEGI a través de su clave correspondiente
#'
#' Esta función busca una coincidencia exacta en [catalogo_maestro_inegi] del paquete seriesMX. Por otro lado, cabe señalar que se puede consultar el catálogo maestro sin configurar previamente el token de autenticación de INEGI.
#'
#' @param clave Una clave de indicador, como texto o número. Es la información que el usuario ingresa a la función.
#' @returns Un data frame con todas las columnas del catálogo y todas las filas que corresponden a la clave seleccionada. Si la clave no existe, devuelve cero filas.
#' @export
#'
#' @examples
#' buscar_clave_bie("736183")
#' buscar_clave_bie("720322")
buscar_clave_bie <- function(clave) {
  if (is.numeric(clave)) {
    clave <- format(clave, scientific = FALSE, trim = TRUE)
  }
  if (!is.character(clave) || length(clave) != 1L || is.na(clave) ||
      !grepl("^[0-9]+$", clave)) {
    stop("Proporcione una sola clave de identificacion del indicador", call. = FALSE)
  }

  catalogo <- seriesMX::catalogo_maestro_inegi
  catalogo[catalogo$clave_bie == clave, , drop = FALSE]
}
