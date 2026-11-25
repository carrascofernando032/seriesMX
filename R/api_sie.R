#' Consulta de indicadores a través de la API del SIE de Banxico
#'
#' Consulta una serie histórica mediante una URL o una clave de
#' [catalogo_maestro_banxico]. Configura el token con [tokens()] o mediante
#' la variable de entorno `token_sie_get`.
#' @param url URL de `url_base`, terminada en `/datos`, sin token ni parámetros.
#'   También acepta la URL anterior sin `/datos` si corresponde al catálogo.
#' @param clave Clave del SIE. Si aparece en varias filas, revisa
#'   [buscar_clave_sie()] y copia una URL en el argumento `url`.
#' @returns Un data frame con `serie`, `fecha` (Date) y `observacion`
#'   (numérica), ordenado por fecha. Los valores no disponibles quedan como NA.
#'   Si no hay observaciones o la respuesta es inválida, devuelve un error.
#' @importFrom httr content GET
#' @importFrom jsonlite fromJSON
#' @export
#' @examplesIf nzchar(Sys.getenv("token_sie_get"))
#' api_sie(clave = "SF17908")
#' ficha <- buscar_clave_sie("SF331451")
#' api_sie(url = ficha$url_base[[1L]])
api_sie <- function(url = NULL, clave = NULL) {
  # 1. Identificar la URL en el catálogo maestro del paquete.
  if (is.null(url) == is.null(clave)) {
    stop("Proporciona exactamente uno de estos argumentos: `url` o `clave`.", call. = FALSE)
  }
  if (!is.null(clave)) {
    fichas <- buscar_clave_sie(clave)
    if (nrow(fichas) == 0L) {
      stop("La clave ", clave, " no est\u00e1 en catalogo_maestro_banxico.", call. = FALSE)
    }
    if (nrow(fichas) > 1L) {
      stop("La clave ", clave, " aparece en ", nrow(fichas), " filas del cat\u00e1logo. ",
           "Consulta buscar_clave_sie(\"", clave, "\") y usa api_sie(url = ...) ",
           "con una URL de la columna url_base. Las filas pueden compartir URL.", call. = FALSE)
    }
    url <- fichas$url_base[[1L]]
  } else {
    if (!is.character(url) || length(url) != 1L || is.na(url)) {
      stop("Proporciona una sola URL de la columna `url_base` del cat\u00e1logo.", call. = FALSE)
    }
    # Compatibilidad con los ejemplos anteriores del paquete.
    if (grepl("^https://www\\.banxico\\.org\\.mx/SieAPIRest/service/v1/series/[A-Z]+[0-9]+$", url)) {
      url <- paste0(url, "/datos")
    }
    if (!url %in% seriesMX::catalogo_maestro_banxico$url_base) {
      stop("Usa una URL de la columna `url_base` del cat\u00e1logo maestro.", call. = FALSE)
    }
  }

  # 2. Obtener el token y consultar el histórico una sola vez.
  token <- .pkg_env$config$token_sie
  if (is.null(token)) token <- Sys.getenv("token_sie_get", unset = "")
  if (!is.character(token) || length(token) != 1L || is.na(token) || !nzchar(token)) {
    stop("Configura el token de Banxico con tokens() o con token_sie_get.", call. = FALSE)
  }
  respuesta <- httr::GET(
    url, httr::add_headers(`Bmx-Token` = token), httr::accept_json(),
    httr::timeout(90), httr::config(followlocation = 0L)
  )
  if (httr::status_code(respuesta) >= 300L && httr::status_code(respuesta) < 400L) {
    stop("Banxico devolvi\u00f3 una redirecci\u00f3n HTTP. No se obtuvo una serie hist\u00f3rica.", call. = FALSE)
  }
  httr::stop_for_status(respuesta)

  # 3. Convertir el JSON y revisar que contenga la serie solicitada.
  datosgenerales <- httr::content(respuesta, as = "text", encoding = "UTF-8")
  lista_json <- tryCatch(
    jsonlite::fromJSON(datosgenerales, simplifyVector = FALSE),
    error = function(e) stop("Banxico no devolvi\u00f3 una respuesta JSON v\u00e1lida.", call. = FALSE)
  )
  if (!is.list(lista_json) || !is.list(lista_json[["bmx"]]) ||
      length(lista_json[["bmx"]][["series"]]) != 1L) {
    stop("La respuesta de Banxico debe incluir una sola serie.", call. = FALSE)
  }
  serie <- lista_json[["bmx"]][["series"]][[1L]]
  clave_esperada <- sub(".*/series/([A-Z]+[0-9]+)/datos$", "\\1", url)
  if (!is.list(serie) || !identical(serie[["idSerie"]], clave_esperada) ||
      !"datos" %in% names(serie) || !is.list(serie[["datos"]])) {
    stop("La respuesta de Banxico no incluye la serie o los datos esperados.", call. = FALSE)
  }
  flujoDatos <- serie[["datos"]]
  if (!length(flujoDatos)) {
    stop("La serie ", clave_esperada, " no tiene observaciones disponibles.", call. = FALSE)
  }
  if (!all(vapply(flujoDatos, is.list, logical(1)))) {
    stop("La respuesta contiene observaciones con una estructura inv\u00e1lida.", call. = FALSE)
  }

  # 4. Extraer las fechas y convertir los valores faltantes en NA.
  fechas <- vapply(flujoDatos, function(observacion) {
    as.character(observacion[["fecha"]])[1L]
  }, character(1))
  valores <- vapply(flujoDatos, function(observacion) {
    as.character(observacion[["dato"]])[1L]
  }, character(1))
  fecha <- as.Date(fechas, format = "%d/%m/%Y")
  if (anyNA(fecha) || any(format(fecha, "%d/%m/%Y") != fechas)) {
    stop("La respuesta de Banxico contiene fechas inv\u00e1lidas.", call. = FALSE)
  }
  valores <- gsub(",", "", trimws(valores), fixed = TRUE)
  valores[toupper(valores) %in% c("", "N/E", "NE", "N/D", "ND", "N/A", "NA")] <- NA_character_

  # 5. Armar la tabla y ordenar las fechas.
  datos <- data.frame(
    serie = rep(serie[["idSerie"]], length(flujoDatos)),
    fecha = fecha,
    observacion = suppressWarnings(as.numeric(valores)),
    stringsAsFactors = FALSE
  )
  datos <- datos[order(datos$fecha), , drop = FALSE]
  rownames(datos) <- NULL
  if (all(is.na(datos$observacion))) {
    warning("La serie tiene observaciones, pero no contiene valores num\u00e9ricos disponibles.", call. = FALSE)
  }
  return(datos)
}
