# Optimización de Portafolio de Criptomonedas - Modelo de Markowitz con Volatilidad Condicional (GARCH/EGARCH)
Trabajo de investigación de licenciatura en Economía (UNAM). En este trabajo se lleva a cabo la construcción y optimización de un portafolio de criptomonedas mediante el Modelo de Markowitz incorporando la volatilidad condicional (GARCH/ECGARCH) como input en la matriz de covarianzas de Markowitz para capturar la heterocedasticidad característica de las series financieras, para superar las limitaciones del modelo clásico. 

### Descripción
Una de las limitantes del modelo de Markowitz es que usa la desviación estándar historica simple como medida de riesgo, asumiendo que la volatilidad es homocedástica (constante). Sin embargo,  las series financieras tienen clusters de volatilidad: se agrupa en períodos de calma y de turbulencia. En este proyecto se aborda esta limitación modelando la volatilidad condicional de cada activo mediante modelos GARCH y EGARCH, e incorporandolo como insumo a la matriz de covarianzas. Como resultado, se obtiene un portafolio óptimo que refleja el riesgo real y dinámico de los activos, no solo la volatilidad histórica promedio.

Se incluye el SPY (S&P500) como benchmark para constrastar el comportamiento riesgo-rendimiento de los activos digitales frente al mercado accionario tradicional.

### Activos anualizados:
* Dogecoin (DOGE)
* Binance Coin (BNB)
* Solana (SOL)
* Cardano (ADA)
* SPY (benchmark)

### Metodología
1. Obtención de datos: Precios históricos de 2020-2023 descargados vía YahooFinance
2. Cálculo de rendimientos logarítmicos diarios: Anualización de criptomonedas 365 días, frente a 252 días para SPY
3. Análisis descriptivo: estadística descriptiva (momentos) y pruebas de normalidad por activo Jarque-Bera
4. Prueba de efectos ARCH: Se llevan a cabo los test ARCH-LM y Ljung-Box sobre residuos al cuadrado para confirmar presencia de heterocedasticidad condicional que justifiquen el uso de modelos GARCH/EGARCH.
5. Modelado de Volatilidad Condicional GARCH/EGARCH: Ajuste de modelos GARCH y EGARCH univariados para capturar la asimetría ante shocks positivos y negativos. Seleccion de mejor modelo, según BIC.
6. Modelo DCC-GARCH (1,1) multivariado (rmgarch) con distribución t-student para incorporar correlaciones dinámicas entre los activos.
7. Cálculo de volatilidad condicional: Estimación de la desviación estandar condicional como medida de riesgo.
8. Optimización de Markowitz: Se obtienen los pesos óptimos del portafolio minimizando el riesgo para cada nivel de rendimiento objetivo con la librería quadprog. Incoporación de restricciones: Suma de pesos = 1, Pesos ≥ 0 (sin ventas en corto),
Peso máximo por activo = 50% (restricción de concentración)
9. Frontera Eficiente: Contrucción de la curva del conjunto de portafolios óptimos.
10. Métricas de riesgo/retorno
11. Comparación con benchmark: contraste de la frontera eficiente del portafolio de criptomonedas frente a SPY.

### RESULTADOS:
#### Activos individuales (anualizados)
Activo	Rend. Anual	Vol. Anual	Sharpe
SOL	161.7%	161.9%	0.999
DOGE	158.8%	207.1%	0.767
BNB	109.0%	114.2%	0.955
ADA	81.7%	129.2%	0.633
SPY	12.1%	17.6%	0.688

### Herramientas
RStudio -- Liberías: quantmod, moments, tseries, FinTS, rugarch, rmgarch, quadprog.
