###############################################################################
# PORTAFOLIO OPTIMO DE CRIPTOMONEDAS: MODELO DE MARKOWITZ + DCC-GARCH
# Periodo: Octubre 2020 - Diciembre 2023
###############################################################################

options(scipen = 999)

# LIBRERÍAS: 
#install.packages("quantmod")
#install.packages("xlsx")
#install.packages("xts")
library(quantmod)
library(moments)
library(tseries)
library(FinTS)
library(rugarch)
library(rmgarch)
library(quadprog)

# ================================================================
#  MÓDULO 1: PRECIOS HISTORICOS 2020-2023
# ================================================================


# Rnago de fechas-Precios desde el 01 de octubre de 2020 al 31 diciembre 2023
inicio <- "2020-10-01"
fin <- "2023-12-31"

# Criptomonedas seleccionadas
tickers <- c("BNB-USD", "SOL-USD", "DOGE-USD", "ADA-USD", "SPY")

# Obtener los datos de las criptos y el rango de fechas dado
getSymbols(tickers,
           from=inicio,
           to=fin)

# 1. Matriz de Precios
prices <- na.omit(do.call(merge, lapply(tickers, function(x) Ad(get(x)))))
View(prices)
write.xlsx(prices, file = "crypto_prices.xlsx")


# Graficando precios en temporalidad diaria y semanal
## BNB
chartSeries(`BNB-USD`,
            theme = 'white',
            up.col = "#008B00",
            dn.col = "red",
            TA= list("addBBands()",
                     "addEMA(100, col=1)",
                     "addRSI(28)",
                     "addVo()"))

BNB_USD_semanal <- to.weekly(`BNB-USD`)
chartSeries(`BNB_USD_semanal`, 
            the= 'white',
            up.col = "#008B00",
            dn.col = "red",
            TA= list("addBBands()",
                     "addEMA(50, col=1)",
                     "addEMA(20, col=4)",
                     "addRSI(14)",
                     "addVo()"))

## SOLANA
chartSeries(`SOL-USD`,
            theme = 'white',
            up.col = "#008B00",
            dn.col = "red",
            TA= list("addBBands()",
                     "addEMA(100, col=1)",
                     "addRSI(28)",
                     "addVo()"))

SOL_USD_semanal <- to.weekly(`SOL-USD`)
chartSeries(`SOL_USD_semanal`, 
            the= 'white',
            up.col = "#008B00",
            dn.col = "red",
            TA= list("addBBands()",
                     "addEMA(50, col=1)",
                     "addEMA(20, col=4)",
                     "addRSI(14)",
                     "addVo()"))
## DOGECOIN
chartSeries(`DOGE-USD`,
            theme = 'white',
            up.col = "#008B00",
            dn.col = "red",
            TA= list("addBBands()",
                     "addEMA(100, col=1)",
                     "addRSI(28)",
                     "addVo()"))

DOGE_USD_semanal <- to.weekly(`DOGE-USD`)
chartSeries(`DOGE_USD_semanal`, 
            the= 'white',
            up.col = "#008B00",
            dn.col = "red",
            TA= list("addBBands()",
                     "addEMA(50, col=1)",
                     "addEMA(20, col=4)",
                     "addRSI(14)",
                     "addVo()"))

## ADA (CARDANO)
chartSeries(`ADA-USD`,
            theme = 'white',
            up.col = "#008B00",
            dn.col = "red",
            TA= list("addBBands()",
                     "addEMA(100, col=1)",
                     "addRSI(28)",
                     "addVo()"))

ADA_USD_semanal <- to.weekly(`ADA-USD`)
chartSeries(`ADA_USD_semanal`, 
            the= 'white',
            up.col = "#008B00",
            dn.col = "red",
            TA= list("addBBands()",
                     "addEMA(50, col=1)",
                     "addEMA(20, col=4)",
                     "addRSI(14)",
                     "addVo()"))

## SPY (mercado accionario)
chartSeries(`SPY`,
            theme = 'white',
            up.col = "#008B00",
            dn.col = "red",
            TA= list("addBBands()",
                     "addEMA(100, col=1)",
                     "addRSI(28)",
                     "addVo()"))

