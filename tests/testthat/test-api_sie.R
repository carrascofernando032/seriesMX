# Las respuestas se simulan: estas pruebas no consultan la API ni usan tokens reales.
respuesta_sie <- function(datos, clave = "SF17908", estado = 200L) {
  texto <- jsonlite::toJSON(list(bmx = list(series = list(
    list(idSerie = clave, datos = datos)
  ))), auto_unbox = TRUE, null = "null")
  structure(list(status_code = estado, url = "https://www.banxico.org.mx/",
                 headers = list(`content-type` = "application/json"),
                 content = charToRaw(texto)), class = "response")
}

test_that("el catálogo de Banxico conserva rutas, claves y estados", {
  x <- catalogo_maestro_banxico
  expect_equal(dim(x), c(140527L, 14L))
  expect_equal(length(unique(x$clave_sie)), 131512L)
  expect_false(anyDuplicated(x$id_catalogo) > 0L)
  expect_type(x$api_ok, "logical")
  expect_equal(sum(x$nota == "verificado"), 140371L)
  expect_equal(sum(x$nota == "sin_observaciones"), 150L)
  expect_equal(sum(x$nota == "redireccion_http302"), 6L)
  expect_equal(sum(is.na(x$api_ok)), 6L)
  expect_identical(x$url_base, paste0(
    "https://www.banxico.org.mx/SieAPIRest/service/v1/series/", x$clave_sie, "/datos"))
  expect_equal(nrow(buscar_clave_sie("SF331451")), 2L)
  expect_equal(nrow(buscar_clave_sie("SF999999999")), 0L)
  expect_error(buscar_clave_sie(17908), "una sola clave")
  expect_error(buscar_clave_sie(NA_character_), "una sola clave")
})

test_that("las entradas inválidas y las claves repetidas se explican antes de consultar", {
  expect_error(api_sie(), "exactamente uno")
  expect_error(api_sie(url = "x", clave = "SF17908"), "exactamente uno")
  expect_error(api_sie(clave = "SF999999999"), "no está")
  expect_error(api_sie(clave = "SF331451"), "aparece en 2 filas")
  expect_error(api_sie(url = NA_character_), "una sola URL")
  expect_error(api_sie(url = "https://example.com"), "url_base")
  withr::local_envvar(token_sie_get = "")
  local_mocked_bindings(.pkg_env = list(config = list()), .package = "seriesMX")
  expect_error(api_sie(clave = "SF17908"), "Configura el token")
})

test_that("clave y las dos formas de URL producen la misma tabla ordenada", {
  local_mocked_bindings(.pkg_env = list(config = list(token_sie = "prueba")), .package = "seriesMX")
  datos <- list(list(fecha = "02/01/2020", dato = "N/E"),
                list(fecha = "01/01/2020", dato = "1,234.50"),
                list(fecha = "03/01/2020", dato = NULL))
  usadas <- character()
  local_mocked_bindings(GET = function(url, ...) {
    usadas <<- c(usadas, url)
    respuesta_sie(datos)
  }, .package = "httr")
  x <- api_sie(clave = "SF17908")
  url <- "https://www.banxico.org.mx/SieAPIRest/service/v1/series/SF17908/datos"
  expect_identical(x, api_sie(url = url))
  expect_identical(x, api_sie(url = sub("/datos$", "", url)))
  expect_identical(usadas, rep(url, 3))
  expect_identical(names(x), c("serie", "fecha", "observacion"))
  expect_s3_class(x$fecha, "Date")
  expect_equal(x$observacion, c(1234.5, NA_real_, NA_real_))
  expect_identical(x$fecha, as.Date(c("2020-01-01", "2020-01-02", "2020-01-03")))
})

test_that("los datos ausentes, errores y redirecciones se distinguen", {
  local_mocked_bindings(.pkg_env = list(config = list(token_sie = "prueba")), .package = "seriesMX")
  r <- respuesta_sie(list())
  local_mocked_bindings(GET = function(...) r, .package = "httr")
  expect_error(api_sie(clave = "SF17908"), "no tiene observaciones")
  r <- respuesta_sie(list(list(fecha = "01/01/2020", dato = "N/E")))
  expect_warning(x <- api_sie(clave = "SF17908"), "no contiene valores numéricos")
  expect_true(is.na(x$observacion))
  r <- respuesta_sie(list(), estado = 302L)
  expect_error(api_sie(clave = "SF17908"), "redirección HTTP")
  r <- respuesta_sie(list(), estado = 401L)
  expect_error(api_sie(clave = "SF17908"), "401")
  r <- respuesta_sie(list(), estado = 429L)
  expect_error(api_sie(clave = "SF17908"), "429")
  r <- respuesta_sie(list()); r$content <- charToRaw("<html>error</html>")
  expect_error(api_sie(clave = "SF17908"), "JSON válida")
  r <- respuesta_sie(list(), clave = "SF1")
  expect_error(api_sie(clave = "SF17908"), "esperados")
  r <- respuesta_sie(list(list(fecha = "31/02/2020", dato = "1")))
  expect_error(api_sie(clave = "SF17908"), "fechas inválidas")
})
