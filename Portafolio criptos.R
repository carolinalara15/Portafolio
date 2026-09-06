###############################################################################
# PORTAFOLIO DE CRIPTOMONEDA: MODELO DE MARKOWITZ
# VOLATILIDAD CONDICIONAL: GARCH/EGARCH
###############################################################################

options(scipen = 999)

# ============================================================
#  MÓDULO 1: DATOS HISTORICOS Y RETORNOS LOGARÍTMICOS: 2020-2023
#  Pipeline: GARCH/EGARCH → DCC → Markowitz
# ============================================================

# LIBRERÍAS: 
#install.packages("quantmod")
#install.packages("xlsx")
#install.packages("xts")
library(quantmod)
library(xlsx)
library(zoo)

# Rnago de fechas-Precios desde el 01 de octubre de 2020 al 31 diciembre 2023
inicio <- "2020-10-01"
fin <- "2023-12-31"

# Criptomonedas seleccionadas
tickers <- c("BNB-USD", "SOL-USD", "DOGE-USD", "MATIC-USD", "SPY")

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

## MATIC
chartSeries(`MATIC-USD`,
            theme = 'white',
            up.col = "#008B00",
            dn.col = "red",
            TA= list("addBBands()",
                     "addEMA(100, col=1)",
                     "addRSI(28)",
                     "addVo()"))

MATIC_USD_semanal <- to.weekly(`MATIC-USD`)
chartSeries(`MATIC_USD_semanal`, 
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

###############################################################################
###############################################################################

# Rendimientos logaritmicos diarios
library(quantmod)

returns <- diff(log(prices))
returns <- na.omit(returns) #eliminamos el primer NA que genera diff ()

#Renombrando las columnas (TICKERS)
colnames(returns) <- c("BNB", "SOL", "DOGE", "MATIC", "SPY")

head(returns)
summary(returns)

###############################################################################
###############################################################################

# ===========================================================================
#  MÓDULO 2: ANÁLISIS DESCRIPTIVO:momentos y prueba de normalidad
# ============================================================================

#install.packages("moments")
#install.packages("tseries")
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
#  MÓDULO 3: Detección de heterocedasticidad condicional: ARCH-LM Test
# ========================================================================

install.packages("FinTS")
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

# ============================================================================
# MODULO 4: MODELOS GARCH/EGARCH
# =============================================================================

install.packages("rugarch")
library(rugarch)

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