SPY_semanal <- to.weekly(`SPY`)
chartSeries(`SPY_semanal`, 
            the= 'white',
            up.col = "#008B00",
            dn.col = "red",
            TA= list("addBBands()",
                     "addEMA(50, col=1)",
                     "addEMA(20, col=4)",
                     "addRSI(14)",
                     "addVo()"))


# ==============================================================================
# 2. RENDIMIENTOS LOGARITMICOS 
# =============================================================================
returns <- diff(log(prices))
returns <- na.omit(returns) #eliminamos el primer NA que genera diff ()

#Renombrando las columnas (TICKERS)
colnames(returns) <- c("BNB", "SOL", "DOGE", "ADA", "SPY")

head(returns)
summary(returns)

# Rendimiento y volatilidad anualizados por activo:
# Días de trading por activo: cripto 365 días/año, SPY (~252)
dias_anualizacion <- c(BNB = 365, SOL = 365, DOGE = 365, MATIC = 365, SPY = 252)

rend_anual <- colMeans(returns) * dias_anualizacion
risk_anual <- apply(returns, 2, sd) * sqrt(dias_anualizacion)

anualizado <- data.frame(
  Activo = colnames(returns),
  Rend_Anual = rend_anual,
  Volatilidad_Anualizada = risk_anual
)

print(anualizado)

###############################################################################
###############################################################################

# ===========================================================================
#  MÓDULO 3: ANÁLISIS DESCRIPTIVO:momentos y prueba de normalidad
# ============================================================================

library(moments)    # para skewness y kurtosis
library(tseries)    # para test de Jarque-Bera

# Tabla de estadística descriptiva de los rendimientos
desc_stats <- data.frame(
  Activo = colnames(returns),
  Media = sapply(returns, mean),
  Mediana = sapply(returns, median),
  Desv_Estandar = sapply(returns, sd),
  Asimetria = sapply(returns, skewness),
  Curtosis = sapply(returns, kurtosis),
  Minimo = sapply(returns, min),
  Maximo = sapply(returns, max)
)

print(desc_stats)


# Test de normalidad Jarque-Bera (por activo)
for (activo in colnames(returns)) {
  jb <- jarque.bera.test(returns[, activo])
  cat("\n---", activo, "---\n")
  print(jb)
}
# P-value < 0.05 para todos los activos se rechaza la Ho, es decir, 
# los datos no siguen una distribución normal. Lo que justifica el
# modelado de datos GARCH/ EGARCH para capturar asimetrías y colas pesadas
# Las criptomonedas presentan asimetrías y colas muy pesadas, 
# especialmente DOGE, con valores extremos


# ========================================================================
#  MÓDULO 4: Detección de heterocedasticidad condicional: ARCH-LM Test
# ========================================================================

library(FinTS)  # para ArchTest

# Prueba ARCH-LM: 
cat("=== ARCH-LM Test ===\n")
for (activo in colnames(returns)) {
  arch_test <- ArchTest(returns[, activo], lags = 10)
  cat("\n---", activo, "---\n")
  print(arch_test)
}

# Ljung-Box sobre residuos al cuadrado
cat("\n=== Ljung-Box Test (residuos al cuadrado) ===\n")
for (activo in colnames(returns)) {
  lb_test <- Box.test(returns[, activo]^2, lag = 10, type = "Ljung-Box")
  cat("\n---", activo, "---\n")
  print(lb_test)
}

# Resultados: 
# Para todos los activos (excepto DOGE) p-value < 0.05, 
# por tanto, se rechaza Ho y,
# se acepta Ha: presencia de Efectos ARCH --> Se justifica modelado GARCH/EGARCH

#*CASO DOGE: Se acepta Ho: No hay efectos ARCH (su varianza es constante)
# esto se debe a que, la curtosis extrema (75) que presenta, el activo
# no tiene clusters de volatilidad persistentes, sino de eventos puntuales explosivos
# NO CAPTURABLES GARCH. Ejemplos: noticias, tweets, euforia explosiva, etc.

