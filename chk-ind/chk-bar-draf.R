## Check indikator

## ----------------
## Function
## ----------------
packages <- c("data.table", "haven")

ipkg <- function(pkg){
  newp <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if(length(newp)) install.packages(newp, repos = "https://cran.uib.no", dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

ipkg(packages)

fpath <- "F:/Prosjekter/Kommunehelsa/PRODUKSJON/PRODUKTER/SSRS_filer/OVP/2020/Kommune/FigurOgTabell"
indDTA <- "Indikator_ny.dta"
barDTA <- "inndataBarometer.dta"

## indikator : fil for indikator
## barometer: fil for barometer
## path : Sti for disse filene

check_bar <- function(type = c("FHP", "OVP"),
                      year = NULL,
                      geo = c("fylke", "kommune", "bydel"),
                      indikator = NULL,
                      barometer = NULL,
                      path = NULL
                      ){

  cat("In progress ...")
  type <- match.arg(type)
  geo <- match.arg(geo)

  ## Barometer
  bar <- haven::read_dta(file.path(path, barometer))

  data.table::setDT(bar)
  barV1 <- c("stedskode_string",
             "stedskode_numeric",
             "indikator_kodet",
             "roede",
             "groenne",
             "hvitMprikk")
  bar[, setdiff(names(bar), barV1) := NULL]

  cat("...")
  data.table::setkey(bar, indikator_kodet)
  ## barometer id starts from 2 and is inverse of indikator id
  ## this makes it equivalent to indikator id
  bar[, kode := rev(indikator_kodet - 1)]

  ## Indicator
  cat("...")
  indraw <- haven::read_dta(file.path(path, indikator))
  
  data.table::setDT(indraw)
  indV1 <- grep("Verdi", names(indraw), value = TRUE)
  indVar <- c("Aar", "LPnr","Sted_kode", "SpraakId", indV1)
  indraw[, setdiff(names(indraw), indVar) := NULL]
  ind <- indraw[SpraakId == "BOKMAAL"]

  cat("... \n\n")
  withVar <- c("Aar", indV1)
  bar[ind, (withVar) := mget(withVar), on = c(stedskode_string = "Sted_kode", kode = "LPnr")]
  setnames(bar, "kode", "LPnr")
  bar

  bar[Verdi_lavesteGeonivaa == Verdi_referansenivaa, ][
    !is.na(roede) | !is.na(groenne) | !is.na(hvitMprikk)]

}

ab <- check_bar(indikator = indDTA, bar = barDTA, path = fpath)



###-----------------
## TEST
##------------------

fpath <- "F:/Prosjekter/Kommunehelsa/PRODUKSJON/PRODUKTER/SSRS_filer/OVP/2020/Kommune/FigurOgTabell"
indDTA <- "Indikator_ny.dta"
barDTA <- "inndataBarometer.dta"

indraw <- haven::read_dta(file.path(fpath, indDTA))
bar <- haven::read_dta(file.path(fpath, barDTA))

setDT(indraw)
indV1 <- grep("Verdi", names(indraw), value = TRUE)
indVar <- c("Aar", "LPnr","Sted_kode", "SpraakId", indV1)
indraw[, setdiff(names(indraw), indVar) := NULL]
ind <- indraw[SpraakId == "BOKMAAL"]
names(ind)


setDT(bar)
names(bar)
barV1 <- c("stedskode_string", "stedskode_numeric", "indikator_kodet", "roede", "groenne", "hvitMprikk")
bar[, setdiff(names(bar), barV1) := NULL]

## ind[LPnr == 1, ][Sted_kode == "0301"]
## bar[indikator_kodet == 30, ][stedskode_string == "0301"]

setkey(bar, indikator_kodet)
bar[, kode := rev(indikator_kodet - 1)]
bar

## Merge
## keepV <- c("indikator_kodet", "roede", "groenne", "hvitMprikk")
## ind[bar, (keepV) := mget(keepV), on = c(Sted_kode = "stedskode_string", LPnr = "kode")]
## ind

## strVar <- c("Verdi_lavesteGeonivaa", "Verdi_mellomGeonivaa", "Verdi_referansenivaa", keepV)


withVar <- c("Aar", indV1)
bar[ind, (withVar) := mget(withVar), on = c(stedskode_string = "Sted_kode", kode = "LPnr")]
setnames(bar, "kode", "LPnr")
bar

bar[Verdi_lavesteGeonivaa == Verdi_referansenivaa, ][!is.na(roede) | !is.na(groenne) | !is.na(hvitMprikk)]


### PROGRESS BAR
## ---------------
total <- 10
for(i in 1:total){
  print(i)
  Sys.sleep(0.1)
}

total <- 20
for(i in 1:total){
  Sys.sleep(0.1)
  print(i)
  # update GUI console
  flush.console()                          
}



library(progress)
pb <- progress_bar$new(total = 100)
for (i in 1:100) {
  pb$tick()
  Sys.sleep(1 / 100)
}

pb <- progress_bar$new(
  format = "  downloading [:bar] :percent eta: :eta",
  total = 100, clear = FALSE, width= 60)
for (i in 1:100) {
  pb$tick()
  Sys.sleep(1 / 100)
}

pb <- progress_bar$new(
  format = "  downloading :what [:bar] :percent eta: :eta",
  clear = FALSE, total = 200, width = 60)
f <- function() {
  for (i in 1:100) {
    pb$tick(tokens = list(what = "foo   "))
    Sys.sleep(2 / 100)
  }
  for (i in 1:100) {
    pb$tick(tokens = list(what = "foobar"))
    Sys.sleep(2 / 100)
  }
}
f()



## No package use
y <- matrix(0, nrow = 31, ncol = 5)
for(sim in 1:5){
  y[1, sim] <- rnorm(1, 0, 8)
  for(j in 1:30){
    y[j+1, sim] <- y[j, sim] + rnorm(1) # random walk
    cat("simulation", sim, "// time step", sprintf("%2.0f", j), "// random walk", sprintf(y[j+1, sim], fmt='% 6.2f'), "\r")
    Sys.sleep(0.1)
  }
}

library(progress)
pb <- progress_bar$new(format = ":elapsedfull // eta :eta // simulation :sim // time step :ts // random walk :y [:bar]", total = 30*5, clear = FALSE)
y <- matrix(0, nrow = 31, ncol = 5)
for(sim in 1:5){
  y[1, sim] <- rnorm(1, 0, 8)
  for(j in 1:30){
    y[j+1, sim] <- y[j, sim] + rnorm(1) # random walk
    pb$tick(tokens = list(sim = sim, ts = sprintf("%2.0f", j), y = sprintf(y[j+1, sim], fmt='% 6.2f')))
    Sys.sleep(0.1)
  }
}




n <- 300
bar_fmt <- green$bold(":elapsedfull | :icon |")
pb <- progress_bar$new(format = bar_fmt, total = n, clear = FALSE)
icon <- progress_bar_icon("fish", n, 75)
for(j in 1:n){
  pb$tick(tokens = list(
    icon = token(icon, j)
  ))
  Sys.sleep(0.03)
}
