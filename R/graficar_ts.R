#' Gráfica de series de tiempo a partir de datos del BIE (INEGI) y del SIE (Banxico)
#'
#' Automatiza la construcción de una gráfica de series de tiempo (una o varias
#' series) a partir de un data frame con una columna de fechas y una o más
#' columnas numéricas (indicadores), como el resultado de unir con `left_join()` los data
#' frames individuales devueltos por [api_bie()] y [api_sie()].
#'
#' La función homologa las fechas (clase `Date`, `"AAAA/MM"`, `"AAAA-MM"` o
#' `"AAAA"`), identifica la frecuencia (mensual, trimestral o anual), completa
#' con `NA` los periodos faltantes para que el objeto `ts` quede bien
#' alineado.
#'
#' @param df Data frame con una columna de fechas y una o más columnas numéricas (indicadores).
#' @param indicadores Vector de caracteres con los nombres de las columnas a graficar.
#'   Por defecto, todas las columnas numéricas (series de tiempo) excepto la de fechas.
#' @param fecha Nombre de la columna de fechas. Por defecto `"fecha"`.
#' @param frecuencia Frecuencia de la serie: `12` (mensual), `4` (trimestral) o
#'   `1` (anual). Si es `NULL`, se infiere a partir de las fechas.
#' @param inicio,fin Fechas (`Date` o texto `"AAAA-MM-DD"`) que delimitan el
#'   periodo a graficar. Si son `NULL`, se utiliza todo el periodo disponible.
#' @param titulo Título de la gráfica.
#' @param subtitulo Texto en cursiva sobre el área de la gráfica (por ejemplo,
#'   `"Base 2018 = 100"`).
#' @param fuente Nota de fuente al pie de la gráfica.
#' @param ejex,ejey Etiquetas de los ejes.
#' @param etiquetas Nombres de las series para la leyenda. Por defecto, los
#'   nombres de las columnas.
#' @param col Colores de las series (se reciclan).
#' @param lty Tipos de línea de las series (se reciclan). Por defecto `1, 2, 3, ...`
#' @param lwd Grosor de las líneas.
#' @param leyenda Posición de la leyenda (por ejemplo, `"topright"`) o `NULL`
#'   para omitirla.
#' @param cuadricula Si es `TRUE`, agrega una cuadrícula punteada a la gráfica.
#'
#' @returns De forma invisible, el objeto `ts` que se graficó.
#'
#' @importFrom stats ts ts.plot
#' @importFrom graphics grid legend mtext par
#' @export
#'
#' @examples
#' set.seed(123)
#' datos <- data.frame(
#'   fecha = seq(as.Date("2018-01-01"), by = "month", length.out = 72),
#'   fix = 19 + cumsum(rnorm(72, 0.02, 0.3)),
#'   fbcf = rnorm(72, 1, 2)
#' )
#'
#' # Variación porcentual anual del FIX (la FBCF ya está en variación anual):
#' datos$fix <- c(rep(NA, 12), (datos$fix[13:72] / datos$fix[1:60] - 1) * 100)
#'
#' graficar_ts(
#'   df = datos,
#'   inicio = "2019-01-01",
#'   titulo = "Gráfica 1. Var% anual del tipo de cambio (FIX) y la FBCF, a.e.",
#'   ejey = "Puntos porcentuales",
#'   etiquetas = c("Tipo de cambio (FIX)", "Formación Bruta de Capital Fijo, a.e."),
#'   fuente = "Fuente: elaboración propia con datos del BIE (INEGI) y el SIE (Banxico).",
#'   subtitulo = "Base 2018 = 100 para la FBCF, a.e."
#' )
#'
#' \dontrun{
#'#Con datos reales de las API's (requiere tokens personales):
#'
#' library(tidyverse)
#' library(seriesMX)
#'
#'#Tipo de cambio mensual, fecha de determinación (FIX).
#'
#'tipo_de_cambio_fix<-api_sie(url = paste0("https://www.banxico.org.mx/SieAPIRest/service/v1/series/SF17908/datos?token="),
#'token = "5864e518164893a673fa467ac9e759836dbee33aecc73525d1e1f03254e44a50",
#'formato_resp = "&mediaType=json")
#'
#'#Variación porcentual anual de la serie desestacionalizada de la Formación Bruta de Capital Fijo (TOTAL).
#' formacion_bcf<-api_bie(url = paste0("https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/741104/es/00/false/BIE-BISE/2.0/"),
#' token = "c1a58e29e-8796-409c-9aeb-3206889b2005",
#' formato_resp = "?type=json")
#'
#'#Homologación de las fechas:
#'
#'tipo_de_cambio_fix <- tipo_de_cambio_fix%>%
#'mutate(fecha = as.Date(fecha))%>%
#'filter(fecha >= "1994-01-01")
#'
#'formacion_bcf<- formacion_bcf%>%
#'mutate(fecha = as.Date(paste0(
#'gsub("/", "-", fecha), "-01")))
#'
#'#Unión por fecha y variación anual del FIX:
#'
#'fix_fbcf<- tipo_de_cambio_fix%>%
#'left_join(formacion_bcf, by = "fecha")%>%
#'rename(fix=observacion.x, fbcf=observacion.y)%>%
#'mutate(var_anual_fix = (fix / lag(fix, n = 12) - 1) * 100)%>%
#'select(fecha, fbcf, var_anual_fix)
#'
#'#Usar la función "graficar_ts" de seriesMX:
#'
#'graficar_ts(df = fix_fbcf, inicio = "2019-01-01", titulo = "Gráfica 1. Var% anual del tipo de cambio (FIX) y la FBCF, a.e.",
#'ejey = "Puntos porcentuales", etiquetas = c("Formación Bruta de Capital Fijo, a.e.", "Tipo de cambio (FIX)"),
#'fuente = "Fuente: elaboración propia con datos del BIE (INEGI) y el SIE (Banxico).",
#'subtitulo = "Base 2018 = 100 para la FBCF, a.e.")
#'
#' }
#'
graficar_ts <- function(df,
                        indicadores = NULL,
                        fecha = "fecha",
                        frecuencia = NULL,
                        inicio = NULL,
                        fin = NULL,
                        titulo = NULL,
                        subtitulo = NULL,
                        fuente = NULL,
                        ejex = "Periodo",
                        ejey = "",
                        etiquetas = NULL,
                        col = c("black", "red", "#FF1493", "#1F77B4", "#2CA02C", "#FF7F0E"),
                        lty = NULL,
                        lwd = 1.5,
                        leyenda = "topright",
                        cuadricula = TRUE) {

  # 1. Validaciones --------------------------------------------------------
  if (!is.data.frame(df)) stop("`df` debe ser un data frame. Validar con `str(df)`", call. = FALSE)
  if (!fecha %in% names(df)) {
    stop("No se encontro la columna de fechas '", fecha, "' en `df`.", call. = FALSE)
  }
  if (is.null(indicadores)) {
    numericas <- names(df)[vapply(df, is.numeric, logical(1))]
    indicadores <- setdiff(numericas, fecha)
  }
  if (length(indicadores) == 0) stop("No hay variables numericas para graficar.", call. = FALSE)
  faltan <- setdiff(indicadores, names(df))
  if (length(faltan) > 0) {
    stop("Columnas no encontradas en `df`: ", paste(faltan, collapse = ", "), call. = FALSE)
  }
  if (!all(vapply(df[indicadores], is.numeric, logical(1)))) {
    stop("Todos los indicadores a graficar deben ser numericos.", call. = FALSE)
  }
  n <- length(indicadores)
  if (is.null(etiquetas)) etiquetas <- indicadores
  if (length(etiquetas) != n) {
    stop("`etiquetas` debe tener la misma longitud que `indicadores`.", call. = FALSE)
  }

  # 2. Fechas y frecuencia ---------------------------------------------------
  fechas <- .serie_a_fecha(df[[fecha]])
  if (is.null(frecuencia)) frecuencia <- .inferir_frecuencia(fechas)
  if (!frecuencia %in% c(1, 4, 12)) {
    stop("`frecuencia` debe ser 12 (mensual), 4 (trimestral) o 1 (anual).", call. = FALSE)
  }
  fechas <- .normalizar_fecha(fechas, frecuencia)
  if (anyDuplicated(fechas) > 0) {
    stop("Hay fechas duplicadas en '", fecha, "' para la frecuencia ", frecuencia, ".", call. = FALSE)
  }

  # 3. Malla completa de periodos (los faltantes quedan como NA) -------------
  paso <- c("1" = "year", "4" = "quarter", "12" = "month")[[as.character(frecuencia)]]
  malla <- seq(min(fechas), max(fechas), by = paso)
  mat <- matrix(NA_real_, nrow = length(malla), ncol = n, dimnames = list(NULL, indicadores))
  pos <- match(fechas, malla)
  for (j in seq_len(n)) mat[pos, j] <- df[[indicadores[j]]]

  # 5. Recorte del periodo -------------------------------------------------
  inicio <- if (is.null(inicio)) min(malla) else as.Date(inicio)
  fin <- if (is.null(fin)) max(malla) else as.Date(fin)
  keep <- malla >= inicio & malla <= fin
  if (!any(keep)) stop("No hay observaciones entre `inicio` y `fin`.", call. = FALSE)
  malla <- malla[keep]
  mat <- mat[keep, , drop = FALSE]

  ano <- as.integer(format(malla[1], "%Y"))
  mes <- as.integer(format(malla[1], "%m"))
  periodo <- switch(as.character(frecuencia), "12" = mes, "4" = (mes - 1) %/% 3 + 1, "1" = 1)
  serie_ts <- stats::ts(mat, start = c(ano, periodo), frequency = frecuencia)

  # 6. Gráfica -------------------------------------------------------------
  col <- rep_len(col, n)
  lty <- if (is.null(lty)) rep_len(1:6, n) else rep_len(lty, n)

  op <- graphics::par(mar = c(5.5, 4.5, 4, 2) + 0.1)
  on.exit(graphics::par(op), add = TRUE)

  stats::ts.plot(serie_ts,
                 gpars = list(main = titulo, xlab = ejex, ylab = ejey,
                              col = col, lty = lty, lwd = lwd))

  if (isTRUE(cuadricula)) graphics::grid(col = "grey", lty = "dotted")

  if (!is.null(leyenda)) {
    graphics::legend(leyenda, legend = etiquetas, col = col, lty = lty, lwd = lwd,
                     seg.len = 1, cex = 0.8, xpd = TRUE, inset = c(0.02, 0.02),
                     bty = "n", y.intersp = 0.7)
  }
  if (!is.null(fuente)) {
    graphics::mtext(fuente, side = 1, line = 4.1, adj = 0, cex = 0.85)
  }
  if (!is.null(subtitulo)) {
    graphics::mtext(subtitulo, side = 3, line = 0.3, cex = 0.89, font = 3, col = "black")
  }

  invisible(serie_ts)
}