# ============================================================================
# MODULO 5: MODELOS GARCH/EGARCH UNIVARIADOS
# =============================================================================

#install.packages("rugarch")
library(rugarch)
#install.packages("rmgarch")
library(rmgarch)

# Especificaciones de los modelos
garch <- ugarchspec(
  variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(0, 0), include.mean = TRUE),
  distribution.model = "std"  # distribución t-Student (mejor que normal para colas pesadas
)

egarch <- ugarchspec(
  variance.model = list(model = "eGARCH", garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(0, 0), include.mean = TRUE),
  distribution.model = "std"
)

# Listas para guardar resultados
fit_garch <- list()
fit_egarch <- list()

# Ajuste por activo
for (activo in colnames(returns)) {
  cat("\nAjustando modelos para:", activo, "\n")
  
  fit_garch[[activo]] <- ugarchfit(spec = garch, 
                                   data = returns[, activo],
                                   solver = "hybrid")
  
  fit_egarch[[activo]] <- ugarchfit(spec = egarch, 
                                    data = returns[, activo],
                                    solver = "hybrid")
}

# TODOS LOS MODELOS CONVERGEN SIN ERROR.

# =============================================================================
# MODULO 6: COMPARACIÓN GARCH vs EGARCH (AIC/BIC)
# =============================================================================

# Tabla comparativa de criterios de información
cat("=== Comparacion AIC/BIC: GARCH vs EGARCH ===\n\n")

comparacion <- data.frame()

for (activo in colnames(returns)) {
  aic_garch  <- infocriteria(fit_garch[[activo]])[1]
  bic_garch  <- infocriteria(fit_garch[[activo]])[2]
  aic_egarch <- infocriteria(fit_egarch[[activo]])[1]
  bic_egarch <- infocriteria(fit_egarch[[activo]])[2]
  
  mejor <- ifelse(bic_egarch < bic_garch, "EGARCH", "GARCH")
  
  comparacion <- rbind(comparacion, data.frame(
    Activo     = activo,
    AIC_GARCH  = round(aic_garch, 5),
    BIC_GARCH  = round(bic_garch, 5),
    AIC_EGARCH = round(aic_egarch, 5),
    BIC_EGARCH = round(bic_egarch, 5),
    Mejor_BIC  = mejor
  ))
}

print(comparacion)

# Criterio Principal BIC - RESULTADOS POR ACTIVO:

# BNB: BIC EGARCH (-3.453) < BIC GARCH (-3.45) -> EGARCH se ajusta mejor: Hay asimetría relevante en la volatilidad (shocks negativos y pos impactan diferente)
# SOL: BIC GARCH (-3.4) < BIC EGARCH (-3.39) -> GARCH se ajusta mejor: volatilidad simetrica
# DOGE: BIC EGARCH (-2.92) < BIC GARCH (-2.91) -> EGARCH
# ADA: BIC GARCH (-2.993) < BIC EGARCH (-2.99) -> GARCH
# SPY: BIC EGARCH (-6.37) < BIC GARCH (-6.33) -> EGARCH


# =============================================================================
# VOLATILIDAD CONDICIONAL: MODELO UNIVARIADO CON CORRELACIONES ESTÁTICAS
# =============================================================================

# Extraemos la volatilidad condicionada del modelo elegido por cada activo, según BIC

sigma <- xts(cbind(
  BNB  = sigma(fit_egarch[["BNB"]]),
  SOL  = sigma(fit_garch[["SOL"]]),
  DOGE = sigma(fit_egarch[["DOGE"]]),
  ADA  = sigma(fit_garch[["ADA"]]),
  SPY  = sigma(fit_egarch[["SPY"]])
), order.by = index(returns))

head(sigma)
tail(sigma)

# CONSTRUCCIÓN DE MATRIZ DE COVARIANZA CON VOLATILIDAD CONDICIONAL:

# rendimientos promedio diarios
mu <- colMeans(returns)

# Correlaciones históricas de los activos
cor_matrix <- cor(returns)

# Matriz de covarianza condicional:
# Cov(i, j)= sigma_i * sigma_j * cor(i,j)
# Usamos sigma promedio de cada activo

