#' Consulta y actualización de indicadores a través de la API del Sistema de Información Económica (SIE) del Banco de México
#'
#' @param url URL de la consulta al SIE de Banxico (el paquete seriesMX agrega el token y el formato). El token se configura con [tokens()].

#' @returns Un dataframe que contiene los datos de la serie de tiempo solicitada.
#' @importFrom httr content GET
#' @importFrom jsonlite fromJSON
#' @export
#'
#' @examplesIf nzchar(Sys.getenv("token_sie_get"))
#'
#' url_fix<-paste0("https://www.banxico.org.mx/SieAPIRest/service/v1/series/SF17908")
#' api_sie(url = url_fix)
#'
#' url_tiie<-paste0("https://www.banxico.org.mx/SieAPIRest/service/v1/series/SF331451")
#' api_sie(url = url_tiie)
#'
#'
api_sie<-function(url){
  token <- if (!is.null(.pkg_env$config$token_sie)) {
    .pkg_env$config$token_sie
  } else {
    Sys.getenv("token_sie_get", unset = "")
  }
  if (is.null(token) || token == "") {
    stop("Token de autenticacion no configurado exitosamente.")
  }
  entrada_token <- "/datos?token="
  formato_resp <- "&mediaType=json"
  url_api<- paste0(url,entrada_token,token,formato_resp) #1. Registrar el URL, Token y formato de respuesta (JSON) para cossultar información a través de la API.
  respuesta <- httr::GET(url_api) #2. Comando para llevar a cabo la consulta de información.
  httr::stop_for_status(respuesta)
  datosgenerales<-httr::content(respuesta, as = "text", encoding = "UTF-8") #3. Respuesta de la consulta de información.
  lista_json<- jsonlite::fromJSON(datosgenerales, simplifyVector = FALSE)  #5. Convertir la información UTF-8 a un formato que pueda procesar R: JSON.
  datos <- data.frame(
    serie = rep(lista_json[["bmx"]][["series"]][[1]][["idSerie"]], length(lista_json[["bmx"]][["series"]][[1]][["datos"]])),
    fecha = as.Date(vapply(lista_json[["bmx"]][["series"]][[1]][["datos"]], `[[`, character(1), "fecha"), format = "%d/%m/%Y"),
    observacion = as.numeric(gsub(",", "",vapply(lista_json[["bmx"]][["series"]][[1]][["datos"]], `[[`, character(1), "dato"), fixed = TRUE)))

  return(datos)

}