# Funciones auxiliares internas (no exportadas) --------------------------------

# Convierte fechas "AAAA/MM", "AAAA-MM", "AAAA" o Date/POSIXt a clase Date.
.serie_a_fecha <- function(x) {
  if (inherits(x, "Date")) return(x)
  if (inherits(x, "POSIXt")) return(as.Date(x))
  x <- gsub("/", "-", as.character(x), fixed = TRUE)
  x <- ifelse(grepl("^[0-9]{4}$", x), paste0(x, "-01-01"),
              ifelse(grepl("^[0-9]{4}-[0-9]{2}$", x), paste0(x, "-01"), x))
  out <- tryCatch(as.Date(x), error = function(e) rep(NA, length(x)))
  if (anyNA(out)) stop("No fue posible convertir la columna de fechas a clase Date.", call. = FALSE)
  out
}

# Infiere la frecuencia a partir de la mediana de la separación entre fechas.
.inferir_frecuencia <- function(fechas) {
  if (length(fechas) < 2) stop("Se requieren al menos 2 fechas.", call. = FALSE)
  dif <- stats::median(as.numeric(diff(sort(unique(fechas)))))
  if (dif >= 27 && dif <= 32) return(12)
  if (dif >= 85 && dif <= 95) return(4)
  if (dif >= 360 && dif <= 370) return(1)
  stop("No se pudo inferir la frecuencia (separacion mediana de ", dif,
       " dias). Indique `frecuencia` = 12, 4 o 1; las series diarias o ",
       "quincenales no estan consideradas.", call. = FALSE)
}

# Lleva cada fecha al primer día de su mes, trimestre o año.
.normalizar_fecha <- function(fechas, frecuencia) {
  ano <- format(fechas, "%Y")
  mes <- as.integer(format(fechas, "%m"))
  mes_ini <- switch(as.character(frecuencia),
                    "12" = mes,
                    "4" = 3 * ((mes - 1) %/% 3) + 1,
                    "1" = rep(1L, length(mes)))
  as.Date(sprintf("%s-%02d-01", ano, mes_ini))
}