sigma_media <- colMeans(sigma)

# Matriz de Covarianza con VOLATILIDAD CONDICIONAL
cov_matrix <- diag(sigma_media) %*% cor_matrix %*% diag(sigma_media)
rownames(cov_matrix) <- colnames(returns)
colnames(cov_matrix) <- colnames(returns)

cat("=== Matriz de Covarianza Condicional ===\n")
print(round(cov_matrix, 6))

# =============================================================================
# Modulo 7a: ESPECIFICACIÓN DEL MODELO DCC-GARCH (CORRELACIONES DINÁMICAS)
# =============================================================================

# Para la estimación de correlación dinámica entre los activos se utilizó una 
# especificación GARCH(1,1) uniforme para todos los activos, a pesar de que anteriormente
# los resultados de los modelos ganadores fueron mixtos (GARCH/EGARCH), dado que
# el modelo DCC requiere homogeneidad en las especificaciones univariadas

spec_univariada <- ugarchspec(
  variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
  mean.model = list(armaOrder = c(0, 0), include.mean = TRUE),
  distribution.model = "std"
)

# Replicamos la especificación para los 5 activos
spec_dcc <- dccspec(
  uspec = multispec(replicate(5, spec_univariada)),
  dccOrder = c(1, 1),
  distribution = "mvt"  # t-Student multivariada — mejor para fat tails conjuntos
)

cat("Especificación DCC lista\n")
print(spec_dcc)

# =============================================================================
# Modulo 7b: Ajuste del modelo DCC-GARCH
# =============================================================================

cat("Ajustando modelo DCC-GARCH...\n")

fit_dcc <- dccfit(spec_dcc, 
                  data = returns,
                  solver = "solnp",
                  fit.control = list(eval.se = TRUE))

cat("Modelo DCC ajustado exitosamente\n")
print(fit_dcc)

# =============================================================================
# Modulo 7c: EXTRACCIÓN DE CORRELACIONES Y COVARIANZAS DINÁMICAS
# =============================================================================

# Correlaciones dinámicas
cor_dinamicas <- rcor(fit_dcc)

# Covarianzas condicionales
cov_dinamica <- rcov(fit_dcc)

# Correlación promedio dinámica (para incorporar en Markowitz)
cor_promedio_dcc <- apply(cor_dinamicas, c(1,2), mean)
rownames(cor_promedio_dcc) <- colnames(returns)
colnames(cor_promedio_dcc) <- colnames(returns)

# Covarianza promedio dinámica
cov_promedio_dcc <- apply(cov_dinamica, c(1,2), mean)
rownames(cov_promedio_dcc) <- colnames(returns)
colnames(cov_promedio_dcc) <- colnames(returns)

cat("=== Correlaciones Dinámicas Promedio (DCC-GARCH) ===\n")
print(round(cor_promedio_dcc, 4))

cat("\n=== Matriz de Covarianza Dinámica Promedio ===\n")
print(round(cov_promedio_dcc, 6))

# Graficar evolución de correlaciones dinámicas vs SPY
fechas <- index(returns)

par(mfrow = c(2, 2))

for (i in 1:4) {
  cor_serie <- cor_dinamicas[i, 5, ]  # correlación de cada cripto con SPY
  
  plot(fechas, cor_serie,
       type = "l",
       main = paste("Correlación dinámica:", colnames(returns)[i], "vs SPY"),
       ylab = "Correlación",
       xlab = "",
       col = "steelblue",
       xaxt = "n")  # desactivamos eje X automático para controlarlo nosotros
  
  # Eje X con fechas legibles cada 6 meses
  axis.Date(1, 
            at = seq(min(fechas), max(fechas), by = "6 months"),
            format = "%b %Y",  # formato: "Oct 2020", "Apr 2021", etc.
            las = 2,           # etiquetas verticales para que no se encimen
            cex.axis = 0.7)   
  
  # Línea de correlación promedio
  abline(h = cor_promedio_dcc[i, 5], col = "red", lty = 2)
  
  # Línea en cero para referencia
  abline(h = 0, col = "gray50", lty = 3)
}

par(mfrow = c(1, 1))

