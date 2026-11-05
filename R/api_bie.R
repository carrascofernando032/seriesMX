#' Consulta y actualización de indicadores a través de la API del Banco de Información Económica (BIE) del INEGI
#'
#' @param url El URL de la API de INEGI excluyendo el TOKEN y el formato de respuesta de la información (JSON).
#' @param token Token personal
#' @param formato_resp Formato de respuesta de la información consultada a través de la API: "?type=json"
#'
#'
#' @returns Un dataframe que contiene la serie de tiempo solicitada y sus características más importantes (metadatos).
#' @importFrom httr content GET
#' @importFrom jsonlite fromJSON
#' @export
#'
#' @examples
#' api_bie(url = paste0("https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/736183/es/00/false/BIE-BISE/2.0/"),
#' token = "f1a58e29e-8796-409c-9aeb-3206889b2005",
#' formato_resp = "?type=json")
#' api_bie(url = paste0("https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/741104/es/00/false/BIE-BISE/2.0/"),
#' token = "c1a58e29e-8796-409c-9aeb-3206889b2005",
#' formato_resp = "?type=json")
#'
api_bie<-function(url,token,formato_resp){
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
