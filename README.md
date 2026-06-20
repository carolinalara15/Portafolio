# Optimización de Portafolio de Criptomonedas - Modelo de Markowitz con Volatilidad Condicional (GARCH/EGARCH)
Trabajo de investigación de licenciatura en Economía (UNAM). 
En este trabajo se lleva a cabo la construcción y optimización de un portafolio de criptomonedas mediante el Modelo de Markowitz incorporando la volatilidad condicional (GARCH/ECGARCH) como input en la matriz de covarianzas de Markowitz para capturar la heterocedasticidad característica de las series financieras, especialmente las criptomonedas. 

### Descripción
Una de las limitantes del modelo de Markowitz es que usa la desviación estándar historica simple como medida de riesgo, asumiendo que la volatilidad es homocedástica (constante). Sin embargo,  las series financieras tienen clusters de volatilidad: se agrupa en períodos de calma y de turbulencia. En este proyecto se aborda esta limitación modelando la volatilidad condicional de cada activo mediante modelos GARCH y EGARCH, e incorporandolo como insumo a la matriz de covarianzas. Como resultado, se obtiene un portafolio óptimo que refleja el riesgo real y dinámico de los activos, no solo laa volatilidad histórica promedio.

Se incluye el SPY (S&P500) como benchmark para constrastar el comporamiento riesgo-rendimiento de los activos digitales frente al mercado accionario tradicional.

### Activos analizados:
* Bitcoin (BTC)
* Dogecoin (DOGE)
* Binance Coin (BNB)
* Solana (SOL)
* Polygon (MATIC)
* Ripple (XRP)
* SPY (benchmark)

### Metodología
1. Obtención de datos: Precios históricos de 2020-2023 descargados vía YahooFinance
2. Análisis descriptivo: estadística descriptiva y exploración de rendimientos de cada activo
3. Modelado de Volatilidad Condicional: Ajuste de modelos GARCH y EGARCH para capturar la asimetría ante shocks positivos y negativos.
4. Cálculo de volatilidad condicional: Estimación de la desviación estandar condicional a partir de los modelos GARCH/EGARCH como medida de riesgo.
5. Optimización de Markowitz: Se obtienen los pesos óptimos del portafolio minimizando el riesgo para cada nivel de rendimiento objetivo.
6. Frontera Eficiente: Contrucción de la curva del conjunto de portafolios óptimos.
7. Métricas de riesgo/retorno
8. Comparación con benchmark: contraste de la frontera eficiente del portafolio de criptomonedas frente a SPY.

### Herramientas
RStudio -- Liberías: quantmod, PermormanceAnalytics
