
<!-- README.md is generated from README.Rmd. Please edit that file -->

# seriesMX

<!-- badges: start -->

<!-- badges: end -->

Las API’s web institucionales son el medio por el cual se presentan
diversos indicadores de la economía mexicana al público general para que
investigadores y desarrolladores consulten los datos de una manera
eficiente y segura.

seriesMX es un paquete de R que automatiza la descarga, procesamiento,
presentación y actualización de diversos indicadores de la economía
mexicana a través del uso de las API’s web del Sistema de Información
Económica (SIE) de Banco de México (Banxico), y del Banco de Información
Económica (BIE) del Instituto Nacional de Estadística y Geografía
(INEGI).

¿Por qué se clasifican como API’s Web?

Una API web (Application Programming Interface o Interfaz de
Programación de Aplicaciones) es un conjunto de reglas y protocolos que
permite que diferentes aplicaciones o sistemas se comuniquen e
intercambien datos a través de internet, utilizando principalmente el
protocolo HTTP/HTTPS.

Para más información consultar: <https://www.ibm.com/think/topics/api>

En ese sentido, para acceder a los datos a través de las API’s web no es
necesario instalar algún software. En su lugar, se realiza una petición
web (una solicitud HTTP) por medio de una dirección URL específica
provista por los sistemas informáticos de INEGI y Banxico. Al momento de
llevar a cabo la consulta, sus servidores procesan la petición y
devuelven la información en formatos estructurados estándar de
intercambio de datos web, principalmente JSON o JSON-Stat.

Sin embargo, es importante señalar que ambos sistemas requieren que se
lleve a cabo un registro en sus “portales de desarrolladores” para
obtener un “Token” o clave de acceso digital, la cual viaja junto con la
petición web para registar y validar el acceso del usuario.

# Enlace del portal de desarrolladores de la API del Banco de Indicadores (BIE) o del Sistema de Información Económica (SIE).

A través de estos portales, los desarrolladores o analistas que
requieren la automatización del proceso de extracción de información
económica publicada por INEGI y Banxico, pueden acceder a los datos
correspondientes.

- INEGI (BIE/BISE):
  <https://www.inegi.org.mx/servicios/api_indicadores.html>

- Banxico (SIE): <https://www.banxico.org.mx/SieAPIRest/service/v1/>

Para consultar la dirección URL de la información asociada a los
indicadores, los usuarios deben seleccionar el “Constructor de
Consultas” en el caso del API de INEGI o el “Catálogo de series” en el
caso de Banxico.

Cualquier lenguaje de programación que tenga la capacidad de conectarse
a internet (como Python, R o incluso macros avanzadas de Excel) puede
consumir estas herramientas enviando peticiones HTTPS de forma remota.

# Acceso al Token de autenticación para realizar las peticiones de información al API del BIE o SIE.

Antes de usar seriesMX, es indispensable consultar los siguientes
enlaces para generar los token correspondientes:

- INEGI (BIE/BISE):
  <https://www.inegi.org.mx/app/desarrolladores/generatoken/Usuarios/token_Verify>

- Banco de México (SIE):
  <https://www.banxico.org.mx/SieAPIRest/service/v1/token>

Nota: en la práctica es posible generar más de un token, su propósito
sólo es controlar el flujo de acceso a las API’s desde los servidores de
INEGI y Banxico.

# Instalación del paquete.