# =============================================================================
# Modulo 8: OPTIMIZACIÓN MODELO DE MARKOWITZ CON CONV DINAMICA
# =============================================================================

library(quadprog)
#install.packages("quadprog")

# Insumos para Markowitz
mu_diario <- colMeans(returns)
Sigma     <- cov_promedio_dcc
n         <- ncol(returns)

# Secuencia de rendimientos objetivo
mu_objetivo <- seq(min(mu_diario), max(mu_diario), length.out = 200)

Dmat <- 2 * Sigma
dvec <- rep(0, n)

# Restricciones:
# 1. Suma de pesos = 1          (meq = 1)
# 2. Pesos >= 0                 (sin ventas en corto)
# 3. Pesos <= 0.50              (máximo 50% por activo)
# 4. Rendimiento >= mu_objetivo

Amat <- cbind(
  rep(1, n),       # 1. suma = 1
  diag(n),         # 2. pesos >= 0
  -diag(n),        # 3. pesos <= 0.50 (como -peso >= -0.50)
  mu_diario        # 4. rendimiento objetivo
)

bvec <- c(
  1,               # suma = 1
  rep(0, n),       # pesos >= 0
  rep(-0.50, n),   # -pesos >= -0.50
  0                # rendimiento objetivo (se actualiza en loop)
)

# Calcular frontera eficiente
frontera <- data.frame()

for (mu_obj in mu_objetivo) {
  bvec[length(bvec)] <- mu_obj
  
  tryCatch({
    sol   <- solve.QP(Dmat, dvec, Amat, bvec, meq = 1)
    pesos <- round(sol$solution, 6)   # limpiamos ruido numérico directamente
    rend  <- sum(pesos * mu_diario)
    vol   <- sqrt(t(pesos) %*% Sigma %*% pesos)
    sharpe <- rend / vol
    
    frontera <- rbind(frontera, data.frame(
      Rendimiento = rend,
      Volatilidad = as.numeric(vol),
      Sharpe      = as.numeric(sharpe),
      BNB         = pesos[1],
      SOL         = pesos[2],
      DOGE        = pesos[3],
      ADA         = pesos[4],
      SPY         = pesos[5]
    ))
  }, error = function(e) NULL)
}

# Verificar
cat("Puntos en la frontera eficiente:", nrow(frontera), "\n")
cat("Peso máximo en cualquier punto:", max(frontera[, 4:8]), "\n")
cat("Peso mínimo en cualquier punto:", min(frontera[, 4:8]), "\n\n")

# PORTAFOLIOS OPTIMOS:

# Portafolio de mínima varianza
pmin_var <- frontera[which.min(frontera$Volatilidad), ]
cat("=== Portafolio de Mínima Varianza ===\n")
print(round(pmin_var, 4))

# Portafolio de máximo Sharpe
pmax_sharpe <- frontera[which.max(frontera$Sharpe), ]
cat("=== Portafolio de Máximo Sharpe ===\n")
print(round(pmax_sharpe, 4))

# ==================================================================
# 9. GRAFICA DE FRONTERA EFICIENTE 
# =========================================================================

par(mar = c(5, 5, 4, 2), bg = "white")

# ── Rangos del plot (incluye activos individuales)
vol_activos <- sqrt(diag(Sigma))
x_rng <- range(c(frontera$Volatilidad, vol_activos))
y_rng <- range(c(frontera$Rendimiento, mu_diario))

x_lim <- c(x_rng[1] * 0.88, x_rng[2] * 1.05)
y_lim <- c(y_rng[1] * 1.20, y_rng[2] * 1.08)


plot(frontera$Volatilidad, frontera$Rendimiento,
     type = "l", lwd = 2.5, col = "steelblue",
     xlim = x_lim, ylim = y_lim,
     main = "Frontera Eficiente: Portafolio Cripto\nDCC-GARCH + Markowitz  |  Oct 2020 – Dic 2023",
     xlab = "Volatilidad diaria", ylab = "Rendimiento diario esperado",
     cex.main = 0.95, cex.lab = 0.90)

abline(h = 0, col = "gray75", lty = 2)

