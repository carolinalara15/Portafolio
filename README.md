# Portafolio
En este proyecto se lleva a cabo la construcción y optimización de un portafolio de criptomonedas mediante el Modelo de Markowit. Cálculo de frontera eficiente, rendimiento esperado y riesgo del portafolio en RStudio
Una de las limitantes del modelo de Markowitz es que usa la desviación estándar historica simple como medida de riesgo, asumiendo que la volatilidad es homocedástica (constante). Pero las series financieras, especialmente las criptomonedas, tienen clusters de volatilidad. Considerando lo anterior, en este trabajo se captura y modela la volatilidad condicional de GARCH/EGARCH, y se incorpora como input en la matriz de covarianzas de Markowitz, en lugar de la desviación estándar simple. Esto permite reflejar el riesgo real y dinámico del portafolio.

En los archivos .do se encuntran los análisis descriptivos
