#' Consulta y actualización de indicadores a través de la API del Sistema de Información Económica (SIE) del Banco de México
#'
#' @param url El URL de la API de INEGI excluyendo el TOKEN y el formato de respuesta de la información (JSON).
#' @param token Token personal
#' @param formato_resp Formato de respuesta de la información consultada a través de la API: "?type=json"
#'
#' @returns Un dataframe que contiene la serie de tiempo solicitada y sus características más importantes (metadatos).
#' @importFrom httr content GET
#' @importFrom jsonlite fromJSON
#' @export
#'
#' @examples
#' api_sie(url = paste0("https://www.banxico.org.mx/SieAPIRest/service/v1/series/SF17908/datos?token="),
#' token = "5864e518164893a673fa467ac9e759836dbee33aecc73525d1e1f03254e44a50",
#' formato_resp = "&mediaType=json")
#' api_sie(url = paste0("https://www.banxico.org.mx/SieAPIRest/service/v1/series/SF331451/datos?token="),
#' token = "5864e518164893a673fa467ac9e759836dbee33aecc73525d1e1f03254e44a50",
#' formato_resp = "&mediaType=json")
#'
api_sie<-function(url,token,formato_resp){
  url_api<- paste0(url,token,formato_resp) #1. Registrar el URL, Token y formato de respuesta (JSON) para cossultar información a través de la API.
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