# ── Activos individuales ──────────────────────────────────
points(vol_activos, mu_diario,
       pch = 4, cex = 1.4, col = "gray30", lwd = 1.8)
text(vol_activos, mu_diario,
     labels = colnames(returns),
     pos = 4, cex = 0.80, col = "gray20")

# ── Portafolio mínima varianza ────────────────────────────
points(pmin_var$Volatilidad, pmin_var$Rendimiento,
       pch = 17, cex = 2.0, col = "blue")
text(pmin_var$Volatilidad, pmin_var$Rendimiento,
     labels = "Mín. Varianza", pos = 3, cex = 0.78, col = "blue")

# ── Portafolio máximo Sharpe ──────────────────────────────
points(pmax_sharpe$Volatilidad, pmax_sharpe$Rendimiento,
       pch = 16, cex = 2.0, col = "red")
text(pmax_sharpe$Volatilidad, pmax_sharpe$Rendimiento,
     labels = "Máx. Sharpe", pos = 3, cex = 0.78, col = "red")

# ── Leyenda ───────────────────────────────────────────────
legend("bottomright",
       legend = c("Frontera eficiente", "Mín. varianza",
                  "Máx. Sharpe", "Activos individuales"),
       col    = c("steelblue", "blue", "red", "gray30"),
       lty    = c(1, NA, NA, NA),
       pch    = c(NA, 17, 16, 4),
       lwd    = c(2.5, NA, NA, NA),
       pt.cex = c(NA, 1.4, 1.4, 1.2),
       bty    = "n", cex = 0.82)

# ============================================================================
# Resultados de Portafolio Óptimo Anualizados 
# ============================================================================

k <- 365

dias_anual <- c(BNB = 365, SOL = 365, DOGE = 365, ADA = 365, SPY = 252)

resumen_activos <- data.frame(
  Activo              = colnames(returns),
  Rend_Diario         = round(mu_diario, 6),
  Rend_Anualizado     = round(mu_diario * dias_anual, 4),
  Vol_Diaria          = round(sqrt(diag(Sigma)), 6),
  Vol_Anualizada      = round(sqrt(diag(Sigma)) * sqrt(dias_anual), 4),
  Sharpe_Anualizado   = round((mu_diario * dias_anual) /
                                (sqrt(diag(Sigma)) * sqrt(dias_anual)), 4),
  Modelo_Volatilidad  = c("EGARCH", "GARCH", "EGARCH", "GARCH", "EGARCH")
)

cat("=== Resumen de Activos Individuales ===\n")
print(resumen_activos)


portafolios <- data.frame(
  Portafolio          = c("Mínima Varianza", "Máximo Sharpe"),
  Rend_Diario         = round(c(pmin_var$Rendimiento,
                                pmax_sharpe$Rendimiento), 6),
  Rend_Anualizado     = round(c(pmin_var$Rendimiento,
                                pmax_sharpe$Rendimiento) * k, 4),
  Vol_Diaria          = round(c(pmin_var$Volatilidad,
                                pmax_sharpe$Volatilidad), 6),
  Vol_Anualizada      = round(c(pmin_var$Volatilidad,
                                pmax_sharpe$Volatilidad) * sqrt(k), 4),
  Sharpe_Anualizado   = round(c(pmin_var$Rendimiento,
                                pmax_sharpe$Rendimiento) * k /
                                (c(pmin_var$Volatilidad,
                                   pmax_sharpe$Volatilidad) * sqrt(k)), 4),
  BNB                 = round(c(pmin_var$BNB,  pmax_sharpe$BNB),  4),
  SOL                 = round(c(pmin_var$SOL,  pmax_sharpe$SOL),  4),
  DOGE                = round(c(pmin_var$DOGE, pmax_sharpe$DOGE), 4),
  ADA                 = round(c(pmin_var$ADA,  pmax_sharpe$ADA),  4),
  SPY                 = round(c(pmin_var$SPY,  pmax_sharpe$SPY),  4)
)

cat("\n=== Resumen de Portafolios Óptimos ===\n")
print(t(portafolios))  # transpuesto para mejor lectura

