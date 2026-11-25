#' Catálogo maestro del SIE de Banxico
#'
#' Disponible como data frame al cargar seriesMX, sin configurar un token.
#' Una clave puede aparecer en varias rutas temáticas con la misma URL.
#' La verificación corresponde a las fechas registradas; no es una consulta
#' en tiempo real ni una garantía de disponibilidad futura.
#' @format Un data frame con 140,527 filas y 14 columnas:
#' \describe{
#'   \item{`id_catalogo`}{Identificador de la fila, como texto.}
#'   \item{`clave_sie`}{Clave de la serie.}
#'   \item{`url_base`}{URL histórica terminada en /datos, sin token.}
#'   \item{`sectores`, `ruta_sie`}{Sector y ruta temática.}
#'   \item{`observaciones`, `observaciones_validas`}{Conteos numéricos de registros y valores válidos.}
#'   \item{`fecha_inicial`, `fecha_final`, `fecha_prueba`}{Fechas registradas, como texto.}
#'   \item{`http_estado`}{Estado HTTP registrado, como entero.}
#'   \item{`api_ok`}{Indicador lógico: TRUE, FALSE o NA si no se resolvió.}
#'   \item{`nota`}{verificado, sin_observaciones o redireccion_http302.}
#'   \item{`frecuencia`}{Frecuencia registrada; NA cuando falta.}
#' }
#' @source Hoja catalogo_maestro de banxicosie_catalogo_maestro.xlsx,
#'   fuente del proyecto revisada el 25 de noviembre de 2026.
#' @examples
#' head(catalogo_maestro_banxico)
"catalogo_maestro_banxico"
