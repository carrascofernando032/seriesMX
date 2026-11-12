#' Registro de tokens de autenticacion del BIE y SIE.
#'
#' La función "tokens()" del paquete seriesMX guarda los tokens de autenticación del BIE y SIE para consultar sus API's en la sesión vigente de R. Si no se configuran los tokens,
#' `api_bie()` y `api_sie()` los buscarán en las variables de entorno token_bie_get` y `token_sie_get`.
#'
#' @param token_bie Token del BIE (INEGI), como texto entre comillas. Ver el README de seriesMX.
#' @param token_sie Token del SIE (Banxico), como texto entre comillas. Ver el README de seriesMX.
#'
#' @returns La función devuelve (de forma invisible) un vector lógico que indica los tokens configurados exitosamente.
#' @export
#'
#' @examples
#' tokens(
#'   token_bie = "token_de_autenticacion_bie",
#'   token_sie = "token_de_autenticacion_sie")
#'
tokens <- function(token_bie = NULL, token_sie = NULL) {
  valido <- function(x) is.character(x) && length(x) == 1 && !is.na(x) && nzchar(x)
  if (!is.null(token_bie)) {
    if (!valido(token_bie)) stop("`token_bie` debe ser un texto no vacio entre comillas.", call. = FALSE)
    .pkg_env$config$token_bie <- token_bie
  }
  if (!is.null(token_sie)) {
    if (!valido(token_sie)) stop("`token_sie` debe ser un texto no vacio entre comillas.", call. = FALSE)
    .pkg_env$config$token_sie <- token_sie
  }
  estado <- c(BIE = !is.null(.pkg_env$config$token_bie),
              SIE = !is.null(.pkg_env$config$token_sie))
  message("Tokens configurados exitosamente en esta sesion: ", paste(names(estado)[estado], collapse = ", "))
  invisible(estado)
}

# Entorno interno del paquete donde se guardan los tokens de la sesion.
.pkg_env <- new.env(parent = emptyenv())
.pkg_env$config <- list()
