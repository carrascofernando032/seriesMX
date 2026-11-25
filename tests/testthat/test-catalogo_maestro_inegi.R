test_that("El catalogo maestro del INEGI es valido", {

  expect_s3_class(catalogo_maestro_inegi, "data.frame")

  expect_equal(nrow(catalogo_maestro_inegi), 89782)

  expect_true("clave_bie" %in% names(catalogo_maestro_inegi))

  expect_true("url_base" %in% names(catalogo_maestro_inegi))

  expect_equal(
    length(unique(catalogo_maestro_inegi$clave_bie)),
    89535
  )

  expect_false(anyNA(catalogo_maestro_inegi$clave_bie))

  expect_false(anyNA(catalogo_maestro_inegi$url_base))

})
