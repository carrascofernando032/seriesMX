# seriesMX

Consulta, procesamiento y visualización de series macroeconómicas de México mediante las API del BIE de INEGI y del SIE de Banco de México.

## Instalación

```r
# install.packages("pak")
pak::pak("carrascofernando032/seriesMX")
library(seriesMX)
```

## 1. Consultar los catálogos sin token

Los catálogos se incluyen como data frames. El usuario no necesita descargar ni cargar un Excel.

| Objeto | Filas | Claves únicas | Columnas |
| --- | ---: | ---: | ---: |
| `catalogo_maestro_inegi` | 89,782 | 89,535 | 20 |
| `catalogo_maestro_banxico` | 140,527 | 131,512 | 14 |

Las filas conservan las rutas temáticas. Una clave repetida no representa necesariamente otra serie: en estos catálogos, cada clave tiene una sola URL distinta.

```r
head(catalogo_maestro_inegi)
head(catalogo_maestro_banxico)
buscar_clave_bie("736183")
buscar_clave_sie("SF17908")
```

## 2. Configurar los tokens

Guarda los tokens en las variables de entorno `token_bie_get` y `token_sie_get`, por ejemplo en tu archivo personal `.Renviron`. Reinicia R después de editarlo. También puedes configurarlos para la sesión:

```r
tokens(token_bie = Sys.getenv("token_bie_get"),
       token_sie = Sys.getenv("token_sie_get"))
```

No guardes los tokens reales en los archivos del paquete.

## 3. Descargar una serie por clave o por URL

```r
pib <- api_bie(clave = "736183")
fix <- api_sie(clave = "SF17908")

# Si la clave aparece en varias filas, revisa las rutas y elige una URL.
ficha <- buscar_clave_sie("SF331451")
serie <- api_sie(url = ficha$url_base[[1L]])

ficha_bie <- buscar_clave_bie("741104")
serie_bie <- api_bie(url = ficha_bie$url_base[[1L]])
```

Proporciona exactamente uno de los argumentos: `url` o `clave`. Para conservar la misma regla de BIE, SIE pide usar una URL cuando encuentra varias filas para la clave, incluso si comparten URL. `[[1L]]` selecciona una sola URL.

Las URL del catálogo SIE ya terminan en `/datos`. `api_sie()` también acepta las URL anteriores sin ese sufijo cuando corresponden al catálogo.

Ambas API devuelven tres columnas: `serie`, `fecha` y `observacion`. BIE conserva `fecha` como texto (por ejemplo, `2020/01`); SIE la entrega como `Date`. Los datos se ordenan de forma ascendente y los valores faltantes quedan como `NA`. Antes de unir series, homologa fechas y frecuencias.

Si Banxico devuelve cero observaciones, una redirección o una respuesta inválida, la función explica el problema. Si devuelve registros sin valores numéricos, conserva los registros con `NA` y muestra una advertencia. Los estados del catálogo son una fotografía de la verificación registrada, no bloquean nuevas consultas.

## 4. Transformar, resumir y graficar

Se conservan `indice()`, `suma_porc()`, `resumen()`, `estadisticos_ts()`, `graficar_ts()` y `comparar_est_ts()`. Consulta sus ejemplos con `?nombre_de_la_funcion`.

```r
set.seed(123)
datos <- data.frame(
  fecha = seq(as.Date("2020-01-01"), by = "month", length.out = 36),
  indicador = rnorm(36, 2, 0.5)
)
estadisticos_ts(datos)
graficar_ts(datos, frecuencia = 12, titulo = "Indicador simulado")
comparar_est_ts(datos, estadistico = "media_aritmetica")
```

`estadisticos_ts()` interpreta las columnas como tasas porcentuales y calcula una media geométrica de los factores `1 + x/100`; usa `resumen()` para medidas aritméticas de niveles. `graficar_ts()` admite frecuencias mensual, trimestral y anual; no agrega automáticamente series diarias o quincenales.

## Mantenimiento

`data/` contiene los dos catálogos comprimidos `.rda`; `R/catalogo_maestro_*.R` contiene su documentación. `data-raw/actualizar_catalogos.R` es el único script de importación y se usa al actualizar los Excel fuente, fuera del uso cotidiano del paquete. Requiere `readxl` solo para mantenimiento. Los Excel, resultados de consultas, SQLite y scripts antiguos de verificación se conservan fuera del paquete.

Para actualizar documentación y comprobar el paquete desde su raíz:

```r
roxygen2::roxygenise(".")
testthat::test_local(".")
# Con devtools instalado:
devtools::check()
```

Fuentes de esta edición: `inegibie_catalogo_maestro.xlsx` y `banxicosie_catalogo_maestro.xlsx`, revisadas el 25 de noviembre de 2026. Los periodos y frecuencias del catálogo se conservan como información de referencia; los valores de las series se descargan en cada consulta.
