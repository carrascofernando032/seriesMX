#' Consulta y actualización de indicadores a través de la API del Banco de Información Económica (BIE) del INEGI
#'
#' Consulte la serie histórica de un indicador del BIE con una URL o una clave del [catalogo_maestro_inegi] del paquete seriesMX.
#' Configure previamente sus tokens de autenticación con la función [tokens()] o en la variable de entorno
#' `token_bie_get` del paquete seriesMX.
#'
#' @param url URL de la consulta al BIE de INEGI, sin el token ni el formato de respuesta (el paquete seriesMX los agrega).
#' @param clave Clave del indicador en el catálogo maestro de seriesMX.
#'   Si la clave aparece en varias filas, use [buscar_clave_bie()] para
#'   revisar las coincidencias y copie la URL elegida en el argumento `url`.
#' @returns Un data frame con `serie`, `fecha` (texto) y `observacion`
#'   (numérica). Los periodos se ordenan y las observaciones faltantes son NA.
#' @importFrom httr content GET
#' @importFrom jsonlite fromJSON
#' @export
#'
#' @examplesIf nzchar(Sys.getenv("token_bie_get"))
#' api_bie(clave = "736183")
#'
#' ficha <- buscar_clave_bie("741104")
#' api_bie(url = ficha$url_base)
api_bie <- function(url = NULL, clave = NULL) {
  # 1. Identificar la URL en el catálogo maestro del paquete.
  if (is.null(url) == is.null(clave)) {
    stop("Proporciona exactamente uno de estos argumentos: `url` o `clave`.", call. = FALSE)
  }

  if (!is.null(clave)) {
    fichas <- buscar_clave_bie(clave)
    if (nrow(fichas) == 0L) {
      stop("La clave ", clave, " no est\u00e1 en catalogo_maestro_inegi.", call. = FALSE)
    }
    if (nrow(fichas) > 1L) {
      clave_entre_comillas <- encodeString(fichas$clave_bie[[1L]], quote = '"')
      stop(
        "La clave ", clave, " aparece en ", nrow(fichas), " filas del cat\u00e1logo. ",
        "Consulta buscar_clave_bie(", clave_entre_comillas, ") y usa api_bie(url = ...) ",
        "con la URL de la fila que elijas.",
        call. = FALSE
      )
    }
    url <- fichas$url_base[[1L]]
  } else {
    if (!is.character(url) || length(url) != 1L ||
        !url %in% seriesMX::catalogo_maestro_inegi$url_base) {
      stop("Usa una URL de la columna `url_base` del cat\u00e1logo maestro.", call. = FALSE)
    }
  }

  # 2. Agregar el token y el formato a la URL base.
  token <- .pkg_env$config$token_bie
  if (is.null(token)) {
    token <- Sys.getenv("token_bie_get", unset = "")
  }
  if (!nzchar(token)) {
    stop("Configura el token de INEGI con tokens() o con token_bie_get.", call. = FALSE)
  }

  formato_resp <- "?type=json"
  url_api <- paste0(url, token, formato_resp)

  # 3. Consultar la API y convertir el texto JSON en listas de R.
  respuesta <- httr::GET(url_api)
  httr::stop_for_status(respuesta)
  datosgenerales <- httr::content(respuesta, as = "text", encoding = "UTF-8")
  lista_json <- jsonlite::fromJSON(datosgenerales, simplifyVector = FALSE)

  if (length(lista_json[["Series"]]) != 1L) {
    stop("La respuesta de INEGI debe incluir una sola serie.", call. = FALSE)
  }
  serie <- lista_json[["Series"]][[1L]]
  flujoDatos <- serie[["OBSERVATIONS"]]
  if (length(serie[["INDICADOR"]]) != 1L || !"OBSERVATIONS" %in% names(serie)) {
    stop("La respuesta de INEGI no incluye INDICADOR u OBSERVATIONS.", call. = FALSE)
  }

  # 4. Extraer un periodo y un valor por observación.
  # El índice [1L] devuelve NA cuando el campo viene vacío.
  fechas <- vapply(flujoDatos, function(observacion) {
    as.character(observacion[["TIME_PERIOD"]])[1L]
  }, character(1))
  valores <- vapply(flujoDatos, function(observacion) {
    as.character(observacion[["OBS_VALUE"]])[1L]
  }, character(1))

  # 5. Armar la tabla y ordenar los periodos.
  datos <- data.frame(
    serie = rep(as.character(serie[["INDICADOR"]]), length(flujoDatos)),
    fecha = fechas,
    observacion = suppressWarnings(as.numeric(valores)),
    stringsAsFactors = FALSE
  )
  datos <- datos[order(datos$fecha), , drop = FALSE]
  return(datos)
}
