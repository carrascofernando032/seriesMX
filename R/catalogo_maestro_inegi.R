#' Catálogo maestro del BIE de INEGI
#'
#' El catálogo está disponible como data frame al cargar seriesMX. Se puede
#' usar directamente o consultar por clave con [buscar_clave_bie()]. Una misma
#' clave puede aparecer en distintos segmentos.
#'
#' @format Un data frame con 89,782 filas y 20 columnas:
#' \describe{
#'   \item{`id_catalogo`}{Identificador de la fila en el catálogo.}
#'   \item{`clave_bie`}{Clave del indicador en la API de INEGI, como texto.}
#'   \item{`url_base`}{URL completa de la consulta, antes del token y del formato.}
#'   \item{`segmento`}{Segmento temático del catálogo.}
#'   \item{`nivel_1` a `nivel_10`}{Niveles de la ruta temática.}
#'   \item{`observaciones`}{Conteo de observaciones registrado en el Excel, como texto.}
#'   \item{`fecha_inicial`, `fecha_final`}{Periodos inicial y final registrados, como texto.}
#'   \item{`fecha_prueba`}{Fecha y hora de la verificación registrada, como texto.}
#'   \item{`api_ok`}{Indicador lógico del resultado de la verificación registrada.}
#'   \item{`frecuencia`}{Frecuencia registrada para el indicador.}
#' }
#' @source Hoja `catalogo_maestro` de `inegibie_catalogo_maestro.xlsx`,
#'   elaborada a partir del Portal de Desarrolladores de INEGI.
#' @examples
#' head(catalogo_maestro_inegi)
"catalogo_maestro_inegi"
