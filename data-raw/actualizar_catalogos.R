# Solo para quien mantiene el paquete. El usuario final NO ejecuta este script.
# source("data-raw/actualizar_catalogos.R", encoding = "UTF-8")
# actualizar_catalogos("ruta/inegibie_catalogo_maestro.xlsx",
#                     "ruta/banxicosie_catalogo_maestro.xlsx")
actualizar_catalogos <- function(archivo_bie, archivo_sie) {
  if (!file.exists("DESCRIPTION")) stop("Abre primero el proyecto seriesMX.")
  if (!requireNamespace("readxl", quietly = TRUE)) stop("Instala readxl.")
  leer <- function(archivo) as.data.frame(readxl::read_excel(
    archivo, sheet = "catalogo_maestro", col_types = "text"
  ), stringsAsFactors = FALSE)
  logico <- function(x) {
    x <- toupper(trimws(x))
    if (any(!is.na(x) & !x %in% c("TRUE", "FALSE", "VERDADERO", "FALSO"))) {
      stop("api_ok contiene etiquetas no reconocidas.")
    }
    resultado <- rep(NA, length(x))
    resultado[x %in% c("TRUE", "VERDADERO")] <- TRUE
    resultado[x %in% c("FALSE", "FALSO")] <- FALSE
    resultado
  }
  catalogo_maestro_inegi <- leer(archivo_bie)
  catalogo_maestro_banxico <- leer(archivo_sie)
  columnas_bie <- c("id_catalogo", "clave_bie", "url_base", "segmento",
                    paste0("nivel_", 1:10), "observaciones", "fecha_inicial",
                    "fecha_final", "fecha_prueba", "api_ok", "frecuencia")
  columnas_sie <- c("id_catalogo", "clave_sie", "url_base", "sectores", "ruta_sie",
                    "observaciones", "observaciones_validas", "fecha_inicial",
                    "fecha_final", "fecha_prueba", "http_estado", "api_ok", "nota", "frecuencia")
  stopifnot(identical(names(catalogo_maestro_inegi), columnas_bie),
            identical(names(catalogo_maestro_banxico), columnas_sie))
  catalogo_maestro_inegi$api_ok <- logico(catalogo_maestro_inegi$api_ok)
  catalogo_maestro_banxico$api_ok <- logico(catalogo_maestro_banxico$api_ok)
  catalogo_maestro_banxico$frecuencia[
    tolower(catalogo_maestro_banxico$frecuencia) %in% c("null", "na", "")
  ] <- NA_character_
  for (columna in c("observaciones", "observaciones_validas", "http_estado")) {
    original <- catalogo_maestro_banxico[[columna]]
    valor <- suppressWarnings(as.numeric(original))
    if (any(!is.na(original) & is.na(valor))) stop("Conteo o estado HTTP no numérico: ", columna)
    catalogo_maestro_banxico[[columna]] <- if (columna == "http_estado") as.integer(valor) else valor
  }
  for (origen in c("inegi", "banxico")) {
    catalogo <- if (origen == "inegi") catalogo_maestro_inegi else catalogo_maestro_banxico
    clave <- if (origen == "inegi") "clave_bie" else "clave_sie"
    stopifnot(!anyNA(catalogo[[clave]]), !anyNA(catalogo$url_base),
              !anyNA(catalogo$id_catalogo), !anyDuplicated(catalogo$id_catalogo))
    extraida <- if (origen == "inegi") {
      sub("^https://www\\.inegi\\.org\\.mx/.*/INDICATOR/([0-9]+)/.*$", "\\1", catalogo$url_base)
    } else sub("^https://www\\.banxico\\.org\\.mx/SieAPIRest/service/v1/series/([A-Z]+[0-9]+)/datos$", "\\1", catalogo$url_base)
    stopifnot(identical(extraida, catalogo[[clave]]))
  }
  dir.create("data", showWarnings = FALSE)
  save(catalogo_maestro_inegi, file = "data/catalogo_maestro_inegi.rda", compress = "xz", version = 2)
  save(catalogo_maestro_banxico, file = "data/catalogo_maestro_banxico.rda", compress = "xz", version = 2)
  message("Catálogos actualizados: INEGI ", nrow(catalogo_maestro_inegi),
          " filas; Banxico ", nrow(catalogo_maestro_banxico), " filas.")
  invisible(NULL)
}
