#' Consulta y actualización de indicadores a través de la API del Banco de Información Económica (BIE) del INEGI
#'
#' @param url URL de la consulta al BIE de INEGI, sin el token ni el formato de respuesta (el paquete seriesMX los agrega). El token se configura con [tokens()].
#'
#' @returns Un dataframe que contiene los datos de la serie de tiempo solicitada.
#' @importFrom httr content GET
#' @importFrom jsonlite fromJSON
#' @export
#'
#' @examplesIf nzchar(Sys.getenv("token_bie_get"))
#'
#' url_pib <-paste0(url = "https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/736183/es/00/false/BIE-BISE/2.0/")
#' api_bie(url = url_pib)
#'
#' url_fbcf<-paste0(url = "https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/741104/es/00/false/BIE-BISE/2.0/")
#' api_bie(url = url_fbcf)
#'
#'
api_bie<-function(url){
  token <- if (!is.null(.pkg_env$config$token_bie)) {
    .pkg_env$config$token_bie
  } else {
    Sys.getenv("token_bie_get", unset = "")
  }
  if (is.null(token) || token == "") {
    stop("Token de autenticacion no configurado exitosamente.")
  }
  formato_resp <- "?type=json"
  url_api<- paste0(url,token,formato_resp) #1. Registrar el URL, Token y formato de respuesta (JSON) para cossultar información a través de la API.
  respuesta <- httr::GET(url_api) #2. Comando para llevar a cabo la consulta de información.
  httr::stop_for_status(respuesta)
  datosgenerales<-httr::content(respuesta, as = "text", encoding = "UTF-8") #3. Respuesta de la consulta de información.
  lista_json<- jsonlite::fromJSON(datosgenerales, simplifyVector = FALSE) #5. Convertir la información UTF-8 a un formato que pueda procesar R: JSON.
  datos <- data.frame(
    serie = rep(lista_json[["Series"]][[1]][["INDICADOR"]], length(lista_json[["Series"]][[1]][["OBSERVATIONS"]])),
    fecha = vapply(lista_json[["Series"]][[1]][["OBSERVATIONS"]], `[[`, character(1), "TIME_PERIOD"),
    observacion = as.numeric(vapply(lista_json[["Series"]][[1]][["OBSERVATIONS"]], `[[`, character(1), "OBS_VALUE")))

  datos <- datos[order(datos$fecha), ]

  return(datos)

}