Puede instalar la última versión del paquete “seriesMX” desde
[GitHub](https://github.com/):

``` r
# install.packages("pak")
pak::pak("carrascofernando032/seriesMX")
```

# Módulo de consumo e integración de las API’s de INEGI y Banxico.

En seriesMX, las funciones denominadas “api_bie” y “api_sie” son los
componentes del paquete que conectan y extraen información de las API’s
de INEGI y Banxico.

## ¿Qué hacen exactamente las funciones api_bie y api_sie?

Consumen las API’s de INEGI o Banxico (por ejemplo, consultando el tipo
de cambio) para obtener información, toman los datos que reciben y los
adaptan para que puedan ser usados, guardados o procesados por R, y
estandarizan el formato de los datos (JSON o XML) controlando los
errores, tiempos de espera y la seguridad (Tokens).

- API del Banco de Información Económica (BIE / INEGI): la función
  “api_bie” automatiza las solicitudes de información a la API de INEGI
  utilizando el token de desarrollador.
- API del Sistema de Información Económica (SIE / Banxico): la función
  “api_sie” es equivalente a “api_bie” para consultar información de
  Banco de México.

# ¿Cómo consultar información a través de la API de INEGI o Banxico?

Ejemplo api_bie - INEGI. Var% anual de la serie desestacionalizada del
Producto Interno Bruto (base 2018).

Argumentos:

- URL del indicador que se desea consultar a través de la API:
  “<https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/736183/es/00/false/BIE-BISE/2.0/>”

- Token de autenticación: “f1a58e29e-8796-409c-9aeb-3206889b2067”

- Formato de respuesta de la información: “?type=json”

Ejemplo api_sie - Banxico. Tipo de cambio mensual, fecha de
determinación (FIX).

Argumentos: - URL del indicador que se desea consultar a través de la
API:
“<https://www.banxico.org.mx/SieAPIRest/service/v1/series/SF17908/datos?token=>”

- Token de autenticación:
  “5864e518164893a673fa467ac9e759836dbee33aecc73525d1e1f03254e43b70”

- Formato de respuesta de la información: “&mediaType=json”

# Características del resultado de api_bie y api_sie

## Data frame

Un data frame en R es una estructura de datos bidimensional (en forma de
tabla con filas y columnas) que permite almacenar datos heterogéneos.Es
el objeto más utilizado para el análisis estadístico y la manipulación
de información en R, ya que funciona de forma similar a una hoja de
cálculo de Excel.

Con un data frame se pueden implementar las herramientas intermedias del
lenguaje de programación R con énfasis en la limpieza, manipulación de
datos y visualizaciones avanzadas.

Debido a la heterogenidad en la información que proviene de los
servidores del Banco de México e INEGI (datos, metadatos, el nombre del
indicador o la frecuencia de las observaciones) api_bie y api_sie
estandarizan los data frames que resulten de utilizar estas funciones.

``` r
library(seriesMX)
api_bie(url = paste0("https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/736183/es/00/false/BIE-BISE/2.0/"),
token = "ejemplo_tokenf1a58e29e-8796-409c-9aeb-3206889b2067",
formato_resp = "?type=json")
```

# Módulo para la unión y visualización de los datos a través de una variable en común: periodo de tiempo

Este módulo está diseñado para tomar los datos extraídos de las API de
BIE (INEGI) y SIE (Banco de México) y generar visualizaciones de las
series. En la ciencia de datos es común tener que unir bases entre sí,
pues un álisis no implica trabajar con una sola base o dataframe, al
contrario, se suele trabajar con múltiples bases y generalmente (casi
siempre) se requiere combinarlas para dar respuesta a las preguntas que
motivan el análisis.

La idea fundamental es: agregar nuevas variables a un marco de datos a
partir de observaciones coincidentes en otro.

En el siguiente caso se tienen dos formatos: - Data frame 1:
“1992-08-01” (fecha diaria). - Data frame 2: “1992/08” (fecha mensual).

Se deben homologar las fechas al primer día de cada mes. Sin embargo,
antes de unir los data frames es importante verificar que ambas series
abarquen el mismo periodo de tiempo.

## Familia Join de la colección Tidyverse en R

Tidyverse es una colección de paquetes de código abierto para R,
diseñados específicamente para la ciencia de datos.

Tidyverse, a través del paquete denominado dplyr, tiene una familia de
funciones llamada “join”. Sus integrantes son: left, rigth, inner, full,
semi y anti, todos de apellido “\_join”. Cada uno de los integrantes de
la familia tiene su peculiaridad, pero todos coinciden en que la unión
de datos debe ser a través de una(s) variable(s) en común.

Para utilizar la función “left_join()” de Tidyverse, es necesario que
las variables “fecha” tengan el mismo formato y, preferentemente, la
misma clase (Date).

## Gráfica de series de tiempo a partir de datos del BIE (INEGI) y del SIE (Banxico) con la función “graficar_ts” de seriesMX

La función “graficar_ts” de seriesMX automatiza la construcción de una
gráfica de series de tiempo a partir de un data frame con una columna de
fechas y una o más columnas numéricas (indicadores), como el resultado
de unir con `left_join()` los data frames individuales devueltos por
api_bie() y api_sie().

``` r
#Paquetería necesaria.
library(tidyverse)
#> Warning: package 'tidyverse' was built under R version 4.6.1
#> Warning: package 'ggplot2' was built under R version 4.6.1
#> Warning: package 'tibble' was built under R version 4.6.1
#> Warning: package 'tidyr' was built under R version 4.6.1
#> Warning: package 'readr' was built under R version 4.6.1
#> Warning: package 'purrr' was built under R version 4.6.1
#> Warning: package 'dplyr' was built under R version 4.6.1
#> Warning: package 'stringr' was built under R version 4.6.1
#> Warning: package 'forcats' was built under R version 4.6.1
#> Warning: package 'lubridate' was built under R version 4.6.1
#> ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
#> ✔ dplyr     1.2.1     ✔ readr     2.2.0
#> ✔ forcats   1.0.1     ✔ stringr   1.6.0
#> ✔ ggplot2   4.0.3     ✔ tibble    3.3.1
#> ✔ lubridate 1.9.5     ✔ tidyr     1.3.2
#> ✔ purrr     1.2.2     
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
#> ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
library(seriesMX)

#Tipo de cambio mensual, fecha de determinación (FIX).

tipo_de_cambio_fix<-api_sie(url = paste0("https://www.banxico.org.mx/SieAPIRest/service/v1/series/SF17908/datos?token="),
token = "5864e518164893a673fa467ac9e759836dbee33aecc73525d1e1f03254e44a50",
formato_resp = "&mediaType=json")

#Variación porcentual anual de la serie desestacionalizada de la Formación Bruta de Capital Fijo (TOTAL).

formacion_bcf<-api_bie(url = paste0("https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/741104/es/00/false/BIE-BISE/2.0/"),
token = "c1a58e29e-8796-409c-9aeb-3206889b2005",
formato_resp = "?type=json")

#Homologación de las fechas:

tipo_de_cambio_fix <- tipo_de_cambio_fix%>%
  mutate(fecha = as.Date(fecha))%>%
  filter(fecha >= "1994-01-01")

formacion_bcf<- formacion_bcf%>%
  mutate(fecha = as.Date(paste0(
    gsub("/", "-", fecha), "-01")))

# Unión por fecha y variación anual del FIX:

fix_fbcf<- tipo_de_cambio_fix%>%
  left_join(formacion_bcf, by = "fecha")%>%
  rename(fix=observacion.x, fbcf=observacion.y)%>%
  mutate(var_anual_fix = (fix / lag(fix, n = 12) - 1) * 100)%>%
  select(fecha, fbcf, var_anual_fix)


#Usar la función "graficar_ts" de seriesMX: 

graficar_ts(df = fix_fbcf,
  inicio = "2019-01-01",
  titulo = "Gráfica 1. Var% anual del tipo de cambio (FIX) y la FBCF, a.e.",
  ejey = "Puntos porcentuales",
  etiquetas = c("Formación Bruta de Capital Fijo, a.e.", "Tipo de cambio (FIX)"),
  fuente = "Fuente: elaboración propia con datos del BIE (INEGI) y el SIE (Banxico).",
  subtitulo = "Base 2018 = 100 para la FBCF, a.e.")
```

<img src="man/figures/README-ejemplo-integracion-series-1.png" alt="" width="100%" />
